# BOOT.md — Startup Sequence

<!-- Runs every time the agent starts a new session -->

## Connectivity Check

Before doing any work, verify all tools are accessible:

```bash
# 1. GTM MCP — must return tag list (may be empty)
mcporter call gtm.list_tags --output json

# 2. Stape MCP — must return container info
mcporter call stape.container_crud action=get identifier=CONTAINER_ID

# 3. Google Ads CLI — must return campaign list (may be empty)
google-ads-cli list-campaigns

# 4. Meta Ads CLI — must return campaign list (may be empty)
meta-ads-cli campaigns --account-id ACT_ID
```

If any tool fails:
- Log the error to today's memory file
- Inform the client which tool is down
- Do NOT proceed with any phase that requires the failed tool
- Attempt to diagnose (expired token? wrong container ID? missing config?)

## Context Load

After connectivity check passes:
1. Read STRATEGY-DESK.md — what's the current phase and priority?
2. Check HEARTBEAT.md — is there a scheduled task due?
3. Read the most recent memory/ entry — what happened last session?
4. Resume work from where you left off

## Quick Status

After loading context, provide a brief status:
```
Tracking Status — YYYY-MM-DD
Phase: [current phase]
Tools: ✅ GTM MCP | ✅ Stape | ✅ Google Ads | ✅ Meta Ads
Last activity: [summary from most recent memory entry]
Next action: [what to do now based on STRATEGY-DESK.md]
```
