# GTM Naming Conventions

Deterministic naming rules for all GTM entities. The agent MUST follow these conventions when creating tags, triggers, and variables via mcporter to ensure consistency across all tracking deployments.

---

## Tag Naming Pattern

**Format:** `[Platform] - [Track Type] - [Detail]`

### Platform Prefixes

| Prefix | Platform |
|--------|----------|
| `GA4` | Google Analytics 4 |
| `GAds` | Google Ads |
| `Meta` | Meta (Facebook) |
| `CL` | Conversion Linker |
| `Consent` | Consent Mode |
| `cHTML` | Custom HTML |
| `sGTM` | Server-side GTM related |
| `Floodlight` | Campaign Manager / DV360 |
| `LinkedIn` | LinkedIn Insight |
| `TikTok` | TikTok Pixel |
| `Pinterest` | Pinterest Tag |

### Track Type Values

| Type | Description |
|------|-------------|
| `Config` | Configuration/initialization tag |
| `Event` | Event tracking tag |
| `Conversion` | Conversion tracking tag |
| `Remarketing` | Remarketing/audience tag |
| `CAPI` | Conversions API (server-side) |
| `Base` | Base pixel/snippet |

### Tag Name Examples

| Tag Name | Description |
|----------|-------------|
| `GA4 - Config - G-XXXXXXX` | GA4 configuration tag |
| `GA4 - Event - Purchase` | GA4 purchase event tag |
| `GA4 - Event - Generate Lead` | GA4 lead event tag |
| `GA4 - Event - Phone Click` | GA4 custom phone click event |
| `GA4 - Event - Video Start` | GA4 video tracking event |
| `GA4 - Event - Scroll Depth` | GA4 scroll tracking event |
| `GAds - Conversion - Purchase` | Google Ads purchase conversion tag |
| `GAds - Conversion - Lead Form` | Google Ads lead conversion tag |
| `GAds - Remarketing - All Pages` | Google Ads remarketing tag |
| `Meta - CAPI - Purchase` | Meta CAPI purchase event (sGTM) |
| `Meta - CAPI - Lead` | Meta CAPI lead event (sGTM) |
| `Meta - Base - Pixel Init` | Meta Pixel base code (if custom HTML) |
| `CL - Conversion Linker` | Google Conversion Linker |
| `Consent - Default State` | Consent Initialization defaults |
| `Consent - Update` | Consent state update from CMP |
| `cHTML - DataLayer Enrichment` | Custom HTML for dataLayer operations |

---

## Trigger Naming Pattern

**Format:** `[Type Prefix] - [Detail]`

### Type Prefixes

| Prefix | Trigger Type | GTM Type Value |
|--------|-------------|---------------|
| `Init` | Initialization | `initialization` |
| `PV` | Page View | `pageview` |
| `DOM` | DOM Ready | `domReady` |
| `WL` | Window Loaded | `windowLoaded` |
| `CE` | Custom Event | `customEvent` |
| `CL` | Click - All Elements | `click` |
| `LC` | Click - Just Links | `linkClick` |
| `FS` | Form Submission | `formSubmission` |
| `EV` | Element Visibility | `elementVisibility` |
| `SC` | Scroll Depth | `scrollDepth` |
| `YT` | YouTube Video | `youTubeVideo` |
| `TM` | Timer | `timer` |
| `HC` | History Change | `historyChange` |

### Trigger Name Examples

| Trigger Name | Description |
|-------------|-------------|
| `Init - All Pages` | Initialization trigger (built-in, for consent + conversion linker) |
| `PV - All Pages` | Pageview on all pages |
| `PV - Thank You Page` | Pageview on /thank-you |
| `PV - Checkout Pages` | Pageview on /checkout/* |
| `CE - purchase` | Custom event: purchase (from dataLayer push) |
| `CE - add_to_cart` | Custom event: add_to_cart |
| `CE - generate_lead` | Custom event: generate_lead |
| `CE - form_submit` | Custom event: form_submit |
| `CL - CTA Button` | Click on CTA buttons (filtered by class/id) |
| `CL - Phone Number` | Click on phone number elements |
| `LC - Tel Links` | Link click on tel: URLs |
| `LC - Mailto Links` | Link click on mailto: URLs |
| `LC - External Links` | Link click on external domains |
| `LC - PDF Downloads` | Link click on .pdf URLs |
| `FS - Contact Form` | Form submission: contact form |
| `FS - Quote Form` | Form submission: quote request form |
| `EV - Footer Visible` | Footer element enters viewport |
| `EV - CTA Section Visible` | CTA section enters viewport |
| `SC - 25 Percent` | Scroll depth: 25% |
| `SC - 50 Percent` | Scroll depth: 50% |
| `SC - 75 Percent` | Scroll depth: 75% |
| `SC - 90 Percent` | Scroll depth: 90% |
| `YT - Video Engagement` | YouTube video: start, progress, complete |
| `TM - 30 Second Engagement` | Timer: 30 seconds on page |
| `HC - SPA Navigation` | History change for SPA routing |

---

## Variable Naming Pattern

**Format:** `[Type Prefix] - [Name]`

### Type Prefixes

| Prefix | Variable Type | GTM Type Value |
|--------|-------------|---------------|
| `DLV` | Data Layer Variable | `v` |
| `CONST` | Constant | `c` |
| `JSV` | Custom JavaScript | `jsm` |
| `LU` | Lookup Table | `smm` |
| `RT` | Regex Table | `remm` |
| `1PK` | First-Party Cookie | `k` |
| `URL` | URL Component | `u` |
| `AEV` | Auto-Event Variable | `aev` |
| `DOM` | DOM Element | `d` |
| `CSS` | CSS Selector | (custom template) |
| `REF` | HTTP Referrer | `f` |
| `JSG` | JavaScript Variable (global) | `j` |

### Variable Name Examples

| Variable Name | Type | Description |
|--------------|------|-------------|
| `CONST - GA4 Measurement ID` | Constant | GA4 property ID (G-XXXXXXX) |
| `CONST - GAds Conversion ID` | Constant | Google Ads conversion ID |
| `CONST - GAds Conversion Label - Purchase` | Constant | Conversion label for purchase |
| `CONST - GAds Conversion Label - Lead` | Constant | Conversion label for lead |
| `CONST - Meta Pixel ID` | Constant | Meta Pixel ID |
| `DLV - ecommerce.transaction_id` | Data Layer | Transaction ID from dataLayer |
| `DLV - ecommerce.value` | Data Layer | Transaction value |
| `DLV - ecommerce.currency` | Data Layer | Currency code |
| `DLV - ecommerce.items` | Data Layer | Items array |
| `DLV - ecommerce.shipping` | Data Layer | Shipping cost |
| `DLV - ecommerce.tax` | Data Layer | Tax amount |
| `DLV - ecommerce.coupon` | Data Layer | Coupon code |
| `DLV - event_id` | Data Layer | Event ID for Meta dedup |
| `DLV - form_id` | Data Layer | Form identifier |
| `DLV - form_name` | Data Layer | Form name |
| `DLV - search_term` | Data Layer | Site search query |
| `DLV - user_id` | Data Layer | Authenticated user ID |
| `DLV - user_data.email` | Data Layer | User email (for hashing) |
| `DLV - user_data.phone` | Data Layer | User phone (for hashing) |
| `JSV - Client ID` | Custom JS | Extracts GA4 client ID from cookie |
| `JSV - UUID Generator` | Custom JS | Generates UUID v4 for event_id |
| `JSV - SHA256 Hash` | Custom JS | SHA256 hashing function |
| `LU - Event to GAds Label` | Lookup Table | Maps event_name → conversion label |
| `LU - Page Type` | Lookup Table | Maps URL patterns → page type |
| `RT - Content Group` | Regex Table | URL regex → content group |
| `1PK - _fbc` | First-Party Cookie | Facebook click ID cookie |
| `1PK - _fbp` | First-Party Cookie | Facebook browser ID cookie |
| `1PK - _ga` | First-Party Cookie | GA4 client ID cookie |
| `URL - Page Path` | URL Component | Page path from URL |
| `URL - Query String` | URL Component | Full query string |
| `URL - utm_source` | URL Component | UTM source parameter |
| `URL - gclid` | URL Component | Google click ID |
| `URL - fbclid` | URL Component | Facebook click ID |

---

## Folder Organization

Use GTM folders to group entities by platform:

| Folder Name | Contains |
|-------------|----------|
| `GA4` | All GA4 tags, triggers, variables |
| `Google Ads` | All GAds conversion + remarketing tags |
| `Meta` | All Meta Pixel/CAPI tags |
| `Consent` | Consent initialization + update tags |
| `Utility` | Conversion Linker, Lookup Tables, helper variables |
| `Custom` | Custom HTML tags, custom JS variables |

---

## General Rules

1. **Title Case** for entity names (Tag Name, Trigger Name, Variable Name)
2. **snake_case** only inside event/parameter names sent TO GA4 (these are GA4's requirement, not GTM's)
3. **Dash separator** ( - ) between prefix and name, with spaces around the dash
4. **No special characters** in names except dashes, spaces, underscores, and periods
5. **Keep names under 50 characters** — long names get truncated in GTM UI
6. **Be specific** — "CL - CTA Button" is better than "CL - Button Click"
7. **Include identifiers** when there are multiples — "FS - Contact Form" vs "FS - Quote Form"
8. **Use the same event name in trigger and tag** — if trigger is "CE - purchase", tag should be "GA4 - Event - Purchase"
