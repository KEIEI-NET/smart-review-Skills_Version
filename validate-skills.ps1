#Requires -Version 5.1
################################################################################
# Smart Review Skills - 包括的検証スクリプト
################################################################################
#
# このスクリプトは、Skillsファイルの互換性を検証します：
# - エンコーディング（UTF-8）
# - 改行コード（LF推奨）
# - JSON構文
# - ファイル構造
# - パス区切り
# - 特殊文字
#
################################################################################

[CmdletBinding()]
param(
    [switch]$Fix = $false,
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillsDir = Join-Path $ScriptDir ".claude\skills"

# 検証結果
$script:TotalFiles = 0
$script:PassedFiles = 0
$script:WarningFiles = 0
$script:ErrorFiles = 0
$script:Issues = @()

################################################################################
# ユーティリティ関数
################################################################################

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

function Write-Fail {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
    $script:ErrorFiles++
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
    $script:WarningFiles++
}

function Write-Detail {
    param([string]$Message)
    if ($Verbose) {
        Write-Host "  $Message" -ForegroundColor Gray
    }
}

function Add-Issue {
    param(
        [string]$File,
        [string]$Type,
        [string]$Message,
        [string]$Severity = "Warning"
    )

    $script:Issues += [PSCustomObject]@{
        File = $File
        Type = $Type
        Message = $Message
        Severity = $Severity
    }
}

################################################################################
# 検証関数
################################################################################

function Test-FileEncoding {
    param([string]$FilePath)

    $bytes = [System.IO.File]::ReadAllBytes($FilePath)

    # BOMチェック
    if ($bytes.Length -ge 3) {
        # UTF-8 BOM: EF BB BF
        if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            return "UTF-8 with BOM"
        }
    }

    if ($bytes.Length -ge 2) {
        # UTF-16 LE: FF FE
        if ($bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
            return "UTF-16 LE"
        }
        # UTF-16 BE: FE FF
        if ($bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
            return "UTF-16 BE"
        }
    }

    # UTF-8 without BOM（推定）
    try {
        $content = [System.IO.File]::ReadAllText($FilePath, [System.Text.Encoding]::UTF8)
        $utf8Bytes = [System.Text.Encoding]::UTF8.GetBytes($content)

        if ($bytes.Length -eq $utf8Bytes.Length) {
            $match = $true
            for ($i = 0; $i -lt $bytes.Length; $i++) {
                if ($bytes[$i] -ne $utf8Bytes[$i]) {
                    $match = $false
                    break
                }
            }
            if ($match) {
                return "UTF-8 without BOM"
            }
        }
    }
    catch {}

    return "Unknown"
}

function Test-LineEndings {
    param([string]$FilePath)

    $content = [System.IO.File]::ReadAllText($FilePath)

    $crlfCount = ([regex]::Matches($content, "`r`n")).Count
    $lfOnlyCount = ([regex]::Matches($content, "(?<!`r)`n")).Count
    $crOnlyCount = ([regex]::Matches($content, "`r(?!`n)")).Count

    if ($crlfCount -gt 0 -and $lfOnlyCount -eq 0 -and $crOnlyCount -eq 0) {
        return "CRLF"
    }
    elseif ($lfOnlyCount -gt 0 -and $crlfCount -eq 0 -and $crOnlyCount -eq 0) {
        return "LF"
    }
    elseif ($crOnlyCount -gt 0 -and $crlfCount -eq 0 -and $lfOnlyCount -eq 0) {
        return "CR"
    }
    elseif ($crlfCount -eq 0 -and $lfOnlyCount -eq 0 -and $crOnlyCount -eq 0) {
        return "None"
    }
    else {
        return "Mixed"
    }
}

function Test-JsonSyntax {
    param([string]$FilePath)

    try {
        $content = Get-Content $FilePath -Raw -Encoding UTF8
        $null = $content | ConvertFrom-Json -ErrorAction Stop
        return $true
    }
    catch {
        return $_.Exception.Message
    }
}

function Test-PathSeparators {
    param([string]$FilePath)

    $content = Get-Content $FilePath -Raw -Encoding UTF8

    # Windowsパス（バックスラッシュ）を検出
    $backslashPaths = [regex]::Matches($content, '[A-Za-z]:\\\\[^\s"'']+')

    if ($backslashPaths.Count -gt 0) {
        return @{
            HasIssue = $true
            Count = $backslashPaths.Count
            Examples = $backslashPaths[0..2] | ForEach-Object { $_.Value }
        }
    }

    return @{ HasIssue = $false }
}

function Test-TrailingWhitespace {
    param([string]$FilePath)

    $lines = Get-Content $FilePath -Encoding UTF8
    $trailingLines = @()

    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '\s+$') {
            $trailingLines += $i + 1
        }
    }

    if ($trailingLines.Count -gt 0) {
        return @{
            HasIssue = $true
            Count = $trailingLines.Count
            Lines = $trailingLines[0..9]
        }
    }

    return @{ HasIssue = $false }
}

function Test-SkillStructure {
    param([string]$SkillPath)

    $skillName = Split-Path $SkillPath -Leaf
    $issues = @()

    # SKILL.mdの存在確認
    $skillMd = Join-Path $SkillPath "SKILL.md"
    if (-not (Test-Path $skillMd)) {
        $issues += "SKILL.md が見つかりません"
    }
    else {
        # YAMLフロントマターの確認
        $content = Get-Content $skillMd -Raw -Encoding UTF8
        if ($content -notmatch '^---\s*\n.*?name:\s*".*?"\s*\n.*?description:') {
            $issues += "SKILL.md のYAMLフロントマターが不正です"
        }
    }

    # Skill固有のファイル確認
    switch ($skillName) {
        "smart-review-security" {
            if (-not (Test-Path (Join-Path $SkillPath "patterns.json"))) {
                $issues += "patterns.json が見つかりません"
            }
            if (-not (Test-Path (Join-Path $SkillPath "cwe-mapping.json"))) {
                $issues += "cwe-mapping.json が見つかりません"
            }
        }
        "smart-review-debug" {
            if (-not (Test-Path (Join-Path $SkillPath "checklist.md"))) {
                $issues += "checklist.md が見つかりません"
            }
            if (-not (Test-Path (Join-Path $SkillPath "common-patterns.json"))) {
                $issues += "common-patterns.json が見つかりません"
            }
        }
        "smart-review-quality" {
            if (-not (Test-Path (Join-Path $SkillPath "metrics.json"))) {
                $issues += "metrics.json が見つかりません"
            }
            if (-not (Test-Path (Join-Path $SkillPath "code-smells.json"))) {
                $issues += "code-smells.json が見つかりません"
            }
        }
        "smart-review-docs" {
            if (-not (Test-Path (Join-Path $SkillPath "templates"))) {
                $issues += "templates ディレクトリが見つかりません"
            }
        }
    }

    return $issues
}

################################################################################
# 検証実行
################################################################################

function Test-File {
    param(
        [string]$FilePath,
        [string]$FileType
    )

    $script:TotalFiles++
    $relativePath = $FilePath.Replace($ScriptDir, ".")
    $hasError = $false
    $hasWarning = $false

    Write-Host "`n$relativePath" -ForegroundColor White

    # 1. エンコーディングチェック
    $encoding = Test-FileEncoding -FilePath $FilePath
    if ($encoding -eq "UTF-8 without BOM") {
        Write-Success "エンコーディング: $encoding"
    }
    elseif ($encoding -eq "UTF-8 with BOM") {
        if ($FileType -eq "JSON") {
            Write-Warn "エンコーディング: $encoding (JSONはBOMなしを推奨)"
            Add-Issue -File $relativePath -Type "Encoding" -Message "UTF-8 with BOM (BOMなしを推奨)" -Severity "Warning"
            $hasWarning = $true
        }
        else {
            Write-Success "エンコーディング: $encoding"
        }
    }
    else {
        Write-Fail "エンコーディング: $encoding (UTF-8を使用してください)"
        Add-Issue -File $relativePath -Type "Encoding" -Message "不正なエンコーディング: $encoding" -Severity "Error"
        $hasError = $true
    }

    # 2. 改行コードチェック
    $lineEnding = Test-LineEndings -FilePath $FilePath
    if ($lineEnding -eq "LF") {
        Write-Success "改行コード: LF"
    }
    elseif ($lineEnding -eq "CRLF") {
        Write-Warn "改行コード: CRLF (LFを推奨)"
        Add-Issue -File $relativePath -Type "LineEnding" -Message "CRLFを使用（LFを推奨）" -Severity "Warning"
        $hasWarning = $true
    }
    elseif ($lineEnding -eq "Mixed") {
        Write-Fail "改行コード: 混在"
        Add-Issue -File $relativePath -Type "LineEnding" -Message "改行コードが混在しています" -Severity "Error"
        $hasError = $true
    }
    else {
        Write-Detail "改行コード: $lineEnding"
    }

    # 3. JSON構文チェック
    if ($FileType -eq "JSON") {
        $jsonResult = Test-JsonSyntax -FilePath $FilePath
        if ($jsonResult -eq $true) {
            Write-Success "JSON構文: 正常"
        }
        else {
            Write-Fail "JSON構文: エラー - $jsonResult"
            Add-Issue -File $relativePath -Type "JSONSyntax" -Message "JSON構文エラー: $jsonResult" -Severity "Error"
            $hasError = $true
        }
    }

    # 4. パス区切りチェック
    $pathCheck = Test-PathSeparators -FilePath $FilePath
    if ($pathCheck.HasIssue) {
        Write-Warn "Windowsパス検出: $($pathCheck.Count) 箇所"
        Write-Detail "例: $($pathCheck.Examples -join ', ')"
        Add-Issue -File $relativePath -Type "PathSeparator" -Message "Windowsパス（バックスラッシュ）を検出" -Severity "Warning"
        $hasWarning = $true
    }
    else {
        Write-Detail "パス区切り: OK"
    }

    # 5. 末尾空白チェック
    $whitespaceCheck = Test-TrailingWhitespace -FilePath $FilePath
    if ($whitespaceCheck.HasIssue) {
        Write-Warn "末尾空白: $($whitespaceCheck.Count) 行"
        if ($Verbose) {
            Write-Detail "行: $($whitespaceCheck.Lines -join ', ')"
        }
        Add-Issue -File $relativePath -Type "TrailingWhitespace" -Message "末尾に空白がある行: $($whitespaceCheck.Count)" -Severity "Info"
    }
    else {
        Write-Detail "末尾空白: なし"
    }

    # 結果カウント
    if (-not $hasError -and -not $hasWarning) {
        $script:PassedFiles++
    }
}

function Test-AllSkills {
    Write-Header "Skills構造検証"

    if (-not (Test-Path $SkillsDir)) {
        Write-Fail "Skillsディレクトリが見つかりません: $SkillsDir"
        return
    }

    $skills = Get-ChildItem $SkillsDir -Directory | Where-Object { $_.Name -like "smart-review-*" }

    foreach ($skill in $skills) {
        Write-Host "`nSkill: $($skill.Name)" -ForegroundColor Cyan

        $structureIssues = Test-SkillStructure -SkillPath $skill.FullName

        if ($structureIssues.Count -eq 0) {
            Write-Success "構造: OK"
        }
        else {
            foreach ($issue in $structureIssues) {
                Write-Fail "構造: $issue"
                Add-Issue -File $skill.Name -Type "Structure" -Message $issue -Severity "Error"
            }
        }
    }

    Write-Header "ファイル検証"

    # 各Skillのファイルを検証
    foreach ($skill in $skills) {
        # Markdownファイル
        Get-ChildItem $skill.FullName -Filter "*.md" -Recurse | ForEach-Object {
            Test-File -FilePath $_.FullName -FileType "Markdown"
        }

        # JSONファイル
        Get-ChildItem $skill.FullName -Filter "*.json" -Recurse | ForEach-Object {
            Test-File -FilePath $_.FullName -FileType "JSON"
        }
    }
}

function Show-Summary {
    Write-Header "検証結果サマリー"

    Write-Host "総ファイル数: $script:TotalFiles" -ForegroundColor White
    Write-Host "成功: $script:PassedFiles" -ForegroundColor Green
    Write-Host "警告: $script:WarningFiles" -ForegroundColor Yellow
    Write-Host "エラー: $script:ErrorFiles" -ForegroundColor Red

    if ($script:Issues.Count -gt 0) {
        Write-Host "`n問題の詳細:" -ForegroundColor Yellow

        # 重要度別にグループ化
        $byeSeverity = $script:Issues | Group-Object Severity

        foreach ($group in $byeSeverity) {
            Write-Host "`n[$($group.Name)]" -ForegroundColor $(
                switch ($group.Name) {
                    "Error" { "Red" }
                    "Warning" { "Yellow" }
                    default { "Gray" }
                }
            )

            foreach ($issue in $group.Group) {
                Write-Host "  $($issue.File)" -ForegroundColor Gray
                Write-Host "    $($issue.Type): $($issue.Message)" -ForegroundColor Gray
            }
        }
    }

    Write-Host ""

    if ($script:ErrorFiles -eq 0 -and $script:WarningFiles -eq 0) {
        Write-Host "[SUCCESS] すべてのチェックに合格しました！" -ForegroundColor Green
    }
    elseif ($script:ErrorFiles -eq 0) {
        Write-Host "[INFO] エラーはありませんが、警告があります" -ForegroundColor Yellow
    }
    else {
        Write-Host "[FAILED] エラーがあります。修正してください" -ForegroundColor Red
    }
}

function Show-Recommendations {
    Write-Host ""
    Write-Host "推奨事項:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. すべてのファイルはUTF-8（BOMなし）で保存してください"
    Write-Host "2. 改行コードはLFを使用してください（Gitで自動変換可能）"
    Write-Host "3. JSONファイルは構文エラーがないことを確認してください"
    Write-Host "4. パスはスラッシュ（/）を使用してください"
    Write-Host ""
    Write-Host "自動修正には .editorconfig と .gitattributes を使用してください"
    Write-Host ""
}

################################################################################
# メイン処理
################################################################################

function Main {
    Write-Header "Smart Review Skills - 互換性検証"

    Write-Host "検証対象: $SkillsDir" -ForegroundColor White
    Write-Host ""

    if (-not (Test-Path $SkillsDir)) {
        Write-Fail "Skillsディレクトリが見つかりません"
        return
    }

    Test-AllSkills
    Show-Summary
    Show-Recommendations

    # 終了コード
    if ($script:ErrorFiles -gt 0) {
        exit 1
    }
    exit 0
}

# 実行
Main
