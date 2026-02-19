# OAuth Consent Screen Setup

Guide for configuring OAuth consent screen for GTM integration.

## Steps

1. **Go to Google Cloud Console**
   - https://console.cloud.google.com
   - Select your project

2. **Navigate to APIs & Services**
   - Click APIs & Services
   - Select OAuth consent screen

3. **Configure Consent Screen**
   - Select User Type: "External"
   - Click Create

4. **Fill in App Information**
   - App name: "GTM CLI Tool"
   - User support email: your-email@example.com
   - Developer contact: your-email@example.com

5. **Add Scopes**
   - Click Add or Remove Scopes
   - Add: https://www.googleapis.com/auth/tagmanager
   - Add: https://www.googleapis.com/auth/cloud-platform

6. **Add Test Users**
   - Add your Google account email
   - This allows development before publishing

7. **Create OAuth Credentials**
   - Go to Credentials
   - Click Create Credentials
   - Select OAuth 2.0 Client ID
   - Choose Desktop Application
   - Download the JSON file

## Environment Setup

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/credentials.json"
```
