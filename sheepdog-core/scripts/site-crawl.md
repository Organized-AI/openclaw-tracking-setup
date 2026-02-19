# Site Crawling for Tracking Analysis

Instructions for crawling a website to identify trackable user actions and conversion points.

## Overview

Site crawling helps identify:

- Buttons and CTAs
- Forms and inputs
- Videos and media
- Navigation patterns
- User interaction opportunities
- Conversion points

## Using the Site Crawler

```bash
node browser-automation/site-crawler.js --url "https://example.com" --depth 2
```

## Configuration

- `--url`: Starting URL to crawl
- `--depth`: How deep to crawl (default: 1)
- `--output`: Output file for results (default: output.json)
- `--headless`: Run in headless mode (default: true)
- `--wait`: Wait time for page load (default: 3000ms)

## Output Format

The crawler generates a JSON report containing:

```json
{
  "url": "https://example.com",
  "title": "Page Title",
  "buttons": [...],
  "forms": [...],
  "videos": [...],
  "links": [...],
  "images": [...]
}
```

## Analyzing Results

1. Review the generated JSON report
2. Identify key interactive elements
3. Map to conversion events
4. Create tracking plan based on findings
