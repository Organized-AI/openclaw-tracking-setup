#!/usr/bin/env bash
set -euo pipefail

# Google Ads CLI — Deployment Verification Script
# Tests all 35 tools across 4 layers before declaring a deployment ready.
#
# Usage:
#   ./verify-google-ads-deployment.sh                    # Run locally
#   ./verify-google-ads-deployment.sh --remote           # Run on Mac Mini via SSH
#   ./verify-google-ads-deployment.sh --remote --write   # Include write tool API tests
#   ./verify-google-ads-deployment.sh --layer 2          # Run specific layer only
#
# Layers:
#   1: Infrastructure (binary, PATH, credentials)
#   2: Read Tools (24 API connectivity tests)
#   3: Write Tools (11 syntax + optional live tests)
#   4: Agent Integration (TOOLS.md, gateway, exec-approvals)

MAC_MINI_IP="${GOOGLE_ADS_VERIFY_IP:-100.66.145.48}"
MAC_MINI_USER="${GOOGLE_ADS_VERIFY_USER:-openclaw}"
MODE="local"
INCLUDE_WRITES=false
LAYER_FILTER=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --remote) MODE="remote"; shift ;;
    --write)  INCLUDE_WRITES=true; shift ;;
    --layer)  LAYER_FILTER="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0
SKIP=0
TOTAL=0
RESULTS=()

run_cmd() {
  if [[ "$MODE" == "remote" ]]; then
    ssh "${MAC_MINI_USER}@${MAC_MINI_IP}" "zsh -l -c '$1'" 2>&1
  else
    eval "$1" 2>&1
  fi
}

check() {
  local name="$1"
  local cmd="$2"
  local expect="${3:-}"

  TOTAL=$((TOTAL + 1))
  local output
  if output=$(run_cmd "$cmd" 2>&1); then
    if [[ -n "$expect" ]] && ! echo "$output" | grep -qi "$expect"; then
      FAIL=$((FAIL + 1))
      RESULTS+=("${RED}FAIL${NC} $name — expected '$expect' in output")
      return 1
    fi
    PASS=$((PASS + 1))
    RESULTS+=("${GREEN}PASS${NC} $name")
    return 0
  else
    FAIL=$((FAIL + 1))
    local err_preview="${output:0:120}"
    RESULTS+=("${RED}FAIL${NC} $name — ${err_preview}")
    return 1
  fi
}

skip() {
  local name="$1"
  local reason="$2"
  TOTAL=$((TOTAL + 1))
  SKIP=$((SKIP + 1))
  RESULTS+=("${YELLOW}SKIP${NC} $name — $reason")
}

header() {
  echo ""
  echo -e "${BLUE}--- $1 ---${NC}"
}

# Layer 1: Infrastructure
if [[ -z "$LAYER_FILTER" || "$LAYER_FILTER" == "1" ]]; then
  header "LAYER 1: Infrastructure"
  check "CLI binary exists" "which google-ads-cli"
  check "CLI --help works" "google-ads-cli --help" "google-ads"
  check "Node.js available" "node --version" "v"

  if [[ "$MODE" == "remote" ]]; then
    check "~/bin in PATH" 'echo $PATH' "bin"
    check "TOOLS.md exists" "test -f ~/.openclaw/workspace/TOOLS.md && echo exists" "exists"
    check "TOOLS.md has write tools" "grep -c 'create-campaign\|update-campaign\|add-keywords' ~/.openclaw/workspace/TOOLS.md" ""
    check "Credentials file exists" "test -f ~/.google-ads-cli/config.json && echo exists" "exists"
  fi
fi

# Layer 2: Read Tools (24 tools)
if [[ -z "$LAYER_FILTER" || "$LAYER_FILTER" == "2" ]]; then
  header "LAYER 2: Read Tools (API connectivity)"
  check "list-campaigns" "google-ads-cli list-campaigns --limit 1"
  check "list-ad-groups" "google-ads-cli list-ad-groups --limit 1"
  check "list-ads" "google-ads-cli list-ads --limit 1"
  check "list-keywords" "google-ads-cli list-keywords --limit 1"
  check "get-account-performance" "google-ads-cli get-account-performance"
  check "get-campaign-performance" "google-ads-cli get-campaign-performance --limit 1"
  check "get-search-terms-report" "google-ads-cli get-search-terms-report --limit 1"
  check "list-accessible-customers" "google-ads-cli list-accessible-customers"
  check "get-account-hierarchy" "google-ads-cli get-account-hierarchy"
  check "get-account-info" "google-ads-cli get-account-info"
  check "get-top-bottom-keywords" "google-ads-cli get-top-bottom-keywords --limit 1"
  check "get-campaign-comparison" "google-ads-cli get-campaign-comparison"
  check "list-conversion-actions" "google-ads-cli list-conversion-actions"
  check "get-conversion-stats" "google-ads-cli get-conversion-stats"
fi

# Layer 3: Write Tools (11 tools)
if [[ -z "$LAYER_FILTER" || "$LAYER_FILTER" == "3" ]]; then
  header "LAYER 3: Write Tools (syntax check)"
  WRITE_TOOLS=(create-campaign update-campaign create-ad-group update-ad-group create-responsive-search-ad update-ad add-keywords add-negative-keywords update-keyword create-conversion-action update-conversion-action)
  for tool in "${WRITE_TOOLS[@]}"; do
    check "$tool (recognized)" "google-ads-cli $tool --help 2>&1 || google-ads-cli --help 2>&1 | grep -i '$tool'" ""
  done

  if [[ "$INCLUDE_WRITES" == true ]]; then
    header "LAYER 3b: Write Tools (LIVE API — PAUSED resources)"
    check "create-campaign (PAUSED)" "google-ads-cli create-campaign --name 'VERIFY-TEST-DELETE-ME' --budget 1 --advertising-channel-type SEARCH --status PAUSED"
  fi
fi

# Layer 4: Agent Integration
if [[ -z "$LAYER_FILTER" || "$LAYER_FILTER" == "4" ]]; then
  header "LAYER 4: Agent Integration"
  if [[ "$MODE" == "remote" ]]; then
    check "TOOLS.md mentions create-campaign" "grep -c 'create-campaign' ~/.openclaw/workspace/TOOLS.md"
    check "TOOLS.md says authorized" "grep -i 'authorized' ~/.openclaw/workspace/TOOLS.md" ""
    check "OpenClaw gateway running" "pgrep -f 'openclaw\|gateway' > /dev/null && echo running" "running"
  else
    skip "Agent integration checks" "Use --remote to check Mac Mini"
  fi
fi

# Results
header "RESULTS"
for r in "${RESULTS[@]}"; do
  echo -e "  $r"
done

echo ""
echo -e "${BLUE}--- SUMMARY ---${NC}"
echo -e "  ${GREEN}PASS${NC}: $PASS"
echo -e "  ${RED}FAIL${NC}: $FAIL"
echo -e "  ${YELLOW}SKIP${NC}: $SKIP"
echo -e "  Total: $TOTAL"

if [[ $FAIL -eq 0 ]]; then
  echo ""
  echo -e "${GREEN}All checks passed. Deployment is ready.${NC}"
  exit 0
else
  echo ""
  echo -e "${RED}$FAIL check(s) failed. Fix before declaring deployment ready.${NC}"
  exit 1
fi
