// index.mjs

/**
 * This function is triggered by AWS EventBridge when ECS service or task state changes.
 * It constructs and sends notification messages to a specified Slack webhook URL.
 *
 * Environment Variables:
 * - SLACK_WEBHOOK_URL: The incoming webhook URL for your Slack channel.
 * - ENVIRONMENT: The environment name to display in notifications.
 * - CLUSTER_NAME: The name of the ECS cluster.
 * - SERVICE_NAME: The name of the ECS service.
 * - DEBUG: Set to 'true' to enable debug logging.
 */

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
 * Determines event severity and returns appropriate formatting
 */
function getEventFormatting(detail, detailType) {
  // Deployment events
  if (detailType === 'ECS Deployment State Change') {
    const { eventName } = detail;
    if (eventName?.includes('COMPLETED')) {
      return { emoji: '✅', color: '#00ff00', severity: 'success' };
    }
    if (eventName?.includes('FAILED')) {
      return { emoji: '❌', color: '#ff0000', severity: 'error' };
    }
    return { emoji: 'ℹ️', color: '#0099ff', severity: 'info' };
  }

  // Task events
  if (detailType === 'ECS Task State Change') {
    const { lastStatus, stopCode, containers } = detail;

    if (lastStatus === 'STOPPED') {
      // Check if it's a critical failure
      const hasNonZeroExit = containers?.some(c => c.exitCode && c.exitCode !== 0);
      const criticalStopCodes = ['TaskFailedToStart', 'ServiceSchedulerInitiated'];

      if (hasNonZeroExit || criticalStopCodes.includes(stopCode)) {
        return { emoji: '❌', color: '#ff0000', severity: 'error' };
      }
      return { emoji: '⚠️', color: '#ffaa00', severity: 'warning' };
    }

    if (lastStatus === 'RUNNING') {
      return { emoji: '✅', color: '#00ff00', severity: 'success' };
    }

    return { emoji: 'ℹ️', color: '#0099ff', severity: 'info' };
  }

  // Service events
  if (detailType === 'ECS Service Action') {
    const { reason } = detail;

    if (reason?.includes('FAILURE')) {
      return { emoji: '❌', color: '#ff0000', severity: 'error' };
    }
    if (reason?.includes('STEADY_STATE')) {
      return { emoji: '✅', color: '#00ff00', severity: 'success' };
    }
    return { emoji: 'ℹ️', color: '#0099ff', severity: 'info' };
  }

  // Default formatting
  return { emoji: 'ℹ️', color: '#0099ff', severity: 'info' };
}

/**
 * Extracts container exit information from stopped task
 */
function getContainerExitInfo(containers) {
  const exitedContainers = containers?.filter(c => c.exitCode !== undefined && c.exitCode !== 0) || [];
  if (exitedContainers.length === 0) return null;

  return exitedContainers.map(c => ({
    name: c.name,
    exitCode: c.exitCode,
    reason: c.reason || 'Unknown'
  }));
}

/**
 * Creates Slack message for deployment events
 */
function createDeploymentMessage(detail, region, formatting, ENV, CLUSTER_NAME, SERVICE_NAME) {
  const { eventName, deploymentId } = detail;
  const consoleUrl = `https://${region}.console.aws.amazon.com/ecs/v2/clusters/${CLUSTER_NAME}/services/${SERVICE_NAME}/deployments`;

  const fields = [
    { type: 'mrkdwn', text: `*Service:* \`${SERVICE_NAME}\`` },
    { type: 'mrkdwn', text: `*Cluster:* \`${CLUSTER_NAME}\`` },
    { type: 'mrkdwn', text: `*Event:* ${eventName || 'Unknown'}` },
  ];

  const blocks = [
    {
      type: 'section',
      fields: fields,
    },
  ];

  blocks.push({
    type: 'actions',
    elements: [
      {
        type: 'button',
        text: {
          type: 'plain_text',
          text: 'View Deployment',
          emoji: true,
        },
        style: formatting.severity === 'error' ? 'danger' : 'primary',
        url: consoleUrl,
        action_id: 'view_deployment_button',
      },
    ],
  });

  blocks.push({
    type: 'context',
    elements: [
      {
        type: 'mrkdwn',
        text: `Region: ${region}`,
      },
    ],
  });

  return {
    text: `${formatting.emoji} ECS Deployment for \`${SERVICE_NAME}\` - ${ENV.toUpperCase()}`,
    attachments: [
      {
        color: formatting.color,
        blocks: blocks,
      },
    ],
  };
}

/**
 * Creates Slack message for task events
 */
function createTaskMessage(detail, region, formatting, ENV, CLUSTER_NAME, SERVICE_NAME) {
  const {
    taskArn,
    lastStatus,
    stopCode,
    stoppedReason,
    containers,
    taskDefinitionArn
  } = detail;

  const taskId = taskArn?.split('/').pop() || 'unknown';
  const taskDefFamily = taskDefinitionArn?.split('/').pop()?.split(':')[0] || 'unknown';
  const consoleUrl = `https://${region}.console.aws.amazon.com/ecs/v2/clusters/${CLUSTER_NAME}/services/${SERVICE_NAME}/tasks/${taskId}/configuration`;

  const fields = [
    { type: 'mrkdwn', text: `*Service:* \`${SERVICE_NAME}\`` },
    { type: 'mrkdwn', text: `*Cluster:* \`${CLUSTER_NAME}\`` },
    { type: 'mrkdwn', text: `*Task:* \`${taskId.substring(0, 13)}...\`` },
    { type: 'mrkdwn', text: `*Status:* ${lastStatus}` },
  ];

  if (stopCode) {
    fields.push({ type: 'mrkdwn', text: `*Stop Code:* ${stopCode}` });
  }

  const blocks = [
    {
      type: 'section',
      fields: fields,
    },
  ];

  if (stoppedReason) {
    blocks.push({
      type: 'section',
      text: {
        type: 'mrkdwn',
        text: `*Reason:* ${stoppedReason}`,
      },
    });
  }

  const containerExits = getContainerExitInfo(containers);
  if (containerExits && containerExits.length > 0) {
    const exitInfo = containerExits
      .map(c => `• *${c.name}*: Exit code ${c.exitCode} - ${c.reason}`)
      .join('\n');
    blocks.push({
      type: 'section',
      text: {
        type: 'mrkdwn',
        text: `*Container Exits:*\n${exitInfo}`,
      },
    });
  }

  blocks.push({
    type: 'actions',
    elements: [
      {
        type: 'button',
        text: {
          type: 'plain_text',
          text: 'View Task Details',
          emoji: true,
        },
        style: formatting.severity === 'error' ? 'danger' : 'primary',
        url: consoleUrl,
        action_id: 'view_task_button',
      },
    ],
  });

  blocks.push({
    type: 'context',
    elements: [
      {
        type: 'mrkdwn',
        text: `Region: ${region} | Task Definition: ${taskDefFamily}`,
      },
    ],
  });

  return {
    text: `ECS Task ${lastStatus} for ${SERVICE_NAME}`,
    attachments: [
      {
        color: formatting.color,
        blocks: blocks,
      },
    ],
  };
}

/**
 * Creates Slack message for service events
 */
function createServiceMessage(detail, region, formatting, ENV, CLUSTER_NAME, SERVICE_NAME) {
  const { eventType, eventName, reason } = detail;
  const consoleUrl = `https://${region}.console.aws.amazon.com/ecs/v2/clusters/${CLUSTER_NAME}/services/${SERVICE_NAME}`;

  return {
    text: `ECS Service Event for ${SERVICE_NAME}`,
    attachments: [
      {
        color: formatting.color,
        blocks: [
          {
            type: 'header',
            text: {
              type: 'plain_text',
              text: `${formatting.emoji} ECS Service Event (${ENV})`,
              emoji: true,
            },
          },
          {
            type: 'section',
            fields: [
              { type: 'mrkdwn', text: `*Service:* \`${SERVICE_NAME}\`` },
              { type: 'mrkdwn', text: `*Cluster:* \`${CLUSTER_NAME}\`` },
              { type: 'mrkdwn', text: `*Event:* ${eventType || eventName || 'Unknown'}` },
            ],
          },
          ...(reason
            ? [
                {
                  type: 'section',
                  text: {
                    type: 'mrkdwn',
                    text: `*Reason:* ${reason}`,
                  },
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
                  text: 'View Service Details',
                  emoji: true,
                },
                style: formatting.severity === 'error' ? 'danger' : 'primary',
                url: consoleUrl,
                action_id: 'view_service_button',
              },
            ],
          },
          {
            type: 'context',
            elements: [
              {
                type: 'mrkdwn',
                text: `Region: ${region}`,
              },
            ],
          },
        ],
      },
    ],
  };
}

/**
 * The main handler for the Lambda function.
 */
export const handler = async (event) => {
  debug.log('Received event:', JSON.stringify(event, null, 2));

  const SLACK_WEBHOOK_URL = process.env.SLACK_WEBHOOK_URL;
  const ENV = process.env.ENVIRONMENT;
  const CLUSTER_NAME = process.env.CLUSTER_NAME;
  const SERVICE_NAME = process.env.SERVICE_NAME;

  if (!SLACK_WEBHOOK_URL) {
    console.error('Error: SLACK_WEBHOOK_URL environment variable is not set.');
    return { statusCode: 500, body: 'SLACK_WEBHOOK_URL is not configured.' };
  }

  const { detail, region = 'us-east-1', 'detail-type': detailType } = event;
  debug.log('Event detail-type:', detailType);

  // Get event formatting
  const formatting = getEventFormatting(detail, detailType);

  // Create appropriate message based on event type
  let slackMessage;

  if (detailType === 'ECS Deployment State Change') {
    slackMessage = createDeploymentMessage(detail, region, formatting, ENV, CLUSTER_NAME, SERVICE_NAME);
  } else if (detailType === 'ECS Task State Change') {
    slackMessage = createTaskMessage(detail, region, formatting, ENV, CLUSTER_NAME, SERVICE_NAME);
  } else if (detailType === 'ECS Service Action') {
    slackMessage = createServiceMessage(detail, region, formatting, ENV, CLUSTER_NAME, SERVICE_NAME);
  } else {
    console.warn('Unknown event type:', detailType);
    return { statusCode: 200, body: 'Event type not handled.' };
  }

  try {
    const response = await fetch(SLACK_WEBHOOK_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(slackMessage),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Slack API error: ${response.status} ${errorText}`);
    }

    return { statusCode: 200, body: 'Notification sent successfully.' };
  } catch (error) {
    console.error('Failed to send message to Slack:', error);
    return { statusCode: 500, body: 'Failed to send notification.' };
  }
};
