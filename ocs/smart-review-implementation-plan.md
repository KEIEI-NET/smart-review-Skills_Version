# Smart Review System - Skills実装プラン

*対象環境: Claude Code CLI*
*アプローチ: Skillsベース（提案1）*
*期間: 4週間*

## 📋 プロジェクト概要

Smart Review Systemを、Claude Skillsとして再実装します。
オーケストレーションは不要とし、Claudeの自動Skill選択機能を活用します。

## 🎯 実装アプローチ

### 選定理由

**Skillsベースアプローチを採用する理由：**

1. **シンプルさ**: オーケストレーションコード不要
2. **保守性**: 各Skillが独立しており、修正・追加が容易
3. **Claude Code CLI との親和性**: 設計思想に合致
4. **拡張性**: 新しいSkillの追加が簡単

### アーキテクチャ

```
プロジェクトルート/
├── .claude/
│   ├── skills/
│   │   ├── smart-review-security/     # Critical優先度
│   │   ├── smart-review-debug/        # High優先度
│   │   ├── smart-review-quality/      # Medium優先度
│   │   └── smart-review-docs/         # Low優先度
│   └── CLAUDE.md                      # プロジェクト全体の指示
└── README.md
```

## 📅 実装スケジュール

### Week 1: セキュリティSkill開発

**成果物:**
- `smart-review-security/SKILL.md`
- `smart-review-security/patterns.json`
- `smart-review-security/cwe-mapping.json`

**検出対象:**
- XSS (Cross-Site Scripting)
- SQLインジェクション
- コマンドインジェクション
- 認証・認可の問題
- 機密情報の露出
- 暗号化の不備

**出力形式:**
```json
{
  "category": "security",
  "issuesFound": 3,
  "issues": [
    {
      "severity": "critical",
      "type": "XSS",
      "cwe": "CWE-79",
      "file": "src/index.js",
      "line": 42,
      "description": "ユーザー入力が直接DOMに挿入",
      "recommendation": "textContentを使用するか適切にエスケープ",
      "autoFixable": true,
      "estimatedEffort": "30m"
    }
  ]
}
```

### Week 2: デバッグSkill開発

**成果物:**
- `smart-review-debug/SKILL.md`
- `smart-review-debug/checklist.md`
- `smart-review-debug/common-patterns.json`

**検出対象:**
- null/undefined参照
- 型の不一致
- ロジックエラー
- 例外処理の不備
- メモリリーク
- レースコンディション
- エッジケースの未処理

### Week 3: 品質・ドキュメントSkills開発

**成果物:**

**品質Skill:**
- `smart-review-quality/SKILL.md`
- `smart-review-quality/metrics.json`
- `smart-review-quality/code-smells.json`

**ドキュメントSkill:**
- `smart-review-docs/SKILL.md`
- `smart-review-docs/templates/`

### Week 4: 統合・テスト・ドキュメント

**タスク:**
1. 全Skillsの統合テスト
2. エラーハンドリングの強化
3. パフォーマンス最適化
4. ユーザードキュメント作成
5. サンプルプロジェクトでの検証

## 🔧 各Skillの詳細仕様

### 1. smart-review-security

#### SKILL.md構造

```markdown
---
name: "smart-review-security"
description: "セキュリティ脆弱性を検出します。XSS、SQLi、認証問題などのCritical/High優先度の問題を分析する際に使用してください。"
---

# Smart Review - Security Analysis

## 概要
コードのセキュリティ脆弱性を包括的に分析します。

## 使用タイミング
- セキュリティレビューが必要な時
- ユーザー入力を扱うコードの分析
- 認証・認可機能の実装確認
- APIエンドポイントのレビュー

## 分析観点

### 1. XSS (CWE-79)
- DOMへの直接挿入
- innerHTML の使用
- dangerouslySetInnerHTML
- 未エスケープの出力

### 2. SQLインジェクション (CWE-89)
- 文字列連結によるクエリ構築
- プリペアドステートメント未使用
- ORMの不適切な使用

### 3. コマンドインジェクション (CWE-78)
- eval() の使用
- exec() へのユーザー入力
- シェルコマンドの構築

### 4. 認証・認可
- JWT の署名検証漏れ
- セッション管理の問題
- アクセス制御の不備

### 5. 機密情報
- ハードコードされた認証情報
- ログへの機密情報出力
- 不適切な暗号化

## 実行手順

1. ファイルリストを取得
2. 各ファイルを順次分析
3. パターンマッチングによる脆弱性検出
4. CWEマッピング
5. 修正推奨の生成
6. 結果のJSON出力

## 出力形式

JSON形式で以下の構造：
- category: "security"
- issuesFound: 問題数
- issues: 問題の配列
  - severity: "critical" | "high" | "medium" | "low"
  - type: 脆弱性タイプ
  - cwe: CWE番号
  - file: ファイルパス
  - line: 行番号
  - description: 問題の説明
  - recommendation: 修正推奨
  - autoFixable: 自動修正可否
  - estimatedEffort: 推定工数

## 参照ファイル

- patterns.json: 検出パターン定義
- cwe-mapping.json: CWEマッピング
```

#### patterns.json

```json
{
  "xss": [
    {
      "pattern": "innerHTML\\s*=",
      "description": "innerHTML への直接代入",
      "severity": "high",
      "cwe": "CWE-79",
      "recommendation": "textContent を使用するか、DOMPurify でサニタイズ"
    },
    {
      "pattern": "dangerouslySetInnerHTML",
      "description": "React の dangerouslySetInnerHTML 使用",
      "severity": "high",
      "cwe": "CWE-79",
      "recommendation": "ユーザー入力を適切にエスケープ"
    }
  ],
  "sqli": [
    {
      "pattern": "SELECT.*\\+.*\\+",
      "description": "文字列連結によるSQLクエリ構築",
      "severity": "critical",
      "cwe": "CWE-89",
      "recommendation": "プリペアドステートメントを使用"
    }
  ],
  "command_injection": [
    {
      "pattern": "exec\\(.*\\$",
      "description": "変数を含むコマンド実行",
      "severity": "critical",
      "cwe": "CWE-78",
      "recommendation": "入力検証とホワイトリスト使用"
    }
  ]
}
```

### 2. smart-review-debug

#### SKILL.md構造

```markdown
---
name: "smart-review-debug"
description: "バグとロジックエラーを検出します。null参照、型エラー、例外処理の不備などのHigh優先度問題を分析する際に使用してください。"
---

# Smart Review - Debug Analysis

## 概要
潜在的なバグとロジックエラーを検出します。

## 使用タイミング
- バグ調査時
- リファクタリング前の品質確認
- Pull Requestレビュー
- プロダクション問題の事前検出

## 分析観点

### 1. null/undefined 参照
- オブジェクトアクセス前のチェック漏れ
- Optional chaining 未使用
- デフォルト値の未設定

### 2. 型の不一致
- TypeScript型定義との不整合
- 暗黙的な型変換
- 型アサーションの誤用

### 3. ロジックエラー
- 条件分岐の漏れ
- ループの無限実行リスク
- 演算子の誤用

### 4. 例外処理
- try-catch の不足
- エラーの握りつぶし
- 適切なエラーハンドリング不足

### 5. 非同期処理
- Promise の未処理
- async/await の誤用
- レースコンディション

## チェックリスト参照

詳細なチェック項目は `checklist.md` を参照
```

### 3. smart-review-quality

```markdown
---
name: "smart-review-quality"
description: "コード品質を評価します。複雑度、保守性、設計パターン、コードスメルなどのMedium優先度問題を分析する際に使用してください。"
---

# Smart Review - Quality Analysis

## 概要
コードの品質と保守性を総合的に評価します。

## 分析観点

### 1. 循環的複雑度
- 関数の複雑度測定
- ネストレベル
- 分岐の数

### 2. コードスメル
- 長すぎる関数
- 重複コード
- デッドコード
- マジックナンバー

### 3. 設計原則
- SOLID原則の遵守
- DRY原則
- 適切な抽象化

### 4. 命名規則
- 変数名の明確性
- 関数名の適切性
- 一貫性のある命名
```

### 4. smart-review-docs

```markdown
---
name: "smart-review-docs"
description: "ドキュメントの完全性をチェックします。JSDoc、コメント、README、型定義などのLow優先度問題を分析する際に使用してください。"
---

# Smart Review - Documentation Analysis

## 概要
コードドキュメントの完全性と品質を評価します。

## 分析観点

### 1. 関数ドキュメント
- JSDoc/TSDoc の完全性
- パラメータ説明
- 戻り値の説明
- 例外の説明

### 2. インラインコメント
- 複雑なロジックの説明
- TODOコメントの管理
- 不要なコメントの削除

### 3. README
- インストール手順
- 使用方法
- API仕様
- 例の提供
```

## 🎨 CLAUDE.md の設定

プロジェクトルートに配置：

```markdown
# Smart Review System

このプロジェクトは、複数の専門Skillsによる包括的コードレビューシステムです。

## 利用可能なSkills

1. **smart-review-security** (Critical)
   - セキュリティ脆弱性の検出
   
2. **smart-review-debug** (High)
   - バグとロジックエラーの検出
   
3. **smart-review-quality** (Medium)
   - コード品質の評価
   
4. **smart-review-docs** (Low)
   - ドキュメント完全性のチェック

## レビュー実行方法

### 包括的レビュー
```
このプロジェクトの包括的なコードレビューをお願いします。
以下の順序で分析してください：
1. セキュリティ分析
2. デバッグ分析
3. 品質分析
4. ドキュメント分析

最後に、検出された全問題を重要度別に整理したTODOリストを生成してください。
```

### 差分レビュー
```
最近変更されたファイルについてレビューをお願いします。
git diff を使って変更ファイルを特定し、それらに対して
セキュリティとデバッグの観点で分析してください。
```

### 特定カテゴリのみ
```
src/api/ ディレクトリ配下のファイルについて、
セキュリティレビューのみ実行してください。
```

## 出力形式

各Skillは以下の形式でJSON出力します：

```json
{
  "category": "security|debug|quality|documentation",
  "issuesFound": 数値,
  "issues": [
    {
      "severity": "critical|high|medium|low",
      "file": "ファイルパス",
      "line": 行番号,
      "description": "問題の説明",
      "recommendation": "推奨される修正",
      "autoFixable": true/false,
      "estimatedEffort": "30m|1h|2h|..."
    }
  ]
}
```

## 注意事項

- 各Skillは独立して動作します
- 必要に応じて適切なSkillが自動的に選択されます
- 複数のSkillを順次実行することも可能です
```

## 📊 使用例

### 例1: 包括的レビュー

```bash
claude

> このプロジェクト全体のコードレビューをお願いします。
> セキュリティ、デバッグ、品質、ドキュメントの順で分析し、
> 最後にTODOリストをMarkdownで生成してください。
```

**Claudeの動作：**
1. CLAUDE.md を読み込み
2. プロジェクト構造を把握
3. 各Skillを順次自動起動
4. 結果を統合してTODOリスト生成

### 例2: 差分レビュー

```bash
claude

> git で最近変更されたファイルをレビューしてください。
> 特にセキュリティとバグに焦点を当ててください。
```

### 例3: 特定ファイルのみ

```bash
claude

> src/auth/login.js のセキュリティレビューをお願いします
```

## 🧪 テスト計画

### Week 4 のテスト内容

#### 1. 単体テスト
- 各Skillが個別に正しく動作するか
- パターンマッチングが正確か
- JSON出力が仕様通りか

#### 2. 統合テスト
- 複数Skillの順次実行
- 結果統合の正確性
- TODOリスト生成

#### 3. サンプルプロジェクトテスト

**テストプロジェクト候補：**
- Express.js APIサーバー（既知の脆弱性を含む）
- React アプリケーション（型エラーを含む）
- Python Flaskアプリ（ドキュメント不足）

#### 4. パフォーマンステスト
- 大規模プロジェクトでの実行時間
- メモリ使用量
- トークン消費量

## 📚 ドキュメント

### 作成するドキュメント

1. **README.md**
   - インストール方法
   - 基本的な使い方
   - 各Skillの説明
   - トラブルシューティング

2. **CONTRIBUTING.md**
   - 新しいSkillの追加方法
   - パターン定義の書き方
   - プルリクエストガイドライン

3. **CHANGELOG.md**
   - バージョン履歴
   - 変更内容

## 🚀 デプロイ・配布

### オプション1: GitHubリポジトリ

```bash
# インストール
cd your-project
git clone https://github.com/your-org/smart-review-system.git .claude/skills/

# または submodule として
git submodule add https://github.com/your-org/smart-review-system.git .claude/skills/smart-review
```

### オプション2: プラグイン化（将来）

```bash
# Claude Code プラグインとして配布
/plugin install smart-review-system
```

## 📈 今後の拡張

### Phase 2 機能（5-8週目）

1. **自動修正機能**
   - autoFixable な問題の自動修正
   - 修正内容のdiff表示
   - ユーザー承認フロー

2. **カスタムルール**
   - プロジェクト固有のルール定義
   - チーム標準の適用

3. **レポート生成**
   - HTML/PDF レポート
   - ダッシュボード
   - トレンド分析

4. **CI/CD 統合**
   - GitHub Actions連携
   - Pre-commit hooks
   - Pull Request自動レビュー

## 🤝 サポート

### トラブルシューティング

**問題: Skillが起動しない**
- SKILL.md の description が明確か確認
- CLAUDE.md で適切に指示されているか確認

**問題: 検出精度が低い**
- patterns.json を調整
- より具体的なパターンを追加

**問題: 実行が遅い**
- 分析対象ファイルを絞り込む
- パターン数を最適化

## 📝 まとめ

このSkillsベースアプローチにより：

✅ **シンプル**: オーケストレーション不要
✅ **保守性**: 各Skillが独立
✅ **拡張性**: 新Skillの追加が容易
✅ **Claude Code CLI ネイティブ**: 設計思想に合致

4週間で実用的なシステムを構築し、段階的に機能拡張していきます。

---

*作成日: 2025年11月17日*
*対象環境: Claude Code CLI v1.0+*
*必要なClaude: Sonnet 4.5以上推奨*
