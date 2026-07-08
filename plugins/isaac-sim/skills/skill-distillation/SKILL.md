---
name: skill-distillation
description: >
  Step 5 of the request loop (`ORIENT -> PLAN -> EXECUTE -> VALIDATE ->
  DISTILL -> DELIVER`). Before delivering any response, extract new skills,
  skill updates, or procedure refinements and write them to the library.
  Triggers: user correction, novel problem solved, undocumented workaround,
  >3-iteration debugging, draft skill created mid-task, heartbeat
  retrospective, every request closure.
---

# Skill Distillation

> Source: `isaac-sim/IsaacSim/skills/skill-distillation/SKILL.md`

Step 5 of the universal request loop. Every user request ends with a distillation pass before delivery. Skip it and the library decays; the next session rediscovers the same lessons.

```
ORIENT -> PLAN -> EXECUTE -> VALIDATE -> DISTILL -> DELIVER
```

## When to run

Run automatically when any of these happen:

1. A task required > 3 iterations.
2. The user corrected you ("that's wrong", "you missed X", "it should be Y").
3. You discovered a workaround not in any existing skill.
4. A sub-agent hit a failure not covered by an existing skill.
5. You solved something that would break again next session without docs.

Also run during heartbeats (every 2-3 days): review recent `memory/` files for undistilled lessons.

## Loop

```
INTERACTION -> TRIGGER CHECK -> EXTRACT -> CLASSIFY -> WRITE -> VERIFY
```

### 1. Trigger check

Ask:
- Did I learn something not in any skill file?
- Did the user correct my approach?
- Did I waste time on something a future agent would also waste time on?
- Was there a procedure that worked but isn't documented?

Any yes -> extract.

### 2. Extract

| What happened | What to extract |
|---|---|
| Debugging session found root cause | Decision tree (symptom -> diagnosis -> fix) |
| User said "do it this way instead" | Procedure update or new rule |
| Tried 5 approaches, only 1 worked | Anti-patterns + the working pattern |
| Used a tool in a new way | New workflow or technique |
| Combined skills in a novel way | Integration pattern |
| Task required a specific order | Phase-gated procedure |

### 3. Classify

```
New knowledge
├── Fits existing skill        -> UPDATE that skill
│   ├── New rule               -> Key Rules
│   ├── New failure mode       -> Failure Modes
│   ├── New procedure          -> Key Workflows
│   └── Correction             -> fix in place
├── Cross-cutting pattern      -> UPDATE meta-skills
├── Entirely new capability    -> CREATE new skill (MSF Phase 1-3)
└── One-off fact               -> MEMORY.md, not skills
```

Rule: if the knowledge helps solve a different future problem, it belongs in a skill. If it's specific to this one situation, it belongs in memory.

### 4. Write

- Skill updates: edit the specific section; bump the Iteration Log.
- New skills: `skills/<name>/SKILL.md` from the meta-skilling template.
- Procedure changes: update the orchestrator or relevant workflow skill.
- Always: date and context ("Learned from SO-101 session 2026-04-08").

### 5. Verify

- Re-read the file. Does it stand on its own?
- Could a fresh agent follow it?
- Is the lesson a procedure, not a fact?

## The Generalization Rule

Always ask: *"What's the general principle behind this specific fix?"*

| Specific fix | Generalized skill |
|-------------|-------------------|
| Stripped RigidBodyAPI from table legs | Asset stability check procedure |
| Used file writes instead of print() | Headless debugging: stdout is unreliable |
| Added PhysxArticulationAPI.Apply() | Articulation setup checklist |
| Robot moved but didn't grasp | Visual validation must confirm task outcome, not just motion |
| User had to give detailed plan | Auto-decomposition: agent breaks down goals into phases |

## Code in Skills — Reference, Don't Embed

Skills should reference canonical sources rather than embed code directly. Embedded code becomes stale when the upstream library or API changes.

### Rule
- *If it comes from Isaac Sim examples or docs:* link to the doc page and/or local example file path. Describe the pattern in prose; let the agent read the actual file.
- *If it's a custom utility not in any upstream source:* put it in a versioned script file in the workspace (e.g., `isaac-sim/utils/grasp_utils.py`), reference it by path, and note the version it was written for.
- *If it's a tiny one-liner or config snippet:* embedding is acceptable, but add a comment with the Isaac Sim version it was validated against.

## Library-Health Check (Run During Distillation)

Distillation isn't only "add new knowledge." Each pass should also detect when an *existing* skill has grown stale, bloated, or duplicate.

| Cue | Action |
|---|---|
| Body > **500 lines** after your edit | Offload to sidecar |
| Description > **1024 chars** | Compress; move detail to the body |
| ≥ 50% of the file is fenced code blocks | Extract `≥ 20-line` blocks to `scripts/<name>.py` |
| 5+ dated sections (`## Learned 2026-MM-DD`) | Move them to a `lessons.md` sidecar |
| You're adding a new "Patch 2026-MM-DD" section | **Don't.** Edit the original section in place |

### Sidecar Offload (when SKILL.md is too long)

| What | Where |
|---|---|
| Reusable Python helpers (≥ 20 lines) | `scripts/<name>.py` |
| Long worked examples / case studies | `examples.md` |
| Lessons / dated discoveries / iteration notes | `lessons.md` |
| Deep API reference, parameter tables | `reference.md` or `<topic>.md` |
| Multi-step workflows that dominate the file | `workflow.md` |

## Cadence

| Trigger | Action |
|---------|--------|
| After every task with user feedback | Immediate distillation pass |
| After every task with >3 iterations | Immediate distillation pass |
| During heartbeat (every 2-3 days) | Review memory/ for undistilled lessons |
| After a PR is merged | Check if merged work revealed patterns worth capturing |
| User says "remember this" | Write to memory AND check if it's a skill-level lesson |
| New skill created mid-task (no prior skill existed) | Flag as HIGH PRIORITY |

## Draft Skills — High Priority Iteration

When a skill is created *during* a task (i.e., no existing skill covered the feature), it is by definition unproven. Treat it differently:

### Frontmatter Flag

```yaml
status: draft
priority: high
created_from: <task description>
```

### Behavior While Draft Skill Is Active

- Tell the user immediately: "I'm working with an untested skill for [feature] — I'll check in after each step."
- Shorten iteration cycles: share intermediate results, not just at delivery
- Ask early, not late: if anything is ambiguous, surface it before implementation
- Validate direction before depth: confirm the approach is right before building fully

### Promotion to Stable

After a draft skill has been used successfully on at least one task with user confirmation:
1. Remove `status: draft` and `priority: high` from frontmatter
2. Add `validated: <date>` and a note on what the validation task was
3. Run a full distillation pass to incorporate any corrections from the task
4. Update the orchestrator's feature→skill map if one exists

## Anti-patterns

- Waiting to be asked. If you learned it, write it now.
- Capturing facts instead of procedures. "X broke" is not a skill; "check X before running" is.
- Over-generalizing from a single data point unless the user confirmed the pattern.
- Under-generalizing: writing a per-asset fix when the pattern applies to all USD assets.
- Skipping verification. An unreadable update is worse than none.
- Duplicating across skills. One canonical location per procedure; cross-reference from others.
- Embedding code in skills. See Code in Skills section above.
