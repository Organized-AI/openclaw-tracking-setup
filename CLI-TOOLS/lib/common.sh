#!/usr/bin/env bash
# OpenClaw CLI — Shared utilities
# Colors, logging, error handling

set -euo pipefail

# ── Colors ──────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  MAGENTA='\033[0;35m'
  CYAN='\033[0;36m'
  BOLD='\033[1m'
  DIM='\033[2m'
  RESET='\033[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN='' BOLD='' DIM='' RESET=''
fi

# ── Logging ─────────────────────────────────────────────────────────────────
log_info()  { echo -e "${CYAN}ℹ${RESET}  $*"; }
log_ok()    { echo -e "${GREEN}✓${RESET}  $*"; }
log_warn()  { echo -e "${YELLOW}⚠${RESET}  $*" >&2; }
log_error() { echo -e "${RED}✗${RESET}  $*" >&2; }
log_step()  { echo -e "${BLUE}→${RESET}  ${BOLD}$*${RESET}"; }
log_dim()   { echo -e "${DIM}$*${RESET}"; }

# ── Header ──────────────────────────────────────────────────────────────────
print_header() {
  local tool="$1"
  echo -e "${BOLD}${MAGENTA}🦞 OpenClaw${RESET} ${DIM}—${RESET} ${BOLD}${tool}${RESET}"
  echo -e "${DIM}$(printf '%.0s─' {1..50})${RESET}"
}

# ── Dependency checks ───────────────────────────────────────────────────────
require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" &>/dev/null; then
    log_error "Required command not found: ${BOLD}$cmd${RESET}"
    log_dim   "Install with: npm install -g $cmd"
    exit 1
  fi
}

require_mcporter() {
  if ! command -v mcporter &>/dev/null && ! npx mcporter --version &>/dev/null 2>&1; then
    log_error "mcporter is required but not found."
    log_dim   "Install: npm install -g mcporter"
    log_dim   "Or use: npx mcporter"
    exit 1
  fi
}

# ── mcporter wrapper ────────────────────────────────────────────────────────
# Prefers local mcporter, falls back to npx
mcp() {
  if command -v mcporter &>/dev/null; then
    mcporter "$@"
  else
    npx mcporter "$@"
  fi
}

# Call an MCP tool and return JSON
mcp_call() {
  local server_tool="$1"
  shift
  mcp call "$server_tool" "$@" --output json 2>/dev/null
}

# Call an MCP tool, pretty print
mcp_call_pretty() {
  local server_tool="$1"
  shift
  mcp call "$server_tool" "$@" 2>/dev/null
}

# ── Environment ─────────────────────────────────────────────────────────────
OPENCLAW_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OPENCLAW_CONFIG="${OPENCLAW_ROOT}/CLI-TOOLS/config"
OPENCLAW_OUTPUT="${OPENCLAW_ROOT}/CLI-TOOLS/output"

mkdir -p "$OPENCLAW_OUTPUT"

# ── JSON helpers ────────────────────────────────────────────────────────────
# Extract a field from JSON (requires jq)
json_get() {
  local json="$1" field="$2"
  echo "$json" | jq -r "$field" 2>/dev/null || echo ""
}

# Count items in a JSON array
json_count() {
  local json="$1"
  echo "$json" | jq 'length' 2>/dev/null || echo "0"
}

# ── Confirm ─────────────────────────────────────────────────────────────────
confirm() {
  local msg="${1:-Continue?}"
  echo -en "${YELLOW}? ${msg} [y/N]${RESET} "
  read -r reply
  [[ "$reply" =~ ^[Yy]$ ]]
}
