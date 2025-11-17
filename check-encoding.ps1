#Requires -Version 5.1
################################################################################
# エンコーディングチェッカー
################################################################################
#
# このスクリプトは、インストールスクリプトのエンコーディングを確認し、
# 必要に応じて修正方法を提案します。
#
################################################################################

[CmdletBinding()]
param(
    [switch]$Fix = $false
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Test-FileEncoding {
    param(
        [string]$FilePath
    )

    if (-not (Test-Path $FilePath)) {
        return $null
    }

    $bytes = [System.IO.File]::ReadAllBytes($FilePath)

    # BOMをチェック
    if ($bytes.Length -ge 3) {
        # UTF-8 BOM: EF BB BF
        if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            return "UTF-8 with BOM"
        }
    }

    if ($bytes.Length -ge 2) {
        # UTF-16 LE BOM: FF FE
        if ($bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
            return "UTF-16 LE"
        }
        # UTF-16 BE BOM: FE FF
        if ($bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
            return "UTF-16 BE"
        }
    }

    # BOMなし - ヒューリスティック判定
    $content = [System.IO.File]::ReadAllText($FilePath)

    # 日本語が含まれているかチェック
    if ($content -match '[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF]') {
        # 日本語を含む場合はShift-JISの可能性
        try {
            $sjis = [System.Text.Encoding]::GetEncoding(932)
            $sjisBytes = $sjis.GetBytes($content)
            $decoded = $sjis.GetString($sjisBytes)
            if ($decoded -eq $content) {
                return "Shift-JIS (推定)"
            }
        }
        catch {}
    }

    return "UTF-8 without BOM (推定)"
}

function Write-Header {
    Write-Host ""
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "エンコーディングチェッカー" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host ""
}

function Test-AllFiles {
    Write-Header

    $files = @(
        @{Path = "install.ps1"; Expected = "UTF-8 with BOM"; Type = "PowerShell"},
        @{Path = "install-safe.ps1"; Expected = "UTF-8 with BOM"; Type = "PowerShell"},
        @{Path = "uninstall.ps1"; Expected = "UTF-8 with BOM"; Type = "PowerShell"},
        @{Path = "install.bat"; Expected = "Shift-JIS"; Type = "Batch"},
        @{Path = "install.sh"; Expected = "UTF-8 without BOM"; Type = "Shell"}
    )

    $issues = @()

    foreach ($file in $files) {
        $filePath = Join-Path $ScriptDir $file.Path

        if (-not (Test-Path $filePath)) {
            Write-Host "[SKIP] $($file.Path) - ファイルが見つかりません" -ForegroundColor Yellow
            continue
        }

        $encoding = Test-FileEncoding -FilePath $filePath

        if ($encoding -eq $file.Expected -or $encoding -like "$($file.Expected)*") {
            Write-Host "[OK] $($file.Path)" -ForegroundColor Green
            Write-Host "     検出: $encoding" -ForegroundColor Gray
        }
        else {
            Write-Host "[WARNING] $($file.Path)" -ForegroundColor Yellow
            Write-Host "     期待: $($file.Expected)" -ForegroundColor Gray
            Write-Host "     検出: $encoding" -ForegroundColor Gray

            $issues += @{
                File = $file.Path
                Expected = $file.Expected
                Detected = $encoding
                Type = $file.Type
            }
        }
    }

    Write-Host ""

    if ($issues.Count -eq 0) {
        Write-Host "[SUCCESS] すべてのファイルが正しいエンコーディングです" -ForegroundColor Green
    }
    else {
        Write-Host "[WARNING] $($issues.Count) 個のファイルに問題があります" -ForegroundColor Yellow
        Write-Host ""
        Show-Recommendations -Issues $issues
    }
}

function Show-Recommendations {
    param($Issues)

    Write-Host "推奨される修正方法:" -ForegroundColor Cyan
    Write-Host ""

    foreach ($issue in $Issues) {
        Write-Host "ファイル: $($issue.File)" -ForegroundColor Yellow
        Write-Host ""

        switch ($issue.Type) {
            "PowerShell" {
                Write-Host "  Visual Studio Codeでの修正:"
                Write-Host "  1. ファイルを開く"
                Write-Host "  2. 右下のエンコーディング表示をクリック"
                Write-Host "  3. 'エンコーディング付きで保存' を選択"
                Write-Host "  4. 'UTF-8 with BOM' を選択"
                Write-Host ""
                Write-Host "  または PowerShell で:"
                Write-Host "  `$content = Get-Content '$($issue.File)' -Raw" -ForegroundColor Gray
                Write-Host "  `$utf8 = New-Object System.Text.UTF8Encoding `$true" -ForegroundColor Gray
                Write-Host "  [System.IO.File]::WriteAllText('$($issue.File)', `$content, `$utf8)" -ForegroundColor Gray
            }
            "Batch" {
                Write-Host "  メモ帳での修正:"
                Write-Host "  1. ファイルを開く"
                Write-Host "  2. '名前を付けて保存'"
                Write-Host "  3. エンコーディングで 'ANSI' を選択"
                Write-Host ""
                Write-Host "  または PowerShell で:"
                Write-Host "  `$content = Get-Content '$($issue.File)' -Raw" -ForegroundColor Gray
                Write-Host "  `$sjis = [System.Text.Encoding]::GetEncoding(932)" -ForegroundColor Gray
                Write-Host "  [System.IO.File]::WriteAllText('$($issue.File)', `$content, `$sjis)" -ForegroundColor Gray
            }
            "Shell" {
                Write-Host "  UTF-8 without BOM が推奨です"
                Write-Host "  現在のエンコーディングで問題ない場合もあります"
            }
        }

        Write-Host ""
    }
}

function Repair-Encoding {
    param(
        [string]$FilePath,
        [string]$TargetEncoding
    )

    Write-Host "[INFO] 修正中: $FilePath → $TargetEncoding" -ForegroundColor Cyan

    try {
        $content = Get-Content $FilePath -Raw

        switch ($TargetEncoding) {
            "UTF-8 with BOM" {
                $utf8 = New-Object System.Text.UTF8Encoding $true
                [System.IO.File]::WriteAllText($FilePath, $content, $utf8)
            }
            "UTF-8 without BOM" {
                $utf8 = New-Object System.Text.UTF8Encoding $false
                [System.IO.File]::WriteAllText($FilePath, $content, $utf8)
            }
            "Shift-JIS" {
                $sjis = [System.Text.Encoding]::GetEncoding(932)
                [System.IO.File]::WriteAllText($FilePath, $content, $sjis)
            }
        }

        Write-Host "[OK] 修正完了: $FilePath" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "[ERROR] 修正失敗: $FilePath - $_" -ForegroundColor Red
        return $false
    }
}

# メイン処理
if ($Fix) {
    Write-Host ""
    Write-Host "自動修正モードは未実装です" -ForegroundColor Yellow
    Write-Host "上記の推奨方法に従って手動で修正してください" -ForegroundColor Yellow
    Write-Host ""
}
else {
    Test-AllFiles
}

Write-Host ""
Write-Host "注意事項:" -ForegroundColor Cyan
Write-Host "  - PowerShellスクリプト (.ps1) は UTF-8 with BOM を使用してください"
Write-Host "  - バッチファイル (.bat) は Shift-JIS (ANSI) を使用してください"
Write-Host "  - シェルスクリプト (.sh) は UTF-8 without BOM を使用してください"
Write-Host "  - 絵文字は環境によって表示されない場合があります"
Write-Host ""
