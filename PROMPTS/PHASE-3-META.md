# Phase 3: openclaw-meta — Pixel + CAPI Tracking Builder

## Claude Code Prompt

```
claude --dangerously-skip-permissions

Build out the openclaw-meta plugin in plugin-marketplace/openclaw-meta/. This plugin deploys dual-tracking: client-side Meta Pixel via GTM and server-side Conversions API via sGTM, with shared event_id deduplication.

## 1. SKILL.md — Meta Tracking Builder

Write skills/meta-tracking-builder/SKILL.md covering:

### Architecture: Dual-Tracking Pattern

```
Browser                    GTM Web Container             sGTM Container
┌─────────┐    dataLayer   ┌──────────────┐   HTTP      ┌──────────────┐
│  User    │──────push────→│ Meta Pixel   │────POST───→│ Meta CAPI    │
│  Action  │               │ Tag (fbq)    │             │ Client+Tag   │
│          │               │              │             │              │
│          │               │ + event_id   │             │ + event_id   │
│          │               │ in dataLayer │             │ for dedup    │
└─────────┘               └──────────────┘             └──────────────┘
                                                              │
                                                              │ graph.facebook.com
                                                              ▼
                                                       ┌──────────────┐
                                                       │ Meta Events  │
                                                       │ Manager      │
                                                       │ (deduplicated│
                                                       │  by event_id)│
                                                       └──────────────┘
```

### Core Capabilities

**Client-Side Pixel (via GTM MCP):**
- Deploy Meta Pixel base code tag via Custom HTML or custom template
- Create event tags for all standard events
- Generate event_id for deduplication (custom JS variable)
- Push event_id to dataLayer for sGTM forwarding
- Configure content_type, content_ids, value parameters

**Server-Side CAPI (via Stape MCP):**
- Configure sGTM container for Meta CAPI
- Deploy Meta CAPI client (receives Pixel events)
- Deploy Meta CAPI tag (sends to Meta API)
- Pass event_id from client-side for deduplication
- Enrich with server-side data (user agent, IP, hashed PII)

**Event Deduplication:**
- Generate unique event_id per event occurrence
- Pass event_id through both Pixel and CAPI paths
- Meta deduplicates based on matching event_id + event_name

### Standard Events Reference

Map these Meta standard events to GTM triggers:

| Meta Event | GTM Trigger Type | Typical Condition |
|-----------|-----------------|-------------------|
| PageView | Page View | All Pages |
| ViewContent | Click / Page View | Product page visit |
| AddToCart | Click | Add to cart button |
| InitiateCheckout | Click / Page View | Checkout page/button |
| Purchase | Page View / Custom Event | Thank you page / dataLayer purchase |
| Lead | Form Submission | Contact/signup form |
| CompleteRegistration | Page View / Custom Event | Registration complete |
| Search | Custom Event | Site search |
| AddPaymentInfo | Custom Event | Payment form step |
| Subscribe | Custom Event | Subscription action |
| Contact | Click / Form | Contact CTA |
| CustomizeProduct | Click | Product customization |
| Schedule | Click / Form | Appointment booking |
| StartTrial | Click | Free trial CTA |

### CAPI Parameters

Required server-side parameters:
- event_name (string)
- event_time (unix timestamp)
- event_id (for dedup)
- event_source_url (page URL)
- action_source ("website")
- user_data.client_ip_address
- user_data.client_user_agent
- user_data.fbc (click ID cookie)
- user_data.fbp (browser ID cookie)

Optional enhanced matching:
- user_data.em (hashed email)
- user_data.ph (hashed phone)
- user_data.fn (hashed first name)
- user_data.ln (hashed last name)
- user_data.ct (hashed city)
- user_data.st (hashed state)
- user_data.zp (hashed zip)
- user_data.country (hashed country)

### MCP Tool Usage Patterns

**Creating the Pixel Base Tag (GTM MCP):**
```
gtm_tag create:
  name: "Meta - Pixel - Base Code"
  type: "html"  (Custom HTML)
  parameter: [
    {type: "html", key: "html", value: "<script>!function(f,b,e,v,n,t,s)...fbq('init','{{PIXEL_ID}}');fbq('track','PageView');</script>"}
  ]
  firingTriggerId: [ALL_PAGES_TRIGGER_ID]
```

**Creating Event Tags:**
```
gtm_tag create:
  name: "Meta - Event - Purchase"
  type: "html"
  parameter: [
    {type: "html", key: "html", value: "<script>fbq('track','Purchase',{value:{{DL-Purchase Value}},currency:'USD',content_type:'product'},\n{eventID:'{{JS-Event ID}}'});</script>"}
  ]
  firingTriggerId: [PURCHASE_TRIGGER_ID]
```

**Event ID Variable:**
```
gtm_variable create:
  name: "JS - Event ID"
  type: "jsm"  (Custom JavaScript)
  parameter: [
    {type: "template", key: "javascript", value: "function(){return Date.now().toString(36)+Math.random().toString(36).substr(2,9)}"}
  ]
```

**sGTM CAPI Setup (Stape MCP):**
- Use stape_container_power_ups to enable cookie_keeper for Meta (_fbc, _fbp cookies)
- Configure stape_container_domains for the sGTM endpoint

### Output Artifacts
1. Pixel deployment spec (JSON) — All GTM tags/triggers/variables for client-side
2. CAPI configuration (JSON) — sGTM client + tag setup
3. Event mapping document (markdown) — Site events → Meta events with parameters
4. Deduplication verification guide — How to verify event_id matching

## 2. Reference Documents

**references/standard-events.md:**
Complete Meta standard event catalog with required and optional parameters for each event.

**references/capi-parameters.md:**
Full Conversions API parameter reference including user_data hashing requirements, custom data fields, and event-specific parameters.

**references/deduplication-guide.md:**
Step-by-step deduplication setup:
1. Generate event_id on client side
2. Include event_id in Pixel event call
3. Push event_id to dataLayer
4. Forward event_id through sGTM to CAPI
5. Verification: Check Events Manager for "Deduplicated" status

**references/naming-conventions.md:**
- Pixel tags: `Meta - Pixel - {Description}` (e.g., "Meta - Pixel - Base Code")
- Event tags: `Meta - Event - {EventName}` (e.g., "Meta - Event - Purchase")
- CAPI tags: `Meta - CAPI - {EventName}` (e.g., "Meta - CAPI - Purchase")
- Variables: `Meta - {Type} - {Name}` (e.g., "Meta - Const - Pixel ID")

## 3. Agent Definition

Write agents/meta-tracking-agent.md:

```markdown
# Meta Tracking Agent

## Identity
You are the Meta Tracking Agent — an autonomous builder that deploys dual-tracking (Pixel + CAPI) with event deduplication via GTM and sGTM.

## Session Protocol
1. Read this agent definition
2. Identify target GTM container and Pixel ID
3. Assess current Meta tracking state
4. Deploy client-side Pixel via GTM MCP
5. Configure server-side CAPI via Stape MCP
6. Verify deduplication setup

## Tools Available
- GTM MCP tools (for Pixel tags in web container)
- Stape MCP tools (for sGTM CAPI configuration)
- Pipeboard Meta MCP (optional — for Meta API queries)

## Workflow

### Audit Flow
1. List existing tags in GTM container, filter for Meta-related
2. Check for existing Pixel base code
3. Check sGTM container for CAPI configuration
4. Identify event coverage gaps
5. Generate audit report

### Deployment Flow
1. Create dedicated workspace in GTM
2. Deploy Pixel base code (Custom HTML tag)
3. Create event_id generator variable
4. Create event-specific Pixel tags
5. Create corresponding triggers
6. Configure sGTM container for CAPI
7. Set up cookie_keeper for _fbc/_fbp
8. Deploy CAPI client and tags in sGTM
9. Run pre-publish audit
10. Create version and publish

## Safety Rules
- NEVER deploy without Pixel ID confirmation
- ALWAYS create event_id for deduplication
- ALWAYS include _fbc and _fbp cookie handling
- VERIFY sGTM endpoint is accessible before deploying CAPI
- Test Mode: Deploy with consent_mode awareness
```

## 4. Commands

**commands/meta-audit.md:**
- Scan GTM container for Meta Pixel tags
- Check sGTM for CAPI configuration
- List tracked events vs standard event catalog
- Identify missing events for the business type
- Generate coverage report

**commands/meta-deploy.md:**
- Accept Pixel ID + event list + site analysis
- Deploy full Pixel + CAPI stack
- Use openclaw-gtm for GTM operations
- Configure Stape sGTM for CAPI
- Output deployment summary

**commands/meta-test-events.md:**
- Generate test event payloads
- Verify Pixel fires in GTM Preview
- Check CAPI events in Meta Events Manager
- Validate deduplication

**commands/meta-status.md:**
- Current Pixel deployment status
- CAPI connection status
- Event coverage summary
- Recent event volume (if Pipeboard Meta MCP connected)

## 5. Hooks

Write hooks/hooks.json:
```json
[
  {
    "name": "pre-deploy-validation",
    "event": "pre-deploy",
    "description": "Validate Pixel ID, event mapping, and sGTM availability",
    "script": "hooks/pre-deploy-validation.md"
  },
  {
    "name": "post-deploy-verification",
    "event": "post-deploy",
    "description": "Verify Pixel fires and CAPI events reach Meta",
    "script": "hooks/post-deploy-verification.md"
  },
  {
    "name": "event-dedup-check",
    "event": "post-deploy",
    "description": "Verify event_id deduplication is working",
    "script": "hooks/event-dedup-check.md"
  }
]
```

## 6. Templates

**templates/pixel-tag.template.json:**
```json
{
  "name": "Meta - Event - {{EVENT_NAME}}",
  "type": "html",
  "parameter": [
    {
      "type": "template",
      "key": "html",
      "value": "<script>\nfbq('track', '{{META_EVENT}}', {\n  {{EVENT_PARAMETERS}}\n}, {\n  eventID: '{{JS - Event ID}}'\n});\n</script>"
    },
    {"type": "boolean", "key": "supportDocumentWrite", "value": "false"}
  ],
  "firingTriggerId": ["{{TRIGGER_ID}}"],
  "tagFiringOption": "oncePerEvent"
}
```

**templates/capi-client.template.json:**
```json
{
  "sgtmClient": {
    "name": "Meta CAPI Client",
    "type": "meta_capi_client",
    "parameters": {
      "pixel_id": "{{PIXEL_ID}}",
      "access_token": "{{META_ACCESS_TOKEN}}"
    }
  },
  "sgtmTag": {
    "name": "Meta - CAPI - {{EVENT_NAME}}",
    "type": "meta_capi_tag",
    "parameters": {
      "event_name": "{{META_EVENT}}",
      "pixel_id": "{{PIXEL_ID}}",
      "access_token": "{{META_ACCESS_TOKEN}}",
      "action_source": "website",
      "event_id": "{{EVENT_ID_VARIABLE}}"
    }
  }
}
```

**templates/event-mapping.template.json:**
```json
{
  "events": [
    {
      "siteTrigger": "{{TRIGGER_DESCRIPTION}}",
      "metaEvent": "{{META_STANDARD_EVENT}}",
      "parameters": {},
      "pixelTag": "Meta - Event - {{EVENT_NAME}}",
      "capiTag": "Meta - CAPI - {{EVENT_NAME}}",
      "dedup": true
    }
  ]
}
```

## Verification

After building:
1. SKILL.md covers both Pixel and CAPI with dedup architecture
2. Event_id generation pattern is documented
3. All 14+ standard events are mapped
4. sGTM CAPI setup is fully specified
5. Templates produce valid GTM tag configurations
6. Agent definition includes dual-tracking workflow
```

## Environment Variables for Claude Code Web

```
STAPE_API_KEY=<your-stape-key>
META_PIXEL_ID=<your-pixel-id>
META_ACCESS_TOKEN=<your-meta-token>
```