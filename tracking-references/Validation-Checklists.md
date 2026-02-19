# Validation Checklists

Structured checklists the agent runs at each phase gate. Each checklist must be completed before advancing to the next phase. Items discovered during site scanning are validated against these lists.

---

## Pre-Audit Checklist (Before Phase 2)

Run this after Phase 1 Discovery to ensure the crawl was thorough.

### Site Scan Completeness

- [ ] All main navigation pages visited
- [ ] All footer links checked for additional pages
- [ ] Sitemap.xml parsed (if exists) for unlisted pages
- [ ] Forms identified: count, location, type (contact, lead, checkout, signup, search)
- [ ] CTA buttons identified: count, text, location, destination
- [ ] Phone number links identified: count, format (tel: vs plain text)
- [ ] Email links identified: count (mailto: vs plain text)
- [ ] Video embeds identified: count, provider (YouTube, Vimeo, HTML5, Wistia)
- [ ] Download links identified: count, file types (PDF, DOC, ZIP)
- [ ] Chat widget detected: provider identified
- [ ] Booking/scheduling widget detected: provider identified
- [ ] Map/directions links identified
- [ ] Existing dataLayer checked: `window.dataLayer` present? Events being pushed?
- [ ] Existing tracking scripts identified: GA4, Google Ads, Meta Pixel, other
- [ ] Schema.org structured data checked (Product, LocalBusiness, etc.)
- [ ] SPA detection: Does the site use client-side routing? (React, Vue, Angular indicators)
- [ ] Cross-domain scenarios identified: checkout on different domain? Subdomain tracking needed?

### Tool Connectivity

- [ ] `mcporter call gtm.list_tags` returns data (GTM MCP authenticated)
- [ ] `mcporter call stape.container_crud action=get identifier=CONTAINER_ID` returns data (Stape MCP authenticated)
- [ ] `google-ads-cli list-campaigns` returns data (Google Ads CLI authenticated)
- [ ] `meta-ads-cli campaigns --account-id ACT_ID` returns data (Meta Ads CLI authenticated)

---

## Pre-Implementation Checklist (After Phase 3 Plan, Before Phase 4)

Run this on the tracking plan before any implementation begins.

### Structural Integrity

- [ ] Every proposed tag has a named trigger (no orphans)
- [ ] Every proposed trigger is referenced by at least one tag
- [ ] No duplicate tags (same event + same trigger combination)
- [ ] All entity names follow GTM-Naming-Conventions.md rules
- [ ] Implementation order documented: Variables → Triggers → Tags → Conversion Actions → CAPI

### Required Foundation Elements

- [ ] Consent Initialization tag is in the plan (if consent is required)
- [ ] Consent Update mechanism identified (CMP callback or custom)
- [ ] Conversion Linker tag is in the plan (required for Google Ads)
- [ ] Google Tag (config) tag fires on Initialization - All Pages
- [ ] GA4 Measurement ID variable is defined as a Constant
- [ ] Google Ads Conversion ID variable is defined as a Constant (if applicable)

### Event Configuration

- [ ] All ecommerce events include both `currency` AND `value` parameters
- [ ] `purchase` event includes `transaction_id`
- [ ] All items[] arrays include `item_id` and `item_name` (minimum required)
- [ ] Custom event names are snake_case, under 40 chars, no reserved prefixes
- [ ] No custom events duplicate automatically collected events (scroll, file_download, etc.)

### Meta CAPI Configuration

- [ ] All Meta events have `event_id` for deduplication
- [ ] `Purchase` event includes `value` (REQUIRED) and `currency` (REQUIRED)
- [ ] User data fields specified: minimum client_ip_address, client_user_agent, fbp
- [ ] Hash requirements noted for PII fields (em, ph, fn, ln, etc.)
- [ ] `action_source` set to `website` for all web events

### Google Ads Conversion Actions

- [ ] Categories are correct per business type (see Google-Ads-Conversions.md)
- [ ] Counting types correct: ONE_PER_CLICK for leads, EVERY for purchases
- [ ] Value settings appropriate: dynamic for purchases, static for leads
- [ ] No more than 3 primary conversion actions (rest are secondary/observation)
- [ ] Attribution model set to DATA_DRIVEN (or LAST_CLICK if insufficient data)

### Safety Checks

- [ ] All new campaigns will be created in PAUSED status
- [ ] No `enable-campaign` commands in the implementation plan
- [ ] Meta budgets in cents (not dollars) — $50/day = 5000
- [ ] Google Ads budgets in micros (not dollars) — $50/day = 50000000
- [ ] No PII will be sent unhashed to any platform
- [ ] GTM will NOT be published during implementation — only version created

### Approval

- [ ] Plan presented to human for review
- [ ] Human has explicitly approved the plan
- [ ] Any requested changes have been incorporated

---

## Post-Implementation Checklist (After Phase 4, Before Phase 5 Verify)

Run this immediately after all GTM entities and conversion actions are created.

### GTM Entity Verification

- [ ] All planned variables created — verify count matches plan
- [ ] All planned triggers created — verify count matches plan
- [ ] All planned tags created — verify count matches plan
- [ ] Tag → Trigger associations are correct (verify via `mcporter call gtm.list_tags`)
- [ ] No orphaned tags (tags without triggers)
- [ ] No orphaned triggers (triggers without tags)
- [ ] Variable references resolve correctly (no typos in variable names)

### Implementation IDs Documented

- [ ] All created variable IDs saved to memory/
- [ ] All created trigger IDs saved to memory/
- [ ] All created tag IDs saved to memory/
- [ ] Google Ads conversion action IDs saved
- [ ] GTM workspace version ID saved

### Google Ads Verification

- [ ] `google-ads-cli list-conversion-actions` shows all created actions
- [ ] All conversion actions have status ENABLED
- [ ] Conversion tag IDs in GTM match the created conversion action IDs
- [ ] Counting types verified in listing output

### Meta Verification

- [ ] Meta Pixel ID confirmed in tag configuration
- [ ] CAPI access token configured in sGTM
- [ ] Event mapping verified (GA4 event → Meta event name)

---

## Preview Mode Verification Checklist (Phase 5)

Run this while the site is loaded in GTM Preview mode.

### Page Load Verification

- [ ] Consent Initialization tag fires FIRST on every page
- [ ] Google Tag (config) fires on Initialization after consent
- [ ] Conversion Linker fires on Initialization on every page
- [ ] dataLayer contains expected `gtm.js` and `gtm.start` events
- [ ] No JavaScript errors in browser console caused by tags
- [ ] Page load time not significantly impacted by tags

### Conversion Path Testing

For each identified conversion path, walk through the full user journey:

#### Ecommerce Path (if applicable)
- [ ] Navigate to category page → verify `view_item_list` fires with items[]
- [ ] Click a product → verify `select_item` fires, then `view_item` on PDP
- [ ] Add to cart → verify `add_to_cart` fires with items[], value, currency
- [ ] View cart → verify `view_cart` fires
- [ ] Begin checkout → verify `begin_checkout` fires
- [ ] Complete shipping step → verify `add_shipping_info` fires
- [ ] Complete payment step → verify `add_payment_info` fires
- [ ] Complete order → verify `purchase` fires with transaction_id, value, currency, items[]
- [ ] Verify no duplicate tag firings on any step

#### Lead Gen Path (if applicable)
- [ ] Load page with form → verify pageview tags fire
- [ ] Interact with first form field → verify `form_start` fires (if tracking)
- [ ] Submit form → verify `generate_lead` fires with correct parameters
- [ ] Click phone number → verify `phone_click` fires
- [ ] Click CTA button → verify `cta_click` fires with cta_text, cta_location

#### Content Path (if applicable)
- [ ] Load article page → verify page_view fires with content_group
- [ ] Scroll to 90% → verify scroll event fires
- [ ] Play video → verify video_start fires
- [ ] Complete video → verify video_complete fires

### DataLayer Inspection

- [ ] Open browser console → `dataLayer` object accessible
- [ ] Event names match expected GA4 event names (snake_case)
- [ ] Ecommerce data structure matches GA4 spec (items as array, not object)
- [ ] `currency` present wherever `value` is present
- [ ] `transaction_id` is unique and present on purchase event
- [ ] `event_id` present for Meta deduplication

### Tag Firing Sequence

Verify correct order on each page:
1. Consent Initialization (Consent Initialization trigger)
2. Conversion Linker (Initialization - All Pages)
3. Google Tag config (Initialization - All Pages)
4. Event-specific tags (on their respective triggers)

- [ ] No event tags fire before config tags
- [ ] No tags fire before consent initialization
- [ ] Consent-required tags are blocked when consent is denied

---

## Pre-Publish Checklist (Phase 5, Before Publishing GTM Container)

Final checks before `mcporter call gtm.publish_version`.

### Final Audit

- [ ] `mcporter call gtm.list_tags --output json` — review all tags one final time
- [ ] `mcporter call gtm.list_triggers --output json` — confirm all triggers
- [ ] `mcporter call gtm.list_variables --output json` — confirm all variables
- [ ] No test/debug tags left in the container
- [ ] No duplicate tags (check for accidentally created duplicates)
- [ ] All tag names follow naming conventions

### Cross-Browser Spot Check

- [ ] Chrome: Full conversion path tested
- [ ] Safari: Verify tags fire (ITP considerations — cookie lifetime)
- [ ] Firefox: Verify tags fire
- [ ] Mobile viewport: Verify mobile-specific elements trigger correctly

### Platform Verification

- [ ] Google Ads conversion actions show status ENABLED
- [ ] Google Ads: `google-ads-cli get-conversion-stats` — no errors
- [ ] Meta: Event Manager shows test events received (if test mode was used)
- [ ] Stape: `mcporter call stape.container_analytics identifier=ID period=today` — requests flowing

### Server-Side Verification

- [ ] sGTM container receiving requests from web container
- [ ] GA4 requests forwarding to Google Analytics endpoint
- [ ] Meta CAPI requests forwarding to Meta Graph API
- [ ] Google Ads conversion requests forwarding (if via sGTM)
- [ ] No elevated error rates in Stape analytics

### Sign-Off

- [ ] All verification results documented in memory/YYYY-MM-DD-verification.md
- [ ] Human approval to publish obtained
- [ ] Version name set: "Tracking Setup - YYYY-MM-DD"

---

## Post-Publish Health Check (First 24 Hours)

Run 24 hours after GTM container publish.

### Data Flow Confirmation

- [ ] GA4 Real-Time report shows events flowing
- [ ] Google Ads conversion actions: status changed from "Unverified" to "Recording conversions" or "Tag inactive" (both normal within first 24h)
- [ ] Meta Events Manager shows events with dedup indicators
- [ ] Stape container analytics show consistent request volume
- [ ] No sudden spike in 4xx/5xx errors

### Volume Baseline

- [ ] Record today's conversion count by type (baseline for future monitoring)
- [ ] Record today's Stape request volume (baseline)
- [ ] Record Meta EMQ score (baseline — target >= 6.0)
- [ ] Record GA4 event counts by event_name (baseline)

### Anomaly Detection

- [ ] Conversion count is non-zero (tracking is working)
- [ ] Conversion count is reasonable (not 10x expected — indicates duplicate firing)
- [ ] No errors in Stape container logs
- [ ] No new JavaScript errors in site console
- [ ] Site performance not degraded (check page load times)

---

## Ongoing Monitoring Checklist (Phase 6)

### Daily (Automated via HEARTBEAT.md)

- [ ] `google-ads-cli get-conversion-stats` — conversions > 0 for active campaigns
- [ ] `meta-ads-cli insights --object-id ACT_ID --time-range yesterday` — events recorded
- [ ] `mcporter call stape.container_analytics identifier=ID period=yesterday` — request volume normal

**Alert triggers:**
- Conversion count drops > 50% vs previous day
- Stape error rate > 5%
- Meta EMQ drops below 6.0
- Zero conversions for 24+ hours during active campaigns

### Weekly

- [ ] Compare conversion counts: Google Ads vs GA4 vs Meta (discrepancy < 15%)
- [ ] Review consent rate trends (dropping consent = dropping data)
- [ ] Check sGTM forwarding completion rate
- [ ] Review any new Google Ads recommendations related to conversions

### Monthly

- [ ] Re-crawl site for new pages, forms, CTAs
- [ ] Run full Phase 2 audit
- [ ] Check for GTM tags added outside this workflow (unauthorized changes)
- [ ] Review Google Ads conversion action relevance
- [ ] Check Meta Pixel health in Events Manager
- [ ] Verify Cookie Keeper is functioning (cookie lifetimes extended)

### Quarterly

- [ ] Full tracking architecture review
- [ ] Platform API changes assessment (GA4, Google Ads, Meta — any deprecations?)
- [ ] Consent mode compliance review
- [ ] Performance optimization: are there new tracking opportunities?
- [ ] Review and update estimated lead values for static conversion actions
