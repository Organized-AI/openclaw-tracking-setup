# GTM Variable Patterns

Templates for common GTM variable configurations created via the GTM MCP API. Variables are the foundation — tags and triggers depend on them. Always create variables FIRST in the implementation order.

---

## GTM API Variable Structure

Every variable created via `mcporter call gtm.create_variable` has:

```
name       - Variable display name (follow GTM-Naming-Conventions.md)
type       - Variable type identifier (see below)
parameter  - Array of parameter objects defining the variable's configuration
```

---

## Data Layer Variable (type: `v`)

Reads values from the dataLayer. The most commonly used variable type for ecommerce and custom event tracking.

### Basic Data Layer Variable

```bash
mcporter call gtm.create_variable \
  name="DLV - ecommerce.transaction_id" \
  type="v" \
  parameter='[
    {"type": "integer", "key": "dataLayerVersion", "value": "2"},
    {"type": "template", "key": "name", "value": "ecommerce.transaction_id"},
    {"type": "boolean", "key": "setDefaultValue", "value": "false"}
  ]'
```

### With Default Value

```bash
mcporter call gtm.create_variable \
  name="DLV - ecommerce.currency" \
  type="v" \
  parameter='[
    {"type": "integer", "key": "dataLayerVersion", "value": "2"},
    {"type": "template", "key": "name", "value": "ecommerce.currency"},
    {"type": "boolean", "key": "setDefaultValue", "value": "true"},
    {"type": "template", "key": "defaultValue", "value": "USD"}
  ]'
```

### Standard Ecommerce Variables to Create

| Variable Name | DataLayer Path | Used By |
|--------------|----------------|---------|
| `DLV - ecommerce.transaction_id` | ecommerce.transaction_id | Purchase tag, Google Ads conversion |
| `DLV - ecommerce.value` | ecommerce.value | Purchase tag, Google Ads conversion, Meta CAPI |
| `DLV - ecommerce.currency` | ecommerce.currency | Purchase tag, Google Ads conversion, Meta CAPI |
| `DLV - ecommerce.tax` | ecommerce.tax | Purchase tag |
| `DLV - ecommerce.shipping` | ecommerce.shipping | Purchase tag |
| `DLV - ecommerce.coupon` | ecommerce.coupon | Checkout/purchase tags |
| `DLV - ecommerce.items` | ecommerce.items | All ecommerce event tags |
| `DLV - ecommerce.shipping_tier` | ecommerce.shipping_tier | Add shipping info tag |
| `DLV - ecommerce.payment_type` | ecommerce.payment_type | Add payment info tag |
| `DLV - ecommerce.item_list_id` | ecommerce.item_list_id | View/select item list tags |
| `DLV - ecommerce.item_list_name` | ecommerce.item_list_name | View/select item list tags |

### Custom Event Variables

| Variable Name | DataLayer Path | Used By |
|--------------|----------------|---------|
| `DLV - event_id` | eventModel.event_id | Meta CAPI deduplication |
| `DLV - form_id` | form_id | Form tracking tags |
| `DLV - form_name` | form_name | Form tracking tags |
| `DLV - search_term` | search_term | Search event tag |
| `DLV - user_id` | user_id | User identification |
| `DLV - user_data.email` | user_data.email | Meta CAPI user matching |
| `DLV - user_data.phone` | user_data.phone | Meta CAPI user matching |
| `DLV - user_data.first_name` | user_data.first_name | Meta CAPI user matching |
| `DLV - user_data.last_name` | user_data.last_name | Meta CAPI user matching |
| `DLV - phone_number` | phone_number | Phone click event |
| `DLV - click_location` | click_location | CTA/click event context |

**Important:** Always set `dataLayerVersion` to `2` for GA4 ecommerce format.

---

## Constant Variable (type: `c`)

Stores fixed values referenced by multiple tags. Prevents hardcoding IDs in every tag.

```bash
mcporter call gtm.create_variable \
  name="CONST - GA4 Measurement ID" \
  type="c" \
  parameter='[
    {"type": "template", "key": "value", "value": "G-XXXXXXX"}
  ]'
```

### Standard Constants to Create

| Variable Name | Value | Purpose |
|--------------|-------|---------|
| `CONST - GA4 Measurement ID` | G-XXXXXXX | GA4 property ID |
| `CONST - GAds Conversion ID` | AW-XXXXXXXXX | Google Ads account conversion ID |
| `CONST - GAds Conversion Label - Purchase` | XXXXXXXXXXXXX | Purchase conversion label |
| `CONST - GAds Conversion Label - Lead` | XXXXXXXXXXXXX | Lead conversion label |
| `CONST - Meta Pixel ID` | 1234567890 | Meta Pixel ID |
| `CONST - sGTM Transport URL` | https://gtm.clientdomain.com | Server-side GTM endpoint |

---

## Custom JavaScript Variable (type: `jsm`)

Executes a JavaScript function and returns the result. Used for computed values.

### UUID Generator (for event_id)

```bash
mcporter call gtm.create_variable \
  name="JSV - UUID Generator" \
  type="jsm" \
  parameter='[
    {"type": "template", "key": "javascript", "value": "function(){return \"xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx\".replace(/[xy]/g,function(c){var r=Math.random()*16|0,v=c===\"x\"?r:(r&0x3|0x8);return v.toString(16);});}"}
  ]'
```

### Extract GA Client ID from Cookie

```bash
mcporter call gtm.create_variable \
  name="JSV - GA Client ID" \
  type="jsm" \
  parameter='[
    {"type": "template", "key": "javascript", "value": "function(){try{var cookie=document.cookie.match(/_ga=GA\\d+\\.\\d+\\.(.+)/);return cookie?cookie[1]:undefined;}catch(e){return undefined;}}"}
  ]'
```

### SHA256 Hash Function

```bash
mcporter call gtm.create_variable \
  name="JSV - SHA256 Hash" \
  type="jsm" \
  parameter='[
    {"type": "template", "key": "javascript", "value": "function(){return async function(str){if(!str)return\"\";var normalized=str.toString().toLowerCase().trim();var encoder=new TextEncoder();var data=encoder.encode(normalized);var hashBuffer=await crypto.subtle.digest(\"SHA-256\",data);var hashArray=Array.from(new Uint8Array(hashBuffer));return hashArray.map(function(b){return b.toString(16).padStart(2,\"0\")}).join(\"\");};}"}
  ]'
```

### Get Page Type from URL

```bash
mcporter call gtm.create_variable \
  name="JSV - Page Type" \
  type="jsm" \
  parameter='[
    {"type": "template", "key": "javascript", "value": "function(){var path=window.location.pathname;if(path===\"/\")return \"homepage\";if(path.match(/^\\/products\\//))return \"product\";if(path.match(/^\\/collections\\//))return \"category\";if(path.match(/^\\/cart/))return \"cart\";if(path.match(/^\\/checkout/))return \"checkout\";if(path.match(/^\\/blog\\//))return \"article\";if(path.match(/\\/thank-you/))return \"confirmation\";return \"other\";}"}
  ]'
```

### Timestamp Generator

```bash
mcporter call gtm.create_variable \
  name="JSV - Timestamp" \
  type="jsm" \
  parameter='[
    {"type": "template", "key": "javascript", "value": "function(){return Math.floor(Date.now()/1000);}"}
  ]'
```

---

## Lookup Table (type: `smm`)

Maps input values to output values. Useful for routing — e.g., mapping event names to Google Ads conversion labels.

### Event Name → Google Ads Conversion Label

```bash
mcporter call gtm.create_variable \
  name="LU - Event to GAds Label" \
  type="smm" \
  parameter='[
    {"type": "template", "key": "input", "value": "{{_event}}"},
    {"type": "list", "key": "map", "list": [
      {"type": "map", "map": [
        {"type": "template", "key": "key", "value": "purchase"},
        {"type": "template", "key": "value", "value": "abc123PURCHASE"}
      ]},
      {"type": "map", "map": [
        {"type": "template", "key": "key", "value": "generate_lead"},
        {"type": "template", "key": "value", "value": "def456LEAD"}
      ]},
      {"type": "map", "map": [
        {"type": "template", "key": "key", "value": "phone_click"},
        {"type": "template", "key": "value", "value": "ghi789PHONE"}
      ]}
    ]},
    {"type": "template", "key": "defaultValue", "value": ""}
  ]'
```

### Page Path → Content Group

```bash
mcporter call gtm.create_variable \
  name="LU - Content Group" \
  type="smm" \
  parameter='[
    {"type": "template", "key": "input", "value": "{{JSV - Page Type}}"},
    {"type": "list", "key": "map", "list": [
      {"type": "map", "map": [
        {"type": "template", "key": "key", "value": "homepage"},
        {"type": "template", "key": "value", "value": "Home"}
      ]},
      {"type": "map", "map": [
        {"type": "template", "key": "key", "value": "product"},
        {"type": "template", "key": "value", "value": "Products"}
      ]},
      {"type": "map", "map": [
        {"type": "template", "key": "key", "value": "article"},
        {"type": "template", "key": "value", "value": "Blog"}
      ]}
    ]},
    {"type": "template", "key": "defaultValue", "value": "Other"}
  ]'
```

---

## Regex Table (type: `remm`)

Like Lookup Table but uses regex matching. For pattern-based classification.

### URL → Content Group (Regex)

```bash
mcporter call gtm.create_variable \
  name="RT - Content Group" \
  type="remm" \
  parameter='[
    {"type": "template", "key": "input", "value": "{{Page Path}}"},
    {"type": "list", "key": "map", "list": [
      {"type": "map", "map": [
        {"type": "template", "key": "key", "value": "^/$"},
        {"type": "template", "key": "value", "value": "Home"}
      ]},
      {"type": "map", "map": [
        {"type": "template", "key": "key", "value": "^/products/"},
        {"type": "template", "key": "value", "value": "Products"}
      ]},
      {"type": "map", "map": [
        {"type": "template", "key": "key", "value": "^/blog/"},
        {"type": "template", "key": "value", "value": "Blog"}
      ]},
      {"type": "map", "map": [
        {"type": "template", "key": "key", "value": "^/checkout"},
        {"type": "template", "key": "value", "value": "Checkout"}
      ]}
    ]},
    {"type": "template", "key": "defaultValue", "value": "Other"},
    {"type": "boolean", "key": "fullMatch", "value": "false"},
    {"type": "boolean", "key": "ignoreCase", "value": "true"}
  ]'
```

---

## First-Party Cookie (type: `k`)

Reads cookie values. Essential for Meta CAPI user data.

### Facebook Browser ID

```bash
mcporter call gtm.create_variable \
  name="1PK - _fbp" \
  type="k" \
  parameter='[
    {"type": "template", "key": "name", "value": "_fbp"}
  ]'
```

### Facebook Click ID

```bash
mcporter call gtm.create_variable \
  name="1PK - _fbc" \
  type="k" \
  parameter='[
    {"type": "template", "key": "name", "value": "_fbc"}
  ]'
```

### GA Client ID Cookie

```bash
mcporter call gtm.create_variable \
  name="1PK - _ga" \
  type="k" \
  parameter='[
    {"type": "template", "key": "name", "value": "_ga"}
  ]'
```

---

## URL Component (type: `u`)

Extracts parts of the current URL.

### Query Parameter

```bash
mcporter call gtm.create_variable \
  name="URL - utm_source" \
  type="u" \
  parameter='[
    {"type": "template", "key": "component", "value": "QUERY"},
    {"type": "template", "key": "queryKey", "value": "utm_source"},
    {"type": "boolean", "key": "stripWww", "value": "false"}
  ]'
```

### Page Path

```bash
mcporter call gtm.create_variable \
  name="URL - Page Path" \
  type="u" \
  parameter='[
    {"type": "template", "key": "component", "value": "PATH"}
  ]'
```

### Full URL

```bash
mcporter call gtm.create_variable \
  name="URL - Full URL" \
  type="u" \
  parameter='[
    {"type": "template", "key": "component", "value": "URL"}
  ]'
```

### Component Options

| Value | Returns |
|-------|---------|
| `URL` | Full URL |
| `PROTOCOL` | http or https |
| `HOST` | hostname |
| `PORT` | Port number |
| `PATH` | URL path |
| `QUERY` | Query string (use with queryKey for specific param) |
| `FRAGMENT` | Hash/fragment |

---

## Auto-Event Variable (type: `aev`)

Built-in variables for click and form triggers. These are pre-defined in GTM but may need to be enabled.

**Built-in Click Variables:**
- `{{Click Element}}` — The clicked DOM element
- `{{Click Classes}}` — CSS classes of clicked element
- `{{Click ID}}` — ID of clicked element
- `{{Click Target}}` — Target attribute of clicked link
- `{{Click URL}}` — href of clicked link
- `{{Click Text}}` — Text content of clicked element

**Built-in Form Variables:**
- `{{Form Element}}` — The form DOM element
- `{{Form Classes}}` — CSS classes of the form
- `{{Form ID}}` — ID of the form
- `{{Form Target}}` — Target attribute of the form
- `{{Form URL}}` — Action URL of the form
- `{{Form Text}}` — Submit button text

**Built-in Visibility Variables:**
- `{{Percent Visible}}` — Percentage of element in viewport
- `{{On-Screen Duration}}` — Time element has been visible

**Built-in Scroll Variables:**
- `{{Scroll Depth Threshold}}` — The threshold that was crossed
- `{{Scroll Depth Units}}` — "percent" or "pixels"
- `{{Scroll Direction}}` — "vertical" or "horizontal"

**Built-in Video Variables:**
- `{{Video Title}}` — Title of the YouTube video
- `{{Video URL}}` — URL of the video
- `{{Video Duration}}` — Total duration in seconds
- `{{Video Current Time}}` — Current playback position
- `{{Video Percent}}` — Percentage watched
- `{{Video Status}}` — start, pause, progress, complete
- `{{Video Visible}}` — Whether video is in viewport

These do NOT need to be created via the API — they are built-in. But they may need to be **enabled** in the GTM workspace (Container Settings > Built-In Variables).

---

## Variable Dependencies Map

When building a tracking implementation, create variables in this order:

```
1. Constants (no dependencies)
   └── CONST - GA4 Measurement ID
   └── CONST - GAds Conversion ID
   └── CONST - GAds Conversion Labels
   └── CONST - Meta Pixel ID
   └── CONST - sGTM Transport URL

2. Data Layer Variables (no dependencies)
   └── DLV - ecommerce.*
   └── DLV - event_id
   └── DLV - user_data.*
   └── DLV - form_id, form_name
   └── DLV - search_term

3. Cookie Variables (no dependencies)
   └── 1PK - _fbp
   └── 1PK - _fbc
   └── 1PK - _ga

4. URL Variables (no dependencies)
   └── URL - utm_source
   └── URL - gclid
   └── URL - fbclid

5. JavaScript Variables (may reference cookies/DLV)
   └── JSV - UUID Generator
   └── JSV - GA Client ID
   └── JSV - SHA256 Hash
   └── JSV - Page Type

6. Lookup/Regex Tables (reference other variables)
   └── LU - Event to GAds Label (references {{_event}})
   └── LU - Content Group (references {{JSV - Page Type}})
   └── RT - Content Group (references {{Page Path}})
```
