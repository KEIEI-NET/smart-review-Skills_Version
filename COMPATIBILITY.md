# Skills互換性ガイド

## 📋 概要

Smart Review Systemは、Windows、macOS、Linux環境で動作します。このドキュメントでは、各環境での互換性を保証するための規則と検証方法を説明します。

## 🎯 対応環境

| OS | サポート状況 | 備考 |
|----|------------|------|
| Windows 10/11 | ✅ 完全対応 | PowerShell 5.1+ 推奨 |
| macOS 11+ | ✅ 完全対応 | Bash, Zsh対応 |
| Linux (Ubuntu 20.04+) | ✅ 完全対応 | Bash対応 |

| Claude Code CLI | サポート状況 |
|----------------|------------|
| v1.0+ | ✅ 推奨 |

## 📝 ファイル規則

### エンコーディング

| ファイルタイプ | エンコーディング | BOM | 理由 |
|--------------|----------------|-----|------|
| **SKILL.md** | UTF-8 | なし | Claude Codeの標準 |
| **JSON** | UTF-8 | なし | JSON標準仕様 |
| **Markdown** | UTF-8 | なし | Git/GitHub標準 |
| **PowerShell (.ps1)** | UTF-8 | **あり** | PowerShell要件 |
| **Batch (.bat)** | Shift-JIS | なし | Windows標準 |
| **Shell (.sh)** | UTF-8 | なし | Unix標準 |

### 改行コード

| ファイルタイプ | 改行コード | 理由 |
|--------------|----------|------|
| **すべてのSkillsファイル** | LF (`\n`) | クロスプラットフォーム互換性 |
| **PowerShell (.ps1)** | CRLF (`\r\n`) | Windows標準 |
| **Batch (.bat)** | CRLF (`\r\n`) | Windows標準 |
| **Shell (.sh)** | LF (`\n`) | Unix標準 |

**Git設定で自動変換:**
- `.gitattributes` で改行コードを制御
- チェックアウト時に環境に合わせて自動変換

### パス区切り

| 環境 | パス区切り | 例 |
|------|----------|-----|
| **Skillsファイル内** | `/` (スラッシュ) | `src/utils/parser.js` |
| **Windows固有** | `\` (バックスラッシュ) | 使用しない |

**理由:** Claude Codeは両方を理解しますが、`/`がクロスプラットフォームで動作します。

## 🔍 検証ツール

### 1. validate-skills.ps1 - 包括的検証

すべてのSkillsファイルを検証します。

```powershell
.\validate-skills.ps1
```

**チェック項目:**
- ✅ エンコーディング（UTF-8）
- ✅ 改行コード（LF推奨）
- ✅ JSON構文
- ✅ ファイル構造
- ✅ パス区切り
- ✅ 末尾空白

**出力例:**
```
================================
Smart Review Skills - 互換性検証
================================

.\.claude\skills\smart-review-security\SKILL.md
[OK] エンコーディング: UTF-8 without BOM
[OK] 改行コード: LF
[OK] パス区切り: OK

.\.claude\skills\smart-review-security\patterns.json
[OK] エンコーディング: UTF-8 without BOM
[OK] 改行コード: LF
[OK] JSON構文: 正常

================================
検証結果サマリー
================================
総ファイル数: 20
成功: 20
警告: 0
エラー: 0

[SUCCESS] すべてのチェックに合格しました！
```

### 2. check-encoding.ps1 - エンコーディング確認

インストールスクリプトのエンコーディングを確認します。

```powershell
.\check-encoding.ps1
```

## ⚙️ 自動修正設定

### .editorconfig

エディタで自動的に正しい設定を適用します。

**対応エディタ:**
- Visual Studio Code
- IntelliJ IDEA
- Sublime Text
- Atom
- その他多数

**設定内容:**
```ini
# Skillsファイル
[*.md]
charset = utf-8
end_of_line = lf
insert_final_newline = true

[*.json]
charset = utf-8
end_of_line = lf
indent_size = 2
```

### .gitattributes

Gitでの改行コード変換を制御します。

```gitattributes
# すべてのテキストファイルはLF
* text=auto eol=lf

# Skillsファイル
.claude/**/*.md text eol=lf
.claude/**/*.json text eol=lf

# PowerShellはUTF-8 with BOM、CRLF
*.ps1 text working-tree-encoding=UTF-8 eol=crlf

# バッチファイルはCRLF
*.bat text eol=crlf
```

## 🐛 よくある問題と解決策

### 問題1: JSONファイルが読み込めない

**症状:**
```
Error: Unexpected token in JSON
```

**原因:** BOM付きUTF-8、または構文エラー

**解決策:**
```powershell
# 検証
.\validate-skills.ps1

# JSONファイルをUTF-8（BOMなし）で保存し直す
$content = Get-Content patterns.json -Raw
$utf8NoBOM = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("patterns.json", $content, $utf8NoBOM)
```

### 問題2: SKILL.mdが認識されない

**症状:** Claude Codeがスキルを読み込まない

**原因:** エンコーディングまたはYAMLフロントマターの問題

**解決策:**
```powershell
# 1. エンコーディング確認
.\validate-skills.ps1

# 2. YAMLフロントマターの確認
# 正しい形式:
---
name: "smart-review-security"
description: "..."
---
```

### 問題3: Windowsで改行が2重になる

**症状:** ファイルを開くと空行が2倍

**原因:** CRLF → LF → CRLF の二重変換

**解決策:**
```bash
# Gitの設定を確認
git config core.autocrlf

# Skillsファイルの場合、falseを推奨
git config core.autocrlf false

# または input（チェックアウト時は変換しない）
git config core.autocrlf input
```

### 問題4: macOS/Linuxでパスが見つからない

**症状:**
```
File not found: C:\path\to\file
```

**原因:** Windowsパス（バックスラッシュ）が使用されている

**解決策:**
```powershell
# 検証（Windowsパスを検出）
.\validate-skills.ps1

# パスをスラッシュに変更
# 悪い: C:\Users\kenji\file.js
# 良い: src/utils/file.js
```

### 問題5: Git commitで警告が出る

**症状:**
```
warning: CRLF will be replaced by LF
```

**原因:** .gitattributesとファイルの改行コードが不一致

**解決策:**
```bash
# .gitattributesが設定されているか確認
cat .gitattributes

# すべてのファイルを再正規化
git add --renormalize .
git commit -m "Normalize line endings"
```

## 🔧 開発者向けガイド

### 新しいSkillを追加する場合

1. **ファイル作成**
```bash
mkdir -p .claude/skills/my-new-skill
cd .claude/skills/my-new-skill
```

2. **SKILL.md作成**
```markdown
---
name: "my-new-skill"
description: "説明"
---

# My New Skill
...
```

3. **エンコーディング確認**
```powershell
# VS Codeで保存時
# 右下: "UTF-8" を確認
# "UTF-8 with BOM" の場合は "UTF-8" に変更

# または PowerShell で
$content = Get-Content SKILL.md -Raw
$utf8 = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("SKILL.md", $content, $utf8)
```

4. **改行コード確認**
```bash
# Unix系
file SKILL.md
# 出力: SKILL.md: UTF-8 Unicode text

# Windows (PowerShell)
(Get-Content SKILL.md -Raw) -match "`r`n"
# False なら LF、True なら CRLF
```

5. **検証**
```powershell
.\validate-skills.ps1
```

### JSONファイルの追加

```json
{
  "pattern": "example",
  "description": "説明"
}
```

**注意:**
- インデント: スペース2つ
- 末尾カンマなし
- UTF-8（BOMなし）
- LF改行

**検証:**
```powershell
# JSON構文チェック
Get-Content file.json | ConvertFrom-Json

# 包括的チェック
.\validate-skills.ps1
```

## 📊 チェックリスト

新しいSkillまたはファイルを追加する際のチェックリスト：

- [ ] エンコーディング: UTF-8（BOMなし）
- [ ] 改行コード: LF
- [ ] パス区切り: `/` (スラッシュ)
- [ ] JSON構文: エラーなし
- [ ] SKILL.mdのYAMLフロントマター: 正しい形式
- [ ] 必要なファイルすべて存在
- [ ] `.\validate-skills.ps1` でエラーなし
- [ ] 複数の環境でテスト（可能であれば）
  - [ ] Windows
  - [ ] macOS または Linux

## 🌍 国際化対応

### 文字セット

すべてのファイルでUTF-8を使用することで、以下の言語をサポート：
- 日本語
- 英語
- その他のUnicode文字

### ロケール依存の問題

**避けるべき:**
- 日付フォーマットのハードコード（`2025/11/17` vs `11/17/2025`）
- ロケール固有の文字列ソート
- 環境依存のパス（`$HOME` vs `%USERPROFILE%`）

**推奨:**
- ISO 8601形式の日付（`2025-11-17`）
- Unicode正規化
- 相対パスの使用

## 🚀 CI/CD統合

### GitHub Actions例

```yaml
name: Validate Skills

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Validate Skills
        run: |
          pwsh -File validate-skills.ps1

      - name: Check Encoding
        run: |
          pwsh -File check-encoding.ps1
```

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Validating Skills..."
pwsh -File validate-skills.ps1

if [ $? -ne 0 ]; then
    echo "Skills validation failed!"
    exit 1
fi
```

## 📚 参考資料

- [EditorConfig](https://editorconfig.org/)
- [Git Attributes](https://git-scm.com/docs/gitattributes)
- [UTF-8 Everywhere](http://utf8everywhere.org/)
- [Claude Code Documentation](https://docs.claude.com/en/docs/claude-code)

---

**最終更新:** 2025年11月17日
**対象バージョン:** Smart Review System v1.0.0
