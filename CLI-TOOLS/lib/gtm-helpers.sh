#!/usr/bin/env bash
# OpenClaw CLI — GTM helper functions
# Wraps GTM MCP (Stape) calls via mcporter

# Source common if not already loaded
[[ -z "${OPENCLAW_ROOT:-}" ]] && source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# ── GTM Account/Container/Workspace resolution ─────────────────────────────
# These use environment variables or resolve from config
GTM_ACCOUNT_ID="${GTM_ACCOUNT_ID:-}"
GTM_CONTAINER_ID="${GTM_CONTAINER_ID:-}"
GTM_WORKSPACE_ID="${GTM_WORKSPACE_ID:-}"

gtm_ensure_ids() {
  if [[ -z "$GTM_ACCOUNT_ID" || -z "$GTM_CONTAINER_ID" || -z "$GTM_WORKSPACE_ID" ]]; then
    log_error "GTM IDs not set. Export these environment variables:"
    log_dim   "  GTM_ACCOUNT_ID=your-account-id"
    log_dim   "  GTM_CONTAINER_ID=your-container-id"
    log_dim   "  GTM_WORKSPACE_ID=your-workspace-id"
    exit 1
  fi
}

# ── Tag operations ──────────────────────────────────────────────────────────
gtm_list_tags() {
  gtm_ensure_ids
  mcp_call gtm-mcp-server.gtm_tag \
    action:list \
    accountId:"$GTM_ACCOUNT_ID" \
    containerId:"$GTM_CONTAINER_ID" \
    workspaceId:"$GTM_WORKSPACE_ID" \
    itemsPerPage:20 \
    page:"${1:-1}"
}

gtm_get_tag() {
  local tag_id="$1"
  gtm_ensure_ids
  mcp_call gtm-mcp-server.gtm_tag \
    action:get \
    accountId:"$GTM_ACCOUNT_ID" \
    containerId:"$GTM_CONTAINER_ID" \
    workspaceId:"$GTM_WORKSPACE_ID" \
    tagId:"$tag_id"
}

gtm_create_tag() {
  local config_json="$1"
  gtm_ensure_ids
  mcp_call gtm-mcp-server.gtm_tag \
    action:create \
    accountId:"$GTM_ACCOUNT_ID" \
    containerId:"$GTM_CONTAINER_ID" \
    workspaceId:"$GTM_WORKSPACE_ID" \
    createOrUpdateConfig:"$config_json"
}

# ── Trigger operations ──────────────────────────────────────────────────────
gtm_list_triggers() {
  gtm_ensure_ids
  mcp_call gtm-mcp-server.gtm_trigger \
    action:list \
    accountId:"$GTM_ACCOUNT_ID" \
    containerId:"$GTM_CONTAINER_ID" \
    workspaceId:"$GTM_WORKSPACE_ID" \
    itemsPerPage:20 \
    page:"${1:-1}"
}

gtm_create_trigger() {
  local config_json="$1"
  gtm_ensure_ids
  mcp_call gtm-mcp-server.gtm_trigger \
    action:create \
    accountId:"$GTM_ACCOUNT_ID" \
    containerId:"$GTM_CONTAINER_ID" \
    workspaceId:"$GTM_WORKSPACE_ID" \
    createOrUpdateConfig:"$config_json"
}

# ── Variable operations ─────────────────────────────────────────────────────
gtm_list_variables() {
  gtm_ensure_ids
  mcp_call gtm-mcp-server.gtm_variable \
    action:list \
    accountId:"$GTM_ACCOUNT_ID" \
    containerId:"$GTM_CONTAINER_ID" \
    workspaceId:"$GTM_WORKSPACE_ID" \
    itemsPerPage:20 \
    page:"${1:-1}"
}

gtm_create_variable() {
  local config_json="$1"
  gtm_ensure_ids
  mcp_call gtm-mcp-server.gtm_variable \
    action:create \
    accountId:"$GTM_ACCOUNT_ID" \
    containerId:"$GTM_CONTAINER_ID" \
    workspaceId:"$GTM_WORKSPACE_ID" \
    createOrUpdateConfig:"$config_json"
}

# ── Workspace operations ────────────────────────────────────────────────────
gtm_workspace_status() {
  gtm_ensure_ids
  mcp_call gtm-mcp-server.gtm_workspace \
    action:getStatus \
    accountId:"$GTM_ACCOUNT_ID" \
    containerId:"$GTM_CONTAINER_ID" \
    workspaceId:"$GTM_WORKSPACE_ID"
}

gtm_create_version() {
  local name="$1" description="${2:-}"
  gtm_ensure_ids
  mcp_call gtm-mcp-server.gtm_workspace \
    action:createVersion \
    accountId:"$GTM_ACCOUNT_ID" \
    containerId:"$GTM_CONTAINER_ID" \
    workspaceId:"$GTM_WORKSPACE_ID"
}

gtm_publish_version() {
  local version_id="$1"
  gtm_ensure_ids
  mcp_call gtm-mcp-server.gtm_version \
    action:publish \
    accountId:"$GTM_ACCOUNT_ID" \
    containerId:"$GTM_CONTAINER_ID" \
    containerVersionId:"$version_id"
}

# ── Container info ──────────────────────────────────────────────────────────
gtm_get_container() {
  gtm_ensure_ids
  mcp_call gtm-mcp-server.gtm_container \
    action:get \
    accountId:"$GTM_ACCOUNT_ID" \
    containerId:"$GTM_CONTAINER_ID"
}

gtm_live_version() {
  gtm_ensure_ids
  mcp_call gtm-mcp-server.gtm_version \
    action:live \
    accountId:"$GTM_ACCOUNT_ID" \
    containerId:"$GTM_CONTAINER_ID"
}

# ── Folder operations ───────────────────────────────────────────────────────
gtm_list_folders() {
  gtm_ensure_ids
  mcp_call gtm-mcp-server.gtm_folder \
    action:list \
    accountId:"$GTM_ACCOUNT_ID" \
    containerId:"$GTM_CONTAINER_ID" \
    workspaceId:"$GTM_WORKSPACE_ID"
}

gtm_create_folder() {
  local name="$1"
  gtm_ensure_ids
  mcp_call gtm-mcp-server.gtm_folder \
    action:create \
    accountId:"$GTM_ACCOUNT_ID" \
    containerId:"$GTM_CONTAINER_ID" \
    workspaceId:"$GTM_WORKSPACE_ID" \
    createOrUpdateConfig:"{\"name\":\"$name\"}"
}

# ── Built-in variables ──────────────────────────────────────────────────────
gtm_list_built_in_variables() {
  gtm_ensure_ids
  mcp_call gtm-mcp-server.gtm_built_in_variable \
    action:list \
    accountId:"$GTM_ACCOUNT_ID" \
    containerId:"$GTM_CONTAINER_ID" \
    workspaceId:"$GTM_WORKSPACE_ID"
}

# ── sGTM Client operations ─────────────────────────────────────────────────
gtm_list_clients() {
  gtm_ensure_ids
  mcp_call gtm-mcp-server.gtm_client \
    action:list \
    accountId:"$GTM_ACCOUNT_ID" \
    containerId:"$GTM_CONTAINER_ID" \
    workspaceId:"$GTM_WORKSPACE_ID"
}

gtm_create_client() {
  local config_json="$1"
  gtm_ensure_ids
  mcp_call gtm-mcp-server.gtm_client \
    action:create \
    accountId:"$GTM_ACCOUNT_ID" \
    containerId:"$GTM_CONTAINER_ID" \
    workspaceId:"$GTM_WORKSPACE_ID" \
    createOrUpdateConfig:"$config_json"
}
