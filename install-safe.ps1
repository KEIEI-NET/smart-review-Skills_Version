#Requires -Version 5.1
################################################################################
# Smart Review System - インストールスクリプト (Windows PowerShell)
# エンコーディング: UTF-8 with BOM
# 絵文字を使わない安全版
################################################################################
#
# このスクリプトは、Smart Review System をプロジェクトにインストールします。
#
# 使用方法:
#   .\install-safe.ps1
#
# オプション:
#   .\install-safe.ps1 -TargetDir "C:\path\to\project"
#   .\install-safe.ps1 -Global
#   .\install-safe.ps1 -DryRun
#   .\install-safe.ps1 -Help
#
################################################################################

[CmdletBinding()]
param(
    [string]$TargetDir = $PWD.Path,
    [switch]$Global = $false,
    [switch]$DryRun = $false,
    [switch]$Help = $false
)

# エラー時に停止
$ErrorActionPreference = "Stop"

# 出力エンコーディングをUTF-8に設定
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# スクリプトのディレクトリ
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

################################################################################
# 関数定義
################################################################################

function Write-Header {
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "Smart Review System Installer" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Show-Help {
    @"
Smart Review System - インストールスクリプト (Windows)

使用方法:
    .\install-safe.ps1 [OPTIONS]

オプション:
    -TargetDir PATH     インストール先ディレクトリを指定（デフォルト: カレントディレクトリ）
    -Global             ホームディレクトリに共通インストール
    -DryRun             実際にインストールせず、実行内容のみ表示
    -Help               このヘルプを表示

例:
    # カレントディレクトリにインストール
    .\install-safe.ps1

    # 特定のディレクトリにインストール
    .\install-safe.ps1 -TargetDir "C:\Projects\MyProject"

    # グローバルインストール
    .\install-safe.ps1 -Global

    # ドライラン
    .\install-safe.ps1 -DryRun

注意:
    このスクリプトは絵文字を使用しない安全版です。
    PowerShell 5.1以上が必要です。
"@
}

function Test-Prerequisites {
    Write-Info "前提条件をチェックしています..."

    # PowerShellバージョンチェック
    $psVersion = $PSVersionTable.PSVersion
    Write-Info "PowerShell バージョン: $psVersion"

    if ($psVersion.Major -lt 5) {
        Write-Warning "PowerShell 5.1以上を推奨します"
    }

    # Claude Code CLI のチェック
    try {
        $claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
        if ($claudeCmd) {
            $claudeVersion = & claude --version 2>&1 | Out-String
            Write-Success "Claude Code CLI: $($claudeVersion.Trim())"
        }
        else {
            Write-Warning "Claude Code CLI が見つかりません"
            Write-Info "Claude Code CLI がインストールされている場合は無視してください"
        }
    }
    catch {
        Write-Warning "Claude Code CLI のチェックに失敗しました"
    }

    Write-Host ""
}

function Test-SourceFiles {
    Write-Info "ソースファイルを検証しています..."

    $sourceSkills = Join-Path $ScriptDir ".claude\skills"

    if (-not (Test-Path $sourceSkills)) {
        Write-ErrorMsg "ソースディレクトリが見つかりません: $sourceSkills"
        Write-Info "このスクリプトは smart-review-system ディレクトリで実行してください"
        throw "ソースディレクトリが見つかりません"
    }

    # 各Skillの存在確認
    $skills = @("smart-review-security", "smart-review-debug", "smart-review-quality", "smart-review-docs")
    $allOk = $true

    foreach ($skill in $skills) {
        $skillPath = Join-Path $sourceSkills $skill
        if (-not (Test-Path $skillPath)) {
            Write-ErrorMsg "Skillが見つかりません: $skill"
            $allOk = $false
            continue
        }

        $skillMd = Join-Path $skillPath "SKILL.md"
        if (-not (Test-Path $skillMd)) {
            Write-ErrorMsg "SKILL.mdが見つかりません: $skill"
            $allOk = $false
        }
    }

    if (-not $allOk) {
        throw "必要なSkillファイルが見つかりません"
    }

    Write-Success "すべてのSkillファイルが確認されました"
    Write-Host ""
}

function New-Directories {
    param([string]$Target)

    Write-Info "ディレクトリを作成しています..."

    $targetSkills = Join-Path $Target ".claude\skills"

    if ($DryRun) {
        Write-Info "[DRY RUN] New-Item -ItemType Directory -Path '$targetSkills' -Force"
        return
    }

    try {
        $null = New-Item -ItemType Directory -Path $targetSkills -Force
        Write-Success "ディレクトリを作成しました: $targetSkills"
    }
    catch {
        Write-ErrorMsg "ディレクトリの作成に失敗しました: $_"
        throw
    }

    Write-Host ""
}

function Copy-Skills {
    param([string]$Target)

    $source = Join-Path $ScriptDir ".claude\skills"
    $targetSkills = Join-Path $Target ".claude\skills"

    Write-Info "Skillsをコピーしています..."

    if ($DryRun) {
        Write-Info "[DRY RUN] Copy-Item -Path '$source\*' -Destination '$targetSkills' -Recurse -Force"
        return
    }

    # 各Skillをコピー
    $skills = @("smart-review-security", "smart-review-debug", "smart-review-quality", "smart-review-docs")

    foreach ($skill in $skills) {
        try {
            $sourcePath = Join-Path $source $skill
            $targetPath = Join-Path $targetSkills $skill

            if (Test-Path $targetPath) {
                Write-Warning "$skill は既に存在します（上書きします）"
                Remove-Item -Path $targetPath -Recurse -Force -ErrorAction Stop
            }

            Copy-Item -Path $sourcePath -Destination $targetPath -Recurse -Force -ErrorAction Stop
            Write-Success "コピー完了: $skill"
        }
        catch {
            Write-ErrorMsg "コピーに失敗しました ($skill): $_"
            throw
        }
    }

    Write-Host ""
}

function Test-Installation {
    param([string]$Target)

    Write-Info "インストールを確認しています..."

    $targetSkills = Join-Path $Target ".claude\skills"
    $skills = @("smart-review-security", "smart-review-debug", "smart-review-quality", "smart-review-docs")
    $allOk = $true

    foreach ($skill in $skills) {
        $skillMd = Join-Path $targetSkills "$skill\SKILL.md"
        if (Test-Path $skillMd) {
            Write-Success "$skill : OK"
        }
        else {
            Write-ErrorMsg "$skill : SKILL.md が見つかりません"
            $allOk = $false
        }
    }

    Write-Host ""

    if ($allOk) {
        Write-Success "すべてのSkillが正常にインストールされました"
        return $true
    }
    else {
        Write-ErrorMsg "一部のSkillのインストールに失敗しました"
        return $false
    }
}

function Show-NextSteps {
    param([string]$Target)

    Write-Host ""
    Write-Host "================================" -ForegroundColor Green
    Write-Host "インストール完了！" -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "次のステップ:"
    Write-Host ""
    Write-Host "1. Claude Code を起動:"
    Write-Host "   PS> cd `"$Target`"" -ForegroundColor Yellow
    Write-Host "   PS> claude" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "2. Skillsをテスト:"
    Write-Host "   > このプロジェクトのセキュリティ分析をお願いします" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "3. ドキュメントを確認:"
    Write-Host "   PS> Get-Content `"$Target\.claude\skills\smart-review-security\SKILL.md`"" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "4. テストサンプルで動作確認（オプション）:"
    Write-Host "   PS> Copy-Item `"$ScriptDir\test\vulnerable-sample.js`" `".\test\`"" -ForegroundColor Yellow
    Write-Host "   PS> claude" -ForegroundColor Yellow
    Write-Host "   > test/vulnerable-sample.js をレビューしてください" -ForegroundColor Yellow
    Write-Host ""

    if ($Global) {
        Write-Host "グローバルインストールされました: $Target" -ForegroundColor Cyan
    }
    Write-Host ""
}

################################################################################
# メイン処理
################################################################################

function Main {
    try {
        # ヘルプ表示
        if ($Help) {
            Show-Help
            return
        }

        # グローバルインストール
        if ($Global) {
            $script:TargetDir = Join-Path $env:USERPROFILE ".claude-skills"
        }

        Write-Header

        if ($DryRun) {
            Write-Warning "ドライランモード（実際にはインストールされません）"
            Write-Host ""
        }

        Write-Info "インストール先: $TargetDir"
        Write-Host ""

        # 前提条件チェック
        Test-Prerequisites

        # ソースファイルの検証
        Test-SourceFiles

        # ディレクトリ作成
        New-Directories -Target $TargetDir

        # Skillsをコピー
        Copy-Skills -Target $TargetDir

        # インストール確認
        if (-not $DryRun) {
            $success = Test-Installation -Target $TargetDir
            if ($success) {
                Show-NextSteps -Target $TargetDir
            }
            else {
                Write-ErrorMsg "インストールに失敗しました"
                exit 1
            }
        }
        else {
            Write-Info "ドライランが完了しました"
            Write-Info "実際にインストールするには -DryRun オプションを外して実行してください"
        }
    }
    catch {
        Write-ErrorMsg "エラーが発生しました: $($_.Exception.Message)"
        Write-Host ""
        Write-Host "詳細なエラー情報:" -ForegroundColor Red
        Write-Host $_.ScriptStackTrace -ForegroundColor Red
        exit 1
    }
}

# スクリプト実行
Main
