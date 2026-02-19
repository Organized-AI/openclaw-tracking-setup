# GA4 Event Taxonomy

Authoritative lookup table for choosing correct GA4 event names and parameters. The agent references this during Phase 2 (Audit) and Phase 3 (Plan) to ensure correct event selection.

---

## Naming Rules

- **snake_case only** — all lowercase, underscores between words
- **Max 40 characters** per event name
- **No spaces, no special characters** except underscores
- **No reserved prefixes:** `ga_`, `google_`, `firebase_`
- **Max 500 distinct event names** per GA4 property
- Custom events: use descriptive names like `phone_click`, `chat_open`, `booking_complete`
- Never recreate automatically collected events as custom events

---

## Automatically Collected Events (No GTM Config Needed)

These fire automatically with gtag.js / GA4 configuration tag. Do NOT create GTM tags for these:

| Event | When It Fires |
|-------|--------------|
| `page_view` | Every page load (with enhanced measurement ON) |
| `first_visit` | User's first visit to the site |
| `session_start` | Beginning of a new session |
| `user_engagement` | When app is in foreground or page is in focus for 10+ seconds |
| `scroll` | 90% scroll depth (enhanced measurement) |
| `click` | Outbound link clicks (enhanced measurement) |
| `file_download` | Links to files with common extensions (enhanced measurement) |
| `form_start` | First interaction with a form (enhanced measurement) |
| `form_submit` | Form submission (enhanced measurement) |
| `video_start` | YouTube video starts (enhanced measurement) |
| `video_progress` | YouTube video 10/25/50/75% (enhanced measurement) |
| `video_complete` | YouTube video finishes (enhanced measurement) |
| `view_search_results` | Site search with query parameter (enhanced measurement) |

**Note:** Enhanced measurement events fire automatically but with limited parameters. Create GTM tags when you need custom parameters (e.g., form_id, video_title, custom dimensions).

---

## Recommended Events by Vertical

### Ecommerce Events

| Event | When to Fire | Required Parameters | Optional Parameters |
|-------|-------------|-------------------|-------------------|
| `view_item_list` | Category/listing page load | items[] | item_list_id, item_list_name |
| `select_item` | Product click from listing | items[] | item_list_id, item_list_name |
| `view_item` | Product detail page load | items[] | value, currency |
| `add_to_cart` | Add-to-cart action | items[] | value, currency |
| `remove_from_cart` | Remove from cart action | items[] | value, currency |
| `view_cart` | Cart page load | items[] | value, currency |
| `begin_checkout` | Checkout initiated | items[] | value, currency, coupon |
| `add_shipping_info` | Shipping step complete | items[] | value, currency, shipping_tier |
| `add_payment_info` | Payment step complete | items[] | value, currency, payment_type |
| `purchase` | Order confirmed | transaction_id, items[] | value, currency, tax, shipping, coupon |
| `refund` | Order refunded | transaction_id | value, items[] (partial refund) |

**Critical:** `value` is silently dropped if `currency` is missing. Always send both together.

### Lead Generation Events

| Event | When to Fire | Required Parameters | Optional Parameters |
|-------|-------------|-------------------|-------------------|
| `generate_lead` | Form submission (contact, quote, demo) | — | value, currency |
| `sign_up` | Account creation | — | method |
| `login` | Successful login | — | method |

### Content / Media Events

| Event | When to Fire | Required Parameters | Optional Parameters |
|-------|-------------|-------------------|-------------------|
| `search` | Site search submitted | search_term | — |
| `share` | Social share button clicked | — | method, content_type, item_id |
| `select_content` | Content item clicked | — | content_type, content_id |
| `select_promotion` | Promo banner clicked | — | promotion_id, promotion_name, creative_name, creative_slot |
| `view_promotion` | Promo banner displayed | — | promotion_id, promotion_name, creative_name, creative_slot |

### Engagement Events (Custom)

These are custom events — not in GA4's recommended list but commonly needed:

| Event | When to Fire | Suggested Parameters |
|-------|-------------|---------------------|
| `phone_click` | Click on tel: link | phone_number, click_location |
| `email_click` | Click on mailto: link | email_destination, click_location |
| `cta_click` | CTA button click | cta_text, cta_id, cta_location, page_location |
| `chat_open` | Chat widget opened | chat_provider |
| `chat_message_sent` | Chat message sent | chat_provider |
| `get_directions` | Map/directions click | location_name, map_provider |
| `booking_complete` | Scheduling widget completion | booking_type, booking_value |
| `store_locator_search` | Location search | search_query, results_count |
| `outbound_click` | External link click | link_url, link_domain, link_text |
| `article_read` | Engaged reading (scroll + time combo) | article_id, article_category, read_time_seconds |
| `pdf_download` | PDF download click | file_name, file_category |
| `video_cta_click` | CTA click during/after video | video_title, cta_text |

---

## Parameter Reference

### Event-Level Parameters

| Parameter | Type | Description | Used With |
|-----------|------|-------------|-----------|
| `currency` | string | ISO 4217 code (USD, EUR, GBP) | Any event with `value` |
| `value` | number | Monetary value (e.g., 29.99) | purchase, generate_lead, add_to_cart, etc. |
| `transaction_id` | string | Unique order/transaction ID | purchase, refund |
| `coupon` | string | Coupon code applied | purchase, begin_checkout |
| `shipping` | number | Shipping cost | purchase |
| `tax` | number | Tax amount | purchase |
| `payment_type` | string | Payment method (credit_card, paypal) | add_payment_info |
| `shipping_tier` | string | Shipping tier (ground, express) | add_shipping_info |
| `search_term` | string | Search query text | search |
| `method` | string | Auth method (email, google, facebook) | sign_up, login, share |
| `content_type` | string | Type of content | share, select_content |
| `item_list_id` | string | List/collection ID | view_item_list, select_item |
| `item_list_name` | string | List/collection name | view_item_list, select_item |

### Items Array Parameters

The `items[]` array is required for all ecommerce events. Each item object can contain:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `item_id` | string | Yes | SKU or product ID |
| `item_name` | string | Yes | Product name |
| `affiliation` | string | No | Store or seller name |
| `coupon` | string | No | Item-level coupon code |
| `discount` | number | No | Discount amount |
| `index` | number | No | Position in list (0-based) |
| `item_brand` | string | No | Brand name |
| `item_category` | string | No | Primary category |
| `item_category2` | string | No | Sub-category level 2 |
| `item_category3` | string | No | Sub-category level 3 |
| `item_category4` | string | No | Sub-category level 4 |
| `item_category5` | string | No | Sub-category level 5 |
| `item_list_id` | string | No | List the item appeared in |
| `item_list_name` | string | No | Name of that list |
| `item_variant` | string | No | Variant (size, color) |
| `location_id` | string | No | Google Place ID or custom location |
| `price` | number | No | Unit price (not total) |
| `quantity` | number | No | Quantity (default 1) |

---

## Custom Dimensions and Metrics

- **Max 50 custom dimensions** per GA4 property (event-scoped)
- **Max 50 custom metrics** per GA4 property
- **Max 25 user-scoped custom dimensions**
- Custom dimension name: max 40 characters
- Custom dimension value: max 100 characters

### Commonly Registered Custom Dimensions

| Dimension Name | Scope | Parameter Name | Example Value |
|----------------|-------|---------------|---------------|
| Content Group | Event | `content_group` | "blog", "product", "landing" |
| Author | Event | `author` | "John Smith" |
| Page Type | Event | `page_type` | "category", "product", "article" |
| Logged In Status | User | `logged_in` | "true", "false" |
| User Type | User | `user_type` | "customer", "prospect", "partner" |
| CTA Location | Event | `cta_location` | "hero", "sidebar", "footer" |

---

## Business Type → Event Selection Decision Tree

```
Is it an ecommerce site with online transactions?
├── YES → Use full ecommerce event chain (view_item_list through purchase)
│   ├── Does it also have lead gen forms? → Add generate_lead, phone_click
│   └── Does it have content/blog? → Add scroll, article_read
│
├── NO → Does the site generate leads (forms, phone, chat)?
│   ├── YES → Use lead gen events (generate_lead, phone_click, cta_click, etc.)
│   │   ├── Does it have booking/scheduling? → Add booking_complete
│   │   └── Does it have multiple locations? → Add get_directions, store_locator_search
│   │
│   └── NO → Is it content/media focused?
│       ├── YES → Use content events (scroll, video_*, share, article_read)
│       │   └── Does it have newsletter signup? → Add generate_lead
│       │
│       └── NO → Is it SaaS/subscription?
│           └── YES → Use SaaS events (sign_up, login, purchase for subscription)
```

---

## Events That Should ALWAYS Be Implemented

Regardless of business type, always implement:

1. **Google Tag (config)** — fires on all pages, sets measurement ID
2. **Conversion Linker** — required for Google Ads
3. **Consent Initialization** — if any consent requirement exists
4. At least ONE primary conversion event (purchase, generate_lead, sign_up, etc.)
