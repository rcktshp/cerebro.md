---
name: cerebro
description: >
  Cerebro session manager — use when the user references their Cerebro history,
  asks about past sessions, wants to capture something, run a Cerebro command,
  or work with their knowledge base. Triggers on phrases like "what did I work
  on", "check my history", "save this as a decision", "run cerebro", "my TILs",
  "last session", "what are my goals", "add to inbox", "research mode".
---

# Cerebro Skill

Cerebro is Diego's persistent memory system. All data lives in plain markdown files.
You have direct read/write access — act on it with the tools you have (Read, Edit,
Write, Bash), not by asking Diego to run commands manually.

## Config

Always read config first if you don't have it in context already:

```bash
cat ~/.cerebro/config.json
```

Key paths from config:
- `cerebro_home` → where all data lives (expand `~` yourself — don't pass `~` to tools)
- `user.preferred_name` → how to address Diego
- `platforms.claude-code.memory_path` → the active memory file

Expanded `cerebro_home`:
`/Users/diegomartins/Library/CloudStorage/GoogleDrive-dpm0828@gmail.com/My Drive/00_Cerebro/00_Storage`

## Directory Layout

```
$CEREBRO_HOME/
  activity-history.md   # append-only session journal — NEVER overwrite, only append
  goals.md              # checklist of active goals
  blockers.md           # checklist of unresolved blockers
  pins.md               # persistent reminders
  inbox.md              # quick-capture triage queue
  favorites.md          # favorited sessions/notes
  memory-backup.md      # latest copy of platform memory file
  sessions/             # per-session log files (YYYY-MM-DD-HHMMSS-<id>.md)
  notes/                # daily notes (YYYY-MM-DD.md) and bookmarks.md
  til/                  # Today I Learned (YYYY-MM-DD.md)
  snippets/             # code snippets (<slug>.md)
  decisions/            # ADR files (YYYY-MM-DD-<slug>.md)
  checkins/             # in-session check-ins (YYYY-MM-DD.md)
  reports/              # handoffs, digests, standups, changelogs
  workspaces/           # named workspace contexts (<name>.md)
  skills/               # user-created Cerebro skills
  archive/              # archived old content (YYYY/ subfolders)
  templates/            # reusable templates

~/.cerebro/
  config.json           # source of truth for all paths and settings
  hooks/                # Python hook scripts (log-prompt.py, log-stop.py, etc.)
  session-map/          # session ID files + .timer files
  VERSION               # installed version
```

## How to Read Session History

```bash
# Last 3 activity entries
tail -80 "$CEREBRO_HOME/activity-history.md"

# Find sessions by keyword
grep -r "keyword" "$CEREBRO_HOME/sessions/"

# List session files by date
ls -lt "$CEREBRO_HOME/sessions/" | head -20

# Read a specific session
cat "$CEREBRO_HOME/sessions/<filename>"
```

## How to Append to Activity History

Always append — never overwrite.

```python
# Check if today's heading exists
grep -n "## $(date +%Y-%m-%d)" "$CEREBRO_HOME/activity-history.md"
# If not found, append the heading first, then the bullet
# If found, find the line and append after the existing bullets under it
```

Pattern for appending:
```markdown
## YYYY-MM-DD

- **Summary bullet** — what happened, what's open
```

## File Formats

### goals.md / blockers.md / pins.md / inbox.md
Plain markdown checklists. `[ ]` = open, `[x]` = done.
```markdown
# Goals
- [ ] 2026-06-01 — Ship Cerebro v0.2.0
- [x] 2026-05-20 — Write onboarding flow
```

### notes/YYYY-MM-DD.md
```markdown
# Notes: YYYY-MM-DD
### HH:MM — <note text>
```

### til/YYYY-MM-DD.md
```markdown
---
type: til
created: YYYY-MM-DD
tags: []
---
# TIL: YYYY-MM-DD
### HH:MM
<learning text>
```

### snippets/<slug>.md
```markdown
---
type: snippet
title: <title>
language: <lang>
created: YYYY-MM-DD
tags: []
---
# <title>
```<lang>
<code>
```
```

### decisions/YYYY-MM-DD-<slug>.md
```markdown
---
type: decision
title: <title>
date: YYYY-MM-DD
status: active
tags: []
---
# <title>
## Context
## Options Considered
## Decision
## Consequences
```

### Research KB (inside knowledge_base_root)
```
<topic-slug>/
  src/          # raw source material (read-only inputs)
  wiki/         # atomic concept pages with [[wikilinks]]
    index.md    # one-line entry per concept page
  CLAUDE.md     # schema and processing rules for this KB
  learnings.md  # what worked/didn't after each session
  .kb/
    config.json   # { "topic": "...", "created": "YYYY-MM-DD" }
    processed.json  # { "sources": { "<filename>": { "processed": "YYYY-MM-DD" } } }
```

## When the User Asks About Their History

1. Read `activity-history.md` — it's the primary journal.
2. For detail, look up the session file referenced in that entry.
3. Search `til/`, `decisions/`, `snippets/` for related captures.
4. Use grep across sessions/ for keyword search.

Do this proactively — don't ask Diego to "run /cerebro search". Just do the search yourself and report what you find.

## When Capturing Something

Write it yourself using Edit/Write:
- Note → append to `notes/$(date +%Y-%m-%d).md`
- TIL → append to `til/$(date +%Y-%m-%d).md`
- Decision → create `decisions/$(date +%Y-%m-%d)-<slug>.md`
- Snippet → create `snippets/<slug>.md`
- Bookmark → append to `notes/bookmarks.md`
- Goal → append to `goals.md`
- Blocker → append to `blockers.md`
- Inbox item → append to `inbox.md`

Always use the correct file format (frontmatter + structure) from the layouts above.

## When Running a Cerebro Command

You are the implementation. When Diego says `/cerebro <command>`:
- You read the `cerebro.md` slash command file for the mode definition
- You execute it using your tools (Read, Edit, Write, Bash)
- You don't tell Diego to run a shell command — you do the work

## Privacy Rules

Always check `privacy` in config before writing:
- `session_recording: false` → don't write session files
- `activity_logging: false` → don't write to activity-history.md
- `private_by_default: true` → confirm with Diego before writing anything

## Knowledge Base Root

`/Users/diegomartins/Library/CloudStorage/GoogleDrive-dpm0828@gmail.com/My Drive/00_Cerebro/00_knowledge`

List existing KBs:
```bash
ls "$KB_ROOT/"
```

Active KBs (from past sessions):
- `adobe-portfolio-deep-dive/` — built 2026-06-15
- `salesforce-principal-pd/` — built 2026-06-15

## Research Mode — Processing Loop

When ingesting a source into a KB's `src/`:
1. Read the source fully (don't summarize prematurely)
2. Identify atomic concepts — each gets its own `wiki/<concept>.md`
3. Add `[[wikilinks]]` wherever concepts reference each other
4. Update `wiki/index.md` with a one-line summary per new/updated page
5. Mark source processed in `.kb/processed.json`
6. Append to `learnings.md`: what was extracted, what linked, anything surprising
7. If the user ran a query: write the answer to `wiki/queries/YYYY-MM-DD-<slug>.md`

This compounds — every session adds pages, every page adds links, every query adds a findable answer.

## Gotchas

- **`cerebro_home` contains a space** (Google Drive path). Always quote it in Bash: `"$CEREBRO_HOME"`.
- **Never use `~` in tool paths** — expand to `/Users/diegomartins/` explicitly.
- **activity-history.md is append-only.** Find the right insertion point; don't rewrite the file.
- **Session files are named** `YYYY-MM-DD-HHMMSS-<uuid-prefix>.md` — list by mtime to find the latest.
- **The memory file path in config is stale** — the correct path is `/Users/diegomartins/.claude/projects/-Users-diegomartins-Library-CloudStorage-GoogleDrive-dpm0828-gmail-com-My-Drive/memory/MEMORY.md`. Use that path for memory backup, not the one in config.json.
