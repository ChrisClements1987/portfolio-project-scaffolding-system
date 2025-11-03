<#
.SYNOPSIS
    Phase 3: Architecture - Organize architecture folder and create junctions
    
.DESCRIPTION
    This script implements Phase 3 of the /00-meta migration by organizing the
    architecture folder with proper subfolders and creating convenient navigation
    junctions.
    
    CRITICAL CORRECTIONS FROM CRITIQUE:
    - Uses directory junctions (no admin required) instead of symlinks
    - Provides fallback to README-based references if junctions fail
    - Documents Developer Mode alternative for symlinks
    
.PARAMETER PortfolioRoot
    Path to the portfolio root (default: C:\Portfolio)
    
.PARAMETER DryRun
    If specified, shows what would be done without making changes
    
.PARAMETER Force
    Skip confirmation prompts (use with caution)
    
.PARAMETER CreateJunctions
    Create convenience junctions for navigation (default: true)
    
.EXAMPLE
    .\Phase3-Architecture.ps1 -DryRun
    Preview changes without executing
    
.EXAMPLE
    .\Phase3-Architecture.ps1 -CreateJunctions:$false
    Organize architecture without creating junctions
    
.NOTES
    Prerequisites:
    - Phase 2 (Numbering) must be completed
    - Git repository should be clean
    - Backup recommended before running
    
    This script addresses:
    - Critical Issue #3: Uses junctions (no admin) instead of symlinks
    - Architecture folder organization with subfolders
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$PortfolioRoot = "C:\Portfolio",
    
    [Parameter()]
    [switch]$DryRun,
    
    [Parameter()]
    [switch]$Force,
    
    [Parameter()]
    [bool]$CreateJunctions = $true
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
    
    # Check Phase 2 was completed (should have numbered folders)
    $automationPath = Join-Path $metaPath "30-automation"
    if (-not (Test-Path $automationPath)) {
        # Check if old name still exists
        $oldAutoPath = Join-Path $metaPath "automation"
        if (Test-Path $oldAutoPath) {
            Write-ErrorMsg "Phase 2 not completed - automation folder not renamed to 30-automation"
            Write-Info "Run Phase2-Numbering.ps1 first"
            return $false
        }
    }
    Write-Success "Phase 2 (Numbering) detected"
    
    # Check architecture folder exists (old or new name)
    $archPaths = @(
        (Join-Path $metaPath "architecture"),
        (Join-Path $metaPath "10-architecture")
    )
    
    $archFound = $false
    foreach ($path in $archPaths) {
        if (Test-Path $path) {
            $archFound = $true
            break
        }
    }
    
    if (-not $archFound) {
        Write-ErrorMsg "Architecture folder not found"
        return $false
    }
    Write-Success "Architecture folder exists"
    
    # Check git status
    Push-Location $PortfolioRoot
    try {
        $gitStatus = git status --porcelain 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Not a git repository - changes won't be tracked"
        } elseif ($gitStatus) {
            Write-Warning "Git repository has uncommitted changes"
            Write-Info "Consider committing changes from Phase 2 first"
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
        git rev-parse --git-dir 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            git add -A
            git commit -m "Migration Phase 3 - Checkpoint: $Message" -m "Automated checkpoint during Phase 3 (Architecture) migration"
            Write-Success "Git checkpoint created: $Message"
        }
    } catch {
        Write-Warning "Could not create git checkpoint: $_"
    } finally {
        Pop-Location
    }
}

# Get architecture folder path (handles old or new name)
function Get-ArchitecturePath {
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    
    $newPath = Join-Path $metaPath "10-architecture"
    if (Test-Path $newPath) {
        return $newPath
    }
    
    $oldPath = Join-Path $metaPath "architecture"
    if (Test-Path $oldPath) {
        return $oldPath
    }
    
    return $null
}

# Rename architecture folder if not numbered yet
function Set-ArchitectureNumbering {
    Write-Step "Ensuring architecture folder is numbered..."
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    $oldPath = Join-Path $metaPath "architecture"
    $newPath = Join-Path $metaPath "10-architecture"
    
    if (Test-Path $newPath) {
        Write-Success "Already numbered: 10-architecture"
        return $newPath
    }
    
    if (-not (Test-Path $oldPath)) {
        Write-ErrorMsg "Architecture folder not found"
        return $null
    }
    
    if ($DryRun) {
        Write-Info "[DRY RUN] Would rename: architecture → 10-architecture"
        return $oldPath
    }
    
    try {
        Rename-Item -Path $oldPath -NewName "10-architecture" -Force
        Write-Success "Renamed: architecture → 10-architecture"
        return $newPath
    } catch {
        Write-ErrorMsg "Failed to rename architecture folder: $_"
        return $null
    }
}

# Organize architecture subfolder structure
function Set-ArchitectureStructure {
    Write-Step "Organizing architecture folder structure..."
    
    $archPath = Get-ArchitecturePath
    if (-not $archPath) {
        Write-ErrorMsg "Cannot find architecture folder"
        return
    }
    
    # Define subfolder structure
    $subfolders = @(
        @{ Name = "migration-plans"; Desc = "Migration and restructuring plans" }
        @{ Name = "analysis"; Desc = "Architecture analysis documents" }
        @{ Name = "data-architecture"; Desc = "Data models and schemas" }
    )
    
    foreach ($subfolder in $subfolders) {
        $subPath = Join-Path $archPath $subfolder.Name
        
        if ($DryRun) {
            Write-Info "[DRY RUN] Would create: 10-architecture/$($subfolder.Name)/"
        } else {
            if (-not (Test-Path $subPath)) {
                New-Item -Path $subPath -ItemType Directory -Force | Out-Null
                Write-Success "Created: $($subfolder.Name)/"
            } else {
                Write-Info "Already exists: $($subfolder.Name)/"
            }
        }
    }
    
    # Move existing migration plan files
    Write-Info "Moving existing migration plan files..."
    $migrationFiles = Get-ChildItem -Path $archPath -Filter "migration-plan*.md" -File -ErrorAction SilentlyContinue
    
    if ($migrationFiles.Count -gt 0) {
        $migrationPlansPath = Join-Path $archPath "migration-plans"
        
        foreach ($file in $migrationFiles) {
            $destPath = Join-Path $migrationPlansPath $file.Name
            
            if ($DryRun) {
                Write-Info "[DRY RUN] Would move: $($file.Name) → migration-plans/"
            } else {
                if (-not (Test-Path $destPath)) {
                    Move-Item -Path $file.FullName -Destination $destPath -Force
                    Write-Success "Moved: $($file.Name) → migration-plans/"
                } else {
                    Write-Info "Already exists in migration-plans: $($file.Name)"
                }
            }
        }
    } else {
        Write-Info "No migration-plan*.md files to move"
    }
    
    # Move existing analysis files
    Write-Info "Moving existing analysis files..."
    $analysisFiles = Get-ChildItem -Path $archPath -Filter "*analysis*.md" -File -ErrorAction SilentlyContinue
    
    if ($analysisFiles.Count -gt 0) {
        $analysisPath = Join-Path $archPath "analysis"
        
        foreach ($file in $analysisFiles) {
            $destPath = Join-Path $analysisPath $file.Name
            
            if ($DryRun) {
                Write-Info "[DRY RUN] Would move: $($file.Name) → analysis/"
            } else {
                if (-not (Test-Path $destPath)) {
                    Move-Item -Path $file.FullName -Destination $destPath -Force
                    Write-Success "Moved: $($file.Name) → analysis/"
                } else {
                    Write-Info "Already exists in analysis: $($file.Name)"
                }
            }
        }
    } else {
        Write-Info "No *analysis*.md files to move"
    }
}

# Create directory junction (Critical Issue #3 solution)
function New-DirectoryJunction {
    param(
        [string]$JunctionPath,
        [string]$TargetPath,
        [string]$Description
    )
    
    if ($DryRun) {
        Write-Info "[DRY RUN] Would create junction: $JunctionPath → $TargetPath"
        return $true
    }
    
    # Check if target exists
    if (-not (Test-Path $TargetPath)) {
        Write-Warning "Target does not exist: $TargetPath (skipping junction)"
        return $false
    }
    
    # Check if junction already exists
    if (Test-Path $JunctionPath) {
        $item = Get-Item $JunctionPath -Force
        if ($item.LinkType -eq "Junction") {
            Write-Info "Junction already exists: $JunctionPath"
            return $true
        } else {
            Write-Warning "Path exists but is not a junction: $JunctionPath (skipping)"
            return $false
        }
    }
    
    try {
        # Create junction using mklink via cmd
        $junctionDir = Split-Path $JunctionPath -Parent
        $junctionName = Split-Path $JunctionPath -Leaf
        
        # Ensure parent directory exists
        if (-not (Test-Path $junctionDir)) {
            New-Item -Path $junctionDir -ItemType Directory -Force | Out-Null
        }
        
        # Create junction (no admin required)
        $result = cmd /c mklink /J "$JunctionPath" "$TargetPath" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Created junction: $junctionName → $(Split-Path $TargetPath -Leaf)"
            return $true
        } else {
            Write-Warning "Failed to create junction: $result"
            return $false
        }
    } catch {
        Write-Warning "Exception creating junction: $_"
        return $false
    }
}

# Create convenience junctions
function New-ConvenienceJunctions {
    if (-not $CreateJunctions) {
        Write-Step "Skipping junction creation (CreateJunctions=false)"
        return
    }
    
    Write-Step "Creating convenience navigation junctions..."
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    
    # Define junctions (optional convenience features)
    $junctions = @(
        @{
            Junction = Join-Path $metaPath "shortcuts\decisions"
            Target = Join-Path $metaPath "02-governance"
            Desc = "Quick access to decision records"
        }
        @{
            Junction = Join-Path $metaPath "shortcuts\arch"
            Target = Join-Path $metaPath "10-architecture"
            Desc = "Quick access to architecture"
        }
    )
    
    $successCount = 0
    $failCount = 0
    
    foreach ($junction in $junctions) {
        $result = New-DirectoryJunction -JunctionPath $junction.Junction -TargetPath $junction.Target -Description $junction.Desc
        if ($result) {
            $successCount++
        } else {
            $failCount++
        }
    }
    
    if ($failCount -gt 0 -and -not $DryRun) {
        Write-Host ""
        Write-Warning "Some junctions could not be created"
        Write-Info "This is optional - you can navigate using numbered folders directly"
        Write-Info "Alternative: Enable Developer Mode in Windows Settings for symlink support"
    }
    
    Write-Host ""
    Write-Info "Junctions created: $successCount"
    if ($failCount -gt 0) {
        Write-Info "Junctions failed: $failCount"
    }
}

# Create README for architecture folder
function New-ArchitectureReadme {
    Write-Step "Creating architecture README..."
    
    $archPath = Get-ArchitecturePath
    if (-not $archPath) {
        Write-ErrorMsg "Cannot find architecture folder"
        return
    }
    
    $readmePath = Join-Path $archPath "README.md"
    
    $readmeContent = @"
# Architecture

Portfolio architecture documentation, migration plans, and analysis.

## Structure

- **migration-plans/** - Migration and restructuring plans (past and future)
- **analysis/** - Architecture analysis documents and assessments
- **data-architecture/** - Data models, schemas, and data flow documentation

## Purpose

Architecture captures the **technical design** and **structural decisions** for the portfolio:
- System structure and organization
- Migration strategies and execution plans
- Technical analysis and assessments
- Data architecture and modeling

## Related Folders

- See **/02-governance/adr/** for Architecture Decision Records (ADRs)
- See **/21-meta-projects/** for active meta-level improvement projects
- See **/30-automation/** for implementation scripts and tooling

## Navigation

Files are organized by type:
- Migration plans in **migration-plans/**
- Analysis documents in **analysis/**
- Data models in **data-architecture/**

## Conventions

### Migration Plans
- Name format: \`migration-plan-v{version}-{topic}.md\`
- Include version number for tracking evolution
- Link to related ADRs for decision context

### Analysis Documents
- Name format: \`{date}-{topic}-analysis.md\`
- Use ISO date format: YYYY-MM-DD
- Tag with relevant domains or categories

### Data Architecture
- Include schema files, entity relationship diagrams
- Document data flows between systems
- Link to relevant ADRs for design decisions
"@

    if ($DryRun) {
        Write-Info "[DRY RUN] Would create: 10-architecture/README.md"
    } else {
        Set-Content -Path $readmePath -Value $readmeContent -Encoding UTF8
        Write-Success "Created: README.md"
    }
}

# Main execution
function Start-Phase3Migration {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Phase 3: Architecture - Organize and create shortcuts      " -ForegroundColor Cyan
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
        Write-Warning "This will organize the architecture folder and create navigation junctions."
        Write-Warning "This implements corrections from Critical Issue #3 (junctions instead of symlinks)."
        Write-Host ""
        Write-Info "Changes:"
        Write-Info "  • Rename architecture → 10-architecture (if needed)"
        Write-Info "  • Create subfolders: migration-plans/, analysis/, data-architecture/"
        Write-Info "  • Move existing files to appropriate subfolders"
        Write-Info "  • Create convenience junctions (optional, no admin required)"
        Write-Host ""
        $response = Read-Host "Continue with Phase 3? (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Info "Cancelled by user"
            exit 0
        }
    }
    
    # Create initial checkpoint
    New-GitCheckpoint -Message "Before Phase 3 - Architecture"
    
    # Execute phase steps
    try {
        Set-ArchitectureNumbering
        Set-ArchitectureStructure
        New-ConvenienceJunctions
        New-ArchitectureReadme
        
        # Final checkpoint
        New-GitCheckpoint -Message "After Phase 3 - Architecture completed"
        
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Success "Phase 3 completed successfully!"
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host ""
        Write-Info "Next steps:"
        Write-Info "1. Review the organized architecture folder"
        Write-Info "2. Check that migration plans and analysis files moved correctly"
        Write-Info "3. Test junctions (if created) by navigating to shortcuts/"
        Write-Info "4. Run Phase 4 (Templates) when ready"
        Write-Host ""
        
    } catch {
        Write-Host ""
        Write-ErrorMsg "Phase 3 failed: $_"
        Write-Warning "You can rollback using: .\Rollback-Phase3.ps1"
        exit 1
    }
}

# Execute
Start-Phase3Migration
