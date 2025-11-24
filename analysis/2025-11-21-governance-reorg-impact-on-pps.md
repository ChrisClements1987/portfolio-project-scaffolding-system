# Governance Reorganization Impact on PPS

**Date:** 2025-11-21  
**Author:** Christopher Clements  
**Related Project:** governance-reorganization-2025-11  
**Impact Level:** High

---

## Summary

The November 2025 governance reorganization significantly improves PPS's foundation by clarifying structure, expanding metamodel, and creating clear policies/processes to automate.

**Net Impact:** ✅ Positive - Better foundation, clearer targets, more automation opportunities

---

## Key Changes Affecting PPS

### 1. Path Changes (Breaking)

| Old Path | New Path | Impact on PPS |
|----------|----------|---------------|
| `40-boilerplates/` | `30-resources/10-boilerplates/` | ✅ Updated in project.yaml |
| `21-meta-projects/` | `10-projects/` | ✅ Updated in README |
| `01-policies/` | `02-governance/00-standards-and-policies/` | ⚠️ Need to update cross-references |
| `50-schemas/` | `standards/metadata-and-taxonomy/` | ⚠️ Need to update schema references |

**Action Required:** Full path audit of PPS documentation and any remaining scripts.

---

### 2. New Governance Structure

**Before (Monolithic):**
```
02-governance/
└── portfolio-items-and-lifecycles.md (667 lines)
```

**After (Organized):**
```
02-governance/
├── 00-standards-and-policies/
│   ├── policies/              # WHEN/WHY
│   │   ├── item-definitions.md
│   │   ├── lifecycle-rules.md
│   │   ├── archive-and-retention.md
│   │   └── data-hygiene-and-sharing.md
│   └── standards/             # HOW/WHAT
│       ├── naming-conventions/
│       ├── metadata-and-taxonomy/
│       ├── coding-standards/
│       └── ... (8 categories)
├── 01-processes/              # STEP-BY-STEP
│   ├── idea-promotion.md
│   ├── concept-to-project-promotion.md
│   ├── archive-and-restoration.md
│   └── data-hygiene-workflows.md
└── 02-decision-records/       # WHY
    ├── adr/
    ├── odr/
    └── sdr/
```

**PPS Benefit:** Clear targets for automation - each process is now automatable.

---

### 3. New Policies to Automate

**Created in reorganization:**

| Policy | PPS Automation Opportunity |
|--------|---------------------------|
| `lifecycle-rules.md` | Automate review reminders, promotion triggers |
| `item-definitions.md` | Validate item structure compliance |
| `archive-and-retention.md` | Automate archiving completed projects |
| `data-hygiene-and-sharing.md` | Pre-commit secret/PII scanning |

**Action Required:** Add to PPS Phase 3/4 roadmap.

---

### 4. Expanded Metamodel

**New files:**
- `00-metamodel/entity-overview.md` - All entity definitions
- `00-metamodel/glossary.md` - Portfolio vocabulary

**PPS Benefit:**
- Clear entity definitions for validation
- Standard terminology for error messages
- Better AI agent context

**Action Required:** Reference glossary in PPS help text and validation messages.

---

### 5. Enhanced Processes

**All processes now have:**
- "Implements Policies" header (clear traceability)
- Updated boilerplate paths
- Data hygiene checkpoints
- Concept `_meta.yaml` creation

**PPS Benefit:** Clear workflows to automate end-to-end.

**Action Required:** Update PPS roadmap with process automation priorities.

---

## PPS Work Items from Governance Reorg

### Immediate (Phase 1.5 - This Branch)

- [x] Update project.yaml dependencies
- [x] Update README paths and version
- [x] Create this impact analysis
- [ ] Update any remaining docs with new paths
- [ ] Update related_policies list in project.yaml

### High Priority (Phase 2)

**From 04-automation integration:**
- [ ] Review 04-automation scripts for duplication with PPS
- [ ] Decide: Keep scripts in 04-automation or move to PPS repo?
- [ ] Create shared PortfolioHelpers.psm1 module
- [ ] Implement New-PortfolioProject.ps1 properly

**From new processes:**
- [ ] Automate archive-and-restoration.md workflow
- [ ] Implement data-hygiene pre-commit checks
- [ ] Support concept _meta.yaml creation

### Medium Priority (Phase 3)

**From lifecycle policies:**
- [ ] Automate Concept → Experiment promotion
- [ ] Automate Experiment → Project migration
- [ ] Implement review cadence reminders

**From standards:**
- [ ] Validate naming conventions compliance
- [ ] Validate metadata schema compliance
- [ ] Enforce coding standards in generated code

### Low Priority (Phase 4)

- [ ] Generate health check reports
- [ ] Auto-fix common compliance issues
- [ ] Integration with metamodel glossary

---

## Dependencies Updated

**Old dependencies:**
```yaml
depends_on:
  - "00-meta/40-boilerplates/"
  - "00-meta/02-governance/.../schemas/"
  - "version-control-policy.md"
```

**New dependencies:**
```yaml
depends_on:
  - "00-meta/30-resources/10-boilerplates/"
  - ".../metadata-and-taxonomy/project-metadata-schema.md"
  - ".../policies/security-and-compliance/version-control-policy.md"
  - "00-meta/02-governance/01-processes/"
  - "00-meta/00-metamodel/"
```

---

## Timeline Impact

**Original Target:** December 31, 2025  
**New Assessment:** Achievable with focused effort

**Rationale:**
- Governance cleanup removes blockers
- Clear policies/processes to implement
- 04-automation provides starting scripts
- Shared work reduces duplication

**Recommended:** Keep December target, add buffer to Q1 2026 if needed.

---

## Risks & Mitigations

**Risk:** Governance structure changes again  
**Mitigation:** Use config-driven paths, not hard-coded

**Risk:** Scope creep from new automation opportunities  
**Mitigation:** Prioritize ruthlessly, defer Phase 4 items

**Risk:** 04-automation vs PPS duplication  
**Mitigation:** Establish clear ownership (see recommendations)

---

## Recommendations for PPS

### 1. Clarify 04-automation vs PPS Ownership

**Proposal:**
- **04-automation/:** Production scripts (stable, reusable)
- **PPS repo:** Development, planning, migration scripts
- **Flow:** Develop in PPS → Graduate to 04-automation when stable

**Alternative:**
- Merge PPS implementation directly into 04-automation
- PPS becomes planning-only project

**Decision needed:** Which model to use?

---

### 2. Update PPS Roadmap

**Add milestones:**
- Governance integration (this work)
- 04-automation ownership decision
- Process automation implementation
- Data hygiene integration

---

### 3. Link Projects

**In PPS project.yaml:**
```yaml
related_projects:
  - slug: "governance-reorganization-2025-11"
    relationship: "governance-foundation"
    description: "Cleaned governance structure PPS automates"
```

---

## Next Steps

**Immediate (Complete this branch):**
1. Review any remaining path references
2. Update related_policies in project.yaml
3. Commit and PR this governance integration
4. Merge to main

**This Week:**
1. Review 04-automation scripts against PPS vision
2. Decide ownership model
3. Plan Phase 2 implementation
4. Update PPS status to active

**Next Week:**
1. Implement core scaffolder
2. Create shared module
3. Test end-to-end

---

**Analysis Complete**  
**Status:** Ready for PPS team decision on next actions
