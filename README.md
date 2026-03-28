# Cerebro

**Your AI assistant's memory.** Cerebro is a persistent memory and session management system that works across AI coding assistants. It remembers what you worked on, tracks your sessions, and builds a searchable knowledge base — all stored locally on your machine.

Created by [Diego Martins](https://www.diegomartins.com)

## Features

- **Session Recording** — Automatically logs every prompt and response
- **Activity History** — An append-only journal that builds across all your sessions
- **Knowledge Capture** — Notes, decisions, snippets, TILs, all searchable
- **Memory Backup** — Syncs your platform memory to safe storage
- **Token & Timing Tracking** — Know how long you spend and what it costs
- **Multi-Platform** — Works with Claude Code, Cursor, Windsurf, and Cline
- **Cross-OS** — macOS, Linux, and Windows
- **Privacy First** — You own all your data. Full control over what's tracked. Anonymous and private modes available.
- **Self-Updating** — `/cerebro update` pulls the latest version

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
| **Knowledge** | `memory`, `map`, `graph`, `links` |
| **Review** | `today`, `digest`, `review`, `changelog`, `flashback`, `stats`, `streaks`, `patterns` |
| **Collaboration** | `team`, `join`, `share`, `handoff`, `standup`, `mention`, `delegate`, `push`, `pull` |
| **Automation** | `template`, `alias`, `watch` |
| **System** | `status`, `profile`, `consent`, `privacy`, `clean`, `update`, `setup`, `uninstall`, `export` |
| **Organization** | `archive`, `fav`, `dedup` |

All commands are invoked as `/cerebro <command>`.

## Platform Support

| Platform | Slash Commands | Auto-Logging (Hooks) | Status |
|----------|---------------|---------------------|--------|
| Claude Code | Yes | Full | Supported |
| Cursor | Yes | Limited | Supported |
| Windsurf | Yes | Manual only | Supported |
| Cline | Yes | Manual only | Supported |

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
| `~/.cerebro/` | Config, hooks, session map (~15 KB) |
| `~/Cerebro/` (or your chosen path) | Sessions, notes, history, knowledge |

No databases. No background processes. No network calls (except version check). Just markdown files and JSON.

## Requirements

- **Python 3** (for hook scripts — standard library only, no pip installs)
- macOS, Linux, or Windows

## Uninstall

```
/cerebro uninstall
```

Walks you through a clean removal with an option to export your data first.

## License

MIT — Copyright (c) 2026 CEREBRO.md by Martins LLC dba Rocketship. See [LICENSE](LICENSE).

For website terms of use, trademark policy, and other project policies, see [rocketship.xyz](https://www.rocketship.xyz).

## Open Core

Cerebro is free and open source for all personal and self-hosted team use. A paid tier for hosted team features, cloud sync, and advanced integrations is planned.
