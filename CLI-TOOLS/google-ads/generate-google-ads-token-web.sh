#!/usr/bin/env bash
set -euo pipefail

# OAuth Token Generator for Web App
# Starts a local HTTP server to handle OAuth callbacks automatically
# More user-friendly than the CLI version (no copy-paste needed)

CLIENT_ID="${GOOGLE_ADS_CLIENT_ID:?Set GOOGLE_ADS_CLIENT_ID env var}"
CLIENT_SECRET="${GOOGLE_ADS_CLIENT_SECRET:?Set GOOGLE_ADS_CLIENT_SECRET env var}"
REDIRECT_URI="http://localhost:8080/oauth2callback"
SCOPE="https://www.googleapis.com/auth/adwords"
PORT=8080

echo "=== Google Ads API - OAuth Token Generator (Web) ==="
echo ""

AUTH_URL="https://accounts.google.com/o/oauth2/v2/auth?client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}&scope=${SCOPE}&response_type=code&access_type=offline&prompt=consent"

echo "Step 1: Opening browser for authorization..."
echo ""
echo "If the browser doesn't open automatically, visit this URL:"
echo "$AUTH_URL"
echo ""

# Open browser
if command -v open &> /dev/null; then
    open "$AUTH_URL"
elif command -v xdg-open &> /dev/null; then
    xdg-open "$AUTH_URL"
fi

echo "Step 2: Waiting for OAuth callback on port $PORT..."
echo ""
echo "After you authorize in the browser, the code will be captured automatically."
echo ""

# Start the Python OAuth callback server
export CLIENT_ID CLIENT_SECRET REDIRECT_URI
python3 "$(dirname "$0")/oauth-server.py"

echo ""
echo "Server stopped."
