# Consent Mode v2 Implementation

Step-by-step reference for implementing Google Consent Mode v2. Required for EU/EEA users and affects how all Google tags behave. The agent references this during Phase 3 (Plan) and Phase 4 (Implement).

---

## Consent Storage Types

| Storage Type | Purpose | Required in v2 |
|-------------|---------|---------------|
| `ad_storage` | Cookies for advertising (Google Ads, remarketing) | Yes (v1) |
| `analytics_storage` | Cookies for analytics (GA4 cookies like _ga) | Yes (v1) |
| `ad_user_data` | Consent to send user data to Google for advertising | **Yes (NEW in v2)** |
| `ad_personalization` | Consent to personalized advertising (remarketing) | **Yes (NEW in v2)** |
| `functionality_storage` | Cookies for site functionality (language, preferences) | Optional |
| `personalization_storage` | Cookies for personalization (recommendations) | Optional |
| `security_storage` | Cookies for security (authentication, fraud prevention) | Optional |

**Critical:** v2 requires `ad_user_data` and `ad_personalization`. Without these, Google Ads remarketing and enhanced conversions will not function for users in regulated regions.

---

## Basic vs. Advanced Implementation

### Basic Mode

- Tags are **completely blocked** until consent is granted
- No data is sent to Google when consent is denied
- No conversion modeling
- Simpler to implement
- **Significant data loss** for uncontested users

### Advanced Mode (Recommended)

- Tags fire with **cookieless pings** when consent is denied
- Google receives anonymized signals (no cookies, no identifiers)
- Google uses these signals for **conversion modeling** (estimates conversions from non-consented users)
- Better data recovery (~70% of conversions can be modeled)
- Required thresholds: 700+ ad clicks over 7 days, 7 full days of data, 20%+ consent rate

**Always recommend Advanced mode** unless the client specifically requests Basic.

---

## Default Consent State

### EU/EEA Users (Denied by Default)

```javascript
// GTM Consent Initialization tag — fires FIRST on every page
gtag('consent', 'default', {
  'ad_storage': 'denied',
  'ad_user_data': 'denied',
  'ad_personalization': 'denied',
  'analytics_storage': 'denied',
  'functionality_storage': 'granted',
  'security_storage': 'granted',
  'region': ['AT', 'BE', 'BG', 'HR', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR',
             'DE', 'GR', 'HU', 'IE', 'IT', 'LV', 'LT', 'LU', 'MT', 'NL',
             'PL', 'PT', 'RO', 'SK', 'SI', 'ES', 'SE',
             'IS', 'LI', 'NO', 'GB', 'CH']
});
```

### US/Non-Regulated Users (Granted by Default)

```javascript
// For regions without consent requirements
gtag('consent', 'default', {
  'ad_storage': 'granted',
  'ad_user_data': 'granted',
  'ad_personalization': 'granted',
  'analytics_storage': 'granted'
});
```

### Combined Region-Specific Implementation

```javascript
// Default: granted for everyone
gtag('consent', 'default', {
  'ad_storage': 'granted',
  'ad_user_data': 'granted',
  'ad_personalization': 'granted',
  'analytics_storage': 'granted'
});

// Override: denied for EU/EEA
gtag('consent', 'default', {
  'ad_storage': 'denied',
  'ad_user_data': 'denied',
  'ad_personalization': 'denied',
  'analytics_storage': 'denied',
  'region': ['AT', 'BE', 'BG', 'HR', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR',
             'DE', 'GR', 'HU', 'IE', 'IT', 'LV', 'LT', 'LU', 'MT', 'NL',
             'PL', 'PT', 'RO', 'SK', 'SI', 'ES', 'SE',
             'IS', 'LI', 'NO', 'GB', 'CH']
});

// Override: denied for California (CCPA/CPRA)
gtag('consent', 'default', {
  'ad_storage': 'denied',
  'ad_user_data': 'denied',
  'ad_personalization': 'denied',
  'analytics_storage': 'granted',
  'region': ['US-CA']
});
```

---

## GTM Implementation

### Step 1: Consent Initialization Tag

Create a tag that fires on the **Consent Initialization** trigger (fires before all other triggers).

**Via mcporter (Custom HTML approach):**
```bash
mcporter call gtm.create_tag \
  name="Consent - Default State" \
  type="html" \
  parameter='[{"type": "template", "key": "html", "value": "<script>window.dataLayer = window.dataLayer || [];function gtag(){dataLayer.push(arguments);}gtag(\"consent\", \"default\", {\"ad_storage\": \"denied\", \"ad_user_data\": \"denied\", \"ad_personalization\": \"denied\", \"analytics_storage\": \"denied\", \"wait_for_update\": 500});</script>"}]' \
  firingTriggerId='["CONSENT_INIT_TRIGGER_ID"]' \
  consentSettings='{"consentStatus": "NOT_SET"}'
```

**Key parameter:** `wait_for_update: 500` — tells Google to wait 500ms for the CMP to update consent before processing. This prevents a flash of denied-then-granted.

### Step 2: Consent Update (CMP Callback)

When the user interacts with the consent banner (accepts/rejects), the CMP fires a callback. Create a tag that translates the CMP's signal into a `gtag('consent', 'update', ...)` call.

**Generic consent update:**
```javascript
gtag('consent', 'update', {
  'ad_storage': userChoice.marketing ? 'granted' : 'denied',
  'ad_user_data': userChoice.marketing ? 'granted' : 'denied',
  'ad_personalization': userChoice.marketing ? 'granted' : 'denied',
  'analytics_storage': userChoice.analytics ? 'granted' : 'denied'
});
```

### Step 3: Tag-Level Consent Settings

Google tags (GA4, Google Ads) have **built-in consent checks** — they automatically respect consent state. No additional configuration needed.

For **Custom HTML tags**, you must manually set consent requirements:
- In GTM UI: Tag > Advanced Settings > Consent Settings > Require additional consent for tag to fire
- Via API: Set `consentSettings` parameter with required consent types

---

## CMP Integration Patterns

### CookieBot

```javascript
// CookieBot fires this event when user consents
window.addEventListener('CookieConsentDeclaration', function() {
  gtag('consent', 'update', {
    'ad_storage': Cookiebot.consent.marketing ? 'granted' : 'denied',
    'ad_user_data': Cookiebot.consent.marketing ? 'granted' : 'denied',
    'ad_personalization': Cookiebot.consent.marketing ? 'granted' : 'denied',
    'analytics_storage': Cookiebot.consent.statistics ? 'granted' : 'denied'
  });
});
```

**GTM approach:** CookieBot has a native GTM template that handles consent mode automatically. Use the template when available.

### OneTrust

```javascript
// OneTrust category mapping:
// C0001 = Strictly Necessary (always granted)
// C0002 = Performance (analytics)
// C0003 = Functional
// C0004 = Targeting/Advertising

function updateConsentFromOneTrust() {
  var activeGroups = OnetrustActiveGroups || '';
  gtag('consent', 'update', {
    'ad_storage': activeGroups.includes('C0004') ? 'granted' : 'denied',
    'ad_user_data': activeGroups.includes('C0004') ? 'granted' : 'denied',
    'ad_personalization': activeGroups.includes('C0004') ? 'granted' : 'denied',
    'analytics_storage': activeGroups.includes('C0002') ? 'granted' : 'denied'
  });
}
```

### CookieScript

```javascript
// CookieScript categories: strictly-necessary, performance, targeting, functionality
document.addEventListener('CookieScriptAccept', function(e) {
  var categories = e.detail.categories;
  gtag('consent', 'update', {
    'ad_storage': categories.includes('targeting') ? 'granted' : 'denied',
    'ad_user_data': categories.includes('targeting') ? 'granted' : 'denied',
    'ad_personalization': categories.includes('targeting') ? 'granted' : 'denied',
    'analytics_storage': categories.includes('performance') ? 'granted' : 'denied'
  });
});
```

### Usercentrics

Usercentrics has a native GTM template. Use the template for automatic integration.

### No CMP Detected

If the site has no CMP during site scan:
1. Flag in the tracking plan: "Consent management platform needed"
2. Recommend installing one (CookieBot, CookieScript, or Usercentrics are most common)
3. Implement consent defaults as `denied` for applicable regions
4. Use `wait_for_update: 500` to handle delayed CMP load
5. Note: Without a CMP, consent will remain `denied` for regulated users = significant data loss

---

## sGTM Consent Forwarding

Consent state automatically propagates from the web GTM container to the server GTM container via the GA4 hit:

1. Web container sets consent state
2. GA4 tag fires with consent-aware behavior
3. Hit sent to sGTM includes consent signals in the request
4. sGTM tags can read consent state from the event data
5. Server-side tags respect the consent signals

**No additional configuration needed** for consent forwarding to sGTM if using the standard GA4 Client in sGTM.

---

## Testing Consent Mode

### In GTM Preview Mode

1. Open GTM Preview
2. Check Consent tab — shows current consent state for each storage type
3. Verify defaults are set to `denied` (for EU test)
4. Tags should show consent state:
   - "Blocked by consent" (Basic mode)
   - "Fired with reduced data" (Advanced mode)
5. Simulate granting consent (click accept on CMP)
6. Verify tags fire with full data after consent granted

### Verification Checklist

- [ ] Consent Initialization fires BEFORE all other tags
- [ ] Default state is `denied` for regulated regions
- [ ] `ad_user_data` and `ad_personalization` are included (v2 requirement)
- [ ] CMP consent update translates correctly to gtag consent update
- [ ] Tags blocked when consent denied (Basic) or fire with reduced data (Advanced)
- [ ] Tags fire normally after consent granted
- [ ] Consent state persists across page loads (cookie-based)
- [ ] `wait_for_update` is set (500ms recommended)

---

## Decision Guide

### Does This Site Need Consent Mode?

| Condition | Answer |
|-----------|--------|
| Site has EU/EEA traffic | **Yes** — GDPR requires it |
| Site targets UK | **Yes** — UK GDPR |
| Site targets California | **Recommended** — CCPA/CPRA |
| Site is US-only, no CA | Optional but recommended as best practice |
| Site uses Google Ads remarketing in EU | **Mandatory** — Google requires it |
| Site has no Google tags at all | Not applicable |

### Which Mode?

| Condition | Mode |
|-----------|------|
| Client wants maximum data recovery | Advanced |
| Client wants simplest implementation | Basic |
| Client has > 700 ad clicks/week | Advanced (meets modeling threshold) |
| Client has < 700 ad clicks/week | Advanced anyway (still provides some modeling) |
| Client has strict legal counsel demanding zero data pre-consent | Basic |
| Default recommendation | **Advanced** |
