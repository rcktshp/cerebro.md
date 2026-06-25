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

# Cursor (commands + skills — uses same SKILL.md format as Claude Code)
if [ -d "$HOME/.cursor" ]; then
    mkdir -p "$HOME/.cursor/commands"
    cp "$SCRIPT_DIR/src/cerebro.md" "$HOME/.cursor/commands/cerebro.md"
    mkdir -p "$HOME/.cursor/skills-cursor/cerebro"
    cp "$SCRIPT_DIR/src/cerebro-skill.md" "$HOME/.cursor/skills-cursor/cerebro/SKILL.md"
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

# Codex CLI (commands + skills — same SKILL.md format as Claude Code)
if [ -d "$HOME/.codex" ]; then
    mkdir -p "$HOME/.codex/prompts"
    cp "$SCRIPT_DIR/src/cerebro.md" "$HOME/.codex/prompts/cerebro.md"
    mkdir -p "$HOME/.codex/skills/cerebro"
    cp "$SCRIPT_DIR/src/cerebro-skill.md" "$HOME/.codex/skills/cerebro/SKILL.md"
    installed_platforms="$installed_platforms Codex-CLI"
fi

# Gemini CLI (commands are TOML; wrap the markdown safely and swap the arg placeholder)
# NOTE: ~/.gemini is shared with Google Antigravity, so detect the *standalone*
# Gemini CLI by its own top-level settings.json / GEMINI.md, not the dir alone.
if [ -f "$HOME/.gemini/settings.json" ] || [ -f "$HOME/.gemini/GEMINI.md" ]; then
    mkdir -p "$HOME/.gemini/commands"
    if command -v python3 >/dev/null 2>&1; then
        python3 - "$SCRIPT_DIR/src/cerebro.md" "$HOME/.gemini/commands/cerebro.toml" <<'PY'
import sys
src, dst = sys.argv[1], sys.argv[2]
md = open(src, encoding="utf-8").read().replace("$ARGUMENTS", "{{args}}")
# Escape for a TOML basic multiline string: double backslashes, escape quotes
# (so no literal """ can ever appear and close the string early).
esc = md.replace("\\", "\\\\").replace('"', '\\"')
with open(dst, "w", encoding="utf-8") as f:
    f.write('description = "Cerebro — personal AI memory & session manager"\n')
    f.write('prompt = """\n')
    f.write(esc)
    f.write('\n"""\n')
PY
        installed_platforms="$installed_platforms Gemini-CLI"
    else
        echo "  Skipping Gemini CLI: python3 is required to build its TOML command."
    fi
fi

# Google Antigravity (skills are plugin-packaged + model-activated; no plain-text
# memory file and no usable logging hooks, so it's commands-only/manual logging).
if [ -d "$HOME/.gemini/antigravity-cli" ] || [ -d "$HOME/.gemini/antigravity" ]; then
    AG_PLUGIN="$HOME/.gemini/config/plugins/cerebro"
    AG_SKILL="$AG_PLUGIN/skills/cerebro"
    mkdir -p "$AG_SKILL"
    cat > "$AG_PLUGIN/plugin.json" <<'JSON'
{
  "name": "cerebro",
  "version": "0.2.0",
  "description": "Cerebro — personal AI memory & session manager",
  "author": { "name": "Cerebro" },
  "license": "MIT",
  "keywords": ["memory", "sessions", "cerebro"]
}
JSON
    {
        printf -- '---\n'
        printf 'name: cerebro\n'
        printf 'description: "Cerebro — personal AI memory and session manager. ACTIVATE when the user types /cerebro or asks to start or end a session, capture notes, goals, blockers, pins, or manage their memory and activity history."\n'
        printf -- '---\n\n'
        cat "$SCRIPT_DIR/src/cerebro.md"
    } > "$AG_SKILL/SKILL.md"
    installed_platforms="$installed_platforms Antigravity"
fi

echo "Cerebro installed successfully!"
echo ""
echo "  Local config:  $CEREBRO_LOCAL/"
echo "  Hook scripts:  $CEREBRO_LOCAL/hooks/"
echo "  Platforms:    $installed_platforms"
echo ""
echo "Run /cerebro in your AI assistant to start onboarding."
