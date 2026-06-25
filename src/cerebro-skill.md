---
name: cerebro
description: >
  Cerebro session manager — activate whenever the user references their Cerebro
  data, session history, past work, or wants to capture something. Also activate
  for any /cerebro command. Trigger phrases include: "what did I work on",
  "check my history", "last session", "what are my goals", "what are my blockers",
  "save this as a decision", "save this as a snippet", "add a TIL", "bookmark this",
  "add to inbox", "check in", "pin this", "start my session", "end my session",
  "run cerebro", "my TILs", "research mode", "create a knowledge base",
  "new project", "what did I learn", "show my notes", "generate standup",
  "write a handoff", "weekly digest", "show my streaks", "what's in my memory",
  "search my history", "show my favorites", "archive old sessions",
  "show my workspace", "create a template", "show my stats".
---

# Cerebro Skill — v0.2.0

Cerebro is Diego's persistent memory and knowledge system. All data lives in plain
markdown files on his machine. Read and write those files directly — never ask
Diego to run shell commands manually.

---

## Config

Read `~/.cerebro/config.json` first whenever you don't have it in context.

Key fields:
- `cerebro_home` — root of all Cerebro data (expand `~` to the full path)
- `user.preferred_name` — how to address Diego
- `knowledge_base_root` — root of research KBs

**Expanded paths (Diego's machine):**
```
cerebro_home:      /Users/diegomartins/Library/CloudStorage/GoogleDrive-dpm0828@gmail.com/My Drive/00_Cerebro/00_Storage
knowledge_base_root: /Users/diegomartins/Library/CloudStorage/GoogleDrive-dpm0828@gmail.com/My Drive/00_Cerebro/00_knowledge
memory_file:       /Users/diegomartins/.claude/projects/-Users-diegomartins-Library-CloudStorage-GoogleDrive-dpm0828-gmail-com-My-Drive/memory/MEMORY.md
```

> **Gotcha:** `cerebro_home` contains a space. Always quote it: `"$CEREBRO_HOME"`. Never pass bare `~` to file tools — expand to `/Users/diegomartins/` first.

---

## Directory Layout

```
$CEREBRO_HOME/
  activity-history.md    # append-only session journal — NEVER overwrite
  goals.md               # [ ] active goals, [x] completed
  blockers.md            # [ ] unresolved blockers, [x] resolved
  pins.md                # persistent items + [due YYYY-MM-DD] reminders
  inbox.md               # quick-capture triage queue
  favorites.md           # favorited sessions/notes/decisions
  memory-backup.md       # latest snapshot of platform memory
  sessions/              # YYYY-MM-DD-HHMMSS-<id>.md
  notes/                 # YYYY-MM-DD.md daily notes + bookmarks.md
  til/                   # YYYY-MM-DD.md Today I Learned
  snippets/              # <slug>.md code snippets
  decisions/             # YYYY-MM-DD-<slug>.md ADR-style decisions
  checkins/              # YYYY-MM-DD.md in-session check-ins
  reports/               # handoffs, digests, standups, changelogs
  workspaces/            # <name>.md named project contexts
  templates/             # reusable markdown templates
  archive/               # YYYY/ subdirs of archived old content
  skills/                # user-created Cerebro skills

~/.cerebro/
  config.json            # all paths + privacy + platform settings
  VERSION                # 0.2.0
  hooks/                 # log-prompt.py, log-stop.py, kb-autoprocess.py, session-autostart.py
  session-map/           # session ID + .timer files
```

---

## All 57 Commands — Quick Reference

| Category | Commands |
|----------|----------|
| **Session** | start, end, log, private |
| **Capture** | note, til, snippet, decision, inbox, bookmark, pin |
| **Focus** | goal, blocked, checkin, workspace, context |
| **Search** | search, find, query, tag |
| **Knowledge** | new-project, new-kb, research, memory, map, links, graph* |
| **Review** | today, digest, review, changelog, flashback, stats, streaks, patterns* |
| **Collaboration** | handoff, standup, team*, join*, share*, mention*, delegate*, push*, pull* |
| **Automation** | template, alias*, watch* |
| **System** | status, profile, consent, privacy, clean, update, setup, uninstall, export |
| **Organization** | archive, fav, dedup* |

*v0.3 stub — explains what's coming, suggests best current alternative.

---

## File Formats

### activity-history.md — append-only
```markdown
## YYYY-MM-DD

- **Session title** — what happened, open items
```
Always append. Find the right date heading and insert after existing bullets, or add a new heading.

### goals.md / blockers.md / pins.md / inbox.md — checklists
```markdown
# Goals
- [ ] YYYY-MM-DD — <item>
- [x] YYYY-MM-DD — <item>
```
Pins with reminders: `- YYYY-MM-DD — [due YYYY-MM-DD] <item>`

### notes/YYYY-MM-DD.md
```markdown
# Notes: YYYY-MM-DD
### HH:MM — <text>
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
<learning>
```

### checkins/YYYY-MM-DD.md
```markdown
---
type: checkin
created: YYYY-MM-DD
tags: []
project: <project>
---
# Check-ins: YYYY-MM-DD
### HH:MM
<text>
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

### notes/bookmarks.md
```markdown
# Bookmarks
- YYYY-MM-DD — [<title>](<url>) `#tag1 #tag2`
```

### reports/handoff-YYYY-MM-DD-HHMM.md
```markdown
---
type: handoff
created: YYYY-MM-DD
---
# Handoff: YYYY-MM-DD HH:MM

## What's in Progress
## Context (files, links, decisions)
## Next Steps
## Known Blockers
## How to Pick This Up
```

### workspaces/<name>.md
```markdown
---
type: workspace
name: <name>
created: YYYY-MM-DD
last_active: YYYY-MM-DD
---
## Active Project
## Pinned Context
## Active Goals
```

### favorites.md
```markdown
# Favorites
- YYYY-MM-DD — <type> — [<title>](<relative-path>)
```

---

## When Capturing Something

Write files directly — never ask Diego to run a command:

| Trigger | Action |
|---------|--------|
| Note | Append to `$CEREBRO_HOME/notes/YYYY-MM-DD.md` |
| TIL | Append to `$CEREBRO_HOME/til/YYYY-MM-DD.md` |
| Decision | Create `$CEREBRO_HOME/decisions/YYYY-MM-DD-<slug>.md` |
| Snippet | Create `$CEREBRO_HOME/snippets/<slug>.md` |
| Bookmark | Append to `$CEREBRO_HOME/notes/bookmarks.md` |
| Goal | Append to `$CEREBRO_HOME/goals.md` |
| Blocker | Append to `$CEREBRO_HOME/blockers.md` |
| Pin | Append to `$CEREBRO_HOME/pins.md` |
| Inbox | Append to `$CEREBRO_HOME/inbox.md` |
| Check-in | Append to `$CEREBRO_HOME/checkins/YYYY-MM-DD.md` |
| Handoff | Create `$CEREBRO_HOME/reports/handoff-YYYY-MM-DD-HHMM.md` |
| Standup | Create `$CEREBRO_HOME/reports/standup-YYYY-MM-DD.md` |
| Digest | Create `$CEREBRO_HOME/reports/digest-YYYY-MM-DD.md` |

Use the correct file format from the layouts above. Create the file with the YAML frontmatter header if it doesn't exist yet.

---

## When Reading Session History

1. Read `activity-history.md` — primary journal
2. List `sessions/` by modification time to find the latest
3. Grep `sessions/` and `til/` and `decisions/` for keywords
4. Read the specific session file for full detail

Do this without being asked. When Diego says "what did I work on last week?" — just read the files and answer.

---

## When Running a /cerebro Command

You are the implementation. Read the mode definition from `~/.claude/commands/cerebro.md` (or whichever platform's command file is active), then execute it using your available file and shell tools. Never tell Diego to run a command himself.

---

## Research Mode — Processing Loop

When ingesting a source into a KB's `src/`:

1. Read the source in full — don't summarize prematurely
2. Extract atomic concepts — one `wiki/<concept>.md` per concept
3. Add `[[wikilinks]]` wherever concepts reference each other
4. Update `wiki/index.md` — one-line entry per new/updated page
5. Mark source processed in `.kb/processed.json`
6. Append to `learnings.md` — what was extracted, what linked, surprises
7. If a query was run — write answer to `wiki/queries/YYYY-MM-DD-<slug>.md`

Every session compounds: more pages → more links → more findable answers.

### Health check triggers (`/cerebro research health`):
- Orphan pages — no inbound links
- Stub pages — under 100 words
- Contradictions — opposite claims in two pages about the same concept
- Stale pages — not updated in 90+ days

### Gap detection (`/cerebro research gaps`):
- `[[wikilinks]]` that have no target page yet
- Topics in multiple sources but thin wiki coverage (<200 words)
- Suggest 3–5 article titles that would fill the gaps

---

## Privacy Rules

Before writing anything, check `privacy` in config:
- `session_recording: false` → don't write to `sessions/`
- `activity_logging: false` → don't write to `activity-history.md`
- `private_by_default: true` → confirm before writing anything

---

## Knowledge Bases

Root: `/Users/diegomartins/Library/CloudStorage/GoogleDrive-dpm0828@gmail.com/My Drive/00_Cerebro/00_knowledge`

Each KB folder contains: `src/`, `wiki/`, `CLAUDE.md`, `learnings.md`, `.kb/config.json`, `.kb/processed.json`

Known KBs:
- `adobe-portfolio-deep-dive/` — built 2026-06-15
- `salesforce-principal-pd/` — built 2026-06-15

---

## Gotchas

- **Space in cerebro_home path** — always quote: `"$CEREBRO_HOME"`
- **activity-history.md is append-only** — find the insertion point, never rewrite
- **Session filenames** — `YYYY-MM-DD-HHMMSS-<uuid-prefix>.md`, sort by mtime for latest
- **Memory file path in config is stale** — use: `/Users/diegomartins/.claude/projects/-Users-diegomartins-Library-CloudStorage-GoogleDrive-dpm0828-gmail-com-My-Drive/memory/MEMORY.md`
- **Checkin files need YAML frontmatter** — create with the full header if the day's file doesn't exist yet
- **Don't expand dates with shell commands in tool args** — compute `YYYY-MM-DD` yourself from today's date
