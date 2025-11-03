<#
.SYNOPSIS
    Rollback migration phases using git history
    
.DESCRIPTION
    Comprehensive rollback script that can undo migration phases 1-4 using git
    checkpoints or backup restore. This is the safest and fastest rollback method.
    
    This addresses Moderate Issue #7: Rollback procedures
    
.PARAMETER Phase
    Which phase to rollback (1, 2, 3, 4, or 'all')
    
.PARAMETER PortfolioRoot
    Path to the portfolio root (default: C:\Portfolio)
    
.PARAMETER Method
    Rollback method: 'git' (default, fastest) or 'backup' (restore from ZIP)
    
.PARAMETER BackupPath
    Path to backup ZIP file (required if Method = 'backup')
    
.PARAMETER Force
    Skip confirmation prompts (use with caution)
    
.EXAMPLE
    .\Rollback-Migration.ps1 -Phase 2
    Rollback Phase 2 using git
    
.EXAMPLE
    .\Rollback-Migration.ps1 -Phase all -Method backup -BackupPath "C:\Backups\00-meta-backup.zip"
    Rollback all phases using backup file
    
.NOTES
    Git Method:
    - Finds checkpoint commit before specified phase
    - Resets to that commit
    - Fast and reliable
    
    Backup Method:
    - Extracts backup ZIP
    - Replaces 00-meta folder
    - Use when git history unavailable
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('1', '2', '3', '4', 'all')]
    [string]$Phase,
    
    [Parameter()]
    [string]$PortfolioRoot = "C:\Portfolio",
    
    [Parameter()]
    [ValidateSet('git', 'backup')]
    [string]$Method = 'git',
    
    [Parameter()]
    [string]$BackupPath,
    
    [Parameter()]
    [switch]$Force
)

#Requires -Version 5.1

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

# Phase names for user-friendly messages
$script:PhaseNames = @{
    '1' = 'Governance'
    '2' = 'Numbering'
    '3' = 'Architecture'
    '4' = 'Templates'
}

# Validate prerequisites
function Test-RollbackPrerequisites {
    Write-Step "Validating rollback prerequisites..."
    
    if (-not (Test-Path $PortfolioRoot)) {
        Write-ErrorMsg "Portfolio root not found: $PortfolioRoot"
        return $false
    }
    Write-Success "Portfolio root exists"
    
    if ($Method -eq 'git') {
        # Check git repository
        Push-Location $PortfolioRoot
        try {
            git rev-parse --git-dir 2>&1 | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Write-ErrorMsg "Not a git repository - use -Method backup instead"
                return $false
            }
            Write-Success "Git repository detected"
        } finally {
            Pop-Location
        }
    } elseif ($Method -eq 'backup') {
        # Check backup file
        if (-not $BackupPath) {
            Write-ErrorMsg "BackupPath required when Method = backup"
            Write-Info "Specify: -BackupPath 'C:\path\to\backup.zip'"
            return $false
        }
        
        if (-not (Test-Path $BackupPath)) {
            Write-ErrorMsg "Backup file not found: $BackupPath"
            return $false
        }
        Write-Success "Backup file exists: $BackupPath"
    }
    
    return $true
}

# Find git checkpoint for phase
function Find-GitCheckpoint {
    param([string]$PhaseNumber)
    
    Push-Location $PortfolioRoot
    try {
        $searchPattern = "Migration Phase $PhaseNumber - Checkpoint: Before"
        
        # Get commit hash for checkpoint
        $commit = git log --all --grep="$searchPattern" --format="%H" -n 1 2>&1
        
        if ($LASTEXITCODE -ne 0 -or -not $commit) {
            Write-Warning "No checkpoint found for Phase $PhaseNumber"
            return $null
        }
        
        # Get commit details
        $commitInfo = git log -1 --format="%H%n%s%n%ai" $commit
        $hash = $commitInfo[0]
        $message = $commitInfo[1]
        $date = $commitInfo[2]
        
        Write-Success "Found checkpoint: $message"
        Write-Info "Commit: $hash"
        Write-Info "Date: $date"
        
        return $hash
        
    } finally {
        Pop-Location
    }
}

# Rollback using git
function Invoke-GitRollback {
    param([string]$PhaseNumber)
    
    Write-Step "Rolling back Phase $PhaseNumber using git..."
    
    $phaseName = $script:PhaseNames[$PhaseNumber]
    $checkpoint = Find-GitCheckpoint -PhaseNumber $PhaseNumber
    
    if (-not $checkpoint) {
        Write-ErrorMsg "Cannot rollback - no checkpoint found"
        Write-Info "Try using -Method backup instead"
        return $false
    }
    
    if (-not $Force) {
        Write-Host ""
        Write-Warning "This will reset your repository to the checkpoint before Phase $PhaseNumber ($phaseName)"
        Write-Warning "All changes after that checkpoint will be lost!"
        Write-Host ""
        Write-Info "Current uncommitted changes will be stashed first"
        Write-Host ""
        
        $response = Read-Host "Proceed with git rollback? (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Info "Cancelled by user"
            return $false
        }
    }
    
    Push-Location $PortfolioRoot
    try {
        # Stash any uncommitted changes
        Write-Info "Stashing uncommitted changes..."
        git stash push -m "Pre-rollback stash $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" 2>&1 | Out-Null
        
        # Reset to checkpoint
        Write-Info "Resetting to checkpoint..."
        git reset --hard $checkpoint
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Git rollback completed"
            
            # Show what was undone
            Write-Host ""
            Write-Info "Recent commits that were undone:"
            git log --oneline -5
            
            return $true
        } else {
            Write-ErrorMsg "Git reset failed"
            return $false
        }
        
    } catch {
        Write-ErrorMsg "Rollback failed: $_"
        return $false
    } finally {
        Pop-Location
    }
}

# Rollback all phases
function Invoke-GitRollbackAll {
    Write-Step "Rolling back ALL phases using git..."
    
    # Find earliest checkpoint (Phase 1)
    $checkpoint = Find-GitCheckpoint -PhaseNumber '1'
    
    if (-not $checkpoint) {
        Write-ErrorMsg "Cannot rollback - no Phase 1 checkpoint found"
        Write-Info "Try using -Method backup instead"
        return $false
    }
    
    if (-not $Force) {
        Write-Host ""
        Write-Warning "This will reset your repository to BEFORE Phase 1 (Governance)"
        Write-Warning "ALL migration changes will be lost!"
        Write-Host ""
        
        $response = Read-Host "Are you absolutely sure? (yes/N)"
        if ($response -ne 'yes') {
            Write-Info "Cancelled by user (must type 'yes' to confirm)"
            return $false
        }
    }
    
    Push-Location $PortfolioRoot
    try {
        # Stash changes
        Write-Info "Stashing uncommitted changes..."
        git stash push -m "Pre-rollback-all stash $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" 2>&1 | Out-Null
        
        # Reset to before Phase 1
        Write-Info "Resetting to before Phase 1..."
        git reset --hard $checkpoint
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Complete rollback finished"
            return $true
        } else {
            Write-ErrorMsg "Git reset failed"
            return $false
        }
        
    } catch {
        Write-ErrorMsg "Rollback failed: $_"
        return $false
    } finally {
        Pop-Location
    }
}

# Rollback using backup file
function Invoke-BackupRollback {
    Write-Step "Rolling back using backup file..."
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    $tempExtractPath = Join-Path $env:TEMP "meta-rollback-$(Get-Date -Format 'yyyyMMddHHmmss')"
    
    if (-not $Force) {
        Write-Host ""
        Write-Warning "This will replace the entire /00-meta folder with backup contents"
        Write-Warning "Current /00-meta will be backed up to: $metaPath.before-rollback"
        Write-Host ""
        
        $response = Read-Host "Proceed with backup rollback? (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Info "Cancelled by user"
            return $false
        }
    }
    
    try {
        # Backup current state
        Write-Info "Backing up current /00-meta..."
        $currentBackup = "$metaPath.before-rollback"
        if (Test-Path $currentBackup) {
            Remove-Item -Path $currentBackup -Recurse -Force
        }
        Copy-Item -Path $metaPath -Destination $currentBackup -Recurse -Force
        Write-Success "Current state backed up to: $currentBackup"
        
        # Extract backup
        Write-Info "Extracting backup archive..."
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($BackupPath, $tempExtractPath)
        Write-Success "Backup extracted"
        
        # Find 00-meta in extracted content
        $extractedMeta = Get-ChildItem -Path $tempExtractPath -Directory -Recurse -Filter "00-meta" | Select-Object -First 1
        
        if (-not $extractedMeta) {
            Write-ErrorMsg "Could not find 00-meta folder in backup"
            return $false
        }
        
        # Remove current meta and restore from backup
        Write-Info "Replacing /00-meta with backup..."
        Remove-Item -Path $metaPath -Recurse -Force
        Copy-Item -Path $extractedMeta.FullName -Destination $metaPath -Recurse -Force
        Write-Success "Backup restored"
        
        # Clean up temp
        Remove-Item -Path $tempExtractPath -Recurse -Force
        
        Write-Success "Backup rollback completed"
        return $true
        
    } catch {
        Write-ErrorMsg "Backup rollback failed: $_"
        
        # Try to restore current backup if it exists
        if (Test-Path $currentBackup) {
            Write-Warning "Attempting to restore from current state backup..."
            try {
                if (Test-Path $metaPath) {
                    Remove-Item -Path $metaPath -Recurse -Force
                }
                Copy-Item -Path $currentBackup -Destination $metaPath -Recurse -Force
                Write-Success "Restored from current state backup"
            } catch {
                Write-ErrorMsg "Could not restore current state - manual intervention required"
            }
        }
        
        return $false
    }
}

# Main execution
function Start-RollbackProcess {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Rollback Migration - Undo Migration Changes                " -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    # Prerequisites
    if (-not (Test-RollbackPrerequisites)) {
        Write-ErrorMsg "Prerequisites check failed. Cannot continue."
        exit 1
    }
    
    # Execute rollback based on method
    $success = $false
    
    if ($Method -eq 'git') {
        if ($Phase -eq 'all') {
            $success = Invoke-GitRollbackAll
        } else {
            $success = Invoke-GitRollback -PhaseNumber $Phase
        }
    } elseif ($Method -eq 'backup') {
        $success = Invoke-BackupRollback
    }
    
    # Summary
    Write-Host ""
    if ($success) {
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Success "Rollback completed successfully!"
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host ""
        Write-Info "Next steps:"
        Write-Info "1. Verify the /00-meta folder structure"
        Write-Info "2. Check git status and history"
        Write-Info "3. Test that your portfolio works correctly"
        
        if ($Method -eq 'git') {
            Write-Info "4. Review stashed changes: git stash list"
        } elseif ($Method -eq 'backup') {
            Write-Info "4. Previous state saved to: 00-meta.before-rollback"
        }
        Write-Host ""
        
        exit 0
    } else {
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Red
        Write-ErrorMsg "Rollback failed!"
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Red
        Write-Host ""
        Write-Warning "Manual intervention may be required"
        
        if ($Method -eq 'backup') {
            Write-Info "Check: 00-meta.before-rollback for previous state"
        }
        
        exit 1
    }
}

# Execute
Start-RollbackProcess
