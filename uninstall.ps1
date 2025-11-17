################################################################################
# Smart Review System - アンインストールスクリプト (Windows PowerShell)
################################################################################

param(
    [switch]$Help = $false,
    [switch]$Force = $false
)

$TargetDir = $PWD.Path

################################################################################
# 関数定義
################################################################################

function Write-Header {
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "Smart Review System Uninstaller" -ForegroundColor Cyan
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
Smart Review System - アンインストールスクリプト (Windows)

使用方法:
    .\uninstall.ps1 [OPTIONS]

オプション:
    -Force      確認なしで削除
    -Help       このヘルプを表示

例:
    # 通常のアンインストール（確認あり）
    .\uninstall.ps1

    # 確認なしで削除
    .\uninstall.ps1 -Force
"@
}

function Remove-Skills {
    $targetSkills = Join-Path $TargetDir ".claude\skills"

    Write-Info "以下のSkillsを削除します:"
    Write-Host ""

    $skills = @("smart-review-security", "smart-review-debug", "smart-review-quality", "smart-review-docs")
    $foundCount = 0

    foreach ($skill in $skills) {
        $skillPath = Join-Path $targetSkills $skill
        if (Test-Path $skillPath) {
            Write-Host "  - $skill"
            $foundCount++
        }
    }

    Write-Host ""

    if ($foundCount -eq 0) {
        Write-Warning "削除するSkillsが見つかりませんでした"
        return
    }

    if (-not $Force) {
        $response = Read-Host "本当に削除してもよろしいですか？ (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Info "アンインストールをキャンセルしました"
            exit 0
        }
    }

    Write-Host ""
    Write-Info "Skillsを削除しています..."

    foreach ($skill in $skills) {
        $skillPath = Join-Path $targetSkills $skill
        if (Test-Path $skillPath) {
            Remove-Item -Path $skillPath -Recurse -Force
            Write-Success "削除完了: $skill"
        }
    }

    # .claude/skills が空なら削除
    if ((Test-Path $targetSkills) -and ((Get-ChildItem $targetSkills).Count -eq 0)) {
        Remove-Item -Path $targetSkills -Force
        Write-Info ".claude\skills ディレクトリを削除しました（空のため）"
    }

    Write-Host ""
    Write-Success "アンインストールが完了しました"
}

################################################################################
# メイン処理
################################################################################

function Main {
    if ($Help) {
        Show-Help
        exit 0
    }

    Write-Header
    Write-Info "対象ディレクトリ: $TargetDir"
    Write-Host ""

    Remove-Skills
}

try {
    Main
}
catch {
    Write-ErrorMsg "エラーが発生しました: $_"
    exit 1
}
