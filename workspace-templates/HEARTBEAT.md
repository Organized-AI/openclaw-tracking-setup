# HEARTBEAT — Tracking Health Checks

> Scheduled tasks the agent runs automatically. Tracking-specific health monitoring.
>
> **Current mode: SANDBOX — Read and report only. No changes auto-applied.**

---

## EVERY MORNING — 8:00 AM (Client Timezone)

### Daily Tracking Health Check

Run automated checks across all platforms. Report anomalies.

**What to do:**

```bash
# 1. Google Ads conversion health
google-ads-cli get-conversion-stats

# 2. Meta event health
meta-ads-cli insights --object-id ACT_ID --time-range yesterday

# 3. Stape container health
mcporter call stape.container_analytics identifier=CONTAINER_ID period=yesterday
```

**Alert the client if:**
- Conversion count drops > 50% vs previous day
- Zero conversions recorded for any active campaign in the last 24 hours
- Stape error rate exceeds 5%
- Meta Event Match Quality drops below 6.0
- Any MCP server or CLI tool fails to respond

**Normal behavior (no alert needed):**
- Conversion counts within 30% of trailing 7-day average
- Stape error rate < 2%
- Meta EMQ >= 6.0
- All tools responding

**Report format:**
```
Daily Tracking Health — YYYY-MM-DD
✅ Google Ads: X conversions (vs Y avg) — [OK/ALERT]
✅ Meta Ads: X events, EMQ X.X — [OK/ALERT]
✅ Stape sGTM: X requests, X% error rate — [OK/ALERT]
```

Save to `memory/YYYY-MM-DD.md`

---

## EVERY FRIDAY — 3:00 PM (Client Timezone)

### Weekly Data Quality Review

Compare conversion data across platforms to identify discrepancies.

**What to do:**

```bash
# Pull weekly numbers from each platform
google-ads-cli get-conversion-stats  # Last 7 days
meta-ads-cli insights --object-id ACT_ID --time-range last_7d
mcporter call stape.container_analytics identifier=CONTAINER_ID period=last_7_days
```

**Check for:**
- [ ] Google Ads vs GA4 conversion count discrepancy (alert if > 15%)
- [ ] Meta Pixel vs CAPI event count (should be ~1:1 with dedup — alert if 2:1 or 0.5:1)
- [ ] Consent rate trend (is it dropping? rising?)
- [ ] sGTM forwarding completion rate
- [ ] Any new Google Ads recommendations related to conversions
- [ ] Any tags added to GTM outside this workflow

**Report format:**
```
Weekly Data Quality — Week of YYYY-MM-DD
Platform Comparison:
  Google Ads: X conversions
  GA4: X conversions
  Meta: X events
  Discrepancy: X%

Consent Rate: X% (trend: ↑/↓/→)
sGTM Health: X requests, X% error rate
New GTM changes detected: Yes/No
```

Save to `memory/YYYY-MM-DD.md`

---

## FIRST MONDAY OF MONTH — 9:00 AM (Client Timezone)

### Monthly Re-Audit

Full site re-crawl and tracking audit. Catches new pages, forms, or CTAs that were added since last audit.

**What to do:**

1. Re-crawl the target site (same as Phase 1 Discovery)
   - Look for new pages, forms, CTAs, video embeds
   - Compare against previous discovery report in memory/

2. Run full GTM audit:
   ```bash
   mcporter call gtm.list_tags --output json
   mcporter call gtm.list_triggers --output json
   mcporter call gtm.list_variables --output json
   ```
   - Check for tags added outside this workflow
   - Check for orphaned tags/triggers
   - Verify naming conventions still followed

3. Review Google Ads conversion actions:
   ```bash
   google-ads-cli list-conversion-actions
   ```
   - Any new actions created outside this workflow?
   - Any actions that should be deactivated?
   - Are primary/secondary designations still correct?

4. Review Meta health:
   ```bash
   meta-ads-cli pixels --account-id ACT_ID
   meta-ads-cli insights --object-id ACT_ID --time-range last_30d
   ```
   - EMQ trend over the month
   - Any events that stopped firing?

5. Check Stape:
   ```bash
   mcporter call stape.container_analytics identifier=CONTAINER_ID period=last_30_days
   ```
   - Cookie Keeper still active?
   - Custom domain still resolving?

**If gaps found:** Generate an update plan and present for approval (same as Phase 3).

**Report format:**
```
Monthly Re-Audit — YYYY-MM

Site Changes Detected:
  New pages: [list or "none"]
  New forms: [list or "none"]
  New CTAs: [list or "none"]

GTM Container Health:
  Total tags: X (was X last month)
  Unauthorized changes: Yes/No
  Orphaned entities: [list or "none"]

Conversion Action Health:
  Google Ads: X active, X secondary
  Meta: EMQ X.X (was X.X last month)

Recommendations:
  [List of suggested tracking updates, or "No changes needed"]
```

Save full report to `memory/YYYY-MM-DD-monthly-audit.md`

---

## QUARTERLY — First Monday of Quarter

### Full Architecture Review

Comprehensive review of the entire tracking stack. Check for platform changes, deprecations, and optimization opportunities.

**Checklist:**
- [ ] GA4 API changes or deprecations
- [ ] Google Ads conversion tracking changes
- [ ] Meta CAPI specification changes
- [ ] GTM template updates
- [ ] Stape power-up changes
- [ ] Consent mode compliance review
- [ ] Review and update estimated lead values for static conversion actions
- [ ] Full cross-platform conversion comparison (month-over-month trend)
- [ ] Performance optimization recommendations

Present findings to client with recommended actions.
