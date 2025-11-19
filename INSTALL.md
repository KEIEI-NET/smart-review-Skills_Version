# Smart Review System - インストールガイド

このガイドでは、Smart Review System を他のPCやプロジェクトにインストールする方法を説明します。

## 📋 目次

- [前提条件](#前提条件)
- [インストール方法](#インストール方法)
  - [方法1: 自動インストール（推奨）](#方法1-自動インストール推奨)
  - [方法2: 手動インストール](#方法2-手動インストール)
  - [方法3: GitHubから直接インストール](#方法3-githubから直接インストール)
- [インストールの確認](#インストールの確認)
- [アンインストール](#アンインストール)
- [トラブルシューティング](#トラブルシューティング)

---

## 前提条件

### 必須

- **Claude Code CLI**: バージョン 1.0 以上
- **OS**: Windows 10/11, macOS 11+, Linux (Ubuntu 20.04+)

### 確認方法

```bash
# Claude Codeがインストールされているか確認
claude --version
```

Claude Codeがインストールされていない場合は、[公式ドキュメント](https://docs.claude.com/en/docs/claude-code)を参照してインストールしてください。

---

## インストール方法

### 方法1: 自動インストール（推奨）

自動インストールスクリプトを使用すると、簡単にインストールできます。

#### Windows (PowerShell)

```powershell
# PowerShellを管理者権限で実行
cd path\to\your\project

# インストールスクリプトをダウンロード
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/KEIEI-NET/smart-review-Skills_Version/main/install.ps1" -OutFile "install.ps1"

# スクリプトを実行
.\install.ps1
```

#### Windows (コマンドプロンプト)

```cmd
cd path\to\your\project

REM インストールスクリプトをダウンロード（手動でダウンロードしてください）
REM または install.bat を実行
install.bat
```

#### macOS / Linux

```bash
cd /path/to/your/project

# インストールスクリプトをダウンロード
curl -O https://raw.githubusercontent.com/KEIEI-NET/smart-review-Skills_Version/main/install.sh

# 実行権限を付与
chmod +x install.sh

# スクリプトを実行
./install.sh
```

---

### 方法2: 手動インストール

#### ステップ1: ファイルのダウンロード

**オプションA: ZIPファイルをダウンロード**

1. [リリースページ](https://github.com/KEIEI-NET/smart-review-Skills_Version/releases)から最新版をダウンロード
2. ZIPファイルを解凍

**オプションB: Gitでクローン**

```bash
git clone https://github.com/KEIEI-NET/smart-review-Skills_Version.git
cd smart-review-system
```

#### ステップ2: プロジェクトディレクトリに移動

```bash
cd /path/to/your/target/project
```

#### ステップ3: .claude/skills/ ディレクトリを作成

```bash
# Windows (PowerShell)
New-Item -ItemType Directory -Path ".claude\skills" -Force

# macOS / Linux
mkdir -p .claude/skills
```

#### ステップ4: Skillsをコピー

```bash
# Windows (PowerShell)
Copy-Item -Path "path\to\smart-review-system\.claude\skills\*" -Destination ".claude\skills\" -Recurse -Force

# macOS / Linux
cp -r /path/to/smart-review-system/.claude/skills/* .claude/skills/
```

#### ステップ5: 権限の設定（macOS / Linux のみ）

```bash
chmod -R 755 .claude/skills
```

#### ステップ6: インストールの確認

```bash
# ディレクトリ構造を確認
ls -la .claude/skills/

# 以下のディレクトリが存在するはずです：
# - smart-review-security
# - smart-review-debug
# - smart-review-quality
# - smart-review-docs
```

---

### 方法3: GitHubから直接インストール

プロジェクトをGitサブモジュールとして追加する方法です。

```bash
cd /path/to/your/project

# .claude/skills/ ディレクトリを作成
mkdir -p .claude/skills

# サブモジュールとして追加
git submodule add https://github.com/KEIEI-NET/smart-review-Skills_Version.git .claude/skills/smart-review

# サブモジュールを初期化
git submodule update --init --recursive

# シンボリックリンクを作成（オプション）
cd .claude/skills
ln -s smart-review/.claude/skills/* .
```

#### サブモジュールの更新

```bash
# 最新版に更新
cd .claude/skills/smart-review
git pull origin main

# または、プロジェクトルートから
git submodule update --remote
```

---

## インストールの確認

### 1. ファイル構造の確認

インストール後、以下のディレクトリ構造になっているはずです：

```
your-project/
├── .claude/
│   └── skills/
│       ├── smart-review-security/
│       │   ├── SKILL.md
│       │   ├── patterns.json
│       │   └── cwe-mapping.json
│       ├── smart-review-debug/
│       │   ├── SKILL.md
│       │   ├── checklist.md
│       │   └── common-patterns.json
│       ├── smart-review-quality/
│       │   ├── SKILL.md
│       │   ├── metrics.json
│       │   └── code-smells.json
│       └── smart-review-docs/
│           ├── SKILL.md
│           └── templates/
│               ├── readme_template.md
│               ├── jsdoc_template.md
│               ├── api_template.md
│               └── contributing_template.md
└── (your project files)
```

### 2. Claude Codeで動作確認

```bash
# Claude Codeを起動
claude

# プロンプトで確認
> このプロジェクトのセキュリティ分析をお願いします
```

正常にインストールされている場合、`smart-review-security` Skillが自動的に起動します。

### 2-2. インストールされているSkillsの一覧を確認

**方法1: 自然文で尋ねる（推奨）**

Claude Code内で以下のように尋ねると、利用可能なSkillsが表示されます：

```bash
claude

# プロンプトで尋ねる
> 利用可能なスキルを教えて
> List all available Skills
```

**方法2: ファイルシステムで確認**

```bash
# グローバルインストールの場合
ls -1 ~/.claude/skills/
# または Windows (Git Bash)
ls -1 /c/Users/YOUR_USERNAME/.claude/skills/

# プロジェクトローカルインストールの場合
ls -1 .claude/skills/
```

**方法3: 各Skillの詳細を確認**

```bash
# 特定のSkillの詳細情報を表示
cat ~/.claude/skills/smart-review-security/SKILL.md | head -n 5

# すべてのSkillsの説明を一覧表示
head -n 3 ~/.claude/skills/*/SKILL.md
```

**補足**: `claude skills list` というコマンドは存在しません。Skillsは自動的に読み込まれ、descriptionに基づいて適切なタイミングで起動します。

### 3. テストサンプルで確認（オプション）

```bash
# テストサンプルをプロジェクトにコピー
cp /path/to/smart-review-system/test/vulnerable-sample.js ./test/

# Claude Codeでレビュー
claude

> test/vulnerable-sample.js をレビューしてください
```

期待される結果：
- セキュリティ問題: 6件以上
- デバッグ問題: 6件以上
- 品質問題: 6件以上
- ドキュメント問題: 4件以上

---

## アンインストール

### 完全削除

```bash
# Windows (PowerShell)
Remove-Item -Path ".claude\skills\smart-review-*" -Recurse -Force

# macOS / Linux
rm -rf .claude/skills/smart-review-*
```

### 特定のSkillのみ削除

```bash
# 例: セキュリティSkillのみ削除
# Windows (PowerShell)
Remove-Item -Path ".claude\skills\smart-review-security" -Recurse -Force

# macOS / Linux
rm -rf .claude/skills/smart-review-security
```

### サブモジュールの削除（方法3でインストールした場合）

```bash
# サブモジュールを削除
git submodule deinit -f .claude/skills/smart-review
git rm -f .claude/skills/smart-review
rm -rf .git/modules/.claude/skills/smart-review
```

---

## トラブルシューティング

### Q1. Skillが認識されない

**症状**: Claude Codeを起動してもSkillが使用できない

**解決策**:

1. ファイル構造を確認
```bash
ls -la .claude/skills/smart-review-security/
# SKILL.md が存在するか確認
```

2. SKILL.md のYAMLフロントマターを確認
```bash
head -n 5 .claude/skills/smart-review-security/SKILL.md
# ---
# name: "smart-review-security"
# description: "..."
# ---
# の形式になっているか確認
```

3. Claude Codeを再起動

### Q2. インストールスクリプトが実行できない（Windows）

**症状**: PowerShellスクリプトが「実行ポリシー」エラーで実行できない

**解決策**:

```powershell
# 実行ポリシーを一時的に変更（管理者権限で実行）
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# スクリプトを実行
.\install.ps1

# 実行ポリシーを元に戻す（オプション）
Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope Process
```

または、手動インストールを使用してください。

### Q3. 権限エラー（macOS / Linux）

**症状**: "Permission denied" エラー

**解決策**:

```bash
# ファイルの権限を確認
ls -la .claude/skills/

# 権限を修正
chmod -R 755 .claude/skills/

# 所有者を変更（必要な場合）
sudo chown -R $USER:$USER .claude/skills/
```

### Q4. パターンファイルが読み込めない

**症状**: JSONファイルが正しく読み込まれない

**解決策**:

1. JSONファイルの構文を確認
```bash
# macOS / Linux
cat .claude/skills/smart-review-security/patterns.json | python -m json.tool

# Windows (PowerShell)
Get-Content .claude\skills\smart-review-security\patterns.json | ConvertFrom-Json
```

2. ファイルのエンコーディングを確認（UTF-8であるべき）

### Q5. 複数のプロジェクトで使用したい

**解決策**:

**オプションA: グローバルインストール（推奨）**

Claude Code CLIは `~/.claude/skills` ディレクトリを使用したグローバルSkillsを公式にサポートしています。このディレクトリにインストールすると、すべてのプロジェクトで自動的に利用可能になります。

```bash
# グローバルディレクトリを作成
mkdir -p ~/.claude/skills

# Smart Review Skillsをコピー
cp -r /path/to/smart-review-system/.claude/skills/* ~/.claude/skills/

# 確認
ls -la ~/.claude/skills/
```

これで、どのプロジェクトでもClaude Codeを起動するだけで使用できます。

**オプションB: プロジェクト固有のインストール**

特定のプロジェクトにのみインストールしたい場合は、各プロジェクトでインストールスクリプトを実行してください。

```bash
cd /path/to/your/project
./install.sh  # または install.ps1
```

**オプションC: シンボリックリンクを使用（代替方法）**

カスタムディレクトリから参照したい場合：

```bash
# 共通の場所にインストール
mkdir -p ~/my-custom-skills
cp -r /path/to/smart-review-system/.claude/skills/* ~/my-custom-skills/

# 各プロジェクトでシンボリックリンクを作成
cd /path/to/project1
mkdir -p .claude/skills
ln -s ~/my-custom-skills/* .claude/skills/
```

**推奨:** ほとんどの場合、オプションA（グローバルインストール）が最適です。

### Q6. アップデート方法

**グローバルインストールの場合（推奨）**:

```bash
# 最新版をダウンロード
cd /path/to/smart-review-system
git pull origin main

# グローバルディレクトリに上書きコピー
cp -r .claude/skills/* ~/.claude/skills/
```

すべてのプロジェクトに即座に反映されます。

**プロジェクト固有のインストールの場合**:

1. 最新版をダウンロード
2. 既存のSkillsを削除
3. 新しいバージョンをインストール

**Gitサブモジュールの場合**:

```bash
cd .claude/skills/smart-review
git pull origin main
```

---

## 複数環境でのインストール

### 開発環境と本番環境で分ける

```bash
# 開発環境のみにインストール
cd /path/to/dev/project
./install.sh

# .gitignore に追加して本番環境には含めない
echo ".claude/skills/smart-review-*" >> .gitignore
```

### チーム全体で使用

**方法1: リポジトリに含める**

```bash
# .claude/skills をGitで管理
git add .claude/skills
git commit -m "Add Smart Review Skills"
git push
```

**方法2: セットアップスクリプトで自動インストール**

```bash
# setup.sh を作成
cat > setup.sh << 'EOF'
#!/bin/bash
echo "Installing Smart Review Skills..."
curl -o install.sh https://raw.githubusercontent.com/KEIEI-NET/smart-review-Skills_Version/main/install.sh
chmod +x install.sh
./install.sh
rm install.sh
echo "Installation complete!"
EOF

chmod +x setup.sh
```

チームメンバーは以下を実行：

```bash
./setup.sh
```

---

## カスタマイズ

インストール後、プロジェクト固有のルールを追加できます：

### カスタムパターンの追加

```bash
# セキュリティパターンを編集
nano .claude/skills/smart-review-security/patterns.json

# 新しいパターンを追加
{
  "custom_pattern": [
    {
      "pattern": "your_regex_pattern",
      "description": "説明",
      "severity": "high",
      "recommendation": "推奨修正"
    }
  ]
}
```

### プロジェクト固有のチェックリスト

```bash
# デバッグチェックリストを編集
nano .claude/skills/smart-review-debug/checklist.md

# プロジェクト固有の項目を追加
```

---

## サポート

問題が解決しない場合：

1. [Issues](https://github.com/KEIEI-NET/smart-review-Skills_Version/issues)で既存の問題を検索
2. 新しいIssueを作成（以下の情報を含める）:
   - OS とバージョン
   - Claude Code のバージョン
   - エラーメッセージ
   - 実行したコマンド
   - ディレクトリ構造（`tree .claude` または `ls -R .claude`）

---

## バージョン管理

### 現在のバージョンを確認

```bash
cat .claude/skills/smart-review-security/SKILL.md | head -n 20
# バージョン情報を確認
```

### バージョン固定（推奨）

特定のバージョンを使用する場合：

```bash
# Gitタグを指定してインストール
git clone --branch v1.0.0 https://github.com/KEIEI-NET/smart-review-Skills_Version.git
```

---

**最終更新:** 2025年11月17日 13:30 JST
**対象バージョン:** Smart Review System v1.1.0
**著作権:** (c) 2025 KEIEI.NET INC.
**作成者:** KENJI OYAMA
