# エンコーディングと文字表示ガイド

## 📝 概要

Smart Review Systemのインストールスクリプトには、Windows環境での文字化けや絵文字表示の問題を防ぐため、複数のバージョンを用意しています。

## 🔍 ファイルと推奨エンコーディング

| ファイル | エンコーディング | 用途 |
|---------|----------------|------|
| install.ps1 | UTF-8 with BOM | PowerShell（絵文字使用） |
| install-safe.ps1 | UTF-8 with BOM | PowerShell（ASCII記号のみ） |
| uninstall.ps1 | UTF-8 with BOM | PowerShell（ASCII記号のみ） |
| install.bat | Shift-JIS (CP932) | コマンドプロンプト |
| install.sh | UTF-8 without BOM | Linux/macOS |
| *.md | UTF-8 without BOM | ドキュメント |
| *.json | UTF-8 without BOM | 設定ファイル |

## 🎯 使用するスクリプトの選択

### Windows環境

#### PowerShell 7+ または Windows Terminal使用時
```powershell
.\install.ps1
```
- UTF-8対応が良好
- 絵文字が正しく表示される

#### PowerShell 5.1 または古いコンソール使用時
```powershell
.\install-safe.ps1
```
- 絵文字の代わりにASCII記号を使用
- 互換性が高い

#### コマンドプロンプト使用時
```cmd
install.bat
```
- Shift-JIS対応
- 日本語が正しく表示される

### macOS / Linux環境

```bash
./install.sh
```
- UTF-8 without BOM
- 絵文字対応

## ⚠️ よくある問題と解決策

### 問題1: PowerShellで文字化けが発生

**症状:**
```
�e�X�g
```

**原因:** エンコーディングが正しくない

**解決策:**

```powershell
# 出力エンコーディングを確認
[Console]::OutputEncoding

# UTF-8に設定
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# スクリプトを再実行
.\install-safe.ps1
```

または、プロファイルに追加：

```powershell
# $PROFILE を編集
notepad $PROFILE

# 以下を追加
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
```

### 問題2: 絵文字が□や?で表示される

**症状:**
```
□ OK
? ERROR
```

**原因:** フォントが絵文字に対応していない

**解決策1:** 安全版スクリプトを使用

```powershell
.\install-safe.ps1  # 絵文字の代わりに [OK], [ERROR] を使用
```

**解決策2:** フォントを変更

Windows Terminalの設定:
```json
{
    "profiles": {
        "defaults": {
            "font": {
                "face": "Cascadia Code",
                "size": 11
            }
        }
    }
}
```

推奨フォント:
- Cascadia Code
- MS Gothic
- Consolas

### 問題3: バッチファイルで日本語が文字化け

**症状:**
```
�C���X�g�[���J�n
```

**原因:** UTF-8で保存されている

**解決策:** Shift-JISで保存し直す

**方法1: メモ帳**
1. ファイルを開く
2. 「名前を付けて保存」
3. エンコーディングで「ANSI」を選択
4. 保存

**方法2: PowerShell**
```powershell
$content = Get-Content install.bat -Raw
$sjis = [System.Text.Encoding]::GetEncoding(932)
[System.IO.File]::WriteAllText("install.bat", $content, $sjis)
```

**方法3: Visual Studio Code**
1. ファイルを開く
2. 右下のエンコーディング表示をクリック
3. 「エンコーディング付きで保存」
4. 「Japanese (Shift-JIS)」を選択

### 問題4: GitでPowerShellスクリプトのBOMが消える

**症状:** Gitにコミット後、UTF-8 BOMがなくなる

**解決策:** `.gitattributes` を設定

```bash
# .gitattributes に追加
*.ps1 working-tree-encoding=UTF-8
```

または、コミット前に確認：

```powershell
# BOMを確認
$bytes = [System.IO.File]::ReadAllBytes("install.ps1")
$bytes[0..2]  # EF BB BF なら UTF-8 BOM

# BOMを追加
$content = Get-Content install.ps1 -Raw
$utf8 = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText("install.ps1", $content, $utf8)
```

## 🔧 エンコーディングチェックツール

プロジェクトには、エンコーディングを確認するツールが含まれています：

```powershell
.\check-encoding.ps1
```

**出力例:**
```
================================
エンコーディングチェッカー
================================

[OK] install.ps1
     検出: UTF-8 with BOM
[WARNING] install.bat
     期待: Shift-JIS
     検出: UTF-8 without BOM (推定)

推奨される修正方法:
...
```

## 📊 記号の対応表

| 意味 | 絵文字版 | ASCII版 |
|------|---------|---------|
| 成功 | ✓ | [OK] |
| エラー | ✗ | [ERROR] |
| 警告 | ⚠ | [WARNING] |
| 情報 | ℹ | [INFO] |

## 🌐 環境別の推奨設定

### Windows PowerShell 5.1

**プロファイル設定 ($PROFILE):**
```powershell
# エンコーディング設定
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# フォント設定（レジストリ）
# 推奨: MS Gothic または Consolas
```

**使用スクリプト:**
```powershell
.\install-safe.ps1  # 安全版を推奨
```

### PowerShell 7+ / Windows Terminal

**設定ファイル (settings.json):**
```json
{
    "profiles": {
        "defaults": {
            "font": {
                "face": "Cascadia Code"
            }
        }
    },
    "defaultProfile": "{...PowerShell 7 GUID...}"
}
```

**使用スクリプト:**
```powershell
.\install.ps1  # 絵文字版でOK
```

### コマンドプロンプト

**設定:**
- コードページ: 932 (Shift-JIS)
- フォント: MS Gothic

**使用スクリプト:**
```cmd
install.bat
```

### VS Code統合ターミナル

**設定 (settings.json):**
```json
{
    "terminal.integrated.fontFamily": "Cascadia Code",
    "terminal.integrated.fontSize": 12,
    "files.encoding": "utf8",
    "files.autoGuessEncoding": false
}
```

## 🚀 ベストプラクティス

### 1. スクリプト作成時

```powershell
# PowerShell スクリプト作成
# - VS Code で作成
# - 右下で "UTF-8 with BOM" を確認
# - ファイル保存時に自動的に BOM 付与
```

### 2. 配布時

```
# 配布パッケージに両方含める
- install.ps1        # 新しい環境向け
- install-safe.ps1   # 互換性重視
- install.bat        # コマンドプロンプト向け
```

### 3. ドキュメント

```markdown
# README.md に記載
- PowerShell 7+ → install.ps1
- PowerShell 5.1 → install-safe.ps1
- コマンドプロンプト → install.bat
```

## 📚 参考情報

### PowerShellのエンコーディング

```powershell
# 現在の設定を確認
[Console]::OutputEncoding
$OutputEncoding

# 推奨設定
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
```

### ファイルのBOM確認

```powershell
function Test-BOM {
    param([string]$FilePath)

    $bytes = [System.IO.File]::ReadAllBytes($FilePath)

    if ($bytes.Length -ge 3) {
        if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            return "UTF-8 with BOM"
        }
    }
    return "No BOM or different encoding"
}

Test-BOM "install.ps1"
```

### 一括変換

```powershell
# すべての .ps1 ファイルに BOM を追加
Get-ChildItem *.ps1 | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $utf8 = New-Object System.Text.UTF8Encoding $true
    [System.IO.File]::WriteAllText($_.FullName, $content, $utf8)
}
```

## ✅ チェックリスト

インストールスクリプトを配布する前に：

- [ ] PowerShellスクリプトは UTF-8 with BOM
- [ ] バッチファイルは Shift-JIS
- [ ] 安全版スクリプト（ASCII記号）を用意
- [ ] README.md に環境別の推奨を記載
- [ ] check-encoding.ps1 で確認
- [ ] 複数の環境でテスト
  - [ ] PowerShell 5.1
  - [ ] PowerShell 7
  - [ ] コマンドプロンプト
  - [ ] Windows Terminal

---

**注意:** エンコーディングの問題は環境依存が大きいため、複数の選択肢を提供することが重要です。

---

**最終更新:** 2025年11月17日 13:30 JST
**著作権:** (c) 2025 KEIEI.NET INC.
**作成者:** KENJI OYAMA
