# Stape CLI - Unified Command Line Interface

Comprehensive CLI for managing Stape server-side tagging infrastructure, integrations, and deployments.

## Overview

Stape CLI provides a unified interface for:

- **GTM Management**: Container configuration, deployment, versioning
- **Server-Side Tagging**: sGTM setup and configuration
- **Conversions API**: Facebook CAPI, TikTok Events, LinkedIn implementation
- **GA4 Configuration**: GA4 setup, event mapping, property management
- **Environment Management**: Dev/staging/production environments
- **Template Installation**: Deploy pre-built templates and integrations

## Quick Start

### Installation

```bash
npm install -g @stape/cli
```

### Configuration

```bash
stape config set --gtm-account-id=ACCOUNT_ID
stape config set --gtm-container-id=CONTAINER_ID
stape config set --gtm-workspace-id=WORKSPACE_ID
stape config set --stape-api-key=YOUR_API_KEY
```

### Basic Commands

```bash
# Show current configuration
stape config show

# Deploy GTM container
stape gtm deploy

# List available templates
stape install list

# Install a template
stape install template --name="facebook-capi"

# Check Stape status
stape status
```

## Command Categories

### Config Commands

```bash
stape config set <key> <value>     # Set config value
stape config get <key>             # Get config value
stape config show                  # Show all config
stape config reset                 # Reset to defaults
```

### GTM Commands

```bash
stape gtm list                     # List containers
stape gtm deploy                   # Deploy current container
stape gtm status                   # Check deployment status
stape gtm rollback                 # Rollback to previous version
stape gtm version                  # Show current version
```

### GA4 Commands

```bash
stape ga4 setup                    # Initialize GA4
stape ga4 events list              # List configured events
stape ga4 events map               # Map events to conversions
stape ga4 property show            # Show GA4 property details
```

### Stape Commands

```bash
stape status                       # Show Stape account status
stape containers list              # List Stape containers
stape containers show <id>         # Show container details
stape domains list                 # List configured domains
stape logs show                    # Show recent logs
```

### Install Commands

```bash
stape install list                 # List available templates
stape install search <keyword>     # Search templates
stape install template <name>      # Install template
stape install verify               # Verify installation
```

## Features

### Interactive Configuration

The CLI provides interactive prompts for complex configurations:

```bash
stape setup --interactive
```

This will guide you through:
1. GTM container selection
2. GA4 property selection
3. Stape account setup
4. Domain configuration
5. Integration selection

### Environment Management

```bash
stape env create development       # Create dev environment
stape env create staging           # Create staging environment
stape env create production        # Create production environment
stape env switch development       # Switch to development
```

### Deployment Automation

```bash
stape deploy --auto-publish        # Deploy and auto-publish
stape deploy --version="1.0.0"    # Deploy specific version
stape deploy --verify              # Deploy with verification
stape deploy --rollback-on-error   # Auto-rollback if errors
```

### Template System

Pre-built templates for common integrations:

- **facebook-capi**: Facebook Conversions API
- **tiktok-events**: TikTok Events API
- **linkedin-capi**: LinkedIn Conversions API
- **shopify-integration**: Shopify tracking
- **woocommerce-integration**: WooCommerce tracking
- **mixpanel-forwarding**: Mixpanel integration
- **amplitude-forwarding**: Amplitude integration
- **databricks-warehouse**: Databricks integration

### Monitoring and Logs

```bash
stape logs show --last=100         # Show last 100 logs
stape logs filter --error          # Show errors only
stape logs follow                  # Follow live logs
stape metrics show                 # Show performance metrics
stape alerts list                  # Show configured alerts
```

## Configuration

### Environment Variables

```bash
export GTM_ACCOUNT_ID="123456"
export GTM_CONTAINER_ID="GTM-XXXXX"
export GTM_WORKSPACE_ID="workspace-id"
export STAPE_API_KEY="sk_live_xxxxx"
export STAPE_REGION="eu"          # or "default" (US)
```

### Configuration File

Config stored at `~/.stape/config.json`:

```json
{
  "stapeApiKey": "sk_live_xxxxx",
  "stapeRegion": "default",
  "gtmAccountId": "123456",
  "gtmWebContainerId": "GTM-XXXXX",
  "gtmServerContainerId": "GTM-YYYYY",
  "gtmWorkspaceId": "workspace-id"
}
```

## Advanced Usage

### Scripting

Use Stape CLI in scripts for automation:

```bash
#!/bin/bash

# Deploy and verify
stape gtm deploy --verify
if [ $? -eq 0 ]; then
  echo "Deployment successful"
  stape ga4 events list
else
  echo "Deployment failed"
  stape gtm rollback
fi
```

### CI/CD Integration

```bash
# GitHub Actions example
stape deploy \
  --version="$GITHUB_SHA" \
  --auto-publish \
  --rollback-on-error
```

### Batch Operations

```bash
# Deploy to multiple containers
for container in GTM-XXXXX GTM-YYYYY GTM-ZZZZZ; do
  stape gtm deploy --container=$container
done
```

## Troubleshooting

### Authentication Issues

```bash
# Verify API key
stape auth verify

# Re-authenticate
stape auth login

# Show current auth status
stape auth status
```

### Deployment Issues

```bash
# Check GTM connectivity
stape gtm health

# Verify container access
stape gtm access --container-id=GTM-XXXXX

# Show deployment logs
stape logs deploy --last=50
```

### Performance Issues

```bash
# Show metrics
stape metrics show

# Identify slow requests
stape metrics slow-requests

# Check domain performance
stape domains performance
```

## Documentation

For more information:

- [Stape Documentation](https://docs.stape.io)
- [GTM Integration Guide](https://docs.stape.io/gtm)
- [Server-Side Tagging Setup](https://docs.stape.io/setup)
- [API Reference](https://docs.stape.io/api)
- [Template Library](https://docs.stape.io/templates)

## Support

- Email: support@stape.io
- Slack: [Join Stape Community](https://slack.stape.io)
- Issues: [GitHub Issues](https://github.com/stape-io/cli/issues)
