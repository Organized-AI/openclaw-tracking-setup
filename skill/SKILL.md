---
name: tracking-setup
description: Autonomous tracking implementation — crawl site, audit GTM container, create tracking plan, implement tags/triggers/variables, configure Google Ads conversions, set up Meta CAPI, verify firing, and monitor health. Uses mcporter for GTM and Stape MCP servers, google-ads-cli for Google Ads management, and meta-ads-cli for Meta Ads management.
homepage: https://github.com/organized-ai/openclaw-tracking-setup
metadata:
  openclaw:
    emoji: 📊
    requires:
      bins: [mcporter, google-ads-cli, meta-ads-cli]
      skills: [mcporter]
    install:
      - id: gtm-mcp
        kind: node
        package: "@anthropic/gtm-mcp-server"
        label: "GTM MCP Server"
      - id: stape-mcp
        kind: node
        package: "stape-mcp-server"
        label: "Stape MCP Server"
---

# Tracking Setup Skill

Autonomous tracking implementation for OpenClaw agents. Crawls a client site, audits the existing GTM container and ad platform configurations, generates a tracking plan, implements it via MCP servers and CLI tools, verifies firing, and monitors ongoing health.

## Tool Chain

| Tool | Access Method | Capabilities |
|------|--------------|--------------|
| GTM MCP | `mcporter call gtm.*` | Full CRUD on tags, triggers, variables, versions, publishing |
| Stape MCP | `mcporter call stape.*` | Server-side GTM containers, domains, power-ups, analytics |
| google-ads-cli | Direct CLI | Full read+write: campaigns, ad groups, ads, keywords, conversion actions (35 tools) |
| meta-ads-cli | Direct CLI | Full CRUD: campaigns, ad sets, ads, creatives, insights, targeting research |
| Browser | Built-in | Site crawling, GTM preview mode, dataLayer inspection |

---

## Phase 1 — Discovery

**Goal:** Understand the client site and identify all trackable user actions.

### Steps

1. Read `TOOLS.md` for target site URLs, GTM container details, Google Ads customer IDs, Meta ad account IDs
2. Use browser to crawl the target site:
   - Identify all pages and navigation paths
   - Find forms (contact, lead gen, checkout, signup)
   - Locate CTAs (buttons, links, downloads)
   - Check for video embeds (YouTube, Vimeo, HTML5)
   - Assess scroll depth opportunities (long-form content pages)
   - Note any existing tracking snippets in page source
3. Document all trackable user actions in a discovery report
4. Save discovery report to `memory/YYYY-MM-DD-discovery.md`

### Key Questions to Answer
- What conversion actions matter for this business?
- What micro-conversions lead to macro-conversions?
- Are there cross-domain tracking needs?
- Is consent management required (GDPR/CCPA)?

---

## Phase 2 — Audit

**Goal:** Understand what tracking already exists and identify gaps.

### GTM Audit (via mcporter)

```bash
mcporter call gtm.list_tags --output json
mcporter call gtm.list_triggers --output json
mcporter call gtm.list_variables --output json
mcporter call gtm.list_versions
```

Check for:
- Duplicate tags firing on same triggers
- Tags without triggers (orphaned)
- Triggers without tags (unused)
- Missing consent mode configuration
- Deprecated tag types
- Tags firing on All Pages that should be scoped

### Google Ads Audit (via google-ads-cli)

```bash
google-ads-cli list-conversion-actions
google-ads-cli get-conversion-stats
google-ads-cli list-campaigns
google-ads-cli list-ad-groups --campaign-id CAMPAIGN_ID
```

Check for:
- Conversion actions without recent conversions
- Duplicate conversion actions tracking the same event
- Missing conversion actions for key business goals
- Campaign status and performance baselines

### Meta Ads Audit (via meta-ads-cli)

```bash
meta-ads-cli campaigns --account-id ACT_ID
meta-ads-cli insights --object-id ACT_ID --time-range last_30d
meta-ads-cli pixels --account-id ACT_ID
```

Check for:
- Pixel firing status and event match quality
- CAPI configuration status
- Event deduplication (event_id presence)
- Missing standard events for optimization

### Stape Audit (via mcporter)

```bash
mcporter call stape.container_crud action=get identifier=CONTAINER_ID
mcporter call stape.container_analytics identifier=CONTAINER_ID period=last_30_days
```

Check for:
- Server-side container health
- Request volume and error rates
- Power-up configuration (cookie keeper, etc.)

### Gap Analysis

Compare existing tracking vs. discovered actions:
- List events being tracked that shouldn't be (noise)
- List events NOT being tracked that should be (gaps)
- Identify misconfigured tags (wrong triggers, missing parameters)
- Reference `tracking-references/*.md` for best practices

Save audit report to `memory/YYYY-MM-DD-audit.md`

---

## Phase 3 — Plan

**Goal:** Generate a complete, reviewable tracking plan before any implementation.

### Plan Structure

Generate a tracking plan document containing:

#### GTM Tags to Create
| Tag Name | Tag Type | Trigger | Firing Rule | Parameters |
|----------|----------|---------|-------------|------------|
| (filled per client) | | | | |

#### GTM Triggers to Create
| Trigger Name | Trigger Type | Conditions |
|--------------|-------------|------------|
| (filled per client) | | |

#### GTM Variables to Create
| Variable Name | Variable Type | Value/Path |
|---------------|--------------|------------|
| (filled per client) | | |

#### Google Ads Conversion Actions to Create
| Name | Category | Type | Value | Count |
|------|----------|------|-------|-------|
| (filled per client) | PURCHASE/LEAD/etc. | WEBPAGE | static/dynamic | ONE_PER_CLICK/EVERY |

#### Meta CAPI Events to Configure
| Event Name | sGTM Tag | Parameters | Dedup Method |
|------------|----------|------------|-------------|
| (filled per client) | | | event_id |

#### Consent Mode Configuration
| Default State | Update Triggers | Storage Types |
|---------------|----------------|---------------|
| (filled per client) | | |

#### Server-Side Forwarding Rules (Stape sGTM)
| Source Event | Destination | Transform |
|-------------|-------------|-----------|
| (filled per client) | | |

### Approval Gate

**STOP HERE.** Present the tracking plan for human approval before proceeding to Phase 4. Do not implement anything without explicit approval.

---

## Phase 4 — Implement

**Goal:** Execute the approved tracking plan.

### Implementation Order

Always implement in dependency order:
1. Variables (other items depend on these)
2. Triggers
3. Tags
4. Google Ads conversion actions
5. Meta CAPI configuration via sGTM
6. Stape server-side setup

### GTM Implementation (via mcporter)

#### Create Variables First (dependencies)

```bash
mcporter call gtm.create_variable \
  name="DLV - transaction_id" \
  type="v" \
  parameter='[{"type": "template", "key": "dataLayerVersion", "value": "2"}, {"type": "template", "key": "name", "value": "ecommerce.transaction_id"}]'
```

#### Create Triggers

```bash
mcporter call gtm.create_trigger \
  name="CE - Form Submit" \
  type="formSubmission" \
  filter='[{"type": "equals", "parameter": [{"type": "template", "key": "arg0", "value": "{{Page Path}}"}, {"type": "template", "key": "arg1", "value": "/contact"}]}]'
```

#### Create Tags

```bash
mcporter call gtm.create_tag \
  name="GA4 - Purchase Event" \
  type="googtag" \
  firingTriggerId='["TRIGGER_ID"]' \
  parameter='[{"type": "template", "key": "tagId", "value": "G-XXXXXXX"}]'
```

### Google Ads Implementation (via google-ads-cli)

#### Create Conversion Actions

```bash
google-ads-cli create-conversion-action \
  --name "Purchase" \
  --category PURCHASE \
  --type WEBPAGE \
  --value-settings '{"default_value": 0, "always_use_default": false}' \
  --counting-type EVERY_CONVERSION

google-ads-cli create-conversion-action \
  --name "Lead Form Submit" \
  --category SUBMIT_LEAD_FORM \
  --type WEBPAGE \
  --counting-type ONE_PER_CLICK
```

#### Update Existing Conversion Actions

```bash
google-ads-cli update-conversion-action \
  --conversion-action-id ID \
  --status ENABLED \
  --attribution-model DATA_DRIVEN
```

**Safety:** All new campaigns created in PAUSED status by default.

```bash
google-ads-cli create-campaign \
  --name "Campaign Name" \
  --status PAUSED \
  --budget-amount-micros 50000000
```

### Meta Ads Implementation (via meta-ads-cli)

#### Create Campaigns (always PAUSED)

```bash
meta-ads-cli create-campaign \
  --account-id ACT_ID \
  --name "Campaign Name" \
  --objective OUTCOME_SALES \
  --status PAUSED \
  --special-ad-categories '[]'
```

**Note:** Budget amounts in cents (e.g., $50/day = 5000).

```bash
meta-ads-cli create-ad-set \
  --campaign-id CAMPAIGN_ID \
  --name "Ad Set Name" \
  --daily-budget 5000 \
  --targeting '{"geo_locations": {"countries": ["US"]}}' \
  --status PAUSED
```

### Stape sGTM Implementation (via mcporter)

#### Configure Server-Side Container

```bash
mcporter call stape.container_crud \
  action=update \
  identifier=CONTAINER_ID \
  settings='{"logging": true}'
```

#### Set Up Custom Domain

```bash
mcporter call stape.container_domains \
  action=create \
  containerIdentifier=CONTAINER_ID \
  domain="gtm.clientdomain.com"
```

#### Enable Power-Ups

```bash
mcporter call stape.container_power_ups \
  containerIdentifier=CONTAINER_ID \
  powerUpType=cookie_keeper \
  action=enable
```

### Post-Implementation

After all items are implemented:
1. Create a new GTM workspace version (do NOT publish yet)
2. Document all created resources with their IDs
3. Save to `memory/YYYY-MM-DD-implementation.md`

---

## Phase 5 — Verify

**Goal:** Confirm everything fires correctly before publishing.

### GTM Preview Mode Verification

1. Use browser to load target site with GTM preview mode enabled
2. Walk through each conversion path:
   - Page loads → verify pageview tags fire
   - Form submissions → verify form triggers activate
   - Button clicks → verify click triggers activate
   - Purchases → verify ecommerce tags fire with correct data
3. Check dataLayer for expected events and parameters
4. Verify tag firing sequence (consent → config → event)

### Google Ads Verification

```bash
google-ads-cli list-conversion-actions
google-ads-cli get-conversion-stats
```

- Confirm conversion actions exist and are ENABLED
- Check for "No recent conversions" warnings (expected for new actions)
- Verify conversion tag IDs match GTM tag configuration

### Meta Verification

```bash
meta-ads-cli insights --object-id ACT_ID --time-range today
meta-ads-cli pixels --account-id ACT_ID
```

- Check Pixel firing status
- Verify event match quality score
- Confirm event_id is present for deduplication

### Cross-Browser Testing

Use browser to test on:
- Chrome (primary)
- Safari (ITP considerations)
- Firefox
- Mobile viewport

### Server-Side Verification

```bash
mcporter call stape.container_analytics identifier=CONTAINER_ID period=today
```

- Verify requests are reaching the server container
- Check for error responses
- Confirm data is forwarding to endpoints

### Publish Decision

If all verifications pass:
1. Run pre-publish audit: `mcporter call gtm.list_tags --output json` (final check)
2. Create version: `mcporter call gtm.create_version name="Tracking Setup - YYYY-MM-DD"`
3. Publish: `mcporter call gtm.publish_version versionId=VERSION_ID`

Document verification results in `memory/YYYY-MM-DD-verification.md`

---

## Phase 6 — Monitor (Ongoing via HEARTBEAT.md)

**Goal:** Ensure tracking remains healthy over time.

### Daily Health Check

```bash
# Google Ads conversion health
google-ads-cli get-conversion-stats

# Meta event health
meta-ads-cli insights --object-id ACT_ID --time-range yesterday

# Stape container health
mcporter call stape.container_analytics identifier=CONTAINER_ID period=yesterday
```

**Alert if:**
- Conversion count drops >50% day-over-day
- Stape error rate exceeds 5%
- Meta event match quality drops below 6.0

### Weekly Data Quality Review

- Compare conversion counts: Google Ads vs GA4 vs Meta
- Check for data discrepancies >15%
- Review consent rate trends
- Verify server-side forwarding completion rate

### Monthly Re-Audit

- Re-crawl the site for new pages/forms/CTAs
- Run full Phase 2 audit
- Check for new GTM tags added outside this workflow
- Review Google Ads conversion action relevance
- Update tracking plan if gaps found

### Quarterly Review

- Full tracking architecture review
- Platform API changes assessment
- Consent mode compliance check
- Performance optimization recommendations
