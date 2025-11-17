# Smart Review System - 全Skillsサマリー

*4つの専門Skillsの完全な実装ガイド*

## 🎯 含まれる全Skills

### 1. smart-review-security (Critical)

**検出対象：**
- XSS (CWE-79)
- SQLインジェクション (CWE-89)
- コマンドインジェクション (CWE-78)
- 認証・認可の問題
- 機密情報の露出

**ファイル構成：**
```
.claude/skills/smart-review-security/
├── SKILL.md              # 本体（2000トークン）
├── patterns.json         # 検出パターン定義
└── cwe-mapping.json      # CWEマッピング
```

**実装状況：** 📝 詳細仕様あり（実装待ち）

---

### 2. smart-review-debug (High)

**検出対象：**
- null/undefined参照
- 型の不一致
- ロジックエラー
- 例外処理の不備
- メモリリーク
- レースコンディション

**ファイル構成：**
```
.claude/skills/smart-review-debug/
├── SKILL.md              # 本体
├── checklist.md          # デバッグチェックリスト
└── common-patterns.json  # 一般的なバグパターン
```

**実装状況：** 📝 詳細仕様あり（実装待ち）

---

### 3. smart-review-quality (Medium)

**検出対象：**
- 循環的複雑度
- コードスメル
- 設計原則違反（SOLID、DRY）
- 命名規則
- 保守性の問題

**ファイル構成：**
```
.claude/skills/smart-review-quality/
├── SKILL.md              # 本体
├── metrics.json          # 品質メトリクス定義
└── code-smells.json      # コードスメルパターン
```

**実装状況：** 📝 詳細仕様あり（実装待ち）

---

### 4. smart-review-docs (Low)

**検出対象：**
- JSDoc/TSDoc の完全性
- インラインコメントの適切性
- README/使用方法ドキュメント
- 型定義の明確性
- 例の提供

**ファイル構成：**
```
.claude/skills/smart-review-docs/
├── SKILL.md              # 本体
└── templates/            # ドキュメントテンプレート
    ├── jsdoc-template.md
    └── readme-template.md
```

**実装状況：** 📝 詳細仕様あり（実装待ち）

---

## 🏗️ 完成時の全体構造

```
smart-review-system/
├── .claude/
│   ├── commands/
│   │   ├── smart-review.md          # 全Skills統合版
│   │   ├── review-changes.md        # 差分レビュー
│   │   ├── review-security.md       # セキュリティのみ
│   │   ├── review-debug.md          # デバッグのみ
│   │   ├── review-quality.md        # 品質のみ
│   │   └── review-docs.md           # ドキュメントのみ
│   ├── skills/
│   │   ├── smart-review-security/   # ✅ Skill 1
│   │   │   ├── SKILL.md
│   │   │   ├── patterns.json
│   │   │   └── cwe-mapping.json
│   │   ├── smart-review-debug/      # ✅ Skill 2
│   │   │   ├── SKILL.md
│   │   │   ├── checklist.md
│   │   │   └── common-patterns.json
│   │   ├── smart-review-quality/    # ✅ Skill 3
│   │   │   ├── SKILL.md
│   │   │   ├── metrics.json
│   │   │   └── code-smells.json
│   │   └── smart-review-docs/       # ✅ Skill 4
│   │       ├── SKILL.md
│   │       └── templates/
│   └── CLAUDE.md
├── docs/
│   ├── smart-review-implementation-plan.md    # 全Skillsの詳細仕様
│   ├── subagents-vs-skills-comparison.md
│   ├── smart-review-subagent-approach.md
│   └── handoff-guide.md
├── test/
│   ├── vulnerable-sample.js         # Security用
│   ├── buggy-sample.js              # Debug用
│   ├── complex-sample.js            # Quality用
│   └── undocumented-sample.js       # Docs用
└── README.md
```

## 📊 実装アプローチの比較

### アプローチ A: 段階的実装（4週間）

```
Week 1: Security Skill 実装 → テスト → 改善
Week 2: Debug Skill 実装 → テスト → 統合
Week 3: Quality & Docs Skills 実装 → テスト
Week 4: 全体統合 → レポート生成 → 完成
```

**メリット：**
- 各Skillを確実に動作させる
- 問題を早期発見
- 段階的な学習

**デメリット：**
- 完成まで時間がかかる
- 全体像の把握に時間がかかる

### アプローチ B: 並行実装（2週間）

```
Week 1: 
  - 全4つのSkillsの基本実装
  - 各Skillの基本動作確認

Week 2:
  - 各Skillの詳細実装
  - 統合テスト
  - レポート生成
```

**メリット：**
- 早期に全体完成
- 最初から統合を意識
- Skillsの相互関係を理解しやすい

**デメリット：**
- デバッグが複雑
- どこに問題があるか特定しにくい

### アプローチ C: MVP → 拡張（推奨）

```
Phase 1 (3日):
  - Security Skill のみ完全実装
  - 動作確認・改善
  - patterns.json の充実

Phase 2 (3日):
  - Debug Skill 実装
  - 2つのSkillsの統合動作確認

Phase 3 (4日):
  - Quality & Docs Skills 実装
  - 全Skillsの統合

Phase 4 (4日):
  - レポート生成
  - 自動修正機能
  - ドキュメント整備
```

**メリット：**
- MVP（最小限の機能）を早期に完成
- 段階的な拡張
- 問題の早期発見と修正

## 🎯 実装優先度

### 必須（Phase 1-2）
1. ✅ **Security Skill** - 最優先
2. ✅ **Debug Skill** - 次点で重要

### 推奨（Phase 3）
3. ⭐ **Quality Skill** - 長期的な価値
4. ⭐ **Docs Skill** - 保守性向上

### オプション（Phase 4以降）
5. 🔧 自動修正機能
6. 📊 HTMLレポート生成
7. 📈 メトリクストレンド分析

## 💡 Claude Codeでの実装指示例

### 全Skillsを一度に実装

```
全4つのSkills（security, debug, quality, docs）を実装してください。

各Skillの詳細仕様は以下を参照：
@docs/smart-review-implementation-plan.md

実装後、以下のテストファイルで動作確認：
- test/vulnerable-sample.js（Security用）
- test/buggy-sample.js（Debug用）
- test/complex-sample.js（Quality用）
- test/undocumented-sample.js（Docs用）

各Skillが正しく動作することを確認してください。
```

### 段階的に実装

```
まず smart-review-security Skill のみを完全に実装してください。

仕様: @docs/smart-review-implementation-plan.md の Week 1 セクション
テスト: test/vulnerable-sample.js

動作確認後、次のSkillに進みます。
```

## 📝 各Skillの出力形式（統一）

全Skillsが以下の統一フォーマットでJSON出力：

```json
{
  "skill": "smart-review-{category}",
  "timestamp": "ISO-8601",
  "summary": "分析の概要",
  "filesAnalyzed": 15,
  "issuesFound": 8,
  "issues": [
    {
      "severity": "critical|high|medium|low",
      "type": "問題タイプ",
      "file": "ファイルパス",
      "line": 行番号,
      "code": "該当コード",
      "description": "問題の説明",
      "recommendation": "修正推奨",
      "example": "修正例",
      "autoFixable": true/false,
      "estimatedEffort": "30m|1h|2h"
    }
  ]
}
```

## 🔧 統合オーケストレーター

**`.claude/commands/smart-review.md`** - 全Skillsを統合

```markdown
---
description: 4つの専門Skillsによる包括的コードレビュー
---

# Smart Review System - 統合レビュー

## Phase 1: Critical/High（順次実行）

### Step 1: Security Analysis
[smart-review-security Skillを使用]
対象: {files}

### Step 2: Debug Analysis  
[smart-review-debug Skillを使用]
対象: {files}

## Phase 2: Medium/Low（並列可能）

### Step 3: Quality Analysis
[smart-review-quality Skillを使用]

### Step 4: Documentation Analysis
[smart-review-docs Skillを使用]

## 統合レポート

全Skillsの実行完了後、以下を生成：
1. 統合サマリー
2. 重要度別TODOリスト
3. カテゴリー別の問題リスト
```

## 🧪 テストサンプルファイル

### test/buggy-sample.js（Debug用）

```javascript
// null参照
function processUser(user) {
    console.log(user.profile.name); // user/profileがnullの可能性
}

// 型エラー
function addNumbers(a, b) {
    return a + b; // 文字列が混入する可能性
}

// 例外処理なし
async function fetchData(url) {
    const response = await fetch(url); // エラーハンドリングなし
    return response.json();
}

// 無限ループの可能性
function processItems(items) {
    let i = 0;
    while (i < items.length) {
        processItem(items[i]);
        // iのインクリメント忘れ
    }
}
```

### test/complex-sample.js（Quality用）

```javascript
// 循環的複雑度が高い
function validateUserInput(input) {
    if (input.type === 'email') {
        if (input.value.includes('@')) {
            if (input.value.length > 5) {
                if (!input.value.startsWith('@')) {
                    if (!input.value.endsWith('@')) {
                        if (input.value.split('@').length === 2) {
                            return true;
                        }
                    }
                }
            }
        }
    }
    return false;
}

// 重複コード
function getUserById(id) {
    const db = connectDatabase();
    const result = db.query('SELECT * FROM users WHERE id = ?', [id]);
    db.close();
    return result;
}

function getProductById(id) {
    const db = connectDatabase();
    const result = db.query('SELECT * FROM products WHERE id = ?', [id]);
    db.close();
    return result;
}
```

### test/undocumented-sample.js（Docs用）

```javascript
// JSDocなし
function calculateTotal(items, tax, discount) {
    let total = 0;
    for (const item of items) {
        total += item.price * item.quantity;
    }
    total = total * (1 + tax) - discount;
    return total;
}

// パラメータ説明なし
async function processOrder(orderId, userId, paymentMethod) {
    // 複雑な処理...
}

// 戻り値の型が不明
function getData() {
    return fetch('/api/data').then(r => r.json());
}
```

## ✅ 完成チェックリスト

### Security Skill
- [ ] SKILL.md 作成
- [ ] patterns.json 作成（10+パターン）
- [ ] cwe-mapping.json 作成
- [ ] test/vulnerable-sample.js で動作確認
- [ ] 6件以上の脆弱性を検出

### Debug Skill
- [ ] SKILL.md 作成
- [ ] checklist.md 作成
- [ ] common-patterns.json 作成
- [ ] test/buggy-sample.js で動作確認
- [ ] 4件以上のバグを検出

### Quality Skill
- [ ] SKILL.md 作成
- [ ] metrics.json 作成
- [ ] code-smells.json 作成
- [ ] test/complex-sample.js で動作確認
- [ ] 複雑度・重複コードを検出

### Documentation Skill
- [ ] SKILL.md 作成
- [ ] templates/ ディレクトリ作成
- [ ] JSDocテンプレート作成
- [ ] test/undocumented-sample.js で動作確認
- [ ] 3件以上のドキュメント不足を検出

### 統合
- [ ] smart-review.md（統合コマンド）作成
- [ ] 全Skillsが順次実行される
- [ ] JSON形式で統一された出力
- [ ] TODOリスト自動生成
- [ ] README.md 更新

## 🎉 完成時の使用例

```bash
claude

# 包括的レビュー
> /smart-review

# カテゴリー別レビュー
> /review-security
> /review-debug
> /review-quality
> /review-docs

# 差分レビュー
> /review-changes

# 自然言語での問い合わせ
> このプロジェクトのセキュリティをチェックしてください
> 最近変更したファイルをデバッグ分析してください
```

---

**重要**: 全4つのSkillsの完全な仕様が `docs/smart-review-implementation-plan.md` に
含まれています。段階的実装でも、一括実装でも対応可能です。

*作成日: 2025年11月17日*
*対象: 全4つのSkills実装*
