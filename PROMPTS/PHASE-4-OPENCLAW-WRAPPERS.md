# Phase 4: OpenClaw Workspace Wrappers

## Claude Code Prompt

```
claude --dangerously-skip-permissions

Create OpenClaw workspace integration files for all three plugins. These wrappers connect each plugin to OpenClaw's persistent agent architecture (HEARTBEAT.md, STRATEGY-DESK.md, TOOLS.md, SCOPE.md).

## Understanding OpenClaw Architecture

OpenClaw uses these core files for persistent agent state:
- TOOLS.md — Available tools, API keys, MCP configs
- HEARTBEAT.md — Scheduled recurring tasks (SANDBOX mode = read/draft only)
- SCOPE.md — Phased project checklist with completion tracking
- STRATEGY-DESK.md — Active priorities, open loops, decisions

Each plugin creates entries for all four files.

## 1. openclaw-google-ads/openclaw/

### TOOLS.md
```markdown
# Google Ads MCP Tools

## Connection
- MCP Server: Google Ads MCP
- Auth: Developer Token + Login Customer ID
- Mode: READ-ONLY (GAQL queries via download-report)

## Available Tools
| Tool | Purpose | Risk Level |
|------|---------|------------|
| list-accounts | List all accessible Google Ads accounts | LOW |
| google-ads-download-report | Execute GAQL queries for reporting/audit | LOW |

## Environment
```env
GOOGLE_ADS_DEVELOPER_TOKEN=<token>
GOOGLE_ADS_LOGIN_CUSTOMER_ID=<login-cid>
```

## Key GAQL Queries
- Conversion action audit: `SELECT conversion_action.* FROM conversion_action`
- Performance check: `SELECT metrics.conversions FROM conversion_action WHERE segments.date DURING LAST_30_DAYS`
- Account health: `SELECT customer.* FROM customer LIMIT 1`

## Integration Points
- Outputs feed into openclaw-gtm for tag deployment
- Conversion specs → GTM tag configurations
```

### HEARTBEAT-ENTRIES.md
```markdown
## Google Ads Tracking Audit

### Weekly: Conversion Action Health Check
- **Frequency**: Every Monday
- **Mode**: SANDBOX (read + draft only)
- **Actions**:
  1. Run GAQL conversion_action query across active accounts
  2. Flag any conversion actions with status != ENABLED
  3. Check for conversion actions with 0 conversions in last 14 days
  4. Draft alert if anomalies found
  5. Save report to memory/YYYY-MM-DD.md

### Monthly: Full Tracking Audit
- **Frequency**: First Monday of month
- **Mode**: SANDBOX
- **Actions**:
  1. Run full gads-audit command for each active account
  2. Compare conversion action count vs previous month
  3. Review attribution model settings
  4. Check Enhanced Conversions status
  5. Generate audit report to DOCUMENTATION/
  6. Draft recommendations for STRATEGY-DESK.md
```

### SCOPE-PHASE.md
```markdown
## Google Ads Tracking — Scope Phase

### Phase 1: Foundation
- [ ] Verify Google Ads MCP connection
- [ ] List all accessible accounts
- [ ] Run initial audit on primary account
- [ ] Document current conversion actions
- [ ] Verify auto-tagging is enabled

### Phase 2: Conversion Mapping
- [ ] Analyze target website for conversion events
- [ ] Map site events to Google Ads conversion categories
- [ ] Define conversion values and counting methods
- [ ] Generate conversion action specifications
- [ ] Review with stakeholder

### Phase 3: GTM Deployment
- [ ] Generate GTM tag configurations
- [ ] Hand off to openclaw-gtm for deployment
- [ ] Deploy Conversion Linker tag
- [ ] Deploy conversion tracking tags
- [ ] Deploy remarketing tag

### Phase 4: Verification
- [ ] Verify conversion actions receiving data
- [ ] Check attribution model settings
- [ ] Validate Enhanced Conversions if applicable
- [ ] Run post-deployment audit
- [ ] Archive to memory
```

## 2. openclaw-meta/openclaw/

### TOOLS.md
```markdown
# Meta Tracking MCP Tools

## Connections
- GTM MCP (Stape): For deploying Pixel tags in web container
- Stape MCP: For configuring sGTM CAPI
- Pipeboard Meta MCP: For Meta API queries (optional)

## Available Tools — GTM MCP
| Tool | Purpose | Risk Level |
|------|---------|------------|
| gtm_tag | Create/manage Pixel event tags | MEDIUM |
| gtm_trigger | Create triggers for Meta events | MEDIUM |
| gtm_variable | Create event_id, Pixel ID variables | LOW |
| gtm_workspace | Manage deployment workspaces | LOW |
| gtm_version | Version and publish | HIGH |

## Available Tools — Stape MCP
| Tool | Purpose | Risk Level |
|------|---------|------------|
| stape_container_crud | Manage sGTM containers | MEDIUM |
| stape_container_power_ups | Enable cookie_keeper for _fbc/_fbp | LOW |
| stape_container_domains | Configure sGTM domains | MEDIUM |

## Environment
```env
STAPE_API_KEY=<key>
META_PIXEL_ID=<pixel-id>
META_ACCESS_TOKEN=<token>
```

## Integration Points
- Depends on openclaw-gtm for GTM operations
- Uses event_id pattern for deduplication
- sGTM receives forwarded Pixel events
```

### HEARTBEAT-ENTRIES.md
```markdown
## Meta Tracking Health Check

### Weekly: Pixel + CAPI Status
- **Frequency**: Every Monday
- **Mode**: SANDBOX
- **Actions**:
  1. List Meta-related tags in GTM container
  2. Verify Pixel base code tag is active
  3. Check sGTM container status
  4. Verify cookie_keeper is enabled for Meta
  5. Draft status report

### Monthly: Event Coverage Audit
- **Frequency**: First Monday of month
- **Mode**: SANDBOX
- **Actions**:
  1. List all Meta event tags (Pixel + CAPI)
  2. Cross-reference with standard events catalog
  3. Identify missing events for client business type
  4. Check deduplication health (event_id present on all events)
  5. Generate coverage report
  6. Draft recommendations
```

### SCOPE-PHASE.md
```markdown
## Meta Tracking — Scope Phase

### Phase 1: Foundation
- [ ] Verify GTM MCP and Stape MCP connections
- [ ] Confirm Meta Pixel ID
- [ ] Audit existing Meta tracking in GTM container
- [ ] Check sGTM container for existing CAPI setup
- [ ] Document current state

### Phase 2: Client-Side Pixel
- [ ] Create event_id generator variable
- [ ] Deploy Pixel base code tag
- [ ] Create Pixel ID constant variable
- [ ] Map site events to Meta standard events
- [ ] Create event-specific Pixel tags with event_id
- [ ] Create corresponding triggers

### Phase 3: Server-Side CAPI
- [ ] Verify sGTM container is running
- [ ] Enable cookie_keeper for _fbc and _fbp
- [ ] Deploy Meta CAPI client in sGTM
- [ ] Deploy Meta CAPI tags for each event
- [ ] Configure event_id forwarding for dedup
- [ ] Set up user_data enrichment (IP, UA, cookies)

### Phase 4: Verification
- [ ] Test Pixel fires in GTM Preview mode
- [ ] Verify CAPI events in Meta Events Manager
- [ ] Confirm deduplication is working (no double-counting)
- [ ] Check Event Match Quality score
- [ ] Run full meta-audit command
- [ ] Archive to memory
```

## 3. openclaw-gtm/openclaw/

### TOOLS.md
```markdown
# GTM MCP Tools (Full Suite)

## Connections
- GTM MCP (Stape): Full GTM container management
- Stape MCP: sGTM container management

## Available Tools — GTM MCP
| Tool | Purpose | Risk Level |
|------|---------|------------|
| gtm_account | List/get accounts | LOW |
| gtm_container | List/get/create containers | MEDIUM |
| gtm_workspace | Create/manage workspaces | LOW |
| gtm_tag | CRUD for all tag types | MEDIUM |
| gtm_trigger | CRUD for all trigger types | MEDIUM |
| gtm_variable | CRUD for all variable types | LOW |
| gtm_built_in_variable | Enable/disable built-ins | LOW |
| gtm_folder | Organize entities | LOW |
| gtm_template | Manage custom templates | MEDIUM |
| gtm_client | Manage sGTM clients | MEDIUM |
| gtm_transformation | Manage transformations | MEDIUM |
| gtm_version | Version management | HIGH |
| gtm_version_header | Version history | LOW |

## Available Tools — Stape MCP
| Tool | Purpose | Risk Level |
|------|---------|------------|
| stape_container_crud | sGTM container CRUD | MEDIUM |
| stape_container_domains | Domain management | MEDIUM |
| stape_container_power_ups | Feature toggles | LOW |
| stape_container_analytics | Usage analytics | LOW |
| stape_container_statistics | Traffic stats | LOW |

## Environment
```env
STAPE_API_KEY=<key>
```

## Safety Protocol
- ALWAYS create workspace before making changes
- ALWAYS run pre-publish audit before publishing
- NEVER modify Default Workspace directly
- Create version snapshot before every publish
```

### HEARTBEAT-ENTRIES.md
```markdown
## GTM Container Health

### Weekly: Container Status Check
- **Frequency**: Every Monday
- **Mode**: SANDBOX
- **Actions**:
  1. Get current live version for each managed container
  2. Check for pending workspace changes
  3. Run naming convention audit
  4. Count tags/triggers/variables
  5. Draft status report

### Monthly: Deep Container Audit
- **Frequency**: First Monday of month
- **Mode**: SANDBOX
- **Actions**:
  1. Run full gtm-audit command
  2. Find orphaned triggers
  3. Find duplicate tags
  4. Check naming convention compliance
  5. Verify sGTM correlations
  6. Check for unused variables
  7. Generate comprehensive audit report
  8. Draft cleanup recommendations

### On-Demand: Pre-Publish Audit
- **Frequency**: Before any publish operation
- **Mode**: ACTIVE (blocks publish if fails)
- **Actions**:
  1. Validate all tags have triggers
  2. Check naming conventions
  3. Verify no duplicate tags
  4. Confirm workspace is synced
  5. Generate pass/fail report
```

### SCOPE-PHASE.md
```markdown
## GTM Tracking — Scope Phase

### Phase 1: Foundation
- [ ] Verify GTM MCP and Stape MCP connections
- [ ] List all accounts and containers
- [ ] Identify target containers
- [ ] Audit current container state
- [ ] Document baseline

### Phase 2: Variables
- [ ] Enable required built-in variables
- [ ] Create constant variables (measurement IDs, pixel IDs)
- [ ] Create data layer variables
- [ ] Create custom JavaScript variables
- [ ] Create lookup/regex tables as needed

### Phase 3: Triggers
- [ ] Create page view triggers
- [ ] Create click triggers (CTA, navigation, outbound)
- [ ] Create form submission triggers
- [ ] Create scroll depth triggers
- [ ] Create video triggers
- [ ] Create custom event triggers

### Phase 4: Tags
- [ ] Deploy GA4 configuration tag
- [ ] Deploy GA4 event tags
- [ ] Deploy platform-specific tags (Meta, Google Ads, LinkedIn)
- [ ] Deploy conversion linker
- [ ] Organize all entities into folders

### Phase 5: Validation & Publish
- [ ] Run pre-publish audit
- [ ] Fix any audit failures
- [ ] Create version with descriptive name
- [ ] Publish to live
- [ ] Verify live version
- [ ] Archive deployment to memory
```

## Verification

After creating all openclaw/ directories:
1. Each plugin has TOOLS.md, HEARTBEAT-ENTRIES.md, SCOPE-PHASE.md
2. TOOLS.md lists correct MCP tools with risk levels
3. HEARTBEAT entries use SANDBOX mode by default
4. SCOPE phases match the plugin's deployment workflow
5. Environment variables are documented
6. Integration points between plugins are noted
```

## Environment Variables for Claude Code Web

```
STAPE_API_KEY=<your-stape-key>
GOOGLE_ADS_DEVELOPER_TOKEN=<your-dev-token>
GOOGLE_ADS_LOGIN_CUSTOMER_ID=<your-login-cid>
META_PIXEL_ID=<your-pixel-id>
META_ACCESS_TOKEN=<your-meta-token>
```