#!/usr/bin/env python3
"""Mechanical Claude config auditor.

Invoked by PostToolUse hook after git commit. Appends new improvement
candidates to .claude/work/output/claude_setup_backlog.md with sig-based
dedupe so the same issue is never reported twice.

Checks:
  1. JSON validity of settings*.json
  2. lib/ and test/ paths cited in agents/*.md and CLAUDE.md exist
  3. file.dart:NNN line-number references are within file bounds

Does NOT call Claude, does NOT modify any file except the backlog.
Exits 0 always (hook must not block a completed commit).
"""

import json
import re
import sys
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BACKLOG = ROOT / ".claude/docs/claude_setup_backlog.md"
TODAY = date.today().isoformat()

PATH_RE = re.compile(r"\b((?:lib|test)/[\w/.-]+\.dart)\b")
LINE_RE = re.compile(r"`?((?:lib|test)/[\w/.-]+\.dart):(\d+)`?")


def read_backlog():
    return BACKLOG.read_text() if BACKLOG.exists() else ""


def existing_sigs(text):
    return set(re.findall(r"<!-- sig:([^\s>]+)\s*-->", text))


def next_id(text, prefix):
    nums = [int(m) for m in re.findall(rf"### {prefix}-(\d+)", text)]
    return f"{prefix}-{(max(nums) if nums else 0) + 1:03d}"


def make_entry(id_, title, kind, target, priority, reason, proposal, sig):
    return (
        f"\n### {id_}: {title}\n"
        f"- **種別**: {kind}\n"
        f"- **対象ファイル**: `{target}`\n"
        f"- **優先度**: {priority}\n"
        f"- **理由**: {reason}\n"
        f"- **提案**: {proposal}\n"
        f"- **状態**: [ ]\n"
        f"- **作成日**: {TODAY}\n"
        f"<!-- sig:{sig} -->\n"
    )


def insert_entry(text, entry):
    # Insert before "## 完了" section
    marker = "## 完了"
    if marker in text:
        return text.replace(marker, entry + marker, 1)
    return text + entry


def main():
    backlog_text = read_backlog()
    if not BACKLOG.exists():
        print("Backlog file not found — skipping audit.", file=sys.stderr)
        return

    sigs = existing_sigs(backlog_text)
    added = []

    def maybe_add(prefix, title, kind, target, priority, reason, proposal, sig):
        nonlocal backlog_text
        if sig in sigs:
            return
        sigs.add(sig)
        id_ = next_id(backlog_text, prefix)
        entry = make_entry(id_, title, kind, target, priority, reason, proposal, sig)
        backlog_text = insert_entry(backlog_text, entry)
        added.append(id_)

    # --- Check 1: JSON validity ---
    for sf in ["settings.json", "settings.local.json"]:
        p = ROOT / ".claude" / sf
        if not p.exists():
            continue
        try:
            json.loads(p.read_text())
        except json.JSONDecodeError as e:
            rel = str(p.relative_to(ROOT))
            maybe_add(
                "CFG", f"JSON 構文エラー: {sf}",
                "settings", rel, "高",
                f"JSON parse 失敗 — {e}",
                "ファイルを修正してから flutter analyze を実行",
                f"json-invalid:{sf}",
            )

    # --- Check 2: lib/ and test/ paths cited in agents and CLAUDE.md ---
    sources = list((ROOT / ".claude/agents").glob("*.md"))
    claude_md = ROOT / "CLAUDE.md"
    if claude_md.exists():
        sources.append(claude_md)

    for src in sources:
        content = src.read_text()
        for path_str in set(PATH_RE.findall(content)):
            if not (ROOT / path_str).exists():
                prefix = "DOC" if src.name == "CLAUDE.md" else "AGT"
                rel_src = str(src.relative_to(ROOT))
                maybe_add(
                    prefix,
                    f"{src.name} が参照する `{path_str}` が存在しない",
                    "doc" if prefix == "DOC" else "agent",
                    rel_src, "高",
                    f"Stale path reference: {path_str}",
                    f"`{path_str}` への参照を更新または削除",
                    f"missing-path:{src.name}:{path_str}",
                )

    # --- Check 3: file.dart:NNN line-number range check ---
    for src in sources:
        content = src.read_text()
        prefix = "DOC" if src.name == "CLAUDE.md" else "AGT"
        rel_src = str(src.relative_to(ROOT))
        for path_str, line_str in set(LINE_RE.findall(content)):
            target = ROOT / path_str
            if not target.exists():
                continue  # Already flagged in check 2
            try:
                total_lines = len(target.read_text().splitlines())
                cited = int(line_str)
                if cited < 1 or cited > total_lines:
                    maybe_add(
                        prefix,
                        f"{src.name} の `{path_str}:{cited}` が範囲外 (最大 {total_lines} 行)",
                        "doc" if prefix == "DOC" else "agent",
                        rel_src, "中",
                        f"行番号 {cited} はファイルの範囲外 (現在 {total_lines} 行)",
                        f"`{path_str}:{cited}` を正しい行番号またはシンボル名に修正",
                        f"line-out-of-range:{src.name}:{path_str}:{cited}",
                    )
            except (ValueError, OSError):
                pass

    # --- Write backlog if changed ---
    if added:
        BACKLOG.write_text(backlog_text)
        print(f"Audit: {len(added)} new candidate(s) added — {', '.join(added)}")
    else:
        print("Audit complete — no new candidates.")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"audit-config.py error: {e}", file=sys.stderr)
        sys.exit(0)
