# Phase 5: Integration Testing & Cross-Plugin Orchestration

## Claude Code Prompt

```
claude --dangerously-skip-permissions

Test the three OpenClaw plugins together by running a simulated deployment against a real GTM container. Use GTM-KV4V3H8W (Wonder Project) as the test target.

## 1. Plugin Connectivity Test

For each plugin, verify MCP tool access:

### openclaw-gtm
1. gtm_account action:list — Should return accounts
2. gtm_container action:list accountId:{ACCOUNT_ID} — Should return containers including GTM-KV4V3H8W
3. gtm_workspace action:list accountId:{ACCOUNT_ID} containerId:{CONTAINER_ID} — Should return workspaces
4. stape_container_crud action:get_all — Should return Stape containers

### openclaw-google-ads
1. list-accounts — Should return Google Ads accounts
2. google-ads-download-report with GAQL: "SELECT customer.id, customer.descriptive_name FROM customer LIMIT 1" — Should return account info

### openclaw-meta
1. Same GTM MCP tests as openclaw-gtm (shared MCP)
2. Same Stape MCP tests as openclaw-gtm (shared MCP)
3. Note: Pipeboard Meta MCP needs separate connection setup

## 2. Dry-Run Deployment Test

Using GTM-KV4V3H8W, run a READ-ONLY audit flow:

### Step 1: GTM Audit (openclaw-gtm)
```
Run gtm-audit command:
1. gtm_workspace action:list — Get current workspaces
2. gtm_tag action:list — List all tags
3. gtm_trigger action:list — List all triggers
4. gtm_variable action:list — List all variables
5. gtm_built_in_variable action:list — List enabled built-ins
6. gtm_folder action:list — List folders
7. gtm_version_header action:latest — Get current live version
```

### Step 2: Google Ads Audit (openclaw-google-ads)
```
Run gads-audit command:
1. list-accounts — Find Wonder Project account
2. google-ads-download-report — Run conversion_action query
3. google-ads-download-report — Run customer settings query
4. Generate audit report
```

### Step 3: Meta Audit (openclaw-meta)
```
Run meta-audit command:
1. gtm_tag action:list — Filter for Meta/Facebook tags
2. Check sGTM for CAPI configuration
3. Verify event_id handling
4. Generate coverage report
```

## 3. Cross-Plugin Workflow Test

Test the handoff between plugins:

### Scenario: Deploy tracking for a new page
1. openclaw-google-ads generates conversion specs
2. openclaw-meta generates Pixel + CAPI event specs
3. openclaw-gtm receives both specs and deploys:
   - Variables (GA4 ID, Pixel ID, event_id generator)
   - Triggers (page view, CTA clicks, form submit)
   - Tags (GA4 events, Google Ads conversion, Meta Pixel, Meta CAPI)
   - Folder organization

### Verification:
1. All tags reference valid triggers
2. All variables exist and are referenced
3. Naming conventions are consistent across platforms
4. Event_id is used in both Meta Pixel and CAPI tags
5. Pre-publish audit passes

## 4. Generate Integration Report

Create DOCUMENTATION/integration-test-report.md with:
- Plugin connectivity status (pass/fail per MCP tool)
- Audit results for each plugin
- Cross-plugin workflow validation
- Missing capabilities or connection gaps
- Recommendations for next steps

## 5. PLUGIN.md and README.md

For each of the three plugins, write comprehensive:

### PLUGIN.md (each plugin)
- Plugin name and version
- Description of autonomous capabilities
- MCP tools used with link to documentation
- Commands available
- Hooks defined
- Skills included
- OpenClaw integration points
- Installation instructions (reference install.sh)
- Dependencies on other plugins

### README.md (each plugin)
- Quick start guide
- Prerequisites (API keys, MCP connections)
- Usage examples
- Architecture diagram (ASCII)
- Troubleshooting guide

## Verification

After integration testing:
1. All 3 plugins successfully connect to their MCP tools
2. GTM audit returns data from GTM-KV4V3H8W
3. Google Ads audit returns data from accessible accounts
4. Meta audit correctly identifies Pixel-related tags
5. Cross-plugin deployment spec is valid
6. Pre-publish audit catches any issues
7. All PLUGIN.md and README.md files are comprehensive
8. integration-test-report.md is generated
```

## Environment Variables for Claude Code Web

```
STAPE_API_KEY=<your-stape-key>
GOOGLE_ADS_DEVELOPER_TOKEN=<your-dev-token>
GOOGLE_ADS_LOGIN_CUSTOMER_ID=<your-login-cid>
META_PIXEL_ID=<your-pixel-id>
META_ACCESS_TOKEN=<your-meta-token>
```