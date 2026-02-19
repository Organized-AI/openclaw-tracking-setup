# Tidy-GTM Workflow Diagram

## Container Audit Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    START: Container Selection               │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
        ┌────────────────────────────┐
        │  Connect to GTM Container  │
        │   (API Auth + Workspace)   │
        └────────────────┬───────────┘
                         │
                         ▼
     ┌──────────────────────────────────────┐
     │    PHASE 1: DATA COLLECTION          │
     │  - List all tags                     │
     │  - List all triggers                 │
     │  - List all variables                │
     │  - List all templates                │
     │  - List all folders                  │
     └──────────────────┬───────────────────┘
                        │
                        ▼
     ┌──────────────────────────────────────┐
     │    PHASE 2: ANALYSIS                 │
     │  - Identify duplicates               │
     │  - Find orphaned items               │
     │  - Check naming violations           │
     │  - Verify references                 │
     │  - Flag broken configs               │
     └──────────────────┬───────────────────┘
                        │
         ┌──────────────┼──────────────┐
         ▼              ▼              ▼
    ┌─────────┐  ┌──────────┐  ┌─────────────┐
    │Duplicates│  │Orphans   │  │Naming Issues│
    │Found    │  │Found     │  │Found        │
    └─────────┘  └──────────┘  └─────────────┘
         │              │              │
         └──────────────┼──────────────┘
                        │
                        ▼
     ┌──────────────────────────────────────┐
     │    PHASE 3: PRIORITIZATION           │
     │  P1: Broken references               │
     │  P2: Duplicates & Orphans            │
     │  P3: Naming standardization          │
     └──────────────────┬───────────────────┘
                        │
                        ▼
         ┌──────────────────────────┐
         │  Generate Audit Report   │
         │  - Issues by priority    │
         │  - Recommended actions   │
         │  - Fix sequence          │
         └──────────────┬───────────┘
                        │
           ┌────────────┴────────────┐
           │                         │
           ▼                         ▼
    ┌─────────────┐          ┌──────────────┐
    │Audit Only   │          │Execute Fixes │
    │(No changes) │          │(Make changes)│
    └─────────────┘          └──────┬───────┘
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
                    ▼               ▼               ▼
            ┌──────────────┐ ┌──────────┐ ┌─────────────┐
            │Fix Broken    │ │Remove    │ │Standardize  │
            │References    │ │Duplicates│ │Naming       │
            └──────┬───────┘ └────┬─────┘ └──────┬──────┘
                   │              │              │
                   └──────────────┬───────────────┘
                                  │
                                  ▼
                  ┌────────────────────────────┐
                  │  PHASE 4: VERSION CONTROL  │
                  │  - Create backup version   │
                  │  - Preview changes         │
                  │  - Test tracking           │
                  └────────────┬───────────────┘
                               │
                               ▼
                  ┌────────────────────────┐
                  │  Publish Clean Version  │
                  └────────────┬───────────┘
                               │
                               ▼
                  ┌────────────────────────┐
                  │  Generate Final Report  │
                  │  - Changes made         │
                  │  - Items removed        │
                  │  - Issues fixed         │
                  └────────────┬───────────┘
                               │
                               ▼
                  ┌────────────────────────┐
                  │    END: Container Clean │
                  └────────────────────────┘
```

## Issue Resolution Sequence

```
ORDER OF OPERATIONS:

1. CREATE MISSING ITEMS
   └─ Variables needed by tags
   └─ Triggers needed by tags

2. FIX BROKEN REFERENCES
   └─ Update tag references
   └─ Fix trigger conditions
   └─ Fix variable mappings

3. REMOVE DUPLICATES
   └─ Consolidate similar tags
   └─ Merge trigger conditions
   └─ Combine variables

4. REMOVE ORPHANS
   └─ Unused triggers
   └─ Unused variables
   └─ Unused templates

5. STANDARDIZE NAMING
   └─ Rename tags
   └─ Rename triggers
   └─ Rename variables

6. ORGANIZE STRUCTURE
   └─ Create folders
   └─ Organize by type
   └─ Group related items
```
