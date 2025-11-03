<#
.SYNOPSIS
    Create safety backup of /00-meta before migration
    
.DESCRIPTION
    Creates a timestamped backup of the entire /00-meta folder before running
    migration phases. This provides a safety net for rollback if needed.
    
    The backup is created as a ZIP archive with timestamp in the filename.
    
.PARAMETER PortfolioRoot
    Path to the portfolio root (default: C:\Portfolio)
    
.PARAMETER BackupLocation
    Where to store the backup (default: C:\Portfolio\.migration-backups)
    
.PARAMETER IncludeGitHistory
    If specified, includes .git folder in backup (larger but complete)
    
.EXAMPLE
    .\Backup-PortfolioMeta.ps1
    Create backup with default settings
    
.EXAMPLE
    .\Backup-PortfolioMeta.ps1 -BackupLocation "D:\Backups"
    Create backup in custom location
    
.NOTES
    This addresses Moderate Issue #7: Rollback procedures
    
    Backup includes:
    - All /00-meta contents
    - Git history (optional)
    - Metadata about backup creation
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$PortfolioRoot = "C:\Portfolio",
    
    [Parameter()]
    [string]$BackupLocation,
    
    [Parameter()]
    [switch]$IncludeGitHistory
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

# Set default backup location if not specified
if (-not $BackupLocation) {
    $BackupLocation = Join-Path $PortfolioRoot ".migration-backups"
}

# Validate prerequisites
function Test-Prerequisites {
    Write-Step "Validating prerequisites..."
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    
    if (-not (Test-Path $PortfolioRoot)) {
        Write-ErrorMsg "Portfolio root not found: $PortfolioRoot"
        return $false
    }
    Write-Success "Portfolio root exists"
    
    if (-not (Test-Path $metaPath)) {
        Write-ErrorMsg "00-meta folder not found"
        return $false
    }
    Write-Success "00-meta folder exists"
    
    # Check available disk space
    $metaSize = (Get-ChildItem -Path $metaPath -Recurse -File | Measure-Object -Property Length -Sum).Sum
    $metaSizeMB = [math]::Round($metaSize / 1MB, 2)
    
    $backupDrive = (Get-Item $BackupLocation -ErrorAction SilentlyContinue)?.Root?.Name
    if (-not $backupDrive) {
        # Extract drive from path
        $backupDrive = Split-Path $BackupLocation -Qualifier
    }
    
    if ($backupDrive) {
        $drive = Get-PSDrive -Name $backupDrive.TrimEnd(':') -ErrorAction SilentlyContinue
        if ($drive) {
            $freeSpaceMB = [math]::Round($drive.Free / 1MB, 2)
            Write-Info "00-meta size: $metaSizeMB MB"
            Write-Info "Available space: $freeSpaceMB MB"
            
            if ($freeSpaceMB -lt ($metaSizeMB * 2)) {
                Write-Warning "Low disk space - backup may be tight"
            } else {
                Write-Success "Sufficient disk space available"
            }
        }
    }
    
    return $true
}

# Create backup
function New-MetaBackup {
    Write-Step "Creating backup of /00-meta..."
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupName = "00-meta-backup-$timestamp"
    $backupZipPath = Join-Path $BackupLocation "$backupName.zip"
    
    # Create backup location if it doesn't exist
    if (-not (Test-Path $BackupLocation)) {
        New-Item -Path $BackupLocation -ItemType Directory -Force | Out-Null
        Write-Success "Created backup directory: $BackupLocation"
    }
    
    Write-Info "Backup will be saved to: $backupZipPath"
    Write-Info "This may take a few moments..."
    
    try {
        # Determine what to exclude
        $excludePatterns = @()
        if (-not $IncludeGitHistory) {
            $excludePatterns += "*.git*"
            Write-Info "Excluding .git folder (use -IncludeGitHistory to include)"
        }
        
        # For PowerShell 5.1 compatibility, use .NET compression
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        
        # Create temporary staging directory
        $tempPath = Join-Path $env:TEMP "meta-backup-staging-$timestamp"
        New-Item -Path $tempPath -ItemType Directory -Force | Out-Null
        
        # Copy meta folder to temp location (excluding patterns)
        Write-Info "Copying files to staging area..."
        $copyParams = @{
            Path = $metaPath
            Destination = $tempPath
            Recurse = $true
            Force = $true
        }
        
        if (-not $IncludeGitHistory) {
            # Copy excluding .git
            Get-ChildItem -Path $metaPath -Recurse | Where-Object {
                $_.FullName -notlike "*\.git\*" -and $_.FullName -notlike "*\.git"
            } | ForEach-Object {
                $targetPath = $_.FullName.Replace($metaPath, (Join-Path $tempPath "00-meta"))
                if ($_.PSIsContainer) {
                    New-Item -Path $targetPath -ItemType Directory -Force | Out-Null
                } else {
                    $targetDir = Split-Path $targetPath -Parent
                    if (-not (Test-Path $targetDir)) {
                        New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
                    }
                    Copy-Item -Path $_.FullName -Destination $targetPath -Force
                }
            }
        } else {
            Copy-Item @copyParams
        }
        
        # Create metadata file
        $metadataPath = Join-Path $tempPath "BACKUP-INFO.txt"
        $metadata = @"
Portfolio Meta Backup
=====================

Backup Created: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Source: $metaPath
Backup Tool: Backup-PortfolioMeta.ps1
Git History Included: $IncludeGitHistory

This backup was created before running portfolio migration.

To restore:
1. Extract this ZIP to a temporary location
2. Copy 00-meta folder contents back to: $metaPath
3. Verify git status and test thoroughly

Created by: $env:USERNAME on $env:COMPUTERNAME
"@
        Set-Content -Path $metadataPath -Value $metadata -Encoding UTF8
        
        Write-Info "Creating ZIP archive..."
        [System.IO.Compression.ZipFile]::CreateFromDirectory(
            $tempPath,
            $backupZipPath,
            [System.IO.Compression.CompressionLevel]::Optimal,
            $false
        )
        
        # Clean up temp directory
        Remove-Item -Path $tempPath -Recurse -Force
        
        $backupSize = (Get-Item $backupZipPath).Length
        $backupSizeMB = [math]::Round($backupSize / 1MB, 2)
        
        Write-Success "Backup created successfully!"
        Write-Info "Location: $backupZipPath"
        Write-Info "Size: $backupSizeMB MB"
        
        return $backupZipPath
        
    } catch {
        Write-ErrorMsg "Backup failed: $_"
        
        # Clean up temp directory if it exists
        if (Test-Path $tempPath) {
            Remove-Item -Path $tempPath -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        throw
    }
}

# List existing backups
function Show-ExistingBackups {
    Write-Step "Checking for existing backups..."
    
    if (-not (Test-Path $BackupLocation)) {
        Write-Info "No backup directory found (this is the first backup)"
        return
    }
    
    $existingBackups = Get-ChildItem -Path $BackupLocation -Filter "00-meta-backup-*.zip" | Sort-Object LastWriteTime -Descending
    
    if ($existingBackups.Count -eq 0) {
        Write-Info "No existing backups found"
        return
    }
    
    Write-Host ""
    Write-Host "  Existing backups:" -ForegroundColor Cyan
    foreach ($backup in $existingBackups) {
        $sizeMB = [math]::Round($backup.Length / 1MB, 2)
        $age = (Get-Date) - $backup.LastWriteTime
        $ageStr = if ($age.Days -gt 0) { "$($age.Days) days ago" } 
                  elseif ($age.Hours -gt 0) { "$($age.Hours) hours ago" }
                  else { "$($age.Minutes) minutes ago" }
        
        Write-Host "    • $($backup.Name) ($sizeMB MB, $ageStr)" -ForegroundColor Gray
    }
    Write-Host ""
}

# Main execution
function Start-BackupProcess {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Backup Portfolio Meta - Safety before migration            " -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    if (-not (Test-Prerequisites)) {
        Write-ErrorMsg "Prerequisites check failed. Cannot continue."
        exit 1
    }
    
    Show-ExistingBackups
    
    Write-Host ""
    Write-Warning "This will create a complete backup of /00-meta before migration."
    Write-Info "Backup location: $BackupLocation"
    Write-Host ""
    
    $response = Read-Host "Create backup now? (Y/n)"
    if ($response -eq 'n' -or $response -eq 'N') {
        Write-Info "Cancelled by user"
        exit 0
    }
    
    try {
        $backupPath = New-MetaBackup
        
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Success "Backup completed successfully!"
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host ""
        Write-Info "Backup saved to:"
        Write-Host "  $backupPath" -ForegroundColor White
        Write-Host ""
        Write-Info "Next steps:"
        Write-Info "1. Verify the backup was created successfully"
        Write-Info "2. Consider copying backup to external drive for extra safety"
        Write-Info "3. Run Phase 0 Discovery: .\Phase0-Discovery.ps1"
        Write-Info "4. Proceed with migration phases when ready"
        Write-Host ""
        
    } catch {
        Write-Host ""
        Write-ErrorMsg "Backup process failed: $_"
        Write-Warning "Do not proceed with migration without a successful backup!"
        exit 1
    }
}

# Execute
Start-BackupProcess
