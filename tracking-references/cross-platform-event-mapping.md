# Cross-Platform Event Mapping Reference

## Standard Event Mapping

| Site Action | GA4 Event | Meta Event | Google Ads Category | GTM Trigger Type |
|-------------|-----------|------------|--------------------|--------------------|}
| Page load | page_view | PageView | PAGE_VIEW | Page View - All Pages |
| Product/service page | view_item | ViewContent | — | Page View - URL match |
| CTA click | generate_lead | Lead | SUBMIT_LEAD_FORM | Click - CSS selector |
| Form start | form_start | — | — | Custom Event |
| Form submit | generate_lead | Lead | SUBMIT_LEAD_FORM | Form Submission / Custom Event |
| Add to cart | add_to_cart | AddToCart | ADD_TO_CART | Click - Add to cart button |
| Begin checkout | begin_checkout | InitiateCheckout | BEGIN_CHECKOUT | Page View / Click |
| Purchase | purchase | Purchase | PURCHASE | Page View / Custom Event |
| Sign up | sign_up | CompleteRegistration | SIGN_UP | Page View / Custom Event |
| Search | search | Search | — | Custom Event |
| Contact | — | Contact | CONTACT | Click / Form |
| Schedule | — | Schedule | BOOK_APPOINTMENT | Click / Form |
| Start trial | — | StartTrial | — | Click |
| Subscribe | — | Subscribe | SUBSCRIBE_PAID | Custom Event |

## DataLayer Push Structure

### Standard Event Push

```javascript
window.dataLayer = window.dataLayer || [];
window.dataLayer.push({
  event: 'generate_lead',
  event_id: Date.now().toString(36) + Math.random().toString(36).substr(2, 9),
  value: 100,
  currency: 'USD',
  user_data: {
    email: 'user@example.com',
    phone: '+15551234567',
    address: {
      first_name: 'John',
      last_name: 'Doe',
      city: 'Austin',
      region: 'TX',
      postal_code: '78701',
      country: 'US'
    }
  }
});
```

### Form Tracking Pattern

```javascript
(function() {
  var form = document.querySelector('#target-form');
  if (!form) return;

  // Track form start on first interaction
  var started = false;
  form.addEventListener('focusin', function() {
    if (started) return;
    started = true;
    window.dataLayer.push({
      event: 'form_start',
      form_id: form.id || 'unknown',
      form_name: form.getAttribute('data-form-name') || 'Contact Form'
    });
  });

  // Track form submission
  form.addEventListener('submit', function(e) {
    var eventId = Date.now().toString(36) + Math.random().toString(36).substr(2, 9);

    window.dataLayer.push({
      event: 'generate_lead',
      event_id: eventId,
      form_id: form.id || 'unknown',
      form_name: form.getAttribute('data-form-name') || 'Contact Form',
      value: 100,
      currency: 'USD',
      user_data: {
        email: form.querySelector('[name="email"]')?.value || '',
        phone: form.querySelector('[name="phone"]')?.value || '',
        address: {
          first_name: form.querySelector('[name="first_name"]')?.value || '',
          last_name: form.querySelector('[name="last_name"]')?.value || ''
        }
      }
    });
  });
})();
```

## User Data Normalization

Before hashing for Meta CAPI / Enhanced Conversions:

```javascript
function normalizeUserData(data) {
  return {
    em: (data.email || '').toLowerCase().trim(),
    ph: (data.phone || '').replace(/[^0-9]/g, ''),
    fn: (data.first_name || '').toLowerCase().trim(),
    ln: (data.last_name || '').toLowerCase().trim(),
    ct: (data.city || '').toLowerCase().trim().replace(/\s/g, ''),
    st: (data.state || '').toLowerCase().trim(),
    zp: (data.zip || '').trim().substring(0, 5),
    country: (data.country || 'us').toUpperCase().trim()
  };
}
```

## Naming Conventions

### GTM Tag Names

| Platform | Pattern | Example |
|----------|---------|----------|
| GA4 | `GA4 - {Type} - {Description}` | GA4 - Event - Purchase |
| Meta Pixel | `Meta - Pixel - {Description}` | Meta - Pixel - Base Code |
| Meta Event | `Meta - Event - {EventName}` | Meta - Event - Purchase |
| Meta CAPI | `Meta - CAPI - {EventName}` | Meta - CAPI - Purchase |
| CAPIG | `CAPIG - {EventName}` | CAPIG - Purchase |
| Google Ads | `GAds - {Type} - {Description}` | GAds - Conversion - Purchase |
| LinkedIn | `LI - {Type} - {Description}` | LI - Event - Lead |

### GTM Variable Names

| Type | Pattern | Example |
|------|---------|----------|
| Constant | `{Platform} - Const - {Name}` | Meta - Const - Pixel ID |
| DataLayer | `DL - {Variable Name}` | DL - Purchase Value |
| Custom JS | `JS - {Description}` | JS - Event ID |
| Lookup Table | `LUT - {Description}` | LUT - Event Value Map |
| First Party Cookie | `Cookie - {Name}` | Cookie - _fbc |

### GTM Trigger Names

| Type | Pattern | Example |
|------|---------|----------|
| Page View | `PV - {Description}` | PV - All Pages |
| Click | `Click - {Description}` | Click - CTA Button |
| Form | `Form - {Description}` | Form - Contact Submit |
| Custom Event | `CE - {Event Name}` | CE - generate_lead |
| Scroll | `Scroll - {Percentage}` | Scroll - 50% |
| Timer | `Timer - {Description}` | Timer - 30s Engaged |

### GTM Folder Organization

```
📁 GA4
  ├── GA4 - Config - G-XXXXXXXXXX
  ├── GA4 - Event - Page View
  ├── GA4 - Event - Generate Lead
  └── GA4 - Event - Purchase

📁 Meta
  ├── Meta - Pixel - Base Code
  ├── Meta - Event - Lead
  ├── Meta - Event - Purchase
  └── (sGTM: Meta - CAPI - * or CAPIG - *)

📁 Google Ads
  ├── GAds - Conversion Linker
  ├── GAds - Conversion - Lead
  ├── GAds - Conversion - Purchase
  └── GAds - Remarketing

📁 LinkedIn
  ├── LI - Insight Tag - Base
  ├── LI - Event - Lead
  └── (sGTM: LI - CAPI - *)

📁 Utilities
  ├── Consent Mode - Default
  └── Data Tag (if using Data Client pattern)
```

## GTM Container Import/Export

### Export Format Version 2

Standard container JSON structure:

```json
{
  "exportFormatVersion": 2,
  "exportTime": "2026-02-19 00:00:00",
  "containerVersion": {
    "tag": [...],
    "trigger": [...],
    "variable": [...],
    "folder": [...],
    "builtInVariable": [...]
  }
}
```

### Import Strategies

| Strategy | Use Case |
|----------|----------|
| Overwrite | New/empty containers — replaces everything |
| Merge (Rename) | Existing containers — adds with renamed conflicts |
| Merge (Overwrite) | Updates — replaces matching entities |

### Version Naming Convention

```
[Project] - [Feature] v[Major].[Minor]
```

Example: `Wonder Project - Meta CAPI Setup v1.0`

### Workspace Best Practices

| Workspace | Purpose |
|-----------|----------|
| Default | Never modify directly — production reference |
| Dev | Active development and testing |
| Staging | Pre-production validation |
| {Feature} | Isolated feature branches |

## Event Value Reference

Values should be set based on business type and funnel stage:

### Lead Generation
| Event | Typical Value |
|-------|---------------|
| Page View | $0 (no value) |
| View Content | $1-5 |
| Lead (form submit) | $10-100 |
| Qualified Lead | $50-500 |
| Appointment Set | $100-1000 |

### E-Commerce
| Event | Value Source |
|-------|---------------|
| View Item | — |
| Add to Cart | Item price |
| Begin Checkout | Cart total |
| Purchase | Transaction revenue |

### High-Value Services (e.g., Medical)
| Event | Example Value |
|-------|----------------|
| Lead | $37,500 (gene therapy) / $15,000 (exosome) |
| Deposit | $25,000-50,000 |
| Treatment Complete | Actual treatment cost |
