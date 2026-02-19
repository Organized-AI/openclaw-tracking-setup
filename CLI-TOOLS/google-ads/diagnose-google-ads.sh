#!/usr/bin/env bash
set -euo pipefail

# Diagnostic script for Google Ads API credentials
# Checks all possible credential locations and reports status

echo "=== Google Ads API Credential Diagnostics ==="
echo "Date: $(date)"
echo "Host: $(hostname)"
echo ""

# Check credential file locations
echo "--- Credential File Locations ---"
LOCATIONS=(
  "$HOME/.google-ads/google-ads.yaml"
  "$HOME/.google-ads.yaml"
  "$HOME/google-ads.yaml"
  "/etc/google-ads.yaml"
)

for loc in "${LOCATIONS[@]}"; do
  if [ -f "$loc" ]; then
    echo "  FOUND: $loc ($(stat -f%z "$loc" 2>/dev/null || stat -c%s "$loc" 2>/dev/null) bytes)"
    # Check if it has the required fields (without showing values)
    for field in developer_token client_id client_secret refresh_token login_customer_id; do
      if grep -q "$field" "$loc"; then
        echo "    $field: present"
      else
        echo "    $field: MISSING"
      fi
    done
  else
    echo "  NOT FOUND: $loc"
  fi
done

echo ""

# Check .google-ads directory
echo "--- .google-ads Directory ---"
if [ -d "$HOME/.google-ads" ]; then
  echo "  Directory exists: $HOME/.google-ads"
  ls -la "$HOME/.google-ads/" 2>/dev/null | sed 's/^/    /'
else
  echo "  Directory NOT FOUND: $HOME/.google-ads"
fi

echo ""

# Check .google-ads-cli directory
echo "--- .google-ads-cli Directory ---"
if [ -d "$HOME/.google-ads-cli" ]; then
  echo "  Directory exists: $HOME/.google-ads-cli"
  ls -la "$HOME/.google-ads-cli/" 2>/dev/null | sed 's/^/    /'
else
  echo "  Directory NOT FOUND: $HOME/.google-ads-cli"
fi

echo ""

# Check Python environment
echo "--- Python Environment ---"
if command -v python3 &> /dev/null; then
  echo "  Python3: $(python3 --version)"
  if python3 -c "import google.ads.googleads" 2>/dev/null; then
    echo "  google-ads-python: installed"
    python3 -c "import google.ads.googleads; print(f'  Version: {google.ads.googleads.__version__}')" 2>/dev/null || true
  else
    echo "  google-ads-python: NOT installed"
  fi
else
  echo "  Python3: NOT FOUND"
fi

echo ""

# Check environment variables
echo "--- Environment Variables ---"
ENV_VARS=(
  "GOOGLE_ADS_CONFIGURATION_FILE_PATH"
  "GOOGLE_ADS_CLIENT_ID"
  "GOOGLE_ADS_CLIENT_SECRET"
  "GOOGLE_ADS_DEVELOPER_TOKEN"
  "GOOGLE_ADS_REFRESH_TOKEN"
  "GOOGLE_ADS_LOGIN_CUSTOMER_ID"
  "GOOGLE_ADS_CUSTOMER_ID"
)

for var in "${ENV_VARS[@]}"; do
  val="${!var:-}"
  if [ -n "$val" ]; then
    echo "  $var: set (${#val} chars)"
  else
    echo "  $var: NOT SET"
  fi
done

echo ""

# Check for project-specific configs
echo "--- Project Configs ---"
if [ -f "./.claude/settings.env" ]; then
  echo "  .claude/settings.env: found"
  grep -c 'GOOGLE_ADS' ./.claude/settings.env 2>/dev/null | xargs -I{} echo "    Google Ads vars: {}"
else
  echo "  .claude/settings.env: not found"
fi

echo ""
echo "=== Diagnostics Complete ==="
