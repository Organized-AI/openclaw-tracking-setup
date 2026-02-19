# GTM Tag Patterns

Structural templates for every tag type the agent creates via the GTM MCP API. Includes exact `type` values, `parameter` array structures, and `firingTriggerId` patterns.

---

## GTM API Tag Structure

Every tag created via `mcporter call gtm.create_tag` has this structure:

```
name          - Tag display name (follow GTM-Naming-Conventions.md)
type          - Tag type identifier (see below)
parameter     - Array of parameter objects
firingTriggerId  - Array of trigger IDs that fire this tag
blockingTriggerId - Array of trigger IDs that block this tag (optional)
consentSettings  - Consent configuration (optional)
```

### Parameter Object Format

```json
{"type": "template", "key": "paramName", "value": "paramValue"}
{"type": "boolean", "key": "paramName", "value": "true"}
{"type": "list", "key": "paramName", "list": [...]}
{"type": "map", "key": "paramName", "map": [...]}
```

---

## Google Tag (gtag Config)

**Type:** `googtag`

Used for GA4 configuration and Google Ads global site tag. Fires on Initialization - All Pages.

### GA4 Configuration

```bash
mcporter call gtm.create_tag \
  name="GA4 - Config - G-XXXXXXX" \
  type="googtag" \
  parameter='[
    {"type": "template", "key": "tagId", "value": "G-XXXXXXX"},
    {"type": "template", "key": "configSettingsVariable", "value": "{{CONST - GA4 Config Settings}}"}
  ]' \
  firingTriggerId='["INIT_ALL_PAGES_TRIGGER_ID"]'
```

### With Server-Side Transport

```bash
mcporter call gtm.create_tag \
  name="GA4 - Config - G-XXXXXXX" \
  type="googtag" \
  parameter='[
    {"type": "template", "key": "tagId", "value": "G-XXXXXXX"},
    {"type": "template", "key": "configSettingsTable", "value": ""},
    {"type": "list", "key": "configSettingsVariable", "list": [
      {"type": "map", "map": [
        {"type": "template", "key": "key", "value": "transport_url"},
        {"type": "template", "key": "value", "value": "https://gtm.clientdomain.com"}
      ]},
      {"type": "map", "map": [
        {"type": "template", "key": "key", "value": "first_party_collection"},
        {"type": "template", "key": "value", "value": "true"}
      ]}
    ]}
  ]' \
  firingTriggerId='["INIT_ALL_PAGES_TRIGGER_ID"]'
```

---

## GA4 Event Tag

**Type:** `gaawe` (Google Analytics App + Web Event)

Used for sending individual events to GA4.

### Basic Event (No Parameters)

```bash
mcporter call gtm.create_tag \
  name="GA4 - Event - Generate Lead" \
  type="gaawe" \
  parameter='[
    {"type": "template", "key": "eventName", "value": "generate_lead"},
    {"type": "template", "key": "measurementIdOverride", "value": ""},
    {"type": "boolean", "key": "sendEcommerceData", "value": "false"}
  ]' \
  firingTriggerId='["CE_GENERATE_LEAD_TRIGGER_ID"]'
```

### Event With Custom Parameters

```bash
mcporter call gtm.create_tag \
  name="GA4 - Event - Phone Click" \
  type="gaawe" \
  parameter='[
    {"type": "template", "key": "eventName", "value": "phone_click"},
    {"type": "boolean", "key": "sendEcommerceData", "value": "false"},
    {"type": "list", "key": "eventSettingsTable", "list": [
      {"type": "map", "map": [
        {"type": "template", "key": "parameter", "value": "phone_number"},
        {"type": "template", "key": "parameterValue", "value": "{{DLV - phone_number}}"}
      ]},
      {"type": "map", "map": [
        {"type": "template", "key": "parameter", "value": "click_location"},
        {"type": "template", "key": "parameterValue", "value": "{{DLV - click_location}}"}
      ]}
    ]}
  ]' \
  firingTriggerId='["LC_TEL_LINKS_TRIGGER_ID"]'
```

### Ecommerce Event (Purchase)

```bash
mcporter call gtm.create_tag \
  name="GA4 - Event - Purchase" \
  type="gaawe" \
  parameter='[
    {"type": "template", "key": "eventName", "value": "purchase"},
    {"type": "boolean", "key": "sendEcommerceData", "value": "true"},
    {"type": "template", "key": "getEcommerceDataFrom", "value": "dataLayer"}
  ]' \
  firingTriggerId='["CE_PURCHASE_TRIGGER_ID"]'
```

When `sendEcommerceData` is true and `getEcommerceDataFrom` is "dataLayer", the tag automatically reads all ecommerce parameters from the dataLayer push. No need to manually map items, value, currency, etc.

### Ecommerce Events That Use sendEcommerceData

All of these use the same pattern — only `eventName` and `firingTriggerId` change:

| Event | eventName | Trigger |
|-------|-----------|---------|
| View Item List | `view_item_list` | CE - view_item_list |
| Select Item | `select_item` | CE - select_item |
| View Item | `view_item` | CE - view_item |
| Add to Cart | `add_to_cart` | CE - add_to_cart |
| Remove from Cart | `remove_from_cart` | CE - remove_from_cart |
| View Cart | `view_cart` | CE - view_cart |
| Begin Checkout | `begin_checkout` | CE - begin_checkout |
| Add Shipping Info | `add_shipping_info` | CE - add_shipping_info |
| Add Payment Info | `add_payment_info` | CE - add_payment_info |
| Purchase | `purchase` | CE - purchase |
| Refund | `refund` | CE - refund |

---

## Google Ads Conversion Tag

**Type:** `awct` (AdWords Conversion Tracking)

### Basic Conversion (No Value)

```bash
mcporter call gtm.create_tag \
  name="GAds - Conversion - Lead Form" \
  type="awct" \
  parameter='[
    {"type": "template", "key": "conversionId", "value": "AW-XXXXXXXXX"},
    {"type": "template", "key": "conversionLabel", "value": "XXXXXXXXXXXXX"},
    {"type": "template", "key": "conversionCookiePrefix", "value": "_gcl"}
  ]' \
  firingTriggerId='["CE_GENERATE_LEAD_TRIGGER_ID"]'
```

### Conversion With Dynamic Value

```bash
mcporter call gtm.create_tag \
  name="GAds - Conversion - Purchase" \
  type="awct" \
  parameter='[
    {"type": "template", "key": "conversionId", "value": "AW-XXXXXXXXX"},
    {"type": "template", "key": "conversionLabel", "value": "XXXXXXXXXXXXX"},
    {"type": "template", "key": "conversionValue", "value": "{{DLV - ecommerce.value}}"},
    {"type": "template", "key": "currencyCode", "value": "{{DLV - ecommerce.currency}}"},
    {"type": "template", "key": "orderId", "value": "{{DLV - ecommerce.transaction_id}}"},
    {"type": "template", "key": "conversionCookiePrefix", "value": "_gcl"}
  ]' \
  firingTriggerId='["CE_PURCHASE_TRIGGER_ID"]'
```

### Using Lookup Table for Multiple Conversions

Instead of creating separate tags per conversion, use a Lookup Table variable:

```bash
# Create Lookup Table: Event Name → Conversion Label
mcporter call gtm.create_variable \
  name="LU - Event to GAds Label" \
  type="smm" \
  parameter='[
    {"type": "template", "key": "input", "value": "{{_event}}"},
    {"type": "list", "key": "map", "list": [
      {"type": "map", "map": [
        {"type": "template", "key": "key", "value": "purchase"},
        {"type": "template", "key": "value", "value": "PURCHASE_LABEL"}
      ]},
      {"type": "map", "map": [
        {"type": "template", "key": "key", "value": "generate_lead"},
        {"type": "template", "key": "value", "value": "LEAD_LABEL"}
      ]}
    ]}
  ]'
```

---

## Google Ads Remarketing Tag

**Type:** `sp` (Smart Pixel)

```bash
mcporter call gtm.create_tag \
  name="GAds - Remarketing - All Pages" \
  type="sp" \
  parameter='[
    {"type": "template", "key": "conversionId", "value": "AW-XXXXXXXXX"}
  ]' \
  firingTriggerId='["PV_ALL_PAGES_TRIGGER_ID"]'
```

---

## Conversion Linker

**Type:** `gclidw` (Google Click ID Writer)

**MUST be on every container. Fires on Initialization - All Pages.**

```bash
mcporter call gtm.create_tag \
  name="CL - Conversion Linker" \
  type="gclidw" \
  parameter='[
    {"type": "boolean", "key": "enableCrossDomain", "value": "false"},
    {"type": "boolean", "key": "enableUrlPassthrough", "value": "false"}
  ]' \
  firingTriggerId='["INIT_ALL_PAGES_TRIGGER_ID"]'
```

### With Cross-Domain

```bash
mcporter call gtm.create_tag \
  name="CL - Conversion Linker" \
  type="gclidw" \
  parameter='[
    {"type": "boolean", "key": "enableCrossDomain", "value": "true"},
    {"type": "list", "key": "crossDomainList", "list": [
      {"type": "map", "map": [
        {"type": "template", "key": "domain", "value": "checkout.clientdomain.com"}
      ]}
    ]},
    {"type": "boolean", "key": "enableUrlPassthrough", "value": "true"}
  ]' \
  firingTriggerId='["INIT_ALL_PAGES_TRIGGER_ID"]'
```

---

## Custom HTML Tag

**Type:** `html`

Used for Meta Pixel base code, custom dataLayer enrichment, or any arbitrary JavaScript.

### Meta Pixel Base Code

```bash
mcporter call gtm.create_tag \
  name="Meta - Base - Pixel Init" \
  type="html" \
  parameter='[
    {"type": "template", "key": "html", "value": "<script>!function(f,b,e,v,n,t,s){if(f.fbq)return;n=f.fbq=function(){n.callMethod?n.callMethod.apply(n,arguments):n.queue.push(arguments)};if(!f._fbq)f._fbq=n;n.push=n;n.loaded=!0;n.version=\"2.0\";n.queue=[];t=b.createElement(e);t.async=!0;t.src=v;s=b.getElementsByTagName(e)[0];s.parentNode.insertBefore(t,s)}(window,document,\"script\",\"https://connect.facebook.net/en_US/fbevents.js\");fbq(\"init\", \"PIXEL_ID\");fbq(\"track\", \"PageView\");</script>"},
    {"type": "boolean", "key": "supportDocumentWrite", "value": "false"}
  ]' \
  firingTriggerId='["PV_ALL_PAGES_TRIGGER_ID"]' \
  consentSettings='{"consentStatus": "NEEDED", "consentType": {"ad_storage": true}}'
```

**Note:** If using sGTM for Meta CAPI, the Meta Pixel base code may not be needed client-side (sGTM handles it). Check if client-side Pixel is still desired for deduplication.

### DataLayer Enrichment

```bash
mcporter call gtm.create_tag \
  name="cHTML - Generate Event ID" \
  type="html" \
  parameter='[
    {"type": "template", "key": "html", "value": "<script>(function(){function uuid(){return \"xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx\".replace(/[xy]/g,function(c){var r=Math.random()*16|0,v=c==\"x\"?r:(r&0x3|0x8);return v.toString(16)});}window.dataLayer=window.dataLayer||[];var eid=uuid();window._currentEventId=eid;})();</script>"},
    {"type": "boolean", "key": "supportDocumentWrite", "value": "false"}
  ]' \
  firingTriggerId='["PV_ALL_PAGES_TRIGGER_ID"]'
```

---

## Tag Firing Priority

Tags fire in this order on a typical page:

| Priority | Trigger Type | Tags |
|----------|-------------|------|
| 1 (First) | Consent Initialization | Consent defaults |
| 2 | Initialization - All Pages | Conversion Linker, Google Tag (config) |
| 3 | Page View | Remarketing, Meta Pixel base |
| 4 | DOM Ready | Tags needing DOM elements |
| 5 | Window Loaded | Tags needing all resources |
| 6 | Custom Event / Click / Form | Event-specific tags |

Use tag firing priority (higher number = fires first within same trigger) when you need to control order among tags on the same trigger. Default priority is 0.

```bash
# Set tag priority
mcporter call gtm.create_tag \
  name="Tag Name" \
  type="..." \
  priority=10 \
  ...
```

---

## Consent Settings for Tags

### Google Tags (Automatic)

GA4 and Google Ads tags have built-in consent awareness. They automatically:
- Block when `analytics_storage` / `ad_storage` is denied (Basic mode)
- Fire with reduced data when denied (Advanced mode)
- No manual consent configuration needed

### Custom HTML Tags (Manual)

Custom HTML tags need explicit consent configuration:

```bash
mcporter call gtm.create_tag \
  name="cHTML - Example" \
  type="html" \
  consentSettings='{"consentStatus": "NEEDED", "consentType": {"ad_storage": true, "analytics_storage": true}}' \
  ...
```

Values for `consentStatus`:
- `NOT_SET` — Tag fires regardless of consent (use for consent initialization tag itself)
- `NOT_NEEDED` — Tag doesn't require consent
- `NEEDED` — Tag requires specified consent types to be granted
