# Changelog

## Unreleased

### Added
- **Focus modes** — `goal` (track/complete goals), `blocked` (record/clear blockers), `pin` (pins + date-based reminders), and `checkin` (timestamped daily check-ins); `start` and `end` now read/update these files so the session loop is self-consistent
- **Codex CLI** support — installs the `/cerebro` prompt as plain markdown at `~/.codex/prompts/cerebro.md` (commands-only; manual logging)
- **Gemini CLI** support — installs the command as a TOML wrapper at `~/.gemini/commands/cerebro.toml`, converting `$ARGUMENTS` to `{{args}}` (commands-only; manual logging)
- **Google Antigravity** support — installs as a plugin (`~/.gemini/config/plugins/cerebro/` with `plugin.json` + `skills/cerebro/SKILL.md`); model-activated skill, no plain-text memory file, manual logging

### Fixed
- Gemini CLI is now detected by its top-level `~/.gemini/settings.json` / `GEMINI.md` rather than the `~/.gemini` directory alone, which it shares with Google Antigravity (prevented a false-positive install on Antigravity machines)

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
