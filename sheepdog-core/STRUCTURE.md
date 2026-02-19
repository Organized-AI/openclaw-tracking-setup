# Sheepdog Core - Shared Infrastructure

This directory contains the core shared components of the Sheepdog GTM Tracking ecosystem, copied from the Wonder Project tracking implementation.

## Directory Structure

### browser-automation/
Browser automation tools for site crawling and interaction
- `site-crawler.js` - Playwright-based website crawler
- `package.json` - Dependencies for browser automation

### gtm-cli/
Google Tag Manager API client and management tools
- `src/` - TypeScript source code for GTM operations
- `create-ga4-tags.js` - Utility for creating GA4 tags
- CLI tools for tag, trigger, variable, template, and workspace management

### stape-cli/
Stape (Server-side Tagging) platform integration tools
- `src/` - TypeScript source code for Stape operations
- Commands for GTM, GA4, Stape platform integration
- Configuration and template utilities

### scripts/
Utility scripts and command documentation
- `create-sheepdog-tags.sh` - Script for tag creation
- `gtm-api.sh` - GTM API interaction scripts
- Command and agent documentation (*.md files)

### config/
Configuration files for the ecosystem
- `config.json` - Main project configuration
- `mcporter.json` - Multi-container porter configuration
- `mcp.json` - MCP server configuration
- `.env.example` - Environment variable template

### documentation/
Analysis reports, tracking plans, and implementation guides
- `site-analysis.md` - Website structure and trackable actions
- `site-analysis-data.json` - Structured site analysis data
- `planning/` - Implementation phases and deployment plans

### oauth/
OAuth authentication setup for Google services
- `auth.js` - OAuth authentication handler
- `gtm-api.js` - GTM API integration
- `verify.js` - OAuth verification utilities
- Configuration files for OAuth flow

### skills/
Reusable Claude skills for GTM and tracking operations
- `gtm-AI/` - AI-powered GTM analysis and planning
- `tidy-gtm/` - GTM cleanup and organization
- `agent-browser/` - Browser automation skill
- `data-audit/` - Data layer auditing
- `tracking-validation/` - Validation of tracking implementations
- `gtm-api-access/` - Direct GTM API access
- `gcp-access-gtm/` - GCP authentication for GTM
- `gtm-preview-browser/` - GTM preview environment browser

## File Count
Total files in sheepdog-core: **3,518**

## Usage
These shared components are referenced by the OpenClaw tracking plugins:
- `openclaw-google-ads` - Google Ads tracking integration
- `openclaw-meta` - Meta/Facebook tracking integration
- `openclaw-gtm` - Enhanced GTM features and builders

Each plugin can reference and extend these core components.