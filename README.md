# Portfolio Project Scaffolding System (PPS)

**Version:** 1.1.0  
**Last Updated:** 2025-11-03  
**Location:** `/00-meta/21-meta-projects/portfolio-project-scaffolding-system/`  
**GitHub:** https://github.com/ChrisClements1987/portfolio-project-scaffolding-system

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
- **[implementation/](implementation/)** - Links to actual implementation in [portfolio-meta-automation](https://github.com/ChrisClements1987/portfolio-meta-automation)

### Files

- **[project-brief.md](project-brief.md)** - Revised project brief with scope, objectives, deliverables
- **[vision-v0.2-mvp.md](vision-v0.2-mvp.md)** - v0.2 MVP vision with epics, features, user stories, NFRs
- **[.portfolio-meta.yaml](.portfolio-meta.yaml)** - Governance metadata for this meta-project

---

## Project Status

**Current Phase:** Phase 1 Complete, Phase 2 In Progress  
**Target Release:** v0.2.0 MVP  
**Approach:** Kanban-driven, pilot-led

**Completed (Phase 1):**
- ✅ Security configs deployed (Dependabot, CodeQL to 4 OSS repos)
- ✅ .portfolio-meta.yaml schema created (enhanced with remote_repo_url, visibility)
- ✅ AI detection Layers 1-2 implemented
- ✅ Portfolio analysis completed
- ✅ 4 ADRs resolved (template engine, config format, taxonomy, GitHub integration)
- ✅ **CLI framework complete** (pps.ps1 - 419 lines, operational)
- ✅ **7 project templates created** (python-cli-tool, python-web-app, powershell-utility, minimal-experiment, meta-project, tier1-business, tier2-community)
- ✅ **Repo architecture cleaned** (Option B executed - clean separation)
- ✅ **PPS and automation have own GitHub repos**

**In Progress (Phase 2):**
- 🏗️ Template engine implementation (variable substitution)
- 🏗️ File copying and path construction logic
- 🏗️ GitHub repo creation integration

**Next (Phase 3):**
- 📋 Complete template engine
- 📋 Initial commit & tagging workflow
- 📋 Concept graduation from ideas-inbox
- 📋 Integration testing

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

**Code Repository:** [portfolio-meta-automation](https://github.com/ChrisClements1987/portfolio-meta-automation) (v1.0.0)  
**Local Path:** `c:/Portfolio/00-meta/30-automation/` (untracked in portfolio repo)

**Implemented (v1.0):**
- [pps.ps1](https://github.com/ChrisClements1987/portfolio-meta-automation/blob/main/scaffolding/pps.ps1) - Main CLI tool (Phase 1 complete)
- [Deploy-SecurityConfigs.ps1](https://github.com/ChrisClements1987/portfolio-meta-automation/blob/main/governance/Deploy-SecurityConfigs.ps1) - Batch deploy security configs
- [Test-IsAICommit.ps1](https://github.com/ChrisClements1987/portfolio-meta-automation/blob/main/governance/Test-IsAICommit.ps1) - AI detection module
- [pre-commit-hook.ps1](https://github.com/ChrisClements1987/portfolio-meta-automation/blob/main/governance/pre-commit-hook.ps1) - Portfolio meta validation
- [Install-PreCommitHook.ps1](https://github.com/ChrisClements1987/portfolio-meta-automation/blob/main/governance/Install-PreCommitHook.ps1) - Hook installer

**In Progress (v0.2):**
- Template engine module (variable substitution)
- GitHub integration module (repo creation via gh CLI)
- File operations module (copying, path construction)

---

## Templates & Schemas

**Schemas:**
- [portfolio-meta.schema.json](/00-meta/50-schemas/portfolio-meta.schema.json) - JSON Schema for .portfolio-meta.yaml
  - Enhanced with `remote_repo_url` and `visibility` fields (2025-11-03)
- [portfolio-meta-template.yaml](/00-meta/50-schemas/portfolio-meta-template.yaml) - Template with comments

**Templates (available):**
- ✅ `/00-meta/40-templates/project-boilerplates/python-cli-tool/` - CLI utilities
- ✅ `/00-meta/40-templates/project-boilerplates/python-web-app/` - Full-stack web apps
- ✅ `/00-meta/40-templates/project-boilerplates/powershell-utility/` - Windows utilities
- ✅ `/00-meta/40-templates/project-boilerplates/minimal-experiment/` - Quick prototypes
- ✅ `/00-meta/40-templates/project-boilerplates/meta-project/` - Portfolio meta-projects
- 🚧 `/00-meta/40-templates/project-boilerplates/tier1-business/` - High-stakes business projects
- 🚧 `/00-meta/40-templates/project-boilerplates/tier2-community/` - OSS/community projects

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
- [/00-meta/10-architecture/PPS-TEMPLATE-ALIGNMENT-ANALYSIS.md](/00-meta/10-architecture/PPS-TEMPLATE-ALIGNMENT-ANALYSIS.md) - Template alignment assessment
- [/00-meta/20-operations/research/PORTFOLIO-GOVERNANCE-MATURITY-ASSESSMENT.md](/00-meta/20-operations/research/PORTFOLIO-GOVERNANCE-MATURITY-ASSESSMENT.md) - Current state

**Architecture:**
- [/00-meta/10-architecture/PORTFOLIO-REPO-ARCHITECTURE.md](/00-meta/10-architecture/PORTFOLIO-REPO-ARCHITECTURE.md) - Repo structure philosophy
- [/00-meta/10-architecture/OPTION-B-COMPLETION-SUMMARY.md](/00-meta/10-architecture/OPTION-B-COMPLETION-SUMMARY.md) - Repo cleanup execution

**Standards:**
- [/00-meta/01-policies/CODE-DOCUMENTATION-STANDARDS-V3.md](/00-meta/01-policies/CODE-DOCUMENTATION-STANDARDS-V3.md)
- [/00-meta/01-policies/README-STRATEGY.md](/00-meta/01-policies/README-STRATEGY.md)

---

## Version History

### 1.1.0 (2025-11-03)
- Phase 1 complete: CLI framework operational
- 7 templates created
- Schema enhanced with remote_repo_url and visibility
- PPS and automation moved to separate GitHub repos
- Repo architecture cleaned (Option B executed)
- Documentation updated to reflect current state

### 1.0.0 (2025-10-29)
- Meta-project created with proper kebab-case structure
- Migrated files from `2025-10-portfolio-governance-tooling-and-hardening/`
- Organized into decisions/, research/, analysis/, implementation/
- Initial planning and analysis complete
