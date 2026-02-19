# Google Ads CLI Tools

Infrastructure scripts for deploying, configuring, and verifying Google Ads API access on the Mac Mini (via Tailscale SSH).

## Scripts

| Script | Purpose |
|--------|---------|
| `deploy-google-ads-credentials.sh` | Deploy API credentials to Mac Mini via SSH |
| `deploy-google-ads-tools-md.sh` | Deploy TOOLS.md (fixes agent refusing write tools) |
| `diagnose-google-ads.sh` | Diagnostic scan of credential locations and env vars |
| `fix-google-ads-credentials.sh` | Interactive credential setup wizard |
| `generate-google-ads-refresh-token.sh` | Generate OAuth refresh token (CLI flow) |
| `generate-google-ads-token-web.sh` | Generate OAuth refresh token (web server flow) |
| `monitor-google-ads-cli.sh` | Health monitor with Telegram/email/desktop alerts |
| `setup-google-ads-on-macmini.sh` | Full Mac Mini credential setup (run ON the Mac Mini) |
| `verify-google-ads-deployment.sh` | 4-layer verification of all 35 tools |
| `verify-tool-deployment.sh` | Generic tool verifier (reusable for any MCP CLI) |
| `oauth-server.py` | Python OAuth callback server for token generation |

## Config

| File | Purpose |
|------|---------|
| `config/exec-approvals.json` | Exec-approvals for 35 tools (24 read + 11 write) |

## Environment Variables

```bash
export GOOGLE_ADS_DEVELOPER_TOKEN="your-dev-token"
export GOOGLE_ADS_CLIENT_ID="your-oauth-client-id"
export GOOGLE_ADS_CLIENT_SECRET="your-oauth-client-secret"
export GOOGLE_ADS_REFRESH_TOKEN="your-refresh-token"
export GOOGLE_ADS_LOGIN_CUSTOMER_ID="your-login-cid"
```

## Mac Mini Target

- **IP**: `100.66.145.48` (Tailscale)
- **User**: `openclaw`
- **Credential paths**: `~/.google-ads-cli/config.json`, `~/.google-ads/google-ads.yaml`

## Verification Layers

The deployment verifier tests 4 layers:

1. **Infrastructure** — Binary exists, PATH configured, credentials present
2. **Read Tools** — All 24 read operations return data from the API
3. **Write Tools** — All 11 write operations recognized (optional live test)
4. **Agent Integration** — TOOLS.md parity, authorization statement, gateway running

## Tool Inventory (35 total)

**Read (24)**: list-campaigns, get-campaign, list-ad-groups, get-ad-group, list-ads, get-ad-performance, list-keywords, get-keyword-performance, get-account-performance, get-campaign-performance, get-ad-group-performance, get-search-terms-report, list-accessible-customers, get-account-hierarchy, get-account-info, list-manager-accounts, get-top-bottom-keywords, get-keyword-opportunities, get-campaign-comparison, list-conversion-actions, get-conversion-stats, get-product-performance, get-product-partition-performance, get-top-bottom-products

**Write (11)**: create-campaign, update-campaign, create-ad-group, update-ad-group, create-responsive-search-ad, update-ad, add-keywords, add-negative-keywords, update-keyword, create-conversion-action, update-conversion-action
