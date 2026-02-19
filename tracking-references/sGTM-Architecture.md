# Server-Side GTM (sGTM) Architecture

Reference for server-side GTM patterns when configuring Stape containers. Covers the data flow model, client/tag architecture, transport URL configuration, and cookie management.

---

## Data Flow

```
Browser                           Server (sGTM via Stape)              Endpoints
┌──────────────┐                 ┌──────────────────────┐            ┌──────────────┐
│ User Action  │                 │                      │            │              │
│ (click, buy) │                 │  GA4 Client          │──────────→│ Google       │
│      ↓       │                 │  (claims request)    │            │ Analytics    │
│ dataLayer    │                 │      ↓               │            │              │
│   .push()    │                 │  Event Data Object   │            ├──────────────┤
│      ↓       │   HTTPS POST   │      ↓               │            │              │
│ GA4 Web Tag  │────────────────→│  Triggers evaluate   │──────────→│ Google Ads   │
│ (transport_  │  (to custom    │      ↓               │            │ Conversions  │
│  url set)    │   domain)      │  Server Tags fire:   │            │              │
│              │                 │  • GA4 Server Tag    │            ├──────────────┤
│ Meta Pixel   │                 │  • GAds Conv. Tag    │            │              │
│ (browser)    │                 │  • Meta CAPI Tag     │──────────→│ Meta Graph   │
│              │                 │  • HTTP Request Tag  │            │ API (CAPI)   │
└──────────────┘                 └──────────────────────┘            └──────────────┘
```

### Key Concepts

1. **Web GTM** sends hits to sGTM instead of directly to Google
2. **sGTM Client** receives and parses the incoming request
3. **sGTM Triggers** evaluate the parsed event data
4. **sGTM Tags** forward data to final destinations (Google, Meta, etc.)
5. All processing happens on Stape's servers, not the user's browser

---

## Client Types

Clients in sGTM receive and parse incoming requests.

### GA4 Client (Default — Use This)

- Claims requests from gtag.js / GA4 web tags
- Parses the GA4 Measurement Protocol format
- Creates an Event Data object with standardized fields
- **This is the only client needed for most implementations**

### Universal Analytics Client

- Legacy — for sites still migrating from UA
- Claims requests from analytics.js / UA tags
- Not relevant for new implementations

### Custom Client

- For non-Google data sources (webhooks, custom APIs)
- Rarely needed for standard tracking setups

---

## Event Data Object

The canonical data structure that flows through sGTM after the Client parses the incoming request:

```json
{
  "event_name": "purchase",
  "client_id": "GA1.1.123456789.1612345678",
  "user_id": "user_123",
  "ip_override": "1.2.3.4",
  "user_agent": "Mozilla/5.0 ...",
  "page_location": "https://example.com/thank-you",
  "page_referrer": "https://example.com/checkout",
  "page_title": "Order Confirmation",

  "x-ga-measurement_id": "G-XXXXXXX",
  "x-ga-protocol_version": "2",

  "currency": "USD",
  "value": 65.32,
  "transaction_id": "T_12345",
  "tax": 3.35,
  "shipping": 5.00,
  "coupon": "SUMMER10",

  "items": [
    {
      "item_id": "SKU_001",
      "item_name": "Blue T-Shirt",
      "price": 19.99,
      "quantity": 2
    }
  ],

  "user_data": {
    "email_address": "john@example.com",
    "phone_number": "+15551234567"
  }
}
```

### How GA4 Web Tag Maps to Event Data

| GA4 Tag Parameter | Event Data Field |
|-------------------|-----------------|
| Event Name | `event_name` |
| Measurement ID | `x-ga-measurement_id` |
| Items array | `items` |
| Value | `value` |
| Currency | `currency` |
| Transaction ID | `transaction_id` |
| User ID | `user_id` |
| Client IP | `ip_override` (from request header) |
| User Agent | `user_agent` (from request header) |

---

## Transport URL Configuration

**Critical:** Without setting `transport_url` on the web GA4 tag, traffic goes directly to Google (bypassing sGTM entirely).

### In Web GTM (Google Tag config)

Set the transport URL to your custom domain:

```
transport_url: https://gtm.clientdomain.com
first_party_collection: true
```

See `GTM-Tag-Patterns.md` for the exact mcporter command.

### How It Works

1. GA4 web tag sends hits to `https://gtm.clientdomain.com` instead of `https://www.google-analytics.com`
2. The custom domain points to Stape's infrastructure (via DNS CNAME or A record)
3. Stape routes the request to your sGTM container
4. The GA4 Client in sGTM claims and parses the request
5. sGTM tags forward to final destinations

---

## Stape Container Setup

### Container Operations (via mcporter)

```bash
# Get container details
mcporter call stape.container_crud action=get identifier=CONTAINER_ID

# Update container settings
mcporter call stape.container_crud \
  action=update \
  identifier=CONTAINER_ID \
  settings='{"logging": true}'
```

### Custom Domain Setup

```bash
# Add custom domain
mcporter call stape.container_domains \
  action=create \
  containerIdentifier=CONTAINER_ID \
  domain="gtm.clientdomain.com"

# List domains
mcporter call stape.container_domains \
  action=get \
  containerIdentifier=CONTAINER_ID
```

**DNS Requirements:**
- Add a CNAME record: `gtm.clientdomain.com` → Stape-provided target
- OR add an A record pointing to Stape's IP
- SSL certificate is automatically provisioned by Stape

### Why Custom Domain Matters

| Without Custom Domain | With Custom Domain |
|----------------------|-------------------|
| Requests go to `stape.io` subdomain | Requests go to `gtm.clientdomain.com` |
| Third-party request (blockable by ad blockers) | First-party request (not blocked) |
| Cookies set as third-party (limited by ITP) | Cookies set as first-party (longer lifetime) |
| Lower data collection rate (~85%) | Higher data collection rate (~95%+) |

---

## Stape Power-Ups

### Cookie Keeper

**What it does:** Extends the lifetime of first-party cookies (_ga, _fbc, _fbp, etc.) that Safari ITP would otherwise truncate to 7 days.

```bash
# Enable Cookie Keeper
mcporter call stape.container_power_ups \
  containerIdentifier=CONTAINER_ID \
  powerUpType=cookie_keeper \
  action=enable
```

**Why it matters:**
- Safari ITP limits JavaScript-set cookies to 7 days
- _ga cookie (GA4 client ID) resets every 7 days = inflated user counts
- _fbc cookie (Meta click ID) expires = lost attribution
- _fbp cookie (Meta browser ID) expires = lower EMQ
- Cookie Keeper rewrites cookies server-side with longer expiry

### Other Power-Ups

```bash
# Enable Hostname Redirects (custom routing)
mcporter call stape.container_power_ups \
  containerIdentifier=CONTAINER_ID \
  powerUpType=hostname_redirects \
  action=enable

# Enable Data Tag (enrichment/transformation)
mcporter call stape.container_power_ups \
  containerIdentifier=CONTAINER_ID \
  powerUpType=data_tag \
  action=enable
```

---

## Server-Side Tags

### GA4 Server Tag

Forwards event data to Google Analytics. Usually auto-configured in sGTM.

- Fires on all events from the GA4 Client
- Sends to `www.google-analytics.com`
- Uses the `x-ga-measurement_id` from the event data

### Google Ads Conversion Tag (sGTM)

Forwards conversion data to Google Ads.

- Fires on specific events (purchase, lead, etc.)
- Needs: Conversion ID, Conversion Label, Value, Currency, Order ID
- These values come from the Event Data object

### Meta Conversions API Tag (sGTM)

Forwards event data to Meta's Conversions API.

Configuration required:
- **API Access Token** — Meta Graph API token (long-lived)
- **Pixel ID** — Meta Pixel ID
- **Event Name** — Maps from GA4 event to Meta event name
- **Event Data** — Maps from Event Data object to Meta's expected fields

Field mapping from Event Data to Meta CAPI:

| Event Data Field | Meta CAPI Field |
|------------------|----------------|
| `event_name` (mapped) | `event_name` (PageView, Purchase, etc.) |
| `ip_override` | `user_data.client_ip_address` |
| `user_agent` | `user_data.client_user_agent` |
| `page_location` | `event_source_url` |
| Cookie: `_fbc` | `user_data.fbc` |
| Cookie: `_fbp` | `user_data.fbp` |
| `user_data.email_address` | `user_data.em` (SHA256) |
| `user_data.phone_number` | `user_data.ph` (SHA256) |
| `value` | `custom_data.value` |
| `currency` | `custom_data.currency` |
| `transaction_id` | `custom_data.order_id` |
| `items[].item_id` | `custom_data.content_ids` |
| Custom: `event_id` | `event_id` |

### HTTP Request Tag

Generic tag for sending data to any HTTP endpoint. Used for:
- Custom analytics platforms
- Webhook endpoints
- Data warehouses
- Third-party attribution platforms

---

## When to Use sGTM vs. Client-Side Only

### Use sGTM When:

| Reason | Benefit |
|--------|---------|
| Meta CAPI is required | Server-to-server = higher EMQ, not blocked by ad blockers |
| Ad blocker resilience needed | First-party domain bypasses most ad blockers |
| Safari/ITP cookie issues | Cookie Keeper extends cookie lifetime |
| Data enrichment needed | Server-side can add data not available in browser |
| Multi-platform forwarding | One incoming hit → multiple destinations |
| Privacy compliance | Reduce client-side data exposure |
| Conversion data reliability | Server-side is more reliable than browser-based |

### Client-Side Only May Be OK When:

| Condition | Rationale |
|-----------|-----------|
| Simple GA4-only tracking | No need for server-side forwarding |
| No Meta Ads | CAPI is the primary sGTM use case |
| Very low traffic | Stape has minimum request volumes |
| No budget for Stape | sGTM hosting has a cost |
| Temporary/test setup | Not worth the infrastructure for short-term |

### Default Recommendation

**Always recommend sGTM** when the client runs both Google Ads and Meta Ads. The data quality improvement from CAPI + Cookie Keeper usually justifies the Stape cost.

---

## Monitoring sGTM Health

### Stape Analytics

```bash
# Daily request volume and error rates
mcporter call stape.container_analytics \
  identifier=CONTAINER_ID \
  period=yesterday

# Weekly overview
mcporter call stape.container_analytics \
  identifier=CONTAINER_ID \
  period=last_7_days
```

### Key Metrics to Monitor

| Metric | Healthy Range | Alert If |
|--------|--------------|----------|
| Request volume | Consistent with web traffic | Drop > 50% vs previous period |
| Error rate | < 2% | > 5% |
| Response time | < 500ms p95 | > 1000ms p95 |
| Client claim rate | > 95% | < 90% (requests not being claimed) |

### Container Logs

```bash
mcporter call stape.container_logs \
  containerIdentifier=CONTAINER_ID \
  period=last_hour
```

Check for:
- 4xx errors (usually authentication issues)
- 5xx errors (server problems)
- "Unclaimed" requests (client not matching)
- Failed tag executions

---

## Debugging sGTM

### GTM Preview Mode with sGTM

1. Enable GTM Preview for the web container
2. Enable GTM Preview for the sGTM container (separate preview)
3. Load the site — see hits in web preview, then trace them to sGTM preview
4. In sGTM preview: check Client claims, Trigger evaluations, Tag executions

### Stape Debug Mode

```bash
# Enable debug logging temporarily
mcporter call stape.container_crud \
  action=update \
  identifier=CONTAINER_ID \
  settings='{"logging": true, "logLevel": "debug"}'
```

**Remember to disable debug logging** after testing — it increases log volume and may impact performance:

```bash
mcporter call stape.container_crud \
  action=update \
  identifier=CONTAINER_ID \
  settings='{"logging": true, "logLevel": "info"}'
```
