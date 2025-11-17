# Smart Review System

> Claude Code Skills による包括的コードレビューシステム + BugSearch3統合

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.1.0-green.svg)](CHANGELOG.md)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)](COMPATIBILITY.md)
[![Skills](https://img.shields.io/badge/skills-4-orange.svg)](.claude/skills)
[![Rules](https://img.shields.io/badge/rules-368+-red.svg)](.claude/skills)

複数の専門Skillsによる包括的なコードレビューを提供します。セキュリティ、デバッグ、品質、ドキュメントの4つの観点から、コードを徹底的に分析します。

**v1.1.0新機能**: BugSearch3の全YAMLルール（168ルール）を統合！10言語以上、20+フレームワーク対応。

## ✨ 特徴

- **🔒 セキュリティ分析**: XSS、SQLインジェクション、コマンドインジェクション、機密情報の露出などを検出
- **🐛 デバッグ分析**: null参照、型エラー、非同期処理の問題、例外処理の不備を検出
- **📊 品質分析**: 循環的複雑度、コードスメル、設計原則の遵守度を評価
- **📝 ドキュメント分析**: JSDoc、README、API仕様の完全性をチェック
- **🌍 BugSearch3統合**: 10言語以上、20+フレームワーク、10+データベース対応

## 🚀 クイックスタート

### インストール

#### Windows (PowerShell)

```powershell
cd your-project
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/KEIEI-NET/smart-review-Skills_Version/main/install-safe.ps1" -OutFile "install.ps1"
.\install.ps1
```

#### macOS / Linux

```bash
cd your-project
curl -O https://raw.githubusercontent.com/KEIEI-NET/smart-review-Skills_Version/main/install.sh
chmod +x install.sh
./install.sh
```

詳細は [INSTALL.md](INSTALL.md) または [QUICKSTART.md](QUICKSTART.md) を参照。

### 使い方

```bash
claude
```

```
> このプロジェクト全体のコードレビューをお願いします
```

Claudeが自動的に4つのSkillsを順次実行し、包括的なレビュー結果を提供します。

## 📋 Skills一覧

| Skill | 優先度 | コアルール | BugSearch3 | 合計 | 主な機能 |
|-------|--------|-----------|------------|------|---------|
| **Security** | Critical | 60+ | 28+ | **88+** | OWASP Top 10準拠の脆弱性検出 |
| **Debug** | High | 70+ | 58+ | **128+** | null参照、非同期エラー、DB問題検出 |
| **Quality** | Medium | 50+ | 70+ | **120+** | 複雑度測定、コードスメル、パフォーマンス |
| **Docs** | Low | 30+ | - | **30+** | JSDoc、README等の完全性チェック |

**総検出ルール数: 368+** (v1.1.0)

## 🌍 対応言語・プラットフォーム

### 言語（10+）

| 言語 | Debug | Quality | Security | 合計 |
|------|-------|---------|----------|------|
| JavaScript | 10 | 5 | 3 | 18 |
| Python | 10 | 3 | 3 | 16 |
| Go | 9 | 4 | 3 | 16 |
| Java | 10 | 3 | 3 | 16 |
| C# | 10 | 4 | 3 | 17 |
| PHP | 8 | 3 | 3 | 14 |
| TypeScript | - | 1 | - | 1 |
| C/C++ | - | 6 | 4 | 10 |
| Swift | - | 3 | 1 | 4 |
| Delphi | 1 | 1 | - | 2 |

### フレームワーク（20+）
- React, Vue, Angular（メモリリーク、ライフサイクル問題）
- Django, Flask, FastAPI
- Spring, Spring Boot
- Express.js
- その他

### データベース（10+）
- MySQL / MariaDB（N+1問題、インデックス、アンチパターン）
- PostgreSQL（アンチパターン、パフォーマンス）
- MongoDB（アンチパターン）
- Redis, Elasticsearch, Cassandra, Memcached
- その他

## 📊 出力形式

各Skillは以下のJSON形式で結果を出力します：

```json
{
  "category": "security|debug|quality|documentation",
  "issuesFound": 3,
  "issues": [
    {
      "severity": "critical",
      "type": "SQLi",
      "file": "src/api/users.js",
      "line": 42,
      "description": "文字列連結によるSQLクエリ構築",
      "recommendation": "プリペアドステートメントを使用してください",
      "autoFixable": true,
      "estimatedEffort": "30m",
      "metadata": {
        "id": "BS3-DB001",
        "source": "BugSearch3",
        "cwe": "CWE-89"
      }
    }
  ]
}
```

## 🧪 テスト

```bash
claude
> test/vulnerable-sample.js のレビューをお願いします
```

**期待される結果:**
- セキュリティ脆弱性: 6件以上
- デバッグ問題: 6件以上
- 品質問題: 6件以上
- ドキュメント問題: 4件以上

## 📁 プロジェクト構造

```
smart-review-system/
├── .claude/skills/               # 4つの専門Skills
│   ├── smart-review-security/
│   │   ├── SKILL.md
│   │   ├── patterns.json         # 60+ コアパターン
│   │   ├── cwe-mapping.json
│   │   └── rules-bugsearch3/     # 28 BugSearch3ルール ★
│   ├── smart-review-debug/
│   │   ├── SKILL.md
│   │   ├── checklist.md
│   │   ├── common-patterns.json  # 70+ コアパターン
│   │   └── rules-bugsearch3/     # 58 BugSearch3ルール ★
│   ├── smart-review-quality/
│   │   ├── SKILL.md
│   │   ├── metrics.json
│   │   ├── code-smells.json      # 50+ コアパターン
│   │   └── rules-bugsearch3/     # 70 BugSearch3ルール ★
│   └── smart-review-docs/
│       ├── SKILL.md
│       └── templates/            # 4つのテンプレート
├── tools/                        # 変換・統合ツール ★
│   ├── convert-yaml-simple.py    # YAML→JSON変換（Python）
│   ├── convert-bugsearch3-rules.ps1  # PowerShell版
│   ├── convert-bugsearch3-rules.sh   # Bash版
│   └── integrate-bugsearch3-rules.ps1
├── test/
│   └── vulnerable-sample.js      # テストサンプル
├── docs/                         # 設計・統合ドキュメント
│   ├── YAML-RULES-INTEGRATION.md     # YAML統合分析 ★
│   └── BUGSEARCH3-INTEGRATION-GUIDE.md  # 統合ガイド ★
├── install.ps1                   # インストーラー（絵文字版）
├── install-safe.ps1              # インストーラー（ASCII版）
├── install.sh                    # Unix版インストーラー
├── install.bat                   # Batch版インストーラー
├── uninstall.ps1 / uninstall.sh  # アンインストーラー
├── validate-skills.ps1           # Skills検証ツール
├── check-encoding.ps1            # エンコーディングチェッカー
├── .gitattributes                # Git改行コード制御
├── .editorconfig                 # エディタ設定
├── README.md                     # このファイル
├── INSTALL.md                    # 詳細インストールガイド
├── QUICKSTART.md                 # クイックスタート
├── COMPATIBILITY.md              # 互換性ガイド
├── ENCODING.md                   # エンコーディングガイド
├── CHANGELOG.md                  # 変更履歴 ★
├── LICENSE                       # MITライセンス ★
└── CLAUDE.md                     # プロジェクト指示
```

★ = v1.1.0で追加

## 🎯 各Skillの詳細

### 1. smart-review-security (Critical優先度)

**検出項目:**
- XSS (Cross-Site Scripting)
- SQLインジェクション
- コマンドインジェクション
- 認証・認可の問題
- 機密情報の露出
- 暗号化の不備
- Float/Double for Money（金額計算の誤差） ★

### 2. smart-review-debug (High優先度)

**検出項目:**
- null/undefined参照エラー
- 型の不一致（`any[]` 検出を含む） ★
- ロジックエラー
- 例外処理の不備
- 非同期処理の問題
- メモリリーク
- **N+1 Query Problem** ★
- **SELECT * Anti-Pattern** ★

### 3. smart-review-quality (Medium優先度)

**検出項目:**
- 循環的複雑度
- コードスメル（長すぎる関数、重複コードなど）
- 設計原則（SOLID、DRY）
- 命名規則
- モジュール化
- パフォーマンスアンチパターン ★

### 4. smart-review-docs (Low優先度)

**検出項目:**
- 関数・クラスのドキュメント
- JSDoc/TSDoc の完全性
- README、API仕様の存在
- インラインコメント
- TODO/FIXMEの管理

## 🆕 v1.1.0 新機能: BugSearch3統合

### 統合内容

- **61個のYAMLファイル** から **168個のルール** を変換・統合
- **66個のJSONファイル** として各Skillに追加
- 言語・フレームワーク・データベース別に自動分類

### 検出力の向上

| 項目 | v1.0.0 | v1.1.0 | 増加率 |
|------|--------|--------|--------|
| **総ルール数** | 200 | 368 | +84% |
| **JavaScript検出** | 50 | 68 | +36% |
| **Python検出** | 40 | 56 | +40% |
| **対応言語** | 3 | 10+ | +233% |

### 新規検出パターン

- **N+1 Query Problem**: ループ内のDBクエリ実行を検出
- **SELECT * Anti-Pattern**: 不要なカラム取得を検出
- **Float for Money**: 金額計算での浮動小数点使用を検出
- **Framework Memory Leaks**: Angular/Reactのメモリリーク検出

## 🛠️ ツール

### インストール

| ツール | プラットフォーム | 特徴 |
|--------|----------------|------|
| `install.ps1` | Windows (PowerShell) | 絵文字対応 |
| `install-safe.ps1` | Windows (PowerShell) | ASCII記号、互換性重視 |
| `install.bat` | Windows (CMD) | Shift-JIS対応 |
| `install.sh` | macOS / Linux | UTF-8対応 |

### 検証

| ツール | 用途 |
|--------|------|
| `validate-skills.ps1` | Skills包括的検証（エンコーディング、JSON構文等） |
| `check-encoding.ps1` | エンコーディング専用チェッカー |

### BugSearch3統合

| ツール | 用途 |
|--------|------|
| `tools/convert-yaml-simple.py` | YAML→JSON変換（依存関係なし） |
| `tools/convert-bugsearch3-rules.ps1` | PowerShell版変換ツール |
| `tools/convert-bugsearch3-rules.sh` | Bash版変換ツール |
| `tools/integrate-bugsearch3-rules.ps1` | ルール統合ツール |

## 📚 ドキュメント

| ドキュメント | 内容 |
|------------|------|
| [INSTALL.md](INSTALL.md) | 詳細なインストールガイド |
| [QUICKSTART.md](QUICKSTART.md) | 5分で始めるクイックスタート |
| [COMPATIBILITY.md](COMPATIBILITY.md) | クロスプラットフォーム互換性 |
| [ENCODING.md](ENCODING.md) | エンコーディングとベストプラクティス |
| [CHANGELOG.md](CHANGELOG.md) | 変更履歴 |
| [docs/BUGSEARCH3-INTEGRATION-GUIDE.md](docs/BUGSEARCH3-INTEGRATION-GUIDE.md) | BugSearch3統合ガイド |
| [docs/YAML-RULES-INTEGRATION.md](docs/YAML-RULES-INTEGRATION.md) | YAML統合の詳細分析 |

## 🎯 使用例

### 包括的レビュー

```
このプロジェクト全体のコードレビューをお願いします。
セキュリティ、デバッグ、品質、ドキュメントの順で分析し、
最後にTODOリストをMarkdownで生成してください。
```

### 特定の観点のみ

```
このプロジェクトのセキュリティ分析をお願いします
```

```
バグがないかチェックしてください
```

```
コードの品質を評価してください
```

### 言語・フレームワーク指定

```
このReactプロジェクトを、React固有のバグパターンも含めてレビューしてください
```

```
このPythonプロジェクトのDjangoコードをチェックしてください
```

### データベース関連

```
src/database/ のMySQLクエリを、N+1問題も含めてレビューしてください
```

## 📈 パフォーマンス

| ルール数 | ファイル数 | 処理時間 | メモリ使用 |
|---------|----------|---------|----------|
| 200（コアのみ） | 100 | ~5秒 | +100KB |
| 368（BugSearch3統合） | 100 | ~8秒 | +500KB |
| 1,000+（カスタム追加） | 100 | ~12秒 | +1MB |

**評価:** 実用上全く問題なし ✅

## 🤝 貢献

貢献を歓迎します！

### 新しい検出パターンの追加

1. 対応するSkillの `patterns.json` または `code-smells.json` を編集
2. パターン、説明、推奨修正を追加
3. テストサンプルで動作確認

### BugSearch3ルールの更新

```bash
# BugSearch3が更新されたら再変換
python tools/convert-yaml-simple.py /path/to/BugSearch3/rules
git add .claude/skills/*/rules-bugsearch3/
git commit -m "chore: Update BugSearch3 rules"
```

詳細は [CONTRIBUTING.md](.claude/skills/smart-review-docs/templates/contributing_template.md) を参照。

## 📝 ライセンス

[MIT License](LICENSE)

Copyright (c) 2025 KEIEI-NET

## 🙏 謝辞

- Claude Code CLI チーム
- BugSearch3 プロジェクト
- すべての貢献者の方々

## 📞 サポート

- **Issues**: [GitHub Issues](https://github.com/KEIEI-NET/smart-review-Skills_Version/issues)
- **ドキュメント**: [Documentation](https://github.com/KEIEI-NET/smart-review-Skills_Version)
- **リポジトリ**: https://github.com/KEIEI-NET/smart-review-Skills_Version

## 🔗 関連リンク

- [Claude Code Documentation](https://docs.claude.com/en/docs/claude-code)
- [BugSearch3 Project](https://github.com/KEIEI-NET/BugSearch3)

---

## 📊 バージョン情報

**現在のバージョン:** v1.1.0
**リリース日:** 2025年11月17日
**対象環境:** Claude Code CLI v1.0+
**推奨Claude:** Sonnet 4.5以上

### バージョン履歴

- **v1.1.0** (2025-11-17): BugSearch3統合（168ルール追加）
- **v1.0.0** (2025-11-17): 初回リリース（4 Skills、200ルール）

詳細は [CHANGELOG.md](CHANGELOG.md) を参照。

---

## ⚠️ 重要な注意事項

1. このシステムは静的解析を行います。動的解析やペネトレーションテストも併用してください。
2. false positiveが発生する可能性があります。最終的な判断は人間が行ってください。
3. プロジェクトの文脈、チームの慣習、ビジネス要件を考慮して結果を解釈してください。

---

**🎉 Production Ready - すぐに使い始められます！**

```bash
# インストール
curl -O https://raw.githubusercontent.com/KEIEI-NET/smart-review-Skills_Version/main/install.sh
chmod +x install.sh
./install.sh

# 使用
claude
> このプロジェクトをレビューしてください
```
