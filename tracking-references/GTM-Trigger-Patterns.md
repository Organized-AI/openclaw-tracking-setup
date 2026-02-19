# GTM Trigger Patterns

Structural templates for every trigger type. Includes exact `type` values, `filter`/`customEventFilter` JSON structures, and site scanning context for when each trigger type is appropriate.

---

## GTM API Trigger Structure

Every trigger created via `mcporter call gtm.create_trigger` has:

```
name                - Trigger display name (follow GTM-Naming-Conventions.md)
type                - Trigger type identifier (see below)
filter              - Array of filter conditions (for built-in triggers)
customEventFilter   - Array of conditions for Custom Event triggers
autoEventFilter     - Array of conditions for click/form/visibility triggers
```

### Filter Condition Format

```json
{
  "type": "equals",
  "parameter": [
    {"type": "template", "key": "arg0", "value": "{{variable}}"},
    {"type": "template", "key": "arg1", "value": "match_value"}
  ]
}
```

**Filter types:** `equals`, `contains`, `startsWith`, `endsWith`, `matchRegex`, `doesNotEqual`, `doesNotContain`, `doesNotStartWith`, `doesNotEndWith`, `doesNotMatchRegex`, `less`, `lessOrEquals`, `greater`, `greaterOrEquals`, `cssSelector`, `urlMatches`

---

## Page View Triggers

### Page View - All Pages

**Type:** `pageview`

**Site scan context:** Every site needs at least one pageview trigger for config and remarketing tags.

```bash
mcporter call gtm.create_trigger \
  name="PV - All Pages" \
  type="pageview"
```

No filter = fires on every page.

### Page View - Specific Pages

**Type:** `pageview`

**Site scan context:** Use when you find thank-you pages, confirmation pages, or specific URL paths that indicate conversions.

```bash
# Exact path match
mcporter call gtm.create_trigger \
  name="PV - Thank You Page" \
  type="pageview" \
  filter='[{
    "type": "equals",
    "parameter": [
      {"type": "template", "key": "arg0", "value": "{{Page Path}}"},
      {"type": "template", "key": "arg1", "value": "/thank-you"}
    ]
  }]'
```

```bash
# Path starts with (for checkout pages)
mcporter call gtm.create_trigger \
  name="PV - Checkout Pages" \
  type="pageview" \
  filter='[{
    "type": "startsWith",
    "parameter": [
      {"type": "template", "key": "arg0", "value": "{{Page Path}}"},
      {"type": "template", "key": "arg1", "value": "/checkout"}
    ]
  }]'
```

```bash
# Regex match (multiple patterns)
mcporter call gtm.create_trigger \
  name="PV - Product Pages" \
  type="pageview" \
  filter='[{
    "type": "matchRegex",
    "parameter": [
      {"type": "template", "key": "arg0", "value": "{{Page Path}}"},
      {"type": "template", "key": "arg1", "value": "^/products/[^/]+$"}
    ]
  }]'
```

---

## DOM Ready

**Type:** `domReady`

**Site scan context:** Use when tags need to read DOM elements (e.g., product data from page markup, form field values).

```bash
mcporter call gtm.create_trigger \
  name="DOM - All Pages" \
  type="domReady"
```

With page filter:
```bash
mcporter call gtm.create_trigger \
  name="DOM - Product Pages" \
  type="domReady" \
  filter='[{
    "type": "matchRegex",
    "parameter": [
      {"type": "template", "key": "arg0", "value": "{{Page Path}}"},
      {"type": "template", "key": "arg1", "value": "^/products/"}
    ]
  }]'
```

---

## Window Loaded

**Type:** `windowLoaded`

**Site scan context:** Rarely needed. Use for tags that must wait for all resources (images, scripts) to load.

```bash
mcporter call gtm.create_trigger \
  name="WL - All Pages" \
  type="windowLoaded"
```

---

## Custom Event

**Type:** `customEvent`

**Site scan context:** The most important trigger type for ecommerce and dynamic sites. Used when the site pushes events to dataLayer (`dataLayer.push({event: "event_name", ...})`). Check for existing dataLayer pushes during site scan.

### Match Specific Event Name

```bash
mcporter call gtm.create_trigger \
  name="CE - purchase" \
  type="customEvent" \
  customEventFilter='[{
    "type": "equals",
    "parameter": [
      {"type": "template", "key": "arg0", "value": "{{_event}}"},
      {"type": "template", "key": "arg1", "value": "purchase"}
    ]
  }]'
```

### Match Event Name with Regex

```bash
mcporter call gtm.create_trigger \
  name="CE - Ecommerce Events" \
  type="customEvent" \
  customEventFilter='[{
    "type": "matchRegex",
    "parameter": [
      {"type": "template", "key": "arg0", "value": "{{_event}}"},
      {"type": "template", "key": "arg1", "value": "^(view_item|add_to_cart|begin_checkout|purchase)$"}
    ]
  }]'
```

### Common Custom Events to Create

| Trigger Name | Event Name | When Detected During Scan |
|-------------|-----------|--------------------------|
| `CE - purchase` | purchase | Order confirmation page with dataLayer push |
| `CE - add_to_cart` | add_to_cart | Add-to-cart button with dataLayer push |
| `CE - begin_checkout` | begin_checkout | Checkout initiation with dataLayer push |
| `CE - view_item` | view_item | Product page with dataLayer push |
| `CE - view_item_list` | view_item_list | Category page with dataLayer push |
| `CE - generate_lead` | generate_lead | Form submission with dataLayer push |
| `CE - form_submit` | form_submit | Enhanced measurement form event |
| `CE - sign_up` | sign_up | Account creation with dataLayer push |

---

## Click - All Elements

**Type:** `click`

**Site scan context:** Use when you find non-link clickable elements (buttons, divs with click handlers, tabs, accordions).

### Filter by CSS Class

```bash
mcporter call gtm.create_trigger \
  name="CL - CTA Button" \
  type="click" \
  autoEventFilter='[{
    "type": "contains",
    "parameter": [
      {"type": "template", "key": "arg0", "value": "{{Click Classes}}"},
      {"type": "template", "key": "arg1", "value": "cta-button"}
    ]
  }]'
```

### Filter by Element ID

```bash
mcporter call gtm.create_trigger \
  name="CL - Submit Button" \
  type="click" \
  autoEventFilter='[{
    "type": "equals",
    "parameter": [
      {"type": "template", "key": "arg0", "value": "{{Click ID}}"},
      {"type": "template", "key": "arg1", "value": "submit-btn"}
    ]
  }]'
```

### Filter by Click Text

```bash
mcporter call gtm.create_trigger \
  name="CL - Get a Quote Buttons" \
  type="click" \
  autoEventFilter='[{
    "type": "matchRegex",
    "parameter": [
      {"type": "template", "key": "arg0", "value": "{{Click Text}}"},
      {"type": "template", "key": "arg1", "value": "(?i)(get a quote|request quote|free quote)"}
    ]
  }]'
```

### Filter by CSS Selector (Most Precise)

```bash
mcporter call gtm.create_trigger \
  name="CL - Hero CTA" \
  type="click" \
  autoEventFilter='[{
    "type": "cssSelector",
    "parameter": [
      {"type": "template", "key": "arg0", "value": "{{Click Element}}"},
      {"type": "template", "key": "arg1", "value": ".hero-section .btn-primary"}
    ]
  }]'
```

---

## Click - Just Links

**Type:** `linkClick`

**Site scan context:** Use when you find `<a>` tags with specific href patterns (tel:, mailto:, file downloads, external links).

### Phone Number Links

```bash
mcporter call gtm.create_trigger \
  name="LC - Tel Links" \
  type="linkClick" \
  autoEventFilter='[{
    "type": "startsWith",
    "parameter": [
      {"type": "template", "key": "arg0", "value": "{{Click URL}}"},
      {"type": "template", "key": "arg1", "value": "tel:"}
    ]
  }]'
```

### Email Links

```bash
mcporter call gtm.create_trigger \
  name="LC - Mailto Links" \
  type="linkClick" \
  autoEventFilter='[{
    "type": "startsWith",
    "parameter": [
      {"type": "template", "key": "arg0", "value": "{{Click URL}}"},
      {"type": "template", "key": "arg1", "value": "mailto:"}
    ]
  }]'
```

### File Downloads

```bash
mcporter call gtm.create_trigger \
  name="LC - PDF Downloads" \
  type="linkClick" \
  autoEventFilter='[{
    "type": "matchRegex",
    "parameter": [
      {"type": "template", "key": "arg0", "value": "{{Click URL}}"},
      {"type": "template", "key": "arg1", "value": "\\.(pdf|doc|docx|xls|xlsx|zip|csv)$"}
    ]
  }]'
```

### External Links

```bash
mcporter call gtm.create_trigger \
  name="LC - External Links" \
  type="linkClick" \
  autoEventFilter='[{
    "type": "doesNotContain",
    "parameter": [
      {"type": "template", "key": "arg0", "value": "{{Click URL}}"},
      {"type": "template", "key": "arg1", "value": "clientdomain.com"}
    ]
  }]'
```

---

## Form Submission

**Type:** `formSubmission`

**Site scan context:** Use when you find standard `<form>` elements. NOT for AJAX/JavaScript forms (those need Custom Event triggers).

### Specific Form by ID

```bash
mcporter call gtm.create_trigger \
  name="FS - Contact Form" \
  type="formSubmission" \
  autoEventFilter='[{
    "type": "equals",
    "parameter": [
      {"type": "template", "key": "arg0", "value": "{{Form ID}}"},
      {"type": "template", "key": "arg1", "value": "contact-form"}
    ]
  }]'
```

### Form by Page Path

```bash
mcporter call gtm.create_trigger \
  name="FS - Quote Page Form" \
  type="formSubmission" \
  filter='[{
    "type": "equals",
    "parameter": [
      {"type": "template", "key": "arg0", "value": "{{Page Path}}"},
      {"type": "template", "key": "arg1", "value": "/get-a-quote"}
    ]
  }]'
```

### All Forms

```bash
mcporter call gtm.create_trigger \
  name="FS - All Forms" \
  type="formSubmission"
```

**Warning:** "All Forms" can fire on search forms, login forms, newsletter signups, etc. Prefer filtering by Form ID, Form Classes, or page path.

### Form Detection During Site Scan

| Element Found | Trigger Approach |
|--------------|-----------------|
| Standard `<form>` with visible submit button | Form Submission trigger |
| AJAX form (no page reload on submit) | Custom Event trigger (site must push to dataLayer) |
| HubSpot embedded form | Custom Event: `hsFormCallback` |
| Gravity Forms (WordPress) | Custom Event: `gform_confirmation_loaded` |
| Contact Form 7 (WordPress) | Custom Event: `wpcf7mailsent` |
| Typeform embed | Custom Event: `typeform-submit` |
| Calendly embed | Custom Event: `calendly.event_scheduled` |

---

## Element Visibility

**Type:** `elementVisibility`

**Site scan context:** Use when you want to track when specific page sections come into view (footer, pricing section, CTA section, testimonials).

### By Element ID

```bash
mcporter call gtm.create_trigger \
  name="EV - Footer Visible" \
  type="elementVisibility" \
  parameter='[
    {"type": "template", "key": "selectorType", "value": "ID"},
    {"type": "template", "key": "elementId", "value": "site-footer"},
    {"type": "template", "key": "useOnScreenDuration", "value": "false"},
    {"type": "template", "key": "useDomChangeListener", "value": "false"},
    {"type": "template", "key": "firingFrequency", "value": "ONCE_PER_PAGE"},
    {"type": "template", "key": "onScreenRatio", "value": "50"}
  ]'
```

### By CSS Selector

```bash
mcporter call gtm.create_trigger \
  name="EV - CTA Section Visible" \
  type="elementVisibility" \
  parameter='[
    {"type": "template", "key": "selectorType", "value": "CSS"},
    {"type": "template", "key": "elementSelector", "value": ".cta-section"},
    {"type": "template", "key": "useOnScreenDuration", "value": "false"},
    {"type": "template", "key": "useDomChangeListener", "value": "true"},
    {"type": "template", "key": "firingFrequency", "value": "ONCE_PER_ELEMENT"},
    {"type": "template", "key": "onScreenRatio", "value": "50"}
  ]'
```

**Firing frequency options:**
- `ONCE_PER_PAGE` — Fires once per page load
- `ONCE_PER_ELEMENT` — Fires once per matching element
- `EVERY_TIME` — Fires every time element becomes visible

---

## Scroll Depth

**Type:** `scrollDepth`

**Site scan context:** Use on content-heavy pages (blog posts, articles, long landing pages) where scroll depth indicates engagement.

```bash
mcporter call gtm.create_trigger \
  name="SC - 90 Percent" \
  type="scrollDepth" \
  parameter='[
    {"type": "template", "key": "verticalThresholdsPercent", "value": "90"},
    {"type": "template", "key": "verticalThresholdOn", "value": "true"},
    {"type": "template", "key": "horizontalThresholdOn", "value": "false"},
    {"type": "template", "key": "triggerStartOption", "value": "WINDOW_LOAD"},
    {"type": "template", "key": "verticalThresholdUnits", "value": "PERCENT"}
  ]'
```

### Multiple Thresholds

```bash
mcporter call gtm.create_trigger \
  name="SC - 25/50/75/90 Percent" \
  type="scrollDepth" \
  parameter='[
    {"type": "template", "key": "verticalThresholdsPercent", "value": "25,50,75,90"},
    {"type": "template", "key": "verticalThresholdOn", "value": "true"},
    {"type": "template", "key": "horizontalThresholdOn", "value": "false"},
    {"type": "template", "key": "triggerStartOption", "value": "WINDOW_LOAD"},
    {"type": "template", "key": "verticalThresholdUnits", "value": "PERCENT"}
  ]'
```

Use `{{Scroll Depth Threshold}}` variable in the GA4 tag to capture which threshold was crossed.

---

## YouTube Video

**Type:** `youTubeVideo`

**Site scan context:** Use when YouTube iframes are detected on the page (`youtube.com/embed/` in src attribute).

```bash
mcporter call gtm.create_trigger \
  name="YT - Video Engagement" \
  type="youTubeVideo" \
  parameter='[
    {"type": "template", "key": "captureStart", "value": "true"},
    {"type": "template", "key": "captureComplete", "value": "true"},
    {"type": "template", "key": "capturePause", "value": "true"},
    {"type": "template", "key": "captureProgress", "value": "true"},
    {"type": "template", "key": "progressThresholdsPercent", "value": "10,25,50,75"},
    {"type": "template", "key": "fixMissingApi", "value": "true"},
    {"type": "template", "key": "triggerStartOption", "value": "WINDOW_LOAD"}
  ]'
```

**Built-in variables available:** `{{Video Title}}`, `{{Video URL}}`, `{{Video Status}}`, `{{Video Percent}}`, `{{Video Duration}}`, `{{Video Visible}}`

**Note:** `fixMissingApi: true` — adds YouTube iframe API to pages that don't include it. Required for tracking to work on most sites.

---

## Timer

**Type:** `timer`

**Site scan context:** Use for time-based engagement tracking (e.g., user spent 30+ seconds on page).

```bash
mcporter call gtm.create_trigger \
  name="TM - 30 Second Engagement" \
  type="timer" \
  parameter='[
    {"type": "template", "key": "interval", "value": "30000"},
    {"type": "template", "key": "limit", "value": "1"},
    {"type": "template", "key": "uniqueTriggerId", "value": "TIMER_30S"}
  ]'
```

- `interval` — Milliseconds between fires (30000 = 30 seconds)
- `limit` — Max number of times to fire (1 = once)
- Page-specific by adding filter conditions

---

## History Change

**Type:** `historyChange`

**Site scan context:** Use on Single Page Applications (React, Vue, Angular, Next.js) where navigation doesn't trigger a full page load.

```bash
mcporter call gtm.create_trigger \
  name="HC - SPA Navigation" \
  type="historyChange"
```

Use this with a GA4 page_view event tag to track virtual page views in SPAs.

**Detection during scan:** Check for React (`__NEXT_DATA__`, `#root`), Vue (`#app`, `__vue__`), Angular (`ng-version`). If SPA detected, add History Change trigger for page tracking.
