# Wonder Project - GTM Deployment Plan

**Container**: GTM-KV4V3H8W
**Website**: https://joinwonderproject.com
**Date**: 2026-02-04

---

## Prerequisites

Before starting, you need:
- [ ] GA4 Measurement ID (format: `G-XXXXXXXXXX`)
- [ ] GTM MCP server configured (already in `.mcp.json`)

---

## Phase 1: Foundation (Critical)

### 1.1 Enable Built-in Variables

Enable these in GTM → Variables → Configure:

**Clicks**
- [x] Click Element
- [x] Click Classes
- [x] Click ID
- [x] Click Text
- [x] Click URL

**Forms**
- [x] Form Element
- [x] Form Classes
- [x] Form ID

**Videos**
- [x] Video Provider
- [x] Video Title
- [x] Video Status
- [x] Video Percent
- [x] Video Duration
- [x] Video Current Time

**Scrolling**
- [x] Scroll Depth Threshold
- [x] Scroll Depth Units
- [x] Scroll Direction

**Pages**
- [x] Page URL
- [x] Page Path
- [x] Page Hostname
- [x] Page Title

---

### 1.2 Create Variables

| Variable Name | Type | Value |
|---------------|------|-------|
| `Const - GA4 Measurement ID` | Constant | `G-XXXXXXXXXX` |

---

### 1.3 Create Triggers

| # | Trigger Name | Type | Condition |
|---|--------------|------|----------|
| 1 | `All Pages` | Page View | All Pages |
| 2 | `Click - Free Trial CTA` | Click - All Elements | CSS Selector: `[data-testid="button-header-trial"], [data-testid="button-sticky-cta"]` |
| 3 | `Click - Plan Selection` | Click - All Elements | CSS Selector: `[data-testid="button-pricing-monthly"], [data-testid="button-pricing-trial"]` |
| 4 | `Click - Email Submit` | Click - All Elements | CSS Selector: `[data-testid="button-email-submit"]` |
| 5 | `Click - Outbound Amazon` | Click - Just Links | Click URL contains `amazon.com` |
| 6 | `YouTube Video` | YouTube Video | All Videos (Start, Progress 25/50/75, Complete) |
| 7 | `Scroll Depth` | Scroll Depth | Vertical, Percentages: 25, 50, 75, 90 |

---

### 1.4 Create Tags

| # | Tag Name | Type | Trigger | Parameters |
|---|----------|------|---------|-------------|
| 1 | `GA4 - Configuration` | Google Tag | All Pages | Measurement ID: `{{Const - GA4 Measurement ID}}` |
| 2 | `GA4 - Free Trial Click` | GA4 Event | Click - Free Trial CTA | Event: `free_trial_click`, button_location: `{{Click Element}}` |
| 3 | `GA4 - Plan Selection` | GA4 Event | Click - Plan Selection | Event: `select_plan`, plan_type: based on testid |
| 4 | `GA4 - Email Signup` | GA4 Event | Click - Email Submit | Event: `generate_lead`, form_name: `email_newsletter` |
| 5 | `GA4 - Outbound Click` | GA4 Event | Click - Outbound Amazon | Event: `outbound_click`, link_url: `{{Click URL}}` |
| 6 | `GA4 - Video Engagement` | GA4 Event | YouTube Video | Event: `video_{{Video Status}}`, video_percent: `{{Video Percent}}` |
| 7 | `GA4 - Scroll Depth` | GA4 Event | Scroll Depth | Event: `scroll`, percent_scrolled: `{{Scroll Depth Threshold}}` |

---

## Phase 2: Execution Commands

When you open Claude Code in the wonder-project-gtm directory, run:

```
/gtm-AI Deploy the tracking plan from PLANNING/GTM-DEPLOYMENT-PLAN.md to container GTM-KV4V3H8W
```

Or step by step:

```
/gtm-AI Create GA4 Configuration tag with Measurement ID G-XXXXXXXXXX in GTM-KV4V3H8W
/gtm-AI Create scroll depth trigger (25, 50, 75, 90%) in GTM-KV4V3H8W
/gtm-AI Create YouTube video trigger in GTM-KV4V3H8W
/gtm-AI Create click trigger for [data-testid="button-header-trial"] in GTM-KV4V3H8W
```

---

## Phase 3: Verification

After deployment:

1. **GTM Preview Mode**: Test each trigger fires correctly
2. **GA4 DebugView**: Verify events appear in real-time
3. **Publish**: Create version and publish to live

---

## Key Data Attributes on Site

| Element | data-testid | Purpose |
|---------|-------------|----------|
| Header CTA | `button-header-trial` | Free trial signup (header) |
| Sticky CTA | `button-sticky-cta` | Free trial signup (sticky bar) |
| Monthly Plan | `button-pricing-monthly` | $4.99/month selection |
| Annual Plan | `button-pricing-trial` | $49.99/year selection |
| Email Submit | `button-email-submit` | Newsletter signup |
| Praise Dots | `button-praise-dot-X` | Testimonial carousel navigation |

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                 WONDER PROJECT GTM SETUP                     │
│                    GTM-KV4V3H8W                              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  TRIGGERS                        TAGS                        │
│  ─────────                       ────                        │
│                                                              │
│  ┌─────────────────┐            ┌─────────────────────────┐ │
│  │ All Pages       │───────────►│ GA4 - Configuration     │ │
│  └─────────────────┘            └─────────────────────────┘ │
│                                                              │
│  ┌─────────────────┐            ┌─────────────────────────┐ │
│  │ Free Trial CTA  │───────────►│ GA4 - Free Trial Click  │ │
│  │ Click           │            │ event: free_trial_click │ │
│  └─────────────────┘            └─────────────────────────┘ │
│                                                              │
│  ┌─────────────────┐            ┌─────────────────────────┐ │
│  │ Plan Selection  │───────────►│ GA4 - Plan Selection    │ │
│  │ Click           │            │ event: select_plan      │ │
│  └─────────────────┘            └─────────────────────────┘ │
│                                                              │
│  ┌─────────────────┐            ┌─────────────────────────┐ │
│  │ Email Submit    │───────────►│ GA4 - Email Signup      │ │
│  │ Click           │            │ event: generate_lead    │ │
│  └─────────────────┘            └─────────────────────────┘ │
│                                                              │
│  ┌─────────────────┐            ┌─────────────────────────┐ │
│  │ Outbound Amazon │───────────►│ GA4 - Outbound Click    │ │
│  │ Link Click      │            │ event: outbound_click   │ │
│  └─────────────────┘            └─────────────────────────┘ │
│                                                              │
│  ┌─────────────────┐            ┌─────────────────────────┐ │
│  │ YouTube Video   │───────────►│ GA4 - Video Engagement  │ │
│  │ (start/progress)│            │ event: video_*          │ │
│  └─────────────────┘            └─────────────────────────┘ │
│                                                              │
│  ┌─────────────────┐            ┌─────────────────────────┐ │
│  │ Scroll Depth    │───────────►│ GA4 - Scroll Depth      │ │
│  │ 25/50/75/90%    │            │ event: scroll           │ │
│  └─────────────────┘            └─────────────────────────┘ │
│                                                              │
│  VARIABLES                                                   │
│  ─────────                                                   │
│  • Const - GA4 Measurement ID                               │
│  • Built-in: Click Element, Click URL, Click Text           │
│  • Built-in: Video Status, Video Percent, Video Title       │
│  • Built-in: Scroll Depth Threshold                         │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Event Summary

| Event Name | Trigger | Priority |
|------------|---------|----------|
| `page_view` | All Pages (automatic with GA4 Config) | Critical |
| `free_trial_click` | Header/Sticky CTA clicks | Critical |
| `select_plan` | Monthly/Annual plan clicks | Critical |
| `generate_lead` | Email form submit | High |
| `outbound_click` | Amazon links | High |
| `video_start/progress/complete` | YouTube engagement | Medium |
| `scroll` | 25/50/75/90% scroll | Medium |

---

*Execute this plan in Claude Code with `/gtm-AI` skill*