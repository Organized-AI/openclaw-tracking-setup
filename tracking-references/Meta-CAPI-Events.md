# Meta Conversions API (CAPI) Events

Complete specification for Meta CAPI events — standard events, parameters, user data fields, hashing requirements, and deduplication. The agent references this when configuring Meta CAPI tags in sGTM during Phase 4 (Implement).

---

## Event Deduplication (Critical)

When running Pixel (browser) + CAPI (server) simultaneously — which is the recommended setup — you MUST deduplicate events.

### Rules

- **`event_id` is REQUIRED** on every event sent from both Pixel and CAPI
- The **same `event_id`** must be sent from both browser and server for the same user action
- **Dedup window:** 48 hours
- **If event_id is missing:** Meta may double-count conversions, inflating reported numbers and breaking optimization
- **Generation method:**
  - For purchases: use `transaction_id` as event_id
  - For all other events: generate UUID v4 client-side, pass through dataLayer, forward via sGTM
- **event_name must also match** between Pixel and CAPI for dedup to work

### Implementation Pattern (sGTM)

1. Client-side: Generate `event_id` (UUID v4) and include in dataLayer push
2. GA4 web tag sends it as an event parameter to sGTM
3. sGTM Meta CAPI tag reads `event_id` from the event data and includes in CAPI request
4. Meta matches browser Pixel event + server CAPI event by event_id + event_name

---

## Standard Events

### PageView

| Field | Value |
|-------|-------|
| Event Name | `PageView` |
| Required custom_data | None |
| Recommended user_data | client_ip_address, client_user_agent, fbp, fbc |
| Notes | Fire on every page load. Lowest priority for CAPI (browser Pixel usually sufficient). |

### ViewContent

| Field | Value |
|-------|-------|
| Event Name | `ViewContent` |
| Required custom_data | None (but strongly recommended below) |
| Recommended custom_data | content_ids, content_type, content_name, value, currency |
| When to fire | Product detail page, service page, key content page |

### Search

| Field | Value |
|-------|-------|
| Event Name | `Search` |
| Required custom_data | None |
| Recommended custom_data | search_string, content_ids, content_category, value, currency |
| When to fire | Site search results page |

### AddToCart

| Field | Value |
|-------|-------|
| Event Name | `AddToCart` |
| Required custom_data | None |
| Recommended custom_data | content_ids, content_type, contents (array), value, currency |
| When to fire | Add-to-cart action |

`contents` array format:
```json
[{"id": "SKU123", "quantity": 2, "item_price": 29.99}]
```

### AddToWishlist

| Field | Value |
|-------|-------|
| Event Name | `AddToWishlist` |
| Required custom_data | None |
| Recommended custom_data | content_ids, content_name, value, currency |

### InitiateCheckout

| Field | Value |
|-------|-------|
| Event Name | `InitiateCheckout` |
| Required custom_data | None |
| Recommended custom_data | content_ids, contents, value, currency, num_items |
| When to fire | Checkout page load or checkout button click |

### AddPaymentInfo

| Field | Value |
|-------|-------|
| Event Name | `AddPaymentInfo` |
| Required custom_data | None |
| Recommended custom_data | content_ids, contents, value, currency |
| When to fire | Payment information step completed |

### Purchase

| Field | Value |
|-------|-------|
| Event Name | `Purchase` |
| **REQUIRED** custom_data | **value** (number), **currency** (ISO 4217) |
| Recommended custom_data | content_ids, contents, content_type, order_id |
| When to fire | Order confirmation page |
| Notes | value and currency are REQUIRED for Purchase. Without them, ROAS optimization will not work. |

### Lead

| Field | Value |
|-------|-------|
| Event Name | `Lead` |
| Required custom_data | None |
| Recommended custom_data | content_name, content_category, value, currency |
| When to fire | Lead form submission, contact form, quote request |

### CompleteRegistration

| Field | Value |
|-------|-------|
| Event Name | `CompleteRegistration` |
| Required custom_data | None |
| Recommended custom_data | content_name, value, currency, status |
| When to fire | Account signup completion |

### Subscribe

| Field | Value |
|-------|-------|
| Event Name | `Subscribe` |
| Required custom_data | None |
| Recommended custom_data | value, currency, predicted_ltv |
| When to fire | Paid subscription start |

### StartTrial

| Field | Value |
|-------|-------|
| Event Name | `StartTrial` |
| Required custom_data | None |
| Recommended custom_data | value, currency, predicted_ltv |
| When to fire | Free trial initiation |

### Contact

| Field | Value |
|-------|-------|
| Event Name | `Contact` |
| Required custom_data | None |
| When to fire | Phone click, email click, chat initiation |

### FindLocation

| Field | Value |
|-------|-------|
| Event Name | `FindLocation` |
| Required custom_data | None |
| When to fire | Store locator search, get directions click |

### Schedule

| Field | Value |
|-------|-------|
| Event Name | `Schedule` |
| Required custom_data | None |
| When to fire | Appointment booking completion |

### CustomizeProduct

| Field | Value |
|-------|-------|
| Event Name | `CustomizeProduct` |
| Recommended custom_data | content_ids, content_type |
| When to fire | Product customization (e.g., engraving, color picker) |

### Donate

| Field | Value |
|-------|-------|
| Event Name | `Donate` |
| Recommended custom_data | value, currency |
| When to fire | Donation completion |

### SubmitApplication

| Field | Value |
|-------|-------|
| Event Name | `SubmitApplication` |
| Required custom_data | None |
| When to fire | Job application, loan application, program application |

---

## User Data Fields

User data fields improve Event Match Quality (EMQ). Higher EMQ = better ad optimization.

### Fields That MUST Be Hashed (SHA256, lowercase, trimmed)

| Field | Key | Format Before Hashing | Example Input → Hash Input |
|-------|-----|----------------------|---------------------------|
| Email | `em` | Lowercase, trim whitespace | `John.Doe@Gmail.com` → `john.doe@gmail.com` |
| Phone | `ph` | Digits only, include country code | `+1 (555) 123-4567` → `15551234567` |
| First Name | `fn` | Lowercase, trim | `John` → `john` |
| Last Name | `ln` | Lowercase, trim | `O'Brien` → `o'brien` |
| City | `ct` | Lowercase, no spaces, no punctuation | `New York` → `newyork` |
| State | `st` | 2-letter code, lowercase | `California` → `ca` |
| Zip Code | `zp` | No spaces, use 5-digit (US) | `90210-1234` → `90210` |
| Country | `country` | 2-letter ISO code, lowercase | `United States` → `us` |
| External ID | `external_id` | Your internal user ID | As-is before hashing |
| Date of Birth | `db` | YYYYMMDD format | `1990-01-15` → `19900115` |
| Gender | `ge` | Single character | `Male` → `m`, `Female` → `f` |

### Fields That Are NOT Hashed

| Field | Key | Description |
|-------|-----|-------------|
| Client IP Address | `client_ip_address` | IPv4 or IPv6, sent as plain text |
| Client User Agent | `client_user_agent` | Browser user agent string, plain text |
| Facebook Click ID | `fbc` | From `_fbc` cookie, plain text |
| Facebook Browser ID | `fbp` | From `_fbp` cookie, plain text |

### Fields Available From sGTM (No Site Code Needed)

These are automatically available in the sGTM event data:

| Field | Source | Always Available |
|-------|--------|-----------------|
| `client_ip_address` | HTTP request header | Yes |
| `client_user_agent` | HTTP request header | Yes |
| `fbp` | `_fbp` cookie (if Cookie Keeper enabled) | Usually (requires first-party cookie) |
| `fbc` | `_fbc` cookie (set when user clicks Meta ad) | Only when user came from Meta ad |

### Fields That Require Site Code

These must be collected from the user (form fills, login) and pushed to dataLayer:

| Field | Typical Source |
|-------|---------------|
| `em` | Signup form, checkout form, login |
| `ph` | Contact form, checkout form |
| `fn`, `ln` | Checkout form, account profile |
| `external_id` | User ID from authentication system |

---

## Event Match Quality (EMQ)

### Target Score: 6.0 or higher (out of 10)

### Fields Ranked by Impact on EMQ

1. **em** (email) — Highest impact. If you can only send one field, send email.
2. **ph** (phone) — Second highest.
3. **fbc** (Facebook click ID) — Very high for users who came from Meta ads.
4. **fbp** (Facebook browser ID) — High. Available from cookie on most visits.
5. **client_ip_address** — Important baseline signal.
6. **client_user_agent** — Important baseline signal.
7. **external_id** — Useful for cross-device matching.
8. **fn**, **ln**, **ct**, **st**, **zp**, **country** — Incremental improvements.

### Minimum Viable User Data (No User PII)

If the site has no login or form data available:
- `client_ip_address` (from sGTM)
- `client_user_agent` (from sGTM)
- `fbp` (from _fbp cookie via Cookie Keeper)
- `fbc` (from _fbc cookie when available)

This typically yields EMQ of 3-5. Acceptable but not optimal.

### Optimal User Data (With Form/Login Data)

- All of the above, plus:
- `em` (from form submission or login)
- `ph` (from form, if collected)
- `external_id` (from user auth system)

This typically yields EMQ of 7-9.

---

## action_source Values

| Value | When to Use |
|-------|------------|
| `website` | Web tracking via Pixel and/or sGTM — **this is almost always what you use** |
| `app` | Mobile app events (iOS/Android SDK) |
| `email` | Email-triggered events |
| `phone_call` | Call center / phone events |
| `chat` | Chat/messaging events |
| `physical_store` | In-store POS events |
| `system_generated` | Server-generated events (e.g., recurring subscriptions) |
| `other` | None of the above |

For sGTM web tracking, **always use `website`**.

---

## GA4 Event → Meta Event Mapping

When the agent configures sGTM to forward GA4 events to Meta CAPI:

| GA4 Event | Meta Event | Notes |
|-----------|-----------|-------|
| `page_view` | `PageView` | Optional for CAPI (Pixel handles it) |
| `view_item` | `ViewContent` | Map items[0] to content_ids |
| `add_to_cart` | `AddToCart` | Map items to contents array |
| `begin_checkout` | `InitiateCheckout` | Include value, currency |
| `add_payment_info` | `AddPaymentInfo` | Include value, currency |
| `purchase` | `Purchase` | value + currency REQUIRED |
| `generate_lead` | `Lead` | Map form context to content_name |
| `sign_up` | `CompleteRegistration` | Include method as content_name |
| `search` | `Search` | Map search_term to search_string |
| `phone_click` | `Contact` | — |
| `booking_complete` | `Schedule` | — |
| `get_directions` | `FindLocation` | — |
| `trial_start` | `StartTrial` | Include predicted_ltv if known |

---

## Custom Events

For events not in Meta's standard list, use custom event names:

```
meta-ads-cli create-custom-event --pixel-id PIXEL_ID --event-name "CustomEventName"
```

Rules:
- Max 50 characters
- No spaces (use underscores or PascalCase)
- Cannot match standard event names
- Custom events cannot be used for standard optimization objectives (use standard events when possible)
