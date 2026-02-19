# Common GTM Container Issues and Fixes

## Issue: Duplicate Tags

**Problem**: Multiple tags with same firing conditions and parameters.

**Detection**:
```
Tag A: GA4 - Purchase (fires on trigger_123, sends purchase data)
Tag B: GA4 - Purchase (fires on trigger_123, sends purchase data)
```

**Fix**:
1. Keep the one with clearer naming
2. Update all tags pointing to remove to point to kept one
3. Delete duplicate
4. Test in preview mode

## Issue: Orphaned Triggers

**Problem**: Triggers not used by any tag.

**Detection**: Run audit, look for unused triggers.

**Fix**:
1. Search for references in tags
2. If truly unused, delete
3. If should be used, add to appropriate tags

## Issue: Broken Variable References

**Problem**: Tag references non-existent variable.

**Error Signs**:
- Tag shows undefined in debug console
- Variable ID doesn't resolve
- Configuration warnings in GTM

**Fix**:
1. Identify missing variable
2. Check if variable was deleted
3. Either restore variable or update tag reference
4. Test tag fires correctly

## Issue: Naming Inconsistency

**Problem**: Tags/triggers/variables have inconsistent naming.

**Examples**:
```
GA4 - Purchase     (correct pattern)
google_analytics_purchase  (wrong pattern)
New Tag            (too generic)
test trigger       (no prefix)
```

**Fix**:
Rename to pattern: `[Platform/Type] - [Description]`

## Issue: Circular Dependencies

**Problem**: Tags/variables reference each other creating loops.

**Detection**: Review variable definitions for circular refs.

**Fix**:
1. Identify the loop
2. Break the dependency chain
3. Restructure variables
4. Test configuration

## Issue: Data Layer Mismatches

**Problem**: Tags expect different data layer structure.

**Example**:
```javascript
// Page sends:
window.dataLayer = [{
  event: 'purchase',
  transaction_id: '123'
}]

// Tag expects:
ecommerce.transaction.id
```

**Fix**:
1. Standardize data layer structure
2. Update tags to match
3. Add data layer variables for mapping
4. Test with real data

## Issue: Trigger Over-firing

**Problem**: Tag fires more times than expected.

**Causes**:
- Trigger condition too broad
- Multiple triggers matching
- Page fires multiple events

**Fix**:
1. Review trigger conditions
2. Add more specific filters
3. Add frequency capping
4. Test with debug console

## Issue: Tags Not Firing

**Problem**: Tags should fire but don't.

**Diagnostic Steps**:
1. Enable preview mode
2. Open debug console
3. Check trigger conditions
4. Verify data layer values
5. Check for JavaScript errors

**Common Causes**:
- Trigger condition never matches
- Tag disabled
- Container not loaded
- Data layer not ready
- JavaScript errors

**Fix**:
1. Verify trigger condition logic
2. Add debug variables
3. Check data availability
4. Review event sequence

## Issue: Page Load Slowdown

**Problem**: Adding GTM increased page load time.

**Causes**:
- Too many tags firing on page load
- Heavy JavaScript variables
- External API calls in tags

**Fix**:
1. Defer non-critical tags
2. Simplify JavaScript variables
3. Remove unnecessary tags
4. Use tag sequencing
5. Monitor tag load times

## Issue: Merge Conflicts in Workspace

**Problem**: Multiple users made changes, conflict created.

**Resolution**:
1. One user publishes first
2. Other user refreshes workspace
3. Reapply changes on top
4. Create new version

## Issue: Template Import Failure

**Problem**: Custom template won't import.

**Causes**:
- Syntax errors in template
- Invalid parameter definitions
- Missing dependencies

**Fix**:
1. Validate template syntax
2. Check parameter types
3. Review error message
4. Fix issues in template
5. Retry import
