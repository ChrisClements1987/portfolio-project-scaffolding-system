<#
.SYNOPSIS
    Phase 0: Discovery and Pre-Flight Validation for Portfolio Meta Migration

.DESCRIPTION
    Analyzes current portfolio structure, identifies potential issues, and validates
    prerequisites before migration. This is a READ-ONLY script that makes no changes.

.NOTES
    Version: 1.0
    Date: 2025-10-30
    Author: Portfolio Migration Team
    
.EXAMPLE
    .\Phase0-Discovery.ps1
    
.EXAMPLE
    .\Phase0-Discovery.ps1 -Verbose
#>

[CmdletBinding()]
param(
    [string]$PortfolioRoot = "C:\Portfolio",
    [switch]$ExportReport
)

$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"

# Colors for output
$script:Colors = @{
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Info = "Cyan"
    Header = "Magenta"
}

function Write-SectionHeader {
    param([string]$Title)
    Write-Host "`n========================================" -ForegroundColor $Colors.Header
    Write-Host $Title -ForegroundColor $Colors.Header
    Write-Host "========================================`n" -ForegroundColor $Colors.Header
}

function Write-StatusMessage {
    param(
        [string]$Message,
        [ValidateSet("Success", "Warning", "Error", "Info")]
        [string]$Type = "Info"
    )
    
    $icon = switch ($Type) {
        "Success" { "✅" }
        "Warning" { "⚠️ " }
        "Error" { "❌" }
        "Info" { "ℹ️ " }
    }
    
    Write-Host "$icon $Message" -ForegroundColor $Colors[$Type]
}

# Initialize report
$report = @{
    Timestamp = Get-Date
    PortfolioRoot = $PortfolioRoot
    Checks = @()
    Issues = @()
    Warnings = @()
    Summary = @{}
}

Write-SectionHeader "Portfolio Meta Migration - Phase 0: Discovery"
Write-StatusMessage "Starting pre-flight validation..." "Info"
Write-StatusMessage "Portfolio Root: $PortfolioRoot" "Info"

# Check 1: Portfolio Root Exists
Write-SectionHeader "Check 1: Portfolio Root Validation"
try {
    if (Test-Path $PortfolioRoot) {
        Write-StatusMessage "Portfolio root exists" "Success"
        $report.Checks += "Portfolio root exists: PASS"
    } else {
        Write-StatusMessage "Portfolio root not found at: $PortfolioRoot" "Error"
        $report.Issues += "Portfolio root not found"
        throw "Portfolio root not found"
    }
} catch {
    $report.Issues += "CRITICAL: $_"
    Write-StatusMessage "CRITICAL ERROR: Cannot proceed without portfolio root" "Error"
    exit 1
}

# Check 2: 00-meta Folder Exists
Write-SectionHeader "Check 2: 00-meta Folder Validation"
$metaPath = Join-Path $PortfolioRoot "00-meta"
if (Test-Path $metaPath) {
    Write-StatusMessage "00-meta folder exists" "Success"
    $report.Checks += "00-meta exists: PASS"
} else {
    Write-StatusMessage "00-meta folder not found" "Error"
    $report.Issues += "00-meta folder missing"
    exit 1
}

# Check 3: Current Folder Structure
Write-SectionHeader "Check 3: Current Folder Structure Analysis"
$expectedFolders = @(
    "00-strategy",
    "architecture",
    "automation",
    "documentation",
    "ideas-inbox",
    "meta-projects",
    "operations",
    "schemas",
    "shared-resources",
    "templates"
)

$actualFolders = Get-ChildItem $metaPath -Directory | Where-Object { $_.Name -ne ".git" }
Write-StatusMessage "Found $($actualFolders.Count) folders in 00-meta" "Info"

foreach ($folder in $expectedFolders) {
    $exists = $actualFolders.Name -contains $folder
    if ($exists) {
        Write-Host "  ✅ $folder" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $folder (missing)" -ForegroundColor Yellow
        $report.Warnings += "Expected folder '$folder' not found"
    }
}

# Check for unexpected folders
$unexpectedFolders = $actualFolders | Where-Object { $expectedFolders -notcontains $_.Name }
if ($unexpectedFolders) {
    Write-StatusMessage "Found unexpected folders:" "Warning"
    foreach ($folder in $unexpectedFolders) {
        Write-Host "  ⚠️  $($folder.Name)" -ForegroundColor Yellow
        $report.Warnings += "Unexpected folder: $($folder.Name)"
    }
}

# Check 4: Automation/Governance Contents
Write-SectionHeader "Check 4: automation/governance Analysis"
$govPath = Join-Path $metaPath "automation\governance"
if (Test-Path $govPath) {
    $govFiles = Get-ChildItem $govPath -File
    Write-StatusMessage "Found $($govFiles.Count) files in automation/governance" "Info"
    foreach ($file in $govFiles) {
        Write-Host "  📄 $($file.Name)" -ForegroundColor Cyan
    }
    $report.Summary["automation/governance files"] = $govFiles.Count
} else {
    Write-StatusMessage "automation/governance not found" "Warning"
    $report.Warnings += "automation/governance folder missing"
}

# Check 5: Documentation Folder Contents
Write-SectionHeader "Check 5: documentation/ Analysis"
$docPath = Join-Path $metaPath "documentation"
if (Test-Path $docPath) {
    $docFiles = Get-ChildItem $docPath -File
    Write-StatusMessage "Found $($docFiles.Count) files in documentation/" "Info"
    foreach ($file in $docFiles) {
        Write-Host "  📄 $($file.Name)" -ForegroundColor Cyan
    }
    $report.Summary["documentation files"] = $docFiles.Count
    
    # Check for specific files
    $expectedDocs = @(
        "CODE-DOCUMENTATION-STANDARDS-V3.md",
        "README-STRATEGY.md",
        "README-TEMPLATE.md"
    )
    foreach ($doc in $expectedDocs) {
        if ($docFiles.Name -contains $doc) {
            Write-Host "  ✅ $doc found" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  $doc not found" -ForegroundColor Yellow
            $report.Warnings += "Expected document '$doc' not found"
        }
    }
} else {
    Write-StatusMessage "documentation/ not found" "Warning"
    $report.Warnings += "documentation/ folder missing"
}

# Check 6: Templates Structure
Write-SectionHeader "Check 6: Templates Analysis"
$templatesPath = Join-Path $metaPath "templates"
$sharedTemplatesPath = Join-Path $metaPath "shared-resources\templates"

if (Test-Path $templatesPath) {
    $templateFolders = Get-ChildItem $templatesPath -Directory
    Write-StatusMessage "templates/ contains: $($templateFolders.Count) folders" "Info"
    foreach ($folder in $templateFolders) {
        Write-Host "  📁 $($folder.Name)" -ForegroundColor Cyan
    }
}

if (Test-Path $sharedTemplatesPath) {
    $sharedTemplateFolders = Get-ChildItem $sharedTemplatesPath -Directory
    Write-StatusMessage "shared-resources/templates/ contains: $($sharedTemplateFolders.Count) folders" "Info"
    foreach ($folder in $sharedTemplateFolders) {
        Write-Host "  📁 $($folder.Name)" -ForegroundColor Cyan
    }
    
    # Check for conflict
    if ((Test-Path $templatesPath) -and (Test-Path $sharedTemplatesPath)) {
        $templatesProj = Join-Path $templatesPath "project-boilerplates"
        $sharedProj = Join-Path $sharedTemplatesPath "project-templates"
        if ((Test-Path $templatesProj) -and (Test-Path $sharedProj)) {
            Write-StatusMessage "CONFLICT: Both project-boilerplates and project-templates exist" "Warning"
            Write-Host "  ⚠️  Manual review required before Phase 4" -ForegroundColor Yellow
            $report.Warnings += "Template conflict: project-boilerplates vs project-templates"
        }
    }
}

# Check 7: Git Status
Write-SectionHeader "Check 7: Git Repository Status"
try {
    Push-Location $PortfolioRoot
    
    # Check if git repo
    $isGitRepo = Test-Path ".git"
    if ($isGitRepo) {
        Write-StatusMessage "Git repository detected" "Success"
        
        # Check for uncommitted changes
        $gitStatus = git status --porcelain 2>$null
        if ($gitStatus) {
            Write-StatusMessage "Uncommitted changes detected:" "Warning"
            Write-Host $gitStatus -ForegroundColor Yellow
            $report.Warnings += "Uncommitted changes exist - commit before migration"
        } else {
            Write-StatusMessage "Working directory clean" "Success"
        }
        
        # Check current branch
        $currentBranch = git rev-parse --abbrev-ref HEAD 2>$null
        Write-StatusMessage "Current branch: $currentBranch" "Info"
        $report.Summary["Git branch"] = $currentBranch
    } else {
        Write-StatusMessage "Not a git repository" "Warning"
        $report.Warnings += "Portfolio is not a git repository - backup is critical"
    }
} catch {
    Write-StatusMessage "Git not available or error checking status" "Warning"
    $report.Warnings += "Could not check git status: $_"
} finally {
    Pop-Location
}

# Check 8: Disk Space
Write-SectionHeader "Check 8: Disk Space Check"
try {
    $drive = Split-Path $PortfolioRoot -Qualifier
    $disk = Get-PSDrive $drive[0]
    $freeGB = [math]::Round($disk.Free / 1GB, 2)
    
    if ($freeGB -lt 2) {
        Write-StatusMessage "Low disk space: ${freeGB}GB free" "Warning"
        $report.Warnings += "Low disk space: ${freeGB}GB (recommend 2GB+ for backups)"
    } else {
        Write-StatusMessage "Disk space: ${freeGB}GB free" "Success"
    }
    $report.Summary["Free disk space (GB)"] = $freeGB
} catch {
    Write-StatusMessage "Could not check disk space" "Warning"
}

# Check 9: Open Files/Processes
Write-SectionHeader "Check 9: Process Check"
try {
    $portfolioProcesses = Get-Process | Where-Object {
        $_.Path -and $_.Path -like "*$PortfolioRoot*"
    }
    
    if ($portfolioProcesses) {
        Write-StatusMessage "Processes accessing portfolio:" "Warning"
        foreach ($proc in $portfolioProcesses) {
            Write-Host "  ⚠️  $($proc.Name) - $($proc.Path)" -ForegroundColor Yellow
        }
        $report.Warnings += "Close all editors/terminals before migration"
    } else {
        Write-StatusMessage "No processes detected accessing portfolio" "Success"
    }
} catch {
    Write-StatusMessage "Could not check processes" "Info"
}

# Check 10: Path Reference Analysis
Write-SectionHeader "Check 10: Path Reference Analysis (Sample)"
$oldPaths = @("00-meta/01-policies", "00-meta/10-architecture", "automation/governance")
$sampleCount = 0

foreach ($oldPath in $oldPaths) {
    $matches = Get-ChildItem $metaPath -Filter "*.md" -Recurse -ErrorAction SilentlyContinue |
        Select-String -Pattern $oldPath -SimpleMatch -ErrorAction SilentlyContinue |
        Select-Object -First 5
    
    if ($matches) {
        $sampleCount += $matches.Count
    }
}

if ($sampleCount -gt 0) {
    Write-StatusMessage "Found references to old paths (sample: $sampleCount)" "Warning"
    Write-Host "  ℹ️  Run Find-PathReferences.ps1 for complete analysis" -ForegroundColor Cyan
    $report.Warnings += "Path references will need updating post-migration"
} else {
    Write-StatusMessage "No obvious old path references found (sample check)" "Info"
}

# Generate Summary
Write-SectionHeader "Discovery Summary"

$report.Summary["Total checks"] = $report.Checks.Count
$report.Summary["Issues found"] = $report.Issues.Count
$report.Summary["Warnings"] = $report.Warnings.Count

Write-Host "Checks performed: $($report.Checks.Count)" -ForegroundColor Cyan
Write-Host "Issues found: $($report.Issues.Count)" -ForegroundColor $(if ($report.Issues.Count -gt 0) { "Red" } else { "Green" })
Write-Host "Warnings: $($report.Warnings.Count)" -ForegroundColor $(if ($report.Warnings.Count -gt 0) { "Yellow" } else { "Green" })

if ($report.Issues.Count -gt 0) {
    Write-Host "`nCRITICAL ISSUES:" -ForegroundColor Red
    foreach ($issue in $report.Issues) {
        Write-Host "  ❌ $issue" -ForegroundColor Red
    }
}

if ($report.Warnings.Count -gt 0) {
    Write-Host "`nWARNINGS:" -ForegroundColor Yellow
    foreach ($warning in $report.Warnings) {
        Write-Host "  ⚠️  $warning" -ForegroundColor Yellow
    }
}

# Recommendations
Write-SectionHeader "Recommendations"

if ($report.Issues.Count -eq 0) {
    Write-StatusMessage "Structure is ready for migration" "Success"
    Write-Host "`nNext steps:" -ForegroundColor Cyan
    Write-Host "  1. Commit any uncommitted changes" -ForegroundColor White
    Write-Host "  2. Run: .\Backup-PortfolioMeta.ps1" -ForegroundColor White
    Write-Host "  3. Create git tag: git tag pre-meta-migration-$(Get-Date -Format 'yyyyMMdd')" -ForegroundColor White
    Write-Host "  4. Run: .\Phase1-Governance.ps1" -ForegroundColor White
} else {
    Write-StatusMessage "Fix critical issues before proceeding" "Error"
}

# Export report
if ($ExportReport) {
    $reportPath = Join-Path $metaPath ".migration-discovery-report.json"
    $report | ConvertTo-Json -Depth 10 | Out-File $reportPath -Encoding UTF8
    Write-StatusMessage "Report exported to: $reportPath" "Success"
}

# Also create human-readable report
$textReportPath = Join-Path $metaPath ".migration-discovery-report.txt"
$reportText = @"
Portfolio Meta Migration - Discovery Report
Generated: $(Get-Date -Format "yyyy-MM-DD HH:mm:ss")
Portfolio Root: $PortfolioRoot

SUMMARY
=======
Total Checks: $($report.Checks.Count)
Issues Found: $($report.Issues.Count)
Warnings: $($report.Warnings.Count)

CHECKS PERFORMED
===============
$($report.Checks | ForEach-Object { "- $_" } | Out-String)

ISSUES
======
$($report.Issues | ForEach-Object { "- $_" } | Out-String)

WARNINGS
========
$($report.Warnings | ForEach-Object { "- $_" } | Out-String)

NEXT STEPS
==========
$(if ($report.Issues.Count -eq 0) {
    "✅ Ready to proceed with migration
1. Commit any uncommitted changes
2. Create backup: .\Backup-PortfolioMeta.ps1
3. Create git tag: git tag pre-meta-migration-$(Get-Date -Format 'yyyyMMdd')
4. Run Phase 1: .\Phase1-Governance.ps1"
} else {
    "❌ Fix critical issues before proceeding:
$($report.Issues | ForEach-Object { "   - $_" } | Out-String)"
})
"@

$reportText | Out-File $textReportPath -Encoding UTF8
Write-StatusMessage "Text report exported to: $textReportPath" "Success"

Write-Host "`n========================================" -ForegroundColor $Colors.Header
Write-Host "Phase 0: Discovery Complete" -ForegroundColor $Colors.Header
Write-Host "========================================`n" -ForegroundColor $Colors.Header

# Return success/failure
if ($report.Issues.Count -gt 0) {
    exit 1
} else {
    exit 0
}
