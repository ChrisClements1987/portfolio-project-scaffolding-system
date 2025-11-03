# Portfolio Project Scaffolding System - v0.2 MVP Vision

**Version:** 0.2.0  
**Date:** 2025-11-03  
**Status:** Phase 1 Complete, Phase 2 In Progress  
**Location:** `/00-meta/21-meta-projects/portfolio-project-scaffolding-system/`  
**GitHub:** https://github.com/ChrisClements1987/portfolio-project-scaffolding-system

---

## 🎯 Vision Statement

**Enable effortless, governed project creation** from concept to production-ready repository with all guardrails active from v0.1.0, adapted from meta-repo-seed patterns for portfolio (personal/family/community) context.

**Tagline:** "From idea to governed repo in 5 minutes"

---

## 🏗️ MVP Scope (v0.2)

### What v0.2 Delivers

**Core Capability:**
- ✅ **DONE:** CLI tool framework (`pps` - Portfolio Project Scaffolding) - Phase 1 complete
- ✅ **DONE:** 7 starter boilerplate templates (5 complete, 2 in progress)
- ✅ **DONE:** Schema with remote_repo_url and visibility fields
- 🏗️ **IN PROGRESS:** Create project from template boilerplate (variable substitution)
- 🏗️ **IN PROGRESS:** Apply governance configs (.portfolio-meta.yaml, security scanning)
- 🏗️ **IN PROGRESS:** Create GitHub repository (via gh CLI)
- 📋 **PLANNED:** Initialize git and set remote in correct domain/folder
- 📋 **PLANNED:** Initial v0.1.0 commit with all guardrails active
- 📋 **PLANNED:** Concept graduation from ideas-inbox

**What v0.2 Does NOT Include:**
- ❌ GUI (CLI only, GUI in future release)
- ❌ Template sync/updates across repos (v0.3+)
- ❌ REST API fallback (gh CLI only in MVP)
- ❌ Advanced features (custom template creation, template marketplace, etc.)
- ❌ Automatic ideas-inbox migration (manual workflow supported)

---

## 📦 Epics & Features

### Epic 1: Core CLI Framework

**User Story:**
> As a developer, I want a simple CLI tool so that I can scaffold new projects quickly without manual setup

**Features:**
1.1. **CLI Entry Point**
   - Single command: `pps`
   - Subcommands: `init`, `apply-governance`, `create-remote`, `validate`
   - Config file support (`~/.config/pps/config.yaml`)
   - Dry-run mode (`--dry-run`)
   - Verbose logging (`--verbose`)

1.2. **Configuration Management**
   - Load defaults from config file
   - Override with CLI arguments
   - Save config (`pps config --set base_dir=C:\Portfolio`)
   - Show config (`pps config --show`)

1.3. **Logging & User Feedback**
   - Clear progress messages
   - Color-coded output (errors, warnings, success)
   - Dry-run preview
   - Summary report

**Acceptance Criteria:**
- ✅ `pps --help` shows usage
- ✅ `pps init --help` shows init options
- ✅ Config file loads successfully
- ✅ Verbose mode shows debug info
- ✅ Dry-run shows actions without executing

**NFRs:**
- Performance: <2 seconds to parse commands
- Usability: Help text clear and actionable
- Dependencies: PowerShell 7+ only

---

### Epic 2: Template System

**User Story:**
> As a developer, I want pre-configured project templates so that I start with best practices and don't repeat setup work

**Features:**
2.1. **Template Library**
   - 5 starter templates:
     1. `python-cli-tool` - CLI utilities (fylum, bonsort pattern)
     2. `python-web-app` - Web applications (LifeQuest pattern)
     3. `powershell-utility` - Windows utilities (multicode, repop pattern)
     4. `minimal-experiment` - Quick prototypes
     5. `smart-home-integration` - Home Assistant projects

2.2. **Template Structure**
   - Standard folder structure
   - `.template` files for variable substitution
   - Template manifest (`.template-manifest.yaml`)
   - Template-specific README

2.3. **Variable Substitution Engine**
   - Replace `{{PROJECT_NAME}}`, `{{DESCRIPTION}}`, etc.
   - Safe file operations (no symlink writes)
   - Binary file detection (copy without substitution)
   - Strip `.template` extension on output

**Acceptance Criteria:**
- ✅ 5 templates available
- ✅ Each template creates working project
- ✅ Variables substituted correctly
- ✅ No hardcoded values in generated projects
- ✅ Templates self-documented

**NFRs:**
- Templates: <100 files each
- Substitution: <5 seconds per template
- Safety: Never overwrite without confirmation

---

### Epic 3: Governance Config Application

**User Story:**
> As a developer, I want governance guardrails active from day one so that security, AI, and documentation standards are enforced automatically

**Features:**
3.1. **.portfolio-meta.yaml Generation**
   - Schema-validated metadata file
   - Domain-aware defaults (personal→minimal, community→strict)
   - Enforcement level based on context
   - AI-allowed flag

3.2. **Security Scanning Setup**
   - Dependabot configuration (if public or opted-in)
   - CodeQL workflow (if public or high-risk)
   - Gitleaks config (always)

3.3. **Documentation Scaffolding**
   - README following README strategy (version, location, navigation, contents)
   - AGENTS.md (if ai_allowed: true)
   - LICENSE file (MIT default)
   - CHANGELOG.md

3.4. **Pre-Commit Hook Installation**
   - AI detection (Layers 1-2)
   - Validation based on enforcement level
   - Auto-installed in new projects

**Acceptance Criteria:**
- ✅ .portfolio-meta.yaml valid per schema
- ✅ Security configs present (per enforcement level)
- ✅ README strategy compliant
- ✅ AGENTS.md generated if ai_allowed
- ✅ Pre-commit hook functional
- ✅ First commit validates successfully

**NFRs:**
- Generation: <10 seconds
- Validation: <2 seconds
- Schema: 100% compliant

---

### Epic 4: GitHub Integration

**User Story:**
> As a developer, I want GitHub repos created automatically so that I don't context-switch between scaffolding and GitHub web UI

**Features:**
4.1. **Repository Creation**
   - Create via `gh` CLI
   - Set visibility (public/private)
   - Set description
   - Add topics/tags

4.2. **Initial Push**
   - Initialize git locally
   - Add remote (origin)
   - Initial commit (v0.1.0)
   - Push to GitHub
   - Create v0.1.0 tag

4.3. **Authentication Handling**
   - Check `gh auth status`
   - Prompt for auth if needed
   - Clear error messages

**Acceptance Criteria:**
- ✅ GitHub repo created successfully
- ✅ Local repo linked to remote
- ✅ Initial commit pushed
- ✅ v0.1.0 tag visible on GitHub
- ✅ Auth errors handled gracefully

**NFRs:**
- Success rate: >95%
- Creation time: <30 seconds
- Network resilient: Retry on failures

---

### Epic 5: Domain-Aware Project Placement

**User Story:**
> As a portfolio manager, I want projects created in the correct domain/folder structure automatically so that organization is maintained

**Features:**
5.1. **Path Calculation**
   - Domain detection (personal, family, community, meta)
   - Project type selection (experiments, productivity, tools, etc.)
   - Full path construction: `C:\Portfolio\{domain}/10-projects/{type}/{project-slug}/`

5.2. **Domain Defaults**
   - Personal → minimal enforcement (unless AI)
   - Family → standard enforcement
   - Community → strict enforcement
   - Meta → standard enforcement

5.3. **Validation**
   - Check domain exists
   - Create type folder if needed
   - Prevent duplicates (check if project exists)

**Acceptance Criteria:**
- ✅ Project created in correct domain folder
- ✅ Type folder created if missing
- ✅ Prevents duplicate project names
- ✅ Domain defaults applied correctly

**NFRs:**
- Path validation: <1 second
- Safe operations: No data loss

---

### Epic 6: Initial Commit & Tagging

**User Story:**
> As a developer, I want an initial release (v0.1.0) with all configs committed so that project starts with clean version history

**Features:**
6.1. **Initial Commit Structure**
   ```
   chore: initial project scaffolding v0.1.0
   
   - Project scaffolded from {template} template
   - Portfolio meta governance enabled ({enforcement})
   - Security scanning configured
   - AI governance enabled (ai_allowed: {true|false})
   - README strategy compliant
   - Ready for development
   
   Generated by: pps v0.2.0
   Template: {template-name}
   Domain: {domain}/{type}
   ```

6.2. **Tagging**
   - Annotated tag: `v0.1.0`
   - Tag message: "Initial scaffolded release"
   - Pushed to remote

6.3. **Activation Verification**
   - Verify all configs committed
   - Verify push successful
   - Verify tag visible on GitHub
   - Print activation status

**Acceptance Criteria:**
- ✅ Clean initial commit
- ✅ v0.1.0 tag created
- ✅ Tag pushed to GitHub
- ✅ All governance files included
- ✅ Activation verified

**NFRs:**
- Atomic operation: All or nothing
- Rollback: Easy to delete and retry

---

## 📋 User Stories (Detailed)

### US-1: Quick Project Creation

**As a** developer  
**I want** to create a new project with one command  
**So that** I can start coding immediately without setup overhead

**Acceptance Criteria:**
```gherkin
Given I have an idea for a Python CLI tool
When I run: pps init my-tool --template python-cli-tool --domain personal --type productivity
Then a new project is created at C:\Portfolio\10-personal\10-projects\productivity\my-tool\
And the GitHub repo https://github.com/ChrisClements1987/my-tool exists
And I can immediately start development
```

**Priority:** P0 (Must Have)

---

### US-2: Concept Graduation

**As a** portfolio manager  
**I want** to graduate a concept from ideas-inbox to active project  
**So that** concept work carries forward and project starts with governance

**Acceptance Criteria:**
```gherkin
Given I have concept "lifequest" in ideas-inbox/concepts/lifequest/
When I run: pps init lifequest --from-concept --template python-web-app --domain personal --type experiments
Then concept docs migrate to project/docs/concept/
And .portfolio-meta.yaml inherits from concept/_meta.yaml
And concept archived to ideas-inbox/archive/completed/
```

**Priority:** P1 (Should Have)

---

### US-3: Governance Compliance

**As a** AI governance lead  
**I want** all projects to have .portfolio-meta.yaml from creation  
**So that** enforcement is explicit and AI agents cannot drift

**Acceptance Criteria:**
```gherkin
Given I create any new project
When project is scaffolded
Then .portfolio-meta.yaml exists and is valid
And enforcement level matches domain defaults
And ai_allowed reflects whether AI will work on this
And pre-commit hook installed with AI detection
```

**Priority:** P0 (Must Have)

---

### US-4: Template Selection

**As a** developer  
**I want** to choose from multiple templates matching my idea patterns  
**So that** I start with relevant structure and tools

**Acceptance Criteria:**
```gherkin
Given I'm creating a new project
When I run: pps init --template ?
Then I see list of available templates with descriptions
And I can select interactively or via CLI arg
And chosen template matches my idea type
```

**Priority:** P1 (Should Have)

---

### US-5: Security By Default

**As a** security-conscious developer  
**I want** security scanning enabled from day one  
**So that** vulnerabilities are caught early

**Acceptance Criteria:**
```gherkin
Given I create a public OSS project
When project is scaffolded
Then Dependabot is configured
And CodeQL workflow is included
And Gitleaks is configured
And security configs push to GitHub
And scans activate automatically
```

**Priority:** P0 (Must Have)

---

## 🏛️ Non-Functional Requirements

### Performance
- **NFR-1:** Project creation completes in <60 seconds (including GitHub creation)
- **NFR-2:** Template substitution <5 seconds per template
- **NFR-3:** CLI command parsing <2 seconds

### Usability
- **NFR-4:** Clear, actionable error messages
- **NFR-5:** Interactive wizard for uncertain users
- **NFR-6:** Sensible defaults (minimal prompting)
- **NFR-7:** Help text comprehensive and examples-driven

### Reliability
- **NFR-8:** Idempotent operations (can re-run safely)
- **NFR-9:** Atomic operations (all-or-nothing for critical steps)
- **NFR-10:** Graceful rollback on failures
- **NFR-11:** Network resilient (retry on transient failures)

### Security
- **NFR-12:** Never commit tokens or secrets
- **NFR-13:** Safe file operations (no symlink exploits)
- **NFR-14:** Path sanitization (prevent directory traversal)
- **NFR-15:** Validate all user inputs

### Maintainability
- **NFR-16:** Well-documented code with comments
- **NFR-17:** Modular design (functions for each step)
- **NFR-18:** Easy to add new templates
- **NFR-19:** AGENTS.md for the scaffolding system itself

### Compatibility
- **NFR-20:** PowerShell 7+ (cross-platform capable)
- **NFR-21:** Windows 10/11 primary, macOS/Linux possible
- **NFR-22:** GitHub.com (not GitHub Enterprise initially)

---

## 🏗️ Architecture Overview

### Component Diagram

```
┌─────────────────────────────────────────────┐
│     Portfolio Project Scaffolding (pps)     │
│                  CLI Tool                    │
└─────────────────────────────────────────────┘
                      │
         ┌────────────┼────────────┐
         │            │            │
    ┌────▼───┐   ┌───▼────┐   ┌──▼──────┐
    │Template│   │Governance│   │GitHub  │
    │ Engine │   │ Applier  │   │Integr. │
    └────┬───┘   └───┬────┘   └──┬──────┘
         │           │            │
    ┌────▼───────────▼────────────▼─────┐
    │      File System Operations        │
    │   (Safe writes, path validation)   │
    └────────────────────────────────────┘
                      │
         ┌────────────┼────────────┐
         │            │            │
    ┌────▼───┐   ┌───▼────┐   ┌──▼──────┐
    │Template│   │ .port- │   │ GitHub  │
    │  Repo  │   │folio-  │   │   API   │
    │        │   │meta.yaml│   │         │
    └────────┘   └────────┘   └─────────┘
```

### Component Responsibilities

**CLI Entry (`pps.ps1`):**
- Parse commands and arguments
- Load configuration
- Route to appropriate handler
- Display results

**Template Engine (`template-engine.ps1`):**
- Load template from library
- Perform variable substitution
- Copy to destination
- Validate output

**Governance Applier (`apply-governance.ps1`):**
- Generate .portfolio-meta.yaml
- Apply security configs (Dependabot, CodeQL, Gitleaks)
- Create README, AGENTS.md, LICENSE
- Install pre-commit hooks

**GitHub Integration (`github-integration.ps1`):**
- Create GitHub repo via `gh` CLI
- Set repo metadata
- Configure topics/labels
- Handle authentication

**File Operations (`file-utils.ps1`):**
- Safe file writes (no symlinks)
- Path sanitization
- Directory creation
- Binary detection

---

## 🎨 Template Boilerplates (v0.2)

### Template 1: python-cli-tool

**Pattern:** Developer productivity tools (fylum, bonsort pattern)

**Structure:**
```
python-cli-tool/
├── README.md.template
├── AGENTS.md.template
├── LICENSE.template (MIT)
├── .gitignore
├── .portfolio-meta.yaml.template
├── .github/
│   ├── dependabot.yml
│   └── workflows/
│       ├── ci-lite.yml (pytest + ruff)
│       └── codeql.yml (optional)
├── src/
│   └── {{PROJECT_SLUG}}/
│       ├── __init__.py
│       └── cli.py (typer skeleton)
├── tests/
│   └── test_{{PROJECT_SLUG}}.py
├── requirements.txt (typer, click, rich)
├── requirements-dev.txt (pytest, ruff, black, mypy)
└── setup.py
```

**Variables:**
- `{{PROJECT_NAME}}` - Human-readable name
- `{{PROJECT_SLUG}}` - kebab-case slug
- `{{DESCRIPTION}}` - One-liner description
- `{{GITHUB_USER}}` - ChrisClements1987
- `{{YEAR}}` - 2025
- `{{ENFORCEMENT}}` - standard (default for CLI tools)

---

### Template 2: python-web-app

**Pattern:** Web platforms (LifeQuest pattern)

**Structure:**
```
python-web-app/
├── README.md.template
├── AGENTS.md.template
├── .portfolio-meta.yaml.template
├── .github/workflows/
│   ├── ci-lite.yml (pytest + ruff + coverage)
│   └── codeql.yml
├── backend/
│   ├── src/
│   ├── tests/
│   └── requirements.txt (FastAPI skeleton)
├── frontend/
│   ├── src/
│   └── package.json (React/Svelte skeleton)
├── docker-compose.yml
└── docs/
    └── architecture/
        └── README.md
```

---

### Template 3: powershell-utility

**Pattern:** Windows utilities (multicode, repop pattern)

**Structure:**
```
powershell-utility/
├── README.md.template
├── .gitignore
├── .portfolio-meta.yaml.template
├── .github/dependabot.yml (GitHub Actions only)
├── src/
│   └── {{PROJECT_SLUG}}.ps1
├── tests/
│   └── {{PROJECT_SLUG}}.Tests.ps1 (Pester)
└── install.ps1
```

---

### Template 4: minimal-experiment

**Pattern:** Quick prototypes, throwaway experiments

**Structure:**
```
minimal-experiment/
├── README.md.template (bare minimum)
├── .gitignore
├── .portfolio-meta.yaml.template (enforcement: minimal)
├── src/
│   └── main.{py|ps1|js}
└── notes.md (experiment notes)
```

---

### Template 5: smart-home-integration

**Pattern:** Home Assistant integrations

**Structure:**
```
smart-home-integration/
├── README.md.template
├── .portfolio-meta.yaml.template
├── automations/
│   └── example.yaml (HA automation)
├── scripts/
│   └── example.py (HA script)
├── dashboards/
│   └── lovelace.yaml
├── docs/
│   └── setup.md
└── tests/
    └── test_automation.yaml
```

---

## 🔧 Technical Architecture Decisions Needed

### ADR-001: GitHub Integration ✅ CREATED
- Decision: Hybrid (gh CLI primary, REST fallback)
- Status: Approved
- See: [ADR-001](ADR-001-github-integration-approach.md)

---

### ADR-002: Template Engine Approach (NEEDED)

**Decision needed:** Simple string replacement vs template engine (Jinja2, etc.)

**Options:**
1. Simple replacement: `{{VAR}}` → value (like meta-repo-seed)
2. Jinja2: Full template engine with conditionals/loops
3. Hybrid: Simple for v0.2, Jinja2 later if needed

**Recommendation:** Option 1 for MVP (simple, proven, no dependencies)

**Research needed:**
- How complex will templates become?
- Do we need conditionals (if/else in templates)?

---

### ADR-003: Configuration Schema Format (NEEDED)

**Decision needed:** YAML vs JSON vs TOML for .portfolio-meta.yaml

**Current:** YAML (human-friendly)

**Considerations:**
- YAML: Human-readable, comments allowed, complex types
- JSON: Machine-first, schema validation easy, no comments
- TOML: Middle ground

**Recommendation:** YAML with JSON Schema validation (best of both)

**Research needed:**
- PowerShell YAML libraries (reliability, safety)
- Schema validation in PowerShell

---

### ADR-004: Project Type Taxonomy (NEEDED)

**Decision needed:** What project types exist per domain?

**Current thinking:**
```
personal/10-projects/
  ├── experiments/
  ├── productivity/
  ├── tools/
  └── learning/

family/10-projects/
  ├── apps/
  ├── automation/
  └── infrastructure/

community/{community}/10-projects/
  └── {project-slug}/  # No type, flat
```

**Research needed:**
- What project types make sense?
- Should types be standardized or flexible?
- Do types affect governance defaults?

---

### ADR-005: Template Versioning (NEEDED)

**Decision needed:** How to handle template updates?

**Options:**
1. Templates unversioned (always latest)
2. Templates versioned (can pin to version)
3. Template sync (detect and update existing projects)

**Recommendation:** Option 2 (versioned) for v0.2, Option 3 (sync) for v0.3+

**Research needed:**
- How to version templates?
- When to force updates vs allow divergence?

---

## 🔬 Research Topics (Prioritized)

### 🔴 Critical (Research Before MVP Implementation)

**1. PowerShell YAML Libraries**
- **Question:** Which YAML library is most reliable for PowerShell?
- **Why:** .portfolio-meta.yaml is YAML, need safe parsing
- **Options:** powershell-yaml, PSYaml, yamldotnet wrapper
- **Deliverable:** Recommendation + installation guide
- **Effort:** 1-2 hours
- **Assign to:** AI researcher + quick human validation

**2. GitHub CLI Capabilities & Limitations**
- **Question:** What operations can `gh` do vs need REST API?
- **Why:** MVP uses gh only, need to know limitations
- **Research:** Labels, branch protection, topics, secrets, variables
- **Deliverable:** Feature matrix (gh vs API)
- **Effort:** 2-3 hours
- **Assign to:** Human research (hands-on testing)

**3. Template Variable Patterns**
- **Question:** What variables do we actually need in templates?
- **Why:** Don't want to over-engineer but need completeness
- **Method:** Analyze existing projects, extract common patterns
- **Deliverable:** Complete variable list + examples
- **Effort:** 2 hours
- **Assign to:** AI researcher (analyze portfolio projects)

---

### 🟠 High Priority (Research During MVP Build)

**4. Project Type Taxonomy**
- **Question:** What project types per domain are actually useful?
- **Why:** Scaffold needs to know where to create projects
- **Method:** Review existing projects, identify patterns
- **Deliverable:** Taxonomy tree + rationale
- **Effort:** 2-3 hours
- **Assign to:** Human (domain knowledge needed)

**5. Pre-Commit Hook Ecosystem**
- **Question:** What existing pre-commit hooks integrate well with portfolio?
- **Why:** Don't reinvent if good tools exist
- **Research:** pre-commit framework, popular hooks, PowerShell hooks
- **Deliverable:** Recommended hook setup per template
- **Effort:** 2-3 hours
- **Assign to:** AI researcher + human validation

**6. Concept Metadata Mapping**
- **Question:** How to map concept/_meta.yaml to project .portfolio-meta.yaml?
- **Why:** Concept graduation should preserve context
- **Method:** Compare schemas, define mapping rules
- **Deliverable:** Mapping specification
- **Effort:** 1-2 hours
- **Assign to:** AI researcher (schema analysis)

---

### 🟡 Medium Priority (Can Research in Parallel)

**7. Template Best Practices**
- **Question:** What makes a good project template?
- **Why:** Want high-quality, maintainable templates
- **Research:** Cookiecutter, Yeoman, cookiecutter-poetry, cargo-generate patterns
- **Deliverable:** Template design guidelines
- **Effort:** 3-4 hours
- **Assign to:** AI researcher (broad survey)

**8. GitHub Label Schemas**
- **Question:** What label sets are useful for different project types?
- **Why:** Consistent labeling improves workflow
- **Research:** Popular OSS label schemes, GitHub label standards
- **Deliverable:** Label sets per tier (minimal, standard, strict)
- **Effort:** 2 hours
- **Assign to:** AI researcher

**9. Initial Commit Best Practices**
- **Question:** What should v0.1.0 commit include/exclude?
- **Why:** Clean start matters for git history
- **Research:** Semantic versioning, initial release patterns
- **Deliverable:** v0.1.0 commit guidelines
- **Effort:** 1 hour
- **Assign to:** AI researcher

---

### 🟢 Low Priority (Nice to Have)

**10. Template Marketplace Patterns**
- **Question:** How do other ecosystems handle template sharing?
- **Why:** Future: might want template contributions
- **Research:** GitHub template repos, Yeoman generators, VS Code project templates
- **Deliverable:** Marketplace design options
- **Effort:** 3-4 hours
- **Assign to:** AI researcher (exploratory)

**11. Multi-Language CI Patterns**
- **Question:** What's the best ci-lite pattern per language?
- **Why:** Templates need working CI from day one
- **Research:** GitHub Actions marketplace, language-specific best practices
- **Deliverable:** CI workflow templates (Python, Node, Rust, PowerShell)
- **Effort:** 4-5 hours
- **Assign to:** AI researcher + human review

**12. Ideas-Inbox to GitHub Issues Migration**
- **Question:** Best way to bulk-create issues from ideas?
- **Why:** Alternative to manual concept creation
- **Research:** gh CLI bulk operations, issue templates, automation
- **Deliverable:** Migration script design
- **Effort:** 2 hours
- **Assign to:** AI researcher

---

## 📅 Implementation Roadmap

### Week 1: Foundation + Critical Research

**Build:**
- [x] Security configs deployed (DONE!)
- [ ] Research: PowerShell YAML libraries (CRITICAL)
- [ ] Research: gh CLI capabilities (CRITICAL)
- [ ] CLI skeleton (`pps.ps1` with argument parsing)
- [ ] Config management
- [ ] File operations utilities

**Deliverable:** Working CLI that parses commands

---

### Week 2: Template Engine + Templates

**Build:**
- [ ] Template engine (variable substitution)
- [ ] Template 1: python-cli-tool
- [ ] Template 2: minimal-experiment
- [ ] Template 3: python-web-app (partial)
- [ ] Research: Template best practices
- [ ] Research: Project type taxonomy

**Deliverable:** Can create project from template locally

---

### Week 3: Governance Integration

**Build:**
- [ ] .portfolio-meta.yaml generator
- [ ] Schema validation
- [ ] apply-governance.ps1
- [ ] Pre-commit hook installer integration
- [ ] Research: Concept metadata mapping

**Deliverable:** Projects created with full governance

---

### Week 4: GitHub Integration + v0.1.0

**Build:**
- [ ] GitHub repo creation (gh CLI)
- [ ] Initial commit logic
- [ ] v0.1.0 tagging
- [ ] Full end-to-end test
- [ ] Documentation (usage guide)

**Deliverable:** **MVP COMPLETE** - Full workflow working

---

### Week 5: Polish + Remaining Templates

**Build:**
- [ ] Templates 4-5 (powershell-utility, smart-home-integration)
- [ ] Error handling improvements
- [ ] Interactive wizard mode
- [ ] Research: Label schemas, initial commit best practices

**Deliverable:** v0.2.0 release-ready

---

## 🔬 Research Hand-Off Package

### For AI Researcher

**Priority 1 (Immediate):**
1. **PowerShell YAML Libraries** - Compare powershell-yaml vs PSYaml, installation, safety, schema validation support
2. **Template Variable Patterns** - Analyze portfolio projects, extract common variables needed
3. **Concept Metadata Mapping** - Compare concept/_meta.yaml to .portfolio-meta.yaml schema, define mapping

**Priority 2 (This Week):**
4. **Template Best Practices** - Survey Cookiecutter, Yeoman, cargo-generate for patterns
5. **GitHub Label Schemas** - Popular OSS label sets, GitHub recommendations
6. **Pre-Commit Hook Ecosystem** - What hooks exist, which integrate well

**Priority 3 (Next Week):**
7. **Multi-Language CI Patterns** - Best ci-lite pattern for Python, Node, Rust, PowerShell
8. **Initial Commit Best Practices** - v0.1.0 commit patterns, what to include
9. **Ideas-to-Issues Migration** - gh CLI bulk operations

---

### For Human Research Assistant

**Priority 1 (Hands-On Testing):**
1. **GitHub CLI Capabilities Matrix** - Test `gh` commands for labels, branch protection, topics, secrets - document what works
2. **Project Type Taxonomy** - Review your actual projects, define useful type categories per domain

**Priority 2 (Domain Knowledge):**
3. **Template Selection Criteria** - What makes you choose one template vs another? Document decision tree
4. **Governance Preset Appropriateness** - Validate domain defaults make sense for your workflow

---

## 📊 Success Criteria (v0.2 MVP)

**Must Achieve:**
- ✅ Create 3 projects using CLI successfully
- ✅ All governance configs active from v0.1.0
- ✅ GitHub repos created and pushed
- ✅ Security scanning enabled
- ✅ AI detection operational
- ✅ Zero manual setup steps needed
- ✅ Documentation complete (usage guide)

**Should Achieve:**
- ✅ 5 templates available
- ✅ Interactive wizard mode
- ✅ Concept graduation works
- ✅ Error handling graceful

**Could Achieve:**
- ⚠️ Template sync command (defer to v0.3)
- ⚠️ REST API fallback (defer to v0.3)
- ⚠️ Custom template creation (defer to v0.3)

---

## 🚀 Next Immediate Actions

1. **Approve research hand-off** - Should I create detailed research briefs?
2. **Approve ADR-001** - GitHub integration approach OK?
3. **Start Week 1 implementation** - Build CLI skeleton?
4. **Research PowerShell YAML** - Can I delegate to AI researcher now?

What should I tackle first?
