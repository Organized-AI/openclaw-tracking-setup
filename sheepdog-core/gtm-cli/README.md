# BLADE GTM MCP Server

Local MCP server for Google Tag Manager operations using OAuth authentication.

## Features

- **7 GTM Tools**: template, variable, tag, trigger, workspace, version, version-header
- **OAuth Authentication**: Uses your Google account (no service account required)
- **Auto Token Refresh**: Refresh tokens are stored and auto-renewed
- **Agent SDK Compatible**: Export tools for Claude Agent SDK

## Prerequisites

OAuth setup must be completed first:
```bash
cd ../oauth-setup
npm install
npm run auth    # Authenticate with your GTM-linked Google account
npm run verify  # Verify GTM access
```

## Installation

```bash
npm install
```

## Usage

### Development Mode

```bash
npm run dev
```

### Production Mode

```bash
npm run build
npm start
```

### Run Tests

```bash
npm test
```

### Verification Loop

Run comprehensive verification to ensure everything works:

```bash
# Full verification (auth + all 7 tools)
npm run verify

# Quick mode (auth only)
npm run verify:quick
```

The verification loop checks:
1. OAuth configuration and credentials
2. Token validity and refresh capability
3. API connection to Google Tag Manager
4. All 7 tools with actual API calls
5. Response validation

Example output:
```
╔══════════════════════════════════════════════════════════════╗
║        BLADE GTM MCP Server - Verification Loop              ║
╚══════════════════════════════════════════════════════════════╝

📋 Phase 1: Authentication
✅ OAuth Configuration (12ms)
✅ Auth Status (5ms)
✅ API Connection (342ms)

📋 Phase 2: Tool Verification
✅ gtm_template (list) (187ms)
✅ gtm_variable (list) (156ms)
✅ gtm_tag (list) (201ms)
✅ gtm_trigger (list) (143ms)
✅ gtm_workspace (getStatus) (178ms)
✅ gtm_version_header (latest) (132ms)
✅ gtm_version (live) (198ms)

📊 Verification Summary
   Total:   10
   Passed:  10 ✅
   Failed:  0 ❌

🎉 All verifications passed! blade-gtm-mcp is ready to use.
```

## Tools

| Tool | Description |
|------|-------------|
| `gtm_template` | Manage custom templates (install from Gallery) |
| `gtm_variable` | Create/manage variables |
| `gtm_tag` | Create/manage tags |
| `gtm_trigger` | List/manage triggers |
| `gtm_workspace` | Workspace operations (status, sync, preview) |
| `gtm_version` | Create versions and publish |
| `gtm_version_header` | List version headers (for rollback) |

## Claude Code Integration

Add to your project's `.claude/settings.json`:

```json
{
  "mcpServers": {
    "blade-gtm": {
      "command": "node",
      "args": ["./mcp-servers/blade-gtm-mcp/dist/index.js"]
    }
  }
}
```

Or for development:

```json
{
  "mcpServers": {
    "blade-gtm": {
      "command": "npx",
      "args": ["tsx", "./mcp-servers/blade-gtm-mcp/src/index.ts"]
    }
  }
}
```

## Agent SDK Usage

```typescript
import { bladeGtmTools, createToolHandler } from './mcp-servers/blade-gtm-mcp/src/agent-sdk-export.js';

// Use with Agent SDK
const agent = new Agent({
  tools: bladeGtmTools,
  toolHandler: createToolHandler(),
});

// Or execute tools directly
import { executeTool } from './mcp-servers/blade-gtm-mcp/src/agent-sdk-export.js';

const result = await executeTool('gtm_template', {
  action: 'list',
  accountId: '4702245012',
  containerId: '42412215',
  workspaceId: '86',
});
```

## BLADE Configuration

Default BLADE container configuration:

```javascript
const BLADE_CONFIG = {
  accountId: '4702245012',
  containerId: '42412215',      // GTM-W9S77T7
  workspaceId: '86',
};
```

## Project Structure

```
blade-gtm-mcp/
├── src/
│   ├── index.ts              # MCP server entry point
│   ├── agent-sdk-export.ts   # Agent SDK compatible exports
│   ├── test.ts               # Basic test script
│   ├── verify.ts             # Comprehensive verification loop
│   ├── tools/
│   │   ├── index.ts          # Tool exports
│   │   ├── template.ts       # GTM template operations
│   │   ├── variable.ts       # GTM variable operations
│   │   ├── tag.ts            # GTM tag operations
│   │   ├── trigger.ts        # GTM trigger operations
│   │   ├── workspace.ts      # Workspace status/sync
│   │   ├── version.ts        # Version create/publish
│   │   └── version-header.ts # Version headers for rollback
│   └── utils/
│       ├── auth.ts           # OAuth authentication
│       └── response.ts       # MCP response formatting
├── dist/                     # Compiled JavaScript (after build)
├── package.json
├── tsconfig.json
└── README.md
```

## Authentication

Uses OAuth tokens from `../oauth-setup/`:
- `client_secret.json` - OAuth client credentials
- `tokens.json` - Access and refresh tokens

Tokens auto-refresh when expired. If you see `invalid_grant` errors, re-run `npm run auth` in oauth-setup.