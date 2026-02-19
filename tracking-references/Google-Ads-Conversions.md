# Google Ads Conversion Actions

Decision rules for creating Google Ads conversion actions via google-ads-cli. Getting the category, counting type, value setting, and attribution model correct is critical — wrong settings degrade Smart Bidding performance.

---

## Conversion Action Categories

### Full Enum Reference with Usage Guidance

| Category | When to Use | Typical Count | Typical Value |
|----------|------------|---------------|---------------|
| `PURCHASE` | Completed transactions (ecommerce, subscription payments) | EVERY | Dynamic (actual transaction value) |
| `ADD_TO_CART` | Item added to shopping cart | ONE_PER_CLICK | None or static |
| `BEGIN_CHECKOUT` | Checkout process started | ONE_PER_CLICK | None or static |
| `SUBSCRIBE_PAID` | Paid subscription started | EVERY | Dynamic (subscription price) |
| `SUBMIT_LEAD_FORM` | Contact form, quote request, demo request, any lead form | ONE_PER_CLICK | Static (estimated lead value) |
| `PHONE_CALL_LEAD` | Phone call from ad or website | ONE_PER_CLICK | Static (estimated call value) |
| `SIGNUP` | Account creation, free trial start | ONE_PER_CLICK | Static or none |
| `BOOK_APPOINTMENT` | Booking, scheduling, reservation | ONE_PER_CLICK | Static |
| `REQUEST_QUOTE` | Quote or estimate request | ONE_PER_CLICK | Static |
| `GET_DIRECTIONS` | Map or directions click | ONE_PER_CLICK | None |
| `PAGE_VIEW` | Key page views (microconversion only) | ONE_PER_CLICK | None |
| `CONTACT` | Generic contact action (call, email, chat) | ONE_PER_CLICK | None |
| `ENGAGEMENT` | Site engagement metric (time on site, scroll) | ONE_PER_CLICK | None |
| `STORE_VISIT` | Physical store visit (requires location extensions) | ONE_PER_CLICK | None |
| `STORE_SALE` | In-store purchase (offline conversion import) | EVERY | Dynamic |
| `QUALIFIED_LEAD` | Lead qualified by sales team (offline import) | ONE_PER_CLICK | Static |
| `CONVERTED_LEAD` | Lead that became a customer (offline import) | ONE_PER_CLICK | Dynamic |
| `DEFAULT` | Fallback — **avoid using this** | — | — |

---

## Counting Type Rules

### ONE_PER_CLICK

**Use for:** Leads, signups, form submissions, phone calls, bookings — actions where repeated submissions from the same ad click should count as ONE conversion.

**Why:** A user who submits the same contact form 3 times from one ad click is still one lead. Counting every submission inflates your conversion numbers and confuses Smart Bidding.

**Applies to:** SUBMIT_LEAD_FORM, PHONE_CALL_LEAD, SIGNUP, BOOK_APPOINTMENT, REQUEST_QUOTE, GET_DIRECTIONS, PAGE_VIEW, CONTACT, ENGAGEMENT

### EVERY_CONVERSION

**Use for:** Purchases, subscription payments, donations — actions where each occurrence has independent value.

**Why:** A user who makes 3 purchases from one ad click represents 3 separate revenue events. Each should be counted.

**Applies to:** PURCHASE, SUBSCRIBE_PAID, STORE_SALE

---

## Value Configuration

### Dynamic Value (Transaction-Based)

```bash
google-ads-cli create-conversion-action \
  --name "Purchase" \
  --category PURCHASE \
  --type WEBPAGE \
  --value-settings '{"default_value": 0, "always_use_default": false}' \
  --counting-type EVERY_CONVERSION
```

- `always_use_default: false` — Use the value passed from the tag (GTM sends actual transaction value)
- `default_value: 0` — Fallback if no value is sent (should rarely happen)
- **Use for:** Purchase, Subscribe, Donate — anywhere actual revenue is known

### Static Value (Estimated)

```bash
google-ads-cli create-conversion-action \
  --name "Lead Form Submit" \
  --category SUBMIT_LEAD_FORM \
  --type WEBPAGE \
  --value-settings '{"default_value": 50, "always_use_default": true}' \
  --counting-type ONE_PER_CLICK
```

- `always_use_default: true` — Always use the fixed value, ignore any value from the tag
- `default_value: 50` — Estimated value per lead (calculate: close rate * average deal value)
- **Use for:** Lead forms, phone calls, signups — where individual conversion value is unknown

### No Value

```bash
google-ads-cli create-conversion-action \
  --name "Get Directions" \
  --category GET_DIRECTIONS \
  --type WEBPAGE \
  --counting-type ONE_PER_CLICK
```

- No `--value-settings` flag — conversion tracked for volume only
- **Use for:** Microconversions, engagement signals, page views

### Calculating Static Lead Values

```
Estimated Lead Value = Close Rate × Average Deal Value

Example:
- 100 leads/month, 10 close → 10% close rate
- Average deal = $5,000
- Lead Value = 0.10 × $5,000 = $500

Or for phone calls:
- 50 calls/month, 15 become customers → 30% close rate
- Average job = $2,000
- Call Value = 0.30 × $2,000 = $600
```

---

## Attribution Model

### Data-Driven Attribution (DDA) — Default and Recommended

- Uses Google's machine learning to assign credit across touchpoints
- **Always use DDA** unless the account has insufficient data (< 300 conversions and < 3,000 ad interactions in 30 days)
- DDA is now the default for all new conversion actions

```bash
google-ads-cli create-conversion-action \
  --name "Purchase" \
  --category PURCHASE \
  --type WEBPAGE \
  --attribution-model DATA_DRIVEN
```

### Last Click — Fallback

- All credit to the last-clicked ad
- Only use if DDA requirements are not met
- Google will auto-suggest upgrading to DDA when data thresholds are met

### Deprecated Models (Do NOT Use)

- First Click
- Linear
- Time Decay
- Position-Based

These are no longer available for new conversion actions.

---

## Primary vs. Secondary Conversion Actions

### Primary Actions

- **Used by Smart Bidding** (Target CPA, Target ROAS, Maximize Conversions)
- Included in the "Conversions" column in reporting
- **Rule: Only 1-3 primary actions per account**
- Too many primary actions confuses Smart Bidding (conflicting signals)

### Secondary Actions (Observation Only)

- NOT used by Smart Bidding
- Shown in "All Conversions" column only
- Use for microconversions and supplementary tracking

### Setting Primary/Secondary

```bash
# Make a conversion action secondary (observation only)
google-ads-cli update-conversion-action \
  --conversion-action-id ID \
  --primary-for-goal false

# Make a conversion action primary (used by bidding)
google-ads-cli update-conversion-action \
  --conversion-action-id ID \
  --primary-for-goal true
```

---

## Conversion Window

How long after an ad click (or view) a conversion can be attributed.

| Business Type | Click-Through Window | View-Through Window |
|--------------|---------------------|-------------------|
| Impulse / low-consideration | 7 days | 1 day |
| Standard ecommerce | 30 days (default) | 1 day |
| High-consideration (B2B, real estate, auto) | 60-90 days | 1 day |
| SaaS with long trial periods | 60-90 days | 1 day |

```bash
google-ads-cli update-conversion-action \
  --conversion-action-id ID \
  --click-through-lookback-window 30 \
  --view-through-lookback-window 1
```

---

## Business Type → Conversion Action Mapping

### Ecommerce

| Action | Category | Count | Value | Primary |
|--------|----------|-------|-------|---------|
| Purchase | PURCHASE | EVERY | Dynamic | Yes |
| Add to Cart | ADD_TO_CART | ONE_PER_CLICK | None | No |
| Begin Checkout | BEGIN_CHECKOUT | ONE_PER_CLICK | None | No |

### Lead Generation

| Action | Category | Count | Value | Primary |
|--------|----------|-------|-------|---------|
| Lead Form Submit | SUBMIT_LEAD_FORM | ONE_PER_CLICK | Static | Yes |
| Phone Call | PHONE_CALL_LEAD | ONE_PER_CLICK | Static | Yes (if calls are significant) |
| Chat Initiated | CONTACT | ONE_PER_CLICK | None | No |

### SaaS

| Action | Category | Count | Value | Primary |
|--------|----------|-------|-------|---------|
| Free Trial Start | SIGNUP | ONE_PER_CLICK | Static | Yes (top-funnel campaigns) |
| Subscription Purchase | SUBSCRIBE_PAID | EVERY | Dynamic | Yes (bottom-funnel) |
| Demo Request | SUBMIT_LEAD_FORM | ONE_PER_CLICK | Static | No |

### Local Business

| Action | Category | Count | Value | Primary |
|--------|----------|-------|-------|---------|
| Phone Call | PHONE_CALL_LEAD | ONE_PER_CLICK | Static | Yes |
| Contact Form | SUBMIT_LEAD_FORM | ONE_PER_CLICK | Static | Yes |
| Get Directions | GET_DIRECTIONS | ONE_PER_CLICK | None | No |
| Appointment Booking | BOOK_APPOINTMENT | ONE_PER_CLICK | Static | No |

### Content / Media

| Action | Category | Count | Value | Primary |
|--------|----------|-------|-------|---------|
| Newsletter Signup | SUBMIT_LEAD_FORM | ONE_PER_CLICK | Static | Yes |
| Engaged Article Read | ENGAGEMENT | ONE_PER_CLICK | None | No |

---

## Conversion Action Types

| Type | Description | When to Use |
|------|------------|------------|
| `WEBPAGE` | Tracked via website tag (GTM) | Standard web conversions |
| `UPLOAD_CLICKS` | Offline conversion import via API/upload | CRM-sourced conversions (qualified lead, closed deal) |
| `UPLOAD_CALLS` | Offline call tracking import | Call center data |
| `CLICK_TO_CALL` | Calls from call extension clicks | Call extensions on ads |
| `STORE_VISIT` | Physical store visit modeling | Brick-and-mortar with location extensions |

For this skill, always use `WEBPAGE` unless implementing offline conversion import.

---

## Budget and Safety Notes

- Budget amounts in **micros**: $50/day = 50,000,000 micros
- All campaigns created via google-ads-cli default to **PAUSED** status
- `enable-campaign` **starts real ad spend** — always get human confirmation first
- `remove-keyword` is permanent and cannot be undone
- Conversion actions can be paused (DISABLED) but not deleted
- Pausing a conversion action removes it from Smart Bidding optimization

---

## Verification Commands

After creating conversion actions, verify with:

```bash
# List all conversion actions with status
google-ads-cli list-conversion-actions

# Check for recent conversion data
google-ads-cli get-conversion-stats

# Verify specific conversion action
google-ads-cli run-query --query "SELECT conversion_action.name, conversion_action.status, conversion_action.category, conversion_action.counting_type FROM conversion_action WHERE conversion_action.status = 'ENABLED'"
```

Expected states after creation:
- Status: ENABLED
- Tag tracking status: "Unverified" (normal — will change to "Tag inactive" then "Recording conversions" as data flows)
- Recent conversions: 0 (normal for newly created actions)
