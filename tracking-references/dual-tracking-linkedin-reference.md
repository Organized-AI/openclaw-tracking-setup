# LinkedIn Dual-Tracking Reference (BLADE Pattern)

## Architecture: Client + Server CAPI

```
Browser                    GTM Web Container             sGTM Container
┌─────────┐    dataLayer   ┌──────────────┐   HTTP      ┌──────────────┐
│  User    │──────push────→│ LI Insight   │────POST───→│ LI CAPI      │
│  Action  │               │ Tag (lintrk) │             │ Client+Tag   │
│          │               │              │             │              │
│          │               │ + event_id   │             │ + event_id   │
└─────────┘               └──────────────┘             └──────┬───────┘
                                                               │
                                                               ▼
                                                        ┌──────────────┐
                                                        │ LinkedIn     │
                                                        │ Campaign Mgr │
                                                        │ (deduplicated│
                                                        │  by event_id)│
                                                        └──────────────┘
```

## GTM Infrastructure (BLADE Example)

| Component | ID |
|-----------|-----|
| Web GTM | GTM-W9S77T7 |
| Server GTM | GTM-KJHX6KJ7 |
| Meta Pixel | 311227299268737 |
| LinkedIn Conversion Rule | 25208314 |

## Key Pattern: Data Tag → Data Client

BLADE uses the Data Tag/Client pattern for flexibility:

1. **Web GTM**: Data Tag (Custom HTML) POSTs JSON to sGTM `/data` endpoint
2. **sGTM**: Data Client receives at `/data`, parses request body
3. **sGTM Tags**: LinkedIn CAPI, Meta CAPI (Addingwell template), etc.

This decouples browser tracking from GA4 transport, allowing any event to reach sGTM.

## LinkedIn CAPI Implementation

### sGTM Tag Configuration

| Setting | Value |
|---------|-------|
| Template | LinkedIn Conversions API |
| Conversion Rule ID | {CONVERSION_RULE_ID} |
| Access Token | {LINKEDIN_ACCESS_TOKEN} |
| Event ID | From event data (for dedup) |

### LinkedIn Standard Events

| Event | Conversion Type |
|-------|------------------|
| Page View | URL visits |
| Lead | Lead form submission |
| Key Page View | High-intent page visit |
| Purchase | Transaction complete |

### Deduplication

LinkedIn uses the same pattern as Meta:
1. Client-side Insight Tag fires with event_id
2. Server-side CAPI fires with same event_id
3. LinkedIn deduplicates on matching event_id

## sGTM CAPI Templates in Use

### Addingwell Meta CAPI Template
- Used by BLADE for Meta server-side tracking
- Alternative to Stape's built-in Facebook CAPI tag
- Community template with active maintenance

### LinkedIn Conversions API Template
- Sends conversion events to LinkedIn's CAPI endpoint
- Requires LinkedIn Access Token and Conversion Rule ID
- Supports all standard conversion events

## Multi-Platform sGTM Stack

A single sGTM container handles multiple platform CAPIs:

```
sGTM Container
├── Clients
│   ├── GA4 Client (/g/collect)
│   ├── Data Client (/data)
│   └── Webhook Client (/webhook)
├── Tags
│   ├── GA4 Server Tag
│   ├── Meta CAPI Tag (Addingwell)
│   ├── LinkedIn CAPI Tag
│   ├── Google Ads Conversion Tag
│   └── CAPIG Tags (alternative to Meta CAPI)
└── Triggers
    ├── GA4 events (Client Name = GA4)
    ├── Data events (Client Name = Data Client)
    └── Webhook events (Client Name = Webhook)
```
