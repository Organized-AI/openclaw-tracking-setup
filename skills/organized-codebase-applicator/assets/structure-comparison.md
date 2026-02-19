# Structure Comparison Diagrams

## Before vs After

### Before (Messy)
```
project/
├── project-v1/          ❌ Iteration folder
├── project-v2/          ❌ Iteration folder
├── project-old/         ❌ Deprecated
├── app/
│   ├── components/
│   ├── views/           ❌ Should be in components
│   └── helpers/         ❌ Should be utils
├── lib/                 ❌ Should be src/utils
├── test/                ⚠️ Inconsistent naming
├── spec/                ⚠️ Duplicate test folder
├── .eslintrc            ⚠️ Old format
├── .eslintrc.json       ⚠️ Duplicate
├── eslint.config.js     ⚠️ Duplicate
├── webpack.config.js    ⚠️ May conflict
├── vite.config.js       ⚠️ May conflict
└── tsconfig.json
```

### After (Organized)
```
project/
├── _archive/
│   └── 2024-01-15_cleanup/
│       ├── project-v1/
│       ├── project-v2/
│       └── project-old/
├── .github/
│   └── workflows/
├── src/
│   ├── components/      ✅ Views merged here
│   ├── services/
│   └── utils/           ✅ lib + helpers merged
├── tests/               ✅ Consolidated
│   ├── unit/
│   └── integration/
├── docs/
├── scripts/
├── config/
├── eslint.config.js     ✅ Single config
├── vite.config.js       ✅ Single bundler
├── tsconfig.json
├── .gitignore           ✅ Merged & deduplicated
└── README.md
```

## Cleanup Decision Tree

```
                    Is this folder needed?
                           │
              ┌────────────┴────────────┐
              │                         │
             YES                        NO
              │                         │
              │                    Is it safe
              │                    to remove?
              │                         │
              │              ┌──────────┴──────────┐
              │              │                     │
              │            SAFE               NOT SAFE
              │              │                     │
              │              ▼                     │
              │        ┌──────────┐                │
              │        │ ARCHIVE  │                │
              │        │   to     │                │
              │        │ _archive/│                │
              │        └──────────┘                │
              │                                    │
              └──────────────┬─────────────────────┘
                             │
                             ▼
                        ┌──────────┐
                        │   KEEP   │
                        │  AS IS   │
                        └──────────┘
```

## File Organization Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    FILE ORGANIZATION FLOW                        │
└─────────────────────────────────────────────────────────────────┘

    Scattered Files                     Organized Structure
    ────────────────                    ────────────────────

    /components/Button.tsx    ────►    /src/components/Button.tsx
    /views/Home.tsx          ────►    /src/components/Home.tsx
    /lib/helpers.ts          ────►    /src/utils/helpers.ts
    /helpers/format.ts       ────►    /src/utils/format.ts
    /test/button.test.ts     ────►    /tests/unit/Button.test.ts
    /spec/home.spec.ts       ────►    /tests/unit/Home.test.ts
    /docs.md                 ────►    /docs/README.md
    /setup.sh                ────►    /scripts/setup.sh
```

## Confidence Levels

```
┌─────────────────────────────────────────────────────────────────┐
│               CLEANUP CONFIDENCE LEVELS                          │
└─────────────────────────────────────────────────────────────────┘

    HIGH CONFIDENCE (Auto-clean)
    ────────────────────────────
    ✅ Matches known iteration pattern (-v1, -v2, -old)
    ✅ Empty directories
    ✅ .DS_Store, Thumbs.db
    ✅ node_modules (regenerate)

    MEDIUM CONFIDENCE (Confirm)
    ───────────────────────────
    ⚠️ Large folders (>100MB)
    ⚠️ Modified in last 7 days
    ⚠️ Contains unique files
    ⚠️ Referenced in configs

    LOW CONFIDENCE (Manual Review)
    ──────────────────────────────
    ❌ .git directory
    ❌ .env files
    ❌ Custom directories
    ❌ Production data
```

## Progress Indicator

```
    CLEANUP PROGRESS
    ════════════════

    Phase 1: Analysis
    [████████████████████] 100%

    Phase 2: Cleanup
    [████████░░░░░░░░░░░░] 40%
    └── Archiving: project-v1/ → _archive/

    Phase 3: Template
    [░░░░░░░░░░░░░░░░░░░░] 0%

    Phase 4: Finalize
    [░░░░░░░░░░░░░░░░░░░░] 0%
```
