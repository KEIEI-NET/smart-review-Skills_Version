# Smart Review System - 実装プロジェクト

*このプロジェクトは Claude.ai Web での設計を Claude Code CLI で実装するものです*

## 📋 プロジェクト概要

**目的**: 複数の専門Skillsによる包括的コードレビューシステムの構築

**採用アプローチ**: ハイブリッド方式（Skills + スラッシュコマンドオーケストレーション）

**理由**:
- トークン効率: 差分レビューで56%削減
- 制御性: 実行順序を保証
- 学習効果: 長期的なナレッジ蓄積
- スケーラビリティ: Skillの追加が容易

## 📚 設計ドキュメント

以下のドキュメントを必ず参照してください：

### 1. docs/subagents-vs-skills-comparison.md
- Subagents vs Skills の詳細比較
- トークン消費の実測シミュレーション
- ハイブリッドアプローチの提案

### 2. docs/smart-review-implementation-plan.md  
- 4週間の実装スケジュール
- 各Skillの詳細仕様
- テスト計画

### 3. docs/smart-review-subagent-approach.md
- Subagentsベースの代替案
- 元のアーキテクチャとの対応

## 🎯 現在のタスク

**Phase 1 - Week 1: Security Skillのプロトタイプ作成**

以下を実装してください：

1. ディレクトリ構造の作成
2. smart-review-security Skillの実装
3. patterns.jsonの作成
4. smart-review.md（オーケストレーター）の実装
5. 動作検証

## 🏗️ 実装する構造

```
smart-review-system/
├── .claude/
│   ├── commands/
│   │   └── smart-review.md       # オーケストレーター
│   ├── skills/
│   │   └── smart-review-security/
│   │       ├── SKILL.md
│   │       ├── patterns.json
│   │       └── cwe-mapping.json
│   └── CLAUDE.md                 # このファイル
├── docs/                         # 設計ドキュメント
│   ├── subagents-vs-skills-comparison.md
│   ├── smart-review-implementation-plan.md
│   └── smart-review-subagent-approach.md
├── test/                         # テスト用サンプル
│   └── vulnerable-sample.js
└── README.md
```

## 📝 実装の指針

### smart-review-security Skill の要件

**SKILL.md の必須要素：**

```markdown
---
name: "smart-review-security"
description: "セキュリティ脆弱性を検出します。XSS、SQLインジェクション、コマンドインジェクション、認証・認可の問題、機密情報の露出などを分析する際に使用してください。"
---

# Security Analysis Skill

## 概要
コードのセキュリティ脆弱性を包括的に分析します。

## 検出対象
1. XSS (CWE-79)
2. SQLインジェクション (CWE-89)
3. コマンドインジェクション (CWE-78)
4. 認証・認可の問題
5. 機密情報の露出

## 出力形式
JSON形式で以下の構造を返してください：

{
  "skill": "smart-review-security",
  "issuesFound": 数値,
  "issues": [
    {
      "severity": "critical|high|medium|low",
      "type": "XSS|SQLi|CommandInjection|...",
      "file": "ファイルパス",
      "line": 行番号,
      "description": "問題の説明",
      "recommendation": "修正推奨",
      "autoFixable": true/false
    }
  ]
}
```

### patterns.json の構造

```json
{
  "xss": [
    {
      "pattern": "innerHTML\\s*=",
      "description": "innerHTML への直接代入",
      "severity": "high",
      "cwe": "CWE-79"
    }
  ],
  "sqli": [
    {
      "pattern": "SELECT.*\\+.*\\+",
      "description": "文字列連結によるSQLクエリ",
      "severity": "critical",
      "cwe": "CWE-89"
    }
  ]
}
```

### smart-review.md（オーケストレーター）

```markdown
---
description: 包括的コードレビュー（Security Skillのテスト版）
---

# Smart Review - Security Analysis Only

このコマンドは現在、Security Skillのみをテストします。

## 実行指示

[smart-review-security Skillを使用]

以下のファイルを分析してください：
- 対象: test/vulnerable-sample.js
- 出力: JSON形式

分析完了後、検出された問題をMarkdown形式で整形して表示してください。
```

## 🧪 テストサンプル

`test/vulnerable-sample.js` を作成し、以下の既知の脆弱性を含めてください：

1. XSS: innerHTML への直接代入
2. SQLインジェクション: 文字列連結
3. eval() の使用
4. ハードコードされたパスワード

## ✅ 成功条件

Phase 1 完了時に以下が動作すること：

```bash
# Claude Codeで実行
claude

> /smart-review

# 期待される出力:
# - test/vulnerable-sample.js を分析
# - 4件程度の脆弱性を検出
# - JSON形式で結果を出力
# - 修正推奨を提示
```

## 🔄 次のフェーズ

Phase 1が完了したら、以下を実装：

**Phase 2**: smart-review-debug Skill
**Phase 3**: smart-review-quality, smart-review-docs Skills
**Phase 4**: 統合テスト、レポート生成

## 💡 実装のヒント

### Skillの動作確認

```bash
# Skillが認識されているか確認
claude --debug

# SKILL.md が正しく読み込まれているかログで確認
```

### patterns.json の参照方法

SKILL.md内で以下のように参照：

```markdown
## 検出パターン

詳細なパターン定義は同じディレクトリの `patterns.json` を参照してください。

[Code Execution Tool を使用して patterns.json を読み込み]
```

### JSON出力の保証

Skillに以下を明記：

```markdown
## 重要な出力ルール

**必ず以下の形式で出力してください**：

\`\`\`json
{
  "skill": "smart-review-security",
  ...
}
\`\`\`

他の説明文は出力の後に追加してください。
```

## 🐛 トラブルシューティング

### Skillが起動しない
- description に適切なキーワードが含まれているか確認
- SKILL.md の YAML フロントマターが正しいか確認

### パターンマッチングが動作しない
- patterns.json が正しいJSON形式か確認
- 正規表現のエスケープを確認（`\\` など）

### 出力形式が不安定
- SKILL.md で出力形式を明確に指定
- 例を複数提示

## 📞 サポート

実装中に不明点があれば、以下を確認：

1. **設計ドキュメント**: docs/ 配下の3つのファイル
2. **Claude Code公式ドキュメント**: https://docs.claude.com/en/docs/claude-code
3. **デバッグモード**: `claude --debug` で詳細ログ

## 🎉 期待される成果

Phase 1完了時：

- ✅ 動作するSecurity Skill
- ✅ パターンベースの脆弱性検出
- ✅ JSON形式の構造化出力
- ✅ オーケストレーション機構の検証
- ✅ 次のフェーズへの基盤確立

---

**重要**: このCLAUDE.mdは、Claude.ai Webでの設計セッションからの引き継ぎドキュメントです。
設計の意図や背景は docs/ 配下のドキュメントを参照してください。

*作成日: 2025年11月17日*
*引き継ぎ元: Claude.ai Web セッション*
