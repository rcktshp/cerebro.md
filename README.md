# CEREBRO.md

**Your AI assistant's memory.** Cerebro is a persistent memory and session management system that works across AI coding assistants. It remembers what you worked on, tracks your sessions, and builds a searchable knowledge base — all stored locally on your machine.

Created by [Diego Martins](https://www.diegomartins.com) *Personal project. Not affiliated with or endorsed by any employer.*

## Features

- **Session Recording** — Automatically logs every prompt and response
- **Activity History** — An append-only journal that builds across all your sessions
- **Knowledge Capture** — Notes, decisions, snippets, TILs, bookmarks — all searchable
- **Research Mode** — Ingest external sources into a self-organizing wiki with `[[wikilinks]]`, health checks, gap detection, and Q&A that files back into the wiki so every exploration compounds
- **MCP Server** — Built-in MCP server gives Claude Desktop, Cursor, Codex CLI, Antigravity, Windsurf, and Cline full read/write access to your Cerebro data in chat UIs — not just coding sessions
- **Skill File** — Teaches Claude Code, Cursor, and Codex CLI to navigate your Cerebro data natively, so your AI can read history and capture notes without being asked
- **Memory Backup** — Syncs your platform memory to safe storage
- **Token & Timing Tracking** — Know how long you spend and what it costs
- **Daily & Weekly Reviews** — Standups, digests, stats, streaks, flashbacks
- **Handoffs** — Structured context docs to resume work in a new session or platform
- **Multi-Platform** — Works with Claude Code, Claude Desktop, Cursor, Windsurf, Cline, Codex CLI, Gemini CLI, and Google Antigravity
- **Cross-OS** — macOS, Linux, and Windows
- **Privacy First** — You own all your data. Full control over what's tracked. Anonymous and private modes available.

## Quick Install

```bash
git clone https://github.com/rcktshp/cerebro.md.git
cd cerebro.md
bash install.sh
```

Then open your AI assistant and type:
```
/cerebro
```

Cerebro will walk you through a guided setup — name, preferences, privacy settings, storage location, and platform detection. Takes about 2 minutes.

## How It Works

```
You type a prompt
  → Cerebro logs it to a session file (automatic via hooks)
  → Tracks timing and token usage

You finish a session
  → /cerebro end summarizes what you did
  → Appends to your activity history
  → Backs up your memory

You start a new session
  → /cerebro start loads your context
  → Shows recent activity, reminders, goals
  → Picks up right where you left off
```

## Commands

| Category | Commands |
|----------|----------|
| **Session** | `start`, `end`, `private`, `log` |
| **Capture** | `note`, `til`, `snippet`, `decision`, `inbox`, `bookmark`, `pin` |
| **Focus** | `goal`, `blocked`, `checkin`, `workspace`, `context` |
| **Search** | `search`, `find`, `query`, `tag` |
| **Knowledge** | `new-project`, `new-kb`, `research`, `memory`, `map`, `graph`*, `links` |
| **Review** | `today`, `digest`, `review`, `changelog`, `flashback`, `stats`, `streaks`, `patterns`* |
| **Collaboration** | `handoff`, `standup`, `team`*, `join`*, `share`*, `mention`*, `delegate`*, `push`*, `pull`* |
| **Automation** | `template`, `alias`*, `watch`* |
| **System** | `status`, `profile`, `consent`, `privacy`, `clean`, `update`, `setup`, `uninstall`, `export` |
| **Organization** | `archive`, `fav`, `dedup`* |

All commands are invoked as `/cerebro <command>`. Commands marked * are v0.3 stubs — they explain what's coming and suggest the best current alternative.

## Platform Support

| Platform | Commands | Auto-Log | Skill | MCP |
|----------|----------|----------|-------|-----|
| Claude Code | ✅ | ✅ hooks | ✅ | — |
| Claude Desktop | — | — | — | ✅ |
| Cursor | ✅ | — | ✅ | ✅ |
| Windsurf | ✅ | — | — | ✅ |
| Cline | ✅ | — | — | ✅ |
| Codex CLI | ✅ | — | ✅ | ✅ |
| Gemini CLI | ✅ TOML | — | — | — |
| Google Antigravity | ✅ plugin | — | — | ✅ |

- **Commands** — `/cerebro` slash command installed
- **Auto-Log** — sessions recorded automatically via hooks (no manual `/cerebro log` needed)
- **Skill** — Cerebro context loads proactively; your AI can read history and capture notes without being asked
- **MCP** — full read/write access to your Cerebro data in the app's chat UI via the built-in MCP server

## MCP Server

The Cerebro MCP server (`~/.cerebro/cerebro-mcp.py`) gives any MCP-compatible client full access to your Cerebro data through five tools:

| Tool | What it does |
|------|-------------|
| `cerebro_config` | Returns your paths, user prefs, and privacy settings |
| `cerebro_read` | Reads any file from your Cerebro data directory |
| `cerebro_list` | Lists files in a Cerebro directory (sortable by date) |
| `cerebro_write` | Appends or writes files (enforces append-only for history/notes) |
| `cerebro_search` | Searches all `.md` files for a keyword with context lines |

`install.sh` registers it automatically in each platform's MCP config — no manual setup needed.

## Privacy

Cerebro is local-first. Your data never leaves your machine unless you explicitly choose cloud storage.

- **All tracking is opt-in** during onboarding
- **Private mode** — `/cerebro private` starts a session with zero logging
- **Anonymous mode** — strips your name from all content
- **Full data export** — `/cerebro privacy export`
- **Delete everything** — `/cerebro privacy delete-all`
- **Granular consent** — `/cerebro consent` to toggle individual features

## Storage

Everything lives in two places:

| Location | What's there |
|----------|-------------|
| `~/.cerebro/` | Config, hooks, MCP server, session map (~20 KB) |
| `~/Cerebro/` (or your chosen path) | Sessions, notes, history, knowledge |

No databases. No background processes. No network calls at runtime. Just markdown files and JSON.

## Requirements

- **Python 3** (for hook scripts and MCP server — standard library only, no pip installs)
- macOS, Linux, or Windows

## Uninstall

```
/cerebro uninstall
```

Walks you through a clean removal with an option to export your data first.

## License

MIT — Copyright (c) 2026 CEREBRO.md by Martins LLC dba Rocketship. See [LICENSE](LICENSE).

## Open Core

Cerebro is free and open source for all personal and self-hosted team use. A paid tier for hosted team features, cloud sync, and advanced integrations is planned.
