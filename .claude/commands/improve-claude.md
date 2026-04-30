# /improve-claude

Run one cycle of the Claude Code self-improvement loop:

1. **Audit** — invoke `claude-config-auditor` to scan `.claude/` and `CLAUDE.md`. New improvement candidates are appended to `.claude/work/output/claude_setup_backlog.md`.

2. **Pick** — read the backlog. If no `[ ]` items remain, print "Backlog is empty — nothing to do." and stop.

3. **Implement** — invoke `claude-config-implementer` with the highest-priority `[ ]` item. It applies the change, validates, and marks the item `[x]`.

4. **Commit** — stage and commit the changed files:
   ```bash
   git add .claude/ CLAUDE.md
   git commit -m "chore(claude): <one-line description of the applied item>"
   ```
   The existing PreToolUse hook runs `flutter analyze + test` as a gate before the commit lands.
   If the hook fails, do NOT force — investigate and fix the underlying issue, or mark the item `[blocked]`.

5. **Update commit hash** — after a successful commit, patch the backlog entry's `**コミット**:` line with the actual hash from `git rev-parse --short HEAD`.

6. **Report**:
   ```
   /improve-claude complete
   Applied: <ID> — <title>
   Commit: <hash>
   Remaining backlog: N 未着手 items
   ```

## Notes

- One item per invocation. Run `/improve-claude` again to apply the next item.
- The loop intentionally stops after one commit to keep diffs small and reviewable.
- If you want to refresh the backlog without applying anything, invoke `claude-config-auditor` directly.
- Do not use `/improve-claude` to implement game-code changes — that is `feature-implementer`'s domain.
