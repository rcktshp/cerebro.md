#!/usr/bin/env python3
"""
Cerebro MCP Server — gives Claude Desktop (and any MCP-compatible client)
full read/write access to your Cerebro data using the same files that
Claude Code, Cursor, and Codex use.

Register in ~/Library/Application Support/Claude/claude_desktop_config.json:
{
  "mcpServers": {
    "cerebro": {
      "command": "python3",
      "args": ["~/.cerebro/cerebro-mcp.py"]
    }
  }
}

Protocol: MCP 2024-11-05 over stdio (JSON-RPC 2.0, newline-delimited).
Dependencies: Python 3.8+ stdlib only.
"""

import json
import os
import sys
import datetime
from pathlib import Path

# ---------------------------------------------------------------------------
# Config helpers
# ---------------------------------------------------------------------------

CONFIG_PATH = Path.home() / ".cerebro" / "config.json"


def load_config():
    if CONFIG_PATH.exists():
        return json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    return {}


def cerebro_home():
    cfg = load_config()
    return Path(os.path.expanduser(cfg.get("cerebro_home", "~/Cerebro")))


def kb_root():
    cfg = load_config()
    home = cerebro_home()
    return Path(os.path.expanduser(
        cfg.get("knowledge_base_root", str(home / "knowledge"))
    ))


def safe_path(base: Path, rel: str) -> Path:
    """Resolve rel relative to base and assert it stays inside base."""
    target = (base / rel).resolve()
    if not str(target).startswith(str(base.resolve())):
        raise ValueError(f"Path '{rel}' escapes the Cerebro data directory.")
    return target


# ---------------------------------------------------------------------------
# Tool definitions
# ---------------------------------------------------------------------------

TOOLS = [
    {
        "name": "cerebro_config",
        "description": (
            "Return Cerebro config and resolved paths. "
            "Call this first to understand the user's setup — "
            "cerebro_home, knowledge_base_root, privacy settings, installed platforms."
        ),
        "inputSchema": {"type": "object", "properties": {}, "required": []},
    },
    {
        "name": "cerebro_read",
        "description": (
            "Read a file from the Cerebro data directory. "
            "Use paths relative to cerebro_home, e.g. 'activity-history.md', "
            "'goals.md', 'notes/2026-06-25.md', 'sessions/2026-06-25-120000-abc.md'. "
            "Pass tail=N to get only the last N lines (useful for activity-history)."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "path": {
                    "type": "string",
                    "description": "File path relative to cerebro_home",
                },
                "tail": {
                    "type": "integer",
                    "description": "If set, return only the last N lines",
                },
            },
            "required": ["path"],
        },
    },
    {
        "name": "cerebro_list",
        "description": (
            "List files/directories inside a Cerebro directory. "
            "Use paths relative to cerebro_home (e.g. 'sessions', 'notes', 'til', "
            "'decisions', 'snippets'). Leave path empty for the root. "
            "Set sort_by_mtime=true to get newest files first (recommended for sessions)."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "path": {
                    "type": "string",
                    "description": "Directory relative to cerebro_home (empty = root)",
                },
                "sort_by_mtime": {
                    "type": "boolean",
                    "description": "Sort newest first by modification time",
                },
            },
            "required": [],
        },
    },
    {
        "name": "cerebro_write",
        "description": (
            "Write or append to a file in the Cerebro data directory. "
            "Use mode='append' for activity-history.md, notes, til, goals, blockers, "
            "pins, and inbox (these are always append-only). "
            "Use mode='write' to create or replace a file (decisions, snippets, "
            "handoffs, new workspace files, etc.). "
            "Parent directories are created automatically."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "path": {
                    "type": "string",
                    "description": "File path relative to cerebro_home",
                },
                "content": {
                    "type": "string",
                    "description": "Content to write or append",
                },
                "mode": {
                    "type": "string",
                    "enum": ["append", "write"],
                    "description": "'append' (default) or 'write' (overwrite/create)",
                },
            },
            "required": ["path", "content"],
        },
    },
    {
        "name": "cerebro_search",
        "description": (
            "Search Cerebro files for a keyword or phrase (case-insensitive). "
            "Searches all .md files under cerebro_home by default. "
            "Narrow the scope with a relative directory path, e.g. 'sessions', "
            "'notes', 'til', 'decisions'. "
            "Returns matching file paths and up to 3 matching lines per file."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "query": {
                    "type": "string",
                    "description": "Search term (case-insensitive)",
                },
                "scope": {
                    "type": "string",
                    "description": "Sub-directory to search (leave empty to search all)",
                },
            },
            "required": ["query"],
        },
    },
]

# ---------------------------------------------------------------------------
# Handlers
# ---------------------------------------------------------------------------


def handle_cerebro_config(_args):
    cfg = load_config()
    version_path = Path.home() / ".cerebro" / "VERSION"
    return {
        "cerebro_home": str(cerebro_home()),
        "knowledge_base_root": str(kb_root()),
        "user": cfg.get("user", {}),
        "privacy": cfg.get("privacy", {}),
        "platforms": list(cfg.get("platforms", {}).keys()),
        "version": version_path.read_text().strip() if version_path.exists() else "unknown",
    }


def handle_cerebro_read(args):
    target = safe_path(cerebro_home(), args["path"])
    if not target.exists():
        return f"(file not found: {args['path']})"
    text = target.read_text(encoding="utf-8")
    tail = args.get("tail")
    if tail:
        lines = text.splitlines()
        text = "\n".join(lines[-int(tail):])
    return text


def handle_cerebro_list(args):
    base = cerebro_home()
    rel = args.get("path") or ""
    target = safe_path(base, rel) if rel else base.resolve()
    if not target.exists():
        return f"(directory not found: {rel or 'root'})"

    entries = list(target.iterdir())
    if args.get("sort_by_mtime"):
        entries.sort(key=lambda p: p.stat().st_mtime, reverse=True)
    else:
        entries.sort(key=lambda p: p.name)

    lines = []
    for e in entries:
        kind = "dir " if e.is_dir() else "file"
        mtime = datetime.datetime.fromtimestamp(e.stat().st_mtime).strftime("%Y-%m-%d %H:%M")
        lines.append(f"{kind}  {e.name}  ({mtime})")

    return "\n".join(lines) if lines else "(empty)"


def handle_cerebro_write(args):
    target = safe_path(cerebro_home(), args["path"])
    target.parent.mkdir(parents=True, exist_ok=True)
    mode = args.get("mode", "append")
    content = args["content"]

    if mode == "append":
        with open(target, "a", encoding="utf-8") as f:
            f.write(content)
        action = "Appended to"
    else:
        target.write_text(content, encoding="utf-8")
        action = "Written"

    return f"{action}: {args['path']}"


def handle_cerebro_search(args):
    base = cerebro_home()
    query = args["query"].lower()
    scope = args.get("scope") or ""
    search_root = safe_path(base, scope) if scope else base.resolve()

    if not search_root.exists():
        return f"(directory not found: {scope})"

    results = []
    for path in sorted(search_root.rglob("*.md"), key=lambda p: p.stat().st_mtime, reverse=True):
        try:
            text = path.read_text(encoding="utf-8")
        except Exception:
            continue
        if query not in text.lower():
            continue
        rel = path.relative_to(base)
        matches = [
            f"  {i + 1}: {line.strip()}"
            for i, line in enumerate(text.splitlines())
            if query in line.lower()
        ][:3]
        results.append(f"{rel}\n" + "\n".join(matches))
        if len(results) >= 20:
            break

    if not results:
        return f"No results for '{args['query']}'"
    return f"Found in {len(results)} file(s):\n\n" + "\n\n".join(results)


HANDLERS = {
    "cerebro_config": handle_cerebro_config,
    "cerebro_read": handle_cerebro_read,
    "cerebro_list": handle_cerebro_list,
    "cerebro_write": handle_cerebro_write,
    "cerebro_search": handle_cerebro_search,
}

# ---------------------------------------------------------------------------
# MCP JSON-RPC loop
# ---------------------------------------------------------------------------


def send(obj):
    sys.stdout.write(json.dumps(obj) + "\n")
    sys.stdout.flush()


def send_error(id_, code, message):
    send({"jsonrpc": "2.0", "id": id_, "error": {"code": code, "message": message}})


def main():
    for raw in sys.stdin:
        raw = raw.strip()
        if not raw:
            continue
        try:
            msg = json.loads(raw)
        except json.JSONDecodeError:
            continue

        method = msg.get("method", "")
        id_ = msg.get("id")          # None for notifications
        params = msg.get("params") or {}

        # Notifications have no id — just continue
        if id_ is None:
            continue

        if method == "initialize":
            send({
                "jsonrpc": "2.0",
                "id": id_,
                "result": {
                    "protocolVersion": "2024-11-05",
                    "capabilities": {"tools": {}},
                    "serverInfo": {"name": "cerebro", "version": "0.2.0"},
                },
            })

        elif method == "tools/list":
            send({"jsonrpc": "2.0", "id": id_, "result": {"tools": TOOLS}})

        elif method == "tools/call":
            name = params.get("name", "")
            args = params.get("arguments") or {}
            handler = HANDLERS.get(name)
            if not handler:
                send_error(id_, -32601, f"Unknown tool: {name}")
                continue
            try:
                result = handler(args)
                if not isinstance(result, str):
                    result = json.dumps(result, indent=2, ensure_ascii=False)
                send({
                    "jsonrpc": "2.0",
                    "id": id_,
                    "result": {"content": [{"type": "text", "text": result}]},
                })
            except Exception as exc:
                send_error(id_, -32000, str(exc))

        else:
            send_error(id_, -32601, f"Method not found: {method}")


if __name__ == "__main__":
    main()
