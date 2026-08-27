// index.mjs

/**
 * This function is triggered by an AWS EventBridge rule when an AWS Amplify build job
 * changes state. It constructs and sends a notification message to a specified
 * Slack webhook URL.
 *
 * Environment Variables:
 * - SLACK_WEBHOOK_URL: The incoming webhook URL for your Slack channel.
 * - ENVIRONMENT: The environment name to display in notifications.
 * - DEBUG: Set to 'true' to enable debug logging.
 */

// SDK imported lazily in the handler: the zip is this file alone (archive_file source_file),
// so a top-level import would make the pure functions below untestable without the SDK.

const DEBUG = process.env.DEBUG === 'true';

/**
 * Debug logger that only logs when DEBUG is enabled
 */
const debug = {
  log: (...args) => {
    if (DEBUG) {
      console.log('[DEBUG]', ...args);
    }
  },
  warn: (...args) => {
    if (DEBUG) {
      console.warn('[DEBUG]', ...args);
    }
  },
  error: (...args) => {
    if (DEBUG) {
      console.error('[DEBUG]', ...args);
    }
  },
};

// Slack caps a section at 3000 chars. Stay well under it, and cap the line count too:
// build logs can echo build-time env, so an uncapped paste would put it in the channel.
const MAX_ERROR_LINES = 12;
const MAX_DETAIL_CHARS = 1500;
const LOG_FETCH_TIMEOUT_MS = 5000;
// The cause sits above the first [ERROR] and is not tagged as one: an OOM kill logs
// "[WARNING]: 1320 Killed npm run build" while [ERROR] says only "exit code 137".
const ERROR_CONTEXT_LINES = 3;

/**
 * Extracts the failure lines from an Amplify step log.
 *
 * [ERROR] is the only usable discriminator: a build that SUCCEEDS carries 47 [WARNING] lines
 * and zero [ERROR]. With no [ERROR] the shape is unknown, so fall back to the tail and report
 * `source` - a tail is a guess and the caller labels it differently.
 *
 * Returns null when there is nothing to report; a logUrl can serve an empty body.
 */
export function extractFailureDetail(logText, opts = {}) {
  const maxLines = opts.maxLines ?? MAX_ERROR_LINES;
  const maxChars = opts.maxChars ?? MAX_DETAIL_CHARS;
  const contextLines = opts.contextLines ?? ERROR_CONTEXT_LINES;

  if (typeof logText !== 'string') return null;
  const lines = logText.split('\n').map((l) => l.trimEnd()).filter((l) => l.length > 0);
  if (lines.length === 0) return null;

  const isError = (l) => l.includes('[ERROR]');
  const firstError = lines.findIndex(isError);
  const source = firstError === -1 ? 'log-tail' : 'error-lines';

  // Stop at the last [ERROR] so trailing "caching completed" chatter stays out.
  const picked =
    firstError === -1
      ? lines.slice(-maxLines)
      : lines.slice(Math.max(0, firstError - contextLines), lines.findLastIndex(isError) + 1);

  const text = picked.slice(-maxLines).join('\n');
  // Trim from the front: the end of a log is where the cause is.
  return { text: text.length > maxChars ? text.slice(-maxChars) : text, source };
}

// Bounded so a slow S3 read cannot hang the notification.
async function fetchStepLog(url) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), LOG_FETCH_TIMEOUT_MS);
  try {
    const response = await fetch(url, { signal: controller.signal });
    if (!response.ok) return null;
    return await response.text();
  } catch (error) {
    debug.warn('Failed to fetch step log:', error);
    return null;
  } finally {
    clearTimeout(timer);
  }
}

// statusReason first, log scraping only as fallback. Every branch can find nothing: a
// cancelled DEPLOY exposes a logUrl that serves an empty body.
async function describeFailure(job) {
  const failedStep = job?.steps?.find((step) => step.status === 'FAILED');
  if (!failedStep) return null;
  if (failedStep.statusReason) return { text: failedStep.statusReason, source: 'status-reason' };
  if (!failedStep.logUrl) return null;
  return extractFailureDetail(await fetchStepLog(failedStep.logUrl));
}

/**
 * Returns an emoji and a descriptive message based on the job status.
 * @param {string} status - The status of the Amplify build job.
 * @returns {{emoji: string, message: string}} An object containing the emoji and message.
 */
function getStatusInfo(status) {
  switch (status) {
    case 'SUCCEED':
      return { emoji: '✅', message: 'succeeded 🎉' };
    case 'FAILED':
      return { emoji: '❌', message: 'failed 😢' };
    case 'STARTED':
      return { emoji: '🚀', message: 'started' };
    default:
      return { emoji: 'ℹ️', message: status || 'unknown' };
  }
}

/**
 * The main handler for the Lambda function.
 * @param {object} event - The event payload from AWS EventBridge.
 * @returns {Promise<{statusCode: number, body: string}>} The response object.
 */
export const handler = async (event) => {
  debug.log('Received event:', JSON.stringify(event, null, 2));

  // Retrieve environment variables
  const SLACK_WEBHOOK_URL = process.env.SLACK_WEBHOOK_URL;
  const ENV = process.env.ENVIRONMENT;

  if (!SLACK_WEBHOOK_URL) {
    console.error('Error: SLACK_WEBHOOK_URL environment variable is not set.');
    return { statusCode: 500, body: 'SLACK_WEBHOOK_URL is not configured.' };
  }

  const { detail, region = 'us-east-1' } = event;
  const { appId, branchName, jobStatus, jobId } = detail || {};

  debug.log('Extracted details:', { appId, branchName, jobStatus, jobId, region });

  const { AmplifyClient, GetAppCommand, ListDomainAssociationsCommand, GetJobCommand } =
    await import('@aws-sdk/client-amplify');
  const amplifyClient = new AmplifyClient({ region });

  let appName = appId;
  let domainName = null;
  let commitMessage = null;
  let failureDetail = null;

  try {
    // Get the Amplify app details to fetch the app name
    const getAppCommand = new GetAppCommand({ appId });
    const appResponse = await amplifyClient.send(getAppCommand);
    appName = appResponse.app?.name || appId;

    debug.log('appResponse:', JSON.stringify(appResponse, null, 2));

    // Get domain associations for the app
    const listDomainsCommand = new ListDomainAssociationsCommand({ appId });
    const domainsResponse = await amplifyClient.send(listDomainsCommand);

    debug.log('domainsResponse:', JSON.stringify(domainsResponse, null, 2));

    if (domainsResponse.domainAssociations && domainsResponse.domainAssociations.length > 0) {
      // Get the first domain association
      domainName = domainsResponse.domainAssociations[0].domainName;
    }

    // Get job details to fetch commit information
    if (jobId) {
      const getJobCommand = new GetJobCommand({ appId, branchName, jobId });
      const jobResponse = await amplifyClient.send(getJobCommand);

      debug.log('jobResponse:', JSON.stringify(jobResponse, null, 2));

      // Extract commit message from job details
      commitMessage = jobResponse.job?.summary?.commitMessage || jobResponse.job?.commitMessage;

      // Same response already carries the step list, so the reason costs no extra API call.
      if (jobStatus === 'FAILED') {
        failureDetail = await describeFailure(jobResponse.job);
      }
    }
  } catch (error) {
    debug.warn('Failed to fetch app details, domains, or job info:', error);
    // Continue with available data as fallback
  }

  // Construct the URL to view the build in the AWS Amplify Console
  const buildUrl = `https://${region}.console.aws.amazon.com/amplify/apps/${appId}/branches/${branchName}/deployments`;

  // Get appropriate status info (emoji and message)
  const { emoji, message } = getStatusInfo(jobStatus);

  // Create the Slack message payload using Block Kit for rich formatting
  const slackMessage = {
    text: `Amplify Build for ${branchName || 'unknown branch'} ${message}`, // Fallback text for notifications
    blocks: [
      {
        type: 'header',
        text: {
          type: 'plain_text',
          text: `${emoji} Amplify Build ${message} (${ENV})`,
          emoji: true,
        },
      },
      {
        type: 'section',
        fields: [
          { type: 'mrkdwn', text: `*App Name:* \`${appName || 'unknown'}\`` },
          { type: 'mrkdwn', text: `*Branch:* \`${branchName || 'unknown'}\`` },
          ...(domainName ? [{ type: 'mrkdwn', text: `*Domain:* https://${domainName}` }] : []),
        ],
      },
      ...(failureDetail
        ? [
            {
              type: 'section',
              text: {
                type: 'mrkdwn',
                text: `*${
                  failureDetail.source === 'log-tail' ? 'Last log lines' : 'Failure'
                }:*\n\`\`\`${failureDetail.text}\`\`\``,
              },
            },
          ]
        : []),
      ...(commitMessage
        ? [
            {
              type: 'context',
              elements: [{ type: 'mrkdwn', text: `*Commit:* ${commitMessage}` }],
            },
          ]
        : []),
      {
        type: 'actions',
        elements: [
          {
            type: 'button',
            text: {
              type: 'plain_text',
              text: 'View Build Details',
              emoji: true,
            },
            style: 'primary',
            url: buildUrl,
            action_id: 'view_build_button', // action_id is required for buttons in actions blocks
          },
        ],
      },
      {
        type: 'context',
        elements: [
          {
            type: 'mrkdwn',
            text: `Occurred in region: ${region}`,
          },
        ],
      },
    ],
  };

  try {
    // Send the message to Slack using the native fetch API
    const response = await fetch(SLACK_WEBHOOK_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(slackMessage),
    });

    if (!response.ok) {
      // If the response is not OK, throw an error to be caught by the catch block
      const errorText = await response.text();
      throw new Error(`Slack API error: ${response.status} ${errorText}`);
    }

    return { statusCode: 200, body: 'Notification sent successfully.' };
  } catch (error) {
    console.error('Failed to send message to Slack:', error);
    return { statusCode: 500, body: 'Failed to send notification.' };
  }
};
