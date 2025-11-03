# Portfolio Project Scaffolding System (PPS)

**Version:** 1.0.0  
**Last Updated:** 2025-10-29  
**Location:** `/00-meta/21-meta-projects/portfolio-project-scaffolding-system/`

---

## Purpose

Meta-project for developing the Portfolio Project Scaffolding System - a CLI tool that creates new projects from boilerplate templates with full governance, security, and AI controls active from v0.1.0.

**Tagline:** "From idea to governed repo in 5 minutes"

---

## Navigation

**Parent:** [meta-projects](../README.md) *(needs README)*

**Children:**
- [decisions/](decisions/) - Architecture Decision Records
- [research/](research/) - Research notes and findings
- [analysis/](analysis/) - Portfolio analysis and validation
- [implementation/](implementation/) - Links to actual code in /00-meta/30-automation/

---

## AI Context

**Portfolio-Level:** [README-STRATEGY.md](/00-meta/01-policies/README-STRATEGY.md)  
**Project-Level:** This is a meta-project (planning-focused)  
**Related Context:** 
- [CODE-DOCUMENTATION-STANDARDS-V3.md](/00-meta/01-policies/CODE-DOCUMENTATION-STANDARDS-V3.md)
- [PORTFOLIO-GOVERNANCE-MATURITY-ASSESSMENT.md](/00-meta/20-operations/research/PORTFOLIO-GOVERNANCE-MATURITY-ASSESSMENT.md)

---

## Contents

### Folders

- **[decisions/](decisions/)** - Architecture Decision Records for PPS design
- **[research/](research/)** - Research briefs and findings (PowerShell YAML, gh CLI capabilities, etc.)
- **[analysis/](analysis/)** - Portfolio analysis validating PPS assumptions
- **[implementation/](implementation/)** - Links to actual implementation in `/00-meta/30-automation/scaffolding/`

### Files

- **[project-brief.md](project-brief.md)** - Revised project brief with scope, objectives, deliverables
- **[vision-v0.2-mvp.md](vision-v0.2-mvp.md)** - v0.2 MVP vision with epics, features, user stories, NFRs
- **[.portfolio-meta.yaml](.portfolio-meta.yaml)** - Governance metadata for this meta-project

---

## Project Status

**Current Phase:** Planning & Initial Implementation  
**Target Release:** v0.2.0 MVP  
**Approach:** Kanban-driven, pilot-led

**Completed:**
- ✅ Security configs deployed (Dependabot, CodeQL to 4 OSS repos)
- ✅ .portfolio-meta.yaml schema created
- ✅ AI detection Layers 1-2 implemented
- ✅ Portfolio analysis completed
- ✅ 3 ADRs resolved (template engine, config format, taxonomy)

**In Progress:**
- 🏗️ PPS CLI framework design
- 🏗️ Template boilerplate creation
- 🏗️ Research: PowerShell YAML libraries

**Next:**
- 📋 Week 1 implementation (CLI skeleton)
- 📋 Template creation (4-5 boilerplates)
- 📋 GitHub integration (gh CLI)

---

## Key Decisions

### Resolved ADRs

1. **[ADR-001: GitHub Integration](decisions/adr-001-github-integration-approach.md)** - Hybrid approach (gh CLI primary, REST fallback)
2. **ADR-002: Template Engine** - Simple {{VARIABLE}} replacement (from analysis)
3. **ADR-003: Config Format** - YAML with JSON Schema (from analysis)
4. **ADR-004: Project Type Taxonomy** - Domain-aware flexible taxonomy (from analysis)

### Deferred
5. **ADR-005: Template Versioning** - Deferred to v0.3

---

## Implementation Outputs

**Code Location:** `/00-meta/30-automation/scaffolding/` and `/00-meta/30-automation/governance/`

**Current implementations:**
- [Deploy-SecurityConfigs.ps1](/00-meta/30-automation/governance/Deploy-SecurityConfigs.ps1) - Batch deploy security configs
- [Test-IsAICommit.ps1](/00-meta/30-automation/governance/Test-IsAICommit.ps1) - AI detection module
- [pre-commit-hook.ps1](/00-meta/30-automation/governance/pre-commit-hook.ps1) - Portfolio meta validation
- [Install-PreCommitHook.ps1](/00-meta/30-automation/governance/Install-PreCommitHook.ps1) - Hook installer

**Planned (v0.2):**
- pps.ps1 - Main CLI tool
- template-engine.ps1 - Variable substitution
- github-integration.ps1 - Repo creation via gh CLI
- apply-governance.ps1 - Apply governance configs

---

## Templates & Schemas

**Schemas:**
- [portfolio-meta.schema.json](/00-meta/50-schemas/portfolio-meta.schema.json) - JSON Schema for .portfolio-meta.yaml
- [portfolio-meta-template.yaml](/00-meta/50-schemas/portfolio-meta-template.yaml) - Template with comments

**Templates (planned):**
- `/00-meta/40-templates/project-boilerplates/python-cli-tool/`
- `/00-meta/40-templates/project-boilerplates/powershell-utility/`
- `/00-meta/40-templates/project-boilerplates/minimal-experiment/`
- `/00-meta/40-templates/project-boilerplates/python-web-app/`
- `/00-meta/40-templates/project-boilerplates/meta-project/`

---

## Research Topics

**Critical (Before Implementation):**
- 🔬 PowerShell YAML libraries - Which is most reliable?
- 🔬 gh CLI capabilities - Feature matrix validation

**High Priority:**
- Template variable patterns - Complete list with usage
- Pre-commit hook ecosystem - Integration opportunities

**See:** [research/](research/) folder for detailed research briefs

---

## Success Criteria

**v0.2 MVP Complete When:**
- ✅ CLI creates project from template
- ✅ All governance active from v0.1.0
- ✅ GitHub repo created automatically
- ✅ Security scanning enabled
- ✅ AI detection operational
- ✅ Documentation (usage guide)
- ✅ 3-5 templates available

**Target:** End of November 2025

---

## Related Documents

**Planning:**
- [project-brief.md](project-brief.md) - Revised governance hardening initiative
- [vision-v0.2-mvp.md](vision-v0.2-mvp.md) - MVP requirements and roadmap

**Analysis:**
- [analysis/portfolio-analysis-for-pps.md](analysis/portfolio-analysis-for-pps.md) - Template validation
- [/00-meta/20-operations/research/PORTFOLIO-GOVERNANCE-MATURITY-ASSESSMENT.md](/00-meta/20-operations/research/PORTFOLIO-GOVERNANCE-MATURITY-ASSESSMENT.md) - Current state

**Standards:**
- [/00-meta/01-policies/CODE-DOCUMENTATION-STANDARDS-V3.md](/00-meta/01-policies/CODE-DOCUMENTATION-STANDARDS-V3.md)
- [/00-meta/01-policies/README-STRATEGY.md](/00-meta/01-policies/README-STRATEGY.md)

---

## Version History

### 1.0.0 (2025-10-29)
- Meta-project created with proper kebab-case structure
- Migrated files from `2025-10-portfolio-governance-tooling-and-hardening/`
- Organized into decisions/, research/, analysis/, implementation/
- Initial planning and analysis complete
