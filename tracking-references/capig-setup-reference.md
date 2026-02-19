# CAPIG (Conversions API Gateway) Setup Reference

## What is CAPIG?

Stape's Conversions API Gateway simplifies Meta CAPI implementation by handling authentication, hashing, and API communication. Instead of configuring the full Meta CAPI tag in sGTM, you send HTTP requests to CAPIG's endpoint.

## URL Structure

```
https://capig.stape.vip/{PIXEL_ID}/{EVENT_NAME}
```

Example: `https://capig.stape.vip/912613798381607/Purchase`

## Architecture

```
Browser                    GTM Web Container             sGTM Container
┌─────────┐    dataLayer   ┌──────────────┐   HTTP      ┌──────────────┐
│  User    │──────push────→│ Meta Pixel   │────POST───→│ CAPIG Tag    │
│  Action  │               │ Tag (fbq)    │             │              │
│          │               │              │             │ POST to:     │
│          │               │ + event_id   │             │ capig.stape  │
│          │               │ in dataLayer │             │ .vip/{PX}/   │
└─────────┘               └──────────────┘             │ {EVENT}      │
                                                        └──────┬───────┘
                                                               │
                                                               ▼
                                                        ┌──────────────┐
                                                        │ Meta Events  │
                                                        │ Manager      │
                                                        │ (deduplicated│
                                                        │  by event_id)│
                                                        └──────────────┘
```

## CAPIG Tags Reference

### Web Events (action_source: "website")

| Tag Name | Event | Trigger |
|----------|-------|---------|
| CAPIG - PageView | PageView | GA4 - Page View |
| CAPIG - ViewContent | ViewContent | GA4 - View Content |
| CAPIG - Lead (Web) | Lead | GA4 - Lead |
| CAPIG - CompleteRegistration | CompleteRegistration | GA4 - Assessment Complete |
| CAPIG - Purchase (Deposit) | Purchase | GA4 - Deposit |
| CAPIG - Purchase (Treatment) | Purchase | GA4 - Treatment Complete |

### Offline Events (action_source: "system_generated")

| Tag Name | Event | Trigger |
|----------|-------|---------|
| CAPIG - Lead (Qualified) | Lead | Webhook - Lead Qualified |

## Required Parameters

### Always Required
- `event_name` — Meta standard event name
- `event_time` — Unix timestamp
- `event_id` — Unique ID for deduplication
- `event_source_url` — Page URL where event occurred
- `action_source` — "website" or "system_generated"

### User Data (for Event Match Quality)
- `client_ip_address` — User's IP
- `client_user_agent` — Browser user agent
- `fbc` — Facebook click ID cookie (`_fbc`)
- `fbp` — Facebook browser ID cookie (`_fbp`)

### Enhanced Matching (optional, improves EMQ)
- `em` — Hashed email
- `ph` — Hashed phone
- `fn` — Hashed first name
- `ln` — Hashed last name
- `ct` — Hashed city
- `st` — Hashed state
- `zp` — Hashed zip code
- `country` — Hashed country code

## Deduplication

CAPIG handles deduplication automatically when `event_id` is provided:

1. Browser Pixel fires with `event_id`
2. sGTM → CAPIG fires with same `event_id`
3. Meta deduplicates within 48-hour window based on matching `event_id` + `event_name`

### Event ID Generation Pattern

```javascript
function() {
  return Date.now().toString(36) + Math.random().toString(36).substr(2, 9);
}
```

For lead-specific events:
```javascript
'lead_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9)
```

## Event Match Quality (EMQ) Scoring

| Score | Rating | Meaning |
|-------|--------|----------|
| 0-5 | Poor | Low match rate, missing key parameters |
| 6-7 | Good | Decent matching, room for improvement |
| 8-10 | Great | High confidence user matching |

### Tips to Improve EMQ
- Always pass `_fbp` cookie (most impactful)
- Capture `_fbc` from URL parameters on landing
- Include IP address and User Agent from server
- Enable cookie_keeper power-up in Stape for _fbc/_fbp persistence
- Pass hashed email/phone when available from forms

## sGTM Variables for CAPIG

### Constants
| Variable | Type | Value |
|----------|------|-------|
| Meta - Const - Pixel ID | Constant | {PIXEL_ID} |
| Meta - Const - CAPI Token | Constant | {ACCESS_TOKEN} |

### Event Data Variables
| Variable | Source |
|----------|--------|
| event_name | Event Data |
| client_id | Event Data |
| page_location | Event Data |
| event_id | Event Data |
| value | Event Data |
| currency | Event Data |

### User Data Variables
| Variable | Source |
|----------|--------|
| user_data.email_address | Event Data |
| user_data.phone_number | Event Data |
| user_data.address.first_name | Event Data |
| user_data.address.last_name | Event Data |
| ip_override | Event Data |
| user_agent | Event Data |

## Stape Power-Up: Cookie Keeper

Enable cookie_keeper for Meta to persist `_fbc` and `_fbp` cookies server-side:

```
stape_container_power_ups:
  powerUpType: cookie_keeper
  isActive: true
  cookieKeeperConfig:
    options:
      standard:
        facebook: true
```
