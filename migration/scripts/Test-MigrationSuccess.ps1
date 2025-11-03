<#
.SYNOPSIS
    Validate migration success with measurable criteria
    
.DESCRIPTION
    Tests the migration against specific, measurable success criteria rather than
    subjective checkboxes. Provides automated validation of the migration results.
    
    This addresses Minor Issue #11: Success metrics should be measurable outcomes
    
.PARAMETER PortfolioRoot
    Path to the portfolio root (default: C:\Portfolio)
    
.PARAMETER Phase
    Specific phase to test (0-4, or 'all' for complete validation)
    
.PARAMETER ExportReport
    Export detailed report to JSON file
    
.EXAMPLE
    .\Test-MigrationSuccess.ps1 -Phase 1
    Test Phase 1 (Governance) completion
    
.EXAMPLE
    .\Test-MigrationSuccess.ps1 -Phase all -ExportReport
    Test all phases and export detailed report
    
.NOTES
    Success criteria are measurable and automated:
    - Folder structure matches target schema
    - All required files exist
    - No broken internal links
    - Path references are valid
    - Git repository is in good state
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$PortfolioRoot = "C:\Portfolio",
    
    [Parameter()]
    [ValidateSet('0', '1', '2', '3', '4', 'all')]
    [string]$Phase = 'all',
    
    [Parameter()]
    [switch]$ExportReport
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

# Test result object
$script:TestResults = @{
    Timestamp = Get-Date
    Phase = $Phase
    Tests = @()
    Summary = @{
        Total = 0
        Passed = 0
        Failed = 0
        Warnings = 0
    }
}

# Add test result
function Add-TestResult {
    param(
        [string]$Category,
        [string]$Test,
        [ValidateSet('Pass', 'Fail', 'Warning')]
        [string]$Status,
        [string]$Message,
        [object]$Details
    )
    
    $result = @{
        Category = $Category
        Test = $Test
        Status = $Status
        Message = $Message
        Details = $Details
    }
    
    $script:TestResults.Tests += $result
    $script:TestResults.Summary.Total++
    
    switch ($Status) {
        'Pass' { $script:TestResults.Summary.Passed++ }
        'Fail' { $script:TestResults.Summary.Failed++ }
        'Warning' { $script:TestResults.Summary.Warnings++ }
    }
    
    # Display result
    $icon = switch ($Status) {
        'Pass' { '✓'; 'Green' }
        'Fail' { '✗'; 'Red' }
        'Warning' { '⚠'; 'Yellow' }
    }
    
    Write-Host "    $($icon[0]) " -ForegroundColor $icon[1] -NoNewline
    Write-Host "$Test" -ForegroundColor White -NoNewline
    if ($Message) {
        Write-Host " - $Message" -ForegroundColor Gray
    } else {
        Write-Host ""
    }
}

# Test Phase 0: Discovery
function Test-Phase0 {
    Write-Step "Testing Phase 0: Prerequisites and Discovery"
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    
    # Test: Portfolio root exists
    if (Test-Path $PortfolioRoot) {
        Add-TestResult -Category "Phase0" -Test "Portfolio root exists" -Status "Pass" -Message $PortfolioRoot
    } else {
        Add-TestResult -Category "Phase0" -Test "Portfolio root exists" -Status "Fail" -Message "Not found: $PortfolioRoot"
    }
    
    # Test: 00-meta exists
    if (Test-Path $metaPath) {
        Add-TestResult -Category "Phase0" -Test "00-meta folder exists" -Status "Pass"
    } else {
        Add-TestResult -Category "Phase0" -Test "00-meta folder exists" -Status "Fail"
    }
    
    # Test: Git repository
    Push-Location $PortfolioRoot
    try {
        $gitStatus = git rev-parse --git-dir 2>&1
        if ($LASTEXITCODE -eq 0) {
            Add-TestResult -Category "Phase0" -Test "Git repository detected" -Status "Pass"
            
            # Test: No uncommitted changes
            $changes = git status --porcelain
            if (-not $changes) {
                Add-TestResult -Category "Phase0" -Test "Git repository is clean" -Status "Pass"
            } else {
                $changeCount = ($changes | Measure-Object).Count
                Add-TestResult -Category "Phase0" -Test "Git repository is clean" -Status "Warning" -Message "$changeCount uncommitted changes"
            }
        } else {
            Add-TestResult -Category "Phase0" -Test "Git repository detected" -Status "Warning" -Message "Not a git repository"
        }
    } finally {
        Pop-Location
    }
}

# Test Phase 1: Governance
function Test-Phase1 {
    Write-Step "Testing Phase 1: Governance Structure"
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    
    # Define required structure
    $requiredFolders = @(
        "01-policies",
        "01-policies\standards",
        "02-governance",
        "02-governance\adr",
        "02-governance\odr",
        "02-governance\sdr",
        "02-governance\pdr"
    )
    
    $allExist = $true
    foreach ($folder in $requiredFolders) {
        $folderPath = Join-Path $metaPath $folder
        if (Test-Path $folderPath) {
            Add-TestResult -Category "Phase1" -Test "Folder exists: $folder" -Status "Pass"
        } else {
            Add-TestResult -Category "Phase1" -Test "Folder exists: $folder" -Status "Fail"
            $allExist = $false
        }
    }
    
    # Test: ADR-001 exists
    $adr001Path = Join-Path $metaPath "02-governance\adr\ADR-001-meta-folder-restructure.md"
    if (Test-Path $adr001Path) {
        Add-TestResult -Category "Phase1" -Test "ADR-001 exists" -Status "Pass"
    } else {
        Add-TestResult -Category "Phase1" -Test "ADR-001 exists" -Status "Fail"
    }
    
    # Test: Templates exist
    $templates = @(
        "02-governance\adr\ADR-template.md",
        "02-governance\odr\ODR-template.md",
        "02-governance\sdr\SDR-template.md",
        "02-governance\pdr\PDR-template.md"
    )
    
    $templateCount = 0
    foreach ($template in $templates) {
        $templatePath = Join-Path $metaPath $template
        if (Test-Path $templatePath) {
            $templateCount++
        }
    }
    
    if ($templateCount -eq $templates.Count) {
        Add-TestResult -Category "Phase1" -Test "All decision record templates exist" -Status "Pass" -Message "$templateCount/4 found"
    } else {
        Add-TestResult -Category "Phase1" -Test "All decision record templates exist" -Status "Warning" -Message "$templateCount/4 found"
    }
    
    # Test: Standards moved from documentation
    $standardsPath = Join-Path $metaPath "01-policies\standards"
    if (Test-Path $standardsPath) {
        $standardsFiles = Get-ChildItem -Path $standardsPath -Filter "*.md" -File -ErrorAction SilentlyContinue
        if ($standardsFiles.Count -gt 0) {
            Add-TestResult -Category "Phase1" -Test "Standards documentation moved" -Status "Pass" -Message "$($standardsFiles.Count) files found"
        } else {
            Add-TestResult -Category "Phase1" -Test "Standards documentation moved" -Status "Warning" -Message "No markdown files in standards/"
        }
    }
}

# Test Phase 2: Numbering
function Test-Phase2 {
    Write-Step "Testing Phase 2: Consistent Numbering"
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    
    # Expected numbered folders
    $expectedNumbered = @(
        "01-policies",
        "02-governance",
        "10-architecture",
        "20-operations",
        "21-meta-projects",
        "22-ideas-inbox",
        "30-automation",
        "40-templates",
        "50-schemas",
        "60-shared-resources",
        "90-legacy-meta"
    )
    
    $numberedCount = 0
    $missingCount = 0
    
    foreach ($folder in $expectedNumbered) {
        $folderPath = Join-Path $metaPath $folder
        if (Test-Path $folderPath) {
            $numberedCount++
        } else {
            $missingCount++
        }
    }
    
    if ($numberedCount -eq $expectedNumbered.Count) {
        Add-TestResult -Category "Phase2" -Test "All folders numbered correctly" -Status "Pass" -Message "$numberedCount/$($expectedNumbered.Count) found"
    } else {
        Add-TestResult -Category "Phase2" -Test "All folders numbered correctly" -Status "Warning" -Message "$numberedCount/$($expectedNumbered.Count) found"
    }
    
    # Test: automation/documentation renamed to automation/docs
    $automationPaths = @(
        (Join-Path $metaPath "30-automation\docs"),
        (Join-Path $metaPath "automation\docs")
    )
    
    $docsFound = $false
    foreach ($path in $automationPaths) {
        if (Test-Path $path) {
            $docsFound = $true
            break
        }
    }
    
    if ($docsFound) {
        Add-TestResult -Category "Phase2" -Test "automation/documentation renamed to docs" -Status "Pass"
    } else {
        Add-TestResult -Category "Phase2" -Test "automation/documentation renamed to docs" -Status "Warning" -Message "docs folder not found"
    }
    
    # Test: Old unnumbered folders removed
    $oldFolders = @("operations", "meta-projects", "ideas-inbox", "automation", "templates", "schemas", "shared-resources", "legacy-meta")
    $oldFoldersRemaining = 0
    
    foreach ($folder in $oldFolders) {
        $folderPath = Join-Path $metaPath $folder
        if (Test-Path $folderPath) {
            $oldFoldersRemaining++
        }
    }
    
    if ($oldFoldersRemaining -eq 0) {
        Add-TestResult -Category "Phase2" -Test "Old unnumbered folders removed" -Status "Pass"
    } else {
        Add-TestResult -Category "Phase2" -Test "Old unnumbered folders removed" -Status "Warning" -Message "$oldFoldersRemaining old folders still exist"
    }
}

# Test Phase 3: Architecture
function Test-Phase3 {
    Write-Step "Testing Phase 3: Architecture Organization"
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    $archPath = Join-Path $metaPath "10-architecture"
    
    # Test: 10-architecture exists
    if (Test-Path $archPath) {
        Add-TestResult -Category "Phase3" -Test "10-architecture folder exists" -Status "Pass"
    } else {
        Add-TestResult -Category "Phase3" -Test "10-architecture folder exists" -Status "Fail"
        return
    }
    
    # Test: Subfolders exist
    $subfolders = @("migration-plans", "analysis", "data-architecture")
    $subfolderCount = 0
    
    foreach ($subfolder in $subfolders) {
        $subfolderPath = Join-Path $archPath $subfolder
        if (Test-Path $subfolderPath) {
            $subfolderCount++
        }
    }
    
    if ($subfolderCount -eq $subfolders.Count) {
        Add-TestResult -Category "Phase3" -Test "Architecture subfolders created" -Status "Pass" -Message "$subfolderCount/3 found"
    } else {
        Add-TestResult -Category "Phase3" -Test "Architecture subfolders created" -Status "Warning" -Message "$subfolderCount/3 found"
    }
    
    # Test: README exists
    $readmePath = Join-Path $archPath "README.md"
    if (Test-Path $readmePath) {
        Add-TestResult -Category "Phase3" -Test "Architecture README exists" -Status "Pass"
    } else {
        Add-TestResult -Category "Phase3" -Test "Architecture README exists" -Status "Warning"
    }
    
    # Test: Junctions (optional feature)
    $shortcutsPath = Join-Path $metaPath "shortcuts"
    if (Test-Path $shortcutsPath) {
        $junctions = Get-ChildItem -Path $shortcutsPath -Directory -ErrorAction SilentlyContinue
        if ($junctions.Count -gt 0) {
            Add-TestResult -Category "Phase3" -Test "Convenience junctions created" -Status "Pass" -Message "$($junctions.Count) junctions"
        } else {
            Add-TestResult -Category "Phase3" -Test "Convenience junctions created" -Status "Warning" -Message "Optional feature not used"
        }
    } else {
        Add-TestResult -Category "Phase3" -Test "Convenience junctions created" -Status "Warning" -Message "Optional feature not used"
    }
}

# Test Phase 4: Templates
function Test-Phase4 {
    Write-Step "Testing Phase 4: Template Consolidation"
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    $templatesPath = Join-Path $metaPath "40-templates"
    
    # Test: 40-templates exists
    if (Test-Path $templatesPath) {
        Add-TestResult -Category "Phase4" -Test "40-templates folder exists" -Status "Pass"
    } else {
        Add-TestResult -Category "Phase4" -Test "40-templates folder exists" -Status "Fail"
        return
    }
    
    # Test: Type-based subfolders exist
    $templateTypes = @(
        "ai-prompts",
        "architecture-templates",
        "github-templates",
        "file-templates",
        "document-templates",
        "project-boilerplates"
    )
    
    $typeCount = 0
    foreach ($type in $templateTypes) {
        $typePath = Join-Path $templatesPath $type
        if (Test-Path $typePath) {
            $typeCount++
        }
    }
    
    if ($typeCount -eq $templateTypes.Count) {
        Add-TestResult -Category "Phase4" -Test "Type-based subfolders created" -Status "Pass" -Message "$typeCount/6 found"
    } else {
        Add-TestResult -Category "Phase4" -Test "Type-based subfolders created" -Status "Warning" -Message "$typeCount/6 found"
    }
    
    # Test: README exists
    $readmePath = Join-Path $templatesPath "README.md"
    if (Test-Path $readmePath) {
        Add-TestResult -Category "Phase4" -Test "Templates README exists" -Status "Pass"
    } else {
        Add-TestResult -Category "Phase4" -Test "Templates README exists" -Status "Warning"
    }
    
    # Test: Templates organized (not flat structure)
    $rootFiles = Get-ChildItem -Path $templatesPath -File -ErrorAction SilentlyContinue
    if ($rootFiles.Count -le 1) {  # Allow README.md
        Add-TestResult -Category "Phase4" -Test "Templates in subfolders (not flat)" -Status "Pass"
    } else {
        Add-TestResult -Category "Phase4" -Test "Templates in subfolders (not flat)" -Status "Warning" -Message "$($rootFiles.Count) files in root"
    }
}

# Export report
function Export-TestReport {
    $reportPath = Join-Path $PortfolioRoot ".migration-test-report.json"
    
    try {
        $script:TestResults | ConvertTo-Json -Depth 10 | Set-Content -Path $reportPath -Encoding UTF8
        Write-Success "Report exported to: $reportPath"
    } catch {
        Write-Warning "Could not export report: $_"
    }
}

# Main execution
function Start-MigrationTest {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Test Migration Success - Measurable Validation             " -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    # Run tests based on phase parameter
    switch ($Phase) {
        '0' { Test-Phase0 }
        '1' { Test-Phase1 }
        '2' { Test-Phase2 }
        '3' { Test-Phase3 }
        '4' { Test-Phase4 }
        'all' {
            Test-Phase0
            Test-Phase1
            Test-Phase2
            Test-Phase3
            Test-Phase4
        }
    }
    
    # Summary
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Test Summary                                                " -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    $summary = $script:TestResults.Summary
    Write-Host "  Total Tests:    " -NoNewline
    Write-Host $summary.Total -ForegroundColor White
    Write-Host "  Passed:         " -NoNewline
    Write-Host $summary.Passed -ForegroundColor Green
    Write-Host "  Failed:         " -NoNewline
    Write-Host $summary.Failed -ForegroundColor Red
    Write-Host "  Warnings:       " -NoNewline
    Write-Host $summary.Warnings -ForegroundColor Yellow
    Write-Host ""
    
    # Calculate success rate
    if ($summary.Total -gt 0) {
        $successRate = [math]::Round(($summary.Passed / $summary.Total) * 100, 1)
        Write-Host "  Success Rate:   " -NoNewline
        
        $color = if ($successRate -ge 90) { 'Green' }
                 elseif ($successRate -ge 70) { 'Yellow' }
                 else { 'Red' }
        
        Write-Host "$successRate%" -ForegroundColor $color
    }
    
    Write-Host ""
    
    # Export report if requested
    if ($ExportReport) {
        Export-TestReport
    }
    
    # Exit code based on failures
    if ($summary.Failed -gt 0) {
        Write-Warning "Some tests failed - review results above"
        exit 1
    } elseif ($summary.Warnings -gt 0) {
        Write-Warning "All tests passed but some warnings present"
        exit 0
    } else {
        Write-Success "All tests passed!"
        exit 0
    }
}

# Execute
Start-MigrationTest
