#!/bin/bash

# Create GA4 tags for Sheepdog tracking
# This script uses the gtm-api CLI to create tags in GTM

set -e

GTM_ACCOUNT_ID="${1:-}"
GTM_CONTAINER_ID="${2:-}"
WORKSPACE_ID="${3:-}"

if [ -z "$GTM_ACCOUNT_ID" ] || [ -z "$GTM_CONTAINER_ID" ] || [ -z "$WORKSPACE_ID" ]; then
    echo "Usage: ./create-sheepdog-tags.sh <account-id> <container-id> <workspace-id>"
    exit 1
fi

echo "Creating Sheepdog tracking tags..."
echo "Account: $GTM_ACCOUNT_ID"
echo "Container: $GTM_CONTAINER_ID"
echo "Workspace: $WORKSPACE_ID"
echo ""

# Source the gtm-api.sh for helper functions
source "$(dirname "$0")/gtm-api.sh"

# Create GA4 event tag
echo "Creating GA4 Event Tag..."
gtm_create_tag "$GTM_ACCOUNT_ID" "$GTM_CONTAINER_ID" "$WORKSPACE_ID" "GA4 Event" "gtagConfig" \
  "$(cat <<'PARAMS'
{
  "parameter": [
    {"key": "measurementId", "value": "G-XXXXXXXXXX"},
    {"key": "eventName", "value": "{{Event Name}}"},
    {"key": "eventParameters", "value": "{{Event Parameters}}"}
  ]
}
PARAMS
)"

echo "Tags created successfully!"
