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

import {
  AmplifyClient,
  GetAppCommand,
  ListDomainAssociationsCommand,
  GetJobCommand,
} from '@aws-sdk/client-amplify';

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

  // Initialize AWS Amplify client
  const amplifyClient = new AmplifyClient({ region });

  let appName = appId;
  let domainName = null;
  let commitMessage = null;

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
