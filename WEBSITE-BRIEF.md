# CEREBRO.md — Website Brief

Use this brief to build the landing page in Cursor. Inspired by [agents.md](https://agents.md) — clean, dark, developer-focused, single-page, content-driven.

---

## Design Direction

- **Dark theme** with a code-editor aesthetic (like agents.md)
- Monospace code blocks for showing Cerebro commands and config
- Clean single-page layout — no flashy animations, emphasis on content and credibility
- Developer-focused branding — conversational, confident, not corporate
- Mobile-responsive
- **Tech stack:** Next.js + Tailwind CSS, deploy on Vercel

---

## Page Structure

### 1. Hero

**Title:** CEREBRO.md

**Tagline:** "Your AI assistant's memory — a persistent knowledge system that works across every coding agent."

**Description:** "Every AI session starts from scratch. Cerebro fixes that. It records your sessions, captures your knowledge, and loads your context automatically — so your AI picks up right where you left off."

**CTAs:**
- "Get Started" → anchor to #install
- "View on GitHub" → repo link

**Visual:** A code block mockup showing a `/cerebro start` session:
```
$ /cerebro start

Hey Diego! Welcome back.

Health Check       ✓ All systems go
Last Session       Yesterday — built Cerebro onboarding flow
Streak             3 days
Pinned             Deploy staging by Friday
Reminder (due)     Review PR #42

Recent Activity:
  • 2026-03-27 — Built Cerebro install system, hooks, onboarding
  • 2026-03-26 — Designed platform-agnostic architecture
  • 2026-03-25 — Figma-to-code workflow with MCP

What would you like to work on today?
```

---

### 2. "Why CEREBRO.md?" Section

**Heading:** Why Cerebro?

Three columns:

**Context that persists**
Your AI assistant forgets everything between sessions. Cerebro doesn't. Every session summary, decision, and note is saved and searchable — across days, weeks, months.

**Works across every tool**
Not locked into one platform. Cerebro installs into Claude Code, Cursor, Windsurf, and Cline. One memory, everywhere you work.

**You own your data**
100% local. No cloud. No accounts. No tracking. Your data lives on your machine in plain markdown files. Export everything, delete everything, go anonymous — anytime.

---

### 3. "One Cerebro works across many agents" Section

**Heading:** One memory across every AI coding assistant

Logo grid/carousel (similar to agents.md ecosystem section):
- Claude Code
- Cursor
- Windsurf
- Cline

Note: "Full hook support on Claude Code. Slash commands work on all platforms. More platforms coming soon."

---

### 4. Features Section

**Heading:** Everything you need to never lose context again

Feature cards (icon + title + short description):

| Feature | Description |
|---------|-------------|
| **Session Recording** | Automatically logs every prompt and response. Know exactly what you worked on, when, and for how long. |
| **Activity History** | An append-only journal across all sessions. Never lose track of what you did last Tuesday. |
| **Knowledge Capture** | Notes, decisions, code snippets, TILs — all searchable, taggable, and linked. |
| **Smart Start** | Every session begins with context. Recent activity, reminders, goals, and pinned items — all surfaced automatically. |
| **Privacy Controls** | Anonymous mode, private sessions, granular consent, full data export, one-click delete. |
| **Token Tracking** | Know exactly how many tokens each session uses. Track costs across projects. |
| **Daily Dashboard** | `/cerebro today` — everything from today in one view: notes, sessions, reminders, goals. |
| **Team Collaboration** | Share decisions, hand off context, generate standups. Self-hosted via git. |

---

### 5. "How It Works" Section

**Heading:** Get started in 2 minutes

4-step visual flow (similar to agents.md's how-to section):

**Step 1: Install**
```bash
git clone https://github.com/rcktshp/cerebro.md.git
cd cerebro.md && bash install.sh
```
Copies hooks and the slash command to all detected AI platforms.

**Step 2: Onboard**
```
/cerebro
```
Cerebro walks you through setup — your name, preferences, privacy settings, storage location. Personalized to you.

**Step 3: Work**
Cerebro records your sessions automatically in the background. Capture notes, decisions, and snippets as you go with quick commands.

**Step 4: Remember**
```
/cerebro start
```
Every session begins with your full context. Recent activity, reminders, goals, and knowledge — loaded automatically.

---

### 6. Commands Section

**Heading:** 45+ commands for your entire workflow

Grouped command table (collapsible or tabbed):

| Category | Commands |
|----------|----------|
| **Session** | `start` `end` `private` `log` |
| **Capture** | `note` `til` `snippet` `decision` `inbox` `bookmark` `pin` |
| **Focus** | `goal` `blocked` `checkin` `workspace` `context` |
| **Search** | `search` `find` `query` `tag` |
| **Knowledge** | `memory` `map` `graph` `links` |
| **Review** | `today` `digest` `review` `changelog` `flashback` `stats` `streaks` `patterns` |
| **Collaboration** | `team` `join` `share` `handoff` `standup` `mention` `delegate` `push` `pull` |
| **Automation** | `template` `alias` `watch` |
| **System** | `status` `profile` `consent` `privacy` `clean` `update` `setup` `uninstall` `export` |

All commands invoked as `/cerebro <command>`.

---

### 7. Example Section

**Heading:** See it in action

Show a realistic session transcript with annotations:

```markdown
# Session: 2026-03-27 14:30:22

**Model**: claude-opus-4-6
**Session ID**: a1b2c3

---

### 14:30:22

/cerebro start

### 14:30:25

Hey Diego! Welcome back. You're on a 5-day streak.

Pinned: Deploy staging by Friday
Reminder (due today): Review PR #42

Recent activity:
  • Yesterday — Built session recording hooks
  • 2 days ago — Designed Cerebro architecture

What would you like to work on today?

_Turn 1 | 3s active | Tokens: 2.1k in, 0.8k out | Total: 3s_

### 14:30:30

Let's work on the install script

### 14:45:12

_Turn 2 | 14m 42s active | Tokens: 45.2k in, 12.1k out | Total: 14m 45s_
```

---

### 8. Privacy Section

**Heading:** Your data. Your rules.

Bullet points with icons:

- **100% local** — No cloud, no accounts, no telemetry. Plain markdown files on your machine.
- **Opt-in everything** — You choose what Cerebro tracks during onboarding. Change anytime.
- **Private sessions** — `/cerebro private` — zero logging, zero trace.
- **Anonymous mode** — Strip your identity from all content.
- **Full export** — `/cerebro privacy export` — download everything.
- **Nuclear option** — `/cerebro privacy delete-all` — wipe it all.
- **Open source** — Read the code. Verify every claim.

---

### 9. Storage Section

**Heading:** Lightweight. No dependencies. Just files.

```
~/.cerebro/           → Config, hooks, session map (~15 KB)
~/Cerebro/            → Sessions, notes, history, knowledge

No databases. No background processes. No daemons.
No npm install. No pip install. Just Python 3.
```

Stats bar:
- **~15 KB** install footprint
- **Python 3** only dependency
- **macOS, Linux, Windows** supported
- **0** background processes

---

### 10. Pricing Section

**Heading:** Free forever. Pay for team power.

Three cards:

**Free (Open Source)**
- All personal features
- Unlimited sessions & storage
- All platforms supported
- Self-hosted team collaboration
- Community support
- **$0 forever**
- CTA: "Install Now"

**Team** *(Coming Soon)*
- Hosted team hub
- Cloud sync across devices
- Web dashboard with analytics
- Slack, Linear, Jira integrations
- Priority support
- **$12/user/month**
- CTA: "Join Waitlist"

**Enterprise** *(Coming Soon)*
- Everything in Team
- SSO & audit logs
- Dedicated support
- Custom integrations
- **Contact us**
- CTA: "Get in Touch"

---

### 11. Install CTA (bottom)

**Heading:** Get started in 2 minutes

```bash
git clone https://github.com/rcktshp/cerebro.md.git
cd cerebro.md && bash install.sh
```

Then type `/cerebro` in your AI assistant.

---

### 12. Footer

```
Created by Diego Martins (diegomartins.com)
Copyright (c) 2026 CEREBRO.md by Martins LLC dba Rocketship
For website terms of use, trademark policy, and other project policies,
see rocketship.xyz

GitHub · Changelog · Docs
```

---

## Brand Guidelines

- **Tone:** Conversational, confident, developer-friendly. Like talking to a sharp colleague, not reading a sales page.
- **Not:** Corporate, salesy, buzzword-heavy. No "revolutionary," "game-changing," or "AI-powered" (ironic, yes).
- **Voice:** "We built this because we needed it. You probably do too."
- **Colors:** Dark background (editor-like), accent color for CTAs and highlights. Suggest deep navy/charcoal with a warm accent (amber, teal, or electric blue).
- **Typography:** Monospace for code blocks and commands. Clean sans-serif (Inter, Geist) for body text.
- **Logo:** CEREBRO.md in monospace, styled like a filename.

---

## Technical Notes for Cursor Build

- **Framework:** Next.js (App Router)
- **Styling:** Tailwind CSS
- **Deploy:** Vercel
- **Single page** to start — all sections on one scrollable page
- **SEO:** meta title "CEREBRO.md — Your AI Assistant's Memory", description from the tagline
- **OG image:** Dark card with "CEREBRO.md" in monospace + tagline
- **Favicon:** Monospace "C" or brain icon, dark/light variants
- **Analytics:** None initially (practice what we preach on privacy)
- **Domain:** cerebro.md (if available) or via rocketship.xyz
