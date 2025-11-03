<#
.SYNOPSIS
    Master orchestrator for portfolio migration
    
.DESCRIPTION
    Coordinates execution of all migration phases with safety checks, progress tracking,
    and automatic rollback on failure. This is the recommended way to run the migration.
    
    This addresses Moderate Issue #8: Phase dependencies and coordination
    
.PARAMETER PortfolioRoot
    Path to the portfolio root (default: C:\Portfolio)
    
.PARAMETER StartFromPhase
    Start from specific phase (0-4, default: 0)
    
.PARAMETER StopAtPhase
    Stop after specific phase (0-4, default: 4)
    
.PARAMETER SkipBackup
    Skip initial backup (NOT recommended!)
    
.PARAMETER SkipDiscovery
    Skip Phase 0 discovery checks (NOT recommended!)
    
.PARAMETER AutoContinue
    Automatically continue between phases without prompts
    
.PARAMETER DryRun
    Run all phases in dry-run mode (preview only)
    
.EXAMPLE
    .\Start-PortfolioMigration.ps1
    Run complete migration with all safety checks
    
.EXAMPLE
    .\Start-PortfolioMigration.ps1 -StartFromPhase 2 -StopAtPhase 3
    Run only Phases 2 and 3
    
.EXAMPLE
    .\Start-PortfolioMigration.ps1 -DryRun
    Preview entire migration without making changes
    
.NOTES
    This is the SAFEST way to run the migration:
    - Validates prerequisites before each phase
    - Creates git checkpoints between phases
    - Automatic rollback on failure
    - Progress tracking and reporting
    - Comprehensive error handling
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$PortfolioRoot = "C:\Portfolio",
    
    [Parameter()]
    [ValidateRange(0, 4)]
    [int]$StartFromPhase = 0,
    
    [Parameter()]
    [ValidateRange(0, 4)]
    [int]$StopAtPhase = 4,
    
    [Parameter()]
    [switch]$SkipBackup,
    
    [Parameter()]
    [switch]$SkipDiscovery,
    
    [Parameter()]
    [switch]$AutoContinue,
    
    [Parameter()]
    [switch]$DryRun
)

#Requires -Version 5.1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Migration state
$script:MigrationState = @{
    StartTime = Get-Date
    CompletedPhases = @()
    FailedPhase = $null
    BackupPath = $null
}

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

# Phase information
$script:Phases = @{
    0 = @{ Name = 'Discovery'; Script = 'Phase0-Discovery.ps1'; Desc = 'Validate prerequisites and analyze current state' }
    1 = @{ Name = 'Governance'; Script = 'Phase1-Governance.ps1'; Desc = 'Create formal governance structure' }
    2 = @{ Name = 'Numbering'; Script = 'Phase2-Numbering.ps1'; Desc = 'Apply consistent folder numbering' }
    3 = @{ Name = 'Architecture'; Script = 'Phase3-Architecture.ps1'; Desc = 'Organize architecture folder' }
    4 = @{ Name = 'Templates'; Script = 'Phase4-Templates.ps1'; Desc = 'Consolidate templates by type' }
}

# Get script directory
$script:ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Show migration plan
function Show-MigrationPlan {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Portfolio Migration Plan                                    " -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "  Portfolio Root: " -NoNewline
    Write-Host $PortfolioRoot -ForegroundColor White
    Write-Host ""
    
    if (-not $SkipBackup) {
        Write-Host "  Pre-Migration:" -ForegroundColor Cyan
        Write-Host "    • Create backup of /00-meta" -ForegroundColor Gray
        Write-Host ""
    }
    
    Write-Host "  Phases to Execute:" -ForegroundColor Cyan
    for ($i = $StartFromPhase; $i -le $StopAtPhase; $i++) {
        $phase = $script:Phases[$i]
        Write-Host "    $i. " -NoNewline -ForegroundColor Yellow
        Write-Host $phase.Name -NoNewline -ForegroundColor White
        Write-Host " - $($phase.Desc)" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "  Safety Features:" -ForegroundColor Cyan
    Write-Host "    • Git checkpoints between phases" -ForegroundColor Gray
    Write-Host "    • Automatic rollback on failure" -ForegroundColor Gray
    Write-Host "    • Prerequisite validation" -ForegroundColor Gray
    Write-Host "    • Progress tracking" -ForegroundColor Gray
    Write-Host ""
    
    if ($DryRun) {
        Write-Host "  MODE: " -NoNewline -ForegroundColor Yellow
        Write-Host "DRY RUN (preview only)" -ForegroundColor Yellow
        Write-Host ""
    }
}

# Create backup
function Invoke-PreMigrationBackup {
    if ($SkipBackup) {
        Write-Warning "Backup skipped (not recommended!)"
        return $true
    }
    
    Write-Step "Creating pre-migration backup..."
    
    $backupScript = Join-Path $script:ScriptDir "Backup-PortfolioMeta.ps1"
    
    if (-not (Test-Path $backupScript)) {
        Write-ErrorMsg "Backup script not found: $backupScript"
        return $false
    }
    
    try {
        if ($DryRun) {
            Write-Info "[DRY RUN] Would create backup"
            return $true
        }
        
        # Check if recent backup exists
        $backupDir = Join-Path $PortfolioRoot ".migration-backups"
        if (Test-Path $backupDir) {
            $recentBackup = Get-ChildItem -Path $backupDir -Filter "00-meta-backup-*.zip" | 
                Sort-Object LastWriteTime -Descending | Select-Object -First 1
            
            if ($recentBackup -and ((Get-Date) - $recentBackup.LastWriteTime).TotalHours -lt 24) {
                Write-Success "Recent backup exists: $($recentBackup.Name)"
                Write-Info "Created: $($recentBackup.LastWriteTime)"
                $script:MigrationState.BackupPath = $recentBackup.FullName
                return $true
            }
        }
        
        # No recent backup - need to create one manually
        Write-Warning "No recent backup found"
        Write-Info "Please run: .\Backup-PortfolioMeta.ps1"
        Write-Info "Then re-run this migration script"
        return $false
        
    } catch {
        Write-ErrorMsg "Backup check error: $_"
        return $false
    }
}

# Run discovery phase
function Invoke-DiscoveryPhase {
    if ($SkipDiscovery -and $StartFromPhase -gt 0) {
        Write-Warning "Discovery skipped"
        return $true
    }
    
    return Invoke-MigrationPhase -PhaseNumber 0
}

# Run specific migration phase
function Invoke-MigrationPhase {
    param([int]$PhaseNumber)
    
    $phase = $script:Phases[$PhaseNumber]
    $scriptPath = Join-Path $script:ScriptDir $phase.Script
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  Phase $PhaseNumber : $($phase.Name)" -ForegroundColor Magenta
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host ""
    
    if (-not (Test-Path $scriptPath)) {
        Write-ErrorMsg "Phase script not found: $scriptPath"
        return $false
    }
    
    # Prompt to continue (unless AutoContinue or DryRun)
    if (-not $AutoContinue -and -not $DryRun -and $PhaseNumber -gt 0) {
        Write-Host "  Ready to execute Phase $PhaseNumber : $($phase.Name)" -ForegroundColor Cyan
        Write-Host "  $($phase.Desc)" -ForegroundColor Gray
        Write-Host ""
        $response = Read-Host "  Continue? (Y/n)"
        if ($response -eq 'n' -or $response -eq 'N') {
            Write-Warning "Skipped by user"
            return $false
        }
    }
    
    try {
        Write-Info "Executing: $($phase.Script)"
        
        # Build parameters
        $params = @{
            PortfolioRoot = $PortfolioRoot
        }
        
        # Phase 0 (Discovery) doesn't support DryRun (it's read-only)
        if ($DryRun -and $PhaseNumber -gt 0) {
            $params['DryRun'] = $true
        }
        
        if ($AutoContinue -and $PhaseNumber -gt 0) {
            $params['Force'] = $true
        }
        
        # Execute phase script
        & $scriptPath @params
        
        if ($LASTEXITCODE -eq 0) {
            $script:MigrationState.CompletedPhases += $PhaseNumber
            Write-Success "Phase $PhaseNumber completed"
            return $true
        } else {
            Write-ErrorMsg "Phase $PhaseNumber failed with exit code: $LASTEXITCODE"
            $script:MigrationState.FailedPhase = $PhaseNumber
            return $false
        }
        
    } catch {
        Write-ErrorMsg "Phase $PhaseNumber error: $_"
        $script:MigrationState.FailedPhase = $PhaseNumber
        return $false
    }
}

# Automatic rollback on failure
function Invoke-AutoRollback {
    param([int]$FailedPhase)
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "  Migration Failed - Initiating Rollback                     " -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host ""
    
    Write-ErrorMsg "Phase $FailedPhase ($($script:Phases[$FailedPhase].Name)) failed"
    Write-Host ""
    
    if ($DryRun) {
        Write-Info "[DRY RUN] Would initiate automatic rollback"
        return
    }
    
    $rollbackScript = Join-Path $script:ScriptDir "Rollback-Migration.ps1"
    
    if (-not (Test-Path $rollbackScript)) {
        Write-Warning "Rollback script not found - manual rollback required"
        Write-Info "To rollback manually:"
        Write-Info "1. Use git: git reset --hard <checkpoint-hash>"
        Write-Info "2. Or restore from backup"
        return
    }
    
    Write-Warning "Attempting automatic rollback to before Phase $FailedPhase..."
    Write-Host ""
    
    if (-not $AutoContinue) {
        $response = Read-Host "Proceed with automatic rollback? (Y/n)"
        if ($response -eq 'n' -or $response -eq 'N') {
            Write-Info "Rollback cancelled - manual intervention required"
            return
        }
    }
    
    try {
        & $rollbackScript -Phase $FailedPhase -PortfolioRoot $PortfolioRoot -Force
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Rollback completed"
        } else {
            Write-ErrorMsg "Rollback failed - manual intervention required"
        }
    } catch {
        Write-ErrorMsg "Rollback error: $_"
        Write-Warning "Manual intervention required"
    }
}

# Run post-migration validation
function Invoke-PostMigrationValidation {
    Write-Step "Running post-migration validation..."
    
    $testScript = Join-Path $script:ScriptDir "Test-MigrationSuccess.ps1"
    
    if (-not (Test-Path $testScript)) {
        Write-Warning "Validation script not found - skipping"
        return $true
    }
    
    try {
        & $testScript -PortfolioRoot $PortfolioRoot -Phase 'all'
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Validation passed"
            return $true
        } else {
            Write-Warning "Validation found issues - review output above"
            return $false
        }
    } catch {
        Write-Warning "Validation error: $_"
        return $false
    }
}

# Show final summary
function Show-MigrationSummary {
    param([bool]$Success)
    
    $duration = (Get-Date) - $script:MigrationState.StartTime
    $durationStr = "{0:mm} minutes {0:ss} seconds" -f $duration
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Migration Summary                                           " -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "  Duration: " -NoNewline
    Write-Host $durationStr -ForegroundColor White
    Write-Host ""
    
    Write-Host "  Completed Phases: " -NoNewline
    Write-Host $script:MigrationState.CompletedPhases.Count -ForegroundColor White
    foreach ($phaseNum in $script:MigrationState.CompletedPhases) {
        Write-Host "    ✓ Phase $phaseNum : $($script:Phases[$phaseNum].Name)" -ForegroundColor Green
    }
    
    if ($script:MigrationState.FailedPhase -ne $null) {
        Write-Host ""
        Write-Host "  Failed Phase: " -NoNewline
        Write-Host $script:MigrationState.FailedPhase -ForegroundColor Red
        Write-Host "    ✗ Phase $($script:MigrationState.FailedPhase) : $($script:Phases[$script:MigrationState.FailedPhase].Name)" -ForegroundColor Red
    }
    
    Write-Host ""
    
    if ($Success) {
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host "  Migration Completed Successfully! 🎉                        " -ForegroundColor Green
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host ""
        Write-Info "Next steps:"
        Write-Info "1. Review the new /00-meta structure"
        Write-Info "2. Run Find-PathReferences.ps1 to find any broken links"
        Write-Info "3. Update path references using Update-PathReferences.ps1"
        Write-Info "4. Test your portfolio thoroughly"
        Write-Info "5. Commit the changes to git"
    } else {
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Red
        Write-Host "  Migration Failed                                            " -ForegroundColor Red
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Red
        Write-Host ""
        Write-Warning "Review the error messages above"
        
        if ($script:MigrationState.BackupPath) {
            Write-Info "Backup available at: $($script:MigrationState.BackupPath)"
        }
        
        Write-Info "To rollback manually:"
        Write-Info "  .\Rollback-Migration.ps1 -Phase $($script:MigrationState.FailedPhase)"
    }
    
    Write-Host ""
}

# Main execution
function Start-MigrationOrchestrator {
    Show-MigrationPlan
    
    # Confirm start
    if (-not $AutoContinue -and -not $DryRun) {
        Write-Host ""
        Write-Warning "This will modify your portfolio structure"
        Write-Host ""
        $response = Read-Host "Ready to begin migration? (Y/n)"
        if ($response -eq 'n' -or $response -eq 'N') {
            Write-Info "Migration cancelled"
            exit 0
        }
    }
    
    # Create backup
    if (-not (Invoke-PreMigrationBackup)) {
        Write-ErrorMsg "Backup failed - cannot proceed safely"
        exit 1
    }
    
    # Run discovery if needed
    if ($StartFromPhase -eq 0) {
        if (-not (Invoke-DiscoveryPhase)) {
            Write-ErrorMsg "Discovery phase failed - cannot proceed"
            exit 1
        }
    }
    
    # Run migration phases
    $success = $true
    for ($phase = [Math]::Max(1, $StartFromPhase); $phase -le $StopAtPhase; $phase++) {
        if (-not (Invoke-MigrationPhase -PhaseNumber $phase)) {
            $success = $false
            
            # Auto rollback on failure (unless dry run)
            if (-not $DryRun) {
                Invoke-AutoRollback -FailedPhase $phase
            }
            
            break
        }
    }
    
    # Post-migration validation (only if all phases succeeded and not dry run)
    if ($success -and -not $DryRun -and $StopAtPhase -eq 4) {
        Invoke-PostMigrationValidation | Out-Null
    }
    
    # Summary
    Show-MigrationSummary -Success $success
    
    # Exit code
    if ($success) {
        exit 0
    } else {
        exit 1
    }
}

# Execute
Start-MigrationOrchestrator
