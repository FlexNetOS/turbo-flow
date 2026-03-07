# Turbo Flow v4.0 — Workflow Guide

## What's Installed

| Layer | Components |
|-------|------------|
| **Orchestration** | Claude Code, Ruflo v3.5 (swarm, MCP, skills, browser, daemon) |
| **Memory** | Beads (cross-session, git-native JSONL), Native Tasks (session), AgentDB v3 (learned patterns, RuVector WASM) |
| **Intelligence** | Ruflo hooks intelligence, neural operations, 3-tier model routing |
| **Codebase** | GitNexus knowledge graph, blast-radius detection, MCP server |
| **Plugins** | 6 plugins: Agentic QE, Code Intelligence, Test Intelligence, Perf Optimizer, Teammate, Gastown Bridge |
| **Skills** | UI UX Pro Max (design), 36+ Ruflo auto-activated skills (SPARC, swarm, DDD, etc.) |
| **Specs** | OpenSpec (spec-driven development) |
| **Isolation** | Git worktrees per agent, PG Vector schema namespacing |
| **Monitoring** | Statusline Pro v4.0, Ruflo built-in observability |

---

## Core Philosophy: ADR + DDD + Memory-First

TurboFlow v4.0 adds a memory-first discipline on top of the ADR + DDD methodology from v3.x.

- **Architecture decisions are documented and traceable** via ADRs
- **Code organization reflects business domains** via DDD bounded contexts
- **Project state persists across sessions** via Beads (issues, decisions, blockers)
- **Agents check blast radius before editing shared code** via GitNexus
- **Each parallel agent operates in isolation** via git worktrees

---

## Boot Sequence

This is the correct startup order. Each step depends on the one before it.

### Step 1 — Source Aliases

```bash
source ~/.bashrc
```

### Step 2 — Initialize Ruflo

This creates the workspace config and registers the MCP server.

```bash
rf-wizard
```

Use `rf-wizard` for guided setup, or `rf-init` for defaults.

### Step 3 — Verify Environment

```bash
rf-doctor
```

Fix any issues before proceeding.

### Step 4 — Check Project Memory

```bash
bd-ready
```

This loads Beads state: blockers, in-progress work, decisions from prior sessions.

### Step 5 — Index the Codebase

```bash
gnx-analyze
```

Builds the GitNexus knowledge graph for blast-radius detection.

### Step 6 — Activate Hooks Intelligence

```bash
hooks-train
```

Deep pretrain from the codebase — teaches Ruflo your project's patterns.

### Step 7 — Start the Daemon

```bash
rf-daemon
```

### Step 8 — Verify Everything

```bash
turbo-status
```

**You're now fully booted.**

---

## Boot Sequence (Quick Copy-Paste)

```bash
source ~/.bashrc
rf-wizard
rf-doctor
bd-ready
gnx-analyze
hooks-train
rf-daemon
turbo-status
```

---

## Three-Tier Memory System

| Tier | System | What it stores | How to use |
|------|--------|---------------|------------|
| **1. Project** | Beads (`bd-*`) | Issues, decisions, blockers, roadmap items | `bd-add`, `bd-ready`, `bd-list` |
| **2. Session** | Native Tasks | Current session checklist, active work | Managed by Claude Code |
| **3. Learned** | AgentDB (`ruv-*`, `mem-*`) | Patterns, routing weights, skills | `ruv-remember`, `ruv-recall`, `mem-search` |

### Decision Tree (from CLAUDE.md)

```
Is this about the project roadmap / blockers / dependencies / decisions?
  → Beads (bd-add)

Is this about what I'm doing right now in this session?
  → Native Tasks

Is this a learned pattern / routing weight / skill?
  → AgentDB (automatic via Ruflo)
```

### Session Protocol (MANDATORY)

**Start of session:**
1. `bd-ready` — check project state
2. Review Native Tasks from prior sessions
3. AgentDB loads automatically

**During work:**
- Project decisions → `bd add --type decision "description"`
- Discovered issues → `bd add --type issue "description"`
- Active tasks → Native Tasks

**End of session:**
- File blockers and decisions as Beads
- AgentDB persists automatically

---

## ADR + DDD Methodology

### Architecture Decision Records (ADR)

ADRs capture important architectural decisions along with their context and consequences.

**ADR Structure:**
```
docs/adr/
├── ADR-001-record-architecture-decisions.md
├── ADR-002-choose-database-technology.md
└── ...
```

**Creating an ADR:**

> "Create an ADR for adopting PostgreSQL as our primary database"

Store the decision in Beads:

```bash
bd add --type decision "ADR-002: PostgreSQL as primary database"
```

### Domain-Driven Design (DDD)

DDD organizes code around business domains with clear bounded contexts.

**DDD Structure:**
```
src/
├── domains/
│   ├── identity/           # User management bounded context
│   │   ├── application/    # Use cases, handlers
│   │   ├── domain/         # Entities, value objects
│   │   ├── infrastructure/ # Repositories, external services
│   │   └── interfaces/     # Controllers, DTOs
│   ├── ordering/           # Order management bounded context
│   └── shared/             # Shared kernel
```

---

## Agent Isolation with Worktrees

When running parallel agents, each one gets its own worktree.

### Creating Isolated Agents

```bash
# Create worktrees for 3 parallel agents
wt-add agent-1
wt-add agent-2
wt-add agent-3
```

Each `wt-add` call:
- Creates a git worktree at `.worktrees/<name>` with a timestamped branch
- Sets `DATABASE_SCHEMA` env var for PG Vector isolation
- Auto-indexes the worktree with GitNexus in the background

### Cleanup

```bash
wt-remove agent-1
wt-remove agent-2
wt-remove agent-3
wt-clean           # Prune any stale worktrees
```

### Check Active Worktrees

```bash
wt-list
```

---

## Codebase Intelligence with GitNexus

Before agents edit shared code, check the blast radius.

```bash
# Index the repo (run once, or after major changes)
gnx-analyze

# Force re-index
gnx-analyze-force

# Start web UI for visual exploration
gnx-serve

# Generate a wiki from the knowledge graph
gnx-wiki

# Check status
gnx-status
```

GitNexus runs as an MCP server — Claude Code agents get knowledge graph tools natively. This means agents can query dependencies, call chains, and execution flows before making changes.

---

## Ruflo Skills (Auto-Activated)

Ruflo v3.5 includes 36+ skills that auto-activate based on your task. You don't need to invoke them manually — Ruflo detects the task type and applies the right skill.

Key skills include: SPARC methodology, swarm orchestration, DDD architecture, performance optimization, security overhaul, memory unification, GitHub integration, ReasoningBank intelligence, and more.

These replace the old v3.x slash commands (`/sparc`, `/speckit.*`, etc.).

---

## Plugins (6)

| Plugin | MCP Tools | Purpose |
|--------|-----------|---------|
| **Agentic QE** | 16 | 58 QE agents — TDD, coverage, security scanning, chaos engineering |
| **Code Intelligence** | — | Code analysis, pattern detection, refactoring suggestions |
| **Test Intelligence** | — | Test generation, gap analysis, flaky test detection |
| **Perf Optimizer** | — | Performance profiling, bottleneck detection |
| **Teammate Plugin** | 21 | Bridges Native Agent Teams with Ruflo swarms, semantic routing |
| **Gastown Bridge** | 20 | WASM-accelerated orchestration, Beads sync, convoy management |

### Plugin Commands

```bash
# Quality Engineering
aqe-generate         # Generate tests
aqe-gate             # Quality gate

# List all plugins
rf-plugins
```

---

## Workflow 1: New Builds (ADR + DDD)

### 1. Boot

```bash
source ~/.bashrc
rf-doctor
bd-ready
gnx-analyze
```

### 2. Domain Discovery

> "Analyze these business requirements and identify potential bounded contexts"

Ruflo auto-activates DDD skills for domain modeling.

### 3. Architecture Decision Records

> "Create ADR-001 documenting our architecture decisions"

```bash
bd add --type decision "ADR-001: Modular monolith with DDD bounded contexts"
```

### 4. Domain Modeling

> "Design aggregates, entities, and value objects for the Identity bounded context"

### 5. Build with Swarm

```bash
rf-swarm
```

> "Spawn a hierarchical swarm with a system architect and implementers"

For parallel agents on different domains, use worktrees:

```bash
wt-add identity-agent
wt-add ordering-agent
```

### 6. Test & Quality

```bash
aqe-generate         # Generate tests
aqe-gate             # Quality gate
```

### 7. Spec-Driven Validation

```bash
os-init              # Initialize OpenSpec
os                   # Run spec validation
```

### 8. Document & Learn

```bash
bd add --type decision "Shipped Identity bounded context"
neural-patterns      # View what Ruflo learned
mem-stats            # Memory statistics
```

---

## Workflow 2: Continued Builds

### 1. Recover Context

```bash
bd-ready                    # What's the project state?
mem-search "domain-model"   # What does memory know?
gnx-status                  # Is the knowledge graph current?
```

### 2. Check Blast Radius

Before extending shared code, use GitNexus:

> "Check the blast radius of modifying the User aggregate"

### 3. Design the Extension

> "Design the Payment bounded context with aggregates and domain events"

```bash
bd add --type decision "ADR-003: Payment bounded context with Stripe integration"
```

### 4. Build with Isolation

```bash
wt-add payment-agent
rf-swarm
```

### 5. Test & Merge

```bash
aqe-generate
aqe-gate
wt-remove payment-agent
```

---

## Workflow 3: Refactor Builds

### 1. Baseline

```bash
bd-ready                  # Load project state
gnx-analyze-force         # Re-index for current state
```

> "Recall all ADRs and the current domain model"

> "Generate characterization tests for the existing codebase"

### 2. Plan the Evolution

> "Create ADR for migrating to modular monolith with DDD"

```bash
bd add --type decision "ADR-004: Migrate from monolith to modular monolith"
```

### 3. Execute with Isolation

Create a worktree for the refactoring agent:

```bash
wt-add refactor-agent
```

> "Use DDD patterns to refactor the monolith into bounded contexts"

### 4. Validate

> "Run characterization tests against refactored code"

```bash
aqe-gate
wt-remove refactor-agent
```

---

## Tool Reference

### Swarm Topologies

| Topology | Command | When to use |
|----------|---------|-------------|
| Hierarchical | `rf-swarm` | Domain implementation (default, 8 agents max) |
| Mesh | `rf-mesh` | Refactoring, parallel work |
| Ring | `rf-ring` | Sequential pipeline tasks |
| Star | `rf-star` | Hub-and-spoke coordination |

### Memory Operations

**Beads (cross-session project memory):**

| Command | What it does |
|---------|-------------|
| `bd-ready` | Check project state (run at session start) |
| `bd-add` | Record issue/decision/blocker |
| `bd-list` | List all beads |
| `bd-status` | Beads system status |

**AgentDB / RuVector (via Ruflo):**

| Command | What it does |
|---------|-------------|
| `ruv-remember "key" "value"` | Store in AgentDB |
| `ruv-recall "query"` | Query AgentDB |
| `ruv-stats` | AgentDB statistics |
| `mem-search "query"` | Search Ruflo memory |
| `mem-store "key" "value"` | Store in Ruflo memory |
| `mem-stats` | Memory statistics |

### Intelligence Operations

| Command | What it does |
|---------|-------------|
| `hooks-train` | Deep pretrain on codebase |
| `hooks-route` | Route task to optimal agent |
| `hooks-pre` | Pre-edit hook |
| `hooks-post` | Post-edit hook |
| `neural-train` | Train neural patterns |
| `neural-status` | Neural system status |
| `neural-patterns` | View learned patterns |

### GitNexus (Codebase Intelligence)

| Command | What it does |
|---------|-------------|
| `gnx-analyze` | Index repo into knowledge graph |
| `gnx-analyze-force` | Force re-index |
| `gnx-serve` | Start web UI |
| `gnx-wiki` | Generate wiki from graph |
| `gnx-status` | Knowledge graph status |
| `gnx-mcp` | Start MCP server manually |

### Worktree Isolation

| Command | What it does |
|---------|-------------|
| `wt-add <name>` | Create worktree + branch + PG Vector schema + GitNexus index |
| `wt-remove <name>` | Remove worktree |
| `wt-list` | List active worktrees |
| `wt-clean` | Prune stale worktrees |

### Specs

| Command | What it does |
|---------|-------------|
| `os-init` | Initialize OpenSpec in project |
| `os` | Run OpenSpec |

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Commands not found | `source ~/.bashrc` |
| MCP servers not connected | `claude mcp list` — re-register with `claude mcp add ruflo -- npx -y ruflo@latest` |
| Old `cf-*` commands not working | Replaced by `rf-*` in v4.0 |
| Beads not initialized | `bd init` (requires git repo) |
| GitNexus not indexed | `gnx-analyze` from repo root |
| Ruflo not responding | `npx ruflo@latest init` then `rf-doctor` |
| Plugins not found | `rf-plugins` to check, reinstall with `npx ruflo@latest plugins install -n <name>` |
| Worktree conflicts | `wt-clean` to prune stale worktrees |
| Memory empty after restart | Beads persists in git — run `bd-ready`. AgentDB persists automatically. |
| Stale v3.x aliases in .bashrc | Setup script auto-cleans, or manually remove `# === TURBO FLOW` blocks |

---

## Quick Reference

```
BOOT:       source ~/.bashrc → rf-wizard → rf-doctor → bd-ready → gnx-analyze → hooks-train → rf-daemon
DISCOVER:   DDD skills auto-activate → identify bounded contexts
DECIDE:     create ADRs → bd add --type decision
MODEL:      aggregates → entities → value objects
ISOLATE:    wt-add agent-N → work in worktree → wt-remove agent-N
BUILD:      rf-swarm → agents work in parallel on worktrees
TEST:       aqe-generate → aqe-gate
SPEC:       os-init → os
LEARN:      ruv-remember → neural-train → neural-patterns
MONITOR:    turbo-status → rf-doctor → bd-ready
```

---

## Component Summary

| Category | Count | Notes |
|----------|-------|-------|
| Ruflo Auto-Activated Skills | 36+ | Built-in, replace slash commands |
| Ruflo Plugins | 6 | QE, Code Intel, Test Intel, Perf, Teammate, Gastown |
| Custom Skills | 1 | UI UX Pro Max |
| Independent Tools | 2 | OpenSpec, GitNexus |
| Memory Systems | 3 | Beads, Native Tasks, AgentDB |
| **Total Components** | **23** | Complete agentic development environment |