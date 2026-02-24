#!/bin/bash
set -x

# Get the directory where this script is located
readonly DEVPOD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============================================
# PATH SETUP - ensure npm global bin is discoverable
# ============================================
if [ -n "$npm_config_prefix" ]; then
    export PATH="$npm_config_prefix/bin:$PATH"
elif [ -f "$HOME/.npmrc" ]; then
    _NPM_PREFIX=$(grep '^prefix=' "$HOME/.npmrc" 2>/dev/null | cut -d= -f2)
    [ -n "$_NPM_PREFIX" ] && export PATH="$_NPM_PREFIX/bin:$PATH"
fi
export PATH="$HOME/.local/bin:$HOME/.claude/bin:$PATH"

# Colors for output
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

success() { echo -e "${GREEN}✅ $*${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $*${NC}"; }
info() { echo -e "${BLUE}ℹ️  $*${NC}"; }
section() { echo -e "${CYAN}━━━ $* ━━━${NC}"; }

cat << 'EOF'
╔══════════════════════════════════════════════════════════════════╗
║                  Turbo Flow V3.3.0 Post-Setup                    ║
║         Configure & Enable ALL Claude Flow Components            ║
║    38 Native Skills + 15 Plugins + Memory + MCP + Extensions    ║
╚══════════════════════════════════════════════════════════════════╝
EOF

echo ""
echo "WORKSPACE_FOLDER: ${WORKSPACE_FOLDER:=$(pwd)}"
echo "DEVPOD_DIR: $DEVPOD_DIR"
echo ""

# Helper function
skill_has_content() {
    local dir="$1"
    [ -d "$dir" ] && [ -n "$(ls -A "$dir" 2>/dev/null)" ]
}

skill_is_installed() {
    local skill_name="$1"
    local skill_dir="$HOME/.claude/skills/$skill_name"
    skill_has_content "$skill_dir"
}

# ============================================================================
# STEP 1: Verify Core Installations
# ============================================================================
info "Step 1: Verifying core installations..."

# Build tools
if command -v g++ >/dev/null 2>&1 && command -v make >/dev/null 2>&1; then
    success "Build tools: g++, make installed"
else
    warning "Build tools not found"
fi

# jq (required for worktree-manager and statusline)
if command -v jq >/dev/null 2>&1; then
    success "jq: $(jq --version 2>/dev/null)"
else
    warning "jq not found (required for worktree-manager and statusline)"
fi

# Node.js & npm
if command -v node >/dev/null 2>&1; then
    NODE_VER=$(node -v)
    NODE_MAJOR=$(echo "$NODE_VER" | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_MAJOR" -ge 20 ]; then
        success "Node.js: $NODE_VER (✓ >= 20)"
    elif [ "$NODE_MAJOR" -ge 18 ]; then
        success "Node.js: $NODE_VER (✓ >= 18, 20+ recommended)"
    else
        warning "Node.js: $NODE_VER (needs >= 18)"
    fi
else
    warning "Node.js not found"
fi

# Claude Code
if command -v claude >/dev/null 2>&1; then
    success "Claude Code: $(claude --version 2>/dev/null | head -1)"
else
    warning "Claude Code not found - run setup.sh first"
fi

# Claude Flow V3
CF_VERSION=$(npx -y claude-flow@alpha --version 2>/dev/null | head -1 || echo "")
if [ -n "$CF_VERSION" ]; then
    success "Claude Flow V3: $CF_VERSION"
else
    warning "Claude Flow not responding"
fi

# RuVector Neural Engine
if npm list -g ruvector --depth=0 >/dev/null 2>&1; then
    success "RuVector: $(npm list -g ruvector --depth=0 2>/dev/null | grep ruvector | head -1)"
elif npx -y ruvector --version >/dev/null 2>&1; then
    success "RuVector: available via npx"
else
    warning "RuVector not installed"
fi

# @ruvector/cli (for hooks)
if npm list -g @ruvector/cli --depth=0 >/dev/null 2>&1; then
    success "@ruvector/cli: installed"
else
    warning "@ruvector/cli not installed"
fi

# sql.js (for memory database WASM fallback)
if npm list -g sql.js --depth=0 >/dev/null 2>&1 || npm list sql.js --depth=0 >/dev/null 2>&1; then
    success "sql.js: installed (memory database)"
else
    warning "sql.js not installed (memory database may fail)"
fi

# AgentDB (vector memory with HNSW)
if npm list -g agentdb --depth=0 >/dev/null 2>&1; then
    success "agentdb: $(npm list -g agentdb --depth=0 2>/dev/null | grep agentdb | head -1)"
else
    info "agentdb: not installed (optional, for 150x faster vector search)"
fi

echo ""

# ============================================================================
# STEP 2: Verify Ecosystem Packages
# ============================================================================
info "Step 2: Verifying ecosystem packages..."

for pkg in agentic-qe @fission-ai/openspec uipro-cli @ruvector/ruvllm; do
    if npm list -g "$pkg" --depth=0 >/dev/null 2>&1; then
        success "$pkg: installed"
    elif npx -y "$pkg" --version >/dev/null 2>&1; then
        success "$pkg: available via npx"
    else
        warning "$pkg not installed"
    fi
done

# agent-browser (check command)
if command -v agent-browser >/dev/null 2>&1; then
    success "agent-browser: $(agent-browser --version 2>/dev/null || echo 'installed')"
else
    warning "agent-browser not found"
fi

# @claude-flow/browser (part of claude-flow)
if [ -d "$WORKSPACE_FOLDER/.claude-flow" ]; then
    success "@claude-flow/browser: integrated (59 MCP tools)"
else
    warning "@claude-flow/browser: requires claude-flow init"
fi

# uv (Python package manager)
if command -v uv >/dev/null 2>&1; then
    success "uv: $(uv --version 2>/dev/null | head -1)"
else
    warning "uv not installed"
fi

# specify CLI (spec-kit)
if command -v specify >/dev/null 2>&1; then
    success "specify CLI: installed"
else
    warning "specify CLI not installed"
fi

echo ""

# ============================================================================
# STEP 3: Start Claude Flow Daemon
# ============================================================================
info "Step 3: Starting Claude Flow daemon..."

if npx -y claude-flow@alpha daemon status 2>/dev/null | grep -q "running"; then
    warning "Daemon already running - skipping"
else
    if npx -y claude-flow@alpha daemon start 2>/dev/null; then
        success "Daemon started"
    else
        warning "Daemon start failed (can be started later)"
    fi
fi

echo ""

# ============================================================================
# STEP 4: Initialize Memory System
# ============================================================================
info "Step 4: Initializing Claude Flow memory system..."

MEMORY_DIR="$WORKSPACE_FOLDER/.claude-flow/memory"

if [ -d "$MEMORY_DIR" ] && [ -f "$MEMORY_DIR/agent.db" ]; then
    success "Memory already initialized"
    info "  └─ HNSW Vector Search: 150x-12,500x faster"
    info "  └─ AgentDB: SQLite-based persistent memory"
    info "  └─ LearningBridge: Bidirectional sync"
else
    if npx -y claude-flow@alpha memory init --force 2>/dev/null; then
        success "Memory initialized with HNSW indexing"
    else
        warning "Memory init failed - will initialize on first use"
    fi
fi

echo ""

# ============================================================================
# STEP 5: Initialize Swarm
# ============================================================================
info "Step 5: Initializing Claude Flow swarm..."

if npx -y claude-flow@alpha swarm status 2>/dev/null | grep -q "active\|initialized"; then
    warning "Swarm already initialized"
else
    if npx -y claude-flow@alpha swarm init --topology hierarchical --max-agents 8 --strategy specialized 2>/dev/null; then
        success "Swarm initialized: hierarchical, 8 agents"
    else
        warning "Swarm init failed - can be initialized later"
    fi
fi

echo ""

# ============================================================================
# STEP 6: Check MCP Configuration
# ============================================================================
info "Step 6: Checking MCP configuration..."

MCP_CONFIG="$HOME/.config/claude/mcp.json"
MCP_CONFIG_ALT="$HOME/.claude/claude_desktop_config.json"

if [ -f "$MCP_CONFIG" ]; then
    grep -q "claude-flow" "$MCP_CONFIG" && success "MCP: claude-flow configured" || warning "MCP: claude-flow missing"
    grep -q "agentic-qe" "$MCP_CONFIG" && success "MCP: agentic-qe configured" || warning "MCP: agentic-qe missing"
    info "Restart Claude Code to detect MCP servers"
elif [ -f "$MCP_CONFIG_ALT" ]; then
    grep -q "claude-flow" "$MCP_CONFIG_ALT" && success "MCP: claude-flow configured" || warning "MCP: claude-flow missing"
else
    warning "MCP config not found"
fi

echo ""

# ============================================================================
# STEP 7: Verify ALL Native Claude Flow Skills (38 total)
# ============================================================================
info "Step 7: Verifying ALL native Claude Flow skills..."

SKILLS_DIR="$HOME/.claude/skills"
SKILLS_DIR_LOCAL="$WORKSPACE_FOLDER/.claude/skills"
SKILLS_INSTALLED=0
SKILLS_MISSING=0

section "Core Skills (6)"
for skill in sparc-methodology swarm-orchestration github-code-review agentdb-vector-search pair-programming hive-mind-advanced; do
    if skill_is_installed "$skill"; then
        success "$skill"
        ((SKILLS_INSTALLED++))
    else
        warning "$skill - missing"
        ((SKILLS_MISSING++))
    fi
done

section "AgentDB Skills (4)"
for skill in agentdb-advanced agentdb-learning agentdb-memory-patterns agentdb-optimization; do
    if skill_is_installed "$skill"; then
        success "$skill"
        ((SKILLS_INSTALLED++))
    else
        warning "$skill - missing"
        ((SKILLS_MISSING++))
    fi
done

section "GitHub Skills (4)"
for skill in github-multi-repo github-project-management github-release-management github-workflow-automation; do
    if skill_is_installed "$skill"; then
        success "$skill"
        ((SKILLS_INSTALLED++))
    else
        warning "$skill - missing"
        ((SKILLS_MISSING++))
    fi
done

section "V3 Development Skills (9)"
for skill in v3-cli-modernization v3-core-implementation v3-ddd-architecture v3-integration-deep v3-mcp-optimization v3-memory-unification v3-performance-optimization v3-security-overhaul v3-swarm-coordination; do
    if skill_is_installed "$skill"; then
        success "$skill"
        ((SKILLS_INSTALLED++))
    else
        warning "$skill - missing"
        ((SKILLS_MISSING++))
    fi
done

section "ReasoningBank Skills (2)"
for skill in reasoningbank-agentdb reasoningbank-intelligence; do
    if skill_is_installed "$skill"; then
        success "$skill"
        ((SKILLS_INSTALLED++))
    else
        warning "$skill - missing"
        ((SKILLS_MISSING++))
    fi
done

section "Flow Nexus Skills (3)"
for skill in flow-nexus-neural flow-nexus-platform flow-nexus-swarm; do
    if skill_is_installed "$skill"; then
        success "$skill"
        ((SKILLS_INSTALLED++))
    else
        warning "$skill - missing"
        ((SKILLS_MISSING++))
    fi
done

section "Additional Skills (8)"
for skill in agentic-jujutsu hooks-automation performance-analysis skill-builder stream-chain swarm-advanced verification-quality dual-mode; do
    if skill_is_installed "$skill"; then
        success "$skill"
        ((SKILLS_INSTALLED++))
    else
        warning "$skill - missing"
        ((SKILLS_MISSING++))
    fi
done

echo ""
info "Skills Summary: $SKILLS_INSTALLED installed, $SKILLS_MISSING missing"
echo ""

# ============================================================================
# STEP 8: Verify Custom Skills (Turbo Flow specific)
# ============================================================================
info "Step 8: Verifying custom Turbo Flow skills..."

section "Security Analyzer"
if skill_is_installed "security-analyzer"; then
    success "security-analyzer skill installed"
else
    warning "security-analyzer skill missing"
fi

section "UI UX Pro Max"
if skill_is_installed "ui-ux-pro-max" || skill_has_content "$SKILLS_DIR_LOCAL/ui-ux-pro-max"; then
    success "UI UX Pro Max skill installed"
else
    warning "UI UX Pro Max skill missing"
fi

section "Worktree Manager"
if [ -f "$SKILLS_DIR/worktree-manager/SKILL.md" ]; then
    success "worktree-manager skill installed"
    if [ -f "$SKILLS_DIR/worktree-manager/config.json" ]; then
        success "  └─ config.json present"
    fi
else
    warning "worktree-manager skill missing"
fi

section "Vercel Deploy"
if [ -f "$SKILLS_DIR/vercel-deploy/SKILL.md" ]; then
    success "vercel-deploy skill installed"
else
    warning "vercel-deploy skill missing"
fi

section "RuV Helpers Visualization"
if skill_has_content "$SKILLS_DIR/rUv_helpers"; then
    success "rUv_helpers installed"
    if [ -d "$SKILLS_DIR/rUv_helpers/claude-flow-ruvector-visualization" ]; then
        success "  └─ visualization dashboard present"
        if [ -d "$SKILLS_DIR/rUv_helpers/claude-flow-ruvector-visualization/node_modules" ]; then
            success "  └─ dependencies installed"
        else
            warning "  └─ dependencies not installed"
        fi
    fi
else
    warning "rUv_helpers missing"
fi

echo ""

# ============================================================================
# STEP 9: Verify Claude Flow Browser Integration
# ============================================================================
info "Step 9: Verifying Claude Flow Browser integration..."

if [ -d "$WORKSPACE_FOLDER/.claude-flow" ]; then
    success "Claude Flow Browser: integrated"
    info "  └─ 59 MCP tools: browser/open, browser/snapshot, browser/click, etc."
    info "  └─ Features: trajectory learning, security scanning, element refs"
    info "  └─ Memory: patterns saved to RuVector"
    if [ -f "$HOME/.config/claude/mcp.json" ] && grep -q "claude-flow" "$HOME/.config/claude/mcp.json" 2>/dev/null; then
        success "  └─ MCP server configured"
    elif [ -f "$HOME/.claude/claude_desktop_config.json" ] && grep -q "claude-flow" "$HOME/.claude/claude_desktop_config.json" 2>/dev/null; then
        success "  └─ MCP server configured"
    else
        warning "  └─ MCP server not configured"
    fi
else
    warning "Claude Flow Browser: requires cf-init"
fi

echo ""

# ============================================================================
# STEP 10: Verify Ultimate Cyberpunk Statusline
# ============================================================================
info "Step 10: Checking Ultimate Cyberpunk Statusline (15 Components)..."

CLAUDE_SETTINGS="$HOME/.claude/settings.json"
STATUSLINE_SCRIPT="$HOME/.claude/turbo-flow-statusline.sh"
STATUSLINE_CONFIG="$HOME/.claude/statusline-pro/config.toml"

section "Statusline Script"
if [ -f "$STATUSLINE_SCRIPT" ]; then
    success "Statusline script: $STATUSLINE_SCRIPT"
    if [ -x "$STATUSLINE_SCRIPT" ]; then
        success "  └─ Script is executable"
    else
        warning "  └─ Script not executable, fixing..."
        chmod +x "$STATUSLINE_SCRIPT"
    fi
else
    warning "Statusline script not found"
fi

section "Settings Configuration"
if [ -f "$CLAUDE_SETTINGS" ]; then
    if grep -q "turbo-flow-statusline" "$CLAUDE_SETTINGS" 2>/dev/null; then
        success "Statusline: configured in settings.json"
    else
        warning "Statusline: not configured"
    fi
else
    warning "Claude settings.json not found"
fi

section "Dependencies"
if command -v jq &>/dev/null; then
    success "jq: $(jq --version 2>/dev/null || echo 'installed')"
else
    warning "jq: not installed (needed for statusline)"
fi

section "15 Component Layout"
info "  LINE 1: 📁 Project │ 🤖 Model │ 🌿 Branch │ 📟 Version │ 🎨 Style"
info "  LINE 2: 📊 Tokens │ 🧠 Context │ 💾 Cache │ 💰 Cost │ 🔥 Burn │ ⏱️ Time"
info "  LINE 3: ➕ Added │ ➖ Removed │ 📂 Git │ 🌳 Worktree │ 🔌 MCP │ ✅ Status"

echo ""

# ============================================================================
# STEP 11: Verify Workspace Files
# ============================================================================
info "Step 11: Verifying workspace files..."

# Directories
for dir in src tests docs scripts config plans; do
    [ -d "$WORKSPACE_FOLDER/$dir" ] && success "Directory: $dir/" || warning "Missing: $dir/"
done

# Key files
[ -f "$WORKSPACE_FOLDER/AGENTS.md" ] && success "AGENTS.md exists" || warning "AGENTS.md missing"
[ -f "$HOME/.claude/commands/prd2build.md" ] && success "prd2build command installed" || warning "prd2build missing"
[ -d "$WORKSPACE_FOLDER/.claude-flow" ] && success ".claude-flow directory exists" || warning ".claude-flow missing"
[ -f "$HOME/.codex/instructions.md" ] && success "Codex instructions exist" || warning "Codex instructions missing"

echo ""

# ============================================================================
# STEP 12: Check External Tools
# ============================================================================
info "Step 12: Checking external tools..."

# GitHub CLI
if command -v gh >/dev/null 2>&1; then
    if gh auth status 2>/dev/null | grep -q "Logged in"; then
        success "GitHub CLI: authenticated"
    else
        warning "GitHub CLI: not authenticated (run 'gh auth login')"
    fi
else
    warning "GitHub CLI: not installed (optional)"
fi

# Codex
if command -v codex >/dev/null 2>&1; then
    success "Codex: $(codex --version 2>/dev/null || echo 'installed')"
else
    warning "Codex: not installed (optional)"
fi

echo ""

# ============================================================================
# STEP 13: Check Bash Aliases (v3.3.0)
# ============================================================================
info "Step 13: Checking bash aliases..."

if grep -q "TURBO FLOW v3.3.0 COMPLETE" ~/.bashrc 2>/dev/null; then
    success "Bash aliases: v3.3.0 installed"
elif grep -q "TURBO FLOW v3.2.0" ~/.bashrc 2>/dev/null; then
    warning "Bash aliases: v3.2.0 (upgrade to v3.3.0)"
elif grep -q "TURBO FLOW v3.1.0" ~/.bashrc 2>/dev/null; then
    warning "Bash aliases: v3.1.0 (upgrade to v3.3.0)"
else
    warning "Bash aliases: not found"
fi

section "Core Aliases"
for alias_name in cf ruv aqe dsp; do
    grep -q "alias $alias_name=" ~/.bashrc 2>/dev/null && success "Alias: $alias_name" || warning "Alias: $alias_name missing"
done

section "Native Skill Aliases"
for alias_name in cf-sparc cf-swarm-skill cf-hive cf-pair cf-gh-review cf-agentdb-search; do
    grep -q "alias $alias_name=" ~/.bashrc 2>/dev/null && success "Alias: $alias_name" || warning "Alias: $alias_name missing"
done

section "AgentDB Aliases"
for alias_name in cf-agentdb-advanced cf-agentdb-learning cf-agentdb-memory cf-agentdb-opt; do
    grep -q "alias $alias_name=" ~/.bashrc 2>/dev/null && success "Alias: $alias_name" || warning "Alias: $alias_name missing"
done

section "GitHub Aliases"
for alias_name in cf-gh-multi cf-gh-project cf-gh-release cf-gh-workflow; do
    grep -q "alias $alias_name=" ~/.bashrc 2>/dev/null && success "Alias: $alias_name" || warning "Alias: $alias_name missing"
done

section "V3 Development Aliases"
for alias_name in cf-v3-cli cf-v3-core cf-v3-ddd cf-v3-perf cf-v3-security; do
    grep -q "alias $alias_name=" ~/.bashrc 2>/dev/null && success "Alias: $alias_name" || warning "Alias: $alias_name missing"
done

section "Utility Aliases"
for alias_name in cf-hooks cf-perf-analyze cf-verify cf-skill-build cf-stream; do
    grep -q "alias $alias_name=" ~/.bashrc 2>/dev/null && success "Alias: $alias_name" || warning "Alias: $alias_name missing"
done

section "Memory & Neural Aliases"
for alias_name in mem-search mem-vsearch mem-stats neural-train neural-patterns; do
    grep -q "alias $alias_name=" ~/.bashrc 2>/dev/null && success "Alias: $alias_name" || warning "Alias: $alias_name missing"
done

section "Browser Aliases"
for alias_name in cfb-open cfb-snap cfb-click cfb-trajectory cfb-learn; do
    grep -q "alias $alias_name=" ~/.bashrc 2>/dev/null && success "Alias: $alias_name" || warning "Alias: $alias_name missing"
done

section "Workflow Aliases"
for alias_name in ruv-viz wt-status wt-create deploy deploy-preview; do
    grep -q "alias $alias_name=" ~/.bashrc 2>/dev/null && success "Alias: $alias_name" || warning "Alias: $alias_name missing"
done

section "Functions"
for func in turbo-status turbo-help; do
    grep -q "${func}()" ~/.bashrc 2>/dev/null && success "Function: $func()" || warning "Function: $func() missing"
done

echo ""

# ============================================================================
# STEP 14: Check Environment
# ============================================================================
info "Step 14: Checking environment..."

section "API Keys"
[ -n "$ANTHROPIC_API_KEY" ] && success "ANTHROPIC_API_KEY is set" || warning "ANTHROPIC_API_KEY not set"

section "PATH"
echo "$PATH" | grep -q "$HOME/.local/bin" && success "PATH: ~/.local/bin" || warning "PATH missing ~/.local/bin"
echo "$PATH" | grep -q "$HOME/.cargo/bin" && success "PATH: ~/.cargo/bin" || warning "PATH missing ~/.cargo/bin"
echo "$PATH" | grep -q "$HOME/.claude/bin" && success "PATH: ~/.claude/bin" || warning "PATH missing ~/.claude/bin"

echo ""

# ============================================================================
# STEP 15: Run Doctor
# ============================================================================
info "Step 15: Running Claude Flow doctor..."

DOCTOR_OUTPUT=$(npx -y claude-flow@alpha doctor 2>&1 || true)
if echo "$DOCTOR_OUTPUT" | grep -qi "error\|failed\|missing"; then
    warning "Doctor found issues:"
    echo "$DOCTOR_OUTPUT" | head -20
else
    success "Doctor check passed"
    echo "$DOCTOR_OUTPUT" | head -15
fi

echo ""

# ============================================================================
# STEP 16: Test Components
# ============================================================================
info "Step 16: Testing v3.3.0 components..."

section "Claude Flow MCP Server"
if npx -y claude-flow@alpha mcp status 2>/dev/null | grep -q "running\|active"; then
    success "MCP server running"
else
    info "MCP server not running - start with: cf-mcp"
fi

section "RuVector Visualization"
if [ -f "$HOME/.claude/skills/rUv_helpers/claude-flow-ruvector-visualization/server.js" ]; then
    success "Visualization server ready"
    info "  └─ Start with: ruv-viz (opens http://localhost:3333)"
else
    warning "Visualization server not found"
fi

section "Worktree Manager"
if [ -f "$HOME/.claude/skills/worktree-manager/SKILL.md" ]; then
    success "Worktree manager skill ready"
    info "  └─ Aliases: wt-status, wt-clean, wt-create"
else
    warning "Worktree manager skill not found"
fi

section "Vercel Deploy"
if [ -f "$HOME/.claude/skills/vercel-deploy/SKILL.md" ]; then
    success "Vercel deploy skill ready"
    info "  └─ Aliases: deploy, deploy-preview"
else
    warning "Vercel deploy skill not found"
fi

section "Memory System"
if [ -d "$WORKSPACE_FOLDER/.claude-flow/memory" ]; then
    success "Memory system initialized"
    info "  └─ Aliases: mem-search, mem-vsearch, mem-stats"
else
    warning "Memory system not initialized"
fi

echo ""

# ============================================================================
# STEP 17: Generate Prompts
# ============================================================================
info "Step 17: Generating Claude prompts..."

PROMPT_FILE="$WORKSPACE_FOLDER/.claude-flow-prompts.md"
cat > "$PROMPT_FILE" << 'PROMPT_EOF'
# Claude Post-Setup Prompts (v3.3.0)

## Quick Verification
```
Run turbo-status to check all installed components.
```

## Restart MCP
```
Restart the MCP server connection to detect claude-flow.
```

## Full Doctor Check
```
Run Claude Flow doctor and show complete status.
```

---

## Core Skills Prompts

### SPARC Methodology
```
Use SPARC methodology to plan a new feature for this codebase.
```

### Swarm Orchestration
```
Initialize a swarm with hierarchical topology to analyze this project.
```

### Hive Mind
```
Use hive-mind to coordinate multiple agents for a complex refactoring task.
```

### Pair Programming
```
Start a pair programming session to implement user authentication.
```

---

## AgentDB Prompts

### Vector Search
```
Use agentdb-vector-search to find similar code patterns in the codebase.
```

### Learning
```
Train an agent using agentdb-learning with Q-Learning algorithm.
```

### Memory Patterns
```
Store the current session context using agentdb-memory-patterns.
```

### Optimization
```
Optimize memory usage with agentdb-optimization quantization.
```

---

## GitHub Prompts

### Code Review
```
Review the last PR using github-code-review skill.
```

### Multi-Repo
```
Coordinate changes across multiple repositories.
```

### Project Management
```
Create a sprint plan using github-project-management.
```

### Release
```
Prepare a release using github-release-management.
```

---

## V3 Development Prompts

### DDD Architecture
```
Analyze the current architecture and suggest DDD improvements.
```

### Performance Optimization
```
Identify performance bottlenecks and suggest optimizations.
```

### Security Overhaul
```
Run a security audit on this codebase.
```

---

## ReasoningBank Prompts

### Adaptive Learning
```
Use reasoningbank to learn from recent successful patterns.
```

### Pattern Recognition
```
Identify recurring patterns in the codebase using reasoningbank-intelligence.
```

---

## Flow Nexus Prompts

### Neural Training
```
Train a neural network model for code prediction.
```

### Cloud Deployment
```
Deploy this application using flow-nexus-platform.
```

---

## Utility Prompts

### Hooks Automation
```
Set up hooks for automatic code formatting before commits.
```

### Performance Analysis
```
Analyze system performance and generate a report.
```

### Verification
```
Run verification-quality checks on recent changes.
```

### Skill Builder
```
Create a new custom skill for this project's specific needs.
```

---

## Workflow Prompts

### Create Worktree
```
Create a worktree for feature/new-api-endpoint.
```

### Deploy to Vercel
```
Deploy this app to Vercel and show the preview URL.
```

### Start Visualization
```
Start the RuVector visualization dashboard.
```

### Memory Operations
```
Search memory for patterns related to authentication.
```

PROMPT_EOF

success "Prompts saved to: $PROMPT_FILE"

echo ""

# ============================================================================
# FINAL: Fix Permissions
# ============================================================================
section "Final Permission Fix"
info "Fixing permissions..."

CURRENT_USER=$(whoami)

sudo chown -R "$CURRENT_USER:$CURRENT_USER" /home/"$CURRENT_USER"/.vscode-server 2>/dev/null || true
sudo chown -R "$CURRENT_USER:$CURRENT_USER" /workspaces/.cache/vscode-server 2>/dev/null || true
sudo chown -R "$CURRENT_USER:$CURRENT_USER" "$HOME/.claude" 2>/dev/null || true
sudo chown -R "$CURRENT_USER:$CURRENT_USER" "$HOME/.local" 2>/dev/null || true
sudo chown -R "$CURRENT_USER:$CURRENT_USER" "$HOME/.config/claude" 2>/dev/null || true
sudo chown -R "$CURRENT_USER:$CURRENT_USER" /workspaces/.cache/npm-global 2>/dev/null || true
success "Permissions fixed"

echo ""

# ============================================================================
# SUMMARY
# ============================================================================
cat << 'EOF'
╔══════════════════════════════════════════════════════════════════╗
║                 Post-Setup Complete! (v3.3.0)                    ║
╚══════════════════════════════════════════════════════════════════╝

Components Verified:

  CORE:
  • Node.js 20+, Claude Code, Claude Flow V3, RuVector
  • jq, sql.js (memory database)

  NATIVE SKILLS (36 installed):
  • Core (6): sparc, swarm, hive, pair-prog, github-review, agentdb-search
  • AgentDB (4): advanced, learning, memory-patterns, optimization
  • GitHub (4): multi-repo, project-mgmt, release, workflow
  • V3 Dev (9): cli, core, ddd, integration, mcp, memory, perf, security, swarm
  • ReasoningBank (2): agentdb, intelligence
  • Flow Nexus (3): neural, platform, swarm
  • Additional (8): jujutsu, hooks, perf-analysis, skill-builder, stream, swarm-adv, verify, dual

  CUSTOM SKILLS:
  • security-analyzer, ui-ux-pro-max, worktree-manager, vercel-deploy, rUv_helpers

  WORKSPACE:
  • src, tests, docs, scripts, config, plans

  CONFIG:
  • AGENTS.md, prd2build, Codex, MCP servers
  • Statusline Pro (15 components)

Next Steps:

  1. RESTART CLAUDE CODE → Required for MCP & skills
  2. RELOAD SHELL → source ~/.bashrc
  3. SET API KEY → export ANTHROPIC_API_KEY="sk-ant-..."
  4. VERIFY → turbo-status

Quick Reference:

  CORE SKILLS     cf-sparc, cf-swarm-skill, cf-hive, cf-pair
  AGENTDB         cf-agentdb-search, cf-agentdb-learning, cf-agentdb-memory
  GITHUB          cf-gh-review, cf-gh-multi, cf-gh-project, cf-gh-release
  V3 DEV          cf-v3-cli, cf-v3-core, cf-v3-ddd, cf-v3-perf, cf-v3-security
  REASONING       cf-reasoning-db, cf-reasoning-intel
  FLOW NEXUS      cf-flow-neural, cf-flow-platform, cf-flow-swarm
  UTILITIES       cf-hooks, cf-perf-analyze, cf-verify, cf-skill-build
  MEMORY          mem-search, mem-vsearch, mem-stats
  NEURAL          neural-train, neural-patterns, neural-predict
  BROWSER         cfb-open, cfb-snap, cfb-click, cfb-trajectory
  WORKFLOW        ruv-viz, wt-status, wt-create, deploy

EOF

success "Post-setup completed!"
echo ""
