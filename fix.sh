#!/bin/bash
# =============================================================================
# Turbo Flow v4 - Documentation and Script Fixes
# =============================================================================
# Run this script from the ROOT of the turbo-flow repository
#
# Fixes applied:
#   1. beads-cli → @beads/bd (correct npm package name)
#   2. Remove references to non-existent turbo-flow/v4 directory
#   3. Fix script paths: .devcontainer/* → devpods/*
#   4. Fix repository structure in README.md
#   5. Fix references in release_notes_4.0.0.md
#
# Usage:
#   cd /path/to/turbo-flow
#   bash /path/to/apply-turboflow-fixes.sh
# =============================================================================

set -e

echo "╔══════════════════════════════════════════════════╗"
echo "║     Turbo Flow v4 - Applying Fixes              ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

# Check we're in the right directory
if [ ! -f "devpods/setup.sh" ]; then
    echo "❌ ERROR: Run this script from the turbo-flow repository root"
    echo "   Expected to find: devpods/setup.sh"
    exit 1
fi

# Create backup directory
BACKUP_DIR="fixes-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo "📁 Creating backups in: $BACKUP_DIR"

# =============================================================================
# BACKUP FILES
# =============================================================================
echo ""
echo "━━━ Backing up files ━━━"

FILES_TO_FIX=(
    "devpods/setup.sh"
    "devpods/post-setup.sh"
    "README.md"
    "V4_Prompt_Guide"
    "V4_Quick_Reference_Guide.md"
    "V4_Turbo Flow v4 + Ruflo v3.5 — The Definitive Prompt & Workflow Guide.md"
    "release_notes_4.0.0.md"
)

for file in "${FILES_TO_FIX[@]}"; do
    if [ -f "$file" ]; then
        cp "$file" "$BACKUP_DIR/"
        echo "  ✓ Backed up: $file"
    else
        echo "  ⚠ File not found: $file"
    fi
done

# =============================================================================
# FIX 1: beads-cli → @beads/bd
# =============================================================================
echo ""
echo "━━━ Fix 1: Correcting Beads package name (beads-cli → @beads/bd) ━━━"

for file in "devpods/setup.sh" "devpods/post-setup.sh" "README.md"; do
    if [ -f "$file" ]; then
        if grep -q "beads-cli" "$file" 2>/dev/null; then
            sed -i 's/beads-cli/@beads\/bd/g' "$file"
            echo "  ✓ Fixed: $file"
        else
            echo "  ○ Already fixed: $file"
        fi
    fi
done

# =============================================================================
# FIX 2: Remove turbo-flow/v4 directory references
# =============================================================================
echo ""
echo "━━━ Fix 2: Removing non-existent v4 directory references ━━━"

for file in "${FILES_TO_FIX[@]}"; do
    if [ -f "$file" ]; then
        if grep -q "turbo-flow/v4" "$file" 2>/dev/null; then
            sed -i 's|turbo-flow/v4|turbo-flow|g' "$file"
            echo "  ✓ Fixed: $file"
        else
            echo "  ○ Already fixed: $file"
        fi
    fi
done

# =============================================================================
# FIX 3: Fix script paths (.devcontainer/* → devpods/*)
# =============================================================================
echo ""
echo "━━━ Fix 3: Correcting script paths ━━━"

# Fix .devcontainer/setup-turboflow-4.sh → devpods/setup.sh
for file in "${FILES_TO_FIX[@]}"; do
    if [ -f "$file" ]; then
        if grep -q "\.devcontainer/setup-turboflow-4\.sh" "$file" 2>/dev/null; then
            sed -i 's|\.devcontainer/setup-turboflow-4\.sh|devpods/setup.sh|g' "$file"
            echo "  ✓ Fixed .devcontainer/setup-turboflow-4.sh path: $file"
        else
            echo "  ○ Already fixed: $file"
        fi
    fi
done

# Fix .devcontainer/post-setup-turboflow-4.sh → devpods/post-setup.sh
for file in "${FILES_TO_FIX[@]}"; do
    if [ -f "$file" ]; then
        if grep -q "\.devcontainer/post-setup-turboflow-4\.sh" "$file" 2>/dev/null; then
            sed -i 's|\.devcontainer/post-setup-turboflow-4\.sh|devpods/post-setup.sh|g' "$file"
            echo "  ✓ Fixed .devcontainer/post-setup-turboflow-4.sh path: $file"
        else
            echo "  ○ Already fixed: $file"
        fi
    fi
done

# Fix standalone setup-turboflow-4.sh references
for file in "${FILES_TO_FIX[@]}"; do
    if [ -f "$file" ]; then
        if grep -q "setup-turboflow-4\.sh" "$file" 2>/dev/null; then
            # Replace backticks with proper naming
            sed -i 's|`setup-turboflow-4\.sh`|`devpods/setup.sh`|g' "$file"
            sed -i 's|setup-turboflow-4\.sh|devpods/setup.sh|g' "$file"
            echo "  ✓ Fixed setup-turboflow-4.sh reference: $file"
        else
            echo "  ○ Already fixed: $file"
        fi
    fi
done

# Fix standalone post-setup-turboflow-4.sh references
for file in "${FILES_TO_FIX[@]}"; do
    if [ -f "$file" ]; then
        if grep -q "post-setup-turboflow-4\.sh" "$file" 2>/dev/null; then
            sed -i 's|post-setup-turboflow-4\.sh|devpods/post-setup.sh|g' "$file"
            echo "  ✓ Fixed post-setup-turboflow-4.sh reference: $file"
        else
            echo "  ○ Already fixed: $file"
        fi
    fi
done

# Fix the specific typo in V4_Quick_Reference_Guide.md: "./. devcontainer" → proper path
if [ -f "V4_Quick_Reference_Guide.md" ]; then
    if grep -q "\./\. devcontainer" "V4_Quick_Reference_Guide.md" 2>/dev/null; then
        sed -i 's|\./\. devcontainer/setup-turboflow-4\.sh|./devpods/setup.sh|g' "V4_Quick_Reference_Guide.md"
        echo "  ✓ Fixed typo './. devcontainer' in V4_Quick_Reference_Guide.md"
    fi
fi

# Fix ./post-setup-turboflow-4.sh → ./devpods/post-setup.sh
for file in "${FILES_TO_FIX[@]}"; do
    if [ -f "$file" ]; then
        if grep -q "\./post-setup-turboflow-4\.sh" "$file" 2>/dev/null; then
            sed -i 's|\./post-setup-turboflow-4\.sh|./devpods/post-setup.sh|g' "$file"
            echo "  ✓ Fixed ./post-setup-turboflow-4.sh path: $file"
        fi
    fi
done

# =============================================================================
# FIX 4: Update README.md Repository Structure section
# =============================================================================
echo ""
echo "━━━ Fix 4: Updating README.md repository structure ━━━"

if [ -f "README.md" ]; then
    # Check if the old structure exists
    if grep -q "├── \.devcontainer/" README.md 2>/dev/null; then
        # Use a heredoc to replace the repository structure section
        cat > /tmp/repo_structure_fix.sed << 'SEDSCRIPT'
/^## Repository Structure$/,/^## /{
  /```$/,/^```$/c\
```\
turbo-flow/\
├── V3/                          ← archived v3.0-v3.4.1 (Claude Flow era)\
├── .claude/                     ← skills, agents, settings\
├── devpods/\
│   ├── setup.sh                 ← main setup script\
│   ├── post-setup.sh            ← post-setup verification\
│   └── context/                 ← devpod context files\
├── scripts/\
│   └── generate-claude-md.sh\
├── CLAUDE.md                    ← workspace context (active)\
└── README.md\
```
}
SEDSCRIPT
        sed -i -f /tmp/repo_structure_fix.sed README.md
        rm -f /tmp/repo_structure_fix.sed
        echo "  ✓ Fixed: README.md repository structure section"
    else
        echo "  ○ Already fixed or different format: README.md repository structure"
    fi
fi

# =============================================================================
# VERIFICATION
# =============================================================================
echo ""
echo "━━━ Verification ━━━"

ERRORS=0

# Check for any remaining beads-cli in core files
echo ""
echo "Checking for remaining 'beads-cli' references in core files:"
FOUND=""
for file in devpods/setup.sh devpods/post-setup.sh README.md; do
    if [ -f "$file" ]; then
        MATCH=$(grep -n "beads-cli" "$file" 2>/dev/null || true)
        if [ -n "$MATCH" ]; then
            echo "  ❌ Found in $file:"
            echo "$MATCH"
            FOUND="yes"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done
if [ -z "$FOUND" ]; then
    echo "  ✅ No 'beads-cli' found - all fixed!"
fi

# Check for any remaining turbo-flow/v4
echo ""
echo "Checking for remaining 'turbo-flow/v4' references:"
FOUND=""
for file in "${FILES_TO_FIX[@]}"; do
    if [ -f "$file" ]; then
        MATCH=$(grep -n "turbo-flow/v4" "$file" 2>/dev/null || true)
        if [ -n "$MATCH" ]; then
            echo "  ❌ Found in $file:"
            echo "$MATCH"
            FOUND="yes"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done
if [ -z "$FOUND" ]; then
    echo "  ✅ No 'turbo-flow/v4' found - all fixed!"
fi

# Check for any remaining setup-turboflow-4.sh
echo ""
echo "Checking for remaining 'setup-turboflow-4.sh' references:"
FOUND=""
for file in "${FILES_TO_FIX[@]}"; do
    if [ -f "$file" ]; then
        MATCH=$(grep -n "setup-turboflow-4\.sh" "$file" 2>/dev/null || true)
        if [ -n "$MATCH" ]; then
            echo "  ❌ Found in $file:"
            echo "$MATCH"
            FOUND="yes"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done
if [ -z "$FOUND" ]; then
    echo "  ✅ No 'setup-turboflow-4.sh' found - all fixed!"
fi

# Check for any remaining post-setup-turboflow-4.sh
echo ""
echo "Checking for remaining 'post-setup-turboflow-4.sh' references:"
FOUND=""
for file in "${FILES_TO_FIX[@]}"; do
    if [ -f "$file" ]; then
        MATCH=$(grep -n "post-setup-turboflow-4\.sh" "$file" 2>/dev/null || true)
        if [ -n "$MATCH" ]; then
            echo "  ❌ Found in $file:"
            echo "$MATCH"
            FOUND="yes"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done
if [ -z "$FOUND" ]; then
    echo "  ✅ No 'post-setup-turboflow-4.sh' found - all fixed!"
fi

# Verify bash syntax
echo ""
echo "Checking bash syntax:"
if bash -n devpods/setup.sh 2>/dev/null; then
    echo "  ✅ devpods/setup.sh syntax valid"
else
    echo "  ❌ devpods/setup.sh syntax error"
    ERRORS=$((ERRORS + 1))
fi

if bash -n devpods/post-setup.sh 2>/dev/null; then
    echo "  ✅ devpods/post-setup.sh syntax valid"
else
    echo "  ❌ devpods/post-setup.sh syntax error"
    ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# SUMMARY
# =============================================================================
echo ""
echo "╔══════════════════════════════════════════════════╗"
if [ $ERRORS -eq 0 ]; then
    echo "║           ✅ All Fixes Applied Successfully     ║"
else
    echo "║     ⚠️  Fixes Applied with $ERRORS Issue(s)               ║"
fi
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "Files modified:"
echo "  - devpods/setup.sh"
echo "  - devpods/post-setup.sh"
echo "  - README.md"
echo "  - V4_Prompt_Guide"
echo "  - V4_Quick_Reference_Guide.md"
echo "  - V4_Turbo Flow v4 + Ruflo v3.5 — The Definitive Prompt & Workflow Guide.md"
echo "  - release_notes_4.0.0.md"
echo ""
echo "Backups saved to: $BACKUP_DIR/"
echo ""
echo "To undo changes, run:"
echo "  cp $BACKUP_DIR/* ."
echo ""
if [ $ERRORS -gt 0 ]; then
    echo "⚠️  Some issues were found. Check the output above."
    exit 1
fi

