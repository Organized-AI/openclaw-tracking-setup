# Tidy-GTM - Skill Definition and Usage

## Skill Purpose

Tidy-GTM is a specialized skill for analyzing, organizing, and cleaning Google Tag Manager containers (both web and server-side). It enables Claude Code to:

1. Audit container structure
2. Identify duplicates and orphaned items
3. Standardize naming conventions
4. Fix configuration issues
5. Organize containers

## When to Use

Use Tidy-GTM when the user asks to:

- "Clean up my GTM container"
- "Audit for duplicate tags"
- "Standardize tag naming"
- "Fix broken triggers and variables"
- "Organize my container structure"
- "Remove orphaned items"
- "Consolidate similar tags"

## Inputs

### Required

- **Container ID**: GTM container identifier
- **Analysis Type**: What to analyze (duplicates, orphans, naming, etc.)
- **Container Type**: Web or Server-side GTM

### Optional

- **Naming Pattern**: Custom naming convention
- **Action Level**: Audit-only or Execute changes
- **Scope**: Specific tags/triggers/variables to focus on

## Outputs

- Audit report with findings
- Detailed issue categorization
- Recommended actions
- Implementation roadmap
- Change summary

## Integration Points

- GTM API via blade-gtm-mcp
- Workspace synchronization
- Preview and validation
- Version control

## Error Handling

- Safe deletion with warnings
- Rollback to previous version
- Conflict resolution
- Dependency tracking

## Workflow

1. **Discovery**: List all items in container
2. **Analysis**: Identify issues by type
3. **Categorization**: Prioritize issues
4. **Planning**: Create fix sequence
5. **Execution**: Apply changes safely
6. **Validation**: Verify changes work
7. **Reporting**: Document what changed
