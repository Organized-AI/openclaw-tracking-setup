# GTM Variable Types Reference

Complete guide to Google Tag Manager variable types and configurations.

## Built-in Variables

### Container Built-in Variables

- **Container ID**: Unique identifier of the GTM container
- **Container Version**: Current version number
- **Preview Mode**: Boolean, true when in preview
- **Debug Mode**: Boolean, true when debug enabled

### Page Variables

- **Page Hostname**: Domain of the page
- **Page Path**: URL path
- **Page URL**: Full URL
- **Page Referrer**: Referrer URL
- **Page Title**: Document title

### Event Variables

- **Click Classes**: CSS classes of clicked element
- **Click Element**: The element that was clicked
- **Click ID**: ID attribute of clicked element
- **Click Target**: Target attribute of link
- **Click Text**: Text content of clicked element
- **Click URL**: HREF of clicked link
- **Form Action**: Action attribute of form
- **Form Class**: CSS classes of form
- **Form ID**: ID of form
- **Form Method**: GET or POST
- **Form Target**: Target of form submission

### Technology Variables

- **User Agent**: Browser user agent string
- **Query String Parameter**: Get URL parameter
- **HTML ID**: Element ID for form/click tracking
- **HTML Class**: CSS classes for element
- **First Party Cookie**: Read first-party cookies
- **HTTP Referrer**: HTTP referrer header
- **JavaScript Variable**: Access JS variables in data layer

## Custom Variable Types

### Data Layer Variable

Reads values from the data layer.

```javascript
{
  "type": "data_layer",
  "key": "eventName",
  "dataLayerVersion": 1
}
```

### Constant

Static value that doesn't change.

```javascript
{
  "type": "constant",
  "value": "my_static_value"
}
```

### JavaScript Variable

Executes custom JavaScript to get value.

```javascript
{
  "type": "javascript",
  "script": "return document.querySelector('.price').textContent;"
}
```

### First-Party Cookie

Reads cookie values.

```javascript
{
  "type": "cookie",
  "cookieName": "user_id"
}
```

### URL Variable

Extracts from URL.

```javascript
{
  "type": "url",
  "component": "HOST" // PROTOCOL, DOMAIN, HOST, PATH, QUERY, FRAGMENT, PORT
}
```

### Lookup Table

Maps input to output value.

```javascript
{
  "type": "lookup_table",
  "input": "Page Path",
  "mapping": {
    "/products": "product_list",
    "/checkout": "checkout",
    "/thank-you": "thank_you"
  }
}
```

### Regex Match

Matches string against regex.

```javascript
{
  "type": "regex",
  "input": "Page URL",
  "pattern": "category=([^&]*)",
  "output": "replacement string"
}
```

## Variable Usage Examples

### Tracking Purchase Amount

```javascript
// Data Layer Variable
Variable Name: Purchase Amount
Data Layer Version: 2
Data Layer Key: ecommerce.transaction.value
```

### Category from URL

```javascript
// Lookup Table Variable
Variable Name: Product Category
Input Variable: Page Path
Mapping:
  /products/electronics → electronics
  /products/clothing → clothing
  /products/home → home
```

### User Login Status

```javascript
// JavaScript Variable
Variable Name: User Logged In
Script: return !!window.currentUser && !!window.currentUser.id
```

## Best Practices

1. **Naming**: Use `[Type] - [Description]` format
   - `DL - Event Name`
   - `Cookie - Session ID`
   - `JS - Cart Total`

2. **Organization**: Group similar variables in folders

3. **Documentation**: Add notes describing purpose and usage

4. **Testing**: Always test in preview mode before publishing

5. **Performance**: Minimize JavaScript variable complexity

6. **Consistency**: Use same naming conventions across all variables
