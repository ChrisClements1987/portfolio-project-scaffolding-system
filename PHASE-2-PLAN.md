# PPS Phase 2 Implementation Plan

**Phase:** Core Scaffolding Implementation  
**Target:** Make New-PortfolioProject.ps1 fully functional  
**Timeline:** 1-2 weeks (4-6 focused hours)  
**Status:** Ready for approval

---

## Objectives

**Primary Goal:** End-to-end working project scaffolder

**Success Criteria:**
- ✅ Single command creates complete project
- ✅ Project has proper metadata (project.yaml)
- ✅ Git repo initialized (local)
- ✅ Structure passes Test-PortfolioMetaCompliance.ps1
- ✅ Follows all governance standards

---

## Current vs Target State

### Current (New-PortfolioProject.ps1)
- ❌ CLI skeleton only (419 lines of parameter parsing)
- ❌ Prints help text but doesn't scaffold
- ❌ Says "Full implementation coming in next phase"
- ⚠️ Shadows Write-Error (dangerous)

### Target
- ✅ Working scaffolder with boilerplate copy
- ✅ Metadata generation from template
- ✅ Git initialization
- ✅ Proper error handling
- ✅ Dry-run mode

---

## Work Breakdown

### Task 1: Create Shared Module (2-3 hours)

**File:** `04-automation/lib/PortfolioHelpers.psm1`

**Functions to implement:**
```powershell
# Configuration
Get-PortfolioConfig          # Read from .yaml or env, fallback C:\Portfolio
Get-BoilerplatePath          # Resolve boilerplate location
Get-DomainPath               # Get path for domain projects folder

# Path Operations
Resolve-PortfolioPath        # Convert relative to absolute
Test-PortfolioPath           # Validate path is in Portfolio
ConvertTo-Slug               # String to kebab-case

# Logging (not shadowing built-ins)
Write-PortfolioInfo          # Info messages
Write-PortfolioWarning       # Warning messages  
Write-PortfolioError         # Error messages
Write-PortfolioSuccess       # Success messages

# Metadata
New-ProjectMetadata          # Generate project.yaml from params
Test-ProjectMetadata         # Validate against schema
```

**Deliverable:** Reusable module, imported by all scripts

---

### Task 2: Implement Core Scaffolder (2-3 hours)

**File:** `04-automation/scaffolding/New-PortfolioProject.ps1`

**Implementation steps:**

**2.1 Use Shared Module**
```powershell
Import-Module "$PSScriptRoot\..\lib\PortfolioHelpers.psm1"
```

**2.2 Implement Project Creation**
```powershell
function New-Project {
    param($ProjectName, $Domain, $Type, $Template, $DryRun)
    
    # 1. Validate parameters
    # 2. Resolve paths using module
    # 3. Check if project already exists
    # 4. Copy boilerplate template
    # 5. Replace template variables
    # 6. Generate project.yaml
    # 7. Initialize Git (optional)
    # 8. Validate result
    # 9. Report success
}
```

**2.3 Variable Substitution**
```powershell
# Simple string replacement for now
$content = $content -replace '{{PROJECT_NAME}}', $ProjectName
$content = $content -replace '{{PROJECT_SLUG}}', $projectSlug
$content = $content -replace '{{DOMAIN}}', $Domain
$content = $content -replace '{{DATE}}', (Get-Date -Format 'yyyy-MM-dd')
```

**2.4 Fix Write-Error Shadowing**
```powershell
# Remove custom Write-Error function
# Use built-in Write-Error or Write-PortfolioError from module
```

**Deliverable:** Functional scaffolder with dry-run support

---

### Task 3: Test End-to-End (1 hour)

**Test cases:**

**3.1 Create Test Project**
```powershell
.\New-PortfolioProject.ps1 `
    -ProjectName "test-scaffolder" `
    -Domain "personal" `
    -Type "experiments" `
    -Template "minimal-experiment" `
    -DryRun
```

**3.2 Validate Output**
- Project folder created in correct location
- All boilerplate files copied
- project.yaml exists and valid
- Variables replaced correctly
- Git repo initialized (if not dry-run)

**3.3 Run Validation**
```powershell
.\04-automation\validation\Test-PortfolioMetaCompliance.ps1 `
    -Path "10-personal\10-projects\experiments\test-scaffolder"
```

**3.4 Clean Up**
```powershell
Remove-Item "10-personal\10-projects\experiments\test-scaffolder" -Recurse
```

**Deliverable:** Confirmed working scaffolder

---

## Scope Decisions Needed

### Decision 1: GitHub Integration in Phase 2?

**Option A:** Include GitHub repo creation (adds 2-3 hours)
- Uses `gh` CLI
- Creates remote repo
- Pushes initial commit

**Option B:** Defer to Phase 3 (keep Phase 2 focused)
- Local Git only for now
- GitHub integration later

**Recommendation:** **Option B** - Keep Phase 2 focused on core scaffolding

---

### Decision 2: Where to Develop?

**Option A:** Develop in PPS repo, deploy to 04-automation
- PPS repo = development
- 04-automation = production
- Manual promotion when stable

**Option B:** Develop directly in 04-automation
- Simpler workflow
- PPS tracks planning/analysis only
- Scripts live in 04-automation

**Recommendation:** **Option B** - Simpler, less ceremony

---

### Decision 3: Template Variable Complexity?

**Option A:** Simple string replacement ({{VARIABLE}})
- Fast to implement
- Good enough for MVP
- Can enhance later

**Option B:** Full template engine (Jinja2-style)
- More powerful
- Handles conditionals, loops
- Adds complexity

**Recommendation:** **Option A** - Simple replacement for Phase 2

---

## Timeline

### Week 1 (Nov 21-24)
- **Day 1-2:** Create shared module + tests
- **Day 3:** Implement core scaffolder
- **Day 4:** Test and fix

### Week 2 (Nov 25-Dec 1)
- **Day 1:** Documentation
- **Day 2:** Polish and edge cases
- **Day 3:** User acceptance testing

**Target:** Phase 2 complete by December 1

---

## Deliverables

**Code:**
- ✅ `lib/PortfolioHelpers.psm1` (shared module)
- ✅ `New-PortfolioProject.ps1` (working scaffolder)
- ✅ Updated validation scripts

**Documentation:**
- ✅ User guide in 30-resources/
- ✅ Updated PPS README
- ✅ Code comments and help text

**Validation:**
- ✅ Test cases documented
- ✅ All tests passing
- ✅ Dry-run mode working

---

## Risks & Mitigations

**Risk:** Complexity creep  
**Mitigation:** Ruthlessly defer features to Phase 3

**Risk:** Template variable issues  
**Mitigation:** Start simple, document limitations

**Risk:** Time overrun  
**Mitigation:** 2-hour time boxes, stop when done enough

---

## Success Metrics

**Phase 2 passes when:**
- Can create minimal-experiment project in <2 minutes
- Generated project passes all validation
- No manual fixes needed
- Documentation clear enough to use without re-learning

---

## Questions for Approval

1. **Defer GitHub integration to Phase 3?** (Keep Phase 2 focused)
2. **Develop directly in 04-automation?** (Simpler than PPS → 04-automation flow)
3. **Simple variable replacement only?** ({{VAR}} not full template engine)
4. **Proceed with 2-week timeline?** (4-6 hours total)

**Please approve/adjust before I proceed with implementation.**
