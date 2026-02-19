# Phase 0: Scaffold All Three Plugins

## Claude Code Prompt

```
claude --dangerously-skip-permissions

Create three Claude Code plugin scaffolds in the plugin-marketplace/ directory. Use the existing gtm-ai-plugin/ as the structural template. Do NOT delete or modify gtm-ai-plugin.

## Plugin 1: openclaw-google-ads

Create plugin-marketplace/openclaw-google-ads/ with this structure:

.claude-plugin/plugin.json:
{
  "name": "openclaw-google-ads",
  "description": "Autonomous Google Ads conversion tracking builder. Audits existing conversion actions via GAQL, generates deployment configurations, and validates tracking implementation.",
  "version": "1.0.0",
  "author": "BHT Labs"
}

mcp-servers.json:
{
  "mcpServers": {
    "google-ads-mcp": {
      "command": "npx",
      "args": ["-y", "@anthropic/google-ads-mcp"],
      "env": {
        "GOOGLE_ADS_DEVELOPER_TOKEN": "${GOOGLE_ADS_DEVELOPER_TOKEN}",
        "GOOGLE_ADS_LOGIN_CUSTOMER_ID": "${GOOGLE_ADS_LOGIN_CUSTOMER_ID}"
      }
    }
  }
}

Create these empty/placeholder files:
- skills/google-ads-builder/SKILL.md (placeholder: "# Google Ads Builder Skill")
- skills/google-ads-builder/references/conversion-types.md
- skills/google-ads-builder/references/gaql-patterns.md
- skills/google-ads-builder/references/naming-conventions.md
- agents/google-ads-agent.md
- commands/gads-audit.md
- commands/gads-deploy.md
- commands/gads-status.md
- hooks/hooks.json (empty array: [])
- hooks/pre-deploy-validation.md
- hooks/post-deploy-verification.md
- templates/conversion-action.template.json
- templates/remarketing-audience.template.json
- planning/IMPLEMENTATION-MASTER-PLAN.md
- openclaw/TOOLS.md
- openclaw/HEARTBEAT-ENTRIES.md
- openclaw/SCOPE-PHASE.md
- PLUGIN.md (placeholder with plugin name and description)
- README.md (placeholder)

Create install.sh that:
1. Checks for required env vars (GOOGLE_ADS_DEVELOPER_TOKEN, GOOGLE_ADS_LOGIN_CUSTOMER_ID)
2. Verifies Google Ads MCP connectivity by listing accounts
3. Copies plugin files to .claude/ directory
4. Makes it executable (chmod +x)

## Plugin 2: openclaw-meta

Create plugin-marketplace/openclaw-meta/ with this structure:

.claude-plugin/plugin.json:
{
  "name": "openclaw-meta",
  "description": "Autonomous Meta Pixel and Conversions API tracking builder. Deploys dual-tracking (client Pixel + server CAPI) via GTM and sGTM with event deduplication.",
  "version": "1.0.0",
  "author": "BHT Labs"
}

mcp-servers.json:
{
  "mcpServers": {
    "google-tag-manager-mcp-server": {
      "type": "url",
      "url": "https://gtm-mcp.stape.ai/mcp"
    },
    "stape-mcp-server": {
      "type": "sse",
      "url": "https://mcp.stape.ai/sse",
      "headers": {
        "x-api-key": "${STAPE_API_KEY}"
      }
    }
  }
}

Create these empty/placeholder files:
- skills/meta-tracking-builder/SKILL.md
- skills/meta-tracking-builder/references/standard-events.md
- skills/meta-tracking-builder/references/capi-parameters.md
- skills/meta-tracking-builder/references/deduplication-guide.md
- skills/meta-tracking-builder/references/naming-conventions.md
- agents/meta-tracking-agent.md
- commands/meta-audit.md
- commands/meta-deploy.md
- commands/meta-test-events.md
- commands/meta-status.md
- hooks/hooks.json
- hooks/pre-deploy-validation.md
- hooks/post-deploy-verification.md
- hooks/event-dedup-check.md
- templates/pixel-tag.template.json
- templates/capi-client.template.json
- templates/event-mapping.template.json
- planning/IMPLEMENTATION-MASTER-PLAN.md
- openclaw/TOOLS.md
- openclaw/HEARTBEAT-ENTRIES.md
- openclaw/SCOPE-PHASE.md
- PLUGIN.md
- README.md

Create install.sh that:
1. Checks for STAPE_API_KEY
2. Verifies GTM MCP and Stape MCP connectivity
3. Notes Pipeboard Meta MCP as optional enhancement
4. Copies plugin files

## Plugin 3: openclaw-gtm

Create plugin-marketplace/openclaw-gtm/ with this structure:

.claude-plugin/plugin.json:
{
  "name": "openclaw-gtm",
  "description": "Enhanced GTM orchestrator. Builds complete tracking configurations across web and server-side containers using Stape GTM MCP. Multi-platform tag deployment with pre-publish auditing.",
  "version": "1.0.0",
  "author": "BHT Labs"
}

mcp-servers.json (same GTM + Stape config as openclaw-meta)

Create these empty/placeholder files:
- skills/gtm-enhanced-builder/SKILL.md
- skills/gtm-enhanced-builder/references/tag-types.md
- skills/gtm-enhanced-builder/references/trigger-patterns.md
- skills/gtm-enhanced-builder/references/variable-types.md
- skills/gtm-enhanced-builder/references/sgtm-correlation.md
- skills/gtm-enhanced-builder/references/naming-conventions.md
- agents/gtm-orchestrator-agent.md
- commands/gtm-build.md
- commands/gtm-audit.md
- commands/gtm-publish.md
- commands/gtm-rollback.md
- commands/gtm-status.md
- hooks/hooks.json
- hooks/pre-publish-audit.md
- hooks/post-phase.md
- hooks/pre-phase.md
- hooks/ascii-diagram-generator.md
- templates/ga4-config.template.json
- templates/phase-state.template.json
- templates/config.template.json
- planning/IMPLEMENTATION-MASTER-PLAN.md
- openclaw/TOOLS.md
- openclaw/HEARTBEAT-ENTRIES.md
- openclaw/SCOPE-PHASE.md
- PLUGIN.md
- README.md

Create install.sh that:
1. Checks for STAPE_API_KEY
2. Verifies both GTM MCP and Stape MCP
3. Lists available GTM accounts/containers
4. Copies plugin files

## Verification

After creating all three plugins:
1. Verify each has a valid plugin.json
2. Verify each has an install.sh
3. Count total files created per plugin
4. Run: find plugin-marketplace/openclaw-* -type f | wc -l
```

## Environment Variables for Claude Code Web

```
STAPE_API_KEY=<your-stape-key>
GOOGLE_ADS_DEVELOPER_TOKEN=<your-dev-token>
GOOGLE_ADS_LOGIN_CUSTOMER_ID=<your-login-cid>
```