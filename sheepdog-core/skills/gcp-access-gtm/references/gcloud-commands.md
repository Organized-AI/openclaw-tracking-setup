# GCloud Commands Reference

Common gcloud commands for Google Cloud Platform access and GTM integration.

## Authentication

```bash
# Login to GCP
gcloud auth login

# Set active project
gcloud config set project PROJECT_ID

# Get current auth status
gcloud auth list

# Create service account
gcloud iam service-accounts create gtm-service-account \
  --display-name="GTM Service Account"
```

## API Management

```bash
# Enable Tag Manager API
gcloud services enable tagmanager.googleapis.com

# List enabled services
gcloud services list --enabled

# Disable a service
gcloud services disable SERVICE_NAME
```

## Service Account Keys

```bash
# Create a key for service account
gcloud iam service-accounts keys create key.json \
  --iam-account=gtm-service-account@PROJECT_ID.iam.gserviceaccount.com

# List keys
gcloud iam service-accounts keys list \
  --iam-account=SERVICE_ACCOUNT_EMAIL

# Delete a key
gcloud iam service-accounts keys delete KEY_ID \
  --iam-account=SERVICE_ACCOUNT_EMAIL
```

## IAM Roles

```bash
# Grant role to service account
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:SERVICE_ACCOUNT_EMAIL \
  --role=roles/tagmanager.admin

# View policy bindings
gcloud projects get-iam-policy PROJECT_ID
```
