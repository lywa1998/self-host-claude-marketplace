---
name: meta-skills
description: >
  Patterns for structuring, composing, and improving agent skills, plus the
  Meta-Skilling Framework (MSF) for developing new skills from zero to competent.
  Covers skill routing, chunked processing, collaboration protocols, quality gates,
  MSF five phases (Discovery, Practice, Capture, Validation, Iteration), the
  SKILL.md template, and stackability patterns. Use when creating new skills,
  improving existing ones, designing multi-skill workflows, building a skill
  hierarchy, reviewing whether an existing skill needs iteration, or deciding how
  to decompose a domain into sub-skills.
---

# Meta-Skills — Patterns for Authoring Agent Skills

> Source: `isaac-sim/IsaacSim/skills/meta-skills/SKILL.md`

Two parts:
1. Composition patterns: structuring and orchestrating skills.
2. Meta-Skilling Framework (MSF): building new skills from zero.

## Core Operating Principle: Distillation Is Not Optional

Every user request follows a six-step loop: **ORIENT → PLAN → EXECUTE → VALIDATE → DISTILL → DELIVER**. The DISTILL step is mandatory, not aspirational. If a task produced a new insight, workaround, correction, or procedure, the relevant skill file must be updated **before** the response is delivered.

---

# Part 1: Composition Patterns

## 1. Skill Routing

**Pattern:** A top-level orchestrator skill routes to specific sub-skills based on task category.

```
User request → Orchestrator reads context → Routes to specific skill
                                          → Provides shared patterns
```

**Key insight:** The orchestrator doesn't do the work — it identifies which specialist skill should handle it and provides cross-cutting concerns (units, naming, validation).

**Example in this library:** `isaac-sim-orchestrator` — turns natural-language requests into runnable sims and routes to `usd-pipeline`, `isaac-sim-rendering`, `isaac-sim-validator`, `physics-simulation`.

## 2. Chunked Processing

**Pattern:** Prevent context overflow by enforcing batch limits and tier-by-tier processing.

Rules:
- Never process more than N items at once (N=10-20 for complex assets)
- Process in tiers: leaf assets first, then composites, then top-level
- After each chunk, summarize and checkpoint before continuing
- Use explicit "processing X of Y" progress tracking

## 3. Quality Gates

**Pattern:** Mandatory external review before publishing any output.

Steps:
1. Generate output (render, code, asset)
2. Upload for review (e.g., image to local host at `$IMAGE_SERVER_URL`)
3. Flood context — include full setup, known issues, what was tried
4. Require minimum score (e.g., 7/10) before sharing
5. Iterate based on prioritized improvement list

## 4. Multi-Skill Composition

**Pattern:** Complex tasks declare skill dependencies explicitly.

```yaml
Dependencies:
  - spatial-reasoning            # all transform math
  - urdf-mjcf-to-usd-conversion       # robot asset import
  - usd-articulation             # multi-link validation
  - physics-simulation           # scene + per-prim physics
  - isaac-sim-rendering          # headless render + tone mapping
```

## 5. Environment Variables, Not User Paths

Skills run on different machines. Every absolute path is a portability bug.

| Replace | With |
|---|---|
| hardcoded Isaac Sim checkout path | `$ISAAC_SIM_DIR` |
| hardcoded SimReady asset path | `$SIMREADY_ASSETS/...` |
| `localhost:8095` | `$KB_SERVICE_URL` |

The orchestrator skill owns the env-var contract; per-skill files reference vars, never declare values.

---

# Part 2: Meta-Skilling Framework (MSF)

A systematic, repeatable process for developing new skills from zero to competent in any domain.

## When to Use MSF
- Starting to learn any new tool, domain, or capability
- Building a skill hierarchy (e.g., Blender → modeling, materials, rigging...)
- Reviewing whether an existing skill needs iteration

## The Five Phases

### Phase 1: Discovery — define what you need to learn and why
1. Identify the need — what problem does this skill solve?
2. Define scope — boundaries; one skill or a hierarchy?
3. Break down sub-skills — list components, create hierarchy if complex
4. Research resources — official docs, API references, tutorials
5. Set competence goals — specific tasks you should be able to perform when done
6. Check existing skills — do any of your skills overlap? Link and reuse.

**Output:** Initial SKILL.md with purpose, scope, hierarchy, resources, goals.

### Phase 2: Practice — build hands-on competence through structured experimentation
1. Follow the learning path — foundational, then advance
2. Do small practical tasks — don't just read; build
3. Take notes AS you go — commands, workflows, gotchas
4. Identify patterns — what's repeatable, what can be scripted
5. Track challenges — tag what's hard; these become iteration targets

**Output:** Raw practice notes, initial scripts, identified patterns.

### Phase 3: Capture — convert raw learnings into structured, reusable knowledge
1. Organize — convert practice notes into structured sections
2. Standardize — follow the SKILL.md template (below)
3. Save scripts — working code in `scripts/`. Reference docs in `references/`.
4. Version — start at v0.1, increment on significant updates
5. Link related skills — cross-reference parent/child/sibling skills

**Critical Rule:** If it's not in the file, it doesn't exist next session.

### Phase 4: Validation — prove the skill actually works
1. Test it — perform a real task using only what's documented
2. Check against goals — can you do what Discovery said you should?
3. Identify gaps — tag as "Validation Gaps" for iteration
4. Get feedback — from user, validator, or test results

### Phase 5: Iteration — refine and expand based on real usage
1. Review gaps at session start
2. Research solutions
3. Update and version
4. Expand scope — add sub-skills once core is solid
5. Re-validate

## SKILL.md Template

```markdown
---
name: skill-name
description: >
  [1-3 sentences: what, when to use, triggers]
---

# [Skill Name]

## When to Use This Skill
- [task 1]
- [task 2]

## Related / Integration Points
- RECEIVES from: [skill] → [data]
- PRODUCES for: [skill] → [data]

## Core Concepts
[Organized knowledge]

## Key Workflows
[Step-by-step procedures with code]

## Decision Trees
[Branching logic for "it depends" situations]

## Failure Modes & Recovery
For each major workflow:
- FAILURE: [what goes wrong]
- SYMPTOMS: [how you notice]
- CAUSE: [why]
- RECOVERY: [fix]
- PREVENTION: [how to avoid]

## Expert Intuition
- Rules of thumb
- Smell tests
- Proportional judgments

## Environment Requirements
Pre-flight checks and tool versions.

## Iteration Log
- v0.1 [date]: Initial capture
```

## Session Start Protocol

1. Read this file to remember the framework
2. Read the PARENT skill for the domain you're working in
3. Read the specific SUB-SKILL you're focusing on
4. Check Challenges & Gaps — that's your TODO
5. Pick up where the last session left off

## Anti-Patterns

- Learning without capturing — you WILL forget
- Starting too broad — focus on one sub-skill at a time
- Skipping validation — untested = unreliable
- Copy-pasting tutorials without adapting to YOUR context
- Ignoring existing skills — always check for overlap first
- Perfectionism before practice — rough working skill beats perfect plan
