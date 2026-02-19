# TOOLS — Tracking Setup Workspace

## Target Site

| Field | Value |
|-------|-------|
| Primary URL | {{FILL: https://example.com}} |
| Additional URLs | {{FILL: comma-separated list or "none"}} |
| Consent Required | {{FILL: yes/no — GDPR, CCPA, etc.}} |

---

## GTM (via mcporter → GTM MCP Server)

| Field | Value |
|-------|-------|
| GTM Account ID | {{FILL: e.g., 1234567}} |
| GTM Container ID | {{FILL: e.g., GTM-XXXXXXX}} |
| Container Type | {{FILL: web / server / both}} |
| mcporter Config | `mcporter-config/tracking-servers.json` |

### Available GTM MCP Operations

Via `mcporter call gtm.<operation>`:

| Operation | Description |
|-----------|-------------|
| `list_tags` | List all tags in container |
| `get_tag` | Get tag by ID |
| `create_tag` | Create a new tag |
| `update_tag` | Update existing tag |
| `delete_tag` | Delete a tag |
| `list_triggers` | List all triggers |
| `get_trigger` | Get trigger by ID |
| `create_trigger` | Create a new trigger |
| `update_trigger` | Update existing trigger |
| `delete_trigger` | Delete a trigger |
| `list_variables` | List all variables |
| `get_variable` | Get variable by ID |
| `create_variable` | Create a new variable |
| `update_variable` | Update existing variable |
| `delete_variable` | Delete a variable |
| `list_versions` | List container versions |
| `create_version` | Create a new version |
| `publish_version` | Publish a version |

---

## Stape sGTM (via mcporter → Stape MCP Server)

| Field | Value |
|-------|-------|
| Stape Container ID | {{FILL: container identifier}} |
| Custom Domain | {{FILL: e.g., gtm.clientdomain.com}} |
| Stape API Key | (stored in mcporter config) |

### Available Stape MCP Operations

Via `mcporter call stape.<operation>`:

| Operation | Description |
|-----------|-------------|
| `container_crud` | Get/update/delete server container |
| `container_domains` | Manage custom domains |
| `container_power_ups` | Enable/disable power-ups (cookie keeper, etc.) |
| `container_analytics` | View container request analytics |
| `container_logs` | View container logs |

---

## Google Ads (via google-ads-cli)

| Field | Value |
|-------|-------|
| Customer ID | {{FILL: e.g., 123-456-7890}} |
| Login Customer ID | {{FILL: MCC ID if using manager account, or same as Customer ID}} |
| google-ads-cli Path | {{FILL: path to binary or "npx google-ads-cli"}} |
| Config File | `~/.google-ads-cli/config.json` |

### google-ads-cli — Full Command Reference (35 Tools)

**Read Operations:**

| Command | Description |
|---------|-------------|
| `list-campaigns` | List all campaigns with status, budget, type |
| `get-campaign` | Get detailed campaign info by ID |
| `list-ad-groups` | List ad groups for a campaign |
| `get-ad-group` | Get detailed ad group info |
| `list-ads` | List ads in an ad group |
| `get-ad` | Get detailed ad info |
| `list-keywords` | List keywords in an ad group |
| `get-keyword` | Get keyword details and quality score |
| `list-conversion-actions` | List all conversion actions |
| `get-conversion-stats` | Get conversion statistics |
| `list-audiences` | List available audiences |
| `get-campaign-stats` | Get campaign performance metrics |
| `list-extensions` | List ad extensions |
| `get-change-history` | Get account change history |
| `run-query` | Run arbitrary GAQL query |

**Write Operations (Full Mutate Access):**

| Command | Description | Safety |
|---------|-------------|--------|
| `create-campaign` | Create new campaign | Created PAUSED by default |
| `update-campaign` | Update campaign settings | Status, budget, targeting |
| `create-ad-group` | Create new ad group | Inherits campaign status |
| `update-ad-group` | Update ad group settings | Bids, status, targeting |
| `create-ad` | Create new ad | RSA, expanded text, etc. |
| `update-ad` | Update ad content | Headlines, descriptions |
| `pause-ad` | Pause a specific ad | Safe operation |
| `create-keyword` | Add keyword to ad group | Match type, bid |
| `update-keyword` | Update keyword settings | Bid, status |
| `remove-keyword` | Remove keyword | Permanent |
| `create-conversion-action` | Create conversion action | Category, type, value |
| `update-conversion-action` | Update conversion action | Status, attribution |
| `create-extension` | Create ad extension | Sitelink, callout, etc. |
| `update-extension` | Update ad extension | Content, scheduling |
| `set-budget` | Set campaign daily budget | Amount in micros |
| `enable-campaign` | Enable a paused campaign | **Starts spending** |
| `pause-campaign` | Pause a running campaign | Safe operation |
| `create-audience` | Create custom audience | Based on intent signals |
| `apply-audience` | Apply audience to campaign | Targeting or observation |
| `create-bidding-strategy` | Create portfolio bid strategy | Target CPA, ROAS, etc. |

**Important google-ads-cli Notes:**
- Budget amounts are in **micros** (e.g., $50/day = 50,000,000 micros)
- All new campaigns default to **PAUSED** status
- `enable-campaign` will start actual ad spend — always confirm before running
- `remove-keyword` is permanent — cannot be undone
- Use `run-query` for any GAQL query not covered by specific commands

---

## Meta Ads (via meta-ads-cli)

| Field | Value |
|-------|-------|
| Ad Account ID | {{FILL: e.g., ACT_1234567890}} |
| Pixel ID | {{FILL: e.g., 1234567890}} |
| meta-ads-cli Path | {{FILL: path to binary or "npx meta-ads-cli"}} |
| Business Manager ID | {{FILL: optional, for BM-level access}} |

### meta-ads-cli — Full Command Reference

**Campaign Management:**

| Command | Description |
|---------|-------------|
| `campaigns` | List campaigns for an account |
| `create-campaign` | Create new campaign (default PAUSED) |
| `update-campaign` | Update campaign settings |
| `delete-campaign` | Delete/archive a campaign |

**Ad Set Management:**

| Command | Description |
|---------|-------------|
| `ad-sets` | List ad sets |
| `create-ad-set` | Create ad set with targeting and budget |
| `update-ad-set` | Update ad set settings |
| `delete-ad-set` | Delete/archive an ad set |

**Ad Management:**

| Command | Description |
|---------|-------------|
| `ads` | List ads |
| `create-ad` | Create ad with creative |
| `update-ad` | Update ad content/status |
| `delete-ad` | Delete/archive an ad |

**Creative Management:**

| Command | Description |
|---------|-------------|
| `creatives` | List ad creatives |
| `create-creative` | Create new creative |
| `update-creative` | Update creative content |

**Insights & Reporting:**

| Command | Description |
|---------|-------------|
| `insights` | Get performance insights |
| `breakdowns` | Get insights with breakdowns (age, gender, platform) |

**Pixel & Events:**

| Command | Description |
|---------|-------------|
| `pixels` | List pixels for account |
| `pixel-events` | Get recent pixel events |
| `pixel-stats` | Get pixel event statistics |

**Targeting Research:**

| Command | Description |
|---------|-------------|
| `targeting-search` | Search for targeting interests |
| `targeting-browse` | Browse targeting categories |
| `audience-estimate` | Estimate audience size for targeting |

**Important meta-ads-cli Notes:**
- Budget amounts are in **cents** (e.g., $50/day = 5000)
- All new campaigns default to **PAUSED** status
- Enabling a campaign will start actual ad spend — always confirm
- Use `--time-range` with insights (e.g., `last_7d`, `last_30d`, `today`, `yesterday`)
- Pixel events are critical for CAPI — always verify event_id is present

---

## mcporter Configuration

Config file location: `mcporter-config/tracking-servers.json`

To test connectivity:
```bash
# Test GTM MCP
mcporter call gtm.list_tags --output json

# Test Stape MCP
mcporter call stape.container_crud action=get identifier=CONTAINER_ID

# Test google-ads-cli
google-ads-cli list-campaigns

# Test meta-ads-cli
meta-ads-cli campaigns --account-id ACT_ID
```
