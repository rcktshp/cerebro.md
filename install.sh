#!/usr/bin/env bash
# Cerebro installer — copies core files to ~/.cerebro/ and platform command dirs.
# Run: curl -sL <repo-url>/install.sh | bash
# Or:  git clone <repo> && cd cerebro && bash install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CEREBRO_LOCAL="$HOME/.cerebro"
CEREBRO_CMD="$SCRIPT_DIR/src/cerebro.md"

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

# Copy MCP server
cp "$SCRIPT_DIR/src/cerebro-mcp.py" "$CEREBRO_LOCAL/cerebro-mcp.py"
chmod +x "$CEREBRO_LOCAL/cerebro-mcp.py"

# ---------------------------------------------------------------------------
# Resolve cerebro_home and kb_root — read from existing config if present,
# else fall back to sensible defaults. Used to personalise the skill file.
# ---------------------------------------------------------------------------
if [ -f "$CEREBRO_LOCAL/config.json" ] && command -v python3 >/dev/null 2>&1; then
    CEREBRO_HOME_RESOLVED="$(python3 -c "
import json, os
cfg = json.load(open('$CEREBRO_LOCAL/config.json'))
print(os.path.expanduser(cfg.get('cerebro_home', '~/Cerebro')))
" 2>/dev/null || echo "$HOME/Cerebro")"
    KB_ROOT_RESOLVED="$(python3 -c "
import json, os
cfg = json.load(open('$CEREBRO_LOCAL/config.json'))
print(os.path.expanduser(cfg.get('knowledge_base_root', os.path.join(os.path.expanduser('~'), 'Cerebro', 'knowledge'))))
" 2>/dev/null || echo "$HOME/Cerebro/knowledge")"
else
    CEREBRO_HOME_RESOLVED="$HOME/Cerebro"
    KB_ROOT_RESOLVED="$HOME/Cerebro/knowledge"
fi

# Generate a personalised skill file with the user's real paths substituted in.
# The source file uses {{CEREBRO_HOME}} and {{KB_ROOT}} as tokens.
SKILL_TMP="$(mktemp)"
sed \
    -e "s|{{CEREBRO_HOME}}|$CEREBRO_HOME_RESOLVED|g" \
    -e "s|{{KB_ROOT}}|$KB_ROOT_RESOLVED|g" \
    "$SCRIPT_DIR/src/cerebro-skill.md" > "$SKILL_TMP"

# Helper: copy the personalised skill to a platform's skill directory
install_skill() {
    local dest_dir="$1"
    mkdir -p "$dest_dir"
    cp "$SKILL_TMP" "$dest_dir/SKILL.md"
}

# ---------------------------------------------------------------------------
# Detect and install into platforms
# ---------------------------------------------------------------------------
installed_platforms=""

# Claude Code
if [ -d "$HOME/.claude" ]; then
    mkdir -p "$HOME/.claude/commands"
    cp "$CEREBRO_CMD" "$HOME/.claude/commands/cerebro.md"
    install_skill "$HOME/.claude/skills/cerebro"
    installed_platforms="$installed_platforms Claude-Code"
fi

# Cursor (commands + skills — uses same SKILL.md format as Claude Code)
if [ -d "$HOME/.cursor" ]; then
    mkdir -p "$HOME/.cursor/commands"
    cp "$CEREBRO_CMD" "$HOME/.cursor/commands/cerebro.md"
    install_skill "$HOME/.cursor/skills-cursor/cerebro"
    installed_platforms="$installed_platforms Cursor"
fi

# Windsurf
if [ -d "$HOME/.windsurf" ]; then
    mkdir -p "$HOME/.windsurf/commands"
    cp "$CEREBRO_CMD" "$HOME/.windsurf/commands/cerebro.md"
    installed_platforms="$installed_platforms Windsurf"
fi

# Cline
if [ -d "$HOME/.cline" ]; then
    mkdir -p "$HOME/.cline/commands"
    cp "$CEREBRO_CMD" "$HOME/.cline/commands/cerebro.md"
    installed_platforms="$installed_platforms Cline"
fi

# Codex CLI (commands + skills — same SKILL.md format as Claude Code)
if [ -d "$HOME/.codex" ]; then
    mkdir -p "$HOME/.codex/prompts"
    cp "$CEREBRO_CMD" "$HOME/.codex/prompts/cerebro.md"
    install_skill "$HOME/.codex/skills/cerebro"
    installed_platforms="$installed_platforms Codex-CLI"
fi

# Gemini CLI (commands are TOML; wrap the markdown safely and swap the arg placeholder)
# NOTE: ~/.gemini is shared with Google Antigravity, so detect the *standalone*
# Gemini CLI by its own top-level settings.json / GEMINI.md, not the dir alone.
if [ -f "$HOME/.gemini/settings.json" ] || [ -f "$HOME/.gemini/GEMINI.md" ]; then
    mkdir -p "$HOME/.gemini/commands"
    if command -v python3 >/dev/null 2>&1; then
        python3 - "$CEREBRO_CMD" "$HOME/.gemini/commands/cerebro.toml" <<'PY'
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
        cat "$CEREBRO_CMD"
    } > "$AG_SKILL/SKILL.md"
    installed_platforms="$installed_platforms Antigravity"
fi

# Clean up temp file
rm -f "$SKILL_TMP"

# ---------------------------------------------------------------------------
# MCP server registration — give every MCP-capable platform Cerebro access
#
# Format cheat-sheet:
#   Claude Desktop / Cursor / Antigravity  →  JSON  {"mcpServers": {...}}
#   VS Code / Windsurf / Cline             →  JSON  {"servers": {"type":"stdio",...}}
#   Codex CLI                              →  TOML  [mcp_servers.cerebro]
# ---------------------------------------------------------------------------

MCP_SCRIPT="$CEREBRO_LOCAL/cerebro-mcp.py"

if command -v python3 >/dev/null 2>&1; then

# Helper — merge into a JSON file that uses the {"mcpServers": {...}} schema
# (Claude Desktop, Cursor, Antigravity)
register_mcp_mcpservers() {
    local config_path="$1"
    mkdir -p "$(dirname "$config_path")"
    python3 - "$config_path" "$MCP_SCRIPT" <<'PY'
import json, sys, os
config_path, mcp_script = sys.argv[1], sys.argv[2]
cfg = {}
if os.path.exists(config_path):
    try:
        cfg = json.loads(open(config_path).read())
    except Exception:
        pass
cfg.setdefault("mcpServers", {})
cfg["mcpServers"]["cerebro"] = {"command": "python3", "args": [mcp_script]}
with open(config_path, "w") as f:
    json.dump(cfg, f, indent=2)
PY
}

# Helper — merge into a JSON file that uses the {"servers": {...}} schema
# (VS Code, Windsurf, Cline)
register_mcp_servers() {
    local config_path="$1"
    mkdir -p "$(dirname "$config_path")"
    python3 - "$config_path" "$MCP_SCRIPT" <<'PY'
import json, sys, os
config_path, mcp_script = sys.argv[1], sys.argv[2]
cfg = {}
if os.path.exists(config_path):
    try:
        cfg = json.loads(open(config_path).read())
    except Exception:
        pass
cfg.setdefault("servers", {})
cfg["servers"]["cerebro"] = {"type": "stdio", "command": "python3", "args": [mcp_script]}
with open(config_path, "w") as f:
    json.dump(cfg, f, indent=2)
PY
}

# Helper — append/update [mcp_servers.cerebro] in a TOML file (Codex CLI)
register_mcp_toml() {
    local config_path="$1"
    python3 - "$config_path" "$MCP_SCRIPT" <<'PY'
import sys, os, re
config_path, mcp_script = sys.argv[1], sys.argv[2]
block = f'\n[mcp_servers.cerebro]\ncommand = "python3"\nargs = ["{mcp_script}"]\n'
if os.path.exists(config_path):
    content = open(config_path).read()
    # Replace existing block if present
    if "[mcp_servers.cerebro]" in content:
        content = re.sub(
            r'\[mcp_servers\.cerebro\][^\[]*',
            block.lstrip(),
            content
        )
    else:
        content += block
else:
    content = block.lstrip()
with open(config_path, "w") as f:
    f.write(content)
PY
}

# --- Claude Desktop ---
if [ "$(uname)" = "Darwin" ]; then
    CLAUDE_CFG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
elif [ "$(uname)" = "Linux" ]; then
    CLAUDE_CFG="$HOME/.config/Claude/claude_desktop_config.json"
else
    CLAUDE_CFG=""
fi
if [ -n "$CLAUDE_CFG" ]; then
    register_mcp_mcpservers "$CLAUDE_CFG"
    installed_platforms="$installed_platforms Claude-Desktop(MCP)"
fi

# --- Cursor ---
if [ -d "$HOME/.cursor" ]; then
    register_mcp_mcpservers "$HOME/.cursor/mcp.json"
    installed_platforms="$installed_platforms Cursor(MCP)"
fi

# --- Google Antigravity ---
if [ -d "$HOME/.gemini/antigravity" ]; then
    register_mcp_mcpservers "$HOME/.gemini/antigravity/mcp_config.json"
    installed_platforms="$installed_platforms Antigravity(MCP)"
fi

# --- VS Code / Windsurf / Cline (shared global MCP config) ---
if [ "$(uname)" = "Darwin" ]; then
    VSCODE_MCP="$HOME/Library/Application Support/Code/User/mcp.json"
elif [ "$(uname)" = "Linux" ]; then
    VSCODE_MCP="$HOME/.config/Code/User/mcp.json"
else
    VSCODE_MCP=""
fi
if [ -n "$VSCODE_MCP" ] && { [ -d "$HOME/.windsurf" ] || [ -d "$HOME/.cline" ] || [ -f "$VSCODE_MCP" ]; }; then
    register_mcp_servers "$VSCODE_MCP"
    installed_platforms="$installed_platforms VSCode/Windsurf/Cline(MCP)"
fi

# --- Codex CLI ---
if [ -d "$HOME/.codex" ] && [ -f "$HOME/.codex/config.toml" ]; then
    register_mcp_toml "$HOME/.codex/config.toml"
    installed_platforms="$installed_platforms Codex-CLI(MCP)"
fi

fi  # end python3 check

echo "Cerebro installed successfully!"
echo ""
echo "  Local config:  $CEREBRO_LOCAL/"
echo "  Hook scripts:  $CEREBRO_LOCAL/hooks/"
echo "  MCP server:    $MCP_SCRIPT"
echo "  Storage:       $CEREBRO_HOME_RESOLVED"
echo "  Platforms:    $installed_platforms"
echo ""
echo "Run /cerebro in your AI coding assistant to start onboarding."
echo "Restart any open desktop apps (Claude, Cursor, Codex, Antigravity)"
echo "to activate the Cerebro MCP server."
