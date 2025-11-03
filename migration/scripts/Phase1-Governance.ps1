<#
.SYNOPSIS
    Phase 1: Governance - Create formal governance structure
    
.DESCRIPTION
    This script implements Phase 1 of the /00-meta migration by creating the formal
    governance structure with decision records (ADR, ODR, SDR, PDR).
    
    CRITICAL CORRECTIONS FROM CRITIQUE:
    - Does NOT move automation/governance (it stays in automation)
    - DOES move documentation/CODE-DOCUMENTATION-STANDARDS* to new standards location
    - Creates ADR template inline before creating first ADR (bootstrapping solution)
    - Creates governance structure with proper decision record types
    
.PARAMETER PortfolioRoot
    Path to the portfolio root (default: C:\Portfolio)
    
.PARAMETER DryRun
    If specified, shows what would be done without making changes
    
.PARAMETER Force
    Skip confirmation prompts (use with caution)
    
.EXAMPLE
    .\Phase1-Governance.ps1 -DryRun
    Preview changes without executing
    
.EXAMPLE
    .\Phase1-Governance.ps1
    Execute Phase 1 with confirmation prompts
    
.NOTES
    Prerequisites:
    - Phase 0 Discovery must have passed all checks
    - Git repository must be clean (no uncommitted changes)
    - Backup recommended before running
    
    This script addresses:
    - Critical Issue #1: Corrected move commands
    - Minor Issue #10: ADR bootstrapping (creates template inline first)
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$PortfolioRoot = "C:\Portfolio",
    
    [Parameter()]
    [switch]$DryRun,
    
    [Parameter()]
    [switch]$Force
)

#Requires -Version 5.1

# Strict mode for better error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Color output functions
function Write-Step {
    param([string]$Message)
    Write-Host "`n==> " -ForegroundColor Cyan -NoNewline
    Write-Host $Message -ForegroundColor White
}

function Write-Success {
    param([string]$Message)
    Write-Host "    ✓ " -ForegroundColor Green -NoNewline
    Write-Host $Message -ForegroundColor White
}

function Write-Warning {
    param([string]$Message)
    Write-Host "    ⚠ " -ForegroundColor Yellow -NoNewline
    Write-Host $Message -ForegroundColor Yellow
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "    ✗ " -ForegroundColor Red -NoNewline
    Write-Host $Message -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "    ℹ " -ForegroundColor Blue -NoNewline
    Write-Host $Message -ForegroundColor Gray
}

# Validate prerequisites
function Test-Prerequisites {
    Write-Step "Validating prerequisites..."
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    
    # Check portfolio root exists
    if (-not (Test-Path $PortfolioRoot)) {
        Write-ErrorMsg "Portfolio root not found: $PortfolioRoot"
        return $false
    }
    Write-Success "Portfolio root exists"
    
    # Check 00-meta exists
    if (-not (Test-Path $metaPath)) {
        Write-ErrorMsg "00-meta folder not found"
        return $false
    }
    Write-Success "00-meta folder exists"
    
    # Check git status
    Push-Location $PortfolioRoot
    try {
        $gitStatus = git status --porcelain 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Not a git repository - changes won't be tracked"
        } elseif ($gitStatus) {
            Write-Warning "Git repository has uncommitted changes"
            Write-Info "Consider committing or stashing changes before migration"
            if (-not $Force) {
                $response = Read-Host "Continue anyway? (y/N)"
                if ($response -ne 'y' -and $response -ne 'Y') {
                    return $false
                }
            }
        } else {
            Write-Success "Git repository is clean"
        }
    } finally {
        Pop-Location
    }
    
    # Check required source folders exist
    $docPath = Join-Path $metaPath "documentation"
    if (-not (Test-Path $docPath)) {
        Write-ErrorMsg "documentation folder not found"
        return $false
    }
    Write-Success "documentation folder exists"
    
    return $true
}

# Create git checkpoint
function New-GitCheckpoint {
    param([string]$Message)
    
    if ($DryRun) {
        Write-Info "[DRY RUN] Would create git checkpoint: $Message"
        return
    }
    
    Push-Location $PortfolioRoot
    try {
        $isGit = git rev-parse --git-dir 2>&1
        if ($LASTEXITCODE -eq 0) {
            git add -A
            git commit -m "Migration Phase 1 - Checkpoint: $Message" -m "Automated checkpoint during Phase 1 (Governance) migration"
            Write-Success "Git checkpoint created: $Message"
        }
    } catch {
        Write-Warning "Could not create git checkpoint: $_"
    } finally {
        Pop-Location
    }
}

# Create folder structure
function New-GovernanceStructure {
    Write-Step "Creating governance folder structure..."
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    $policiesPath = Join-Path $metaPath "policies"
    $governancePath = Join-Path $metaPath "governance"
    
    # Create policies folder
    if ($DryRun) {
        Write-Info "[DRY RUN] Would create: $policiesPath"
    } else {
        if (-not (Test-Path $policiesPath)) {
            New-Item -Path $policiesPath -ItemType Directory -Force | Out-Null
            Write-Success "Created: policies/"
        } else {
            Write-Info "Already exists: policies/"
        }
    }
    
    # Create governance folder with subfolders
    $govSubfolders = @(
        "governance",
        "governance/adr",
        "governance/odr", 
        "governance/sdr",
        "governance/pdr"
    )
    
    foreach ($subfolder in $govSubfolders) {
        $fullPath = Join-Path $metaPath $subfolder
        if ($DryRun) {
            Write-Info "[DRY RUN] Would create: $fullPath"
        } else {
            if (-not (Test-Path $fullPath)) {
                New-Item -Path $fullPath -ItemType Directory -Force | Out-Null
                Write-Success "Created: $subfolder/"
            } else {
                Write-Info "Already exists: $subfolder/"
            }
        }
    }
}

# Create ADR template inline (bootstrapping solution)
function New-InlineAdrTemplate {
    param([string]$TargetPath)
    
    $adrTemplate = @'
# ADR-{NUMBER}: {TITLE}

**Status:** {Proposed | Accepted | Deprecated | Superseded}  
**Date:** {YYYY-MM-DD}  
**Decision Makers:** {Names/Roles}  
**Tags:** {architecture, infrastructure, tooling, etc.}

## Context

### Problem Statement
What architectural challenge or decision are we facing?

### Background
- Current state
- Why this decision is needed
- Technical or business drivers

### Stakeholders
- Who is affected by this decision?
- Who needs to be consulted?

## Decision

### What We Decided
Clear, unambiguous statement of the architectural decision.

### Alternatives Considered

#### Alternative 1: {Name}
- **Pros:**
- **Cons:**
- **Why rejected:**

#### Alternative 2: {Name}
- **Pros:**
- **Cons:**
- **Why rejected:**

## Consequences

### Positive
- Improvements, benefits, opportunities

### Negative  
- Trade-offs, limitations, risks

### Neutral
- Changes that are neither clearly positive nor negative

## Implementation

### Technical Approach
- How will this be implemented?
- What components/systems are affected?

### Migration Strategy
- If replacing existing system, how do we transition?
- Backward compatibility considerations

### Timeline
- When will this be implemented?
- Any phased rollout?

## Validation

### Success Criteria
- How do we know this decision was correct?
- Measurable outcomes

### Monitoring
- What metrics track success?
- Warning signs that may indicate problems

## References
- Links to related ADRs
- External documentation
- RFC documents
- Related issues/tickets

## Changelog
- {YYYY-MM-DD}: Created
- {YYYY-MM-DD}: Accepted
'@

    if ($DryRun) {
        Write-Info "[DRY RUN] Would create ADR template at: $TargetPath"
    } else {
        Set-Content -Path $TargetPath -Value $adrTemplate -Encoding UTF8
        Write-Success "Created ADR template inline"
    }
}

# Create decision record templates
function New-DecisionRecordTemplates {
    Write-Step "Creating decision record templates..."
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    $templatesBasePath = Join-Path $PortfolioRoot "00-meta\meta-projects\portfolio-project-scaffolding-system\migration\templates"
    $govPath = Join-Path $metaPath "governance"
    
    # Create ADR template inline first (bootstrapping solution for Critical Issue #10)
    $adrTemplatePath = Join-Path $govPath "adr\ADR-template.md"
    New-InlineAdrTemplate -TargetPath $adrTemplatePath
    
    # Copy other templates if they exist from migration package
    $templateMappings = @{
        "ODR-template.md" = "odr\ODR-template.md"
        "SDR-template.md" = "sdr\SDR-template.md"
        "PDR-template.md" = "pdr\PDR-template.md"
    }
    
    foreach ($template in $templateMappings.GetEnumerator()) {
        $sourcePath = Join-Path $templatesBasePath $template.Key
        $destPath = Join-Path $govPath $template.Value
        
        if (Test-Path $sourcePath) {
            if ($DryRun) {
                Write-Info "[DRY RUN] Would copy: $($template.Key) -> governance/$($template.Value)"
            } else {
                Copy-Item -Path $sourcePath -Destination $destPath -Force
                Write-Success "Copied: $($template.Key)"
            }
        } else {
            Write-Warning "Template not found: $($template.Key) - skipping"
        }
    }
}

# Create initial ADR
function New-InitialAdr {
    Write-Step "Creating initial ADR (ADR-001)..."
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    $adrPath = Join-Path $metaPath "governance\adr\ADR-001-meta-folder-restructure.md"
    
    $adrContent = @"
# ADR-001: Meta Folder Restructure

**Status:** Accepted  
**Date:** $(Get-Date -Format 'yyyy-MM-dd')  
**Decision Makers:** Portfolio Owner  
**Tags:** architecture, portfolio-structure, meta-organization

## Context

### Problem Statement
The /00-meta folder lacks consistent organization with mixed numbering schemes, unclear governance/automation separation, and scattered templates across multiple locations.

### Background
- Current structure mixes numbered and non-numbered folders
- Governance documentation lives in automation/governance (ambiguous)
- Templates split between documentation/templates and shared-resources/templates
- No formal decision record system
- Navigation difficult due to inconsistent naming

### Stakeholders
- Portfolio maintainers
- Future contributors
- Automated tools that reference /00-meta paths

## Decision

### What We Decided
Restructure /00-meta with consistent numbering (00-90), formal governance separation (policies + governance with ADR/ODR/SDR/PDR), and type-based template consolidation.

### Alternatives Considered

#### Alternative 1: Minimal changes (keep current structure)
- **Pros:** No migration effort, no path reference updates
- **Cons:** Technical debt continues, harder to maintain, confusing for new users
- **Why rejected:** Perpetuates existing problems

#### Alternative 2: Complete flat structure (no subfolders)
- **Pros:** Simple, everything at top level
- **Cons:** Too many items, no logical grouping, scales poorly
- **Why rejected:** Doesn't support growth

## Consequences

### Positive
- Consistent, predictable structure
- Clear governance vs automation separation
- Easier navigation with numbered prefixes
- Formal decision record system
- Consolidated templates by type

### Negative
- Path references require updates
- Migration effort required
- Learning curve for new structure

### Neutral
- Domain structures (10-personal, 20-family, etc.) unchanged
- PARA methodology within domains unchanged

## Implementation

### Technical Approach
5-phase migration:
1. Phase 1 (Governance): Create policies and governance structure
2. Phase 2 (Numbering): Apply consistent numbering
3. Phase 3 (Architecture): Organize architecture folder
4. Phase 4 (Templates): Consolidate templates by type
5. Phase 5 (Optional): Create navigation shortcuts

### Migration Strategy
- Git checkpoints between phases
- Rollback scripts for each phase
- Path reference scanning and batch updates
- Validation testing after each phase

### Timeline
- Discovery: 30 minutes
- Phases 1-4: 4-6 hours total
- Testing and validation: 1 hour
- Optional shortcuts: 30 minutes

## Validation

### Success Criteria
- All folders follow numbering convention
- Zero broken internal links
- All templates accessible from single location hierarchy
- Decision records in proper subfolders (adr/, odr/, sdr/, pdr/)

### Monitoring
- Path reference validation script
- Link checker for markdown files
- Structure validation against target schema

## References
- Analysis: 2025-10-30-as-is-portfolio-structure-analysis.md
- Critique: 2025-10-30-critique-of-2025-10-30-as-is-portfolio-structure-analysis.md
- Migration package: portfolio-project-scaffolding-system/migration/

## Changelog
- $(Get-Date -Format 'yyyy-MM-dd'): Created and accepted during Phase 1 migration
"@

    if ($DryRun) {
        Write-Info "[DRY RUN] Would create: ADR-001-meta-folder-restructure.md"
    } else {
        Set-Content -Path $adrPath -Value $adrContent -Encoding UTF8
        Write-Success "Created: ADR-001-meta-folder-restructure.md"
    }
}

# Move standards documentation (Critical Issue #1 correction)
function Move-StandardsDocumentation {
    Write-Step "Moving CODE-DOCUMENTATION-STANDARDS to new location..."
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    $docPath = Join-Path $metaPath "documentation"
    $policiesPath = Join-Path $metaPath "policies"
    
    # Create standards subfolder in policies
    $standardsPath = Join-Path $policiesPath "standards"
    if ($DryRun) {
        Write-Info "[DRY RUN] Would create: policies/standards/"
    } else {
        if (-not (Test-Path $standardsPath)) {
            New-Item -Path $standardsPath -ItemType Directory -Force | Out-Null
            Write-Success "Created: policies/standards/"
        }
    }
    
    # Find all CODE-DOCUMENTATION-STANDARDS files
    $standardsFiles = Get-ChildItem -Path $docPath -Filter "CODE-DOCUMENTATION-STANDARDS*.md" -ErrorAction SilentlyContinue
    
    if ($standardsFiles.Count -eq 0) {
        Write-Warning "No CODE-DOCUMENTATION-STANDARDS*.md files found"
        return
    }
    
    foreach ($file in $standardsFiles) {
        # Drop version suffix as per Moderate Issue #6
        $newName = if ($file.Name -match '-V\d+\.md$') {
            $file.Name -replace '-V\d+', ''
        } else {
            $file.Name
        }
        
        $destPath = Join-Path $standardsPath $newName
        
        if ($DryRun) {
            Write-Info "[DRY RUN] Would move: $($file.Name) -> policies/standards/$newName"
        } else {
            Move-Item -Path $file.FullName -Destination $destPath -Force
            Write-Success "Moved: $($file.Name) -> $newName"
        }
    }
}

# Create README files
function New-ReadmeFiles {
    Write-Step "Creating README files for governance structure..."
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    
    # Policies README
    $policiesReadme = @"
# Policies

Portfolio-wide policies, standards, and mandates.

## Structure

- **standards/** - Coding standards, documentation standards, quality requirements
- Additional policy documents at this level as needed

## Purpose

Policies define the **requirements** and **mandates** for the portfolio:
- MUST/SHOULD/MAY compliance levels
- Enforcement mechanisms
- Review and approval processes

## Related Folders

- See **/governance/** for decision records explaining policy origins
- See **/automation/scripts/** for policy enforcement tooling
"@

    $governanceReadme = @"
# Governance

Decision records documenting architectural, operational, strategic, and policy decisions.

## Structure

- **adr/** - Architecture Decision Records (technical design, tech selection, system structure)
- **odr/** - Operational Decision Records (process changes, workflows, procedures)
- **sdr/** - Strategy Decision Records (high-level direction, portfolio strategy, priorities)
- **pdr/** - Policy Decision Records (governance rules, compliance, mandates)

## Purpose

Governance captures the **what** and **why** of decisions:
- Decisions made and their context
- Alternatives considered
- Consequences and trade-offs
- Implementation guidance

## Templates

Each decision record type has a template in its respective subfolder. Use these templates to maintain consistency.

## Naming Convention

- ADR: \`ADR-###-brief-description.md\`
- ODR: \`ODR-###-brief-description.md\`
- SDR: \`SDR-###-brief-description.md\`
- PDR: \`PDR-###-brief-description.md\`

Start numbering at 001 for each type.
"@

    $readmes = @{
        "policies\README.md" = $policiesReadme
        "governance\README.md" = $governanceReadme
    }
    
    foreach ($readme in $readmes.GetEnumerator()) {
        $readmePath = Join-Path $metaPath $readme.Key
        
        if ($DryRun) {
            Write-Info "[DRY RUN] Would create: $($readme.Key)"
        } else {
            Set-Content -Path $readmePath -Value $readme.Value -Encoding UTF8
            Write-Success "Created: $($readme.Key)"
        }
    }
}

# Main execution
function Start-Phase1Migration {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Phase 1: Governance - Create formal governance structure   " -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    if ($DryRun) {
        Write-Warning "DRY RUN MODE - No changes will be made"
        Write-Host ""
    }
    
    # Prerequisites
    if (-not (Test-Prerequisites)) {
        Write-ErrorMsg "Prerequisites check failed. Cannot continue."
        exit 1
    }
    
    # Confirmation
    if (-not $DryRun -and -not $Force) {
        Write-Host ""
        Write-Warning "This will create the governance structure and move standards documentation."
        Write-Warning "This implements corrections from Critical Issue #1 (proper governance separation)."
        Write-Host ""
        $response = Read-Host "Continue with Phase 1? (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Info "Cancelled by user"
            exit 0
        }
    }
    
    # Create initial checkpoint
    New-GitCheckpoint -Message "Before Phase 1 - Governance"
    
    # Execute phase steps
    try {
        New-GovernanceStructure
        New-DecisionRecordTemplates
        New-InitialAdr
        Move-StandardsDocumentation
        New-ReadmeFiles
        
        # Final checkpoint
        New-GitCheckpoint -Message "After Phase 1 - Governance completed"
        
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Success "Phase 1 completed successfully!"
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host ""
        Write-Info "Next steps:"
        Write-Info "1. Review the created governance structure"
        Write-Info "2. Verify ADR-001-meta-folder-restructure.md"
        Write-Info "3. Run Phase 2 (Numbering) when ready"
        Write-Host ""
        
    } catch {
        Write-Host ""
        Write-ErrorMsg "Phase 1 failed: $_"
        Write-Warning "You can rollback using: .\Rollback-Phase1.ps1"
        exit 1
    }
}

# Execute
Start-Phase1Migration
