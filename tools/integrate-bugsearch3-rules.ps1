#Requires -Version 5.1
################################################################################
# BugSearch3 Rules Integration Script
################################################################################
#
# 変換されたBugSearch3ルールを既存のSkillsに統合します
#
################################################################################

[CmdletBinding()]
param(
    [string]$SkillsDir = ".\.claude\skills",
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Stop"

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host $Text -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Integrate-BugSearch3Rules {
    param([string]$SkillName)

    $skillDir = Join-Path $SkillsDir $SkillName
    $rulesDir = Join-Path $skillDir "rules-bugsearch3"
    $commonPatternsFile = Join-Path $skillDir "common-patterns.json"

    if (-not (Test-Path $rulesDir)) {
        Write-Info "No BugSearch3 rules found for $SkillName"
        return
    }

    if (-not (Test-Path $commonPatternsFile)) {
        Write-Info "No common-patterns.json found for $SkillName"
        return
    }

    # 既存のpatterns.jsonを読み込み
    $commonPatterns = Get-Content $commonPatternsFile -Raw | ConvertFrom-Json

    # BugSearch3ルールを読み込み
    $bugsearch3Files = Get-ChildItem $rulesDir -Filter "*.json"
    $totalRules = 0

    foreach ($file in $bugsearch3Files) {
        $bugsearch3Data = Get-Content $file.FullName -Raw | ConvertFrom-Json

        $categoryName = "bugsearch3_$($bugsearch3Data.language)"

        # 新しいカテゴリとして追加
        if (-not $commonPatterns.PSObject.Properties[$categoryName]) {
            $commonPatterns | Add-Member -MemberType NoteProperty -Name $categoryName -Value $bugsearch3Data.rules
            $totalRules += $bugsearch3Data.rules.Count
            Write-Success "Added $($bugsearch3Data.rules.Count) $($bugsearch3Data.language) rules to $SkillName"
        }
    }

    if ($totalRules -gt 0) {
        # 書き戻し
        if (-not $DryRun) {
            $commonPatterns | ConvertTo-Json -Depth 10 | Out-File $commonPatternsFile -Encoding UTF8
            Write-Success "Integrated $totalRules BugSearch3 rules into $SkillName"
        }
        else {
            Write-Info "[DRY RUN] Would integrate $totalRules rules into $SkillName"
        }
    }
}

################################################################################
# メイン処理
################################################################################

Write-Header "BugSearch3 Rules Integration"

if ($DryRun) {
    Write-Info "DRY RUN MODE - No files will be modified"
    Write-Host ""
}

$skills = @("smart-review-security", "smart-review-debug", "smart-review-quality")

foreach ($skill in $skills) {
    Integrate-BugSearch3Rules -SkillName $skill
}

Write-Host ""
Write-Success "Integration completed!"
