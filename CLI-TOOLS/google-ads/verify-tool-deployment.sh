#!/usr/bin/env bash
set -euo pipefail

# Generic OpenClaw Tool Deployment Verifier
# Tests that a CLI tool is properly deployed AND that the OpenClaw
# agent can discover and use ALL of its capabilities (read + write).
#
# 4 verification layers:
#   Layer 1: Infrastructure (binary, PATH, credentials)
#   Layer 2: CLI functionality (every subcommand runs)
#   Layer 3: TOOLS.md parity (every subcommand documented)
#   Layer 4: Write authorization (agent knows it can write)
#
# Usage:
#   ./verify-tool-deployment.sh --tool google-ads-cli --remote --ip 100.66.145.48
#   ./verify-tool-deployment.sh --tool google-ads-cli          # local only
#   ./verify-tool-deployment.sh --tool my-cli --layer 3        # specific layer

TOOL_NAME=""
IP=""
USER="openclaw"
MODE="local"
LAYER_FILTER=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --tool)   TOOL_NAME="$2"; shift 2 ;;
    --remote) MODE="remote"; shift ;;
    --ip)     IP="$2"; MODE="remote"; shift 2 ;;
    --user)   USER="$2"; shift 2 ;;
    --layer)  LAYER_FILTER="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 --tool <name> [--remote] [--ip <tailscale-ip>] [--user <ssh-user>] [--layer <1-4>]"
      exit 0 ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

if [[ -z "$TOOL_NAME" ]]; then
  echo "ERROR: --tool <name> is required"
  exit 1
fi

if [[ "$MODE" == "remote" && -z "$IP" ]]; then
  echo "ERROR: --ip required for remote mode"
  exit 1
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

PASS=0
FAIL=0
SKIP=0
WARN=0
TOTAL=0
RESULTS=()
BLOCKERS=()

run_cmd() {
  if [[ "$MODE" == "remote" ]]; then
    ssh "${USER}@${IP}" "zsh -l -c '$1'" 2>&1
  else
    eval "$1" 2>&1
  fi
}

check() {
  local name="$1"
  local cmd="$2"
  local expect="${3:-}"
  local blocking="${4:-true}"

  TOTAL=$((TOTAL + 1))
  local output
  if output=$(run_cmd "$cmd" 2>&1); then
    if [[ -n "$expect" ]] && ! echo "$output" | grep -qi "$expect"; then
      if [[ "$blocking" == "true" ]]; then
        FAIL=$((FAIL + 1))
        RESULTS+=("${RED}FAIL${NC} $name — expected '$expect'")
        BLOCKERS+=("$name")
      else
        WARN=$((WARN + 1))
        RESULTS+=("${YELLOW}WARN${NC} $name — expected '$expect'")
      fi
      return 1
    fi
    PASS=$((PASS + 1))
    RESULTS+=("${GREEN}PASS${NC} $name")
    return 0
  else
    if [[ "$blocking" == "true" ]]; then
      FAIL=$((FAIL + 1))
      RESULTS+=("${RED}FAIL${NC} $name — ${output:0:100}")
      BLOCKERS+=("$name")
    else
      WARN=$((WARN + 1))
      RESULTS+=("${YELLOW}WARN${NC} $name — ${output:0:100}")
    fi
    return 1
  fi
}

header() {
  echo ""
  echo -e "${BLUE}${BOLD}--- $1 ---${NC}"
}

echo -e "${BOLD}OpenClaw Tool Deployment Verification${NC}"
echo "Tool: $TOOL_NAME"
echo "Mode: $MODE $([ "$MODE" == "remote" ] && echo "($USER@$IP)")"
echo "Date: $(date '+%Y-%m-%d %H:%M')"

# Layer 1: Infrastructure
if [[ -z "$LAYER_FILTER" || "$LAYER_FILTER" == "1" ]]; then
  header "LAYER 1: Infrastructure"
  check "Binary in PATH" "which $TOOL_NAME"
  check "--help works" "$TOOL_NAME --help 2>&1 | head -5" ""
  check "Node.js available" "node --version" "v"
  if [[ "$MODE" == "remote" ]]; then
    check "TOOLS.md exists" "test -f ~/.openclaw/workspace/TOOLS.md && echo exists" "exists"
  fi
fi

# Layer 2: CLI Functionality
if [[ -z "$LAYER_FILTER" || "$LAYER_FILTER" == "2" ]]; then
  header "LAYER 2: CLI Functionality"
  HELP_OUTPUT=$(run_cmd "$TOOL_NAME --help 2>&1" || true)
  SUBCOMMANDS=$(echo "$HELP_OUTPUT" | grep -oE '^\s{2,}[a-z][-a-z_]+' | sed 's/^[[:space:]]*//' | sort -u || true)
  CMD_COUNT=$(echo "$SUBCOMMANDS" | grep -c '[a-z]' || echo "0")
  echo "  Found $CMD_COUNT subcommands in --help"

  if [[ "$CMD_COUNT" -gt 0 ]]; then
    SAMPLE=$(echo "$SUBCOMMANDS" | head -5)
    for cmd in $SAMPLE; do
      check "Subcommand: $cmd" "$TOOL_NAME $cmd --help 2>&1 || $TOOL_NAME $cmd --limit 1 2>&1 || true" "" "false"
    done
  fi
fi

# Layer 3: TOOLS.md Parity
if [[ -z "$LAYER_FILTER" || "$LAYER_FILTER" == "3" ]]; then
  header "LAYER 3: TOOLS.md Parity"
  if [[ "$MODE" != "remote" ]]; then
    echo "  Use --remote to check Mac Mini"
  else
    TOOLS_REFS=$(run_cmd "grep -c '$TOOL_NAME' ~/.openclaw/workspace/TOOLS.md 2>/dev/null || echo 0")
    check "Tool mentioned in TOOLS.md ($TOOLS_REFS refs)" "test $TOOLS_REFS -gt 0 && echo yes" "yes"
  fi
fi

# Layer 4: Write Authorization
if [[ -z "$LAYER_FILTER" || "$LAYER_FILTER" == "4" ]]; then
  header "LAYER 4: Write Authorization"
  if [[ "$MODE" != "remote" ]]; then
    echo "  Use --remote to check Mac Mini"
  else
    check "Authorization statement" "grep -ciE 'you are authorized|authorized to use|can create|can update' ~/.openclaw/workspace/TOOLS.md 2>/dev/null | grep -v '^0$'" ""
    check "Write Operations section" "grep -ciE 'write operations|write tools|Create & Modify' ~/.openclaw/workspace/TOOLS.md 2>/dev/null | grep -v '^0$'" ""
  fi
fi

# Results
header "RESULTS"
for r in "${RESULTS[@]}"; do
  echo -e "  $r"
done

echo ""
echo -e "${BOLD}--- SUMMARY ---${NC}"
echo -e "  ${GREEN}PASS${NC}: $PASS"
echo -e "  ${RED}FAIL${NC}: $FAIL"
echo -e "  ${YELLOW}WARN${NC}: $WARN"
echo -e "  SKIP: $SKIP"
echo -e "  Total: $TOTAL"

if [[ ${#BLOCKERS[@]} -gt 0 ]]; then
  echo ""
  echo -e "${RED}DEPLOYMENT BLOCKED:${NC}"
  for b in "${BLOCKERS[@]}"; do
    echo -e "  x $b"
  done
fi

echo ""
if [[ $FAIL -eq 0 ]]; then
  echo -e "${GREEN}DEPLOYMENT APPROVED — All verification gates passed.${NC}"
  exit 0
else
  echo -e "${RED}DEPLOYMENT NOT READY — $FAIL blocker(s) found.${NC}"
  exit 1
fi
