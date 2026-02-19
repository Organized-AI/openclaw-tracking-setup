# OpenClaw Tracking Setup

## Tech Stack
- Platform: Claude Code Plugins (distributable)
- MCP Servers: GTM MCP (Stape), Stape MCP, Google Ads MCP
- Architecture: Three autonomous builder plugins
- Integration: OpenClaw workspace wrappers

## Project Structure
```
plugin-marketplace/
├── openclaw-google-ads/    # Google Ads conversion tracking builder
├── openclaw-meta/          # Meta Pixel + CAPI dual-tracking builder
└── openclaw-gtm/           # GTM container orchestrator (foundation)

PROMPTS/                    # Claude Code execution prompts (Phase 0-5)
PLANNING/                   # Implementation planning docs
DOCUMENTATION/              # Generated reports and architecture docs
CONFIG/                     # Configuration files
```

## Plugin Execution Order
1. openclaw-gtm (foundation — both Meta and Google Ads depend on this)
2. openclaw-google-ads (conversion tracking via GAQL audit + GTM deployment)
3. openclaw-meta (Pixel + CAPI dual-tracking with event_id deduplication)

## Code Conventions
- Plugin manifests: .claude-plugin/plugin.json
- Commands: commands/*.md with YAML frontmatter
- Agents: agents/*.md with workflow phases
- Skills: skills/*/SKILL.md
- Naming: kebab-case for directories, Title Case for PLANNING/DOCUMENTATION

## DO NOT
- Publish GTM containers without running pre-publish audit
- Modify Default Workspace directly (always create a new workspace)
- Deploy Meta Pixel without event_id for deduplication
- Run Google Ads mutate operations (read-only via GAQL)
- Skip verification steps between phases

## Verification Requirements
Before completing ANY task:
1. Describe verification approach first
2. Run plugin connectivity test (MCP tool access)
3. For GTM changes: run pre-publish audit
4. For deployments: verify in GTM Preview mode
5. Generate audit report to DOCUMENTATION/
