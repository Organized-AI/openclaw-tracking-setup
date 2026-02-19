#!/usr/bin/env bash
set -euo pipefail

# Deploy Google Ads API credentials to Mac Mini via Tailscale SSH
#
# This script:
# 1. Tests SSH connectivity to the Mac Mini
# 2. Creates JSON config for google-ads-cli
# 3. Creates YAML config for standard google-ads-python library
# 4. Copies both to the Mac Mini
# 5. Tests the CLI connection
#
# Prerequisites:
#   - Tailscale running on both machines
#   - SSH key configured for openclaw@100.66.145.48
#   - Environment variables set (see below)

MAC_MINI_IP="${DEPLOY_IP:-100.66.145.48}"
MAC_MINI_USER="${DEPLOY_USER:-openclaw}"

# Required environment variables
DEV_TOKEN="${GOOGLE_ADS_DEVELOPER_TOKEN:?Set GOOGLE_ADS_DEVELOPER_TOKEN}"
CLIENT_ID="${GOOGLE_ADS_CLIENT_ID:?Set GOOGLE_ADS_CLIENT_ID}"
CLIENT_SECRET="${GOOGLE_ADS_CLIENT_SECRET:?Set GOOGLE_ADS_CLIENT_SECRET}"
REFRESH_TOKEN="${GOOGLE_ADS_REFRESH_TOKEN:?Set GOOGLE_ADS_REFRESH_TOKEN}"
LOGIN_CID="${GOOGLE_ADS_LOGIN_CUSTOMER_ID:-4761832056}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Deploy Google Ads Credentials to Mac Mini ==="
echo "Target: ${MAC_MINI_USER}@${MAC_MINI_IP}"
echo ""

# 1. Test connectivity
echo -e "${YELLOW}[1/5] Testing connectivity...${NC}"
if ! ping -c 2 "$MAC_MINI_IP" > /dev/null 2>&1; then
  echo -e "${RED}Cannot reach $MAC_MINI_IP — is Tailscale running?${NC}"
  exit 1
fi

if ! ssh "${MAC_MINI_USER}@${MAC_MINI_IP}" "echo ok" > /dev/null 2>&1; then
  echo -e "${RED}SSH failed to ${MAC_MINI_USER}@${MAC_MINI_IP}${NC}"
  exit 1
fi
echo -e "${GREEN}  Connected${NC}"

# 2. Create JSON config (for google-ads-cli)
echo -e "${YELLOW}[2/5] Creating JSON config...${NC}"
JSON_CONFIG=$(cat <<EOF
{
  "developer_token": "$DEV_TOKEN",
  "client_id": "$CLIENT_ID",
  "client_secret": "$CLIENT_SECRET",
  "refresh_token": "$REFRESH_TOKEN",
  "login_customer_id": "$LOGIN_CID"
}
EOF
)
echo -e "${GREEN}  JSON config ready${NC}"

# 3. Create YAML config (for google-ads-python library)
echo -e "${YELLOW}[3/5] Creating YAML config...${NC}"
YAML_CONFIG=$(cat <<EOF
# Google Ads API Configuration
# Deployed: $(date)

developer_token: $DEV_TOKEN
client_id: $CLIENT_ID
client_secret: $CLIENT_SECRET
refresh_token: $REFRESH_TOKEN
login_customer_id: $LOGIN_CID
EOF
)
echo -e "${GREEN}  YAML config ready${NC}"

# 4. Deploy to Mac Mini
echo -e "${YELLOW}[4/5] Deploying to Mac Mini...${NC}"

ssh "${MAC_MINI_USER}@${MAC_MINI_IP}" bash <<REMOTE
  set -euo pipefail
  mkdir -p ~/.google-ads-cli ~/.google-ads
  chmod 700 ~/.google-ads-cli ~/.google-ads

  # Backup existing configs
  [ -f ~/.google-ads-cli/config.json ] && cp ~/.google-ads-cli/config.json ~/.google-ads-cli/config.json.backup.\$(date +%Y%m%d_%H%M%S) || true
  [ -f ~/.google-ads/google-ads.yaml ] && cp ~/.google-ads/google-ads.yaml ~/.google-ads/google-ads.yaml.backup.\$(date +%Y%m%d_%H%M%S) || true

  # Write new configs
  cat > ~/.google-ads-cli/config.json <<'JSONEOF'
$JSON_CONFIG
JSONEOF
  chmod 600 ~/.google-ads-cli/config.json

  cat > ~/.google-ads/google-ads.yaml <<'YAMLEOF'
$YAML_CONFIG
YAMLEOF
  chmod 600 ~/.google-ads/google-ads.yaml

  echo "Credentials deployed successfully"
REMOTE

echo -e "${GREEN}  Deployed to Mac Mini${NC}"

# 5. Test the CLI
echo -e "${YELLOW}[5/5] Testing Google Ads CLI...${NC}"
if ssh "${MAC_MINI_USER}@${MAC_MINI_IP}" "command -v google-ads-cli" > /dev/null 2>&1; then
  if ssh "${MAC_MINI_USER}@${MAC_MINI_IP}" "google-ads-cli list-accessible-customers" > /dev/null 2>&1; then
    echo -e "${GREEN}  CLI test passed${NC}"
  else
    echo -e "${YELLOW}  CLI installed but API test failed — check credentials${NC}"
  fi
else
  echo -e "${YELLOW}  google-ads-cli not in PATH — credentials installed but CLI needs setup${NC}"
fi

echo ""
echo -e "${GREEN}=== Deployment Complete ===${NC}"
echo "Credentials installed at:"
echo "  ~/.google-ads-cli/config.json (for CLI)"
echo "  ~/.google-ads/google-ads.yaml (for Python library)"
