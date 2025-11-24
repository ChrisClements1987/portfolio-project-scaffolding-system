# PPS Phase 3 Implementation Plan

**Phase:** Enhanced Automation & Lifecycle Support  
**Target:** Automate key portfolio workflows  
**Timeline:** 2-3 weeks (6-9 focused hours)  
**Status:** Ready to execute

---

## Objectives

**Primary Goals:**
1. Automate lifecycle promotions (Concept → Experiment → Project)
2. Automate archiving workflow
3. Create unified health check runner
4. Add data hygiene pre-commit hooks

**Success Criteria:**
- ✅ Complete promotion workflows automated
- ✅ Archiving is one command
- ✅ Single health check command
- ✅ Secrets/PII caught before commit

---

## Work Breakdown

### Task 3.1: Lifecycle Promotions (3-4 hours)

**Files to create/update:**

**3.1.1 Promote-ConceptToExperiment.ps1** (2 hours)
```powershell
# Implements: concept-to-project-promotion.md process
# Does:
- Validates concept readiness (documentation complete)
- Creates experiment project from boilerplate
- Migrates concept assets (research, decisions)
- Updates concept _meta.yaml (status: graduated)
- Moves concept to graduated-concepts/
- Initializes Git repo
```

**3.1.2 Update Promote-IdeaToConcept.ps1** (1 hour)
```powershell
# Current: Working but needs enhancements
# Add:
- Use PortfolioHelpers module
- Create concept _meta.yaml (new requirement)
- Validate against lifecycle-rules.md
- Better error messages using glossary terms
```

**3.1.3 Archive-CompletedProject.ps1** (1 hour)
```powershell
# Implements: archive-and-restoration.md process
# Does:
- Validates project completion (status = completed/cancelled)
- Updates project.yaml with archive metadata
- Moves to {domain}/90-archive/projects/
- Updates cross-references
- Git commits the archival
```

**Deliverable:** 3 working lifecycle automation scripts

---

### Task 3.2: Unified Health Check Runner (2 hours)

**File:** `validation/Invoke-PortfolioHealthChecks.ps1`

**Implementation:**
```powershell
# Runs all health checks and generates unified report
# Checks:
- Test-ReadmeCompliance
- Test-PortfolioMetaCompliance
- Test-Frontmatter
- Test-PathCase
- Custom checks (broken links, missing metadata, etc.)

# Outputs:
- Console summary (pass/fail counts)
- Markdown report to 03-landscape/01-reports/health-checks/
- Exit code (0 = healthy, 1 = issues found)
```

**Features:**
- Run all checks or specific subset
- Severity filtering (critical only, all issues)
- JSON output option (for CI/CD future)
- Time-stamped reports

**Deliverable:** Single command for portfolio health validation

---

### Task 3.3: Data Hygiene Pre-Commit Hook (2-3 hours)

**Files to create:**

**3.3.1 Scan-ForSecrets.ps1** (1 hour)
```powershell
# Implements: data-hygiene-workflows.md#pre-commit-workflow
# Scans staged changes for:
- API keys (sk-proj-, AKIA, ghp_, AIza)
- Email addresses (@gmail, @hotmail, personal domains)
- Phone numbers (regex patterns)
- Hard-coded paths (C:\Users\Chris)
- Common secret patterns

# Exit 1 if secrets found (blocks commit)
```

**3.3.2 Scan-ForPII.ps1** (1 hour)
```powershell
# Implements: data-hygiene-workflows.md#family-privacy
# Scans staged changes for:
- Family member names (configurable list)
- Addresses (Greasley, Nottingham patterns)
- School names
- Personal identifiers

# Exit 1 if PII found (blocks commit with warning)
```

**3.3.3 Install-DataHygieneHooks.ps1** (30 min)
```powershell
# Installs pre-commit hooks
# Hooks run:
1. Scan-ForSecrets (always)
2. Scan-ForPII (optional, configurable)
3. Test-ReadmeCompliance (on README changes)

# Provides bypass: SKIP_HOOKS=1 git commit
```

**Deliverable:** Automated secret/PII detection

---

## Phase 3 Milestones

### Milestone 3.1: Lifecycle Automation (Week 1)
**Target:** Dec 1-7  
**Time:** 4 hours  
**Deliverables:**
- Promote-ConceptToExperiment.ps1
- Updated Promote-IdeaToConcept.ps1
- Archive-CompletedProject.ps1

**Success:** Can promote/archive with single commands

---

### Milestone 3.2: Health & Hygiene (Week 2)
**Target:** Dec 8-14  
**Time:** 4-5 hours  
**Deliverables:**
- Invoke-PortfolioHealthChecks.ps1
- Scan-ForSecrets.ps1
- Scan-ForPII.ps1
- Install-DataHygieneHooks.ps1

**Success:** Unified health checks + pre-commit protection

---

### Milestone 3.3: Testing & Documentation (Week 3)
**Target:** Dec 15-21  
**Time:** 2-3 hours  
**Deliverables:**
- User acceptance testing all scripts
- User guide in 30-resources/
- Updated PPS README
- Smoke tests documented

**Success:** Everything works, documented, ready for daily use

---

## Testing Phase (Built-In)

**Approach:** Test incrementally, not at end

### Per-Script Testing (As We Build)
**After each script:**
1. Dry-run test (verify logic without side effects)
2. Real test with test project
3. Validation (does it pass health checks?)
4. Cleanup test artifacts
5. Document in script help text

### Integration Testing (Milestone 3.3)
**Full workflows:**
1. **Idea → Project flow:**
   - Create spark
   - Promote to idea (manual)
   - Promote to concept (Promote-IdeaToConcept.ps1)
   - Graduate to experiment (Promote-ConceptToExperiment.ps1)
   - Archive when done (Archive-CompletedProject.ps1)

2. **Health validation:**
   - Create project with scaffolder
   - Run health checks (Invoke-PortfolioHealthChecks.ps1)
   - Verify passes

3. **Data hygiene:**
   - Create file with fake API key
   - Try to commit
   - Verify hook blocks
   - Remove secret, verify passes

### User Acceptance Testing (Week 3)
**Scenarios:**
- Create personal project
- Create family project
- Create meta project
- Promote concept to experiment
- Archive completed project
- Run full health check

**Criteria:** All scenarios work without manual intervention

---

## Scope Decisions

### In Scope for Phase 3
- ✅ Lifecycle promotions (Concept → Experiment)
- ✅ Archiving automation
- ✅ Unified health checks
- ✅ Secret/PII scanning
- ✅ Pre-commit hooks

### Deferred to Phase 4
- ⏳ GitHub remote repo creation
- ⏳ Experiment → Project migration
- ⏳ Auto-fixers (missing READMEs, metadata)
- ⏳ CI/CD integration
- ⏳ Pester unit tests

**Rationale:** Phase 3 focuses on daily workflow automation. Phase 4 adds polish and advanced features.

---

## Timeline

### Week 1 (Dec 1-7)
- **Mon-Tue:** Promote-ConceptToExperiment.ps1
- **Wed:** Update Promote-IdeaToConcept.ps1
- **Thu:** Archive-CompletedProject.ps1
- **Fri:** Test and fix

### Week 2 (Dec 8-14)
- **Mon:** Invoke-PortfolioHealthChecks.ps1
- **Tue-Wed:** Secret and PII scanners
- **Thu:** Install-DataHygieneHooks.ps1
- **Fri:** Test and fix

### Week 3 (Dec 15-21)
- **Mon-Tue:** Integration testing all workflows
- **Wed:** User acceptance testing
- **Thu:** Documentation (user guide)
- **Fri:** Final review and wrap-up

**Target:** Phase 3 complete by December 21

---

## Deliverables

**Scripts (7 total):**
1. ✅ PortfolioHelpers.psm1 (DONE - Phase 2)
2. ✅ New-PortfolioProject.ps1 (DONE - Phase 2)
3. ⏳ Promote-ConceptToExperiment.ps1 (NEW)
4. ⏳ Updated Promote-IdeaToConcept.ps1
5. ⏳ Archive-CompletedProject.ps1 (NEW)
6. ⏳ Invoke-PortfolioHealthChecks.ps1 (NEW)
7. ⏳ Scan-ForSecrets.ps1 + Scan-ForPII.ps1 + Install hooks (NEW)

**Documentation:**
- ⏳ User guide (30-resources/automation-user-guide.md)
- ⏳ Updated PPS README with Phase 3 status
- ⏳ Test scenarios documented

---

## Success Metrics

**Phase 3 passes when:**
- ✅ Can execute complete Idea → Project → Archive workflow with automation
- ✅ Single health check command reports all issues
- ✅ Secrets/PII caught before commit
- ✅ User can use without referring to code
- ✅ All scripts use shared module (no duplication)

**Project completion:** 60% → 85% after Phase 3

---

## Risks & Mitigations

**Risk:** Time overrun (scope too ambitious)  
**Mitigation:** Time-box each task, defer features if needed

**Risk:** Data hygiene hooks too strict (blocks valid commits)  
**Mitigation:** Start with warnings, add bypass flag, tune patterns

**Risk:** Health check runner too slow  
**Mitigation:** Make checks optional/configurable, optimize later

---

## Dependencies

**Requires (Already Available):**
- ✅ PortfolioHelpers.psm1 module
- ✅ Governance policies/processes documentation
- ✅ Boilerplates in 30-resources/10-boilerplates
- ✅ Working validation scripts

**External:**
- Git installed and configured
- PowerShell 7+

---

## PM Assessment

**Feasibility:** ✅ High - Phase 2 proved we can deliver  
**Timeline:** ✅ Realistic - 3 weeks for 6-9 hours work  
**Dependencies:** ✅ All available  
**Risk:** 🟢 Low - Incremental approach, tested as we go

**Recommendation:** Proceed with Phase 3 execution

---

**Plan Status:** Ready for approval and execution  
**Awaiting:** Go/no-go decision from project owner
