# BugSearch3 Rules Integration Guide

## 📋 概要

このガイドでは、BugSearch3の全YAMLルール（言語・フレームワーク・DB・プラットフォーム別）をSmart Review Systemに統合する手順を説明します。

## 🎯 対応範囲

### 言語
- JavaScript / TypeScript
- Python
- Go
- Java
- C# (.NET)
- Ruby
- PHP
- その他の言語

### フレームワーク
- **JavaScript/TypeScript**: React, Vue, Angular, Express, Next.js
- **Python**: Django, Flask, FastAPI
- **Java**: Spring, Spring Boot
- **Go**: Gin, Echo
- その他

### データベース
- MySQL / MariaDB
- PostgreSQL
- MongoDB
- Redis
- Elasticsearch
- その他

### プラットフォーム
- Node.js
- Browser
- Deno
- その他

## 🚀 クイックスタート

### Windows (PowerShell)

```powershell
# 1. BugSearch3のルールディレクトリを指定して変換
cd C:\path\to\smart-review-system

.\tools\convert-bugsearch3-rules.ps1 `
    -BugSearch3RulesDir "C:\path\to\BugSearch3\services\analysis-service-go\rules"

# 2. 統合（既存のSkillsに追加）
.\tools\integrate-bugsearch3-rules.ps1

# 3. 完了！
```

### macOS / Linux

```bash
# 1. スクリプトに実行権限を付与
chmod +x tools/convert-bugsearch3-rules.sh

# 2. 変換実行
./tools/convert-bugsearch3-rules.sh \
    -s /path/to/BugSearch3/services/analysis-service-go/rules

# 3. 完了！
```

## 📊 変換後の構造

```
.claude/skills/
├── smart-review-security/
│   ├── SKILL.md
│   ├── patterns.json                    # 既存のコアルール
│   ├── cwe-mapping.json
│   └── rules-bugsearch3/                # BugSearch3ルール（新規）
│       ├── bugsearch3-javascript.json   # JavaScript セキュリティルール
│       ├── bugsearch3-typescript.json   # TypeScript セキュリティルール
│       ├── bugsearch3-python.json       # Python セキュリティルール
│       ├── bugsearch3-go.json           # Go セキュリティルール
│       └── ...
├── smart-review-debug/
│   ├── SKILL.md
│   ├── common-patterns.json
│   ├── checklist.md
│   └── rules-bugsearch3/
│       ├── bugsearch3-javascript.json
│       ├── bugsearch3-typescript.json
│       ├── bugsearch3-react.json        # React 固有のバグパターン
│       ├── bugsearch3-vue.json          # Vue 固有のバグパターン
│       └── ...
└── smart-review-quality/
    ├── SKILL.md
    ├── metrics.json
    ├── code-smells.json
    └── rules-bugsearch3/
        ├── bugsearch3-javascript.json
        ├── bugsearch3-python.json
        └── ...
```

## 🔧 詳細手順

### Step 1: 変換スクリプトの実行

#### Windows

```powershell
# ドライランで確認（実際にファイルを作成しない）
.\tools\convert-bugsearch3-rules.ps1 `
    -BugSearch3RulesDir "C:\path\to\BugSearch3\rules" `
    -DryRun

# 詳細ログ付きで実行
.\tools\convert-bugsearch3-rules.ps1 `
    -BugSearch3RulesDir "C:\path\to\BugSearch3\rules" `
    -Verbose

# カスタム出力先を指定
.\tools\convert-bugsearch3-rules.ps1 `
    -BugSearch3RulesDir "C:\path\to\BugSearch3\rules" `
    -OutputDir "C:\custom\output"
```

#### Unix/Linux

```bash
# ドライラン
./tools/convert-bugsearch3-rules.sh \
    -s /path/to/BugSearch3/rules \
    -d

# カスタム出力先
./tools/convert-bugsearch3-rules.sh \
    -s /path/to/BugSearch3/rules \
    -o /custom/output
```

### Step 2: 変換結果の確認

```powershell
# Windows
Get-ChildItem .\.claude\skills\smart-review-*\rules-bugsearch3\

# Unix/Linux
ls -la ./.claude/skills/smart-review-*/rules-bugsearch3/
```

**期待される出力:**
```
smart-review-security/rules-bugsearch3/
  - bugsearch3-javascript.json (125 rules)
  - bugsearch3-typescript.json (98 rules)
  - bugsearch3-python.json (156 rules)
  - bugsearch3-go.json (89 rules)
  ...

smart-review-debug/rules-bugsearch3/
  - bugsearch3-javascript.json (234 rules)
  - bugsearch3-typescript.json (198 rules)
  - bugsearch3-react.json (67 rules)
  - bugsearch3-vue.json (54 rules)
  ...
```

### Step 3: 既存Skillsへの統合（オプション）

既存の `common-patterns.json` に統合する場合：

```powershell
# Windows
.\tools\integrate-bugsearch3-rules.ps1

# ドライランで確認
.\tools\integrate-bugsearch3-rules.ps1 -DryRun
```

## 📈 統計情報の確認

変換スクリプト実行後の出力例：

```
================================
Conversion Summary
================================

Total YAML files: 1,247
Converted rules: 1,189
Skipped rules: 58
Errors: 0

Rules by Category & Language:
  security-javascript : 125
  security-typescript : 98
  security-python : 156
  security-go : 89
  debug-javascript : 234
  debug-typescript : 198
  debug-react : 67
  debug-vue : 54
  debug-python : 189
  quality-javascript : 98
  quality-python : 67
  ...

[OK] Conversion completed successfully!
```

## 🎯 使用方法

### 基本的な使い方

```bash
claude
```

```
> このプロジェクトのデバッグ分析をお願いします
```

Claudeが自動的に：
1. プロジェクトの言語を検出（例: JavaScript）
2. 対応するBugSearch3ルールを適用
3. `bugsearch3-javascript.json` のルールを使用
4. 包括的な分析を実行

### 言語を明示的に指定

```
> このPythonプロジェクトを、BugSearch3のルールを含めてレビューしてください
```

### フレームワーク固有のレビュー

```
> このReactプロジェクトを、React固有のバグパターンも含めてチェックしてください
```

### データベース関連のレビュー

```
> src/database/ ディレクトリのMySQLクエリをレビューしてください
```

## 📊 ルールファイルの形式

変換後のJSONファイルの例：

```json
{
  "source": "BugSearch3",
  "language": "javascript",
  "category": "debug",
  "rules_count": 234,
  "rules": [
    {
      "pattern": "\\w+\\.\\w+\\.\\w+(?!\\?)",
      "description": "Multiple property access without null check",
      "severity": "high",
      "recommendation": "Use optional chaining (?.) or explicit null checks",
      "example": "user?.profile?.name",
      "metadata": {
        "id": "JS-NULL-001",
        "language": "javascript",
        "category": "debug",
        "cwe": "CWE-476",
        "tags": ["null-safety", "defensive-programming"]
      }
    },
    {
      "pattern": "Promise\\.all\\([^)]*\\)(?!.*catch)",
      "description": "Promise.all without error handling",
      "severity": "high",
      "recommendation": "Add .catch() or use try-catch with await",
      "metadata": {
        "id": "JS-ASYNC-004",
        "language": "javascript",
        "category": "debug",
        "tags": ["async", "error-handling"]
      }
    }
  ]
}
```

## 🔍 カスタマイズ

### 特定の言語のみを変換

```powershell
# JavaScriptのみ
Get-ChildItem "C:\path\to\BugSearch3\rules\javascript" -Filter "*.yaml" |
    ForEach-Object {
        # カスタム変換ロジック
    }
```

### 特定のカテゴリのみを統合

```powershell
# セキュリティルールのみ統合
$securityRules = Get-ChildItem ".\.claude\skills\smart-review-security\rules-bugsearch3\*.json"
# 統合処理
```

## 🚨 トラブルシューティング

### 問題1: YAMLファイルが見つからない

```
[ERROR] BugSearch3 rules directory not found
```

**解決策:**
```powershell
# パスを確認
Test-Path "C:\path\to\BugSearch3\rules"

# 正しいパスを指定
.\tools\convert-bugsearch3-rules.ps1 -BugSearch3RulesDir "正しいパス"
```

### 問題2: 変換エラーが多数発生

```
Converted rules: 150
Skipped rules: 1,000
Errors: 50
```

**原因:** YAMLファイルの形式が想定と異なる

**解決策:**
```powershell
# 詳細ログで確認
.\tools\convert-bugsearch3-rules.ps1 `
    -BugSearch3RulesDir "..." `
    -Verbose

# サンプルYAMLを確認
Get-Content "C:\path\to\BugSearch3\rules\sample.yaml"
```

### 問題3: メモリ不足

大量のルール（5,000+）を一度に変換する場合

**解決策:**
```powershell
# 言語別に分けて変換
.\tools\convert-bugsearch3-rules.ps1 `
    -BugSearch3RulesDir "C:\path\to\BugSearch3\rules\javascript"

.\tools\convert-bugsearch3-rules.ps1 `
    -BugSearch3RulesDir "C:\path\to\BugSearch3\rules\python"
```

## 📚 高度な使い方

### カスタムルールの追加

BugSearch3ルールに加えて、プロジェクト固有のルールを追加：

```bash
# 1. カスタムルールディレクトリを作成
mkdir -p .claude/skills/smart-review-debug/rules-custom

# 2. YAMLファイルを配置
cp my-custom-rules/*.yaml .claude/skills/smart-review-debug/rules-custom/

# 3. 変換
./tools/convert-bugsearch3-rules.sh -s .claude/skills/smart-review-debug/rules-custom
```

### CI/CD統合

```yaml
# .github/workflows/update-rules.yml
name: Update BugSearch3 Rules

on:
  schedule:
    - cron: '0 0 * * 0'  # 毎週日曜日

jobs:
  update-rules:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3

      - name: Clone BugSearch3
        run: |
          git clone https://github.com/KEIEI-NET/BugSearch3.git

      - name: Convert Rules
        run: |
          .\tools\convert-bugsearch3-rules.ps1 `
            -BugSearch3RulesDir ".\BugSearch3\services\analysis-service-go\rules"

      - name: Commit Changes
        run: |
          git add .claude/skills/*/rules-bugsearch3/
          git commit -m "chore: Update BugSearch3 rules"
          git push
```

## 🎯 ベストプラクティス

### 1. 定期的な更新

```bash
# 月1回、BugSearch3の最新ルールを取得
git pull origin main  # BugSearch3リポジトリで
./tools/convert-bugsearch3-rules.sh -s /path/to/BugSearch3/rules
```

### 2. バージョン管理

```bash
# 変換日時をファイル名に含める
./tools/convert-bugsearch3-rules.sh \
    -s /path/to/BugSearch3/rules \
    -o ./.claude/skills/rules-bugsearch3-$(date +%Y%m%d)
```

### 3. チーム共有

```bash
# GitHubリポジトリで共有
git add .claude/skills/*/rules-bugsearch3/
git commit -m "feat: Add BugSearch3 rules integration"
git push origin main
```

## 📊 期待される効果

### 検出力の向上

| 項目 | コアルールのみ | BugSearch3統合後 |
|------|--------------|------------------|
| JavaScriptバグ検出 | 50パターン | 284パターン |
| TypeScriptバグ検出 | 30パターン | 228パターン |
| Pythonバグ検出 | 40パターン | 256パターン |
| セキュリティ検出 | 60パターン | 468パターン |
| React固有問題 | 0パターン | 67パターン |
| Vue固有問題 | 0パターン | 54パターン |

### カバレッジ

- **言語カバレッジ**: 8言語 → 15+言語
- **フレームワーク**: 0 → 20+フレームワーク
- **データベース**: 0 → 10+データベース

## 🔗 関連ドキュメント

- [YAML Rules Integration](./YAML-RULES-INTEGRATION.md) - 統合の詳細分析
- [COMPATIBILITY.md](../COMPATIBILITY.md) - クロスプラットフォーム互換性
- [README.md](../README.md) - プロジェクト概要

---

**最終更新:** 2025年11月17日
**対象バージョン:** Smart Review System v1.1.0
