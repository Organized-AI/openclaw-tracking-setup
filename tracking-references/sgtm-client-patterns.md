# sGTM Client Architecture Patterns

## Overview

Server-side GTM containers use **clients** to receive incoming requests and **tags** to send data to destinations. This reference covers the three-client pattern used in production tracking setups.

## Three-Client Pattern

```
Web GTM Container                    sGTM Container
┌─────────────────┐                  ┌─────────────────────────────────────┐
│                  │   /g/collect     │  ┌─────────────┐                   │
│  GA4 Config Tag  │────────────────→│  │ GA4 Client  │→ GA4 Server Tag   │
│                  │                  │  └─────────────┘  Meta CAPI Tag    │
│                  │                  │                   Google Ads Tag    │
│  Data Tag        │   /data          │  ┌─────────────┐                   │
│  (Custom HTML)   │────────────────→│  │ Data Client │→ (Testing only)   │
│                  │                  │  └─────────────┘                   │
└─────────────────┘                  │                                     │
                                      │                                     │
External CRM (GHL)                   │  ┌───────────────┐                 │
┌─────────────────┐   /webhook       │  │ Webhook Client│→ Offline Conv   │
│  Pipeline Stage  │────────────────→│  └───────────────┘  Tags           │
│  Change          │                  │                                     │
└─────────────────┘                  └─────────────────────────────────────┘
```

## Client 1: GA4 Client (Production)

**Purpose**: Receives standard GA4 measurement protocol requests from browser

| Setting | Value |
|---------|-------|
| Path | `/g/collect` (default) |
| Type | GA4 Client (built-in) |
| Mode | Production |

**What it receives**: All GA4 events pushed via `gtag()` or `dataLayer.push()` in the web container, forwarded by the GA4 Configuration tag's server container URL setting.

**Downstream tags**: GA4 Server, Meta CAPI/CAPIG, Google Ads Conversion, LinkedIn CAPI

## Client 2: Webhook Client (Production)

**Purpose**: Receives HTTP POST webhooks from external systems (CRM, marketing automation)

| Setting | Value |
|---------|-------|
| Path | `/webhook` |
| Type | Custom or Webhook Client template |
| Method | POST |
| Mode | Production |

**Use cases**:
- GoHighLevel pipeline stage changes (lead qualified, purchase, etc.)
- Offline conversion tracking
- CRM event ingestion

**Downstream tags**: Meta CAPI with `action_source: "system_generated"`, Google Ads offline conversions

### GHL Webhook Payload Structure

```json
{
  "event_name": "lead_qualified",
  "event_time": 1739580000,
  "event_id": "ghl_lead_1739580000_abc123",
  "action_source": "system_generated",
  "event_source_url": "https://example.com",
  "user_data": {
    "em": "hashed_email",
    "ph": "hashed_phone",
    "fn": "hashed_first_name",
    "ln": "hashed_last_name",
    "ct": "hashed_city",
    "st": "hashed_state",
    "zp": "hashed_zip",
    "country": "hashed_country"
  },
  "custom_data": {
    "value": 37500,
    "currency": "USD",
    "content_name": "Gene Therapy Lead"
  }
}
```

## Client 3: Data Client (Testing)

**Purpose**: Receives all dataLayer events from web GTM for testing/debugging sGTM tags without depending on GA4 transport.

| Setting | Value |
|---------|-------|
| Path | `/data` |
| Type | Stape Data Client template |
| Source | `https://github.com/gtm-server/data-client` |
| Mode | Testing (can disable in production) |

### Web-Side: Data Tag Configuration

The Data Tag in web GTM sends events to the Data Client:

| Setting | Value |
|---------|-------|
| Event Name | `{{Event}}` |
| GTM Server Side URL | `https://sst.example.com` |
| Send all from DataLayer | ✅ Enabled |
| Include common event data | ✅ Enabled |

**Two implementation options for the Data Tag**:

**Option A: Stape Data Tag Template** (recommended)
- Install from Stape gallery in web GTM
- Configure with sGTM URL and event settings
- Fires on All Events trigger

**Option B: Custom HTML with fetch + keepalive**
```javascript
<script>
(function() {
  var data = {
    event_name: {{Event}},
    // ... all dataLayer variables
  };
  fetch('https://sst.example.com/data', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(data),
    keepalive: true
  });
})();
</script>
```

### Data Client Template Options

| Option | Default | Description |
|--------|---------|-------------|
| exposeFPIDCookie | false | Expose first-party ID cookie |
| httpOnlyCookie | false | Make cookies HTTP-only |
| generateClientId | true | Auto-generate client_id |
| prolongCookies | true | Extend cookie lifetime on visits |
| acceptMultipleEvents | false | Accept batch events |

### Response Settings
- Status codes: 200, 201, 301, 302, 403, 404
- Body options: timestamp JSON (recommended), event data, empty

## Trigger Conditions: Avoiding Duplicate Fires

When multiple clients are active, use **Client Name** conditions on triggers:

```
Trigger: GA4 - Page View
  Condition: Client Name equals "GA4"
  AND Event Name equals "page_view"

Trigger: Data - Page View
  Condition: Client Name equals "Data Client"
  AND Event Name equals "page_view"
```

This prevents the same tag from firing twice when both GA4 Client and Data Client receive the same event.

## DNS Setup for sGTM

| Record Type | Name | Value |
|-------------|------|-------|
| CNAME | sst | {container-id}.{region}.stape.io |

Example: `sst.teleios.health` → `xoxfuunr.usa.stape.io`

## Preview Mode Testing Workflow

1. Open **web GTM Preview** mode (Tag Assistant)
2. Open **sGTM Preview** mode in a separate tab
3. Navigate to the website — both previews capture events
4. In web GTM Preview: verify Data Tag fires and sends to sGTM
5. In sGTM Preview: verify Data Client claims the request, downstream tags fire
6. Note: Preview mode doesn't actually send data to Meta/Google — this is expected

## Production Deployment Notes

- Data Client/Tag can remain enabled for ongoing debugging
- Alternatively, disable Data Tag after testing, keep Data Client for future use
- GA4 Client + Webhook Client handle all production traffic
- Always publish both web GTM and sGTM containers together
