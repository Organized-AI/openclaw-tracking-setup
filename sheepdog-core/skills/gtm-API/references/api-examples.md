# GTM API Examples

Practical code examples for using the Google Tag Manager API.

## Authentication

### Using OAuth 2.0

```javascript
const {google} = require('googleapis');

const tagmanager = google.tagmanager({
  version: 'v2',
  auth: oauth2Client
});
```

### Service Account

```javascript
const auth = new google.auth.GoogleAuth({
  keyFile: './service-account-key.json',
  scopes: ['https://www.googleapis.com/auth/tagmanager']
});
```

## List Tags

```javascript
const response = await tagmanager.accounts.containers.workspaces.tags.list({
  parent: 'accounts/ACCOUNT_ID/containers/CONTAINER_ID/workspaces/WORKSPACE_ID'
});

console.log(response.data.tag);
```

## Create Tag

```javascript
const tag = {
  name: 'GA4 - Page View',
  type: 'gaawe',
  firingTriggerId: ['trigger_123'],
  parameter: [
    {
      type: 'template',
      key: 'measurementId',
      value: 'G-XXXXXXXXXX'
    },
    {
      type: 'template',
      key: 'eventName',
      value: 'page_view'
    }
  ]
};

const response = await tagmanager.accounts.containers.workspaces.tags.create({
  parent: 'accounts/ACCOUNT_ID/containers/CONTAINER_ID/workspaces/WORKSPACE_ID',
  requestBody: tag
});
```

## Update Tag

```javascript
const response = await tagmanager.accounts.containers.workspaces.tags.update({
  path: 'accounts/ACCOUNT_ID/containers/CONTAINER_ID/workspaces/WORKSPACE_ID/tags/TAG_ID',
  requestBody: updatedTag
});
```

## Delete Tag

```javascript
await tagmanager.accounts.containers.workspaces.tags.delete({
  path: 'accounts/ACCOUNT_ID/containers/CONTAINER_ID/workspaces/WORKSPACE_ID/tags/TAG_ID'
});
```
