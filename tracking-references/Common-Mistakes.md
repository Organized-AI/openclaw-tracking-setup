# Common Tracking Implementation Mistakes

Explicit "do not do this" reference. The agent should self-check against this list during Phase 3 (Plan) and Phase 5 (Verify) to catch errors before they reach production.

---

## GA4 Mistakes

### Event Naming

- **WRONG:** `AddToCart`, `addToCart`, `Add_To_Cart`
  **RIGHT:** `add_to_cart` — GA4 requires strict snake_case

- **WRONG:** Creating a custom `page_view` event tag
  **RIGHT:** `page_view` is automatically collected — don't duplicate it. Only create a custom tag if you need additional parameters.

- **WRONG:** `ga_purchase`, `google_signup`
  **RIGHT:** No `ga_`, `google_`, `firebase_` prefixes — these are reserved

- **WRONG:** Event name `user_clicked_on_the_cta_button_in_hero_section` (52 chars)
  **RIGHT:** `cta_click` — max 40 characters

### Parameters

- **WRONG:** Sending `value: 29.99` without `currency`
  **RIGHT:** Always send `value` AND `currency` together. GA4 silently drops value if currency is missing.

- **WRONG:** `items: {item_id: "SKU1", item_name: "Shirt"}` (object)
  **RIGHT:** `items: [{item_id: "SKU1", item_name: "Shirt"}]` (array, even for single items)

- **WRONG:** `price: "$29.99"` (string with dollar sign)
  **RIGHT:** `price: 29.99` (number, no currency symbol)

- **WRONG:** Reusing the same `transaction_id` across different orders
  **RIGHT:** Every transaction_id must be unique. Duplicates cause GA4 to deduplicate (drop) the event.

- **WRONG:** `quantity: "2"` (string)
  **RIGHT:** `quantity: 2` (number)

### Custom Dimensions

- **WRONG:** Registering 60 event-scoped custom dimensions
  **RIGHT:** Max 50 event-scoped, 50 custom metrics, 25 user-scoped. Plan carefully.

- **WRONG:** Sending high-cardinality values as custom dimensions (user IDs, timestamps)
  **RIGHT:** Use low-to-medium cardinality values. High-cardinality dimensions cause "(other)" grouping.

---

## GTM Mistakes

### Tag Firing Order

- **WRONG:** Event tags firing before the Google Tag (config) tag
  **RIGHT:** Google Tag must fire on Initialization - All Pages BEFORE any event tags

- **WRONG:** Tags firing before Consent Initialization
  **RIGHT:** Consent Initialization must be the FIRST thing that fires. Use the Consent Initialization trigger type.

- **WRONG:** Firing Conversion Linker only on conversion pages
  **RIGHT:** Conversion Linker MUST fire on ALL PAGES (Initialization - All Pages). It reads gclid/dclid from the URL on landing pages.

### Tag Configuration

- **WRONG:** Creating a Google Ads conversion tag without a Conversion Linker tag in the container
  **RIGHT:** Conversion Linker is REQUIRED for Google Ads conversion tracking to work. Without it, conversions will not be attributed.

- **WRONG:** Using "All Pages" trigger for a purchase event tag
  **RIGHT:** Purchase tag should only fire on the purchase Custom Event trigger — firing on all pages wastes requests and may cause false conversions

- **WRONG:** Leaving test/debug tags in the container before publishing
  **RIGHT:** Remove all debug-only tags before creating the publish version

### Variables

- **WRONG:** Data Layer Variable reading from v1 format: `transactionId`
  **RIGHT:** Use v2 format: `ecommerce.transaction_id` (with dataLayerVersion set to 2)

- **WRONG:** Variable name `{{ecommerce.items}}` in tag parameter
  **RIGHT:** Just `ecommerce.items` as the Data Layer Variable name. The `{{}}` notation is for referencing variables in the GTM UI, not in API calls.

- **WRONG:** Hardcoding GA4 Measurement ID in every tag
  **RIGHT:** Create a Constant variable `CONST - GA4 Measurement ID` and reference it in all tags

### Publishing

- **WRONG:** Publishing directly without preview testing
  **RIGHT:** ALWAYS test in GTM Preview mode before publishing

- **WRONG:** Publishing during high-traffic hours without a rollback plan
  **RIGHT:** Publish during low-traffic windows when possible. Know how to revert to previous version.

---

## Google Ads Mistakes

### Conversion Actions

- **WRONG:** Using `EVERY_CONVERSION` for lead form submissions
  **RIGHT:** Use `ONE_PER_CLICK` for leads. A user submitting the same form 3 times is still one lead.

- **WRONG:** Making all 8 conversion actions primary
  **RIGHT:** Max 1-3 primary actions. The rest should be secondary (observation). Too many primaries confuses Smart Bidding.

- **WRONG:** Using `DEFAULT` category for all conversion actions
  **RIGHT:** Use specific categories (PURCHASE, SUBMIT_LEAD_FORM, etc.). Google uses categories for reporting and optimization.

- **WRONG:** Last-click attribution when DDA is available
  **RIGHT:** Use Data-Driven Attribution (DDA) unless the account has < 300 conversions in 30 days

- **WRONG:** No conversion value on Purchase actions
  **RIGHT:** Purchase MUST have dynamic value (`always_use_default: false`). Without value, ROAS-based bidding won't work.

- **WRONG:** Creating duplicate conversion actions for the same event (e.g., two "Purchase" actions)
  **RIGHT:** One conversion action per distinct business action. Duplicates double-count conversions.

### Budget and Campaigns

- **WRONG:** `--budget-amount-micros 50` (meaning $0.00005/day)
  **RIGHT:** `--budget-amount-micros 50000000` ($50/day). Budgets are in micros (millionths of the currency unit).

- **WRONG:** Creating campaigns with `--status ENABLED`
  **RIGHT:** Always create with `--status PAUSED`. Confirm with human before enabling.

---

## Meta CAPI Mistakes

### Event Deduplication

- **WRONG:** Running Pixel + CAPI without event_id
  **RIGHT:** event_id is REQUIRED when running both. Without it, Meta double-counts conversions.

- **WRONG:** Different event_id on Pixel vs CAPI for the same user action
  **RIGHT:** SAME event_id must be sent from both browser (Pixel) and server (CAPI)

- **WRONG:** Using timestamp as event_id
  **RIGHT:** Use UUID v4, or transaction_id for purchase events. Timestamps can collide across users.

### User Data

- **WRONG:** Sending email as plain text: `em: "john@example.com"`
  **RIGHT:** Hash with SHA256 after normalizing: lowercase, trim whitespace, then SHA256

- **WRONG:** Hashing IP address: `client_ip_address: SHA256("1.2.3.4")`
  **RIGHT:** client_ip_address and client_user_agent are sent as PLAIN TEXT, NOT hashed

- **WRONG:** Hashing fbc/fbp cookies
  **RIGHT:** fbc and fbp are sent as PLAIN TEXT, NOT hashed

- **WRONG:** Phone number with formatting: hash of "+1 (555) 123-4567"
  **RIGHT:** Strip to digits with country code first: `15551234567`, then SHA256

- **WRONG:** Not sending fbp/fbc (relying only on email)
  **RIGHT:** Always extract _fbp and _fbc cookies. These are the highest-impact fields after email for EMQ.

### Purchase Events

- **WRONG:** Meta Purchase event without `value`
  **RIGHT:** `value` is REQUIRED for Purchase events. Without it, ROAS optimization won't work.

- **WRONG:** Meta Purchase event without `currency`
  **RIGHT:** `currency` is REQUIRED alongside value. Use ISO 4217 (USD, EUR, GBP).

### Budget

- **WRONG:** `--daily-budget 50` (meaning $0.50/day)
  **RIGHT:** `--daily-budget 5000` ($50/day). Meta budgets are in CENTS.

- **WRONG:** Creating campaigns with `--status ACTIVE`
  **RIGHT:** Always create with `--status PAUSED`. Confirm with human before activating.

### Action Source

- **WRONG:** `action_source: "server"` for web tracking
  **RIGHT:** `action_source: "website"` for all web-based tracking via Pixel/sGTM

---

## Consent Mode Mistakes

- **WRONG:** Setting consent defaults AFTER tags have already fired
  **RIGHT:** Consent Initialization must fire BEFORE all other tags. Use Consent Initialization trigger type.

- **WRONG:** Only setting `ad_storage` and `analytics_storage` (v1)
  **RIGHT:** Consent Mode v2 REQUIRES `ad_user_data` AND `ad_personalization` in addition to ad_storage and analytics_storage

- **WRONG:** Using Basic consent mode and wondering why conversion data is missing
  **RIGHT:** Basic mode blocks tags entirely when consent denied. Use Advanced mode for cookieless pings and conversion modeling.

- **WRONG:** Defaulting all consent to `granted` for EU users
  **RIGHT:** EU/EEA users must default to `denied`. Use region-specific defaults.

- **WRONG:** Not testing the consent denied state
  **RIGHT:** Test both granted AND denied states. Verify tags behave correctly in both scenarios.

---

## Server-Side GTM (sGTM) Mistakes

- **WRONG:** Not setting `transport_url` on the web GA4 tag
  **RIGHT:** Without transport_url, traffic goes directly to Google (bypassing sGTM). Set to your custom domain (e.g., `https://gtm.clientdomain.com`).

- **WRONG:** Not enabling Cookie Keeper in Stape
  **RIGHT:** Without Cookie Keeper, Safari ITP truncates _ga, _fbc, _fbp cookies to 7 days. Enable it.

- **WRONG:** Using the Stape default domain (e.g., stape.io subdomain)
  **RIGHT:** Set up a custom domain (gtm.clientdomain.com). Default domains are more likely to be blocked by ad blockers.

- **WRONG:** Not forwarding client IP and user agent to Meta CAPI tag
  **RIGHT:** sGTM receives these from the original request. The Meta CAPI tag needs them explicitly configured to forward. Without them, EMQ drops significantly.

- **WRONG:** Testing with real conversion data on production containers
  **RIGHT:** Use GTM Preview mode and Stape debug logs. Meta has a Test Events tool in Events Manager.

---

## Site Scanning Mistakes

- **WRONG:** Only scanning the homepage and assuming the whole site is similar
  **RIGHT:** Crawl ALL key page types: homepage, category, product/service, blog, contact, about, checkout, thank-you

- **WRONG:** Missing dynamically loaded elements (AJAX forms, modals, lazy-loaded content)
  **RIGHT:** Interact with the page — click buttons, scroll, open modals. SPAs load content dynamically.

- **WRONG:** Not checking for existing dataLayer implementation
  **RIGHT:** Always run `console.log(window.dataLayer)` first. If the site already pushes events, build on existing structure.

- **WRONG:** Assuming forms use standard `<form>` submissions
  **RIGHT:** Many modern forms use JavaScript (AJAX) submission. These need Custom Event triggers, not Form Submission triggers.

- **WRONG:** Ignoring mobile viewport differences
  **RIGHT:** Some elements (hamburger menus, mobile CTAs, sticky phone buttons) only appear on mobile. Test both viewports.
