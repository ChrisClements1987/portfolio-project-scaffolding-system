# ✅ Project Brief (REVISED)

## Portfolio Governance Tooling & Hardening Initiative

**Version:** 2.0.0 (Revised based on maturity assessment)  
**Location:** `C:\Portfolio` (Personal, Family, Community domains ONLY)  
**Owner:** Chris Clements  
**Start Date:** 2025-10-29  
**Approach:** Kanban-driven, pilot-led, metadata-driven

---

## 🎯 Objective

Strengthen **security**, **AI governance**, and **documentation consistency** across Portfolio Meta-governed domains through **lightweight, metadata-driven automation** that respects tiered enforcement needs.

**NOT enterprise governance** - Right-sized for personal/family/small OSS context.

---

## 🏛 Scope (CORRECTED)

### Portfolio Meta Governs

**IN SCOPE:**
- ✅ `00-meta/` - Portfolio operations
- ✅ `10-personal/` - Personal projects
- ✅ `20-family/` - Family projects
- ✅ `30-community/` - Community projects YOU lead

**OUT OF SCOPE:**
- ❌ `40-business/` - Governed by meta-repo-seed (business meta)
- ❌ Community projects others lead - Use `.portfolio-meta-exclude`

**Critical:** This initiative does NOT touch business domain.

---

## 📊 Current State (From Maturity Assessment)

| Domain | Score | Status | Priority Gaps |
|--------|-------|--------|---------------|
| **Meta-repo-seed** | 4.4 | ✅ Excellent | N/A (out of scope) |
| **Community OSS** | 1.3 | ⚠️ Variable | Security, AI gov, README |
| **Personal** | 0.4 | ⚠️ Minimal | AI gov when used |
| **Family** | 0.1 | ✅ Appropriately minimal | Docs when collaborative |

**Critical Findings:**
1. 🔴 **Security blind spot** - No Dependabot/CodeQL on public OSS
2. 🔴 **AI governance missing** - Heavy AI use, zero detection mechanisms
3. ⚠️ **README inconsistent** - Strategy defined, not applied
4. ⚠️ **Documentation drift** - AGENTS.md rare despite AI assistance

---

## ✅ Work to Perform

### Deliverables (Metadata-Driven)

1. **`.portfolio-meta.yaml` schema** - Declarative enforcement per project
2. **AI detection (Layers 1-2)** - Environment var + .commit-meta.json
3. **README automation** - Checker script + generator template
4. **Security baseline** - Dependabot + CodeQL on public/active repos
5. **AGENTS.md enforcement** - Required when ai_allowed: true
6. **Tier-specific templates** - Minimal/Standard/Strict
7. **Pre-commit hooks** - AI detection + validation
8. **Governance checklist script** - Simple maturity scorer (not badge service)

**NOT delivering:**
- ❌ Dashboard/badge service (overhead, defer)
- ❌ Enterprise SaaS tools (Swimm, SonarCloud, Snyk, Qodana)
- ❌ Business domain tooling (out of scope)
- ❌ Complex quality gates (TDD is business meta's domain)

---

## 🧩 Right-Sized Tooling

### Tools We'll Use (GitHub-Native + OSS)

| Area | Tool | Cost | Scope |
|------|------|------|-------|
| **Security** | Dependabot | Free (public), included (private) | All public OSS |
| **Security** | CodeQL | Free (public), limited (private) | Public OSS, optional business |
| **Secrets** | Gitleaks | Free (OSS) | Pre-commit or CI |
| **Docs (optional)** | Vale | Free (OSS) | Advisory prose linting |
| **Containers** | Trivy | Free (OSS) | Only if containers used |
| **README** | Custom PS script | Free | Portfolio-specific |
| **AI Detection** | Custom PS script | Free | Portfolio-specific |

**Total added cost:** $0 for portfolio meta scope

### Tools We're NOT Using (Why)

| Tool | Reason to Skip |
|------|----------------|
| **Swimm** | SaaS lock-in, overhead for small repos, docs already covered |
| **SonarCloud** | Overlaps CodeQL, adds noise, enterprise-focused |
| **Qodana** | JetBrains lock-in, unnecessary for portfolio scope |
| **Snyk** | Overlaps Dependabot, costs money at scale, enterprise-focused |
| **Checkov** | Only needed if heavy IaC (Terraform, etc.) - rare in portfolio |

**Defer these** unless specific repo justifies (e.g., Strategos might want Qodana if it helps Rust/TS quality)

---

## 🧠 Enforcement Model (Metadata-Driven)

### .portfolio-meta.yaml (Single Source of Truth)

**Every project declares:**
```yaml
enforcement: minimal | standard | strict
ai_allowed: true | false
no_bypass: false  # true = absolute enforcement
require_adr: auto | true | false  # auto = risk-based
require_agents_md: auto | true | false  # auto = if ai_allowed
```

**Domain defaults:**
- Personal (solo human): minimal
- Personal (AI): standard
- Family (Chris solo): standard
- Family (collaborative): strict
- Community (you lead): strict
- Meta: standard

**Automation reads metadata** - no calculation needed

---

### Enforcement Levels

**Minimal:**
- README exists (basic)
- No broken links
- Gitleaks (advisory)

**Standard:**
- README strategy compliant
- AGENTS.md if ai_allowed
- Basic CI (ci-lite)
- Dependabot (if public OSS)
- Gitleaks (blocking)

**Strict:**
- All Standard +
- Branch protection
- CODEOWNERS
- CodeQL (if public OSS)
- ADRs for risk triggers
- Structured TODO tags (AI commits)
- Tests required

---

## 🛡️ AI Governance (Portfolio Innovation)

### AI Detection Stack (Phased)

**Phase 1 (Now):**
- **Layer 1:** Environment variable (`AI_AGENT=true`)
- **Layer 2:** Commit metadata file (`.commit-meta.json`)

**Phase 2 (Later):**
- **Layer 4:** Branch convention (`ai/{agent}/{description}`)
- **Layer 3:** GPG signatures (if needed)
- **Layer 5:** Author pattern (fallback)

---

### AI Enforcement Rules

**AI commits ALWAYS:**
- ✅ Use strict enforcement (no bypass)
- ✅ Use structured tags
- ✅ Update AGENTS.md when structure changes
- ✅ Run full tests
- ✅ Cannot use --no-verify

**Human commits:**
- Context-aware (per .portfolio-meta.yaml)
- Can bypass minimal/standard with `PORTFOLIO_HUMAN_MODE=true`
- Strict requires justification to bypass

---

## 📋 Kanban-Driven Implementation (Not Time-Phased)

### Backlog (Prioritized by Impact)

**Epic 1: Security Hardening (CRITICAL)**
- [ ] Enable Dependabot on public OSS (bonsort, fylum, proprompt, repop, multicode)
- [ ] Enable CodeQL on public OSS
- [ ] Add Gitleaks to pre-commit or CI
- [ ] Document secrets handling in READMEs

**Effort:** Small (1-2h)  
**Risk Reduction:** HIGH

---

**Epic 2: AI Governance (HIGH)**
- [ ] Implement AI detection Layers 1-2
- [ ] Create pre-commit hook with AI detection
- [ ] Create AGENTS.md for AI-assisted projects
- [ ] Add ai_allowed to .portfolio-meta.yaml schema
- [ ] Enforce AGENTS.md when ai_allowed: true

**Effort:** Medium (4-6h)  
**Prevents:** AI drift

---

**Epic 3: README Strategy Application (HIGH)**
- [ ] Create readme-checker.ps1
- [ ] Apply README strategy to meta-repo-seed (dogfood)
- [ ] Apply to 5 active projects (2 OSS, 1 personal, 1 family, 1 meta)
- [ ] Create readme-generator.ps1

**Effort:** Medium (4-6h)  
**Improves:** Navigation, AI context

---

**Epic 4: Metadata Infrastructure (MEDIUM)**
- [ ] Finalize .portfolio-meta.yaml schema
- [ ] Create .portfolio-meta.yaml generator script
- [ ] Add to project templates
- [ ] Document .portfolio-meta-exclude for community

**Effort:** Medium (3-4h)  
**Enables:** Declarative enforcement

---

**Epic 5: CI-Lite Template (MEDIUM)**
- [ ] Create reusable GitHub Actions workflow
- [ ] Single job: lint + test (language-aware)
- [ ] Apply to active OSS (fylum, proprompt, multicode, repop)

**Effort:** Medium (3-4h)  
**Adds:** Basic quality gates

---

**Epic 6: Tier-Specific Templates (MEDIUM)**
- [ ] Issue/PR templates (minimal, standard, strict)
- [ ] .gitignore templates
- [ ] Pre-commit config templates
- [ ] Apply to applicable repos

**Effort:** Small-Medium (2-4h)  
**Improves:** Contribution clarity

---

**Epic 7: Advanced Automation (LOW - Defer)**
- [ ] readme-sync.ps1 (parent/children sync)
- [ ] readme-version.ps1 (version management)
- [ ] tag-linter.ps1 (structured tag validation)
- [ ] Governance score table generator
- [ ] Weekly validation automation

**Effort:** Large (10-15h)  
**Can Wait:** Nice-to-have optimizations

---

## 🚀 Pilot-Led Rollout

### Phase 0: Pilot (Week 1)

**Target Projects (5):**
1. **fylum** (Community OSS) - Standard enforcement
2. **bonsort** (Community OSS) - Standard to Strict
3. **personal-ux/contacts** (Personal + AI) - Standard enforcement
4. **Portfolio meta (00-meta)** (Meta) - Standard enforcement
5. **family-calendars** (Family) - Minimal to Standard

**Validate:**
- Security scanning works (Dependabot/CodeQL)
- AI detection works (Layers 1-2)
- README strategy applies cleanly
- .portfolio-meta.yaml drives enforcement
- No workflow breakage

**Adjust based on learnings**

---

### Phase 1: Template & Scale (Weeks 2-4)

**After pilot success:**
- Apply learnings to templates
- Roll out to remaining active projects
- Create reusable workflows
- Document adoption guide

---

### Phase 2: Optimize (Ongoing)

- Refine automation based on actual use
- Add advanced features (if justified)
- Monitor and improve

---

## 🔒 Risk Controls (Enhanced)

### Safety Mechanisms

**1. Metadata Overrides:**
```yaml
# .portfolio-meta.yaml
overrides:
  disable_enforcement: true  # Emergency escape hatch
  override_reason: "Reason here"
  override_expires: 2025-11-30  # Auto-reverts
```

**2. Human Bypass (Documented):**
- Environment variable: `PORTFOLIO_HUMAN_MODE=true`
- Git flag: `--no-verify` (with justification if strict)
- Logged for review

**3. Exclusion for External Governance:**
- `.portfolio-meta-exclude` for community projects not led by you
- Automation skips these repos

**4. Advisory-First Rollout:**
- New checks start as warnings
- Promote to errors after validation
- Always test on pilot repos first

**5. Rollback Ready:**
- Git allows reverting automation changes
- Disable flags in metadata
- Document escape procedures

---

## 📈 Success Criteria (Simplified)

**Within 30 days:**
- ✅ Zero security incidents from lack of scanning
- ✅ Dependabot + CodeQL enabled on all public OSS
- ✅ AI detection operational (Layers 1-2)
- ✅ 5 pilot projects compliant with standards
- ✅ Zero workflow breakage

**Within 90 days:**
- ✅ README strategy applied to all active projects (15+)
- ✅ AGENTS.md present where ai_allowed: true
- ✅ .portfolio-meta.yaml in all active repos
- ✅ Community average score: 1.3 → 2.5
- ✅ Personal/Family scores appropriate for tier

**Ongoing:**
- ✅ AI commits cannot bypass validation
- ✅ Documentation drift <5%
- ✅ Security scanning coverage 100% of public repos

---

## ✅ Deliverables Checklist (Revised)

| Deliverable | Priority | Effort |
|-------------|----------|--------|
| **Dependabot + CodeQL enabled** | 🔴 Critical | S (1-2h) |
| **AI detection L1-L2** | 🔴 Critical | M (4-6h) |
| **.portfolio-meta.yaml schema** | 🟠 High | M (3-4h) |
| **readme-checker.ps1** | 🟠 High | M (3-4h) |
| **Pre-commit hook with AI detection** | 🟠 High | M (3-4h) |
| **AGENTS.md where ai_allowed** | 🟠 High | S (per repo, 1h each) |
| **ci-lite workflow** | 🟡 Medium | M (3-4h) |
| **Issue/PR templates** | 🟡 Medium | S (2-3h) |
| **Gitleaks integration** | 🟡 Medium | S (1-2h) |
| **readme-generator.ps1** | 🟢 Low | M (4-5h) |
| **Governance score table script** | 🟢 Low | S (2h) |
| ~~**Dashboard/badge service**~~ | ❌ **Deferred** | - |
| ~~**SonarCloud/Snyk/Swimm**~~ | ❌ **Not needed** | - |

---

## 🛠️ Right-Sized Tooling Stack

### Core Tools (GitHub-Native + Free OSS)

**Security:**
- ✅ **Dependabot** - Dependency updates (FREE)
- ✅ **CodeQL** - Security scanning (FREE for public)
- ✅ **Gitleaks** - Secret scanning (FREE OSS tool)
- ⚠️ **Trivy** - Container scanning (only if containers used)

**Quality:**
- ✅ **Language-native linters** (ruff/black for Python, ESLint for JS, etc.)
- ✅ **ci-lite workflow** - Simple test + lint job
- ❌ ~~SonarCloud~~ - Overkill, costs money
- ❌ ~~Qodana~~ - JetBrains lock-in

**Documentation:**
- ✅ **README checker/generator** - Custom PowerShell (matches portfolio needs)
- ⚠️ **Vale** - Prose linting (advisory only, optional)
- ❌ ~~Swimm~~ - SaaS overhead unnecessary

**AI Governance:**
- ✅ **Custom AI detection** - Layers 1-2 (env var + .commit-meta.json)
- ✅ **AGENTS.md validation** - Custom script
- ✅ **Structured tag linting** - Custom script (for AI commits)

**Versioning:**
- ✅ **Conventional Commits** - Optional (recommended for OSS)
- ✅ **CHANGELOG.md** - Manual or automated from commits
- ❌ ~~Semantic Release~~ - Defer (manual semver OK initially)

---

## 📐 Tiered Enforcement (Metadata-Driven)

### Enforcement Determined By

**NOT calculated** - Read from `.portfolio-meta.yaml`:

```yaml
# Example: Personal project with AI
enforcement: standard
ai_allowed: true
no_bypass: false
require_agents_md: true  # Auto: true when ai_allowed
require_adr: auto  # Auto: risk-based triggers
```

### Domain Defaults (If metadata missing)

| Domain | Human Solo | Human + AI | Collaborative |
|--------|------------|------------|---------------|
| **Personal** | minimal | standard | standard |
| **Family (Chris)** | standard | standard | strict |
| **Family (Others)** | strict | strict | strict |
| **Community (you lead)** | strict | strict | strict |
| **Meta** | standard | standard | strict |

---

## 🔐 AI Detection Implementation

### Layers 1-2 (Now)

**Layer 1: Environment Variable**
```powershell
# AI must set before committing
$env:AI_AGENT = "true"
$env:AI_AGENT_NAME = "amp" | "cursor" | "copilot"
```

**Layer 2: Ephemeral Metadata File**
```json
// .commit-meta.json (created pre-commit, deleted post-commit)
{
  "commit_type": "ai-generated",
  "agent": "amp",
  "timestamp": "2025-10-29T12:00:00Z",
  "session_id": "abc-123",
  "human_reviewed": false
}
```

**Pre-commit hook validates both**

---

### Layers 3-5 (Later, If Needed)

**Defer unless:**
- Multiple AI agents collaborating
- Audit/compliance requirements
- Cryptographic provenance needed

---

## 📅 Kanban-Driven (Not Time-Based)

### Kanban Structure

**Location:** `/00-meta/20-operations/kanban/governance-hardening/`

**Or:** GitHub Projects board

**Columns:**
- 📥 Backlog
- 🔜 Ready (validated approach, ready to implement)
- 🏗️ In Progress
- 👀 Review
- ✅ Done

**Work priority:** Critical → High → Medium → Low  
**Work as capacity allows** - no fixed deadlines

---

### Epic Breakdown

**Critical Security (Do First):**
- Enable Dependabot (6 repos × 15min = 1.5h)
- Enable CodeQL (6 repos × 15min = 1.5h)
- Add Gitleaks (1-2h for template)

**High Priority AI Governance:**
- AI detection script (3-4h)
- Pre-commit hook with AI detection (2-3h)
- Create AGENTS.md template (done)
- Apply to 5 projects (5h)

**High Priority Documentation:**
- readme-checker.ps1 (3-4h)
- Apply README strategy to 5 pilots (5h)
- Document .portfolio-meta.yaml (done)

**Medium Priority Quality:**
- ci-lite workflow (3-4h)
- Apply to 4 OSS repos (4h)

**Low Priority Polish:**
- Advanced automation (defer)
- Governance scoring (simple version OK)

---

## 🎯 Pilot Projects (Validate Before Scaling)

**Pilot targets:**

1. **fylum** - Active OSS, AI-assisted, needs security + README
2. **bonsort** - Mature OSS, good baseline, add security
3. **personal-ux/contacts** - Personal + AI, test AI detection
4. **00-meta** - Meta domain, dogfood standards
5. **family-calendars** - Family, test collaborative standards

**Success criteria per pilot:**
- Security scanning enabled without breaking workflow
- AI detection catches AI commits correctly
- README strategy applied without issues
- .portfolio-meta.yaml drives enforcement accurately
- No false positives/negatives

**Adjust templates/automation based on pilot learnings**

---

## ⚠️ Risk Mitigation (Enhanced)

**Risk 1: Breaks existing workflows**
- **Mitigation:** Pilot first, advisory mode initially, metadata escape hatches

**Risk 2: AI detection false positives**
- **Mitigation:** Multi-layer detection (redundancy), logging for audit, human override

**Risk 3: Tool noise/alert fatigue**
- **Mitigation:** Use only high-signal tools, configure properly, start advisory

**Risk 4: Scope creep into business**
- **Mitigation:** Explicit scope boundaries, .portfolio-meta-exclude, document business is out of scope

**Risk 5: Over-automation maintenance burden**
- **Mitigation:** Use simple scripts over complex services, defer nice-to-haves, keep tool count low

**Risk 6: Community friction**
- **Mitigation:** .portfolio-meta-exclude for external governance, your lead = your rules applies only to projects you actually lead

---

## 📊 Success Metrics (Measurable)

### Security

- ✅ 100% of public OSS have Dependabot enabled
- ✅ 100% of public OSS have CodeQL enabled  
- ✅ Zero secret leaks (Gitleaks catches all)
- ✅ Zero critical vulnerabilities unpatched >7 days

### AI Governance

- ✅ 100% of AI commits detected correctly
- ✅ Zero AI bypass of validation
- ✅ AGENTS.md present where ai_allowed: true
- ✅ AI contributions logged for audit

### Documentation

- ✅ 90% of active projects have README following strategy
- ✅ Documentation drift <5%
- ✅ All .portfolio-meta.yaml files valid

### Quality

- ✅ Active OSS have CI (ci-lite minimum)
- ✅ Strict tier repos have tests
- ✅ No broken links in documentation

### Maturity Scores (From Assessment)

- Community OSS: 1.3 → **2.5** (target)
- Personal: 0.4 → **1.5** (target, when AI involved)
- Family: 0.1 → **1.0** (target, when collaborative)

**Review:** Monthly (not weekly - too frequent)

---

## 🏁 Done Means…

**Governance is:**
- ✅ **Metadata-driven** - .portfolio-meta.yaml controls enforcement
- ✅ **AI-hardened** - AI cannot drift, detection works
- ✅ **Security-baseline** - Public repos scanned, secrets protected
- ✅ **Documentation-consistent** - README strategy applied, AGENTS.md where needed
- ✅ **Appropriately tiered** - Strict where needed, minimal where appropriate
- ✅ **Low-maintenance** - Simple tools, automated where valuable
- ✅ **Non-disruptive** - Zero business workflow impact (out of scope)

**NOT:**
- ❌ Enterprise-grade with dashboards/badges
- ❌ Enforcing business standards (that's meta-repo-seed)
- ❌ One-size-fits-all governance

---

## 🔄 Integration with Existing Work

### Builds On

- ✅ README-STRATEGY.md (00-meta/01-policies/)
- ✅ CODE-DOCUMENTATION-STANDARDS-V3.md (00-meta/01-policies/)
- ✅ PORTFOLIO-GOVERNANCE-MATURITY-ASSESSMENT.md (assessment complete)
- ✅ meta-repo-seed-learnings.md (business alignment tracked)

### Feeds Into

- 🔄 meta-repo-seed adoption (after validation in portfolio)
- 🔄 Business meta standards (document what works)

### Scope Boundaries

**Portfolio Meta** (this initiative) ↔ **Business Meta** (meta-repo-seed)
- Separate governance systems
- Learn from each other
- No overlap/conflict
- Feed learnings quarterly

---

## 💰 Cost Analysis

### One-Time Costs
- **Implementation time:** ~25-35 hours (spread over 4-6 weeks as capacity allows)
- **Learning curve:** Minimal (using familiar tools)

### Recurring Costs
- **Tool subscriptions:** $0 (all free for our scope)
- **Maintenance time:** ~2-4 hours/month (README audits, security patch reviews)
- **False positive handling:** ~1 hour/month (adjust tool configs)

### Avoided Costs (Deferred Tools)
- SonarCloud: ~$10-20/month
- Snyk: ~$25/month
- Swimm: ~$20/user/month
- **Saved:** ~$50-60/month by using GitHub-native + OSS

---

## ✅ Authorization (Clarified)

**AI Agent is authorized to:**
- ✅ Create .portfolio-meta.yaml files (reviewed by human)
- ✅ Enable Dependabot/CodeQL (one-time setup, approved by human)
- ✅ Create README following strategy (reviewed before commit)
- ✅ Create AGENTS.md from template (reviewed before commit)
- ✅ Propose CI workflows (human approves before merge)
- ✅ Update documentation (human reviews)

**AI Agent must NOT:**
- ❌ Merge PRs without human approval
- ❌ Bypass validation (cannot --no-verify)
- ❌ Touch business domain (40-business/)
- ❌ Modify governance scripts without review
- ❌ Enable enforcement without pilot validation

**Human approval required for:**
- All PRs
- Enforcement level increases
- New automation scripts
- Tool additions

---

## 📚 Related Documents

**Standards:**
- [CODE-DOCUMENTATION-STANDARDS-V3.md](/00-meta/01-policies/CODE-DOCUMENTATION-STANDARDS-V3.md)
- [README-STRATEGY.md](/00-meta/01-policies/README-STRATEGY.md)

**Analysis:**
- [PORTFOLIO-GOVERNANCE-MATURITY-ASSESSMENT.md](/00-meta/20-operations/research/PORTFOLIO-GOVERNANCE-MATURITY-ASSESSMENT.md)
- [meta-repo-seed-learnings.md](/00-meta/20-operations/research/meta-repo-seed-learnings.md)

**Templates:**
- [ADR-TEMPLATE.md](/00-meta/60-shared-resources/templates/architecture/ADR-TEMPLATE.md)
- [AGENTS-TEMPLATE.md](/00-meta/60-shared-resources/templates/project-templates/AGENTS-TEMPLATE.md)
- [PR templates](/00-meta/60-shared-resources/templates/github/)

---

## 🔄 Differences from Original Brief

### Major Corrections

| Original | Revised | Reason |
|----------|---------|--------|
| Includes 40-business (Tier A) | **Excluded** | Business has own meta (meta-repo-seed) |
| Time-based phases | **Kanban-driven** | Flexible, capacity-based approach |
| Enterprise tools (Swimm, SonarCloud, Snyk) | **GitHub-native + OSS only** | Cost, complexity, scope-appropriate |
| Calculated tiers | **Metadata-driven** (.portfolio-meta.yaml) | Explicit, no guesswork |
| Governance badge service | **Simple score table script** | Simpler, no service overhead |
| Vague AI governance | **Hardened 5-layer detection** | Specific, proven approach |
| Generic README mention | **Portfolio README strategy** | Detailed (version, nav, contents, sync) |

### Additions

- ✅ .portfolio-meta-exclude mechanism
- ✅ Human bypass mechanisms (PORTFOLIO_HUMAN_MODE, justifications)
- ✅ AI detection multi-layer stack
- ✅ Risk-based ADR triggers (correctness/safety/collaboration)
- ✅ AGENTS.md requirement tied to ai_allowed metadata
- ✅ Pilot-led validation approach
- ✅ Integration with existing portfolio meta work

---

## 🚦 Next Steps

### Before Starting Implementation

1. **Review and approve** this revised brief
2. **Answer open questions** (if any remaining)
3. **Prioritize epics** in Kanban
4. **Identify pilot week** (when you have 4-6 hours capacity)

### Week 1 (Pilot)

5. **Critical security** - Enable Dependabot + CodeQL (1.5h)
6. **Pilot project 1** - Apply to fylum (2-3h)
7. **Validate** - Check nothing broke

### Ongoing

8. **Work through Kanban** - One epic at a time
9. **Monthly review** - Assess progress and adjust
10. **Feed learnings** - Document for meta-repo-seed quarterly

---

## Version History

### 2.0.0 (2025-10-29)
- Complete revision based on portfolio meta standards
- Corrected scope (removed business domain)
- Right-sized tooling (removed enterprise SaaS)
- Metadata-driven enforcement
- Hardened AI detection
- Kanban approach vs time-phased
- Pilot-led validation
- Integrated with existing portfolio meta work

### 1.0.0 (2025-10-29)
- Original brief from GPT-5 (superseded)
