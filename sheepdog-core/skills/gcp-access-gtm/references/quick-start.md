# GCP GTM Quick Start

Quick reference for getting started with GCP and GTM integration.

## Prerequisites

- Google Cloud Account
- gcloud CLI installed
- Google Tag Manager account

## Quick Setup

### 1. Install gcloud CLI

```bash
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
gcloud init
```

### 2. Create GCP Project

```bash
gcloud projects create gtm-project --name="GTM Project"
gcloud config set project gtm-project
```

### 3. Enable APIs

```bash
# Enable Tag Manager API
gcloud services enable tagmanager.googleapis.com

# Enable necessary OAuth APIs
gcloud services enable oauth2.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
```

### 4. Create Service Account

```bash
gcloud iam service-accounts create gtm-cli
gcloud projects add-iam-policy-binding gtm-project \
  --member=serviceAccount:gtm-cli@gtm-project.iam.gserviceaccount.com \
  --role=roles/tagmanager.admin
```

### 5. Generate Credentials

```bash
gcloud iam service-accounts keys create gtm-credentials.json \
  --iam-account=gtm-cli@gtm-project.iam.gserviceaccount.com
```

### 6. Configure Environment

```bash
export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/gtm-credentials.json"
```

## Verification

```bash
# List GTM containers
gcloud tag-manager containers list
```
