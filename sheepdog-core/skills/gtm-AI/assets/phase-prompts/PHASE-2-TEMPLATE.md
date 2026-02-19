# Phase 2: Event Tracking Implementation - Template

## Overview

Phase 2 covers implementing specific event tracking for user actions and conversions.

## Objectives

1. Create event-specific tags
2. Configure event triggers
3. Set up event parameters
4. Implement custom events
5. Test event tracking

## Key Tasks

### Event Tag Creation

```
For each event:
1. Create GA4 event tag
2. Configure event name
3. Map event parameters
4. Set firing triggers
5. Add tag sequencing if needed
```

### Trigger Configuration

```
Trigger Types:
1. Page view triggers
2. Click triggers
3. Form submission triggers
4. Scroll triggers
5. Timer triggers
6. Custom event triggers
```

### Event Parameter Mapping

```
For each event:
- event_name: [string]
- value: [number] (if purchase)
- currency: [string] (if purchase)
- custom_parameter_1: [value]
- custom_parameter_2: [value]
```

### Testing

```
Validate:
1. Enable preview mode
2. Perform tracked actions
3. Verify events fire
4. Check parameter values
5. Confirm GA4 receipt
```

## Prompt Template

```
Implement tracking for these events:
1. Event: [NAME]
   - Trigger: [CONDITION]
   - Parameters: [PARAMS]
2. Event: [NAME]
   - Trigger: [CONDITION]
   - Parameters: [PARAMS]
```

## Deliverables

- [ ] Event tags created
- [ ] Triggers configured
- [ ] Parameters mapped
- [ ] Tracking tested
- [ ] GA4 events visible
