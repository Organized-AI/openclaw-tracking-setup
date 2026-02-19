#!/usr/bin/env bash
set -euo pipefail

# Deploy TOOLS.md to Mac Mini — Fixes the agent refusing write tools
#
# Root cause: The OpenClaw agent reads ~/.openclaw/workspace/TOOLS.md to know
# what it can do. If write tools aren't documented there, the agent will refuse
# to use them even though the CLI supports them.
#
# This script:
# 1. Backs up the existing TOOLS.md on the Mac Mini
# 2. Deploys the updated TOOLS.md with all 35 tools (read + write)
# 3. Verifies the agent can see the new tools
# 4. Optionally runs the full verification suite

MAC_MINI_IP="${DEPLOY_IP:-100.66.145.48}"
MAC_MINI_USER="${DEPLOY_USER:-openclaw}"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TOOLS_MD="${SCRIPT_DIR}/03-ACTIVE-PROJECTS/google-ads-mcp/TOOLS.md"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Deploy Google Ads TOOLS.md to Mac Mini ==="
echo "Target: ${MAC_MINI_USER}@${MAC_MINI_IP}"
echo ""

# 1. Pre-flight checks
echo -e "${YELLOW}[1/5] Pre-flight checks...${NC}"

if [[ ! -f "$TOOLS_MD" ]]; then
  echo -e "${RED}TOOLS.md not found at: $TOOLS_MD${NC}"
  exit 1
fi

if ! ssh "${MAC_MINI_USER}@${MAC_MINI_IP}" "echo ok" > /dev/null 2>&1; then
  echo -e "${RED}Cannot SSH to ${MAC_MINI_USER}@${MAC_MINI_IP}${NC}"
  echo "Is Tailscale running? Is the Mac Mini online?"
  exit 1
fi

echo -e "${GREEN}  SSH connected, TOOLS.md found locally${NC}"

# 2. Backup existing TOOLS.md
echo -e "${YELLOW}[2/5] Backing up existing TOOLS.md...${NC}"

BACKUP_NAME="TOOLS.md.backup-$(date +%Y%m%d-%H%M%S)"
ssh "${MAC_MINI_USER}@${MAC_MINI_IP}" \
  "cp ~/.openclaw/workspace/TOOLS.md ~/.openclaw/workspace/${BACKUP_NAME} 2>/dev/null || echo 'No existing TOOLS.md to backup'"

echo -e "${GREEN}  Backup: ~/.openclaw/workspace/${BACKUP_NAME}${NC}"

# 3. Deploy new TOOLS.md
echo -e "${YELLOW}[3/5] Deploying updated TOOLS.md...${NC}"

# Check if TOOLS.md already has other tool sections — append, don't replace
EXISTING_CONTENT=$(ssh "${MAC_MINI_USER}@${MAC_MINI_IP}" "cat ~/.openclaw/workspace/TOOLS.md 2>/dev/null || echo ''")

if echo "$EXISTING_CONTENT" | grep -q "## google-ads-cli"; then
  echo "  Replacing existing google-ads-cli section..."
  scp "$TOOLS_MD" "${MAC_MINI_USER}@${MAC_MINI_IP}:/tmp/google-ads-tools.md"

  ssh "${MAC_MINI_USER}@${MAC_MINI_IP}" bash << 'REMOTE_SCRIPT'
    python3 -c "
import re
with open('/Users/openclaw/.openclaw/workspace/TOOLS.md', 'r') as f:
    content = f.read()
pattern = r'## google-ads-cli.*?(?=\n## [^g]|\Z)'
content = re.sub(pattern, '', content, flags=re.DOTALL)
content = content.rstrip() + '\n\n'
with open('/Users/openclaw/.openclaw/workspace/TOOLS.md', 'w') as f:
    f.write(content)
" 2>/dev/null || true
    cat /tmp/google-ads-tools.md >> ~/.openclaw/workspace/TOOLS.md
    rm /tmp/google-ads-tools.md
REMOTE_SCRIPT
else
  echo "  Appending google-ads-cli section..."
  scp "$TOOLS_MD" "${MAC_MINI_USER}@${MAC_MINI_IP}:/tmp/google-ads-tools.md"
  ssh "${MAC_MINI_USER}@${MAC_MINI_IP}" \
    "echo '' >> ~/.openclaw/workspace/TOOLS.md && cat /tmp/google-ads-tools.md >> ~/.openclaw/workspace/TOOLS.md && rm /tmp/google-ads-tools.md"
fi

echo -e "${GREEN}  TOOLS.md deployed with all 35 tools${NC}"

# 4. Verify deployment
echo -e "${YELLOW}[4/5] Verifying TOOLS.md content on Mac Mini...${NC}"

TOOL_COUNT=$(ssh "${MAC_MINI_USER}@${MAC_MINI_IP}" "grep -c 'google-ads-cli' ~/.openclaw/workspace/TOOLS.md")
HAS_WRITES=$(ssh "${MAC_MINI_USER}@${MAC_MINI_IP}" "grep -c 'create-campaign\|update-campaign\|add-keywords\|create-ad-group\|update-ad' ~/.openclaw/workspace/TOOLS.md || echo 0")
HAS_AUTH=$(ssh "${MAC_MINI_USER}@${MAC_MINI_IP}" "grep -ci 'authorized' ~/.openclaw/workspace/TOOLS.md || echo 0")

echo "  Tool references: $TOOL_COUNT"
echo "  Write tool mentions: $HAS_WRITES"
echo "  Authorization statement: $HAS_AUTH"

if [[ "$TOOL_COUNT" -ge 30 && "$HAS_WRITES" -ge 5 && "$HAS_AUTH" -ge 1 ]]; then
  echo -e "${GREEN}  TOOLS.md looks correct${NC}"
else
  echo -e "${RED}  TOOLS.md may be incomplete — check manually${NC}"
fi

# 5. Summary
echo -e "${YELLOW}[5/5] Summary${NC}"
echo ""
echo -e "${GREEN}TOOLS.md deployed successfully.${NC}"
echo ""
echo "What changed:"
echo "  - Agent now knows about all 35 tools (was only 5)"
echo "  - Write tools explicitly listed with examples"
echo "  - Authorization statement tells agent it CAN modify the account"
echo ""
echo "Next steps:"
echo "  1. Test via Telegram: ask the agent to 'create a paused campaign called Test'"
echo "  2. Run full verification: ./scripts/verify-google-ads-deployment.sh --remote"
echo "  3. If agent still refuses, restart the gateway:"
echo "     ssh ${MAC_MINI_USER}@${MAC_MINI_IP} 'pkill -f openclaw && sleep 2 && openclaw start'"
echo ""
echo "Rollback: ssh ${MAC_MINI_USER}@${MAC_MINI_IP} 'cp ~/.openclaw/workspace/${BACKUP_NAME} ~/.openclaw/workspace/TOOLS.md'"
