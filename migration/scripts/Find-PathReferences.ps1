<#
.SYNOPSIS
    Find all references to old meta folder paths
    
.DESCRIPTION
    Scans the portfolio for references to old meta folder paths that need updating
    after the migration. Exports findings to CSV for review before bulk updates.
    
    This addresses Moderate Issue #5: Impact analysis for path reference updates
    
.PARAMETER PortfolioRoot
    Path to the portfolio root (default: C:\Portfolio)
    
.PARAMETER FileTypes
    File extensions to scan (default: .md, .yaml, .yml, .ps1, .json)
    
.PARAMETER ExportPath
    Where to save the CSV report (default: .path-references-found.csv)
    
.EXAMPLE
    .\Find-PathReferences.ps1
    Scan for path references with default settings
    
.EXAMPLE
    .\Find-PathReferences.ps1 -FileTypes ".md",".ps1"
    Scan only markdown and PowerShell files
    
.NOTES
    Creates CSV with columns: FilePath, LineNumber, OldPath, SuggestedNewPath, Context
    Review the CSV before running Update-PathReferences.ps1
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$PortfolioRoot = "C:\Portfolio",
    
    [Parameter()]
    [string[]]$FileTypes = @('.md', '.yaml', '.yml', '.ps1', '.json', '.txt'),
    
    [Parameter()]
    [string]$ExportPath
)

#Requires -Version 5.1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Set default export path
if (-not $ExportPath) {
    $ExportPath = Join-Path $PortfolioRoot ".path-references-found.csv"
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

function Write-Info {
    param([string]$Message)
    Write-Host "    ℹ " -ForegroundColor Blue -NoNewline
    Write-Host $Message -ForegroundColor Gray
}

# Path mapping: old path → new path
$script:PathMappings = @{
    '00-meta/10-architecture' = '00-meta/10-architecture'
    '00-meta/20-operations' = '00-meta/20-operations'
    '00-meta/21-meta-projects' = '00-meta/21-meta-projects'
    '00-meta/22-ideas-inbox' = '00-meta/22-ideas-inbox'
    '00-meta/30-automation' = '00-meta/30-automation'
    '00-meta/30-automation/documentation' = '00-meta/30-automation/automation-docs'
    '00-meta/30-automation/docs' = '00-meta/30-automation/automation-docs'
    '00-meta/40-templates' = '00-meta/40-templates'
    '00-meta/40-templates/project-templates' = '00-meta/40-templates/concept-boilerplates'
    '00-meta/40-templates/architecture-templates' = '00-meta/40-templates/workflow-templates/architecture-templates'
    '00-meta/50-schemas' = '00-meta/50-schemas'
    '00-meta/60-shared-resources' = '00-meta/60-shared-resources'
    '00-meta/90-legacy-meta' = '00-meta/90-legacy-meta'
    '00-meta/01-policies' = '00-meta/01-policies'
    '00-meta/02-governance' = '00-meta/02-governance'
    '00-meta/20-operations/projects' = '00-meta/20-operations'
}

# Results collection
$script:Findings = @()

# Find files to scan
function Get-FilesToScan {
    Write-Step "Finding files to scan..."
    
    $files = @()
    
    foreach ($ext in $FileTypes) {
        $foundFiles = Get-ChildItem -Path $PortfolioRoot -Filter "*$ext" -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notlike "*\.git\*" -and $_.FullName -notlike "*\node_modules\*" }
        
        $files += $foundFiles
    }
    
    $files = $files | Sort-Object -Property FullName -Unique
    
    Write-Success "Found $($files.Count) files to scan"
    Write-Info "File types: $($FileTypes -join ', ')"
    
    return $files
}

# Get suggested new path
function Get-SuggestedPath {
    param([string]$OldPath)
    
    # Normalize path separators
    $normalized = $OldPath -replace '\\', '/'
    
    # Try exact match first
    foreach ($mapping in $script:PathMappings.GetEnumerator()) {
        if ($normalized -match [regex]::Escape($mapping.Key)) {
            return $normalized -replace [regex]::Escape($mapping.Key), $mapping.Value
        }
    }
    
    return $null
}

# Scan file for path references
function Search-FileForPaths {
    param([System.IO.FileInfo]$File)
    
    try {
        $content = Get-Content -Path $File.FullName -ErrorAction Stop
        $lineNumber = 0
        
        foreach ($line in $content) {
            $lineNumber++
            
            # Check each old path pattern
            foreach ($mapping in $script:PathMappings.GetEnumerator()) {
                $oldPath = $mapping.Key
                
                # Create regex patterns for different path formats
                $patterns = @(
                    $oldPath,  # Forward slashes
                    ($oldPath -replace '/', '\\'),  # Backslashes
                    ($oldPath -replace '/', '\\\\')  # Escaped backslashes
                )
                
                foreach ($pattern in $patterns) {
                    if ($line -match [regex]::Escape($pattern)) {
                        $suggestedPath = Get-SuggestedPath -OldPath $pattern
                        
                        # Get context (truncate if too long)
                        $context = $line.Trim()
                        if ($context.Length -gt 100) {
                            $context = $context.Substring(0, 97) + "..."
                        }
                        
                        $finding = [PSCustomObject]@{
                            FilePath = $File.FullName -replace [regex]::Escape($PortfolioRoot), ''
                            LineNumber = $lineNumber
                            OldPath = $pattern
                            SuggestedNewPath = $suggestedPath
                            Context = $context
                            FileType = $File.Extension
                        }
                        
                        $script:Findings += $finding
                        break  # Only record once per line
                    }
                }
            }
        }
    } catch {
        Write-Warning "Could not scan $($File.Name): $_"
    }
}

# Export findings
function Export-Findings {
    Write-Step "Exporting findings to CSV..."
    
    if ($script:Findings.Count -eq 0) {
        Write-Success "No path references found - migration paths already updated or not used"
        return
    }
    
    try {
        $script:Findings | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
        Write-Success "Exported $($script:Findings.Count) findings to:"
        Write-Host "  $ExportPath" -ForegroundColor White
    } catch {
        Write-Warning "Could not export CSV: $_"
    }
}

# Show summary
function Show-FindingsSummary {
    Write-Step "Summary of findings"
    
    if ($script:Findings.Count -eq 0) {
        Write-Success "No path references found!"
        return
    }
    
    # Group by old path
    $byPath = $script:Findings | Group-Object -Property OldPath | Sort-Object Count -Descending
    
    Write-Host ""
    Write-Host "  Path references found:" -ForegroundColor Cyan
    foreach ($group in $byPath) {
        Write-Host "    • " -ForegroundColor Yellow -NoNewline
        Write-Host "$($group.Name)" -ForegroundColor White -NoNewline
        Write-Host " ($($group.Count) occurrences)" -ForegroundColor Gray
    }
    
    # Group by file type
    $byType = $script:Findings | Group-Object -Property FileType | Sort-Object Count -Descending
    
    Write-Host ""
    Write-Host "  By file type:" -ForegroundColor Cyan
    foreach ($group in $byType) {
        Write-Host "    • " -ForegroundColor Blue -NoNewline
        Write-Host "$($group.Name)" -ForegroundColor White -NoNewline
        Write-Host " ($($group.Count) references)" -ForegroundColor Gray
    }
    
    Write-Host ""
}

# Main execution
function Start-PathSearch {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Find Path References - Impact Analysis                     " -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    # Get files to scan
    $files = Get-FilesToScan
    
    if ($files.Count -eq 0) {
        Write-Warning "No files found to scan"
        exit 0
    }
    
    # Scan files
    Write-Step "Scanning files for old path references..."
    Write-Info "This may take a moment..."
    
    $progress = 0
    $total = $files.Count
    
    foreach ($file in $files) {
        $progress++
        
        # Show progress every 50 files
        if ($progress % 50 -eq 0 -or $progress -eq $total) {
            Write-Progress -Activity "Scanning files" -Status "$progress of $total" -PercentComplete (($progress / $total) * 100)
        }
        
        Search-FileForPaths -File $file
    }
    
    Write-Progress -Activity "Scanning files" -Completed
    Write-Success "Scan complete"
    
    # Show summary
    Show-FindingsSummary
    
    # Export results
    if ($script:Findings.Count -gt 0) {
        Export-Findings
    }
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Success "Path reference scan completed!"
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    
    if ($script:Findings.Count -gt 0) {
        Write-Info "Next steps:"
        Write-Info "1. Review the CSV file: $ExportPath"
        Write-Info "2. Verify suggested new paths are correct"
        Write-Info "3. Run Update-PathReferences.ps1 to apply updates"
        Write-Host ""
    }
}

# Execute
Start-PathSearch
