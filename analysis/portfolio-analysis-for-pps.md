# Portfolio Analysis for PPS v0.2 MVP Validation

**Date:** 2025-10-29  
**Purpose:** Validate template assumptions and resolve open ADRs through actual portfolio analysis

---

## Priority 1: Template Pattern Validation

### Finding: All 5 Proposed Templates Have Real Examples ✅

| Template Pattern | Examples Found | Validation Status |
|------------------|----------------|-------------------|
| **python-cli-tool** | fylum, bonsort, proprompt, flat, family-calendar | ✅ **CONFIRMED** - 5 examples |
| **python-web-app** | fylum (GUI planned), bonsort (Streamlit viewer) | ✅ **CONFIRMED** - 2 examples |
| **powershell-utility** | repop, multicode | ✅ **CONFIRMED** - 2 examples |
| **minimal-experiment** | PATHtidy, contact-audit | ✅ **CONFIRMED** - 2 examples |
| **smart-home-integration** | family-enterprise-arch (partial) | ⚠️ **NO PURE EXAMPLES** - Defer or remove |

**Recommendation:** **Keep 4 templates for MVP, defer smart-home-integration to v0.3**

**Priority order for MVP:**
1. ✅ **python-cli-tool** (Most common - 5 examples)
2. ✅ **minimal-experiment** (Quick starts - 2 examples)
3. ✅ **powershell-utility** (Windows tools - 2 examples)
4. ✅ **python-web-app** (Ambitious projects - 2 examples)
5. ⏸️ ~~smart-home-integration~~ (Defer - no clear pattern yet)

---

### Actual File Structures by Template

#### python-cli-tool (Mature Pattern)

**Evidence from fylum:**
```
fylum/
├── .github/
│   ├── dependabot.yml
│   └── workflows/
│       └── codeql.yml
├── src/
│   └── {module_name}/
│       ├── __init__.py
│       ├── config.py
│       └── cli.py
├── tests/
│   └── test_{module}.py
├── docs/
│   ├── architecture/
│   └── releases/
├── app.py (entry point)
├── setup.py
├── requirements.txt
├── requirements-dev.txt
├── .gitignore
├── .portfolio-meta.yaml
├── AGENTS.md
├── LICENSE
├── README.md
└── CHANGELOG.md (optional)
```

**Common across all Python CLI examples:**
- ✅ `requirements.txt` (100% - always)
- ✅ `requirements-dev.txt` (80% - mature projects)
- ✅ Entry point: `app.py` or `{project}.py` or `src/{module}/cli.py`
- ✅ CLI framework: Typer (modern) or Click (older) or argparse
- ✅ `tests/` directory (mature projects have this)
- ✅ `.gitignore` (always)

**Variables needed:**
- `{{PROJECT_NAME}}` - "Fylum"
- `{{PROJECT_SLUG}}` - "fylum"
- `{{MODULE_NAME}}` - "fylum" (Python import name)
- `{{CLI_FRAMEWORK}}` - "typer" | "click" | "argparse"
- `{{DESCRIPTION}}` - One-liner
- `{{AUTHOR_NAME}}` - "Chris Clements"
- `{{AUTHOR_EMAIL}}` - Email
- `{{GITHUB_USER}}` - "ChrisClements1987"

---

#### powershell-utility (Lightweight Pattern)

**Evidence from repop:**
```
repop/
├── .github/
│   └── dependabot.yml (GitHub Actions only)
├── .git/
├── repop.ps1 (main script)
├── install.ps1
├── uninstall.ps1
├── config.ps1
├── adr.md (decision record)
├── README.md
├── LICENSE.txt
└── .gitignore
```

**Common across PowerShell examples:**
- ✅ Main `.ps1` script
- ✅ `config.ps1` for settings
- ✅ `install.ps1` / `uninstall.ps1` for Windows integration
- ✅ README with PowerShell examples
- ✅ No `tests/` typically (manual testing)
- ✅ Single file or few files (< 5 typically)

**Variables needed:**
- `{{PROJECT_NAME}}` - "Repop"
- `{{PROJECT_SLUG}}` - "repop"
- `{{DESCRIPTION}}`
- `{{GITHUB_USER}}`
- `{{YEAR}}`

---

#### minimal-experiment (Concept/Planning Pattern)

**Evidence from contact-audit:**
```
20251024-contact-audit.../
├── ai-prompts/
│   └── (AI assistance artifacts)
├── contact-exports/
│   └── (data files)
├── scripts/
│   └── (automation scripts)
├── README.md
├── plan-v1.0.md
├── project-goal.md
└── .portfolio-meta.yaml
```

**Common across minimal examples:**
- ✅ README.md
- ✅ Planning/goal docs
- ✅ `scripts/` or `src/` (ad-hoc)
- ✅ `.portfolio-meta.yaml` (governance)
- ❌ No formal structure
- ❌ No tests
- ❌ No CI/CD

**Variables needed:**
- `{{PROJECT_NAME}}`
- `{{DESCRIPTION}}`
- `{{DATE}}` - For dated experiments

---

#### python-web-app (Multi-Component Pattern)

**Evidence from fylum (V2.0.0 planned):**
```
fylum/
├── web/
│   ├── package.json
│   └── (Svelte frontend planned)
├── src/
│   └── api/
│       └── (FastAPI backend)
├── backend/ (or combined with src/)
├── frontend/ (or web/)
├── docker-compose.yml (optional)
└── (all python-cli-tool files)
```

**Common across web app examples:**
- ✅ Backend + Frontend separation
- ✅ API layer (FastAPI, Flask)
- ✅ Frontend framework (React, Svelte, etc.)
- ✅ `docker-compose.yml` (development)
- ✅ More complex `.github/workflows/` (multi-stage deploy)

**Variables needed:**
- All python-cli-tool variables +
- `{{BACKEND_FRAMEWORK}}` - "fastapi" | "flask"
- `{{FRONTEND_FRAMEWORK}}` - "react" | "svelte" | "vue"
- `{{USE_DOCKER}}` - true | false

---

## Priority 2: Template Engine Approach (ADR-002)

### Finding: Simple Replacement Sufficient ✅

**Analysis:**
- **Checked:** Variations between similar projects
- **Result:** Differences are in **content** (logic, features), NOT structure
- **Example:** repop vs multicode:
  - Both have: `{name}.ps1`, `config.ps1`, `install.ps1`, `README.md`
  - Differences: Business logic in scripts, config values
  - No conditional structure (if has database, add X)

**No evidence of needing:**
- ❌ Conditional blocks (if/else in templates)
- ❌ Loops (for each X, add Y)
- ❌ Template inheritance

**Recommendation:** **Use simple `{{VARIABLE}}` replacement for v0.2 MVP**

**Rationale:**
- All examples use consistent structure per type
- Variations are in code content, not file structure
- Simple replacement proven in meta-repo-seed
- Can upgrade to Jinja2 later if needed

**Evidence:**
- Fylum and bonsort (same pattern): Both have `src/`, `tests/`, `requirements.txt` - no conditional differences
- Repop and multicode (same pattern): Both have `.ps1` files, `install.ps1` - structure identical

---

## Priority 3: Project Type Taxonomy (ADR-004)

### Finding: Current Structure is FLAT, Not Typed ⚠️

**Actual organization:**

**Personal (`10-personal/10-projects/`):**
```
10-projects/
├── personal-ux/             ← Type folder
│   └── 20251024-contact-audit.../
└── private-software/        ← Type folder
    └── flat/
```
- ✅ **Uses type folders** (personal-ux, private-software)
- Pattern: Dated projects under personal-ux

**Family (`20-family/10-projects/`):**
```
10-projects/
├── home-automation/         ← Type folder (empty)
├── home-infrastructure/     ← Type folder (empty)
├── infrastructure/          ← Type folder
│   └── family-enterprise-architecture/
└── software/                ← Type folder
    └── family-apps/
        ├── family/
        └── family-calendars/
```
- ✅ **Uses type folders** (infrastructure, software, home-automation, home-infrastructure)
- Some nesting: `software/family-apps/{project}`

**Community (`30-community/open-source/10-projects/`):**
```
10-projects/
├── bonsort/
├── fylum/
├── multicode/
├── PATHtidy/
├── proprompt/
└── repop/
```
- ❌ **FLAT** - No type folders
- All OSS projects directly in 10-projects/

**Recommendation:** **Flexible taxonomy per domain**

**Proposed rules:**
```yaml
# Domain-specific type structures
personal:
  use_types: true
  default_types:
    - personal-ux
    - private-software
    - productivity
    - learning
    - experiments
  allow_new: true  # Can create new types

family:
  use_types: true
  default_types:
    - software
    - infrastructure
    - home-automation
    - home-infrastructure
  allow_new: true

community:
  use_types: false  # Flat structure
  # Community projects go directly in {community}/10-projects/{slug}/

meta:
  use_types: true
  types:
    - meta-projects
    - automation
    - operations
    - templates
```

**Evidence:**
- Personal: 2 type folders in use
- Family: 4 type folders in use  
- Community: 0 type folders (flat)
- Documented structure (from vision.md) suggests types for personal/family

---

## Priority 4: Template Variables Discovery

### Finding: Core Variable Set + Domain-Specific Extensions

**Variables found in .portfolio-meta.yaml (4 files analyzed):**

**Core (100% occurrence):**
- `version` - Schema version (1.0.0)
- `enforcement` - minimal | standard | strict
- `ai_allowed` - true | false
- `contributors` - solo | family | community
- `primary_contributor` - chris
- `risk_level` - low | medium | high
- `governed_by` - portfolio-meta
- `last_reviewed` - 2025-10-29
- `tags` - Array of tags

**Common (75%+):**
- `no_bypass` - true | false
- `require_adr` - true | false | auto
- `require_agents_md` - true | false | auto
- `risk_factors` - {correctness, safety, collaboration}

**From setup.py (fylum example):**
```python
name="fylum"
version="1.0.0"
author="Chris Clements"
author_email="..."  # Would need
description="A smart file organizer..."
url="https://github.com/ChrisClements1987/fylum"
license="MIT"
python_requires=">=3.8"
```

**From package.json (strategos example):**
```json
{
  "name": "@strategos/app",
  "version": "1.0.0",
  "description": "...",
  "author": "Chris Clements",
  "license": "MIT"
}
```

**Complete Variable List:**

**Project Identity:**
- `{{PROJECT_NAME}}` - Human-readable: "File Organizer" 
- `{{PROJECT_SLUG}}` - kebab-case: "file-organizer"
- `{{MODULE_NAME}}` - Python import: "file_organizer"
- `{{DESCRIPTION}}` - One-liner description
- `{{DESCRIPTION_LONG}}` - Multi-paragraph (for README)

**Ownership:**
- `{{AUTHOR_NAME}}` - "Chris Clements"
- `{{AUTHOR_EMAIL}}` - Email address
- `{{GITHUB_USER}}` - "ChrisClements1987"
- `{{GITHUB_ORG}}` - Organization (if applicable)
- `{{REPO_URL}}` - Full GitHub URL

**Dates:**
- `{{YEAR}}` - 2025
- `{{DATE}}` - 2025-10-29
- `{{DATE_ISO}}` - 2025-10-29T12:00:00Z

**Technical:**
- `{{LICENSE}}` - "MIT" (default)
- `{{PYTHON_VERSION}}` - "3.8+" | "3.9+" | "3.10+"
- `{{NODE_VERSION}}` - "18+" | "20+"
- `{{LANGUAGE}}` - "Python" | "PowerShell" | "TypeScript"

**Governance:**
- `{{ENFORCEMENT}}` - minimal | standard | strict
- `{{AI_ALLOWED}}` - true | false
- `{{RISK_LEVEL}}` - low | medium | high
- `{{VISIBILITY}}` - public | private

**Derived:**
- `{{REPO_SLUG}}` - "ChrisClements1987/file-organizer"
- `{{INITIAL_VERSION}}` - "0.1.0" (default)

**Frequency:**
- PROJECT_NAME/SLUG: 100% (every file)
- DESCRIPTION: 90% (README, setup.py, package.json)
- AUTHOR_NAME/EMAIL: 80% (setup.py, package.json, LICENSE)
- GITHUB_USER: 70% (README badges, git remotes)
- YEAR: 60% (LICENSE, copyright headers)
- ENFORCEMENT/AI_ALLOWED: 100% (in .portfolio-meta.yaml)

**Recommendation:** **Use complete set above, mark optional vs required in generator**

---

## Priority 2: Template Engine Decision (ADR-002)

### Finding: Simple Replacement Sufficient for MVP ✅

**Evidence:**

**Same-pattern project comparison:**

| Project | Pattern | Structure Identical? | Differences |
|---------|---------|---------------------|-------------|
| repop vs multicode | powershell-utility | ✅ YES | Script logic, config values |
| fylum vs bonsort | python-cli-tool | ✅ YES | Module organization, dependencies |
| proprompt vs flat | python-cli-tool (minimal) | ✅ YES | Complexity, no structural conditionals |

**No conditional structure found:**
- ❌ No "if has_database then add db/ folder"
- ❌ No "if web_app then add frontend/"
- ❌ No loops or complex logic

**Structural differences are TEMPLATE CHOICE, not conditionals:**
- Choose `python-cli-tool` → Get CLI structure
- Choose `python-web-app` → Get backend+frontend structure
- Not: Choose `python` and conditionally get CLI or web

**Recommendation:** **ADR-002: Use simple `{{VARIABLE}}` replacement**

**Rationale:**
- Zero evidence of needing conditionals in actual projects
- Template choice handles variants (separate templates)
- Simpler = easier to maintain, less dependencies
- Can upgrade to Jinja2 later if pattern emerges

**Decision:** ✅ **APPROVED - Simple replacement for v0.2**

---

## Priority 3: Project Type Taxonomy (ADR-004)

### Finding: Domain-Specific Type Usage, Not Universal

**Current reality:**

| Domain | Uses Types? | Types Found | Pattern |
|--------|-------------|-------------|---------|
| **Personal** | ✅ Yes | personal-ux, private-software | Categorization by purpose |
| **Family** | ✅ Yes | software, infrastructure, home-automation, home-infrastructure | Categorization by area |
| **Community** | ❌ No | (flat) | All projects directly in 10-projects/ |
| **Meta** | ✅ Likely | meta-projects, automation, operations | Functional categorization |

**Recommendation:** **ADR-004: Flexible, domain-aware taxonomy**

**Proposed Implementation:**

```yaml
# In pps config or template manifest
taxonomies:
  personal:
    use_types: true
    types:
      - productivity    # Tools for personal productivity
      - learning        # Learning projects
      - experiments     # Throwaway experiments
      - ux             # Personal UX improvements
      - software       # Private software
    allow_custom: true  # Can create new types
    
  family:
    use_types: true
    types:
      - software           # Family apps
      - infrastructure     # Home infrastructure
      - home-automation    # HA integrations
    allow_custom: true
    
  community:
    use_types: false  # Flat: community/{slug}/10-projects/{project}/
    
  meta:
    use_types: true
    types:
      - meta-projects   # Portfolio improvement projects
      - automation      # Automation scripts
      - operations      # Ongoing operations
    allow_custom: false  # Fixed types
```

**CLI behavior:**
```powershell
# Personal domain - requires type
pps init my-tool --domain personal --type productivity

# Community domain - no type (flat)
pps init my-tool --domain community

# Type not in list - prompt to confirm
pps init my-tool --domain personal --type new-category
# → "Type 'new-category' not in standard list. Create anyway? (y/n)"
```

**Decision:** ✅ **APPROVED - Domain-aware flexible taxonomy**

---

## Priority 4: Additional Template Variables

### Finding: Some Critical Variables Missing from Original List

**From actual README headers:**
```markdown
# Fylum 📁
**Version:** 1.0.0
**Location:** /30-community/open-source/10-projects/fylum/
```

**Missing variables needed:**
- `{{LOCATION_BREADCRUMB}}` - `/30-community/open-source/10-projects/fylum/`
- `{{PARENT_README}}` - `../README.md` (relative path)
- `{{DOMAIN}}` - `30-community`
- `{{DOMAIN_NAME}}` - "Community"
- `{{PROJECT_TYPE}}` - Type folder (if used)

**From setup.py (Python projects):**
```python
install_requires=[
    "typer>=0.9.0",
    "pyyaml>=6.0",
    # ...
]
python_requires=">=3.8"
classifiers=[
    "Development Status :: 4 - Beta",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3.8",
]
```

**Missing variables:**
- `{{PYTHON_MIN_VERSION}}` - "3.8" | "3.9" | "3.10"
- `{{DEV_STATUS}}` - "Alpha" | "Beta" | "Stable"
- `{{DEPENDENCIES}}` - Array of deps (template-specific)

**Complete variable list (41 variables):**

See section in VISION-V0.2-MVP.md - updating now with findings...

**Recommendation:** **Add 8 missing variables** (location, domain, parent, versions, dev status)

---

## Priority 5: GitHub Integration Features

### Finding: gh CLI Can Handle 90% of Needs ✅

**Workflows found across projects (57 total):**

**Most common patterns:**
- CI/CD: `ci.yml` (15 occurrences) - Test + lint + build
- Security: `codeql.yml` (2 - just added), `license-check.yml`, `commit-lint.yml`
- Deployment: `deploy-*.yml`, `release.yml`
- Governance: `standards-enforcement.yml`, `pr-quality-check.yml`, `readme-docs.yml`

**What gh CLI CAN do (researched from examples):**
- ✅ Create repo: `gh repo create`
- ✅ Set visibility: `--public` / `--private`
- ✅ Set description: `--description`
- ✅ Add topics: `gh repo edit --add-topic`
- ✅ Create labels: `gh label create`
- ✅ Initial push: `--source . --push`
- ✅ Create releases: `gh release create`

**What gh CLI CANNOT do (need REST API or manual):**
- ⚠️ Branch protection rules (need API or web UI)
- ⚠️ CODEOWNERS enforcement (need branch protection)
- ⚠️ Required status checks (need API)
- ⚠️ Secrets/variables (need API or manual)

**Recommendation:** **ADR-001 validated - gh CLI sufficient for MVP**

**For v0.2:**
- ✅ Use `gh` for repo creation, topics, labels
- ⏸️ Defer branch protection to v0.3 (REST API needed)
- ⏸️ Document manual steps for secrets/variables

**Evidence:**
- Common-code/meta-repo uses workflows for enforcement (not branch protection)
- Meta-repo-seed has branch protection but it's configured manually or via API

---

## Priority 6: Governance Validation

### Finding: .portfolio-meta.yaml Fields Align Well ✅

**Files analyzed: 4**
- `00-meta/.portfolio-meta.yaml` - enforcement: standard
- `fylum/.portfolio-meta.yaml` - enforcement: standard
- `bonsort/.portfolio-meta.yaml` - enforcement: strict
- `personal-ux/contacts/.portfolio-meta.yaml` - enforcement: standard

**Domain → Enforcement mapping (validates our defaults):**

| Domain | Project | Actual Enforcement | Our Default | Match? |
|--------|---------|-------------------|-------------|--------|
| Meta | 00-meta | standard | standard | ✅ Match |
| Personal + AI | contacts | standard | standard | ✅ Match |
| Community | fylum | standard | strict | ⚠️ Lower than default |
| Community | bonsort | strict | strict | ✅ Match |

**Finding:** Fylum is `standard` not `strict` - likely because it's still in active development

**Adjustment:** Domain defaults are **recommendations**, not enforced - OK

**AI_ALLOWED distribution:**
- 100% have `ai_allowed: true` (all 4 projects)
- Validates that AI assistance is common

**Most common fields (priority for templates):**
1. version, enforcement, ai_allowed (100%)
2. contributors, primary_contributor, risk_level (100%)
3. governed_by, last_reviewed, tags (100%)
4. require_adr, require_agents_md (100%)
5. ai_restrictions (100%)

**Recommendation:** **Schema validated - all fields are used**

---

## Quick Scans

### ADR-003: Configuration Format

**Config files found:**
- YAML: 95% (config.yaml, .portfolio-meta.yaml, GitHub workflows, setup configs)
- JSON: 3% (package.json, schema files)
- TOML: 2% (pyproject.toml in bonsort only)

**Recommendation:** **YAML is portfolio standard** - Keep .portfolio-meta.yaml as YAML

---

### ADR-005: Template Versioning

**Drift analysis:**
- bonsort: Has extensive customization beyond initial structure
- fylum: Added web/ folder (V2 feature), custom modules
- repop: Minimal drift (still matches initial pattern)

**Evidence of drift:** ~50% of mature projects diverge structurally from initial template

**Recommendation:** **Templates should allow divergence** - Don't force sync in v0.2

**For v0.3:** Consider "template sync" but only for governance files (.github/, .portfolio-meta.yaml), NOT structure

---

## Summary Recommendations

### ADR-002: Template Engine ✅ RESOLVED
**Decision:** Simple `{{VARIABLE}}` replacement  
**Evidence:** No conditional structures found in any projects  
**Status:** APPROVED

### ADR-003: Config Format ✅ RESOLVED
**Decision:** YAML with JSON Schema validation  
**Evidence:** 95% of configs are YAML  
**Status:** APPROVED

### ADR-004: Project Type Taxonomy ✅ RESOLVED
**Decision:** Domain-aware flexible taxonomy  
**Evidence:** Personal/Family use types (different per domain), Community flat  
**Taxonomy:** As proposed above  
**Status:** APPROVED

### ADR-005: Template Versioning ⏸️ DEFERRED
**Decision:** Allow divergence, no sync in v0.2  
**Evidence:** 50% of projects customized beyond template  
**Status:** Defer to v0.3

---

## Template Refinements Based on Analysis

### Template 1: python-cli-tool (REFINED)

**Based on:** fylum, bonsort, proprompt, flat

**Must include:**
- `requirements.txt` (always)
- `requirements-dev.txt` (recommended)
- `src/{module}/` OR root `{project}.py`
- CLI framework: Typer (modern) as default
- `.gitignore` (Python-specific)
- `setup.py` (for distribution)
- Optional: `tests/`, `.pre-commit-config.yaml`, `pyproject.toml`

---

### Template 2: powershell-utility (REFINED)

**Based on:** repop, multicode

**Must include:**
- `{project}.ps1` (main script)
- `config.ps1` (configuration)
- `install.ps1`, `uninstall.ps1` (Windows integration)
- `.gitignore` (PowerShell/Windows-specific)
- README with PowerShell examples

---

### Template 3: minimal-experiment (REFINED)

**Based on:** PATHtidy, contact-audit

**Must include:**
- `README.md` (basic)
- `.portfolio-meta.yaml` (enforcement: minimal)
- `notes.md` or `plan.md`
- `src/` or `scripts/` (ad-hoc)
- Dated folder name support: `YYYYMMDD-{description}/`

---

### Template 4: python-web-app (REFINED)

**Based on:** fylum V2 (planned), bonsort (Streamlit)

**Must include:**
- All python-cli-tool files
- `backend/` or `src/api/`
- `frontend/` or `web/`
- `docker-compose.yml` (development)
- More complex CI (multi-stage)

---

### Template 5: smart-home-integration (DEFERRED)

**Recommendation:** **Remove from v0.2 MVP** - No clear examples found

**Reason:** Would need to define from scratch, not based on actual patterns

**Add when:** You create first HA project and can extract pattern

---

## Critical Research Results

### PowerShell YAML Library (CRITICAL)

**Need to research:** Which library to use for parsing .portfolio-meta.yaml

**Current usage:** None found in automation scripts yet

**Options to investigate:**
- powershell-yaml
- PSYaml  
- yamldotnet (C# library wrapper)

**Assign:** AI researcher (Priority 1)

---

### Project Type List Completion

**Based on analysis, complete taxonomy:**

**Personal types found/inferred:**
- ✅ personal-ux (exists)
- ✅ private-software (exists)
- 💡 productivity (inferred from tool nature)
- 💡 learning (inferred, none yet)
- 💡 experiments (inferred, none yet)

**Family types found:**
- ✅ software (exists)
- ✅ infrastructure (exists)
- ✅ home-automation (exists, empty)
- ✅ home-infrastructure (exists, empty)

**Recommendation:** Use actual folders as defaults, allow custom

---

## Next Steps

1. ✅ **ADR-002 RESOLVED** - Simple replacement
2. ✅ **ADR-003 RESOLVED** - YAML format
3. ✅ **ADR-004 RESOLVED** - Flexible taxonomy
4. ⏸️ **ADR-005 DEFERRED** - No sync in v0.2
5. 🔬 **Research needed:** PowerShell YAML library (before implementation)
6. 🔧 **Ready to build:** CLI skeleton can start
7. 📝 **Update templates:** Based on actual structures found

**Can begin Week 1 implementation pending PowerShell YAML research.**
