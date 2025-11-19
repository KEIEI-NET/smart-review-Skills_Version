# Smart Review System - GitHub Actions統合実装計画

**ドキュメントバージョン:** 1.0.0
**作成日:** 2025年11月18日 (JST)
**ステータス:** 計画段階（未実装）
**著作権:** (c) 2025 KEIEI.NET INC.
**作成者:** KENJI OYAMA

---

## 📋 目次

- [概要](#概要)
- [実装可能性](#実装可能性)
- [技術要件](#技術要件)
- [実装フェーズ](#実装フェーズ)
- [ワークフロー設計](#ワークフロー設計)
- [コスト試算](#コスト試算)
- [セキュリティ考慮事項](#セキュリティ考慮事項)
- [制約事項・課題](#制約事項課題)
- [実装手順](#実装手順)
- [参考資料](#参考資料)

---

## 概要

Smart Review System SkillsをGitHub Actionsに統合し、CI/CDパイプラインで自動コードレビューを実現する実装計画。

### 目的

1. **自動化**: PRオープン時に4 Skillsによる包括的レビューを自動実行
2. **品質保証**: すべてのコミットでSkills構造とエンコーディングを検証
3. **継続的更新**: BugSearch3ルールの定期的な自動更新
4. **インタラクティブ**: `@claude`メンションによる対話的レビュー

### 対象読者

- プロジェクト管理者
- CI/CDパイプライン構築担当者
- 将来の実装担当者

---

## 実装可能性

### ✅ 結論: 条件付き可能

GitHub ActionsでSmart Review System Skillsを使用することは**技術的に可能**です。

### 根拠

1. **公式サポート**: Claude Code CLIはGitHub Actionsを公式にサポート（2025年現在）
2. **既存事例**: プロジェクト内に既にCI/CD関連ドキュメントが存在
   - `TODO.md` - GitHub Actionsワークフロー作成タスク
   - `COMPATIBILITY.md` - Validate Skills例
   - `docs/BUGSEARCH3-INTEGRATION-GUIDE.md` - ルール更新ワークフロー例
3. **実証済み**: Anthropic公式アクション `anthropics/claude-code-action@v1` が利用可能

### 条件

- Anthropic API Key（有効なサブスクリプション）
- GitHubリポジトリ管理者権限（GitHubアプリインストール）
- 適切なシークレット・権限設定

---

## 技術要件

### 必須要件

| 項目 | 要件 | 備考 |
|------|------|------|
| **GitHubリポジトリ** | public/private両方対応 | - |
| **Anthropic API Key** | 有効なAPIキー | フェーズ2-4で必須 |
| **リポジトリ権限** | 管理者権限 | GitHubアプリインストールに必要 |
| **Claude Code CLI** | v1.0以上 | 最新版推奨 |

### 推奨要件

| 項目 | 要件 | 理由 |
|------|------|------|
| **モデル** | Sonnet 4.5以上 | 高精度分析のため |
| **Git LFS** | 導入 | 大量のルールファイル管理（オプション） |
| **PowerShell** | 7.0以上 | Windowsランナー使用時 |

### 対応環境

| ランナー | 対応状況 | 備考 |
|---------|---------|------|
| `ubuntu-latest` | ✅ 推奨 | 最速・最安定 |
| `windows-latest` | ✅ 対応 | PowerShell必須 |
| `macos-latest` | ✅ 対応 | - |

---

## 実装フェーズ

### フェーズ1: 基本検証ワークフロー【最優先・推奨】

**工数:** 1時間
**コスト:** 無料（Public）/ 無料枠内（Private）
**依存:** なし

#### 実装内容

- **ファイル:** `.github/workflows/validate.yml`
- **機能:**
  - Skills構造検証（`validate-skills.ps1`）
  - エンコーディングチェック（`check-encoding.ps1`）
  - JSON構文チェック（`patterns.json`, `cwe-mapping.json`など）
- **トリガー:** `push`, `pull_request`

#### 期待される成果

- すべてのコミットでSkills構造の整合性を自動検証
- UTF-8エンコーディング違反を即座に検出
- JSON構文エラーを早期発見

---

### フェーズ2: インタラクティブレビュー【推奨】

**工数:** 30分
**コスト:** 使用時のみ（$0.05-0.20/レビュー）
**依存:** Anthropic API Key

#### 実装内容

- **ファイル:** `.github/workflows/claude-interactive.yml`
- **機能:**
  - `@claude`メンションでSkills起動
  - PR/Issueコメントで対話的レビュー
  - 4 Skills（Security/Debug/Quality/Docs）を自然文で指定可能
- **トリガー:** `issue_comment`, `pull_request_review_comment`

#### 期待される成果

- レビュー対象を柔軟に指定可能
- 対話的なコードレビュー体験
- 必要な時だけAPIコストが発生（コスト効率的）

#### 使用例

```
# PRコメントで使用
@claude このPRを包括的にレビューしてください

# 特定のSkillのみ実行
@claude セキュリティ分析をお願いします
@claude test/auth.js のバグを検出してください
```

---

### フェーズ3: PR自動レビュー【オプション】

**工数:** 1-2時間
**コスト:** PR 1回あたり$0.05-0.20
**依存:** Anthropic API Key

#### 実装内容

- **ファイル:** `.github/workflows/smart-review-pr.yml`
- **機能:**
  - PRオープン時に4 Skillsを自動実行
  - 結果をPRコメントに投稿
  - Security → Debug → Quality → Docs の順で実行
  - 各Skillの結果をMarkdown形式で整形
- **トリガー:** `pull_request` (types: `[opened, synchronize]`)

#### 期待される成果

- 完全自動化されたコードレビュー
- 一貫したレビュー品質
- レビュー待機時間の削減

#### 注意事項

- **コスト**: すべてのPRで実行されるため、月間コストが増加
- **時間**: 1 PRあたり2-5分の実行時間
- **推奨**: 大規模プロジェクトや頻繁なPRがある場合は、フェーズ2（インタラクティブ）を優先

---

### フェーズ4: BugSearch3ルール定期更新【オプション】

**工数:** 1時間
**コスト:** 月1回実行（無料枠内）
**依存:** なし

#### 実装内容

- **ファイル:** `.github/workflows/update-bugsearch3.yml`
- **機能:**
  - 月次スケジュールでBugSearch3リポジトリをクローン
  - `tools/convert-bugsearch3-rules.ps1`（または`.py`）を実行
  - 変更があれば自動的にPR作成
- **トリガー:** `schedule` (cron: `0 0 1 * *` - 毎月1日)

#### 期待される成果

- BugSearch3の最新セキュリティルールを自動反映
- 手動更新作業の削減
- ルール更新の追跡可能性（PR経由）

---

## ワークフロー設計

### フェーズ1: validate.yml

```yaml
name: Validate Skills

on:
  push:
    branches: ['**']
  pull_request:
    branches: ['main', 'develop']

jobs:
  validate:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup PowerShell
        shell: pwsh
        run: |
          $PSVersionTable.PSVersion

      - name: Validate Skills Structure
        shell: pwsh
        run: |
          if (Test-Path "validate-skills.ps1") {
            ./validate-skills.ps1
          } else {
            Write-Host "validate-skills.ps1 not found, skipping..."
          }

      - name: Check Encoding
        shell: pwsh
        run: |
          if (Test-Path "check-encoding.ps1") {
            ./check-encoding.ps1
          } else {
            Write-Host "check-encoding.ps1 not found, skipping..."
          }

      - name: Validate JSON Files
        shell: pwsh
        run: |
          Get-ChildItem -Path ".claude/skills" -Recurse -Filter "*.json" | ForEach-Object {
            Write-Host "Validating $($_.FullName)..."
            $content = Get-Content $_.FullName -Raw
            try {
              $content | ConvertFrom-Json | Out-Null
              Write-Host "✅ $($_.Name) is valid JSON"
            } catch {
              Write-Error "❌ $($_.Name) is invalid JSON: $_"
              exit 1
            }
          }
```

**特徴:**
- PowerShellスクリプトの存在チェック（柔軟性）
- JSON構文検証を直接実行
- クロスプラットフォーム対応（`pwsh`使用）

---

### フェーズ2: claude-interactive.yml

```yaml
name: Claude Interactive Review

on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]

jobs:
  claude-interactive:
    # @claudeメンションがある場合のみ実行
    if: contains(github.event.comment.body, '@claude')

    runs-on: ubuntu-latest

    permissions:
      contents: write
      pull-requests: write
      issues: write

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Install Skills globally
        run: |
          mkdir -p ~/.claude/skills
          cp -r .claude/skills/* ~/.claude/skills/

      - name: Run Claude Code
        uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

**特徴:**
- `@claude`メンションでのみ実行（コスト最適化）
- Skillsをグローバルディレクトリにコピー
- 公式アクション使用

---

### フェーズ3: smart-review-pr.yml

```yaml
name: Smart Review - PR Auto Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  smart-review:
    runs-on: ubuntu-latest

    permissions:
      contents: read
      pull-requests: write

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Install Skills globally
        run: |
          mkdir -p ~/.claude/skills
          cp -r .claude/skills/* ~/.claude/skills/

      - name: Run Smart Review
        uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            このPRを包括的にレビューしてください。

            以下の4つの観点から分析し、結果をMarkdown形式で整理してください：
            1. セキュリティ（smart-review-security）
            2. バグ・ロジックエラー（smart-review-debug）
            3. コード品質（smart-review-quality）
            4. ドキュメント（smart-review-docs）

            各Skillの結果を以下の形式で報告：

            ## [Skill名] レビュー結果

            **検出された問題数:** X件

            ### 問題詳細

            - **[優先度]** ファイル名:行番号 - 問題の説明
              - 推奨修正: ...
          claude_args: "--max-turns 5"
```

**特徴:**
- 構造化されたプロンプト（一貫した出力形式）
- `--max-turns`でコスト制御
- PRコメントに自動投稿

---

### フェーズ4: update-bugsearch3.yml

```yaml
name: Update BugSearch3 Rules

on:
  schedule:
    - cron: '0 0 1 * *'  # 毎月1日 00:00 UTC
  workflow_dispatch:  # 手動実行も可能

jobs:
  update-rules:
    runs-on: ubuntu-latest

    permissions:
      contents: write
      pull-requests: write

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Clone BugSearch3
        run: |
          git clone https://github.com/KEIEI-NET/BugSearch3.git

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install pyyaml

      - name: Convert Rules
        run: |
          python tools/convert-yaml-simple.py BugSearch3/services/analysis-service-go/rules

      - name: Check for changes
        id: changes
        run: |
          if [[ -n $(git status --porcelain) ]]; then
            echo "has_changes=true" >> $GITHUB_OUTPUT
          else
            echo "has_changes=false" >> $GITHUB_OUTPUT
          fi

      - name: Create Pull Request
        if: steps.changes.outputs.has_changes == 'true'
        env:
          GH_TOKEN: ${{ github.token }}
        run: |
          git config user.name github-actions
          git config user.email github-actions@github.com

          BRANCH_NAME="update-bugsearch3-rules-$(date +%Y%m%d)"
          git checkout -b "$BRANCH_NAME"

          git add .claude/skills/*/rules-bugsearch3/
          git commit -m "chore: Update BugSearch3 rules (automated)"
          git push origin "$BRANCH_NAME"

          gh pr create \
            --title "Update BugSearch3 rules ($(date +%Y-%m-%d))" \
            --body "Automated update from BugSearch3 repository.

          **Updated rules:**
          $(git diff --name-only HEAD~1 HEAD | grep rules-bugsearch3)

          **Review checklist:**
          - [ ] Verify rule syntax
          - [ ] Test with sample code
          - [ ] Check for breaking changes" \
            --label "automated,dependencies"
```

**特徴:**
- `workflow_dispatch`で手動実行も可能
- 変更検出ロジック（無駄なPR作成を防止）
- PR本文に変更されたファイルを自動リスト化

---

## 認証・シークレット管理

### 必須シークレット

| シークレット名 | 用途 | 必須フェーズ | 取得方法 |
|--------------|------|------------|---------|
| `ANTHROPIC_API_KEY` | Claude APIアクセス | フェーズ2-3 | https://console.anthropic.com/ |
| `GITHUB_TOKEN` | PR作成、コミット権限 | フェーズ4 | 自動提供（`github.token`） |

### シークレット設定手順

1. GitHubリポジトリページを開く
2. **Settings** → **Secrets and variables** → **Actions**
3. **New repository secret** をクリック
4. Name: `ANTHROPIC_API_KEY`
5. Secret: APIキーを貼り付け
6. **Add secret** をクリック

### 権限設定

各ワークフローで必要な権限：

```yaml
permissions:
  contents: write        # ファイル変更、ブランチ作成
  pull-requests: write   # PR作成・コメント
  issues: write          # Issue対応（フェーズ2のみ）
```

**最小権限原則**: 各ワークフローで必要最小限の権限のみを付与

---

## コスト試算

### GitHub Actions

| リポジトリ種類 | 無料枠 | 超過料金 |
|--------------|--------|---------|
| Public | 無制限 | 無料 |
| Private（Free） | 2,000分/月 | $0.008/分 |
| Private（Pro） | 3,000分/月 | $0.008/分 |
| Private（Team） | 3,000分/月 | $0.008/分 |
| Private（Enterprise） | 50,000分/月 | $0.008/分 |

### Claude API

| モデル | 入力トークン単価 | 出力トークン単価 | 1レビュー想定コスト |
|-------|---------------|----------------|------------------|
| Claude Sonnet 4.5 | $3/1M tokens | $15/1M tokens | $0.05-0.20 |
| Claude Opus 4 | $15/1M tokens | $75/1M tokens | $0.25-1.00 |

### 月間コスト例

#### シナリオ1: Publicリポジトリ、月50 PR、フェーズ1+2
- GitHub Actions: **$0**（無制限）
- Claude API: $2.50-10.00（インタラクティブレビュー 半数のPRで使用）
- **合計: $2.50-10.00**

#### シナリオ2: Privateリポジトリ、月50 PR、フェーズ1+3
- GitHub Actions: $0-5（無料枠内で収まる可能性高）
- Claude API: $2.50-10.00（全PRで自動レビュー）
- **合計: $2.50-15.00**

#### シナリオ3: Privateリポジトリ、月100 PR、全フェーズ
- GitHub Actions: $5-10
- Claude API: $10.00-30.00
- **合計: $15.00-40.00**

### コスト最適化戦略

1. **フェーズ2（インタラクティブ）を優先**: 必要な時だけ実行
2. **`--max-turns`制限**: プロンプトで`claude_args: "--max-turns 3"`を設定
3. **特定ブランチのみ**: `main`, `develop`へのPRのみ自動レビュー
4. **ファイルフィルタ**: 重要ファイル（`src/**/*.js`など）のみ対象

---

## セキュリティ考慮事項

### 1. シークレット管理

#### ❌ 絶対に避けること
```yaml
# 悪い例: APIキーをハードコード
env:
  ANTHROPIC_API_KEY: "sk-ant-api03-..."  # 絶対ダメ！
```

#### ✅ 推奨方法
```yaml
# 良い例: GitHub Secretsを使用
env:
  ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

### 2. ログへの露出防止

```yaml
- name: Mask sensitive data
  run: |
    echo "::add-mask::${{ secrets.ANTHROPIC_API_KEY }}"
```

### 3. 最小権限原則

```yaml
permissions:
  contents: read  # 読み取りのみで十分な場合
```

### 4. 外部依存の検証

```yaml
- name: Verify BugSearch3 repository
  run: |
    # 信頼できるソースからのみクローン
    if [[ "$BUGSEARCH3_REPO" != "https://github.com/KEIEI-NET/BugSearch3.git" ]]; then
      echo "Untrusted repository"
      exit 1
    fi
```

### 5. フォークからのPR対策

```yaml
# フォークからのPRではシークレットを使用しない
if: github.event.pull_request.head.repo.full_name == github.repository
```

---

## 制約事項・課題

### 既知の制約

#### 1. API制限
- **Claude API**: レート制限あり（Tier依存）
- **回避策**: `--max-turns`制限、リトライロジック

#### 2. 実行時間
- **GitHub Actions**: ジョブあたり最大6時間
- **通常**: 1レビュー 2-5分（大規模コードベースでは10-15分）

#### 3. 並行実行
- **制限**: 同時実行ジョブ数（Planによる）
- **影響**: 複数PR同時オープン時に待機発生

### Smart Review System固有の課題

#### 1. Skills認識

**問題**: GitHub Actionsランナー上でSkillsが自動読み込みされない

**解決策**:
```yaml
- name: Install Skills globally
  run: |
    mkdir -p ~/.claude/skills
    cp -r .claude/skills/* ~/.claude/skills/
```

#### 2. エンコーディング

**問題**: PowerShellスクリプト（UTF-8 with BOM）とSkills MD（UTF-8 without BOM）の混在

**現状**: `.gitattributes`で制御済み、問題なし

#### 3. パス区切り

**問題**: Windows `\` vs Linux/macOS `/`

**解決策**: Skills内で常に `/` を使用（現在対応済み）

#### 4. BugSearch3更新の安全性

**問題**: 上流リポジトリの変更を自動的に取り込むリスク

**解決策**:
- PR経由で取り込み（即座にmainへマージしない）
- レビュープロセスを必須化

---

## 実装手順

### ステップ1: 事前準備（15分）

#### 1.1 Anthropic API Key取得（フェーズ2-3で必須）

```bash
# 1. https://console.anthropic.com/ にアクセス
# 2. API Keys → Create Key
# 3. キーをコピー（一度しか表示されない）
```

#### 1.2 GitHubシークレット設定

```bash
# 1. GitHubリポジトリページを開く
# 2. Settings → Secrets and variables → Actions
# 3. New repository secret
# 4. Name: ANTHROPIC_API_KEY
# 5. Secret: 取得したAPIキーを貼り付け
```

---

### ステップ2: フェーズ1実装（1時間）

#### 2.1 ディレクトリ作成

```bash
mkdir -p .github/workflows
```

#### 2.2 ワークフローファイル作成

**ファイル:** `.github/workflows/validate.yml`

```yaml
# 上記「フェーズ1: validate.yml」の内容をコピー
```

#### 2.3 動作確認

```bash
git add .github/workflows/validate.yml
git commit -m "ci: Add Skills validation workflow"
git push origin main

# GitHub ActionsタブでWorkflowの実行を確認
```

---

### ステップ3: フェーズ2実装（30分）

#### 3.1 GitHubアプリインストール（推奨）

**方法A: Claude CLI経由（推奨）**
```bash
claude
> /install-github-app
```

**方法B: 手動**
```bash
# 1. https://github.com/apps/claude にアクセス
# 2. Install
# 3. リポジトリを選択
# 4. Install完了
```

#### 3.2 ワークフローファイル作成

**ファイル:** `.github/workflows/claude-interactive.yml`

```yaml
# 上記「フェーズ2: claude-interactive.yml」の内容をコピー
```

#### 3.3 動作確認

```bash
# 1. テストPRを作成
git checkout -b test-interactive-review
echo "test" > test.txt
git add test.txt
git commit -m "test: Interactive review"
git push origin test-interactive-review
gh pr create --title "Test Interactive Review" --body "Testing @claude integration"

# 2. PRコメントで実行
# PRページで以下をコメント:
# @claude このPRをレビューしてください

# 3. Claudeの応答を確認
```

---

### ステップ4: フェーズ3実装（1-2時間、オプション）

#### 4.1 ワークフローファイル作成

**ファイル:** `.github/workflows/smart-review-pr.yml`

```yaml
# 上記「フェーズ3: smart-review-pr.yml」の内容をコピー
```

#### 4.2 動作確認

```bash
# テストPRを作成（自動的にレビューが実行される）
git checkout -b test-auto-review
echo "test auto review" > test-auto.txt
git add test-auto.txt
git commit -m "test: Auto review"
git push origin test-auto-review
gh pr create --title "Test Auto Review" --body "Testing automatic review"

# PRページでコメントを確認
```

---

### ステップ5: フェーズ4実装（1時間、オプション）

#### 5.1 変換スクリプトの確認

```bash
# Python版の存在確認
ls -la tools/convert-yaml-simple.py

# または PowerShell版
ls -la tools/convert-bugsearch3-rules.ps1
```

#### 5.2 ワークフローファイル作成

**ファイル:** `.github/workflows/update-bugsearch3.yml`

```yaml
# 上記「フェーズ4: update-bugsearch3.yml」の内容をコピー
```

#### 5.3 手動実行テスト

```bash
# GitHub Actions → update-bugsearch3.yml → Run workflow
# 「Run workflow」ボタンをクリックして手動実行

# 実行結果を確認:
# - PRが作成されたか
# - ルールファイルが更新されたか
```

---

### ステップ6: ドキュメント更新（30分）

#### 6.1 README.md更新

```markdown
## CI/CD統合

このプロジェクトはGitHub Actionsに対応しています。

### ワークフロー

- **Validate Skills** - すべてのPush/PRでSkills構造を検証
- **Claude Interactive** - `@claude`メンションで対話的レビュー
- **Smart Review PR** - PRオープン時に自動レビュー（オプション）
- **Update BugSearch3** - 月次でルール更新（オプション）

詳細は [docs/github-actions-integration-plan.md](docs/github-actions-integration-plan.md) を参照。
```

#### 6.2 INSTALL.md更新

「CI/CD統合」セクションを追加（既存のQ&Aセクションの後）:

```markdown
## CI/CD統合

### GitHub Actionsでの使用

このプロジェクトはGitHub Actionsに対応しています。

詳細な実装手順は [docs/github-actions-integration-plan.md](docs/github-actions-integration-plan.md) を参照してください。

### クイックセットアップ

1. Anthropic API Keyを取得
2. GitHubシークレットに `ANTHROPIC_API_KEY` を追加
3. `.github/workflows/validate.yml` を作成（フェーズ1）
4. GitHubアプリをインストール（フェーズ2）

### 使用方法

- **自動検証**: すべてのPush/PRで自動実行
- **対話的レビュー**: PRコメントで `@claude このPRをレビューして`
```

#### 6.3 バッジ追加（README.md冒頭）

```markdown
# Smart Review System

[![Validate Skills](https://github.com/KEIEI-NET/smart-review-Skills_Version/workflows/Validate%20Skills/badge.svg)](https://github.com/KEIEI-NET/smart-review-Skills_Version/actions)
```

---

## 推奨実装パターン

### パターンA: 最小構成（即座に開始可能）

**対象:** すべてのプロジェクト

**フェーズ:** 1のみ

**工数:** 1時間

**コスト:** $0

**内容:**
- Skills構造検証
- エンコーディングチェック
- JSON構文チェック

**メリット:**
- コスト無料
- 品質保証の基盤確立
- 今後の拡張の土台

---

### パターンB: 実用構成（推奨）

**対象:** 中規模プロジェクト、コスト意識的

**フェーズ:** 1 + 2

**工数:** 1.5時間

**コスト:** $2.50-10.00/月

**内容:**
- パターンAの内容
- インタラクティブレビュー（`@claude`）

**メリット:**
- 必要な時だけレビュー実行（コスト効率的）
- 柔軟なレビュー対象指定
- 対話的な改善提案

---

### パターンC: フル自動化構成

**対象:** 大規模プロジェクト、品質最優先

**フェーズ:** 1 + 2 + 3 + 4

**工数:** 3-5時間

**コスト:** $15.00-40.00/月

**内容:**
- パターンBの内容
- PR自動レビュー
- BugSearch3定期更新

**メリット:**
- 完全自動化
- 一貫したレビュー品質
- 最新ルールの自動反映

---

## トラブルシューティング

### Q1. Skillsが認識されない

**症状**: ワークフロー実行時に「Skill not found」エラー

**解決策**:

```yaml
# Skillsを明示的にグローバルディレクトリにコピー
- name: Install Skills globally
  run: |
    mkdir -p ~/.claude/skills
    cp -r .claude/skills/* ~/.claude/skills/
    ls -la ~/.claude/skills/  # 確認
```

---

### Q2. APIキーエラー

**症状**: "Invalid API key" または "Unauthorized"

**解決策**:

1. シークレットが正しく設定されているか確認
   ```bash
   # Settings → Secrets and variables → Actions
   # ANTHROPIC_API_KEY が存在するか確認
   ```

2. APIキーの有効性を確認
   ```bash
   curl https://api.anthropic.com/v1/messages \
     -H "x-api-key: YOUR_API_KEY" \
     -H "anthropic-version: 2023-06-01"
   ```

3. キーを再生成して再設定

---

### Q3. PRコメントでClaudeが反応しない

**症状**: `@claude`メンションしてもワークフローが起動しない

**原因と解決策**:

1. **ワークフローファイルが存在しない**
   ```bash
   ls -la .github/workflows/claude-interactive.yml
   ```

2. **GitHubアプリがインストールされていない**
   ```bash
   # https://github.com/apps/claude でインストール
   ```

3. **条件式のミス**
   ```yaml
   # 正しい条件式を確認
   if: contains(github.event.comment.body, '@claude')
   ```

---

### Q4. BugSearch3更新が失敗する

**症状**: "Repository not found" または変換エラー

**解決策**:

1. **BugSearch3リポジトリのアクセス権限確認**
   ```bash
   git clone https://github.com/KEIEI-NET/BugSearch3.git
   # Privateリポジトリの場合、Personal Access Token必要
   ```

2. **変換スクリプトのパス確認**
   ```bash
   ls -la tools/convert-yaml-simple.py
   # または
   ls -la tools/convert-bugsearch3-rules.ps1
   ```

3. **依存関係のインストール**
   ```yaml
   - name: Install dependencies
     run: pip install pyyaml
   ```

---

### Q5. ワークフロー実行時間が長すぎる

**症状**: 1レビューに10分以上かかる

**解決策**:

1. **`--max-turns`制限を追加**
   ```yaml
   claude_args: "--max-turns 3"
   ```

2. **対象ファイルを絞る**
   ```yaml
   on:
     pull_request:
       paths:
         - 'src/**/*.js'
         - 'src/**/*.ts'
   ```

3. **Skillを段階的に実行**
   ```yaml
   # Security Skillのみ実行
   prompt: "セキュリティ分析のみお願いします"
   ```

---

## 参考資料

### 公式ドキュメント

- [Claude Code - GitHub Actions Integration](https://docs.claude.com/en/docs/claude-code/github-actions)
- [Anthropic API Documentation](https://docs.anthropic.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

### プロジェクト内ドキュメント

- [TODO.md](../TODO.md) - CI/CD統合タスク
- [COMPATIBILITY.md](../COMPATIBILITY.md) - Validate Skills例
- [docs/BUGSEARCH3-INTEGRATION-GUIDE.md](./BUGSEARCH3-INTEGRATION-GUIDE.md) - ルール更新例

### 外部リソース

- [anthropics/claude-code-action](https://github.com/anthropics/claude-code-action) - 公式アクション
- [GitHub Apps - Claude](https://github.com/apps/claude) - GitHubアプリ

---

## 更新履歴

| バージョン | 日付 | 変更内容 | 作成者 |
|-----------|------|---------|-------|
| 1.0.0 | 2025-11-18 | 初版作成 | KENJI OYAMA |

---

## ライセンス・著作権

**著作権:** (c) 2025 KEIEI.NET INC.
**作成者:** KENJI OYAMA
**ライセンス:** MIT License（プロジェクトルートのLICENSEファイルを参照）

---

**注意事項:**
- このドキュメントは計画段階のものであり、実装は未完了です
- 実装時は最新のClaude Code CLIドキュメントを確認してください
- API料金やGitHub Actions料金は変更される可能性があります
- 実装前にテスト環境での検証を推奨します

**質問・フィードバック:**
- Issues: https://github.com/KEIEI-NET/smart-review-Skills_Version/issues
- Discussions: https://github.com/KEIEI-NET/smart-review-Skills_Version/discussions
