# Phase 2: openclaw-google-ads — Conversion Tracking Builder

## Claude Code Prompt

```
claude --dangerously-skip-permissions

Build out the openclaw-google-ads plugin in plugin-marketplace/openclaw-google-ads/. This plugin autonomously audits and builds Google Ads conversion tracking configurations.

## 1. SKILL.md — Google Ads Builder

Write skills/google-ads-builder/SKILL.md covering:

### Core Capabilities

**Auditing (via GAQL through google-ads-download-report):**
- List all conversion actions with status, category, and attribution settings
- Analyze conversion action performance (conversions, value, cost-per-conversion)
- Identify missing conversion types for the account type
- Check conversion tracking tag status
- Review audience lists and remarketing configuration
- Assess account-level conversion settings (attribution model, counting)

**Deployment Planning:**
- Generate conversion action specifications based on site analysis
- Map website events to Google Ads conversion categories
- Define conversion values and counting methods
- Plan Enhanced Conversions setup
- Generate GTM tag configurations for Google Ads conversion tracking

**GTM Integration:**
- Generate Google Ads Conversion Tracking tag (awct) parameters
- Generate Google Ads Remarketing tag (sp) parameters
- Generate Conversion Linker tag (gclidw) configuration
- Define triggers for conversion events
- Produce deployment artifacts for openclaw-gtm plugin

### GAQL Query Library

Include ready-to-use GAQL queries:

```sql
-- List all conversion actions
SELECT
  conversion_action.id,
  conversion_action.name,
  conversion_action.category,
  conversion_action.type,
  conversion_action.status,
  conversion_action.primary_for_goal,
  conversion_action.attribution_model_settings.attribution_model,
  conversion_action.counting_type,
  conversion_action.value_settings.default_value,
  conversion_action.value_settings.always_use_default_value
FROM conversion_action
ORDER BY conversion_action.name

-- Conversion performance last 30 days
SELECT
  conversion_action.name,
  metrics.conversions,
  metrics.conversions_value,
  metrics.cost_per_conversion,
  metrics.conversion_rate
FROM conversion_action
WHERE segments.date DURING LAST_30_DAYS
  AND metrics.conversions > 0
ORDER BY metrics.conversions DESC

-- Campaign conversion breakdown
SELECT
  campaign.name,
  conversion_action.name,
  metrics.conversions,
  metrics.conversions_value
FROM campaign
WHERE segments.date DURING LAST_30_DAYS
  AND metrics.conversions > 0
ORDER BY metrics.conversions DESC
LIMIT 50

-- Account-level settings
SELECT
  customer.id,
  customer.descriptive_name,
  customer.currency_code,
  customer.time_zone,
  customer.auto_tagging_enabled,
  customer.conversion_tracking_setting.conversion_tracking_id,
  customer.conversion_tracking_setting.cross_account_conversion_tracking_id
FROM customer
LIMIT 1

-- Remarketing audiences
SELECT
  user_list.id,
  user_list.name,
  user_list.type,
  user_list.size_for_display,
  user_list.size_for_search,
  user_list.membership_life_span
FROM user_list
WHERE user_list.type IN ('REMARKETING', 'RULE_BASED', 'LOGICAL_USER_LIST')
ORDER BY user_list.name
```

### Conversion Categories Reference
Map these conversion types to business objectives:
- PURCHASE — E-commerce transactions
- ADD_TO_CART — Shopping intent
- BEGIN_CHECKOUT — Purchase intent
- SUBMIT_LEAD_FORM — Lead generation
- SUBSCRIBE_PAID — Subscription signups
- SIGN_UP — Account creation
- PAGE_VIEW — Key page visits
- CONTACT — Contact form submissions
- BOOK_APPOINTMENT — Booking/scheduling
- DOWNLOAD — App/content downloads
- DEFAULT — Custom/other conversions

### Output Artifacts
The skill generates:
1. Audit report (markdown) — Current state of conversion tracking
2. Conversion plan (JSON) — Proposed conversion actions with settings
3. GTM deployment spec (JSON) — Tag/trigger configs for openclaw-gtm
4. Enhanced Conversions guide — Setup instructions for first-party data

## 2. Reference Documents

**references/conversion-types.md:**
Document all Google Ads conversion action types with:
- Category enum values
- Counting methods (ONE_PER_CLICK vs MANY_PER_CLICK)
- Attribution model options
- Default value settings
- When to use each type

**references/gaql-patterns.md:**
Complete GAQL query reference for:
- Conversion actions (list, performance, settings)
- Campaign metrics (performance, budget, bidding)
- Ad group and ad performance
- Audience/remarketing lists
- Change history
- Account diagnostics

Include GAQL syntax notes:
- Resource names and field paths
- WHERE clause operators
- Date range predicates (DURING LAST_30_DAYS, BETWEEN)
- Ordering and limits
- Metric vs segment vs attribute fields

**references/naming-conventions.md:**
Standard naming for Google Ads entities:
- Conversion actions: `{Category} - {Description}` (e.g., "Purchase - Checkout Complete")
- Remarketing audiences: `{Source} - {Criteria}` (e.g., "Website - Product Page Visitors")
- GTM tags: `GAds - {Type} - {Description}` (e.g., "GAds - Conversion - Purchase")

## 3. Agent Definition

Write agents/google-ads-agent.md:

```markdown
# Google Ads Tracking Agent

## Identity
You are the Google Ads Tracking Agent — an autonomous builder that audits existing Google Ads conversion tracking and generates deployment specifications for new conversion actions.

## Session Protocol
1. Read this agent definition
2. List available Google Ads accounts (list-accounts)
3. Identify target account by name or CID
4. Run comprehensive GAQL audit queries
5. Generate audit report
6. If deployment requested: generate conversion plan + GTM specs

## Tools Available
- google-ads-download-report (GAQL queries)
- list-accounts (account discovery)

## Workflow

### Audit Flow
1. Get account info (customer resource)
2. List all conversion actions
3. Check conversion performance (last 30 days)
4. Review remarketing audiences
5. Verify auto-tagging enabled
6. Check conversion tracking ID configuration
7. Generate comprehensive audit report

### Deployment Flow
1. Complete audit first
2. Analyze site for conversion opportunities (use site crawl data)
3. Generate conversion action specifications
4. Generate GTM tag configurations (for openclaw-gtm to deploy)
5. Generate Enhanced Conversions setup guide
6. Output deployment package

## Safety Rules
- NEVER modify Google Ads account directly (read-only via GAQL)
- ALWAYS verify account ID before running queries
- Report all errors with query details
```

## 4. Commands

**commands/gads-audit.md:**
- Accept account name or CID
- Run all audit GAQL queries
- Generate markdown report with:
  - Account settings (auto-tagging, conversion tracking ID)
  - All conversion actions with status/category/attribution
  - Top performing conversions (last 30 days)
  - Remarketing audience inventory
  - Recommendations for missing tracking

**commands/gads-deploy.md:**
- Accept site analysis data or tracking plan
- Map site events to conversion categories
- Generate conversion action specifications (JSON)
- Generate GTM tag/trigger configurations for openclaw-gtm
- Output deployment package to DOCUMENTATION/

**commands/gads-status.md:**
- Quick status: account info, conversion count, last conversion date
- Active vs inactive conversion actions
- Account health indicators

## 5. Hooks

Write hooks/hooks.json:
```json
[
  {
    "name": "pre-deploy-validation",
    "event": "pre-deploy",
    "description": "Validate conversion specifications before generating GTM configs",
    "script": "hooks/pre-deploy-validation.md"
  },
  {
    "name": "post-deploy-verification",
    "event": "post-deploy",
    "description": "Verify conversion tracking after GTM deployment",
    "script": "hooks/post-deploy-verification.md"
  }
]
```

**hooks/pre-deploy-validation.md:**
- Verify account has auto-tagging enabled
- Check for duplicate conversion actions
- Validate conversion categories match business type
- Ensure conversion values are set appropriately

**hooks/post-deploy-verification.md:**
- Run GAQL query to check conversion action status
- Verify GTM tags deployed via openclaw-gtm
- Check for recent conversion data

## 6. Templates

**templates/conversion-action.template.json:**
```json
{
  "name": "{{CONVERSION_NAME}}",
  "category": "{{CATEGORY}}",
  "type": "WEBPAGE",
  "countingType": "{{COUNTING_TYPE}}",
  "attributionModelSettings": {
    "attributionModel": "GOOGLE_SEARCH_ATTRIBUTION_DATA_DRIVEN"
  },
  "valueSettings": {
    "defaultValue": {{DEFAULT_VALUE}},
    "alwaysUseDefaultValue": {{ALWAYS_USE_DEFAULT}}
  },
  "primaryForGoal": {{PRIMARY_FOR_GOAL}},
  "gtmTag": {
    "type": "awct",
    "parameters": {
      "conversionId": "{{CONVERSION_ID}}",
      "conversionLabel": "{{CONVERSION_LABEL}}"
    },
    "trigger": "{{TRIGGER_REFERENCE}}"
  }
}
```

**templates/remarketing-audience.template.json:**
```json
{
  "name": "{{AUDIENCE_NAME}}",
  "type": "RULE_BASED",
  "membershipLifeSpan": {{DAYS}},
  "rule": {
    "ruleType": "OR_OF_ANDS",
    "ruleItemGroups": [
      {
        "ruleItems": [
          {
            "name": "url__",
            "stringRuleItem": {
              "operator": "{{OPERATOR}}",
              "value": "{{URL_PATTERN}}"
            }
          }
        ]
      }
    ]
  }
}
```

## Verification

After building:
1. SKILL.md contains at least 6 complete GAQL queries
2. All reference docs have substantive content
3. Agent definition includes audit + deploy flows
4. Commands are actionable with clear inputs/outputs
5. Templates contain valid JSON with placeholder variables
6. Run test: Execute gads-audit command against a known account
```

## Environment Variables for Claude Code Web

```
GOOGLE_ADS_DEVELOPER_TOKEN=<your-dev-token>
GOOGLE_ADS_LOGIN_CUSTOMER_ID=<your-login-cid>
```