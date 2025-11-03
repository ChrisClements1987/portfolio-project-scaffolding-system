# Implementation

**Purpose:** Links to actual PPS implementation code

**Note:** Meta-project planning lives here. Actual code lives in `/00-meta/30-automation/` for reusability.

---

## Code Locations

### Governance & Security (Phase 1 - Completed)

**Location:** `/00-meta/30-automation/governance/`

- **[Deploy-SecurityConfigs.ps1](/00-meta/30-automation/governance/Deploy-SecurityConfigs.ps1)** - Batch deploy Dependabot/CodeQL configs
- **[Test-IsAICommit.ps1](/00-meta/30-automation/governance/Test-IsAICommit.ps1)** - AI detection module (Layers 1-2)
- **[pre-commit-hook.ps1](/00-meta/30-automation/governance/pre-commit-hook.ps1)** - Portfolio meta validation hook
- **[Install-PreCommitHook.ps1](/00-meta/30-automation/governance/Install-PreCommitHook.ps1)** - Hook installer

**Status:** ✅ Complete and deployed to 4 OSS repos

---

### Scaffolding System (Phase 2 - Planned)

**Location:** `/00-meta/30-automation/scaffolding/` *(to be created)*

**Planned scripts:**
- `pps.ps1` - Main CLI entry point
- `template-engine.ps1` - Variable substitution engine
- `github-integration.ps1` - GitHub repo creation (gh CLI)
- `apply-governance.ps1` - Apply governance configs
- `file-utils.ps1` - Safe file operations
- `config-manager.ps1` - Configuration management

**Status:** ⏳ In planning

---

### Templates (Phase 2 - Planned)

**Location:** `/00-meta/40-templates/project-boilerplates/`

**Templates to create:**
1. `python-cli-tool/` - CLI utilities
2. `powershell-utility/` - Windows tools
3. `minimal-experiment/` - Quick prototypes
4. `python-web-app/` - Web applications
5. `meta-project/` - Meta-project planning structure

**Status:** ⏳ In planning

---

### Schemas (Phase 1 - Complete)

**Location:** `/00-meta/50-schemas/`

- **[portfolio-meta.schema.json](/00-meta/50-schemas/portfolio-meta.schema.json)** - JSON Schema for validation
- **[portfolio-meta-template.yaml](/00-meta/50-schemas/portfolio-meta-template.yaml)** - Commented template

**Status:** ✅ Complete

---

## Development Workflow

**Plan in meta-project:**
1. Create ADRs, research, analysis in this folder
2. Define requirements in vision docs
3. Design architecture and interfaces

**Implement in automation:**
4. Write code in `/00-meta/30-automation/scaffolding/`
5. Create templates in `/00-meta/40-templates/project-boilerplates/`
6. Test with pilot projects

**Deploy & iterate:**
7. Use PPS to create real projects
8. Gather feedback
9. Refine templates and CLI

---

## Testing Approach

**Manual testing:**
- Create 3-5 projects using PPS
- Validate all features work
- Check governance configs active

**Pilot projects:**
- Graduate LifeQuest from ideas-inbox
- Create new minimal-experiment
- Test each template type

**Success criteria:**
- Zero manual setup steps needed
- All governance active from v0.1.0
- User feedback positive

---

## Version History

### 1.0.0 (2025-10-29)
- Implementation tracking structure created
- Linked to actual code locations
- Documented completed and planned work
