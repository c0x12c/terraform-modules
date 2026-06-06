#!/usr/bin/env node

import { readFileSync, writeFileSync } from 'fs';
import { createInterface } from 'readline';
import { handler } from './files/index.mjs';

const rl = createInterface({
  input: process.stdin,
  output: process.stdout
});

function askQuestion(question) {
  return new Promise((resolve) => {
    rl.question(question, resolve);
  });
}

async function main() {
  console.log('Lambda Function Local Testing\n');

  // Get user inputs
  const appId = await askQuestion('Enter Amplify App ID: ');
  const slackWebhookUrl = await askQuestion('Enter Slack Webhook URL: ');
  const environment = await askQuestion('Enter Environment (default: development): ') || 'development';

  // Set up environment variables
  process.env.SLACK_WEBHOOK_URL = slackWebhookUrl;
  process.env.ENVIRONMENT = environment;

  // Load and modify test event with user-provided appId
  const testEvent = JSON.parse(readFileSync('./test-event.json', 'utf8'));
  testEvent.detail.appId = appId;
  testEvent.resources = [`arn:aws:amplify:us-east-1:123456789012:apps/${appId}/branches/main/jobs/1`];

  console.log('\nRunning Lambda function with:');
  console.log('- App ID:', appId);
  console.log('- Environment:', environment);
  console.log('- Test Event:', JSON.stringify(testEvent, null, 2));
  console.log('\n--- Lambda Execution ---');

  try {
    const result = await handler(testEvent);
    console.log('\n--- Result ---');
    console.log('Lambda function result:', result);
  } catch (error) {
    console.error('\n--- Error ---');
    console.error('Error running Lambda function:', error);
  } finally {
    rl.close();
  }
}

main();