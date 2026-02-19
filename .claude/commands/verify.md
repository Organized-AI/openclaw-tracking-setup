---
description: Run all verification checks across OpenClaw plugins
---

# Verify OpenClaw Plugins

Run complete verification suite:

1. **Plugin Connectivity**: Test MCP tool access for each plugin
   - GTM MCP: gtm_account action:list
   - Stape MCP: stape_container_crud action:get_all
   - Google Ads MCP: list-accounts
2. **Structure Validation**: Verify all plugin directories have required files
3. **Template Validation**: Check JSON templates parse correctly
4. **Cross-Plugin References**: Verify integration points between plugins

Report Pass/Fail for each with specific errors.
