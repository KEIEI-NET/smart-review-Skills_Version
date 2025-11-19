# Smart Review System - AST分析実装計画

**ドキュメントバージョン:** 1.0.0
**作成日:** 2025年11月19日 (JST)
**ステータス:** 調査・計画段階（BugSearch3確認待ち）
**著作権:** (c) 2025 KEIEI.NET INC.
**作成者:** KENJI OYAMA

---

## 📋 目次

- [概要](#概要)
- [背景と課題](#背景と課題)
- [BugSearch3 AST機能の確認手順](#bugsearch3-ast機能の確認手順)
- [現状分析](#現状分析)
- [実装選択肢](#実装選択肢)
- [推奨アプローチ](#推奨アプローチ)
- [実装ロードマップ](#実装ロードマップ)
- [技術的詳細](#技術的詳細)
- [参考資料](#参考資料)

---

## 概要

BugSearch3がAST（Abstract Syntax Tree）分析サービスを実装した可能性があるため、Smart Review Systemでの対応可能性を調査し、実装計画を策定する。

### 目的

1. **BugSearch3のAST機能確認**: 実際にAST分析機能が存在するか確認
2. **対応可能性の評価**: Smart Review Systemで活用可能か検証
3. **実装方式の決定**: 最適なアプローチを選定
4. **実装計画の策定**: 工数・スケジュールの明確化

### 対象読者

- プロジェクト管理者
- 技術実装担当者
- AST分析統合検討者

---

## 背景と課題

### 現在のSmart Review System

**実装方式:** 正規表現ベースのパターンマッチング

**制約:**
1. **構文理解不可**: ネストした構造の解析困難
2. **スコープ理解不可**: 変数のスコープを追跡できない
3. **型システム理解不可**: TypeScript型、C++テンプレート等の解析不可
4. **コンテキスト依存検出不可**: 条件分岐後の安全性を判断できない
5. **False Positive多い**: 文字列内のパターン、コメント内を誤検出

**具体例:**
```javascript
// False Positive: 文字列内のパターンを誤検出
const code = "user.profile.name";
// ↑ 正規表現が "チェーンアクセス" として検出

// False Negative: 実際は安全だが検出
if (user && user.profile) {
  const name = user.profile.name; // 安全だが警告される
}
```

### AST分析の利点

**AST（Abstract Syntax Tree）とは:**
- ソースコードを構文解析して得られる木構造
- プログラムの構造を正確に表現
- コンパイラ、リンター、フォーマッターで使用

**AST分析の利点:**
1. **高精度**: 構文を正確に理解
2. **スコープ追跡**: 変数の宣言・使用を追跡
3. **型理解**: TypeScript型システムを理解
4. **制御フロー解析**: if/else/switch等を追跡
5. **データフロー解析**: 変数の値の流れを追跡
6. **False Positive削減**: コンテキストを考慮した判定

---

## BugSearch3 AST機能の確認手順

### ステップ1: リポジトリへのアクセス

#### 1.1 リポジトリURL

**BugSearch3リポジトリ:**
- URL: `https://github.com/KEIEI-NET/BugSearch3`
- ブランチ: `main` または `master`

#### 1.2 クローン

```bash
cd /path/to/workspace
git clone https://github.com/KEIEI-NET/BugSearch3.git
cd BugSearch3
```

---

### ステップ2: AST関連コードの検索

#### 2.1 キーワード検索

**検索すべきキーワード:**
```bash
# AST関連
grep -r "AST" --include="*.go" --include="*.md"
grep -r "Abstract Syntax Tree" --include="*.go" --include="*.md"
grep -r "tree-sitter" --include="*.go" --include="*.md"
grep -r "parser" --include="*.go" --include="*.md"

# Go標準パッケージ
grep -r "go/ast" --include="*.go"
grep -r "go/parser" --include="*.go"

# サードパーティパーサー
grep -r "github.com/tree-sitter" --include="*.go"
grep -r "github.com/davecgh/go-spew" --include="*.go"
```

#### 2.2 ディレクトリ構造の確認

```bash
# 分析サービスの構造を確認
ls -la services/analysis-service-go/

# 期待されるディレクトリ構造:
# services/
# └── analysis-service-go/
#     ├── rules/          # YAMLルール定義
#     ├── analyzer/       # 分析エンジン（AST?）
#     ├── parser/         # パーサー（AST?）
#     └── main.go
```

---

### ステップ3: ドキュメントの確認

#### 3.1 README確認

```bash
# READMEでAST言及を確認
cat README.md | grep -i "ast"
cat README.md | grep -i "syntax tree"
cat README.md | grep -i "parser"
```

#### 3.2 ドキュメントフォルダ確認

```bash
# docsフォルダの確認
ls -la docs/
cat docs/ARCHITECTURE.md 2>/dev/null
cat docs/ANALYSIS.md 2>/dev/null
```

---

### ステップ4: コード分析

#### 4.1 Go言語パッケージの確認

```bash
# go.modでAST関連依存を確認
cat go.mod | grep -E "(ast|parser|tree-sitter)"

# 例: 見つかるべきパッケージ
# - golang.org/x/tools/go/ast
# - github.com/tree-sitter/tree-sitter-go
```

#### 4.2 分析サービスのコード確認

```bash
# 分析サービスのmain.goを確認
cat services/analysis-service-go/main.go

# analyzer/ ディレクトリの確認
ls -la services/analysis-service-go/analyzer/ 2>/dev/null
```

---

### ステップ5: 実行テスト（オプション）

#### 5.1 BugSearch3のビルド

```bash
# Go環境が必要
cd services/analysis-service-go/
go build -o bugsearch3
```

#### 5.2 テスト実行

```bash
# サンプルファイルで分析テスト
./bugsearch3 analyze --file test-sample.js --format json

# 出力にAST情報が含まれるか確認
# 期待される出力:
# {
#   "ast": {...},        # ← AST機能があればこれが存在
#   "issues": [...]
# }
```

---

### ステップ6: 判定

#### 6.1 AST機能の存在判定

**AST機能があると判定できる条件:**

✅ **確認できれば AST機能あり:**
1. `go/ast`, `go/parser` パッケージの使用
2. `tree-sitter` ライブラリの使用
3. READMEやドキュメントに "AST" "構文解析" の明示的記載
4. `analyzer/`, `parser/` ディレクトリの存在
5. コード内で AST ノードの走査ロジック
6. API出力に AST データが含まれる

❌ **AST機能なしと判定:**
1. YAMLルールの正規表現のみ
2. `go/ast` パッケージの不使用
3. ドキュメントにAST言及なし

---

### ステップ7: 結果のドキュメント化

#### 7.1 調査結果テンプレート

```markdown
# BugSearch3 AST機能調査結果

**調査日:** YYYY-MM-DD
**調査者:** [Your Name]
**リポジトリ:** https://github.com/KEIEI-NET/BugSearch3
**コミット:** [commit hash]

## 結論
- [ ] AST機能あり
- [ ] AST機能なし
- [ ] 部分的にAST機能あり

## 発見事項

### AST関連コード
- ファイル: `services/analysis-service-go/analyzer/ast.go`
- パッケージ: `go/ast`, `go/parser`
- 説明: ...

### APIエンドポイント
- エンドポイント: `/api/analyze`
- 出力: JSON (AST含む)
- 例: ...

### ドキュメント
- README: AST機能の説明あり
- Architecture: 分析フローにAST解析の記載

## 次のアクション
1. ...
2. ...
```

---

## 現状分析

### Smart Review Systemの制約

| 項目 | 正規表現（現在） | AST分析（目標） |
|------|----------------|---------------|
| **検出精度** | 中（60-70%） | 高（90-95%） |
| **False Positive率** | 高（30-40%） | 低（5-10%） |
| **スコープ理解** | 不可 | 可能 |
| **型システム理解** | 不可 | 可能 |
| **制御フロー解析** | 不可 | 可能 |
| **実装難易度** | 低 | 高 |
| **保守性** | 高 | 中 |

### 正規表現の限界例

#### 例1: Optional Chaining検出

**現在の正規表現:**
```regex
\w+\.\w+\.\w+(?!\?)
```

**問題:**
```javascript
// False Positive
const code = "user.profile.name"; // 文字列なのに検出

// False Positive
// user.profile.name  // コメントなのに検出

// False Negative（見逃し）
if (user && user.profile) {
  user.profile.name; // 実際は安全だが検出
}
```

#### 例2: 型アサーション検出

**現在の正規表現:**
```regex
as\s+(any|unknown)
```

**問題:**
```typescript
// False Positive
const type = "as any"; // 文字列

// False Negative
type UserType = any; // 型エイリアスは検出できない
```

---

## 実装選択肢

### 選択肢A: 正規表現の高度化

**アプローチ:**
複雑な正規表現と除外パターンでFalse Positiveを削減

**実装内容:**
```json
{
  "pattern": "\\w+\\.\\w+\\.\\w+(?!\\?)",
  "excludePatterns": [
    "^\\s*//",         // 行コメント除外
    "^\\s*\\*",        // ブロックコメント除外
    "\"[^\"]*\"",      // ダブルクォート文字列除外
    "'[^']*'"          // シングルクォート文字列除外
  ],
  "contextHints": [
    "nullチェック後は検出しない",
    "try-catchブロック内は検出しない"
  ]
}
```

**利点:**
- 実装容易（2-3日）
- 既存ルールとの互換性維持
- 外部依存なし

**欠点:**
- 根本的な解決ではない
- 精度向上は限定的（+20-30%）
- 複雑なパターンは保守困難

**工数:** 2-3日
**精度向上:** +20-30%
**推奨度:** ⭐⭐⭐⭐

---

### 選択肢B: 外部ASTツール統合

**アプローチ:**
tree-sitter、ESLint、Clang等を外部ツールとして統合

**実装内容:**

1. **tree-sitter統合（全言語対応）**
```bash
# TypeScript
npx tree-sitter parse file.ts --quiet > ast.json

# C++
tree-sitter parse file.cpp --language cpp > ast.json
```

2. **SKILL.mdでAST JSONを解析**
```markdown
## AST解析フロー
1. tree-sitterでASTを生成
2. JSON出力を読み込み
3. ノード種別でフィルタリング
   - `type: "CallExpression"`
   - `type: "MemberExpression"`
4. 問題パターンを検出
```

**利点:**
- 高精度（+60-80%）
- 完全なAST解析
- 言語ごとのパーサーが充実

**欠点:**
- 外部依存が大幅に増加
- インストール・設定が複雑
- クロスプラットフォーム対応困難
- ユーザー体験の低下

**依存パッケージ:**
- `tree-sitter` (CLI)
- `tree-sitter-javascript`
- `tree-sitter-typescript`
- `tree-sitter-cpp`
- `tree-sitter-swift`
- （10+ parsers必要）

**工数:** 7-10日
**精度向上:** +60-80%
**推奨度:** ⭐⭐（外部依存増加のため）

---

### 選択肢C: Claude AI活用型疑似AST

**アプローチ:**
Claude AIの言語理解能力を活用し、AST相当の解析を疑似的に実行

**実装内容:**

#### SKILL.md拡張例

```markdown
## 疑似AST解析

### Phase 1: ファイル全体の構造解析
対象ファイルを読み込み、以下を抽出:
1. **関数定義:** すべての関数名、パラメータ、戻り値型
2. **クラス定義:** クラス名、メンバ変数、メソッド
3. **変数宣言:** スコープ、型、初期値
4. **インポート文:** 依存関係

### Phase 2: スコープ追跡
各変数について:
- 宣言位置
- 使用箇所
- スコープ（グローバル/ローカル/ブロック）
- 型の一貫性

### Phase 3: 制御フロー解析
- if/else/switch の分岐
- ループ（for/while）
- 例外処理（try-catch）
- 早期リターン

### Phase 4: 問題検出
構造理解を活用し、以下を検出:
1. **null安全性:**
   - nullチェック後のアクセス → 安全
   - nullチェックなしのアクセス → 警告

2. **型安全性:**
   - 型ガード後のキャスト → 安全
   - 型ガードなしのキャスト → 警告

3. **スコープ安全性:**
   - スコープ内の変数アクセス → 安全
   - スコープ外の変数アクセス → エラー
```

**利点:**
- 外部依存なし
- Claude AIの強みを最大活用
- 段階的な実装が可能
- トークン消費は許容範囲

**欠点:**
- 完全なAST解析ではない（精度90-95%ではなく80-85%）
- トークン消費増加（+20-30%）
- 大規模ファイルでは制限あり

**工数:** 4-5日
**精度向上:** +40-50%
**推奨度:** ⭐⭐⭐⭐

---

### 選択肢D: Multi-Layer Analysis（ハイブリッド）

**アプローチ:**
正規表現 + Claude AI疑似AST + コンテキスト理解の3段階

**実装内容:**

#### Layer 1: 正規表現スクリーニング（1秒）
```json
{
  "pattern": "\\w+\\.\\w+\\.\\w+(?!\\?)",
  "severity": "candidate"
}
```
→ 問題候補を高速抽出

#### Layer 2: Claude AI疑似AST解析（5秒）
```markdown
候補の各パターンについて:
1. 周辺10行のコードを読み込み
2. 以下を確認:
   - nullチェックの存在
   - try-catchブロック内か
   - 型ガードの適用
   - スコープの安全性
```
→ 候補を検証

#### Layer 3: コンテキスト理解（3秒）
```markdown
最終判定:
- null安全: nullチェック後 → 問題なし
- 型安全: 型ガード後 → 問題なし
- 例外安全: try-catch内 → 問題なし
→ 上記以外のみ警告
```

**フロー図:**
```
100ファイル
  ↓ Layer 1 (1秒)
20候補
  ↓ Layer 2 (5秒)
8候補
  ↓ Layer 3 (3秒)
3真の問題 ← 報告
```

**利点:**
- 精度と速度のバランス最良
- 外部依存なし
- 段階的導入可能
- False Positive大幅削減

**欠点:**
- 実装がやや複雑
- 3つのレイヤーの調整が必要

**工数:** 9-13日
**精度向上:** +50-60%
**推奨度:** ⭐⭐⭐⭐⭐（最推奨）

---

## 推奨アプローチ

### 最終推奨: Multi-Layer Analysis（選択肢D）

**推奨理由:**

1. **外部依存なし:**
   - インストール不要
   - クロスプラットフォーム対応簡単
   - ユーザー体験良好

2. **精度と速度のバランス:**
   - Layer 1で高速スクリーニング（1秒）
   - Layer 2/3で精密分析（8秒）
   - 総時間: 9秒/100ファイル（許容範囲）

3. **段階的導入:**
   - まず選択肢Aで正規表現強化
   - 次にLayer 2/3を追加
   - 既存ルールとの互換性維持

4. **ROI（投資対効果）:**
   - 工数: 9-13日（約2週間）
   - 精度向上: +50-60%
   - False Positive削減: -40-50%
   - ユーザー満足度: 大幅向上

### BugSearch3 AST機能がある場合の対応

**シナリオ1: BugSearch3にAST機能が存在**

**対応:**
1. **Phase 1:** Multi-Layer Analysis実装（基盤確立）
2. **Phase 2:** BugSearch3 ASTを外部ツールとして統合
3. **Phase 3:** ハイブリッド運用（両方活用）

**統合方法:**
```bash
# BugSearch3のAST分析を呼び出し
bugsearch3 analyze --format json --ast file.js > ast.json

# Smart Review SystemでAST JSONを読み込み
claude --skill smart-review-security --ast-input ast.json
```

**シナリオ2: BugSearch3にAST機能なし**

**対応:**
- Multi-Layer Analysis単独で実装
- 将来的に外部ASTツール統合を検討（Phase 4）

---

## 実装ロードマップ

### v1.2.0: Multi-Layer Analysis実装（2-3ヶ月）

#### Phase 1: 正規表現高度化（2-3日）

**タスク:**
- [ ] 除外パターン追加（50ルール）
- [ ] False Positive削減テスト
- [ ] ドキュメント更新

**成果物:**
- 拡張版 patterns.json
- テストレポート

---

#### Phase 2: Claude AI疑似AST（3-4日）

**タスク:**
- [ ] SKILL.mdに疑似AST解析指示を追加
- [ ] 構造解析ロジックの明文化
- [ ] スコープ・型追跡の指示追加

**成果物:**
- 拡張版 SKILL.md（Security, Debug, Quality）
- 分析フローのドキュメント

---

#### Phase 3: Multi-Layer統合（2-3日）

**タスク:**
- [ ] 3レイヤーの統合
- [ ] パフォーマンステスト
- [ ] 精度検証（Before/After比較）

**成果物:**
- 統合版 Smart Review System
- パフォーマンスレポート
- 精度改善レポート

---

#### Phase 4: テスト・ドキュメント（2-3日）

**タスク:**
- [ ] テストサンプル作成（各言語）
- [ ] ユーザーガイド更新
- [ ] CHANGELOG作成
- [ ] リリースノート作成

**成果物:**
- 完全なテストスイート
- ドキュメントセット
- v1.2.0リリース

**総工数:** 9-13日
**リリース目標:** 2025年12月

---

### v1.3.0以降: BugSearch3統合・外部ツール（3-6ヶ月）

#### Phase 5: BugSearch3 AST統合（条件付き）

**前提条件:** BugSearch3にAST機能が存在する場合

**タスク:**
- [ ] BugSearch3 API連携
- [ ] AST JSON解析実装
- [ ] Multi-Layerとのハイブリッド運用

**工数:** 5-7日

---

#### Phase 6: 外部ASTツールのPoC（オプション）

**タスク:**
- [ ] tree-sitter統合のPoC
- [ ] ESLint/Clang-Tidy連携のPoC
- [ ] パフォーマンス・精度比較

**工数:** 10-15日

---

## 技術的詳細

### Multi-Layer Analysisの実装詳細

#### Layer 1: 正規表現スクリーニング

**実装場所:** `patterns.json`, `common-patterns.json`

**拡張内容:**
```json
{
  "rules": [
    {
      "id": "CHAIN-ACCESS-001",
      "pattern": "\\w+\\.\\w+\\.\\w+(?!\\?)",
      "severity": "candidate",
      "description": "チェーンアクセス候補",
      "excludePatterns": [
        "^\\s*//",
        "^\\s*\\*",
        "\"[^\"]*\"",
        "'[^']*'"
      ],
      "layer": 1
    }
  ]
}
```

---

#### Layer 2: Claude AI疑似AST解析

**実装場所:** `SKILL.md`

**拡張内容:**
```markdown
## Layer 2: 疑似AST解析

### 実行条件
Layer 1で抽出された候補のみ実行

### 解析手順
各候補について:

#### 1. コンテキスト読み込み
候補の前後10行を読み込み

#### 2. 構造解析
以下を抽出:
- スコープ（関数内/グローバル）
- 制御フロー（if/try-catch内か）
- null/undefinedチェックの存在

#### 3. 安全性判定
**安全と判定する条件:**
- nullチェック後のアクセス
- try-catchブロック内
- 型ガード後のキャスト
- Optional chainedアクセス

**警告と判定する条件:**
- 上記以外
```

---

#### Layer 3: コンテキスト理解

**実装場所:** `SKILL.md`

**拡張内容:**
```markdown
## Layer 3: 最終判定

### 判定基準

#### 1. null安全性
\`\`\`javascript
// 安全
if (user) {
  user.profile.name; // ← 問題なし
}

// 警告
user.profile.name; // ← 警告
\`\`\`

#### 2. 型安全性
\`\`\`typescript
// 安全
if (typeof value === 'string') {
  value.toUpperCase(); // ← 問題なし
}

// 警告
value.toUpperCase(); // ← 警告
\`\`\`

#### 3. 例外安全性
\`\`\`javascript
// 安全
try {
  riskyOperation(); // ← 問題なし
} catch (e) {}

// 警告
riskyOperation(); // ← 警告
\`\`\`
```

---

### パフォーマンス最適化

#### 1. 並列処理

```markdown
## 並列実行戦略
- Layer 1: 全ファイル並列スクリーニング
- Layer 2/3: 候補を並列解析（最大5並列）
```

#### 2. キャッシング

```markdown
## キャッシング戦略
- ファイルハッシュでキャッシュ
- 変更されたファイルのみ再解析
- キャッシュ有効期限: 24時間
```

#### 3. 段階的解析

```markdown
## 段階的解析
- 重要ファイル優先（src/**/*.ts）
- テストファイルは後回し
- 設定ファイルはスキップ
```

---

## 参考資料

### プロジェクト内ドキュメント

- [BUGSEARCH3-INTEGRATION-GUIDE.md](./BUGSEARCH3-INTEGRATION-GUIDE.md)
- [rule-expansion-plan.md](./rule-expansion-plan.md)
- [github-actions-integration-plan.md](./github-actions-integration-plan.md)

### 外部リソース

**AST関連:**
- [tree-sitter](https://tree-sitter.github.io/tree-sitter/)
- [ESLint - Working with AST](https://eslint.org/docs/latest/extend/custom-parsers)
- [TypeScript Compiler API](https://github.com/microsoft/TypeScript/wiki/Using-the-Compiler-API)

**Go AST:**
- [go/ast package](https://pkg.go.dev/go/ast)
- [go/parser package](https://pkg.go.dev/go/parser)

**BugSearch3:**
- [BugSearch3 Repository](https://github.com/KEIEI-NET/BugSearch3)

---

## 更新履歴

| バージョン | 日付 | 変更内容 | 作成者 |
|-----------|------|---------|-------|
| 1.0.0 | 2025-11-19 | 初版作成（BugSearch3確認待ち） | KENJI OYAMA |

---

## ライセンス・著作権

**著作権:** (c) 2025 KEIEI.NET INC.
**作成者:** KENJI OYAMA
**ライセンス:** MIT License（プロジェクトルートのLICENSEファイルを参照）

---

## 次のアクション

### 優先度1: BugSearch3 AST機能の確認

**担当:** プロジェクト管理者
**期限:** 1週間以内

**タスク:**
1. BugSearch3リポジトリへアクセス
2. [確認手順](#bugsearch3-ast機能の確認手順)に従ってAST機能を調査
3. 調査結果をドキュメント化
4. 実装方針を決定

### 優先度2: 実装準備（AST機能なしの場合）

**タスク:**
1. Multi-Layer Analysis実装開始
2. Phase 1（正規表現高度化）から着手
3. テストサンプル作成

### 優先度3: 実装準備（AST機能ありの場合）

**タスク:**
1. BugSearch3統合アーキテクチャの設計
2. Multi-Layer + BugSearch3のハイブリッド方式検討
3. PoC実装

---

**注意事項:**
- このドキュメントは調査・計画段階のものです
- BugSearch3のAST機能確認後に実装方針を最終決定します
- 実装前にテスト環境での検証を推奨します

**質問・フィードバック:**
- Issues: https://github.com/KEIEI-NET/smart-review-Skills_Version/issues
- Discussions: https://github.com/KEIEI-NET/smart-review-Skills_Version/discussions
