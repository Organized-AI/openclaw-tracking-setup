# MCP API Reference

Precise parameter schemas for GTM MCP and Stape MCP operations. This reference covers the exact parameters the agent passes to `mcporter call` commands, including expected responses and error handling.

---

## GTM MCP Server

Access via: `mcporter call gtm.<operation>`

### Authentication

The GTM MCP server requires OAuth2 credentials configured in `mcporter-config/tracking-servers.json`:
- `GTM_ACCOUNT_ID` — Google Tag Manager account ID
- `GTM_OAUTH_CLIENT_ID` — OAuth2 client ID
- `GTM_OAUTH_CLIENT_SECRET` — OAuth2 client secret
- `GTM_OAUTH_REFRESH_TOKEN` — OAuth2 refresh token

All operations require a container context (account + container) which is set via the MCP server configuration.

---

### gtm.list_tags

Lists all tags in the container workspace.

```bash
mcporter call gtm.list_tags --output json
```

**Parameters:** None required (uses configured container)

**Response:** Array of tag objects:
```json
[
  {
    "tagId": "123",
    "name": "GA4 - Config - G-XXXXXXX",
    "type": "googtag",
    "firingTriggerId": ["456"],
    "parameter": [...],
    "consentSettings": {...}
  }
]
```

**Use in workflow:** Phase 2 (Audit), Phase 5 (pre-publish audit)

---

### gtm.get_tag

Gets a single tag by ID.

```bash
mcporter call gtm.get_tag tagId=TAG_ID
```

**Parameters:**
| Param | Required | Description |
|-------|----------|-------------|
| `tagId` | Yes | Tag ID (numeric string) |

**Response:** Single tag object (same structure as list item)

---

### gtm.create_tag

Creates a new tag in the workspace.

```bash
mcporter call gtm.create_tag \
  name="TAG_NAME" \
  type="TAG_TYPE" \
  parameter='[...]' \
  firingTriggerId='["TRIGGER_ID"]'
```

**Parameters:**
| Param | Required | Type | Description |
|-------|----------|------|-------------|
| `name` | Yes | string | Tag display name |
| `type` | Yes | string | Tag type identifier (see Tag Types below) |
| `parameter` | Yes | JSON array | Array of parameter objects |
| `firingTriggerId` | Yes | JSON array | Array of trigger IDs (as strings) |
| `blockingTriggerId` | No | JSON array | Array of trigger IDs that block this tag |
| `consentSettings` | No | JSON object | Consent configuration |
| `priority` | No | integer | Firing priority (higher = fires first) |

**Tag Types:**
| Type | Description |
|------|-------------|
| `googtag` | Google Tag (GA4 + Google Ads config) |
| `gaawe` | GA4 Event Tag |
| `awct` | Google Ads Conversion Tracking |
| `sp` | Google Ads Remarketing (Smart Pixel) |
| `gclidw` | Conversion Linker |
| `html` | Custom HTML |

**Response:** Created tag object with generated `tagId`

**Common Errors:**
| Error | Cause | Fix |
|-------|-------|-----|
| 400 Bad Request | Invalid parameter structure | Check JSON format, ensure all required params present |
| 403 Forbidden | Insufficient permissions | Check OAuth scope includes tagmanager.edit.containers |
| 409 Conflict | Name already exists in workspace | Use unique name or update existing tag |

See `GTM-Tag-Patterns.md` for complete examples of each tag type.

---

### gtm.update_tag

Updates an existing tag.

```bash
mcporter call gtm.update_tag \
  tagId=TAG_ID \
  name="UPDATED_NAME" \
  parameter='[...]'
```

**Parameters:** Same as create_tag, plus:
| Param | Required | Description |
|-------|----------|-------------|
| `tagId` | Yes | ID of tag to update |

Only include parameters you want to change.

---

### gtm.delete_tag

Deletes a tag from the workspace.

```bash
mcporter call gtm.delete_tag tagId=TAG_ID
```

**Warning:** Deletion is permanent within the workspace. Can be undone by reverting to a previous version (if one exists).

---

### gtm.list_triggers

Lists all triggers in the container workspace.

```bash
mcporter call gtm.list_triggers --output json
```

**Response:** Array of trigger objects:
```json
[
  {
    "triggerId": "456",
    "name": "CE - purchase",
    "type": "customEvent",
    "customEventFilter": [...],
    "filter": [...]
  }
]
```

---

### gtm.create_trigger

Creates a new trigger.

```bash
mcporter call gtm.create_trigger \
  name="TRIGGER_NAME" \
  type="TRIGGER_TYPE" \
  customEventFilter='[...]'
```

**Parameters:**
| Param | Required | Type | Description |
|-------|----------|------|-------------|
| `name` | Yes | string | Trigger display name |
| `type` | Yes | string | Trigger type identifier (see below) |
| `filter` | No | JSON array | Page-level filter conditions |
| `customEventFilter` | No | JSON array | Custom event matching conditions |
| `autoEventFilter` | No | JSON array | Click/form/visibility filter conditions |
| `parameter` | No | JSON array | Type-specific parameters (scroll, video, timer, visibility) |

**Trigger Types:**
| Type | Description | Uses |
|------|-------------|------|
| `pageview` | Page View | `filter` |
| `domReady` | DOM Ready | `filter` |
| `windowLoaded` | Window Loaded | `filter` |
| `customEvent` | Custom Event (dataLayer) | `customEventFilter` |
| `click` | Click - All Elements | `autoEventFilter` |
| `linkClick` | Click - Just Links | `autoEventFilter` |
| `formSubmission` | Form Submission | `autoEventFilter`, `filter` |
| `elementVisibility` | Element Visibility | `parameter` |
| `scrollDepth` | Scroll Depth | `parameter` |
| `youTubeVideo` | YouTube Video | `parameter` |
| `timer` | Timer | `parameter` |
| `historyChange` | History Change (SPA) | `filter` |
| `initialization` | Initialization (fires first) | — |

**Response:** Created trigger object with generated `triggerId`

See `GTM-Trigger-Patterns.md` for complete examples of each type.

---

### gtm.update_trigger

Updates an existing trigger.

```bash
mcporter call gtm.update_trigger \
  triggerId=TRIGGER_ID \
  name="UPDATED_NAME" \
  filter='[...]'
```

---

### gtm.delete_trigger

Deletes a trigger. Will fail if any tags reference this trigger.

```bash
mcporter call gtm.delete_trigger triggerId=TRIGGER_ID
```

**Error:** "Trigger is in use" — remove tag references first.

---

### gtm.list_variables

Lists all variables in the container workspace.

```bash
mcporter call gtm.list_variables --output json
```

**Response:** Array of variable objects:
```json
[
  {
    "variableId": "789",
    "name": "DLV - ecommerce.transaction_id",
    "type": "v",
    "parameter": [...]
  }
]
```

---

### gtm.create_variable

Creates a new variable.

```bash
mcporter call gtm.create_variable \
  name="VARIABLE_NAME" \
  type="VARIABLE_TYPE" \
  parameter='[...]'
```

**Parameters:**
| Param | Required | Type | Description |
|-------|----------|------|-------------|
| `name` | Yes | string | Variable display name |
| `type` | Yes | string | Variable type identifier (see below) |
| `parameter` | Yes | JSON array | Type-specific parameter configuration |

**Variable Types:**
| Type | Description |
|------|-------------|
| `v` | Data Layer Variable |
| `c` | Constant |
| `jsm` | Custom JavaScript |
| `smm` | Lookup Table |
| `remm` | Regex Table |
| `k` | First-Party Cookie |
| `u` | URL Component |
| `aev` | Auto-Event Variable |
| `d` | DOM Element |
| `j` | JavaScript Variable (global) |
| `f` | HTTP Referrer |

**Response:** Created variable object with generated `variableId`

See `GTM-Variable-Patterns.md` for complete examples of each type.

---

### gtm.update_variable

```bash
mcporter call gtm.update_variable \
  variableId=VARIABLE_ID \
  name="UPDATED_NAME" \
  parameter='[...]'
```

---

### gtm.delete_variable

```bash
mcporter call gtm.delete_variable variableId=VARIABLE_ID
```

**Warning:** Will NOT error if tags/triggers reference this variable — they'll break silently. Always check for references before deleting.

---

### gtm.list_versions

Lists all container versions.

```bash
mcporter call gtm.list_versions
```

**Response:** Array of version objects:
```json
[
  {
    "containerVersionId": "10",
    "name": "Tracking Setup - 2025-01-15",
    "description": "Initial tracking implementation",
    "fingerprint": "abc123"
  }
]
```

---

### gtm.create_version

Creates a new container version from the current workspace.

```bash
mcporter call gtm.create_version \
  name="Tracking Setup - YYYY-MM-DD" \
  description="Description of changes"
```

**Parameters:**
| Param | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Version name |
| `description` | No | Version description |

**Response:** Version object with `containerVersionId`

**Important:** Creating a version snapshots the ENTIRE workspace. All tags, triggers, and variables are included.

---

### gtm.publish_version

Publishes a container version, making it live.

```bash
mcporter call gtm.publish_version versionId=VERSION_ID
```

**Parameters:**
| Param | Required | Description |
|-------|----------|-------------|
| `versionId` | Yes | The containerVersionId to publish |

**Response:** Published version confirmation

**CRITICAL SAFETY CHECK:** Always run the pre-publish audit (list all tags, verify in preview mode) before publishing. Publishing is immediate and affects all site visitors.

**Common Errors:**
| Error | Cause | Fix |
|-------|-------|-----|
| 409 Conflict | Another version was published since creating this one | Create a new version and publish that one |
| 403 Forbidden | Insufficient permissions | Need tagmanager.publish scope |

---

## Stape MCP Server

Access via: `mcporter call stape.<operation>`

### Authentication

The Stape MCP server requires an API key configured in `mcporter-config/tracking-servers.json`:
- `STAPE_API_KEY` — Stape account API key

---

### stape.container_crud

Get, update, or delete a server-side GTM container.

```bash
# Get container info
mcporter call stape.container_crud \
  action=get \
  identifier=CONTAINER_ID

# Update container settings
mcporter call stape.container_crud \
  action=update \
  identifier=CONTAINER_ID \
  settings='{"logging": true, "logLevel": "info"}'

# Delete container
mcporter call stape.container_crud \
  action=delete \
  identifier=CONTAINER_ID
```

**Parameters:**
| Param | Required | Description |
|-------|----------|-------------|
| `action` | Yes | `get`, `update`, or `delete` |
| `identifier` | Yes | Container identifier (from Stape dashboard) |
| `settings` | For update | JSON object with settings to change |

**Settings Object:**
```json
{
  "logging": true,
  "logLevel": "info",
  "region": "us-east",
  "customGtmServerUrl": "https://gtm.clientdomain.com"
}
```

**Log Levels:** `debug`, `info`, `warn`, `error`

---

### stape.container_domains

Manage custom domains for a container.

```bash
# List domains
mcporter call stape.container_domains \
  action=get \
  containerIdentifier=CONTAINER_ID

# Add domain
mcporter call stape.container_domains \
  action=create \
  containerIdentifier=CONTAINER_ID \
  domain="gtm.clientdomain.com"

# Remove domain
mcporter call stape.container_domains \
  action=delete \
  containerIdentifier=CONTAINER_ID \
  domain="gtm.clientdomain.com"
```

**Parameters:**
| Param | Required | Description |
|-------|----------|-------------|
| `action` | Yes | `get`, `create`, or `delete` |
| `containerIdentifier` | Yes | Container ID |
| `domain` | For create/delete | Domain name to add or remove |

**After adding a domain:** DNS must be configured (CNAME or A record) before the domain will work. SSL is auto-provisioned after DNS propagates.

---

### stape.container_power_ups

Enable or disable container power-ups.

```bash
# Enable Cookie Keeper
mcporter call stape.container_power_ups \
  containerIdentifier=CONTAINER_ID \
  powerUpType=cookie_keeper \
  action=enable

# Disable Cookie Keeper
mcporter call stape.container_power_ups \
  containerIdentifier=CONTAINER_ID \
  powerUpType=cookie_keeper \
  action=disable

# Get power-up status
mcporter call stape.container_power_ups \
  containerIdentifier=CONTAINER_ID \
  powerUpType=cookie_keeper \
  action=status
```

**Parameters:**
| Param | Required | Description |
|-------|----------|-------------|
| `containerIdentifier` | Yes | Container ID |
| `powerUpType` | Yes | Power-up identifier (see below) |
| `action` | Yes | `enable`, `disable`, or `status` |

**Power-Up Types:**
| Type | Description |
|------|-------------|
| `cookie_keeper` | Extends first-party cookie lifetime (ITP workaround) |
| `hostname_redirects` | Custom hostname routing rules |
| `data_tag` | Server-side data enrichment and transformation |
| `custom_loader` | Custom gtm.js loader |
| `global_privacy_control` | GPC signal detection |

---

### stape.container_analytics

View container request analytics.

```bash
mcporter call stape.container_analytics \
  identifier=CONTAINER_ID \
  period=last_7_days
```

**Parameters:**
| Param | Required | Description |
|-------|----------|-------------|
| `identifier` | Yes | Container ID |
| `period` | Yes | Time period for analytics |

**Period Options:**
| Period | Description |
|--------|-------------|
| `today` | Current day |
| `yesterday` | Previous day |
| `last_7_days` | Last 7 days |
| `last_30_days` | Last 30 days |
| `last_hour` | Last 60 minutes |

**Response:**
```json
{
  "totalRequests": 15420,
  "successfulRequests": 15200,
  "failedRequests": 220,
  "errorRate": 1.4,
  "avgResponseTime": 245,
  "p95ResponseTime": 480,
  "requestsByTag": {
    "GA4 Server Tag": 15420,
    "Meta CAPI Tag": 8200,
    "GAds Conversion Tag": 320
  }
}
```

---

### stape.container_logs

View container execution logs.

```bash
mcporter call stape.container_logs \
  containerIdentifier=CONTAINER_ID \
  period=last_hour
```

**Parameters:**
| Param | Required | Description |
|-------|----------|-------------|
| `containerIdentifier` | Yes | Container ID |
| `period` | No | Time period (default: last_hour) |
| `level` | No | Log level filter: `debug`, `info`, `warn`, `error` |

**Response:** Array of log entries:
```json
[
  {
    "timestamp": "2025-01-15T10:30:00Z",
    "level": "info",
    "message": "Tag fired: GA4 Server Tag",
    "tagName": "GA4 Server Tag",
    "eventName": "purchase",
    "statusCode": 200
  },
  {
    "timestamp": "2025-01-15T10:30:01Z",
    "level": "error",
    "message": "Tag failed: Meta CAPI Tag - 401 Unauthorized",
    "tagName": "Meta CAPI Tag",
    "eventName": "purchase",
    "statusCode": 401
  }
]
```

---

## Error Handling

### Common Error Codes

| Code | Meaning | Typical Cause | Resolution |
|------|---------|---------------|------------|
| 400 | Bad Request | Malformed JSON, missing required params | Check parameter structure |
| 401 | Unauthorized | Invalid or expired credentials | Refresh OAuth token / check API key |
| 403 | Forbidden | Insufficient permissions/scope | Check OAuth scopes or API key permissions |
| 404 | Not Found | Wrong container/tag/trigger/variable ID | Verify the ID exists |
| 409 | Conflict | Name collision or version conflict | Use different name or create fresh version |
| 429 | Rate Limited | Too many requests | Wait and retry with exponential backoff |
| 500 | Server Error | MCP server issue | Retry; check MCP server logs |

### Retry Strategy

For transient errors (429, 500):
1. Wait 1 second
2. Retry
3. If fail: wait 3 seconds, retry
4. If fail: wait 10 seconds, retry
5. If fail: log error and alert human

For auth errors (401, 403):
- Do NOT retry — requires credential fix
- Log error and present to human for resolution

### Verifying MCP Connectivity

Before starting any workflow phase, verify connectivity:

```bash
# Test GTM MCP
mcporter call gtm.list_tags --output json
# Expected: Array of tags (may be empty for new container)

# Test Stape MCP
mcporter call stape.container_crud action=get identifier=CONTAINER_ID
# Expected: Container info object

# Test google-ads-cli
google-ads-cli list-campaigns
# Expected: Campaign list (may be empty)

# Test meta-ads-cli
meta-ads-cli campaigns --account-id ACT_ID
# Expected: Campaign list (may be empty)
```

If any command fails, do NOT proceed. Diagnose the auth/connectivity issue first.
