<#
.SYNOPSIS
    Phase 2: Numbering - Apply consistent numbering to all meta folders
    
.DESCRIPTION
    This script implements Phase 2 of the /00-meta migration by applying consistent
    numbering prefixes (00-90 range) to all meta folders.
    
    CRITICAL CORRECTIONS FROM CRITIQUE:
    - Renames automation/documentation → automation/docs (Critical Issue #4)
    - Keeps automation/scripts/governance in place (doesn't move it)
    - Applies numbering in correct order to avoid conflicts
    
.PARAMETER PortfolioRoot
    Path to the portfolio root (default: C:\Portfolio)
    
.PARAMETER DryRun
    If specified, shows what would be done without making changes
    
.PARAMETER Force
    Skip confirmation prompts (use with caution)
    
.EXAMPLE
    .\Phase2-Numbering.ps1 -DryRun
    Preview changes without executing
    
.EXAMPLE
    .\Phase2-Numbering.ps1
    Execute Phase 2 with confirmation prompts
    
.NOTES
    Prerequisites:
    - Phase 1 (Governance) must be completed
    - Git repository should be clean
    - Backup recommended before running
    
    This script addresses:
    - Critical Issue #4: Clarifies automation/documentation → automation/docs
    - Numbering consistency across all meta folders
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
    
    # Check Phase 1 was completed (governance folder should exist)
    $govPath = Join-Path $metaPath "governance"
    if (-not (Test-Path $govPath)) {
        Write-ErrorMsg "Phase 1 not completed - governance folder not found"
        Write-Info "Run Phase1-Governance.ps1 first"
        return $false
    }
    Write-Success "Phase 1 (Governance) detected"
    
    # Check git status
    Push-Location $PortfolioRoot
    try {
        $gitStatus = git status --porcelain 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Not a git repository - changes won't be tracked"
        } elseif ($gitStatus) {
            Write-Warning "Git repository has uncommitted changes"
            Write-Info "Consider committing changes from Phase 1 first"
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
        $isGitRepo = git rev-parse --git-dir 2>&1
        if ($LASTEXITCODE -eq 0) {
            git add -A
            git commit -m "Migration Phase 2 - Checkpoint: $Message" -m "Automated checkpoint during Phase 2 (Numbering) migration"
            Write-Success "Git checkpoint created: $Message"
        }
    } catch {
        Write-Warning "Could not create git checkpoint: $_"
    } finally {
        Pop-Location
    }
}

# Rename folder with validation
function Rename-MetaFolder {
    param(
        [string]$OldName,
        [string]$NewName,
        [string]$Description
    )
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    $oldPath = Join-Path $metaPath $OldName
    $newPath = Join-Path $metaPath $NewName
    
    # Check if source exists
    if (-not (Test-Path $oldPath)) {
        Write-Info "Skipping: $OldName (not found)"
        return $false
    }
    
    # Check if destination already exists
    if (Test-Path $newPath) {
        Write-Warning "Destination already exists: $NewName (skipping)"
        return $false
    }
    
    if ($DryRun) {
        Write-Info "[DRY RUN] Would rename: $OldName → $NewName ($Description)"
        return $true
    }
    
    try {
        Rename-Item -Path $oldPath -NewName $NewName -Force
        Write-Success "Renamed: $OldName → $NewName"
        return $true
    } catch {
        Write-ErrorMsg "Failed to rename ${OldName}: $_"
        return $false
    }
}

# Apply numbering to meta folders
function Set-MetaFolderNumbering {
    Write-Step "Applying consistent numbering to meta folders..."
    
    # Define rename operations in order
    # IMPORTANT: Order matters to avoid conflicts (rename parents before children)
    $renameOps = @(
        # Already numbered in Phase 1
        @{ Old = "policies"; New = "01-policies"; Desc = "Portfolio policies and standards" }
        @{ Old = "governance"; New = "02-governance"; Desc = "Decision records (ADR/ODR/SDR/PDR)" }
        
        # Operations folder group (10-29 range)
        @{ Old = "operations"; New = "20-operations"; Desc = "Operational items" }
        @{ Old = "meta-projects"; New = "21-meta-projects"; Desc = "Meta-level projects" }
        @{ Old = "ideas-inbox"; New = "22-ideas-inbox"; Desc = "Captured ideas awaiting triage" }
        
        # Automation and scripts (30-39 range)
        @{ Old = "automation"; New = "30-automation"; Desc = "Scripts and tooling" }
        
        # Templates and schemas (40-59 range)
        @{ Old = "templates"; New = "40-templates"; Desc = "Template library" }
        @{ Old = "schemas"; New = "50-schemas"; Desc = "Schema definitions" }
        @{ Old = "shared-resources"; New = "60-shared-resources"; Desc = "Shared resources" }
        
        # Legacy and archive (90+ range)
        @{ Old = "legacy-meta"; New = "90-legacy-meta"; Desc = "Archived meta content" }
    )
    
    $successCount = 0
    $skipCount = 0
    
    foreach ($op in $renameOps) {
        $result = Rename-MetaFolder -OldName $op.Old -NewName $op.New -Description $op.Desc
        if ($result) {
            $successCount++
        } else {
            $skipCount++
        }
    }
    
    Write-Host ""
    Write-Info "Renamed: $successCount folders"
    if ($skipCount -gt 0) {
        Write-Info "Skipped: $skipCount folders"
    }
}

# Rename automation/documentation to automation/docs (Critical Issue #4)
function Rename-AutomationDocumentation {
    Write-Step "Renaming automation/documentation → automation/docs..."
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    
    # Handle both old name (automation) and new name (30-automation)
    $automationPaths = @(
        (Join-Path $metaPath "automation"),
        (Join-Path $metaPath "30-automation")
    )
    
    foreach ($autoPath in $automationPaths) {
        if (-not (Test-Path $autoPath)) {
            continue
        }
        
        $oldDocPath = Join-Path $autoPath "documentation"
        $newDocPath = Join-Path $autoPath "docs"
        
        if (Test-Path $oldDocPath) {
            if (Test-Path $newDocPath) {
                Write-Warning "automation/docs already exists - manual merge may be needed"
                continue
            }
            
            if ($DryRun) {
                Write-Info "[DRY RUN] Would rename: $(Split-Path $oldDocPath -Leaf) → docs (in $(Split-Path $autoPath -Leaf))"
            } else {
                try {
                    Rename-Item -Path $oldDocPath -NewName "docs" -Force
                    Write-Success "Renamed: documentation → docs (in $(Split-Path $autoPath -Leaf))"
                } catch {
                    Write-ErrorMsg "Failed to rename documentation folder: $_"
                }
            }
        } else {
            Write-Info "No documentation folder found in $(Split-Path $autoPath -Leaf)"
        }
    }
}

# Rename subfolders within numbered folders
function Set-SubfolderNumbering {
    Write-Step "Applying numbering to subfolders (where needed)..."
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    
    # Automation subfolders (scripts, docs, governance)
    $automationPaths = @(
        (Join-Path $metaPath "automation"),
        (Join-Path $metaPath "30-automation")
    )
    
    foreach ($autoPath in $automationPaths) {
        if (-not (Test-Path $autoPath)) {
            continue
        }
        
        $subfolderOps = @(
            @{ Old = "scripts"; New = "scripts"; Desc = "Keep as-is" }  # No numbering needed
            @{ Old = "docs"; New = "docs"; Desc = "Keep as-is" }
            @{ Old = "governance"; New = "governance"; Desc = "Keep as-is - stays in automation" }
        )
        
        Write-Info "Automation subfolders maintain their names (no numbering needed)"
    }
    
    # Architecture subfolders will be handled in Phase 3
    Write-Info "Architecture subfolders will be organized in Phase 3"
}

# Create summary report
function Show-NumberingReport {
    Write-Step "Generating numbering report..."
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    
    if (-not (Test-Path $metaPath)) {
        Write-ErrorMsg "Cannot generate report - 00-meta not found"
        return
    }
    
    Write-Host ""
    Write-Host "Current /00-meta structure:" -ForegroundColor Cyan
    Write-Host ""
    
    $folders = Get-ChildItem -Path $metaPath -Directory | Sort-Object Name
    
    foreach ($folder in $folders) {
        $hasNumber = $folder.Name -match '^\d{2}-'
        if ($hasNumber) {
            Write-Host "  ✓ " -ForegroundColor Green -NoNewline
        } else {
            Write-Host "  ○ " -ForegroundColor Yellow -NoNewline
        }
        Write-Host $folder.Name
        
        # Show immediate subfolders for key directories
        if ($folder.Name -match '^(30-automation|automation|10-architecture|architecture|02-governance|governance)$') {
            $subfolders = Get-ChildItem -Path $folder.FullName -Directory -ErrorAction SilentlyContinue | Sort-Object Name
            foreach ($sub in $subfolders) {
                Write-Host "      └─ $($sub.Name)" -ForegroundColor Gray
            }
        }
    }
    
    Write-Host ""
    Write-Host "Legend:" -ForegroundColor Gray
    Write-Host "  ✓ = Numbered folder" -ForegroundColor Green
    Write-Host "  ○ = Not numbered" -ForegroundColor Yellow
    Write-Host ""
}

# Main execution
function Start-Phase2Migration {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Phase 2: Numbering - Apply consistent folder numbering     " -ForegroundColor Cyan
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
        Write-Warning "This will rename multiple folders in /00-meta with number prefixes."
        Write-Warning "This implements corrections from Critical Issue #4 (automation/docs rename)."
        Write-Host ""
        Write-Info "Folders to be renamed:"
        Write-Info "  • operations → 20-operations"
        Write-Info "  • meta-projects → 21-meta-projects"
        Write-Info "  • ideas-inbox → 22-ideas-inbox"
        Write-Info "  • automation → 30-automation"
        Write-Info "  • templates → 40-templates"
        Write-Info "  • schemas → 50-schemas"
        Write-Info "  • shared-resources → 60-shared-resources"
        Write-Info "  • legacy-meta → 90-legacy-meta"
        Write-Info "  • automation/documentation → automation/docs"
        Write-Host ""
        $response = Read-Host "Continue with Phase 2? (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Info "Cancelled by user"
            exit 0
        }
    }
    
    # Create initial checkpoint
    New-GitCheckpoint -Message "Before Phase 2 - Numbering"
    
    # Execute phase steps
    try {
        Set-MetaFolderNumbering
        Rename-AutomationDocumentation
        Set-SubfolderNumbering
        
        # Final checkpoint
        New-GitCheckpoint -Message "After Phase 2 - Numbering completed"
        
        # Show final structure
        Show-NumberingReport
        
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Success "Phase 2 completed successfully!"
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host ""
        Write-Info "Next steps:"
        Write-Info "1. Review the numbered folder structure above"
        Write-Info "2. Update any automation that references old paths"
        Write-Info "3. Run Phase 3 (Architecture) when ready"
        Write-Host ""
        Write-Warning "NOTE: Some path references may be broken - run Find-PathReferences.ps1 to identify them"
        Write-Host ""
        
    } catch {
        Write-Host ""
        Write-ErrorMsg "Phase 2 failed: $_"
        Write-Warning "You can rollback using: .\Rollback-Phase2.ps1"
        exit 1
    }
}

# Execute
Start-Phase2Migration
