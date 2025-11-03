<#
.SYNOPSIS
    Phase 4: Templates - Consolidate templates with type-based organization
    
.DESCRIPTION
    This script implements Phase 4 of the /00-meta migration by consolidating
    templates from multiple locations into a single type-based hierarchy.
    
    CRITICAL CORRECTIONS FROM CRITIQUE:
    - Uses type-based subfolders (not forcing all into one flat folder)
    - Prompts for manual review when project-templates exists
    - Preserves template types: ai-prompts, architecture-templates, github-templates, etc.
    
.PARAMETER PortfolioRoot
    Path to the portfolio root (default: C:\Portfolio)
    
.PARAMETER DryRun
    If specified, shows what would be done without making changes
    
.PARAMETER Force
    Skip confirmation prompts (use with caution)
    
.EXAMPLE
    .\Phase4-Templates.ps1 -DryRun
    Preview changes without executing
    
.EXAMPLE
    .\Phase4-Templates.ps1
    Execute Phase 4 with confirmation prompts
    
.NOTES
    Prerequisites:
    - Phase 3 (Architecture) must be completed
    - Git repository should be clean
    - Backup recommended before running
    
    This script addresses:
    - Critical Issue #2: Type-based template consolidation
    - Template organization with proper categorization
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
    
    # Check Phase 3 was completed (should have 10-architecture)
    $archPath = Join-Path $metaPath "10-architecture"
    if (-not (Test-Path $archPath)) {
        Write-ErrorMsg "Phase 3 not completed - 10-architecture folder not found"
        Write-Info "Run Phase3-Architecture.ps1 first"
        return $false
    }
    Write-Success "Phase 3 (Architecture) detected"
    
    # Check git status
    Push-Location $PortfolioRoot
    try {
        $gitStatus = git status --porcelain 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Not a git repository - changes won't be tracked"
        } elseif ($gitStatus) {
            Write-Warning "Git repository has uncommitted changes"
            Write-Info "Consider committing changes from Phase 3 first"
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
            git commit -m "Migration Phase 4 - Checkpoint: $Message" -m "Automated checkpoint during Phase 4 (Templates) migration"
            Write-Success "Git checkpoint created: $Message"
        }
    } catch {
        Write-Warning "Could not create git checkpoint: $_"
    } finally {
        Pop-Location
    }
}

# Ensure templates folder is numbered
function Set-TemplatesNumbering {
    Write-Step "Ensuring templates folder is numbered..."
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    $oldPath = Join-Path $metaPath "templates"
    $newPath = Join-Path $metaPath "40-templates"
    
    if (Test-Path $newPath) {
        Write-Success "Already numbered: 40-templates"
        return $newPath
    }
    
    if (-not (Test-Path $oldPath)) {
        # Create if doesn't exist
        if ($DryRun) {
            Write-Info "[DRY RUN] Would create: 40-templates/"
            return $oldPath
        }
        
        New-Item -Path $newPath -ItemType Directory -Force | Out-Null
        Write-Success "Created: 40-templates/"
        return $newPath
    }
    
    if ($DryRun) {
        Write-Info "[DRY RUN] Would rename: templates → 40-templates"
        return $oldPath
    }
    
    try {
        Rename-Item -Path $oldPath -NewName "40-templates" -Force
        Write-Success "Renamed: templates → 40-templates"
        return $newPath
    } catch {
        Write-ErrorMsg "Failed to rename templates folder: $_"
        return $null
    }
}

# Create type-based subfolder structure (Critical Issue #2 correction)
function New-TemplateTypeStructure {
    Write-Step "Creating type-based template structure..."
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    $templatesPath = Join-Path $metaPath "40-templates"
    
    if (-not (Test-Path $templatesPath)) {
        $templatesPath = Join-Path $metaPath "templates"
    }
    
    # Define template type subfolders
    $templateTypes = @(
        @{ Name = "ai-prompts"; Desc = "AI prompt templates and patterns" }
        @{ Name = "architecture-templates"; Desc = "Architecture documentation templates" }
        @{ Name = "github-templates"; Desc = "GitHub issue/PR templates" }
        @{ Name = "file-templates"; Desc = "Generic file templates (.gitignore, .editorconfig, etc.)" }
        @{ Name = "document-templates"; Desc = "Document templates (README, changelog, etc.)" }
        @{ Name = "project-boilerplates"; Desc = "Full project scaffolding templates" }
    )
    
    foreach ($type in $templateTypes) {
        $typePath = Join-Path $templatesPath $type.Name
        
        if ($DryRun) {
            Write-Info "[DRY RUN] Would create: 40-templates/$($type.Name)/"
        } else {
            if (-not (Test-Path $typePath)) {
                New-Item -Path $typePath -ItemType Directory -Force | Out-Null
                Write-Success "Created: $($type.Name)/"
            } else {
                Write-Info "Already exists: $($type.Name)/"
            }
        }
    }
}

# Move templates from documentation folder
function Move-DocumentationTemplates {
    Write-Step "Moving templates from documentation folder..."
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    
    # Check both old and new paths for documentation folder
    $docPaths = @(
        (Join-Path $metaPath "documentation"),
        (Join-Path $metaPath "01-policies\documentation"),  # If moved in Phase 1
        (Join-Path $metaPath "30-automation\docs")  # If renamed in Phase 2
    )
    
    $templatesPath = Join-Path $metaPath "40-templates"
    if (-not (Test-Path $templatesPath)) {
        $templatesPath = Join-Path $metaPath "templates"
    }
    
    $foundTemplates = $false
    
    foreach ($docPath in $docPaths) {
        $docTemplatePath = Join-Path $docPath "templates"
        
        if (-not (Test-Path $docTemplatePath)) {
            continue
        }
        
        $foundTemplates = $true
        Write-Info "Found templates in: $docPath"
        
        # Get all template files
        $templateFiles = Get-ChildItem -Path $docTemplatePath -File -ErrorAction SilentlyContinue
        
        foreach ($file in $templateFiles) {
            # Determine destination based on file name
            $destSubfolder = "document-templates"  # Default
            
            if ($file.Name -match "README|CHANGELOG|CONTRIBUTING") {
                $destSubfolder = "document-templates"
            }
            
            $destPath = Join-Path $templatesPath "$destSubfolder\$($file.Name)"
            
            if ($DryRun) {
                Write-Info "[DRY RUN] Would move: $($file.Name) → 40-templates/$destSubfolder/"
            } else {
                if (-not (Test-Path $destPath)) {
                    Copy-Item -Path $file.FullName -Destination $destPath -Force
                    Write-Success "Moved: $($file.Name) → $destSubfolder/"
                } else {
                    Write-Warning "Already exists: $destSubfolder/$($file.Name)"
                }
            }
        }
    }
    
    if (-not $foundTemplates) {
        Write-Info "No documentation/templates folder found"
    }
}

# Move templates from shared-resources
function Move-SharedResourcesTemplates {
    Write-Step "Moving templates from shared-resources folder..."
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    
    # Check both old and new paths
    $sharedPaths = @(
        (Join-Path $metaPath "shared-resources"),
        (Join-Path $metaPath "60-shared-resources")
    )
    
    $templatesPath = Join-Path $metaPath "40-templates"
    if (-not (Test-Path $templatesPath)) {
        $templatesPath = Join-Path $metaPath "templates"
    }
    
    $foundTemplates = $false
    
    foreach ($sharedPath in $sharedPaths) {
        $sharedTemplatePath = Join-Path $sharedPath "templates"
        
        if (-not (Test-Path $sharedTemplatePath)) {
            continue
        }
        
        $foundTemplates = $true
        Write-Info "Found templates in: $sharedPath"
        
        # Get all items (files and folders)
        $items = Get-ChildItem -Path $sharedTemplatePath -ErrorAction SilentlyContinue
        
        foreach ($item in $items) {
            if ($item.PSIsContainer) {
                # Handle folders (like project-boilerplates)
                $destPath = Join-Path $templatesPath $item.Name
                
                if ($DryRun) {
                    Write-Info "[DRY RUN] Would move folder: $($item.Name) → 40-templates/"
                } else {
                    if (-not (Test-Path $destPath)) {
                        Copy-Item -Path $item.FullName -Destination $destPath -Recurse -Force
                        Write-Success "Moved folder: $($item.Name)/"
                    } else {
                        Write-Warning "Folder already exists: $($item.Name) - manual merge may be needed"
                    }
                }
            } else {
                # Handle individual files - categorize by type
                $destSubfolder = "file-templates"  # Default
                
                if ($item.Name -match "\.md$") {
                    $destSubfolder = "document-templates"
                }
                
                $destPath = Join-Path $templatesPath "$destSubfolder\$($item.Name)"
                
                if ($DryRun) {
                    Write-Info "[DRY RUN] Would move: $($item.Name) → 40-templates/$destSubfolder/"
                } else {
                    if (-not (Test-Path $destPath)) {
                        Copy-Item -Path $item.FullName -Destination $destPath -Force
                        Write-Success "Moved: $($item.Name) → $destSubfolder/"
                    } else {
                        Write-Warning "Already exists: $destSubfolder/$($item.Name)"
                    }
                }
            }
        }
    }
    
    if (-not $foundTemplates) {
        Write-Info "No shared-resources/templates folder found"
    }
}

# Handle project-templates conflict (Critical Issue #2 mitigation)
function Test-ProjectTemplatesConflict {
    Write-Step "Checking for project-templates conflicts..."
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    $templatesPath = Join-Path $metaPath "40-templates"
    if (-not (Test-Path $templatesPath)) {
        $templatesPath = Join-Path $metaPath "templates"
    }
    
    $existingProjectTemplates = Join-Path $templatesPath "project-templates"
    $incomingProjectBoilerplates = Join-Path $templatesPath "project-boilerplates"
    
    if ((Test-Path $existingProjectTemplates) -and (Test-Path $incomingProjectBoilerplates)) {
        Write-Host ""
        Write-Warning "CONFLICT DETECTED: Both project-templates/ and project-boilerplates/ exist"
        Write-Host ""
        Write-Info "Manual action required:"
        Write-Info "1. Review contents of both folders:"
        Write-Info "   - $existingProjectTemplates"
        Write-Info "   - $incomingProjectBoilerplates"
        Write-Info "2. Merge or choose which to keep"
        Write-Info "3. Rename appropriately for clarity"
        Write-Host ""
        
        if (-not $DryRun -and -not $Force) {
            Write-Host "Press any key to acknowledge and continue..." -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
        return $true
    }
    
    Write-Success "No project-templates conflicts detected"
    return $false
}

# Create templates README
function New-TemplatesReadme {
    Write-Step "Creating templates README..."
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    $templatesPath = Join-Path $metaPath "40-templates"
    
    if (-not (Test-Path $templatesPath)) {
        $templatesPath = Join-Path $metaPath "templates"
    }
    
    $readmePath = Join-Path $templatesPath "README.md"
    
    $readmeContent = @"
# Templates

Centralized template library organized by type.

## Structure

- **ai-prompts/** - AI prompt templates and patterns for LLM interactions
- **architecture-templates/** - Architecture documentation templates (system design docs, RFC templates)
- **github-templates/** - GitHub-specific templates (issue templates, PR templates, workflows)
- **file-templates/** - Generic file templates (.gitignore, .editorconfig, .prettierrc, etc.)
- **document-templates/** - Document templates (README, changelog, contributing guides)
- **project-boilerplates/** - Full project scaffolding templates (complete starter projects)

## Purpose

Templates provide **reusable starting points** for common artifacts:
- Consistent formatting and structure
- Best practices baked in
- Reduce setup time for new projects/documents
- Maintain portfolio-wide standards

## Usage

### For Documents
1. Copy template to your target location
2. Fill in the placeholder sections
3. Customize as needed for your specific use case

### For Projects
1. Use project-boilerplates as starting point
2. Run any setup scripts included
3. Customize for your specific project needs
4. Remove template-specific markers

## Template Types Explained

### AI Prompts
Templates for interacting with AI assistants:
- Code review prompts
- Documentation generation prompts
- Analysis and refactoring prompts

### Architecture Templates
System design documentation:
- RFC (Request for Comments) templates
- System design documents
- Technical specifications

### GitHub Templates
Repository-specific templates:
- Issue templates (bug reports, feature requests)
- Pull request templates
- GitHub Actions workflow templates

### File Templates
Configuration and standard files:
- .gitignore patterns for different languages
- .editorconfig for code style
- .prettierrc, .eslintrc, etc.

### Document Templates
Markdown and documentation:
- README.md templates
- CHANGELOG.md templates
- CONTRIBUTING.md templates
- Code of conduct templates

### Project Boilerplates
Complete project scaffolds:
- Language-specific starters
- Framework-specific starters
- Multi-file project structures with build configs

## Related Folders

- See **/02-governance/pdr/** for policy decisions about template standards
- See **/01-policies/standards/** for documentation standards that templates implement
- See **/30-automation/scripts/** for template generation and scaffolding tools

## Contributing Templates

When adding new templates:
1. Choose the correct type-based subfolder
2. Use clear, descriptive filenames
3. Include placeholder text in UPPERCASE or {braces}
4. Add comments explaining each section
5. Document template usage in comments or accompanying README
"@

    if ($DryRun) {
        Write-Info "[DRY RUN] Would create: 40-templates/README.md"
    } else {
        Set-Content -Path $readmePath -Value $readmeContent -Encoding UTF8
        Write-Success "Created: README.md"
    }
}

# Create type-specific READMEs
function New-TypeReadmes {
    Write-Step "Creating type-specific README files..."
    
    $metaPath = Join-Path $PortfolioRoot "00-meta"
    $templatesPath = Join-Path $metaPath "40-templates"
    
    if (-not (Test-Path $templatesPath)) {
        $templatesPath = Join-Path $metaPath "templates"
    }
    
    # Project boilerplates README
    $boilerplatesReadme = @"
# Project Boilerplates

Full project scaffolding templates for different languages, frameworks, and project types.

## Usage

1. Copy the entire boilerplate folder to your target location
2. Rename folder to your project name
3. Run any setup scripts (if included)
4. Customize configuration files
5. Remove template-specific markers and documentation

## Available Boilerplates

Each subfolder is a complete, ready-to-use project structure. Check individual README files within each boilerplate for specific setup instructions.

## Creating New Boilerplates

When adding a new boilerplate:
1. Include all necessary configuration files
2. Add a README.md explaining setup steps
3. Use placeholder names that are easy to find/replace
4. Include any automation scripts for setup
5. Test the boilerplate on a fresh system
"@

    $readmes = @{
        "project-boilerplates\README.md" = $boilerplatesReadme
    }
    
    foreach ($readme in $readmes.GetEnumerator()) {
        $readmePath = Join-Path $templatesPath $readme.Key
        $readmeDir = Split-Path $readmePath -Parent
        
        if ($DryRun) {
            Write-Info "[DRY RUN] Would create: 40-templates/$($readme.Key)"
        } else {
            if (Test-Path $readmeDir) {
                if (-not (Test-Path $readmePath)) {
                    Set-Content -Path $readmePath -Value $readme.Value -Encoding UTF8
                    Write-Success "Created: $($readme.Key)"
                } else {
                    Write-Info "Already exists: $($readme.Key)"
                }
            } else {
                Write-Info "Skipping (folder doesn't exist): $($readme.Key)"
            }
        }
    }
}

# Main execution
function Start-Phase4Migration {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Phase 4: Templates - Consolidate with type-based structure " -ForegroundColor Cyan
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
        Write-Warning "This will consolidate templates from multiple locations into type-based structure."
        Write-Warning "This implements corrections from Critical Issue #2 (type-based organization)."
        Write-Host ""
        Write-Info "Changes:"
        Write-Info "  • Rename templates → 40-templates (if needed)"
        Write-Info "  • Create type subfolders: ai-prompts/, architecture-templates/, github-templates/, etc."
        Write-Info "  • Move templates from documentation/ and shared-resources/"
        Write-Info "  • Organize templates by type, not source location"
        Write-Host ""
        $response = Read-Host "Continue with Phase 4? (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Info "Cancelled by user"
            exit 0
        }
    }
    
    # Create initial checkpoint
    New-GitCheckpoint -Message "Before Phase 4 - Templates"
    
    # Execute phase steps
    try {
        Set-TemplatesNumbering
        New-TemplateTypeStructure
        Move-DocumentationTemplates
        Move-SharedResourcesTemplates
        Test-ProjectTemplatesConflict
        New-TemplatesReadme
        New-TypeReadmes
        
        # Final checkpoint
        New-GitCheckpoint -Message "After Phase 4 - Templates completed"
        
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Success "Phase 4 completed successfully!"
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host ""
        Write-Info "Next steps:"
        Write-Info "1. Review the consolidated template structure"
        Write-Info "2. Check for any conflicts (especially project-templates vs project-boilerplates)"
        Write-Info "3. Verify templates moved to correct type-based folders"
        Write-Info "4. Run Find-PathReferences.ps1 to identify broken links"
        Write-Host ""
        Write-Warning "NOTE: Old template locations may still exist - review and clean up manually"
        Write-Host ""
        
    } catch {
        Write-Host ""
        Write-ErrorMsg "Phase 4 failed: $_"
        Write-Warning "You can rollback using: .\Rollback-Phase4.ps1"
        exit 1
    }
}

# Execute
Start-Phase4Migration
