#!/usr/bin/env node
/**
 * Create GA4 Event Tags for The Wonder Project
 *
 * Container: GTM-KV4V3H8W
 * Account: 6251408418
 * Container ID: 196424732
 * Workspace: 8 (GA4)
 */

import { executeTool } from './dist/agent-sdk-export.js';

const config = {
  accountId: '6251408418',
  containerId: '196424732',
  workspaceId: '8'
};

// Tags to create
const tags = [
  {
    name: 'GA4 - Sticky Trial Click',
    type: 'gaawe',
    parameter: [
      { type: 'tagReference', key: 'measurementId', value: 'Google tag' },
      { type: 'template', key: 'eventName', value: 'free_trial_click' },
      { type: 'list', key: 'eventParameters', list: [
        { type: 'map', map: [
          { type: 'template', key: 'name', value: 'button_location' },
          { type: 'template', key: 'value', value: 'sticky' }
        ]}
      ]}
    ],
    firingTriggerId: ['18']
  },
  {
    name: 'GA4 - Plan Selection',
    type: 'gaawe',
    parameter: [
      { type: 'tagReference', key: 'measurementId', value: 'Google tag' },
      { type: 'template', key: 'eventName', value: 'plan_selection' },
      { type: 'list', key: 'eventParameters', list: [
        { type: 'map', map: [
          { type: 'template', key: 'name', value: 'plan_type' },
          { type: 'template', key: 'value', value: '{{Click Text}}' }
        ]}
      ]}
    ],
    firingTriggerId: ['19']
  },
  {
    name: 'GA4 - Email Signup',
    type: 'gaawe',
    parameter: [
      { type: 'tagReference', key: 'measurementId', value: 'Google tag' },
      { type: 'template', key: 'eventName', value: 'generate_lead' },
      { type: 'list', key: 'eventParameters', list: [
        { type: 'map', map: [
          { type: 'template', key: 'name', value: 'form_name' },
          { type: 'template', key: 'value', value: 'email_newsletter' }
        ]}
      ]}
    ],
    firingTriggerId: ['20']
  },
  {
    name: 'GA4 - Outbound Amazon Click',
    type: 'gaawe',
    parameter: [
      { type: 'tagReference', key: 'measurementId', value: 'Google tag' },
      { type: 'template', key: 'eventName', value: 'outbound_click' },
      { type: 'list', key: 'eventParameters', list: [
        { type: 'map', map: [
          { type: 'template', key: 'name', value: 'link_domain' },
          { type: 'template', key: 'value', value: 'amazon.com' }
        ]},
        { type: 'map', map: [
          { type: 'template', key: 'name', value: 'link_url' },
          { type: 'template', key: 'value', value: '{{Click URL}}' }
        ]},
        { type: 'map', map: [
          { type: 'template', key: 'name', value: 'outbound' },
          { type: 'template', key: 'value', value: 'true' }
        ]}
      ]}
    ],
    firingTriggerId: ['21']
  },
  {
    name: 'GA4 - Scroll Depth',
    type: 'gaawe',
    parameter: [
      { type: 'tagReference', key: 'measurementId', value: 'Google tag' },
      { type: 'template', key: 'eventName', value: 'scroll' },
      { type: 'list', key: 'eventParameters', list: [
        { type: 'map', map: [
          { type: 'template', key: 'name', value: 'percent_scrolled' },
          { type: 'template', key: 'value', value: '{{Scroll Depth Threshold}}' }
        ]}
      ]}
    ],
    firingTriggerId: ['22']
  },
  {
    name: 'GA4 - Video Engagement',
    type: 'gaawe',
    parameter: [
      { type: 'tagReference', key: 'measurementId', value: 'Google tag' },
      { type: 'template', key: 'eventName', value: 'video_progress' },
      { type: 'list', key: 'eventParameters', list: [
        { type: 'map', map: [
          { type: 'template', key: 'name', value: 'video_title' },
          { type: 'template', key: 'value', value: '{{Video Title}}' }
        ]},
        { type: 'map', map: [
          { type: 'template', key: 'name', value: 'video_percent' },
          { type: 'template', key: 'value', value: '{{Video Percent}}' }
        ]},
        { type: 'map', map: [
          { type: 'template', key: 'name', value: 'video_status' },
          { type: 'template', key: 'value', value: '{{Video Status}}' }
        ]}
      ]}
    ],
    firingTriggerId: ['23']
  }
];

async function createTags() {
  console.log('Creating GA4 Event Tags...\n');

  const results = [];

  for (const tag of tags) {
    console.log(`Creating: ${tag.name}...`);
    try {
      const result = await executeTool('gtm_tag', {
        action: 'create',
        ...config,
        config: tag
      });

      const data = JSON.parse(result.content[0].text);
      if (data.tag) {
        console.log(`  ✅ Created tag ID: ${data.tag.tagId}`);
        results.push({ name: tag.name, id: data.tag.tagId, success: true });
      } else {
        console.log(`  ❌ Error: ${JSON.stringify(data)}`);
        results.push({ name: tag.name, error: data, success: false });
      }
    } catch (err) {
      console.log(`  ❌ Error: ${err.message}`);
      results.push({ name: tag.name, error: err.message, success: false });
    }
  }

  console.log('\n--- Summary ---');
  const successful = results.filter(r => r.success);
  const failed = results.filter(r => !r.success);

  console.log(`✅ Created: ${successful.length} tags`);
  successful.forEach(r => console.log(`   - ${r.name} (ID: ${r.id})`));

  if (failed.length > 0) {
    console.log(`❌ Failed: ${failed.length} tags`);
    failed.forEach(r => console.log(`   - ${r.name}: ${r.error}`));
  }
}

createTags().catch(console.error);