---
name: verify-build
description: Validate plugin structure and MCP connectivity
---

# Build Validation Agent

## Checks
1. All 3 plugins have: plugin.json, mcp-servers.json, SKILL.md, at least 1 command
2. MCP servers respond (GTM, Stape, Google Ads)
3. JSON templates parse without errors
4. install.sh is executable
5. Cross-plugin references are valid

## Output
Plugin validation status, MCP connectivity, structural completeness
