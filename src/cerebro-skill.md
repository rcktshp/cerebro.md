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

Cerebro is a persistent memory and knowledge system for AI coding assistants. All
data lives in plain markdown files. Read and write those files directly — never
ask the user to run shell commands manually.

---

## Config

Read `~/.cerebro/config.json` first if you don't have it in context.

Key fields:
- `cerebro_home` — root of all Cerebro data (expand `~` to the full absolute path)
- `user.preferred_name` — how to address the user
- `knowledge_base_root` — root of research knowledge bases
- `platforms.<platform>.memory_path` — the active memory file for this platform

**Installed paths (substituted at install time):**
```
cerebro_home:        {{CEREBRO_HOME}}
knowledge_base_root: {{KB_ROOT}}
```

> **Gotcha:** `cerebro_home` may contain spaces (e.g. a Google Drive path). Always
> quote it in shell commands: `"$CEREBRO_HOME"`. Never pass bare `~` to file tools
> — expand to the full absolute path first.

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
  hooks/                 # log-prompt.py, log-stop.py, kb-autoprocess.py
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
` ` `<lang>
<code>
` ` `
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

Write files directly — never ask the user to run a command:

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

1. Read `$CEREBRO_HOME/activity-history.md` — primary journal
2. List `$CEREBRO_HOME/sessions/` by modification time to find the latest
3. Search `$CEREBRO_HOME/sessions/`, `til/`, and `decisions/` for keywords
4. Read the specific session file for full detail

Do this proactively — when the user asks "what did I work on last week?" just read the files and answer.

---

## When Running a /cerebro Command

You are the implementation. Read the mode definition from the platform's cerebro command file, then execute it using your available file and shell tools. Never tell the user to run a command themselves.

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

### Health check (`/cerebro research health`):
- Orphan pages — no inbound links
- Stub pages — under 100 words
- Contradictions — opposite claims about the same concept
- Stale pages — not updated in 90+ days

### Gap detection (`/cerebro research gaps`):
- `[[wikilinks]]` that have no target page yet
- Topics in multiple sources but thin wiki coverage (<200 words)
- Suggest 3–5 article titles that would fill the gaps

### Knowledge base structure:
```
{{KB_ROOT}}/
  <topic-slug>/
    src/            # raw source material (read-only inputs)
    wiki/           # atomic concept pages with [[wikilinks]]
      index.md      # one-line entry per concept page
      queries/      # YYYY-MM-DD-<slug>.md answer files
    CLAUDE.md       # schema and processing rules for this KB
    learnings.md    # what worked/didn't after each session
    .kb/
      config.json   # { "topic": "...", "created": "YYYY-MM-DD" }
      processed.json  # sources processed so far
```

List existing KBs: `ls "{{KB_ROOT}}/"`

---

## Privacy Rules

Before writing anything, check `privacy` in `~/.cerebro/config.json`:
- `session_recording: false` → don't write to `sessions/`
- `activity_logging: false` → don't write to `activity-history.md`
- `private_by_default: true` → confirm with the user before writing anything

---

## Gotchas

- **`cerebro_home` may contain spaces** — always quote: `"$CEREBRO_HOME"`
- **Never use `~` in file tool paths** — expand to the full absolute path (read from config)
- **activity-history.md is append-only** — find the insertion point, never rewrite the file
- **Session filenames** — `YYYY-MM-DD-HHMMSS-<uuid-prefix>.md`, sort by mtime for latest
- **Memory file path** — read `platforms.<platform>.memory_path` from config; don't guess it
- **Checkin files need YAML frontmatter** — create with the full header if the day's file doesn't exist yet
- **Don't use shell date expansion in tool args** — compute `YYYY-MM-DD` from today's date yourself
