# Phase 1: GTM Container Setup - Template

## Overview

Phase 1 covers setting up the GTM container and basic infrastructure.

## Objectives

1. Create or configure GTM container
2. Set up data layer structure
3. Define core variables
4. Configure basic triggers
5. Create GA4 tags

## Key Tasks

### Container Configuration

```
Setup:
1. Verify GTM container created
2. Install GTM tracking code
3. Configure data layer
4. Set up environment variables
5. Enable preview mode
```

### Data Layer Structure

```
Define:
- pageInfo (title, type, URL)
- userData (ID, segment, properties)
- eventInfo (name, properties, timestamp)
- customData (business-specific data)
```

### Core Variables

```
Create:
1. Data layer variables for key events
2. URL variables for page tracking
3. Custom JavaScript variables
4. First-party cookie variables
5. Lookup tables for categorization
```

### GA4 Setup

```
Configure:
1. GA4 measurement ID
2. Event naming convention
3. Parameter mapping
4. User ID tracking
5. Enhanced e-commerce (if applicable)
```

## Prompt Template

```
Set up GTM container [CONTAINER-ID] with:
- GA4 measurement ID: [GA4-ID]
- Data layer events: [EVENTS]
- User tracking: [DETAILS]
- Custom parameters: [LIST]
```

## Deliverables

- [ ] GTM container configured
- [ ] Data layer implemented
- [ ] Core variables created
- [ ] GA4 tags deployed
- [ ] Preview mode validated
