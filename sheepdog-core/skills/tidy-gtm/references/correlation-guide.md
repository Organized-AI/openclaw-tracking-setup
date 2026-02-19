# GTM Correlation Guide

Understanding relationships between GTM components.

## Tag → Trigger → Variable Flow

```
┌─────────────────────┐
│   TAG (gaawe)       │
│  GA4 - Purchase     │
│                     │
│ FiringTriggerId:    │
│  └─ trigger_123     │  ← References trigger
│                     │
│ Parameters:         │
│  └─ {{DL - Total}} │  ← References variable
└─────────────────────┘
         │
         ├──────────────────┬──────────────────┐
         │                  │                  │
         ▼                  ▼                  ▼
    ┌─────────────┐  ┌─────────────┐  ┌──────────────┐
    │  TRIGGER    │  │  VARIABLE   │  │   VARIABLE   │
    │ trigger_123 │  │DL - Total   │  │DL - Currency │
    │             │  │             │  │              │
    │ Type: Click │  │Type: DL     │  │Type: Constant│
    │ on button   │  │Key: purchase│  │Value: USD    │
    └─────────────┘  └─────────────┘  └──────────────┘
```

## Dependency Chain

```
Step 1: PAGE LOADS
        ↓
Step 2: DATA LAYER FIRES
        window.dataLayer.push({
          event: 'purchase',
          purchase: { total: 99.99 }
        })
        ↓
Step 3: TRIGGER EVALUATES
        "Event equals purchase" ✓
        ↓
Step 4: VARIABLES RESOLVE
        {{DL - Total}} → 99.99
        ↓
Step 5: TAG FIRES
        GA4 event with value: 99.99
        ↓
Step 6: MEASUREMENT RECORDED
        GA4 conversion logged
```

## Common Correlation Patterns

### Pattern 1: Page View Tags

```
TAG: GA4 - Page View
  └─ Trigger: Initialization - All Pages
  └─ Variables:
      ├─ {{Page Title}}
      ├─ {{Page URL}}
      └─ {{Page Path}}
```

### Pattern 2: Event Tags

```
TAG: GA4 - {{Event Name}}
  └─ Trigger: Custom Event
      └─ Condition: event equals {{Event Var}}
  └─ Variables:
      ├─ {{DL - Event Name}}
      ├─ {{DL - Event Category}}
      └─ {{DL - Event Value}}
```

### Pattern 3: E-commerce Tags

```
TAG: GA4 - Purchase
  └─ Trigger: Custom Event
      └─ Condition: event equals "purchase"
  └─ Variables:
      ├─ {{DL - Transaction ID}}
      ├─ {{DL - Transaction Total}}
      ├─ {{DL - Currency}}
      └─ {{DL - Items}}
```

## Circular Dependency Detection

```
DANGER: Variable A depends on Variable B
        Variable B depends on Variable A

Example (WRONG):
  Variable: "Total with Tax"
    = {{Total}} + ({{Total}} * {{Tax Rate}})
    But {{Total}} = {{Total with Tax}} - {{Tax}}

Fix: Break the cycle by using data layer values
  Variable: "Total with Tax"
    = {{DL - Cart Total}} + ({{DL - Cart Total}} * {{DL - Tax Rate}})
```

## Server-Side (sGTM) Correlation

### Client → Server

```
CLIENT-SIDE (Web GTM)
┌──────────────┐
│ GA4 Event    │
│ {            │
│   event: purchase
│   value: 99.99
│ }            │
└────────┬─────┘
         │ (via measurement protocol)
         ▼
SERVER-SIDE (sGTM)
┌──────────────────────┐
│ Server Container     │
│ Receives request     │
│ Enriches data        │
│ Sends to CAPI        │
└──────────────────────┘
```

### Event ID Correlation

```
CLIENT:
  gtag('event', 'purchase', {
    event_id: 'evt_12345',
    value: 99.99
  })
  ↓
SERVER:
  Check incoming event_id
  If event_id == 'evt_12345'
    Send to Facebook CAPI
    with matching event_id
```

## Data Layer Correlation

### Map Data Layer to GA4

```
WEBSITE DATA LAYER:
window.dataLayer = [{
  event: 'purchase',
  ecommerce: {
    transaction_id: 'order_123',
    value: 99.99,
    currency: 'USD',
    items: [...]
  },
  user: {
    id: 'user_456',
    email: 'user@example.com'
  }
}]
         │
         ▼
GTM VARIABLES:
  DL - Transaction ID  → ecommerce.transaction_id
  DL - Order Value     → ecommerce.value
  DL - Currency        → ecommerce.currency
  DL - User ID         → user.id
  DL - User Email      → user.email
         │
         ▼
GA4 EVENTS:
  event: purchase
  transaction_id: order_123
  value: 99.99
  currency: USD
  user_id: user_456
  user_data.email_address: user@example.com
```

## Testing Correlations

### Debug Console View

```
1. Open GTM Debug Console
2. Perform action (click, form submit)
3. In console, verify:
   ✓ Event fires in "Events" section
   ✓ Data layer shows correct values
   ✓ Trigger evaluates to TRUE
   ✓ Variables resolve to expected values
   ✓ Tag fires with correct parameters
```

## Validation Checklist

- [ ] Every tag has at least one trigger
- [ ] Every trigger ID referenced by tags exists
- [ ] Every variable ID referenced exists
- [ ] Data layer structure matches variable definitions
- [ ] No circular dependencies
- [ ] All parameter values are defined
- [ ] Test in preview mode
- [ ] Verify GA4 receives events
