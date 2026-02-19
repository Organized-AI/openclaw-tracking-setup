# Organized Codebase Template Structure

## Standard Directory Layout

```
project-root/
├── .github/
│   ├── workflows/
│   │   ├── ci.yml
│   │   └── deploy.yml
│   └── CODEOWNERS
├── docs/
│   ├── architecture/
│   ├── api/
│   └── guides/
├── src/
│   ├── components/
│   ├── services/
│   ├── utils/
│   └── index.ts
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── scripts/
│   ├── setup.sh
│   └── deploy.sh
├── config/
│   ├── default.json
│   └── production.json
├── .gitignore
├── package.json
├── tsconfig.json
├── README.md
└── LICENSE
```

## Directory Purposes

| Directory | Purpose | Contents |
|-----------|---------|----------|
| `.github/` | GitHub configuration | Workflows, issue templates, CODEOWNERS |
| `docs/` | Documentation | Architecture docs, API refs, guides |
| `src/` | Source code | Application code organized by feature |
| `tests/` | Test files | Unit, integration, and e2e tests |
| `scripts/` | Utility scripts | Build, deploy, setup scripts |
| `config/` | Configuration | Environment-specific configs |

## Redundant Patterns to Clean

### Iteration Suffixes (Archive These)
```
❌ project-v1/
❌ project-v2/
❌ project-old/
❌ project-backup/
❌ project-pwa/
❌ project-app/
```

### Legacy Folders (Consolidate)
```
❌ lib/ → src/utils/
❌ helpers/ → src/utils/
❌ models/ → src/types/ or src/models/
❌ views/ → src/components/
```

### Duplicate Configs (Keep One)
```
❌ .eslintrc AND eslint.config.js
❌ webpack.config.js AND vite.config.js
❌ Multiple tsconfig files (consolidate)
```

## Cleanup Decision Matrix

| Pattern | Action | Reason |
|---------|--------|--------|
| `-v[0-9]` suffix | Archive | Version iteration |
| `-old` suffix | Archive | Deprecated version |
| `-backup` suffix | Archive | Manual backup |
| `-pwa` suffix | Merge or Archive | Feature variant |
| `-app` suffix | Merge or Archive | Platform variant |
| `.git` | **NEVER TOUCH** | Version control |
| `node_modules` | Regenerate | Dependencies |
| `.env*` | **PRESERVE** | Configuration |

## Archive Strategy

### Archive Folder Structure
```
_archive/
├── YYYY-MM-DD_reason/
│   ├── original-folder-name/
│   └── ARCHIVE_NOTES.md
```

### Archive Notes Template
```markdown
# Archive Notes

**Date**: YYYY-MM-DD
**Original Location**: /path/to/folder
**Reason**: [Version iteration / Deprecated / Superseded]
**Dependencies**: [Any other projects depending on this]
**Restore Instructions**: [How to restore if needed]
```

## Gitignore Merge Strategy

### Keep from existing:
- Project-specific patterns
- IDE configurations
- Local environment files

### Add from template:
- Standard language ignores
- Build artifacts
- Dependency directories

### Deduplication:
```bash
# Sort and remove duplicates
sort -u .gitignore > .gitignore.tmp && mv .gitignore.tmp .gitignore
```

## Safety Protocols

### Pre-Cleanup Checklist
- [ ] Git repository clean (no uncommitted changes)
- [ ] Recent backup exists
- [ ] All team members notified
- [ ] CI/CD pipelines paused

### Never Delete
- `.git/` directory
- `.env` files (unless explicitly requested)
- `node_modules/` (regenerate instead)
- Any file with uncommitted changes

### Always Confirm
- Folders larger than 100MB
- Folders with recent modifications (< 7 days)
- Folders referenced in package.json or configs

## Application Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│              ORGANIZED CODEBASE APPLICATION                      │
└─────────────────────────────────────────────────────────────────┘

    Phase 1: ANALYSIS
    ─────────────────
    • Scan current structure
    • Identify redundant patterns
    • Calculate folder sizes
    • Check for dependencies
              │
              ▼
    Phase 2: CLEANUP (with confirmation)
    ────────────────────────────────────
    • Archive iteration folders
    • Consolidate duplicates
    • Merge gitignore entries
              │
              ▼
    Phase 3: TEMPLATE APPLICATION
    ─────────────────────────────
    • Create missing directories
    • Add standard configs
    • Update README structure
              │
              ▼
    Phase 4: FINALIZATION
    ─────────────────────
    • Run linters
    • Verify builds
    • Commit changes
```
