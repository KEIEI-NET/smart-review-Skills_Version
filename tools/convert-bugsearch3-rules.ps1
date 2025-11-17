#Requires -Version 5.1
################################################################################
# BugSearch3 YAML Rules → Smart Review JSON Converter
################################################################################
#
# このスクリプトは、BugSearch3のYAMLルールファイルを
# Smart Review System用のJSONファイルに変換します。
#
# 対応:
# - 言語別ルール (JavaScript, TypeScript, Python, Go, Java, etc.)
# - フレームワーク別 (React, Vue, Express, Django, etc.)
# - データベース別 (MySQL, PostgreSQL, MongoDB, etc.)
# - プラットフォーム別 (Node.js, Browser, etc.)
#
################################################################################

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$BugSearch3RulesDir,

    [string]$OutputDir = ".\.claude\skills",

    [switch]$Merge = $false,

    [switch]$DryRun = $false,

    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"

# 統計情報
$script:Stats = @{
    TotalYamlFiles = 0
    ConvertedRules = 0
    SkippedRules = 0
    Errors = @()
    Categories = @{}
}

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
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Detail {
    param([string]$Message)
    if ($Verbose) {
        Write-Host "  $Message" -ForegroundColor Gray
    }
}

################################################################################
# YAMLパーサー（PowerShell 5.1互換）
################################################################################

function ConvertFrom-SimpleYaml {
    param([string]$YamlContent)

    $result = @{}
    $lines = $YamlContent -split "`n"
    $currentKey = $null
    $multilineValue = ""
    $inMultiline = $false

    foreach ($line in $lines) {
        $line = $line.TrimEnd()

        # コメントをスキップ
        if ($line -match '^\s*#' -or $line -match '^\s*$') {
            continue
        }

        # マルチライン文字列の処理
        if ($inMultiline) {
            if ($line -match '^\s{2,}(.+)') {
                $multilineValue += "`n" + $matches[1]
                continue
            }
            else {
                $result[$currentKey] = $multilineValue.Trim()
                $inMultiline = $false
                $multilineValue = ""
            }
        }

        # キー:値のペア
        if ($line -match '^(\w+):\s*(.*)$') {
            $key = $matches[1]
            $value = $matches[2]

            if ($value -eq '|' -or $value -eq '>') {
                # マルチライン開始
                $currentKey = $key
                $inMultiline = $true
                $multilineValue = ""
            }
            elseif ($value) {
                # 単一行の値
                $result[$key] = $value.Trim('"', "'")
            }
            else {
                # 値なし（ネストの可能性）
                $currentKey = $key
            }
        }
        # ネストされた値（examples.bad など）
        elseif ($line -match '^\s{2}(\w+):\s*(.+)$') {
            $subKey = $matches[1]
            $subValue = $matches[2].Trim('"', "'")

            if ($currentKey) {
                if (-not $result.ContainsKey($currentKey)) {
                    $result[$currentKey] = @{}
                }
                if ($result[$currentKey] -is [hashtable]) {
                    $result[$currentKey][$subKey] = $subValue
                }
            }
        }
    }

    # 最後のマルチライン値を処理
    if ($inMultiline -and $currentKey) {
        $result[$currentKey] = $multilineValue.Trim()
    }

    return $result
}

################################################################################
# カテゴリ判定
################################################################################

function Get-RuleCategory {
    param([hashtable]$YamlRule, [string]$FilePath)

    # ファイルパスからカテゴリを推測
    $relativePath = $FilePath.Replace($BugSearch3RulesDir, "").TrimStart('\', '/')

    # 言語判定
    $language = "general"
    if ($relativePath -match 'javascript|js') { $language = "javascript" }
    elseif ($relativePath -match 'typescript|ts') { $language = "typescript" }
    elseif ($relativePath -match 'python|py') { $language = "python" }
    elseif ($relativePath -match 'go|golang') { $language = "go" }
    elseif ($relativePath -match 'java') { $language = "java" }
    elseif ($relativePath -match 'csharp|c#|cs') { $language = "csharp" }
    elseif ($relativePath -match 'ruby|rb') { $language = "ruby" }
    elseif ($relativePath -match 'php') { $language = "php" }

    # YAMLのcategoryフィールドから判定
    $category = "debug"
    if ($YamlRule.category) {
        $yamlCategory = $YamlRule.category.ToLower()
        if ($yamlCategory -match 'security') { $category = "security" }
        elseif ($yamlCategory -match 'quality|code-smell') { $category = "quality" }
        elseif ($yamlCategory -match 'doc|comment') { $category = "docs" }
        elseif ($yamlCategory -match 'debug|bug|error') { $category = "debug" }
    }

    # フレームワーク判定
    $framework = $null
    if ($relativePath -match 'react') { $framework = "react" }
    elseif ($relativePath -match 'vue') { $framework = "vue" }
    elseif ($relativePath -match 'angular') { $framework = "angular" }
    elseif ($relativePath -match 'express') { $framework = "express" }
    elseif ($relativePath -match 'django') { $framework = "django" }
    elseif ($relativePath -match 'spring') { $framework = "spring" }

    # データベース判定
    $database = $null
    if ($relativePath -match 'mysql') { $database = "mysql" }
    elseif ($relativePath -match 'postgresql|postgres') { $database = "postgresql" }
    elseif ($relativePath -match 'mongodb|mongo') { $database = "mongodb" }
    elseif ($relativePath -match 'redis') { $database = "redis" }

    return @{
        Category = $category
        Language = $language
        Framework = $framework
        Database = $database
    }
}

################################################################################
# YAML → JSON 変換
################################################################################

function Convert-YamlRuleToJson {
    param(
        [hashtable]$YamlRule,
        [string]$FilePath,
        [hashtable]$Metadata
    )

    # 必須フィールドのチェック
    if (-not $YamlRule.pattern) {
        Write-Detail "Skipping rule (no pattern): $FilePath"
        $script:Stats.SkippedRules++
        return $null
    }

    # 重要度のマッピング
    $severityMap = @{
        'critical' = 'critical'
        'high' = 'high'
        'medium' = 'medium'
        'low' = 'low'
        'info' = 'low'
        'warning' = 'medium'
        'error' = 'high'
    }

    $severity = 'medium'
    if ($YamlRule.severity) {
        $yamlSeverity = $YamlRule.severity.ToLower()
        if ($severityMap.ContainsKey($yamlSeverity)) {
            $severity = $severityMap[$yamlSeverity]
        }
    }

    # JSON形式に変換
    $jsonRule = @{
        pattern = $YamlRule.pattern
        description = $YamlRule.description ?? $YamlRule.name ?? "No description"
        severity = $severity
        recommendation = $YamlRule.recommendation ?? "Review this pattern"
    }

    # オプショナルフィールド
    if ($YamlRule.examples -and $YamlRule.examples.good) {
        $jsonRule.example = $YamlRule.examples.good
    }

    # メタデータ追加
    $jsonRule.metadata = @{
        id = $YamlRule.id ?? [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
        language = $Metadata.Language
        category = $Metadata.Category
    }

    if ($Metadata.Framework) {
        $jsonRule.metadata.framework = $Metadata.Framework
    }

    if ($Metadata.Database) {
        $jsonRule.metadata.database = $Metadata.Database
    }

    if ($YamlRule.cwe) {
        $jsonRule.metadata.cwe = $YamlRule.cwe
    }

    if ($YamlRule.tags) {
        $jsonRule.metadata.tags = $YamlRule.tags -split ',' | ForEach-Object { $_.Trim() }
    }

    $script:Stats.ConvertedRules++
    return $jsonRule
}

################################################################################
# ファイル処理
################################################################################

function Process-YamlFile {
    param([string]$FilePath)

    Write-Detail "Processing: $FilePath"

    try {
        # YAML読み込み
        $content = Get-Content $FilePath -Raw -Encoding UTF8
        $yamlRule = ConvertFrom-SimpleYaml -YamlContent $content

        # カテゴリ判定
        $metadata = Get-RuleCategory -YamlRule $yamlRule -FilePath $FilePath

        # 統計更新
        $categoryKey = "$($metadata.Category)-$($metadata.Language)"
        if (-not $script:Stats.Categories.ContainsKey($categoryKey)) {
            $script:Stats.Categories[$categoryKey] = 0
        }
        $script:Stats.Categories[$categoryKey]++

        # JSON変換
        $jsonRule = Convert-YamlRuleToJson -YamlRule $yamlRule -FilePath $FilePath -Metadata $metadata

        return @{
            Rule = $jsonRule
            Metadata = $metadata
        }
    }
    catch {
        Write-Detail "Error processing $FilePath : $_"
        $script:Stats.Errors += "Error in ${FilePath}: $_"
        return $null
    }
}

################################################################################
# 出力ファイル生成
################################################################################

function Write-JsonRuleFiles {
    param([array]$ConvertedRules)

    # カテゴリ・言語別にグループ化
    $groupedRules = @{}

    foreach ($item in $ConvertedRules) {
        if (-not $item -or -not $item.Rule) { continue }

        $category = $item.Metadata.Category
        $language = $item.Metadata.Language

        $key = "$category-$language"

        if (-not $groupedRules.ContainsKey($key)) {
            $groupedRules[$key] = @{
                Category = $category
                Language = $language
                Rules = @()
            }
        }

        $groupedRules[$key].Rules += $item.Rule
    }

    # ファイル出力
    foreach ($key in $groupedRules.Keys) {
        $group = $groupedRules[$key]
        $category = $group.Category
        $language = $group.Language

        # 出力先ディレクトリ
        $skillDir = Join-Path $OutputDir "smart-review-$category"
        $rulesDir = Join-Path $skillDir "rules-bugsearch3"

        if (-not (Test-Path $rulesDir)) {
            if (-not $DryRun) {
                New-Item -ItemType Directory -Path $rulesDir -Force | Out-Null
            }
        }

        # ファイル名
        $fileName = "bugsearch3-$language.json"
        $filePath = Join-Path $rulesDir $fileName

        # JSON生成
        $json = @{
            source = "BugSearch3"
            language = $language
            category = $category
            rules_count = $group.Rules.Count
            rules = $group.Rules
        } | ConvertTo-Json -Depth 10

        # 出力
        if ($DryRun) {
            Write-Info "[DRY RUN] Would write: $filePath ($($group.Rules.Count) rules)"
        }
        else {
            $json | Out-File $filePath -Encoding UTF8
            Write-Success "Created: $filePath ($($group.Rules.Count) rules)"
        }
    }
}

################################################################################
# メイン処理
################################################################################

function Main {
    Write-Header "BugSearch3 YAML Rules Converter"

    # 入力ディレクトリの確認
    if (-not (Test-Path $BugSearch3RulesDir)) {
        Write-Fail "BugSearch3 rules directory not found: $BugSearch3RulesDir"
        exit 1
    }

    Write-Info "Source: $BugSearch3RulesDir"
    Write-Info "Output: $OutputDir"
    if ($DryRun) {
        Write-Warn "DRY RUN MODE - No files will be written"
    }
    Write-Host ""

    # YAMLファイルを検索
    Write-Info "Scanning YAML files..."
    $yamlFiles = Get-ChildItem $BugSearch3RulesDir -Filter "*.yaml" -Recurse -File
    $script:Stats.TotalYamlFiles = $yamlFiles.Count

    Write-Success "Found $($yamlFiles.Count) YAML files"
    Write-Host ""

    # 変換処理
    Write-Info "Converting YAML to JSON..."
    $convertedRules = @()

    foreach ($file in $yamlFiles) {
        $result = Process-YamlFile -FilePath $file.FullName
        if ($result) {
            $convertedRules += $result
        }
    }

    Write-Success "Converted $($script:Stats.ConvertedRules) rules"
    if ($script:Stats.SkippedRules -gt 0) {
        Write-Warn "Skipped $($script:Stats.SkippedRules) rules"
    }
    Write-Host ""

    # ファイル出力
    Write-Info "Writing JSON files..."
    Write-JsonRuleFiles -ConvertedRules $convertedRules
    Write-Host ""

    # 統計表示
    Write-Header "Conversion Summary"

    Write-Host "Total YAML files: $($script:Stats.TotalYamlFiles)" -ForegroundColor White
    Write-Host "Converted rules: $($script:Stats.ConvertedRules)" -ForegroundColor Green
    Write-Host "Skipped rules: $($script:Stats.SkippedRules)" -ForegroundColor Yellow
    Write-Host "Errors: $($script:Stats.Errors.Count)" -ForegroundColor $(if ($script:Stats.Errors.Count -gt 0) { 'Red' } else { 'Green' })

    Write-Host "`nRules by Category & Language:" -ForegroundColor Cyan
    foreach ($key in ($script:Stats.Categories.Keys | Sort-Object)) {
        Write-Host "  $key : $($script:Stats.Categories[$key])" -ForegroundColor Gray
    }

    if ($script:Stats.Errors.Count -gt 0) {
        Write-Host "`nErrors:" -ForegroundColor Red
        foreach ($error in $script:Stats.Errors) {
            Write-Host "  $error" -ForegroundColor Red
        }
    }

    Write-Host ""
    if ($script:Stats.ConvertedRules -gt 0) {
        Write-Success "Conversion completed successfully!"
    }
}

# 実行
Main
