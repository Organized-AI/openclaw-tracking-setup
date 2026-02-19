# Tracking Architectures — Business Type Blueprints

Pre-built tracking blueprints by business type. After the agent crawls a site (Phase 1 Discovery), it matches the business type below and uses the corresponding blueprint as the starting point for the tracking plan.

---

## How to Use This Reference

1. During Discovery (Phase 1), crawl the site and identify the business type
2. Match to the closest blueprint below
3. Cross-reference discovered page elements (forms, CTAs, videos, etc.) against the blueprint
4. Add custom events for any site-specific elements not covered by the blueprint
5. Remove any blueprint events that don't apply to this specific site

---

## Ecommerce (Standard)

**Identifies as:** Product listing pages, product detail pages, cart, checkout flow, order confirmation page.

**Site Elements to Scan For:**
- Product listing/category pages (grid/list of products)
- Product detail pages (add-to-cart button, price, variant selectors)
- Cart page or slide-out cart (quantity controls, remove buttons)
- Checkout steps (shipping form, payment form, promo code field)
- Order confirmation/thank-you page (order ID, total, items)
- Wishlist/save-for-later buttons
- Search bar and search results page
- Product review/rating sections
- Upsell/cross-sell widgets

### GA4 Events

| Event | Trigger | Key Parameters |
|-------|---------|----------------|
| `view_item_list` | Category/listing page load | items[], item_list_id, item_list_name |
| `select_item` | Product click from listing | items[], item_list_id, item_list_name |
| `view_item` | Product detail page load | items[], value, currency |
| `add_to_cart` | Add-to-cart button click | items[], value, currency |
| `remove_from_cart` | Remove item from cart | items[], value, currency |
| `view_cart` | Cart page load | items[], value, currency |
| `begin_checkout` | Checkout page load / checkout button click | items[], value, currency, coupon |
| `add_shipping_info` | Shipping step complete | items[], value, currency, shipping_tier |
| `add_payment_info` | Payment step complete | items[], value, currency, payment_type |
| `purchase` | Order confirmation page | transaction_id, value, currency, tax, shipping, items[], coupon |
| `refund` | Refund processed (server-side) | transaction_id, value, items[] |
| `search` | Site search submit | search_term |

### Google Ads Conversion Actions

| Name | Category | Count | Value | Primary |
|------|----------|-------|-------|---------|
| Purchase | `PURCHASE` | EVERY | Dynamic (transaction value) | Yes |
| Add to Cart | `ADD_TO_CART` | ONE_PER_CLICK | None | No (secondary) |
| Begin Checkout | `BEGIN_CHECKOUT` | ONE_PER_CLICK | None | No (secondary) |

### Meta Events (CAPI + Pixel)

| Event | Parameters | Dedup |
|-------|-----------|-------|
| `PageView` | — | event_id |
| `ViewContent` | content_ids, content_type, value, currency | event_id |
| `AddToCart` | content_ids, contents, value, currency | event_id |
| `InitiateCheckout` | content_ids, contents, value, currency, num_items | event_id |
| `AddPaymentInfo` | content_ids, contents, value, currency | event_id |
| `Purchase` | content_ids, contents, value, currency, order_id | event_id (use transaction_id) |

### sGTM Configuration

- GA4 Client receives all web hits
- GA4 Server Tag forwards to Google Analytics
- Google Ads Conversion Tag fires on purchase event
- Meta CAPI Tag fires on ViewContent, AddToCart, InitiateCheckout, Purchase
- Cookie Keeper enabled for _ga, _fbc, _fbp
- Custom domain: gtm.clientdomain.com

### Consent Mode

Required for EU-facing stores. Advanced mode recommended for conversion modeling.

---

## Lead Generation (Service Business)

**Identifies as:** Contact forms, quote request forms, phone numbers, service pages, no shopping cart.

**Site Elements to Scan For:**
- Contact forms (name, email, phone, message fields)
- Quote/estimate request forms
- Booking/scheduling widgets (Calendly, Acuity, HubSpot)
- Phone number links (`tel:` hrefs)
- Email links (`mailto:` hrefs)
- Chat widgets (Intercom, Drift, LiveChat, Tidio)
- CTA buttons ("Get a Quote", "Schedule a Call", "Contact Us")
- Service/pricing pages
- Case study / portfolio pages
- Blog content (scroll depth opportunities)
- Location pages with maps/directions
- Download links (brochures, whitepapers, PDFs)

### GA4 Events

| Event | Trigger | Key Parameters |
|-------|---------|----------------|
| `generate_lead` | Form submission (contact, quote) | value (estimated lead value), currency |
| `form_start` | First interaction with form field | form_id, form_name, form_destination |
| `sign_up` | Account creation (if applicable) | method |
| `phone_click` (custom) | Click on tel: link | phone_number, page_location |
| `email_click` (custom) | Click on mailto: link | email_destination, page_location |
| `cta_click` (custom) | CTA button click | cta_text, cta_location, page_location |
| `chat_open` (custom) | Chat widget opened | chat_provider |
| `file_download` | PDF/brochure download | file_name, file_extension, link_url |
| `scroll` | 90% scroll depth | percent_scrolled |
| `booking_complete` (custom) | Scheduling widget completion | booking_type |
| `get_directions` (custom) | Map/directions click | location_name |

### Google Ads Conversion Actions

| Name | Category | Count | Value | Primary |
|------|----------|-------|-------|---------|
| Lead Form Submit | `SUBMIT_LEAD_FORM` | ONE_PER_CLICK | Static (est. lead value) | Yes |
| Phone Call | `PHONE_CALL_LEAD` | ONE_PER_CLICK | Static (est. call value) | Yes |
| Booking Complete | `BOOK_APPOINTMENT` | ONE_PER_CLICK | Static | No (secondary) |
| Chat Initiated | `DEFAULT` | ONE_PER_CLICK | None | No (secondary) |

### Meta Events (CAPI + Pixel)

| Event | Parameters | Dedup |
|-------|-----------|-------|
| `PageView` | — | event_id |
| `Lead` | content_name (form name), value, currency | event_id |
| `Contact` | — | event_id |
| `Schedule` | — | event_id |
| `FindLocation` | — | event_id |

### sGTM Configuration

- GA4 Client receives all web hits
- GA4 Server Tag forwards to Google Analytics
- Google Ads Conversion Tag fires on generate_lead, phone_click
- Meta CAPI Tag fires on Lead, Contact, Schedule

---

## SaaS / Subscription

**Identifies as:** Signup/login pages, pricing page, free trial flow, dashboard/app behind auth, subscription checkout.

**Site Elements to Scan For:**
- Pricing page (plan comparison, CTA buttons per tier)
- Signup form (email, password, company fields)
- Login form
- Free trial start button/form
- Demo request form
- Feature pages with CTAs
- Onboarding/tutorial steps (if accessible)
- Upgrade/plan change buttons
- Billing/payment page
- Blog/resource center (content marketing)
- Webinar/event registration forms
- API documentation pages

### GA4 Events

| Event | Trigger | Key Parameters |
|-------|---------|----------------|
| `sign_up` | Account creation complete | method (email, google, github) |
| `login` | Successful login | method |
| `generate_lead` | Demo request form submission | value, currency |
| `begin_checkout` | Pricing page CTA click (plan selection) | items[] (plan name, price) |
| `purchase` | Subscription checkout complete | transaction_id, value, currency, items[] |
| `trial_start` (custom) | Free trial initiated | plan_name, trial_length |
| `upgrade` (custom) | Plan upgrade completed | from_plan, to_plan, value, currency |
| `feature_use` (custom) | Key feature interaction | feature_name |
| `tutorial_begin` | Onboarding started | — |
| `tutorial_complete` | Onboarding completed | — |

### Google Ads Conversion Actions

| Name | Category | Count | Value | Primary |
|------|----------|-------|-------|---------|
| Sign Up | `SIGNUP` | ONE_PER_CLICK | Static (est. signup value) | Yes (top-funnel campaigns) |
| Trial Start | `SIGNUP` | ONE_PER_CLICK | Static | No (secondary) |
| Subscription Purchase | `SUBSCRIBE_PAID` | EVERY | Dynamic (plan price) | Yes (bottom-funnel campaigns) |
| Demo Request | `SUBMIT_LEAD_FORM` | ONE_PER_CLICK | Static | No (secondary) |

### Meta Events (CAPI + Pixel)

| Event | Parameters | Dedup |
|-------|-----------|-------|
| `PageView` | — | event_id |
| `CompleteRegistration` | value, currency, status | event_id |
| `StartTrial` | value, currency, predicted_ltv | event_id |
| `Subscribe` | value, currency, predicted_ltv | event_id |
| `Lead` | content_name (demo form) | event_id |

---

## Content Publisher / Media

**Identifies as:** Article pages, blog posts, video content, newsletter signup, ad-supported revenue model.

**Site Elements to Scan For:**
- Article/blog post pages (long-form content — scroll depth)
- Video embeds (YouTube, Vimeo, HTML5 video players)
- Image galleries / slideshows
- Newsletter signup forms (inline, popup, footer)
- Social share buttons
- Comment sections
- Podcast embed players
- Download links (PDFs, infographics, resources)
- Category/tag archive pages
- Search bar
- Paywall/gated content triggers
- Ad placements (if tracking ad viewability)
- Related content / recommendation widgets

### GA4 Events

| Event | Trigger | Key Parameters |
|-------|---------|----------------|
| `page_view` | Every page load | page_title, content_group, author, publish_date (custom) |
| `scroll` | 25%, 50%, 75%, 90% depth | percent_scrolled |
| `video_start` | Video play begins | video_title, video_provider, video_url |
| `video_progress` | 25%, 50%, 75% video progress | video_title, video_percent |
| `video_complete` | Video reaches end | video_title, video_duration |
| `file_download` | PDF/resource download | file_name, file_extension |
| `generate_lead` | Newsletter signup | method (popup, inline, footer) |
| `share` | Social share button click | method (facebook, twitter, linkedin), content_type, item_id |
| `search` | Site search | search_term |
| `article_read` (custom) | Time-on-page threshold OR scroll + time combo | article_id, article_category, read_time |

### Google Ads Conversion Actions

| Name | Category | Count | Value | Primary |
|------|----------|-------|-------|---------|
| Newsletter Signup | `SUBMIT_LEAD_FORM` | ONE_PER_CLICK | Static | Yes |
| Engaged Article Read | `PAGE_VIEW` | ONE_PER_CLICK | None | No (secondary) |

### Meta Events (CAPI + Pixel)

| Event | Parameters | Dedup |
|-------|-----------|-------|
| `PageView` | content_name, content_category | event_id |
| `ViewContent` | content_ids, content_type, content_name | event_id |
| `Lead` | content_name (newsletter) | event_id |

---

## Local Business / Multi-Location

**Identifies as:** Location pages, Google Maps embeds, store hours, phone numbers prominent, service area pages.

**Site Elements to Scan For:**
- Location pages (address, hours, map embed)
- Store locator / location search
- Phone numbers (prominent, often in header/footer)
- Driving directions links (Google Maps, Apple Maps, Waze)
- Appointment/booking widgets
- Contact forms (per location or global)
- "Near me" or location-based CTAs
- Menu/service list pages (restaurants, salons)
- Online ordering buttons (restaurants)
- Review/testimonial sections
- Job application forms

### GA4 Events

| Event | Trigger | Key Parameters |
|-------|---------|----------------|
| `generate_lead` | Contact form submission | location_name, form_type |
| `phone_click` (custom) | tel: link click | phone_number, location_name |
| `get_directions` (custom) | Directions link/button click | location_name, map_provider |
| `store_locator_search` (custom) | Location search submit | search_query, results_count |
| `location_page_view` (custom) | Location page load | location_name, location_id |
| `booking_complete` (custom) | Appointment scheduled | location_name, service_type |
| `order_click` (custom) | Online ordering button click | location_name, order_platform |
| `menu_view` (custom) | Menu page view | location_name |

### Google Ads Conversion Actions

| Name | Category | Count | Value | Primary |
|------|----------|-------|-------|---------|
| Phone Call | `PHONE_CALL_LEAD` | ONE_PER_CLICK | Static | Yes |
| Contact Form | `SUBMIT_LEAD_FORM` | ONE_PER_CLICK | Static | Yes |
| Get Directions | `GET_DIRECTIONS` | ONE_PER_CLICK | None | No (secondary) |
| Booking | `BOOK_APPOINTMENT` | ONE_PER_CLICK | Static | No (secondary) |

### Meta Events (CAPI + Pixel)

| Event | Parameters | Dedup |
|-------|-----------|-------|
| `PageView` | — | event_id |
| `FindLocation` | — | event_id |
| `Contact` | — | event_id |
| `Schedule` | — | event_id |
| `Lead` | content_name (form type) | event_id |

---

## Hybrid: Ecommerce + Lead Gen

**Identifies as:** Both product pages AND contact/quote forms. Common for B2B with both self-serve and enterprise sales.

**Approach:** Combine the Ecommerce and Lead Gen blueprints. Track both funnels independently with separate conversion action groups.

- Ecommerce funnel: Full ecommerce event chain for self-serve purchases
- Lead gen funnel: Form submissions, phone calls for enterprise/custom sales
- Google Ads: Separate primary conversion actions per campaign type (Shopping campaigns use Purchase; Search campaigns targeting enterprise leads use Lead Form)
- Meta: All events from both blueprints with CAPI dedup

---

## Site Element → GTM Construct Mapping

When the agent discovers page elements during site crawl, use this table to determine what GTM constructs to create:

| Discovered Element | GTM Trigger Type | GTM Tag Type | Variables Needed |
|-------------------|-----------------|-------------|-----------------|
| Form (contact, lead, signup) | Form Submission or Custom Event (dataLayer push) | GA4 Event | Form ID, Form Name, Form Destination |
| Button / CTA | Click - All Elements (filter by CSS class/ID/text) | GA4 Event | Click Text, Click Classes, Click URL |
| Link (tel:, mailto:, external) | Click - Just Links (filter by Click URL regex) | GA4 Event | Click URL, Click Text |
| Video embed (YouTube) | YouTube Video trigger (built-in) | GA4 Event | Video Title, Video URL, Video Status, Video Percent |
| Video embed (Vimeo/HTML5) | Custom Event (requires dataLayer listener script) | GA4 Event | Custom video variables |
| Scroll content (long pages) | Scroll Depth (percentage thresholds) | GA4 Event | Scroll Depth Threshold |
| Product listing | Custom Event (dataLayer push from site code) | GA4 Event (view_item_list) | DLV - ecommerce.items |
| Product detail page | Custom Event or Page View (URL match) | GA4 Event (view_item) | DLV - ecommerce.items, value, currency |
| Add-to-cart button | Custom Event (dataLayer push) | GA4 Event (add_to_cart) | DLV - ecommerce.items, value, currency |
| Checkout flow | Custom Event (dataLayer push per step) | GA4 Event (begin_checkout, etc.) | DLV - ecommerce.* |
| Order confirmation page | Custom Event (dataLayer push) or Page View | GA4 Event (purchase) | DLV - ecommerce.*, transaction_id |
| Search bar | Custom Event (dataLayer push) or Form Submission | GA4 Event (search) | Search term variable |
| File download link | Click - Just Links (filter by file extension regex) | GA4 Event (file_download) | Click URL, file name extraction |
| Chat widget | Custom Event (listen for chat provider's JS events) | GA4 Event (chat_open) | Chat provider variable |
| Map / directions | Click - All Elements or Click - Just Links | GA4 Event (get_directions) | Click URL, location context |
| Booking widget | Custom Event (listen for widget completion callback) | GA4 Event (booking_complete) | Booking type, service variables |
| Element visibility (footer, section) | Element Visibility (CSS selector or ID) | GA4 Event | Element ID/Class |
| Timer-based engagement | Timer trigger (interval, limit, condition) | GA4 Event | Timer event name |
| SPA navigation | History Change trigger | GA4 Event (virtual page_view) | New URL, Page Title |

### Detection Patterns for Site Crawling

When scanning the site source, look for these indicators:

**DataLayer Already Exists:**
- `window.dataLayer = window.dataLayer || [];`
- `dataLayer.push({...})` calls — map these to Custom Event triggers
- Check for ecommerce data structure in pushes

**Forms:**
- `<form>` elements — note `id`, `class`, `action` attributes
- JavaScript form handlers (`.addEventListener('submit', ...)`)
- Third-party form widgets (HubSpot `hbspt.forms.create`, Typeform embeds, Gravity Forms)

**Click Targets:**
- `<a>` tags with `tel:`, `mailto:`, or external domains in `href`
- `<button>` elements with meaningful `id`, `class`, or `data-*` attributes
- Elements with `onclick` handlers

**Video:**
- YouTube iframes (`youtube.com/embed/`)
- Vimeo iframes (`player.vimeo.com/video/`)
- `<video>` HTML5 elements
- Third-party players (Wistia `wistia_embed`, JW Player)

**Ecommerce:**
- Cart icons/counters
- Price elements with structured data (`itemprop="price"`)
- "Add to Cart" buttons
- Checkout progress indicators
- Schema.org Product markup in page source
