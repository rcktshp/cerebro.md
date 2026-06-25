#!/usr/bin/env bash
# Cerebro installer — copies core files to ~/.cerebro/ and platform command dirs.
# Run: curl -sL <repo-url>/install.sh | bash
# Or:  git clone <repo> && cd cerebro && bash install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CEREBRO_LOCAL="$HOME/.cerebro"

echo "Installing Cerebro..."
echo ""

# Create local directories
mkdir -p "$CEREBRO_LOCAL/hooks"
mkdir -p "$CEREBRO_LOCAL/session-map"

# Copy hook scripts
cp "$SCRIPT_DIR/src/hooks/log-prompt.py" "$CEREBRO_LOCAL/hooks/log-prompt.py"
cp "$SCRIPT_DIR/src/hooks/log-stop.py" "$CEREBRO_LOCAL/hooks/log-stop.py"
chmod +x "$CEREBRO_LOCAL/hooks/log-prompt.py"
chmod +x "$CEREBRO_LOCAL/hooks/log-stop.py"

# Copy platform defaults
cp "$SCRIPT_DIR/src/platform-defaults.json" "$CEREBRO_LOCAL/platform-defaults.json"

# Copy version
cp "$SCRIPT_DIR/VERSION" "$CEREBRO_LOCAL/VERSION"

# Detect and install into platforms
installed_platforms=""

# Claude Code
if [ -d "$HOME/.claude" ]; then
    mkdir -p "$HOME/.claude/commands"
    cp "$SCRIPT_DIR/src/cerebro.md" "$HOME/.claude/commands/cerebro.md"
    mkdir -p "$HOME/.claude/skills/cerebro"
    cp "$SCRIPT_DIR/src/cerebro-skill.md" "$HOME/.claude/skills/cerebro/SKILL.md"
    installed_platforms="$installed_platforms Claude-Code"
fi

# Cursor
if [ -d "$HOME/.cursor" ]; then
    mkdir -p "$HOME/.cursor/commands"
    cp "$SCRIPT_DIR/src/cerebro.md" "$HOME/.cursor/commands/cerebro.md"
    installed_platforms="$installed_platforms Cursor"
fi

# Windsurf
if [ -d "$HOME/.windsurf" ]; then
    mkdir -p "$HOME/.windsurf/commands"
    cp "$SCRIPT_DIR/src/cerebro.md" "$HOME/.windsurf/commands/cerebro.md"
    installed_platforms="$installed_platforms Windsurf"
fi

# Cline
if [ -d "$HOME/.cline" ]; then
    mkdir -p "$HOME/.cline/commands"
    cp "$SCRIPT_DIR/src/cerebro.md" "$HOME/.cline/commands/cerebro.md"
    installed_platforms="$installed_platforms Cline"
fi

echo "Cerebro installed successfully!"
echo ""
echo "  Local config:  $CEREBRO_LOCAL/"
echo "  Hook scripts:  $CEREBRO_LOCAL/hooks/"
echo "  Platforms:    $installed_platforms"
echo ""
echo "Run /cerebro in your AI assistant to start onboarding."
