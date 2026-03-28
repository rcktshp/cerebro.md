#!/usr/bin/env python3
"""Cerebro UserPromptSubmit hook — logs every user prompt to a per-session file."""

import json
import os
import sys
from datetime import datetime
from pathlib import Path

CEREBRO_CONFIG = Path.home() / ".cerebro" / "config.json"
SESSION_MAP = Path.home() / ".cerebro" / "session-map"


def load_config():
    try:
        with open(CEREBRO_CONFIG) as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return None


def main():
    # Read hook JSON from stdin
    try:
        hook_input = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        sys.exit(0)

    config = load_config()
    if not config:
        sys.exit(0)

    # Check privacy settings
    privacy = config.get("privacy", {})
    if not privacy.get("session_recording", True):
        sys.exit(0)
    if privacy.get("private_by_default", False):
        sys.exit(0)

    cerebro_home = Path(os.path.expanduser(config.get("cerebro_home", "~/Cerebro")))
    sessions_dir = cerebro_home / "sessions"
    sessions_dir.mkdir(parents=True, exist_ok=True)
    SESSION_MAP.mkdir(parents=True, exist_ok=True)

    # Extract session_id
    session_id = hook_input.get("session_id", "").strip()
    if not session_id:
        sys.exit(0)

    # Extract prompt text
    prompt = hook_input.get("prompt", hook_input.get("message", hook_input.get("content", "")))
    if isinstance(prompt, list):
        parts = []
        for item in prompt:
            if isinstance(item, dict):
                parts.append(item.get("text", ""))
            elif isinstance(item, str):
                parts.append(item)
        prompt = " ".join(parts)
    prompt = str(prompt).strip()
    if not prompt:
        sys.exit(0)

    map_file = SESSION_MAP / session_id
    timer_file = SESSION_MAP / f"{session_id}.timer"
    now = datetime.now()
    timestamp_epoch = int(now.timestamp())

    if not map_file.exists():
        # First prompt — create session file
        timestamp_str = now.strftime("%Y-%m-%d-%H%M%S")
        short_id = session_id[:6]
        session_filename = f"{timestamp_str}-{short_id}.md"
        session_file = sessions_dir / session_filename

        # Resolve model
        model = hook_input.get("model", "").strip()
        if not model:
            try:
                settings_path = config.get("settings_path", "")
                if settings_path:
                    with open(os.path.expanduser(settings_path)) as f:
                        settings = json.load(f)
                    model = settings.get("model", "unknown")
            except Exception:
                model = "unknown"

        # Write session header
        header = (
            f"---\n"
            f"type: session\n"
            f"created: {now.strftime('%Y-%m-%dT%H:%M:%S')}\n"
            f"model: {model}\n"
            f"session_id: {session_id}\n"
            f"tags: []\n"
            f"project: \n"
            f"---\n\n"
            f"# Session: {now.strftime('%Y-%m-%d %H:%M:%S')}\n\n"
            f"**Model**: {model}\n"
            f"**Session ID**: {session_id}\n"
            f"Auto-logged by Cerebro.\n\n"
            f"---\n"
        )
        session_file.write_text(header)
        map_file.write_text(str(session_file))

        # Initialize timer
        timer_data = {
            "PROMPT_TIME": timestamp_epoch,
            "ACCUMULATED": 0,
            "PROMPT_COUNT": 0,
            "SESSION_START": timestamp_epoch,
            "TOTAL_INPUT_TOKENS": 0,
            "TOTAL_OUTPUT_TOKENS": 0,
            "TOTAL_CACHE_READ": 0,
            "TOTAL_CACHE_WRITE": 0,
        }
    else:
        # Load existing timer
        timer_data = {}
        if timer_file.exists():
            for line in timer_file.read_text().splitlines():
                if "=" in line:
                    key, val = line.split("=", 1)
                    try:
                        timer_data[key] = int(val) if val else 0
                    except ValueError:
                        timer_data[key] = 0
        timer_data["PROMPT_TIME"] = timestamp_epoch
        if "SESSION_START" not in timer_data:
            timer_data["SESSION_START"] = timestamp_epoch

    # Write timer file
    timer_lines = [f"{k}={v}" for k, v in timer_data.items()]
    timer_file.write_text("\n".join(timer_lines) + "\n")

    # Append prompt to session file
    session_file_path = map_file.read_text().strip()
    if session_file_path and os.path.isfile(session_file_path):
        include_prompts = privacy.get("include_prompts_in_sessions", True)
        time_str = now.strftime("%H:%M:%S")
        if include_prompts:
            entry = f"\n### {time_str}\n\n{prompt}\n"
        else:
            entry = f"\n### {time_str}\n\n_[prompt recorded but hidden per privacy settings]_\n"
        with open(session_file_path, "a") as f:
            f.write(entry)


if __name__ == "__main__":
    main()
