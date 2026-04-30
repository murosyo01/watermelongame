# Claude Code セットアップ改善計画

作成日: 2026-04-30

---

## 実施項目一覧

| # | 対象 | 状態 |
|---|------|------|
| 1 | フック修正（PreToolUse 化、analyze + test の統合） | [x] |
| 2 | 許可リスト拡充（settings.local.json） | [x] |
| 3 | CLAUDE.md にテストパターン追記 | [x] |
| 4 | `test-writer` エージェント追加 | [x] |
| 5 | `feature-implementer` エージェント追加 | [x] |
| 6 | `/simplify` スキルの活用方針をCLAUDE.mdに記載 | [x] |
| 7 | `/schedule` 活用方針をCLAUDE.mdに記載 | [x] |

---

## 詳細

### 1. フック修正（PreToolUse 化）

**ファイル**: `.claude/settings.json`

**問題**: 現在の設定は `PostToolUse` + `if: "Bash(git commit *)"` という非標準な組み合わせ。
`if` フィールドは Claude Code の hook では `matcher` で代替できるため冗長。
また `PostToolUse` ではコミット後にテストが走るため失敗してもコミットを止められない。

**修正後**:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash(git commit*)",
        "hooks": [
          {
            "type": "command",
            "command": "flutter analyze --no-fatal-infos && flutter test --no-pub 2>&1",
            "timeout": 120,
            "statusMessage": "analyze + test を実行中..."
          }
        ]
      }
    ]
  }
}
```

---

### 2. 許可リスト拡充

**ファイル**: `.claude/settings.local.json`

**問題**: `flutter test *` しか許可されておらず、`flutter analyze`・`flutter run`・`flutter pub` などを使うたびに確認プロンプトが出る。

**修正後**:
```json
{
  "permissions": {
    "allow": [
      "Bash(flutter test *)",
      "Bash(flutter analyze *)",
      "Bash(flutter run *)",
      "Bash(flutter pub *)",
      "Bash(dart format *)"
    ]
  }
}
```

---

### 3. CLAUDE.md テストパターン追記

**ファイル**: `CLAUDE.md`

`flame_test` の `testWithGame` 使用パターンと、既存テストのパスを明記する。
また `.claude/work/output/improvement_proposals.md` への参照を追加する。

---

### 4. test-writer エージェント

**ファイル**: `.claude/agents/test-writer.md`

Flame の `testWithGame` / `testWithFlameGame` を使ったテストを書くことに特化したエージェント。
マージフロー・衝突判定・ゲームオーバーのテストケースに詳しい。

---

### 5. feature-implementer エージェント

**ファイル**: `.claude/agents/feature-implementer.md`

`.claude/work/output/improvement_proposals.md` の改善案を 1 件ずつ実装するエージェント。
改善案の優先度・難易度を把握した上で、安全に実装する。

---

### 6. /simplify スキル活用方針

改善実装後に `/simplify` を呼ぶことで、追加コードの品質チェック・重複排除を自動化する。
特に Paint キャッシュ化・Set<Fruit> 管理などの実装後に有効。

---

### 7. /schedule 活用方針

improvement_proposals.md の未実装改善案が残った場合、`/schedule` で定期的に拾い上げる
エージェントを設定する。例: 「1 週間後に未実装案をまとめて PR 作成」。
