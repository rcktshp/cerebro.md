# Changelog

## 0.2.0 — 2026-06-25

### New Commands (32 added)

**Capture**
- `til` — "Today I Learned" capture with per-day files and keyword search
- `snippet` — save reusable code snippets with language tagging
- `decision` — ADR-style decision log with interactive capture (context, options, choice, consequences)
- `bookmark` — save URLs and resources with tags and search
- `inbox` — quick-capture triage queue with interactive filing

**Focus**
- `workspace` — named project workspaces with context switching
- `context` — set/show active project for the current session

**Search**
- `find` — richer search with type filters and date ranges
- `query` — natural-language Q&A against your session history
- `tag` — tag management across all content types

**Knowledge**
- `research` — LLM-powered research wiki: ingest sources → wiki pages with `[[wikilinks]]` → health checks → gap detection → query-answers filed back into the wiki so every exploration compounds
- `memory` — inspect and edit the platform memory file directly
- `map` — text-based knowledge map organized by project and type
- `links` — cross-references and orphan detection across content

**Review**
- `digest` — weekly/daily/monthly summary of everything that happened
- `review` — detailed review of a past session or date range
- `changelog` — view or generate a project changelog from decisions and activity
- `flashback` — explicit surface of past entries by date or keyword
- `stats` — usage statistics: sessions, active time, busiest days, streak
- `streaks` — streak tracking with ASCII calendar heatmap

**Session / Capture (continued)**
- `log` — manual session entry for platforms without hooks
- `handoff` — structured handoff doc to resume in a new session or platform
- `standup` — standup update from recent activity, copy-paste ready
- `export` — export all Cerebro data to a portable folder or zip archive

**Automation**
- `template` — create, list, edit, and instantiate reusable markdown templates

**Organization**
- `archive` — move old sessions/notes to dated archive folders (never deletes)
- `fav` — mark sessions, notes, and decisions as favorites

### Planned for v0.3 (honest stubs)
`graph`, `patterns`, `alias`, `watch`, `dedup`, and the full team/collaboration suite (`team`, `join`, `share`, `mention`, `delegate`, `push`, `pull`) — each mode explains what's coming and suggests the best current alternative.

### Other
- **Research mode** (`/cerebro research`) — full wiki pipeline: source ingestion, concept extraction, `[[wikilinks]]`, health checks, gap detection, and query-answer filing. Every exploration compounds the wiki.
- **Skill file** (`src/cerebro-skill.md`) — teaches Claude Code to navigate Cerebro data formats, read session history, capture content, and run commands natively. Installed to `~/.claude/skills/cerebro/SKILL.md`.
- **Version** bumped to 0.2.0

---

## Unreleased

### Added
- **Focus modes** — `goal` (track/complete goals), `blocked` (record/clear blockers), `pin` (pins + date-based reminders), and `checkin` (timestamped daily check-ins); `start` and `end` now read/update these files so the session loop is self-consistent
- **Codex CLI** support — installs the `/cerebro` prompt as plain markdown at `~/.codex/prompts/cerebro.md` (commands-only; manual logging)
- **Gemini CLI** support — installs the command as a TOML wrapper at `~/.gemini/commands/cerebro.toml`, converting `$ARGUMENTS` to `{{args}}` (commands-only; manual logging)
- **Google Antigravity** support — installs as a plugin (`~/.gemini/config/plugins/cerebro/` with `plugin.json` + `skills/cerebro/SKILL.md`); model-activated skill, no plain-text memory file, manual logging

### Fixed
- Gemini CLI is now detected by its top-level `~/.gemini/settings.json` / `GEMINI.md` rather than the `~/.gemini` directory alone, which it shares with Google Antigravity (prevented a false-positive install on Antigravity machines)

---

## 0.1.0 — 2026-03-27

### Initial Release
- Guided onboarding experience (personalization, privacy, platform detection)
- Session recording via hooks (Claude Code)
- Activity history (append-only journal)
- Memory backup and sync
- Token and timing tracking
- Privacy controls (anonymous mode, private sessions, granular consent)
- Multi-platform support (Claude Code, Cursor, Windsurf, Cline)
- Cross-OS support (macOS, Linux, Windows via Python hooks)
- Self-update mechanism (`/cerebro update`)
- Slash commands: start, end, note, search, today, status, profile, help
- Clean uninstall (`/cerebro uninstall`)
