# Portfolio Meta Folder Migration Package

**Version:** 1.0  
**Date:** 2025-10-30  
**Status:** ⚠️ READY FOR EXECUTION - Review Required

---

## ⚠️ IMPORTANT WARNINGS

**STOP! Read This First:**

1. 🔴 **This migration will reorganize `/00-meta` folder structure**
2. 🔴 **Backup and git checkpoint are MANDATORY before starting**
3. 🔴 **Do NOT use the original migration plan - it has data loss risks**
4. 🔴 **Run scripts in order - Phase dependencies exist**
5. 🔴 **Test after each phase - don't proceed if tests fail**

**Estimated Time:** 4-6 hours spread over 6 days (1 hour per day)

**Risk Level:** 🟢 LOW (with these corrected scripts)

---

## What This Migration Does

### Creates
- `01-policies/` - Portfolio-wide policies
- `02-governance/` - Standards, decision records (ADR, ODR, SDR, PDR)
- Numbered prefixes for all meta folders (00-90)
- Organized template structure with type separation
- Navigation junctions for convenience

### Moves
- Standards from `documentation/` → `02-governance/standards/`
- Templates from `shared-resources/` → `40-templates/` (by type)
- Old standard versions → `90-legacy-meta/documentation/archive/`

### Renames
- `architecture/` → `10-architecture/`
- `automation/` → `30-automation/`
- `templates/` → `40-templates/`
- `schemas/` → `50-schemas/`
- `shared-resources/` → `60-shared-resources/`
- `meta-projects/` → `21-meta-projects/`
- `ideas-inbox/` → `22-ideas-inbox/`
- `legacy-meta/` → `90-legacy-meta/`

### Preserves
- ✅ All domain structures (10-personal, 20-family, 30-community, 40-business)
- ✅ All project files and content
- ✅ Git history
- ✅ automation/governance scripts (stay in automation)

---

## Prerequisites

### Before You Start

- [ ] **Close all editors and IDEs** working in `C:\Portfolio`
- [ ] **Close all terminals** with current directory in `C:\Portfolio`
- [ ] **Commit any pending changes** to git
- [ ] **Read the critique document** (`analysis/2025-10-30-critique-...md`)
- [ ] **Verify you have 1-2 hours** of uninterrupted time
- [ ] **Ensure disk space** - At least 2GB free for backups

### System Requirements

- Windows 10/11 (for PowerShell 5.1+ and junction support)
- Git installed and working
- Administrator privileges (optional - for symlinks, junctions work without admin)

---

## Migration Structure

```
migration/
├── README.md                           # This file
├── scripts/
│   ├── Phase0-Discovery.ps1           # Analyze current state
│   ├── Phase1-Governance.ps1          # Create governance structure
│   ├── Phase2-Numbering.ps1           # Apply numbering
│   ├── Phase3-Architecture.ps1        # Organize architecture folder
│   ├── Phase4-Templates.ps1           # Consolidate templates
│   ├── Phase5-Shortcuts.ps1           # (Optional) Create shortcuts
│   ├── Backup-PortfolioMeta.ps1       # Create safety backup
│   ├── Find-PathReferences.ps1        # Find old path references
│   ├── Update-PathReferences.ps1      # Update path references
│   ├── Test-MigrationSuccess.ps1      # Validate migration
│   └── Start-PortfolioMigration.ps1   # Master orchestrator
├── rollback/
│   ├── Rollback-Phase1.ps1
│   ├── Rollback-Phase2.ps1
│   ├── Rollback-Phase3.ps1
│   └── Rollback-Phase4.ps1
└── templates/
    ├── ADR-template.md
    ├── ODR-template.md
    ├── SDR-template.md
    └── PDR-template.md
```

---

## Execution Guide

### Option 1: Automated (Recommended)

Run all phases automatically with validation:

```powershell
cd C:\Portfolio\00-meta\meta-projects\portfolio-project-scaffolding-system\migration\scripts

# Review what will happen
.\Start-PortfolioMigration.ps1 -WhatIf

# Execute all phases
.\Start-PortfolioMigration.ps1 -CreateBackup
```

### Option 2: Manual (Step-by-Step)

Execute each phase individually with testing:

#### Day 1: Preparation (30 minutes)

```powershell
cd C:\Portfolio\00-meta\meta-projects\portfolio-project-scaffolding-system\migration\scripts

# Run discovery
.\Phase0-Discovery.ps1

# Create backup
.\Backup-PortfolioMeta.ps1

# Create git checkpoint
cd C:\Portfolio
git add -A
git commit -m "Pre-migration: Portfolio meta restructure"
git tag "pre-meta-migration-$(Get-Date -Format 'yyyyMMdd')"
```

#### Day 2: Phase 1 - Governance (1 hour)

```powershell
# Execute Phase 1
.\Phase1-Governance.ps1

# Test
.\Test-MigrationSuccess.ps1 -Phase 1

# Commit if successful
cd C:\Portfolio
git add -A
git commit -m "Phase 1 complete: Governance structure"
```

#### Day 3: Phase 2 - Numbering (30 minutes)

```powershell
# Execute Phase 2
.\Phase2-Numbering.ps1

# Test
.\Test-MigrationSuccess.ps1 -Phase 2

# Commit if successful
cd C:\Portfolio
git add -A
git commit -m "Phase 2 complete: Numbered meta folders"
```

#### Day 4: Phase 3 - Architecture (30 minutes)

```powershell
# Execute Phase 3
.\Phase3-Architecture.ps1

# Test
.\Test-MigrationSuccess.ps1 -Phase 3

# Commit if successful
cd C:\Portfolio
git add -A
git commit -m "Phase 3 complete: Architecture organization"
```

#### Day 5: Phase 4 - Templates (1 hour)

```powershell
# Execute Phase 4
.\Phase4-Templates.ps1

# Test
.\Test-MigrationSuccess.ps1 -Phase 4

# Commit if successful
cd C:\Portfolio
git add -A
git commit -m "Phase 4 complete: Template consolidation"
```

#### Day 6: Post-Migration (1 hour)

```powershell
# Find and update path references
.\Find-PathReferences.ps1 -Export

# Review the CSV, then update
.\Update-PathReferences.ps1 -Execute

# Run comprehensive tests
.\Test-MigrationSuccess.ps1 -Comprehensive

# Final commit
cd C:\Portfolio
git add -A
git commit -m "Migration complete: Portfolio meta restructure"
git tag "post-meta-migration-$(Get-Date -Format 'yyyyMMdd')"
```

---

## If Something Goes Wrong

### Immediate Actions

1. **STOP** - Don't continue
2. **Don't panic** - Everything is backed up
3. **Assess** - What failed? Check error messages
4. **Choose recovery option** below

### Recovery Options

#### Option 1: Git Rollback (Fastest)

```powershell
cd C:\Portfolio

# See available checkpoints
git tag | Select-String "meta-migration"

# Rollback to before migration
git reset --hard pre-meta-migration-YYYYMMDD

# Or rollback one phase
git reset --hard HEAD~1
```

#### Option 2: Phase-Specific Rollback

```powershell
cd C:\Portfolio\00-meta\meta-projects\portfolio-project-scaffolding-system\migration\rollback

# Rollback specific phase
.\Rollback-Phase1.ps1  # Or Phase2, Phase3, Phase4
```

#### Option 3: Full Restore from Backup

```powershell
# Your backup location was recorded by Backup-PortfolioMeta.ps1
$backupPath = "C:\Portfolio-Backups\00-meta-backup-YYYYMMDD-HHMMSS"

# Remove current (potentially corrupted) meta folder
Remove-Item C:\Portfolio\00-meta -Recurse -Force

# Restore from backup
Copy-Item $backupPath C:\Portfolio\00-meta -Recurse

# Verify
Test-Path C:\Portfolio\00-meta\architecture
```

---

## Success Criteria

Migration is complete when all tests pass:

```powershell
.\Test-MigrationSuccess.ps1 -Comprehensive
```

### Checklist

- [ ] All 8 meta folders numbered consistently (00, 10, 20, 21, 22, 30, 40, 50, 60, 90)
- [ ] Governance structure exists (01-policies, 02-governance with ADR/ODR/SDR/PDR)
- [ ] 0 broken markdown links
- [ ] 0 references to old paths (00-meta/01-policies, etc.)
- [ ] Templates consolidated with proper subfolders
- [ ] Standards in 02-governance/standards/
- [ ] Old versions archived to 90-legacy-meta/
- [ ] Navigation junctions work (optional)
- [ ] All domain structures unchanged
- [ ] automation/governance scripts still in place

---

## Phase Details

### Phase 0: Discovery (Read-Only)

**Purpose:** Analyze current state, identify potential issues

**What it does:**
- Scans current folder structure
- Identifies files to be moved
- Checks for conflicts
- Validates prerequisites
- Generates discovery report

**Output:** `00-meta/.migration-discovery-report.txt`

**Safe:** ✅ Read-only, no changes made

---

### Phase 1: Governance Structure

**Purpose:** Create formal governance without breaking automation

**What it does:**
- Creates 01-policies, 02-governance structure
- Moves CODE-DOCUMENTATION-STANDARDS-V3.md → 02-governance/standards/CODE-DOCUMENTATION-STANDARDS.md
- Moves README-STRATEGY.md → 02-governance/standards/
- Moves README-TEMPLATE.md → templates/document-templates/
- Archives old standard versions to 90-legacy-meta/
- Creates ADR template and first ADR inline
- **Does NOT move automation/governance** (keeps enforcement scripts in automation)

**Key Correction:** automation/governance stays in automation (renamed in Phase 2)

**Duration:** 30-60 minutes

---

### Phase 2: Numbering

**Purpose:** Apply consistent numbering to all meta folders

**What it does:**
- Renames 8 folders with numbered prefixes
- Renames automation/documentation → 30-automation/docs
- Creates 30-automation/scripts/documentation/ for future use
- Updates internal references

**Key Correction:** Clear naming (docs vs scripts/documentation)

**Duration:** 15-30 minutes

**Warning:** ⚠️ This phase affects many paths. Commit before and after.

---

### Phase 3: Architecture Organization

**Purpose:** Organize architecture folder, create navigation links

**What it does:**
- Creates migration-plans/, analysis/, data-architecture/ subfolders
- Moves migration-plan*.* to migration-plans/
- Moves *-analysis.md to analysis/
- Creates junction: 10-architecture/adr → 02-governance/decision-records/ADR

**Key Correction:** Uses junctions (no admin) instead of symlinks

**Duration:** 15-30 minutes

---

### Phase 4: Template Consolidation

**Purpose:** Organize templates by type

**What it does:**
- Creates subfolders: document-templates, file-templates, ai-prompts, architecture-templates, github-templates
- Moves templates from shared-resources/ to appropriate subfolders
- **Manually reviews** project-templates vs project-boilerplates conflict
- Consolidates all template types

**Key Correction:** Different types → different subfolders (not forced into document-templates)

**Duration:** 30-60 minutes

**Manual Step:** Review project-templates conflict before finalizing

---

### Phase 5: Shortcuts (Optional)

**Purpose:** Create navigation shortcuts to domain resources

**Status:** OPTIONAL - Skip unless needed

**Recommendation:** Use README references instead

---

## Troubleshooting

### Common Issues

#### "Access Denied" Errors

**Cause:** File/folder in use or permissions issue

**Solution:**
```powershell
# Close all apps using Portfolio folder
# Check what's using it
Get-Process | Where-Object {$_.Path -like "*Portfolio*"}

# Kill if needed (save work first!)
Stop-Process -Name "Code" -Force  # VS Code
Stop-Process -Name "pwsh" -Force  # Other terminals
```

#### "Path Not Found" Errors

**Cause:** Phase prerequisites not met

**Solution:**
```powershell
# Check which phase completed
Get-Content C:\Portfolio\00-meta\.migration-progress.json | ConvertFrom-Json

# Run missing prerequisite phase first
```

#### "Junction Creation Failed"

**Cause:** Target doesn't exist or path too long

**Solution:**
```powershell
# Verify target exists
Test-Path "C:\Portfolio\00-meta\02-governance\decision-records\ADR"

# If not, run Phase 1 first
.\Phase1-Governance.ps1
```

#### Path References Not Updated

**Cause:** Update-PathReferences needs review

**Solution:**
```powershell
# Find all references
.\Find-PathReferences.ps1 -Export

# Review CSV
Import-Csv "C:\Portfolio\00-meta\path-references-to-update.csv" | Out-GridView

# Update manually or run with -Execute
.\Update-PathReferences.ps1 -Execute -Confirm
```

---

## Post-Migration Tasks

### Immediate (Day 6)

- [ ] Run comprehensive tests
- [ ] Update all path references
- [ ] Create completion ADR documenting lessons learned
- [ ] Update README.md files to reflect new structure
- [ ] Test automation scripts still work
- [ ] Test AI agents can navigate new structure

### Week 2

- [ ] Monitor for broken links in daily use
- [ ] Update any external documentation
- [ ] Create operational runbook for new structure
- [ ] Train team (if applicable) on new locations

### Month 2

- [ ] Review if Phase 5 (shortcuts) needed based on usage
- [ ] Implement documentation generation automation
- [ ] Archive old backup (if migration stable)
- [ ] Remove .migration-progress.json

---

## FAQs

**Q: Can I run this on a subset for testing?**
A: Not easily. The structure is interdependent. Better to backup and test on full structure.

**Q: What if I've customized my 00-meta?**
A: Discovery script will identify conflicts. Review before proceeding.

**Q: Can I skip phases?**
A: No. Phases have dependencies. Run in order or use git checkpoints.

**Q: How long does rollback take?**
A: Git rollback: 10 seconds. Backup restore: 1-2 minutes.

**Q: Will this affect my domain folders?**
A: No. 10-personal, 20-family, 30-community, 40-business are untouched.

**Q: What about automation scripts?**
A: They're renamed (automation → 30-automation) but content unchanged.

**Q: Do I need admin privileges?**
A: No. Junctions work without admin. Only needed for symlinks (not used).

---

## Related Documentation

- [Critique Document](../analysis/2025-10-30-critique-of-2025-10-30-as-is-portfolio-structure-analysis.md) - Full analysis of issues and corrections
- [Original Analysis](../analysis/2025-10-30-as-is-portfolio-structure-analysis.md) - Original migration plan (DO NOT USE)
- [Portfolio Vision](/00-meta/00-strategy/chris-portfolio-vision.md) - Why this structure
- [Solution Design](/00-meta/10-architecture/chris-portfolio-solution-design.md) - Technical architecture

---

## Support

**Issues During Migration:**
1. Stop execution
2. Check error messages
3. Review troubleshooting section above
4. Consider rollback if uncertain
5. Document issue for future reference

**After Migration:**
- Create ADR if significant issues encountered
- Update this README with lessons learned
- Contribute improvements to scripts

---

**Last Updated:** 2025-10-30  
**Migration Package Version:** 1.0  
**Status:** ✅ Ready for Execution

**Good luck! The scripts are designed to be safe and reversible. 🚀**
