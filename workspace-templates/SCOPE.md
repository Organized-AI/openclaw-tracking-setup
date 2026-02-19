# SCOPE — Tracking Setup Workspace

## Phase 1: Foundation
**Status:** Not Started

### Objectives
- Verify GTM container access via mcporter
- Authenticate MCP servers (GTM, Stape)
- Authenticate CLI tools (google-ads-cli, meta-ads-cli)
- Perform initial site crawl and discovery
- Document all trackable user actions

### Entry Criteria
- mcporter is installed and accessible
- google-ads-cli is installed and authenticated
- meta-ads-cli is installed and authenticated
- GTM MCP server credentials are configured in mcporter-config/
- Stape API key is configured
- Target site URL(s) are documented in TOOLS.md

### Exit Criteria
- All MCP servers respond to test calls
- Both CLI tools authenticated and returning data
- Site crawl complete with discovery report saved to memory/
- All trackable actions documented

---

## Phase 2: Implementation
**Status:** Not Started

### Objectives
- Audit existing tracking (GTM tags, Google Ads conversions, Meta events)
- Generate and get approval on tracking plan
- Implement GTM tags, triggers, and variables via mcporter
- Create Google Ads conversion actions via google-ads-cli
- Configure Meta CAPI events via sGTM
- Set up Stape server-side container, domains, and power-ups
- Configure consent mode

### Entry Criteria
- Phase 1 complete
- Discovery report reviewed
- Audit report generated and gaps identified

### Exit Criteria
- Tracking plan approved by human
- All GTM tags/triggers/variables created
- Google Ads conversion actions created and ENABLED
- Meta CAPI events configured with event_id deduplication
- Stape sGTM container configured with custom domain
- Consent mode implemented
- New GTM version created (not yet published)

---

## Phase 3: Verification
**Status:** Not Started

### Objectives
- Test all tracking in GTM preview mode
- Verify tag firing on all conversion paths
- Verify Google Ads conversion actions are receiving data
- Verify Meta Pixel and CAPI events are firing with correct parameters
- Cross-browser testing (Chrome, Safari, Firefox, mobile)
- Server-side verification via Stape analytics
- Publish GTM container after all checks pass

### Entry Criteria
- Phase 2 complete
- All tags/triggers/variables/conversion actions created
- GTM version ready for preview

### Exit Criteria
- All tags fire correctly in preview mode
- dataLayer contains expected events and parameters
- Google Ads conversion actions show as active
- Meta event match quality score >= 6.0
- Cross-browser testing complete
- Server-side requests verified in Stape analytics
- GTM container published

---

## Phase 4: Monitoring
**Status:** Not Started

### Objectives
- Daily health checks on conversion tag firing
- Weekly data quality reviews across platforms
- Monthly site re-crawl for new tracking opportunities
- Quarterly full architecture review

### Entry Criteria
- Phase 3 complete
- GTM container published
- Tracking has been live for >= 24 hours

### Exit Criteria
- Ongoing — this phase runs continuously
- HEARTBEAT.md updated with monitoring schedule
- Alert thresholds configured:
  - Conversion drop >50% day-over-day
  - Stape error rate >5%
  - Meta event match quality <6.0
