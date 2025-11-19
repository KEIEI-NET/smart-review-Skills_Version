# Smart Review System - クイックスタートガイド

5分でSmart Review Systemを使い始めるためのガイドです。

## 📦 インストール

### 推奨: グローバルインストール

すべてのプロジェクトで使用可能になります。

#### macOS / Linux

```bash
# グローバルディレクトリを作成
mkdir -p ~/.claude/skills

# プロジェクトをクローン
git clone https://github.com/KEIEI-NET/smart-review-Skills_Version.git
cd smart-review-Skills_Version

# Skillsをコピー
cp -r .claude/skills/* ~/.claude/skills/
```

#### Windows (PowerShell)

```powershell
# グローバルディレクトリを作成
New-Item -ItemType Directory -Path "$env:USERPROFILE\.claude\skills" -Force

# プロジェクトをクローン
git clone https://github.com/KEIEI-NET/smart-review-Skills_Version.git
cd smart-review-Skills_Version

# Skillsをコピー
Copy-Item -Path ".claude\skills\*" -Destination "$env:USERPROFILE\.claude\skills\" -Recurse -Force
```

### 代替: プロジェクト固有のインストール

#### Windows

```powershell
# PowerShellを管理者権限で起動
cd your-project-directory

# スクリプトをダウンロード
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/KEIEI-NET/smart-review-Skills_Version/main/install.ps1" -OutFile "install.ps1"

# インストール実行
.\install.ps1
```

#### macOS / Linux

```bash
cd /path/to/your/project

# スクリプトをダウンロード
curl -O https://raw.githubusercontent.com/KEIEI-NET/smart-review-Skills_Version/main/install.sh

# 実行権限を付与
chmod +x install.sh

# インストール実行
./install.sh
```

## 🚀 基本的な使い方

### 1. Claude Codeを起動

```bash
cd your-project-directory
claude
```

### 2. レビューを実行

#### 包括的レビュー

```
このプロジェクト全体のコードレビューをお願いします
```

Claudeが自動的に以下を実行します：
1. セキュリティ分析
2. デバッグ分析
3. 品質評価
4. ドキュメントチェック

#### 特定の観点のみ

**セキュリティ分析:**
```
このプロジェクトのセキュリティ分析をお願いします
```

**バグチェック:**
```
バグがないかチェックしてください
```

**品質評価:**
```
コードの品質を評価してください
```

**ドキュメントチェック:**
```
ドキュメントの完全性を確認してください
```

#### 特定のファイル・ディレクトリのみ

```
src/api/ ディレクトリのセキュリティレビューをお願いします
```

```
src/auth/login.js のバグをチェックしてください
```

## 📊 レビュー結果の見方

### 重要度レベル

- **Critical**: 即座に修正が必要（SQLインジェクション、機密情報の露出など）
- **High**: 早急に修正すべき（XSS、null参照エラーなど）
- **Medium**: 計画的に修正（コードスメル、不完全なドキュメントなど）
- **Low**: 将来的に改善（命名規則、軽微な問題など）

### 出力例

```json
{
  "category": "security",
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
      "estimatedEffort": "30m"
    }
  ]
}
```

## 🎯 よくある使い方

### 差分レビュー（Pull Request前）

```
gitで最近変更されたファイルをレビューしてください。
セキュリティとバグに焦点を当ててください。
```

### 新機能追加後のチェック

```
src/features/payment/ ディレクトリの包括的なレビューをお願いします。
特にセキュリティとエラーハンドリングを重点的に確認してください。
```

### リファクタリング前の評価

```
src/legacy/ ディレクトリのコード品質を評価してください。
リファクタリングの優先順位を教えてください。
```

### ドキュメント整備

```
このプロジェクトのドキュメントをチェックして、
不足している部分をリストアップしてください。
```

## 📝 レビュー結果の活用

### TODO リスト生成

```
このプロジェクトの包括的レビューを実行し、
検出された問題を重要度順にTODOリストとして出力してください。
```

### 修正計画の作成

```
レビュー結果に基づいて、1週間で対応できる修正計画を立ててください。
優先度と工数を考慮してください。
```

## 🧪 動作確認（テストサンプル）

インストール後、テストサンプルで動作確認できます：

```bash
# テストサンプルをコピー
cp /path/to/smart-review-system/test/vulnerable-sample.js ./test/

# Claude Codeで確認
claude
```

```
test/vulnerable-sample.js をレビューしてください
```

期待される結果：
- セキュリティ問題: 6件以上検出
- デバッグ問題: 6件以上検出
- 品質問題: 6件以上検出
- ドキュメント問題: 4件以上検出

## 💡 Tips

### 1. レビューの粒度を調整

**大まかなチェック:**
```
このプロジェクトの主要な問題を洗い出してください
```

**詳細なチェック:**
```
このファイルを一行ずつ詳しくレビューしてください
```

### 2. 特定の問題に絞る

```
XSSの脆弱性のみをチェックしてください
```

```
非同期処理のエラーハンドリングを重点的に確認してください
```

### 3. 学習目的での利用

```
検出された問題について、なぜそれが問題なのか、
どう修正すべきか、具体的な例を含めて説明してください
```

## 🔧 カスタマイズ

プロジェクト固有のルールを追加できます：

```bash
# セキュリティパターンを編集
nano .claude/skills/smart-review-security/patterns.json
```

詳細は [INSTALL.md](INSTALL.md#カスタマイズ) を参照してください。

## 📚 さらに詳しく

- **完全なインストールガイド**: [INSTALL.md](INSTALL.md)
- **詳細な使い方**: [README.md](README.md)
- **各Skillの仕様**:
  - [Security](.claude/skills/smart-review-security/SKILL.md)
  - [Debug](.claude/skills/smart-review-debug/SKILL.md)
  - [Quality](.claude/skills/smart-review-quality/SKILL.md)
  - [Documentation](.claude/skills/smart-review-docs/SKILL.md)

## 🆘 トラブルシューティング

### Skillが認識されない

```bash
# ファイル構造を確認
ls -la .claude/skills/

# 必要なファイルが存在するか確認
ls -la .claude/skills/smart-review-security/
```

### 権限エラー（macOS/Linux）

```bash
chmod -R 755 .claude/skills/
```

### PowerShell実行ポリシーエラー（Windows）

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\install.ps1
```

詳細なトラブルシューティングは [INSTALL.md](INSTALL.md#トラブルシューティング) を参照してください。

## 🗑️ アンインストール

### Windows

```powershell
.\uninstall.ps1
```

### macOS / Linux

```bash
./uninstall.sh
```

または手動で削除：

```bash
rm -rf .claude/skills/smart-review-*
```

---

**これで準備完了です！** 🎉

早速プロジェクトをレビューしてみましょう！

```bash
claude
> このプロジェクトのセキュリティ分析をお願いします
```

---

**最終更新:** 2025年11月17日 13:30 JST
**著作権:** (c) 2025 KEIEI.NET INC.
**作成者:** KENJI OYAMA
