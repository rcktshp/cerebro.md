#!/usr/bin/env python3
"""Cerebro Stop hook — fires when the assistant finishes a response.
Records turn duration and cumulative token usage."""

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


def fmt_time(seconds):
    m, s = divmod(seconds, 60)
    if m > 0:
        return f"{m}m {s}s"
    return f"{s}s"


def fmt_tokens(n):
    if n >= 1000:
        return f"{n / 1000:.1f}k"
    return str(n)


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

    session_id = hook_input.get("session_id", "").strip()
    if not session_id:
        sys.exit(0)

    timer_file = SESSION_MAP / f"{session_id}.timer"
    if not timer_file.exists():
        sys.exit(0)

    # Load timer data
    timer_data = {}
    for line in timer_file.read_text().splitlines():
        if "=" in line:
            key, val = line.split("=", 1)
            try:
                timer_data[key] = int(val) if val else 0
            except ValueError:
                timer_data[key] = 0

    prompt_time = timer_data.get("PROMPT_TIME", 0)
    if not prompt_time:
        sys.exit(0)

    stop_time = int(datetime.now().timestamp())
    accumulated = timer_data.get("ACCUMULATED", 0)
    prompt_count = timer_data.get("PROMPT_COUNT", 0)
    session_start = timer_data.get("SESSION_START", stop_time)

    # Parse transcript for cumulative token usage
    turn_input_tokens = 0
    turn_output_tokens = 0
    turn_cache_read = 0
    turn_cache_write = 0

    transcript_path = hook_input.get("transcript_path", "").strip()
    if transcript_path and os.path.isfile(transcript_path):
        try:
            with open(transcript_path) as f:
                for line in f:
                    try:
                        entry = json.loads(line)
                        if entry.get("type") == "assistant":
                            msg = entry.get("message", {})
                            if isinstance(msg, dict):
                                usage = msg.get("usage", {})
                                turn_input_tokens += usage.get("input_tokens", 0)
                                turn_output_tokens += usage.get("output_tokens", 0)
                                turn_cache_read += usage.get("cache_read_input_tokens", 0)
                                turn_cache_write += usage.get("cache_creation_input_tokens", 0)
                    except (json.JSONDecodeError, AttributeError):
                        continue
        except (PermissionError, OSError):
            pass

    # Compute timing
    turn_duration = stop_time - prompt_time
    new_accumulated = accumulated + turn_duration
    new_count = prompt_count + 1

    # Update timer file
    timer_data.update({
        "PROMPT_TIME": 0,
        "ACCUMULATED": new_accumulated,
        "PROMPT_COUNT": new_count,
        "SESSION_START": session_start,
        "TOTAL_INPUT_TOKENS": turn_input_tokens,
        "TOTAL_OUTPUT_TOKENS": turn_output_tokens,
        "TOTAL_CACHE_READ": turn_cache_read,
        "TOTAL_CACHE_WRITE": turn_cache_write,
    })
    timer_lines = [f"{k}={v}" for k, v in timer_data.items()]
    timer_file.write_text("\n".join(timer_lines) + "\n")

    # Build token annotation
    token_str = ""
    track_tokens = privacy.get("token_tracking", True)
    if track_tokens and (turn_input_tokens > 0 or turn_output_tokens > 0):
        in_fmt = fmt_tokens(turn_input_tokens)
        out_fmt = fmt_tokens(turn_output_tokens)
        cr_fmt = fmt_tokens(turn_cache_read)
        cw_fmt = fmt_tokens(turn_cache_write)
        token_str = f" | Tokens: {in_fmt} in, {out_fmt} out, {cr_fmt} cache-read, {cw_fmt} cache-write"

    turn_fmt = fmt_time(turn_duration)
    total_fmt = fmt_time(new_accumulated)

    # Append to session file
    map_file = SESSION_MAP / session_id
    if map_file.exists():
        session_file_path = map_file.read_text().strip()
        if session_file_path and os.path.isfile(session_file_path):
            annotation = f"\n_Turn {new_count} | {turn_fmt} active{token_str} | Total: {total_fmt}_\n"
            with open(session_file_path, "a") as f:
                f.write(annotation)


if __name__ == "__main__":
    main()
