################################################################################
# Smart Review System - インストールスクリプト (Windows PowerShell)
################################################################################
#
# このスクリプトは、Smart Review System をプロジェクトにインストールします。
#
# 使用方法:
#   .\install.ps1
#
# オプション:
#   .\install.ps1 -TargetDir "C:\path\to\project"
#   .\install.ps1 -Global
#   .\install.ps1 -DryRun
#   .\install.ps1 -Help
#
################################################################################

param(
    [string]$TargetDir = $PWD.Path,
    [switch]$Global = $false,
    [switch]$DryRun = $false,
    [switch]$Help = $false
)

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
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Cyan
}

function Show-Help {
    @"
Smart Review System - インストールスクリプト (Windows)

使用方法:
    .\install.ps1 [OPTIONS]

オプション:
    -TargetDir PATH     インストール先ディレクトリを指定（デフォルト: カレントディレクトリ）
    -Global             ホームディレクトリに共通インストール
    -DryRun             実際にインストールせず、実行内容のみ表示
    -Help               このヘルプを表示

例:
    # カレントディレクトリにインストール
    .\install.ps1

    # 特定のディレクトリにインストール
    .\install.ps1 -TargetDir "C:\Projects\MyProject"

    # グローバルインストール
    .\install.ps1 -Global

    # ドライラン
    .\install.ps1 -DryRun
"@
}

function Test-Prerequisites {
    Write-Info "前提条件をチェックしています..."

    # Claude Code CLI のチェック
    try {
        $claudeVersion = claude --version 2>$null
        if ($claudeVersion) {
            Write-Success "Claude Code CLI: $claudeVersion"
        }
    }
    catch {
        Write-Warning "Claude Code CLI が見つかりません"
        Write-Info "Claude Code CLI がインストールされている場合は無視してください"
    }

    Write-Host ""
}

function Test-SourceFiles {
    Write-Info "ソースファイルを検証しています..."

    $sourceSkills = Join-Path $ScriptDir ".claude\skills"

    if (-not (Test-Path $sourceSkills)) {
        Write-ErrorMsg "ソースディレクトリが見つかりません: $sourceSkills"
        Write-Info "このスクリプトは smart-review-system ディレクトリで実行してください"
        exit 1
    }

    # 各Skillの存在確認
    $skills = @("smart-review-security", "smart-review-debug", "smart-review-quality", "smart-review-docs")
    foreach ($skill in $skills) {
        $skillPath = Join-Path $sourceSkills $skill
        if (-not (Test-Path $skillPath)) {
            Write-ErrorMsg "Skillが見つかりません: $skill"
            exit 1
        }

        $skillMd = Join-Path $skillPath "SKILL.md"
        if (-not (Test-Path $skillMd)) {
            Write-ErrorMsg "SKILL.mdが見つかりません: $skill"
            exit 1
        }
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

    New-Item -ItemType Directory -Path $targetSkills -Force | Out-Null
    Write-Success "ディレクトリを作成しました: $targetSkills"
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
        $sourcePath = Join-Path $source $skill
        $targetPath = Join-Path $targetSkills $skill

        if (Test-Path $targetPath) {
            Write-Warning "$skill は既に存在します（上書きします）"
            Remove-Item -Path $targetPath -Recurse -Force
        }

        Copy-Item -Path $sourcePath -Destination $targetPath -Recurse -Force
        Write-Success "コピー完了: $skill"
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
            Write-Success "$skill`: OK"
        }
        else {
            Write-ErrorMsg "$skill`: SKILL.md が見つかりません"
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
    Write-Host "   PS> cd $Target" -ForegroundColor Yellow
    Write-Host "   PS> claude" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "2. Skillsをテスト:"
    Write-Host "   > このプロジェクトのセキュリティ分析をお願いします" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "3. ドキュメントを確認:"
    Write-Host "   PS> Get-Content $Target\.claude\skills\smart-review-security\SKILL.md" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "4. テストサンプルで動作確認（オプション）:"
    Write-Host "   PS> Copy-Item $ScriptDir\test\vulnerable-sample.js .\test\" -ForegroundColor Yellow
    Write-Host "   PS> claude" -ForegroundColor Yellow
    Write-Host "   > test/vulnerable-sample.js をレビューしてください" -ForegroundColor Yellow
    Write-Host ""

    if ($Global) {
        Write-Host "グローバルインストールされました: $Target" -ForegroundColor Cyan
        Write-Host "他のプロジェクトで使用するには、ディレクトリをコピーしてください" -ForegroundColor Cyan
    }
    Write-Host ""
}

################################################################################
# メイン処理
################################################################################

function Main {
    # ヘルプ表示
    if ($Help) {
        Show-Help
        exit 0
    }

    # グローバルインストール
    if ($Global) {
        $TargetDir = Join-Path $env:USERPROFILE ".claude-skills"
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

# スクリプト実行
try {
    Main
}
catch {
    Write-ErrorMsg "エラーが発生しました: $_"
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}
