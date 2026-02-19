# Tidy-GTM Audit Checklist

Systematic checklist for auditing GTM containers.

## Pre-Audit

- [ ] Backup current version
- [ ] Get container access
- [ ] Verify MCP authentication
- [ ] Document current state
- [ ] Gather requirements

## Phase 1: Inventory

### Count Items

- [ ] Number of tags: ___
- [ ] Number of triggers: ___
- [ ] Number of variables: ___
- [ ] Number of templates: ___
- [ ] Number of folders: ___
- [ ] Number of versions: ___

### Check Status

- [ ] All items have names
- [ ] No hidden characters in names
- [ ] All items are active (unless archived)

## Phase 2: Naming Standards

### Tag Naming

- [ ] All tags follow pattern: `[Platform] - [Action]`
- [ ] No "Copy of" prefixes
- [ ] No generic names ("New Tag", "test")
- [ ] No special characters except hyphens
- [ ] Maximum 80 characters

### Trigger Naming

- [ ] All triggers follow pattern: `[Type] - [Description]`
- [ ] Named by firing condition
- [ ] No duplicate names
- [ ] Clear purpose from name

### Variable Naming

- [ ] All variables follow pattern: `[Type] - [Name]`
- [ ] Type is clear (DL, Cookie, JS, etc.)
- [ ] Describes what variable contains
- [ ] Consistency with GA dimensions/metrics

## Phase 3: Tag Analysis

### For Each Tag

- [ ] Has at least one firing trigger
- [ ] All trigger IDs resolve
- [ ] Parameters are correctly configured
- [ ] No typos in parameter values
- [ ] Accounts/IDs are correct (GA4, FB pixel, etc.)
- [ ] Not disabled unless intentional
- [ ] Has relevant notes if needed

### Tag Purpose

- [ ] Purpose is clear from name
- [ ] Documented why it exists
- [ ] Know who created it
- [ ] Know when it was created

## Phase 4: Trigger Analysis

### For Each Trigger

- [ ] Used by at least one tag
- [ ] Conditions are correct
- [ ] Filters are appropriate
- [ ] Fire "on page load" triggers exist
- [ ] Click/form triggers are specific
- [ ] Custom event triggers have clear event names

### Trigger Logic

- [ ] All conditions are AND/OR correctly
- [ ] No unreachable conditions
- [ ] No overly broad conditions
- [ ] All referenced variables exist

## Phase 5: Variable Analysis

### For Each Variable

- [ ] Used by at least one tag or trigger
- [ ] Data source exists (data layer, cookie, etc.)
- [ ] Returns expected data type
- [ ] Has meaningful name
- [ ] Tested with real data

### Variable Consistency

- [ ] Data layer variable names match website
- [ ] Cookie names are correct
- [ ] URL parameter names are correct
- [ ] JavaScript variable paths work

## Phase 6: Configuration Issues

### Broken References

- [ ] All trigger IDs exist
- [ ] All variable IDs exist
- [ ] No circular dependencies
- [ ] No missing required parameters

### Data Flow

- [ ] Data layer structure is consistent
- [ ] Event naming is standardized
- [ ] Parameter names match GA4 conventions
- [ ] Custom parameters documented

## Phase 7: Duplicates Detection

### Potential Duplicates

- [ ] Same tag name but different ID
- [ ] Same firing conditions
- [ ] Same parameters
- [ ] Should be consolidated: YES/NO

### Resolution

- [ ] Identified duplicates
- [ ] Marked for removal
- [ ] Updated references

## Phase 8: Orphan Detection

### Unused Items

- [ ] Triggers with no tags: ___
- [ ] Variables with no references: ___
- [ ] Templates not in use: ___
- [ ] Folders with no items: ___

### Resolution

- [ ] Mark for deletion
- [ ] Confirm not needed
- [ ] Delete safely

## Phase 9: Verification

### Testing

- [ ] Enable preview mode
- [ ] Test key user flows
- [ ] Check debug console
- [ ] Verify data in GA4
- [ ] Check server container (if applicable)

### Sign-Off

- [ ] All issues documented
- [ ] Fixes planned
- [ ] Timeline agreed
- [ ] Stakeholders notified

## Post-Audit

- [ ] Create version with audit notes
- [ ] Document findings
- [ ] Share report with team
- [ ] Schedule follow-ups
- [ ] Set monitoring alerts
