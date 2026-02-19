# GA4 Ecommerce DataLayer Schemas

Exact JSON schemas for every GA4 ecommerce event pushed to the dataLayer. The agent uses these to create matching GTM Data Layer Variables and to validate existing dataLayer implementations during site scanning.

---

## DataLayer Version

All schemas below use **dataLayer v2** format (GA4 standard). When creating GTM Data Layer Variables, always set `dataLayerVersion: 2`.

**v2 path format:** `ecommerce.transaction_id` (dot notation)
**v1 path format (LEGACY):** `transactionId` (flat, camelCase) — do NOT use

---

## Items Array Schema

The `items[]` array is shared across all ecommerce events. Each item object:

```json
{
  "item_id": "SKU_12345",
  "item_name": "Blue T-Shirt",
  "affiliation": "Store Name",
  "coupon": "SUMMER10",
  "discount": 2.00,
  "index": 0,
  "item_brand": "BrandName",
  "item_category": "Apparel",
  "item_category2": "Men",
  "item_category3": "Shirts",
  "item_category4": "T-Shirts",
  "item_category5": "Crew Neck",
  "item_list_id": "related_products",
  "item_list_name": "Related Products",
  "item_variant": "Blue / Large",
  "location_id": "ChIJrTLr-GyuEmsRBfy61i59si0",
  "price": 19.99,
  "quantity": 2
}
```

### Required Fields

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `item_id` | string | Yes (or item_name) | SKU or product ID |
| `item_name` | string | Yes (or item_id) | Product display name |

At least one of `item_id` or `item_name` must be present. Both is recommended.

### Common Fields

| Field | Type | Notes |
|-------|------|-------|
| `price` | number | Unit price, NOT total. No currency symbol. |
| `quantity` | number | Integer. Defaults to 1 if omitted. |
| `item_brand` | string | Brand name |
| `item_category` | string | Primary category |
| `item_variant` | string | Size, color, or other variant |
| `discount` | number | Discount amount per unit |
| `coupon` | string | Item-level coupon (separate from order-level coupon) |

---

## Event Schemas

### view_item_list

**When:** Category page, collection page, search results page — any page showing a list of products.

**During site scan:** Look for product grids/lists, category pages, search results.

```json
dataLayer.push({
  "event": "view_item_list",
  "ecommerce": {
    "item_list_id": "category_mens_shirts",
    "item_list_name": "Men's Shirts",
    "items": [
      {
        "item_id": "SKU_001",
        "item_name": "Blue T-Shirt",
        "item_brand": "BrandName",
        "item_category": "Apparel",
        "item_variant": "Blue",
        "price": 19.99,
        "index": 0,
        "quantity": 1
      },
      {
        "item_id": "SKU_002",
        "item_name": "Red T-Shirt",
        "item_brand": "BrandName",
        "item_category": "Apparel",
        "item_variant": "Red",
        "price": 24.99,
        "index": 1,
        "quantity": 1
      }
    ]
  }
})
```

**GTM Variables Needed:**
- `DLV - ecommerce.item_list_id`
- `DLV - ecommerce.item_list_name`
- `DLV - ecommerce.items`

---

### select_item

**When:** User clicks a product from a listing to view its detail page.

```json
dataLayer.push({
  "event": "select_item",
  "ecommerce": {
    "item_list_id": "category_mens_shirts",
    "item_list_name": "Men's Shirts",
    "items": [
      {
        "item_id": "SKU_001",
        "item_name": "Blue T-Shirt",
        "item_brand": "BrandName",
        "item_category": "Apparel",
        "price": 19.99,
        "index": 0,
        "quantity": 1
      }
    ]
  }
})
```

---

### view_item

**When:** Product detail page (PDP) loads.

**During site scan:** Look for pages with product images, price, add-to-cart button, variant selectors.

```json
dataLayer.push({
  "event": "view_item",
  "ecommerce": {
    "currency": "USD",
    "value": 19.99,
    "items": [
      {
        "item_id": "SKU_001",
        "item_name": "Blue T-Shirt",
        "item_brand": "BrandName",
        "item_category": "Apparel",
        "item_category2": "Men",
        "item_variant": "Blue / Large",
        "price": 19.99,
        "quantity": 1
      }
    ]
  }
})
```

**GTM Variables Needed:**
- `DLV - ecommerce.currency`
- `DLV - ecommerce.value`
- `DLV - ecommerce.items`

---

### add_to_cart

**When:** User clicks add-to-cart button.

**During site scan:** Look for add-to-cart buttons, "Add to Bag" buttons, quantity + add buttons.

```json
dataLayer.push({
  "event": "add_to_cart",
  "ecommerce": {
    "currency": "USD",
    "value": 39.98,
    "items": [
      {
        "item_id": "SKU_001",
        "item_name": "Blue T-Shirt",
        "item_brand": "BrandName",
        "item_category": "Apparel",
        "item_variant": "Blue / Large",
        "price": 19.99,
        "quantity": 2
      }
    ]
  }
})
```

**Value calculation:** Sum of (price × quantity) for all items in the add action.

---

### remove_from_cart

**When:** User removes item from cart.

**During site scan:** Look for "Remove" buttons/links in cart, "×" close buttons on cart items.

```json
dataLayer.push({
  "event": "remove_from_cart",
  "ecommerce": {
    "currency": "USD",
    "value": 19.99,
    "items": [
      {
        "item_id": "SKU_001",
        "item_name": "Blue T-Shirt",
        "price": 19.99,
        "quantity": 1
      }
    ]
  }
})
```

---

### view_cart

**When:** Cart page loads or cart drawer opens.

**During site scan:** Look for cart pages (/cart), slide-out cart drawers, cart modals.

```json
dataLayer.push({
  "event": "view_cart",
  "ecommerce": {
    "currency": "USD",
    "value": 59.97,
    "items": [
      {
        "item_id": "SKU_001",
        "item_name": "Blue T-Shirt",
        "price": 19.99,
        "quantity": 2
      },
      {
        "item_id": "SKU_003",
        "item_name": "Black Jeans",
        "price": 19.99,
        "quantity": 1
      }
    ]
  }
})
```

---

### begin_checkout

**When:** User starts checkout process (clicks "Checkout" button or lands on checkout page).

**During site scan:** Look for "Checkout" buttons, checkout page URLs (/checkout, /checkout/information).

```json
dataLayer.push({
  "event": "begin_checkout",
  "ecommerce": {
    "currency": "USD",
    "value": 59.97,
    "coupon": "SUMMER10",
    "items": [
      {
        "item_id": "SKU_001",
        "item_name": "Blue T-Shirt",
        "price": 19.99,
        "quantity": 2
      },
      {
        "item_id": "SKU_003",
        "item_name": "Black Jeans",
        "price": 19.99,
        "quantity": 1
      }
    ]
  }
})
```

---

### add_shipping_info

**When:** User completes shipping information step.

**During site scan:** Look for multi-step checkouts with shipping address form, shipping method selection.

```json
dataLayer.push({
  "event": "add_shipping_info",
  "ecommerce": {
    "currency": "USD",
    "value": 59.97,
    "coupon": "SUMMER10",
    "shipping_tier": "Ground",
    "items": [
      {
        "item_id": "SKU_001",
        "item_name": "Blue T-Shirt",
        "price": 19.99,
        "quantity": 2
      },
      {
        "item_id": "SKU_003",
        "item_name": "Black Jeans",
        "price": 19.99,
        "quantity": 1
      }
    ]
  }
})
```

---

### add_payment_info

**When:** User completes payment information step.

**During site scan:** Look for payment forms (credit card fields, PayPal buttons, payment method selection).

```json
dataLayer.push({
  "event": "add_payment_info",
  "ecommerce": {
    "currency": "USD",
    "value": 59.97,
    "coupon": "SUMMER10",
    "payment_type": "Credit Card",
    "items": [
      {
        "item_id": "SKU_001",
        "item_name": "Blue T-Shirt",
        "price": 19.99,
        "quantity": 2
      },
      {
        "item_id": "SKU_003",
        "item_name": "Black Jeans",
        "price": 19.99,
        "quantity": 1
      }
    ]
  }
})
```

---

### purchase

**When:** Order confirmation page loads.

**During site scan:** Look for thank-you/confirmation pages, order summary displays, order number displays.

```json
dataLayer.push({
  "event": "purchase",
  "ecommerce": {
    "transaction_id": "T_12345",
    "value": 65.32,
    "tax": 3.35,
    "shipping": 5.00,
    "currency": "USD",
    "coupon": "SUMMER10",
    "items": [
      {
        "item_id": "SKU_001",
        "item_name": "Blue T-Shirt",
        "item_brand": "BrandName",
        "item_category": "Apparel",
        "item_variant": "Blue / Large",
        "price": 19.99,
        "quantity": 2,
        "coupon": ""
      },
      {
        "item_id": "SKU_003",
        "item_name": "Black Jeans",
        "item_brand": "BrandName",
        "item_category": "Apparel",
        "price": 19.99,
        "quantity": 1,
        "coupon": ""
      }
    ]
  }
})
```

**Critical fields:**
- `transaction_id` — MUST be unique per order. Duplicates cause deduplication (event dropped).
- `value` — Total order value including tax and shipping (or just product total — be consistent).
- `currency` — REQUIRED. Value is silently dropped without currency.

**GTM Variables Needed (all DLV type):**
- `DLV - ecommerce.transaction_id`
- `DLV - ecommerce.value`
- `DLV - ecommerce.tax`
- `DLV - ecommerce.shipping`
- `DLV - ecommerce.currency`
- `DLV - ecommerce.coupon`
- `DLV - ecommerce.items`

---

### refund

**When:** Full or partial refund processed (typically server-side, not from the browser).

**Full refund:**
```json
dataLayer.push({
  "event": "refund",
  "ecommerce": {
    "transaction_id": "T_12345",
    "value": 65.32,
    "currency": "USD"
  }
})
```

**Partial refund (specific items):**
```json
dataLayer.push({
  "event": "refund",
  "ecommerce": {
    "transaction_id": "T_12345",
    "value": 19.99,
    "currency": "USD",
    "items": [
      {
        "item_id": "SKU_003",
        "item_name": "Black Jeans",
        "price": 19.99,
        "quantity": 1
      }
    ]
  }
})
```

---

## DataLayer Validation During Site Scan

When auditing an existing dataLayer implementation, check for these common issues:

### Structure Checks

```javascript
// Run in browser console during site scan:

// 1. Is dataLayer defined?
console.log('dataLayer exists:', typeof window.dataLayer !== 'undefined');

// 2. List all events
window.dataLayer.forEach(function(entry) {
  if (entry.event) console.log('Event:', entry.event);
});

// 3. Check ecommerce structure
window.dataLayer.forEach(function(entry) {
  if (entry.ecommerce) {
    console.log('Ecommerce event:', entry.event, entry.ecommerce);
    // Check items is array
    if (entry.ecommerce.items) {
      console.log('Items is array:', Array.isArray(entry.ecommerce.items));
      console.log('Items count:', entry.ecommerce.items.length);
    }
  }
});
```

### Common Issues to Flag

| Issue | How to Detect | Impact |
|-------|--------------|--------|
| `items` is object, not array | `typeof items === 'object' && !Array.isArray(items)` | GA4 ignores the data |
| Missing `currency` with `value` | `value` present but no `currency` field | Value is silently dropped |
| `price` as string | `typeof price === 'string'` | May cause calculation errors |
| `quantity` as string | `typeof quantity === 'string'` | May cause calculation errors |
| Duplicate `transaction_id` | Same ID on page reload | GA4 deduplicates (drops event) |
| Empty `items` array | `items.length === 0` | Event fires but with no product data |
| Missing `item_id` AND `item_name` | Neither field present in item | Item is ignored by GA4 |
| Using v1 format | Flat keys like `transactionId`, `transactionTotal` | Wrong format for GA4 |

### Platform-Specific DataLayer Patterns

When scanning sites, these platforms have known dataLayer implementations:

| Platform | DataLayer Quality | Notes |
|----------|------------------|-------|
| Shopify | Good (with GA4 app) | Uses official GA4 ecommerce format. Check theme customizations. |
| WooCommerce | Varies | Depends on plugin (GTM4WP recommended). Check plugin version. |
| Magento 2 | Good (with GTM module) | Built-in dataLayer support. |
| BigCommerce | Moderate | May need custom implementation. |
| Squarespace | Limited | Basic ecommerce events. May need custom code. |
| Wix | Limited | Basic support via native integration. |
| Custom builds | Varies | Must validate structure manually. |

### What to Do When DataLayer Is Missing

If the site has NO dataLayer implementation:

1. Document which events need dataLayer pushes
2. This requires developer work on the site (outside GTM)
3. Provide the exact JSON schemas from this document to the developer
4. In the meantime, use GTM triggers that don't require dataLayer:
   - Page View triggers (URL matching) for page-based events
   - Click triggers (element matching) for button/link clicks
   - Form Submission triggers for forms
   - Element Visibility for scroll-into-view
5. NOTE: Without dataLayer, ecommerce events (purchase, add_to_cart) cannot capture product/transaction data through GTM alone. The site code MUST push this data.
