# Tracking Validation - Skill Definition and Usage

## Skill Purpose

Tracking Validation is a specialized skill for verifying, testing, and validating tracking implementations across web and server-side GTM. It enables Claude Code to:

1. Test tracking implementations
2. Verify event data accuracy
3. Validate GA4 configuration
4. Check conversion tracking
5. Audit data quality

## When to Use

Use Tracking Validation when the user asks to:

- "Test my tracking implementation"
- "Verify GA4 events are firing correctly"
- "Check if conversions are tracked"
- "Audit data quality in GA4"
- "Validate event parameters"
- "Check server-side conversion tracking"
- "Test cross-domain tracking"

## Inputs

### Required

- **Website URL**: Page to test
- **Test Cases**: What to validate
- **Expected Results**: What should happen

### Optional

- **GA4 View ID**: For validation
- **Event Names**: Specific events to test
- **Parameters**: Event parameters to validate
- **User Actions**: Sequence of interactions to test

## Outputs

- Test execution results
- Event firing verification
- Parameter validation report
- Data quality assessment
- Issues and recommendations

## Integration Points

- Browser automation for testing
- GTM debug console analysis
- GA4 API for event verification
- Network request inspection
- Server-side validation

## Error Handling

- Event not firing detection
- Parameter mismatch identification
- Data quality issues
- Conversion tracking failures
- Timing and sequencing issues
