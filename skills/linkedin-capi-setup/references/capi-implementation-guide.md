# LinkedIn Conversions API Implementation Guide

## Overview

The LinkedIn Conversions API (CAPI) enables server-side event tracking for improved measurement accuracy, especially in light of browser privacy changes.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      EVENT TRACKING FLOW                         │
└─────────────────────────────────────────────────────────────────┘

    User Action                    Server                    LinkedIn
        │                            │                          │
        │   Browser Event            │                          │
        │──────────────────────────► │                          │
        │   (Insight Tag)            │                          │
        │                            │                          │
        │   ◄──────────────────────► │   Server Event (CAPI)    │
        │   (Deduplication)          │──────────────────────────►│
        │                            │                          │
        │                            │                          │
        │   ════════════════════════════════════════════════════│
        │           Both events deduplicated at LinkedIn        │
        │   ════════════════════════════════════════════════════│
```

## Prerequisites

### 1. LinkedIn Assets
- LinkedIn Ads Account
- Insight Tag installed (for deduplication)
- Partner ID (from LinkedIn)
- Access Token with Marketing API access

### 2. Technical Requirements
- Server-side capability (Node.js, Python, etc.)
- SSL/HTTPS endpoint
- User data collection consent

## API Endpoint

```
POST https://api.linkedin.com/rest/conversionEvents
```

### Headers
```
Authorization: Bearer {access_token}
Content-Type: application/json
LinkedIn-Version: 202401
X-Restli-Protocol-Version: 2.0.0
```

## Event Structure

### Standard Event Payload
```json
{
  "conversion": "urn:li:lyndaConversion:(urn:li:sponsoredAccount:{account_id},{conversion_id})",
  "conversionHappenedAt": 1705881600000,
  "conversionValue": {
    "amount": "99.99",
    "currencyCode": "USD"
  },
  "eventId": "event_unique_id_12345",
  "user": {
    "userIds": [
      {
        "idType": "SHA256_EMAIL",
        "idValue": "hashed_email_here"
      }
    ],
    "userInfo": {
      "firstName": "John",
      "lastName": "Doe",
      "companyName": "Acme Corp",
      "title": "Marketing Manager",
      "countryCode": "US"
    }
  }
}
```

## Supported Events

| Event Type | Use Case |
|------------|----------|
| LEAD | Form submissions, sign-ups |
| PURCHASE | Completed transactions |
| ADD_TO_CART | Shopping cart additions |
| SIGN_UP | Account registrations |
| KEY_PAGE_VIEW | Important page visits |
| DOWNLOAD | Asset downloads |
| INSTALL | App installations |
| CUSTOM | Any custom conversion |

## User Matching Parameters

### Required (at least one)
| Parameter | Format | Example |
|-----------|--------|---------|
| SHA256_EMAIL | SHA256 hash | `sha256(lowercase(trim(email)))` |
| SHA256_PHONE | SHA256 hash | `sha256(+1XXXXXXXXXX)` |
| LINKEDIN_FIRST_PARTY_ADS_TRACKING_UUID | LinkedIn cookie | From `li_fat_id` cookie |

### Optional (improves match rate)
| Parameter | Description |
|-----------|-------------|
| firstName | User's first name |
| lastName | User's last name |
| title | Job title |
| companyName | Company name |
| countryCode | ISO country code |

## Implementation Steps

### Step 1: Set Up Conversion
1. Go to LinkedIn Campaign Manager
2. Navigate to Analyze → Conversion Tracking
3. Create new conversion
4. Note the Conversion ID and Partner ID

### Step 2: Hash User Data
```python
import hashlib

def hash_sha256(value):
    """Hash value for LinkedIn CAPI."""
    if not value:
        return None
    # Normalize: lowercase and trim
    normalized = value.lower().strip()
    # SHA256 hash
    return hashlib.sha256(normalized.encode()).hexdigest()

# Usage
hashed_email = hash_sha256("user@example.com")
```

### Step 3: Send Event
```python
import requests
import time

def send_linkedin_event(access_token, account_id, conversion_id, event_data):
    """Send conversion event to LinkedIn CAPI."""
    url = "https://api.linkedin.com/rest/conversionEvents"

    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json",
        "LinkedIn-Version": "202401",
        "X-Restli-Protocol-Version": "2.0.0"
    }

    payload = {
        "conversion": f"urn:li:lyndaConversion:(urn:li:sponsoredAccount:{account_id},{conversion_id})",
        "conversionHappenedAt": int(time.time() * 1000),
        "eventId": event_data.get("event_id"),
        "user": {
            "userIds": [
                {
                    "idType": "SHA256_EMAIL",
                    "idValue": hash_sha256(event_data.get("email"))
                }
            ]
        }
    }

    if event_data.get("value"):
        payload["conversionValue"] = {
            "amount": str(event_data["value"]),
            "currencyCode": event_data.get("currency", "USD")
        }

    response = requests.post(url, headers=headers, json=payload)
    return response.json()
```

### Step 4: Implement Deduplication

Use the same `eventId` for both browser and server events:

```javascript
// Browser (Insight Tag)
window.lintrk('track', {
  conversion_id: 12345,
  event_id: 'unique_event_id_12345'
});
```

```python
# Server (CAPI)
payload = {
    "eventId": "unique_event_id_12345",  # Same ID!
    # ... rest of payload
}
```

## Validation

### Test Event
```bash
curl -X POST 'https://api.linkedin.com/rest/conversionEvents' \
  -H 'Authorization: Bearer {access_token}' \
  -H 'Content-Type: application/json' \
  -H 'LinkedIn-Version: 202401' \
  -H 'X-Restli-Protocol-Version: 2.0.0' \
  -d '{
    "conversion": "urn:li:lyndaConversion:(urn:li:sponsoredAccount:{account_id},{conversion_id})",
    "conversionHappenedAt": '$(date +%s)000',
    "eventId": "test_event_'$(date +%s)'",
    "user": {
      "userIds": [{
        "idType": "SHA256_EMAIL",
        "idValue": "test_hash_value"
      }]
    }
  }'
```

### Success Response
```json
{
  "status": "ACCEPTED"
}
```

### Error Response
```json
{
  "status": "FAILED",
  "message": "Invalid conversion URN"
}
```

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| 401 Unauthorized | Invalid token | Refresh access token |
| 400 Bad Request | Malformed payload | Check JSON structure |
| No conversions appearing | Wrong conversion ID | Verify conversion URN |
| Low match rate | Insufficient user data | Add more user identifiers |
| Duplicate events | Missing event_id | Ensure unique eventId |
