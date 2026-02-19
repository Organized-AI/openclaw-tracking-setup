# GTM-AI - Skill Definition and Usage

## Skill Purpose

GTM-AI is a specialized skill for automating Google Tag Manager operations using AI-driven workflows. It enables Claude Code to:

1. Deploy tracking implementations
2. Audit GTM containers
3. Manage tags, triggers, and variables
4. Validate tracking configurations
5. Optimize container performance

## When to Use

Use GTM-AI when the user asks to:

- "Set up GA4 tracking for my website"
- "Audit my GTM container for issues"
- "Create event tags for conversion tracking"
- "Implement form tracking"
- "Fix duplicate tags or triggers"
- "Deploy tracking across multiple pages"

## Inputs

### Required

- **Action**: Type of operation (audit, deploy, validate, etc.)
- **GTM Container**: Account ID, Container ID, Workspace ID
- **Tracking Requirements**: What events to track

### Optional

- **Tag Configuration**: Custom parameters
- **Trigger Conditions**: Specific firing conditions
- **Variable Mappings**: Data layer variables
- **Preview Mode**: Test before publishing

## Outputs

- Tag/trigger/variable IDs
- Implementation summary
- Validation report
- Recommended changes
- Deployment status

## Integration Points

- GTM API via blade-gtm-mcp
- GCP access and authentication
- Browser automation for testing
- Data validation and auditing

## Error Handling

- Invalid configuration detection
- API error recovery
- Preview mode validation
- Rollback capabilities
