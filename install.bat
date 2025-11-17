@echo off
REM ##############################################################################
REM Smart Review System - インストールスクリプト (Windows バッチファイル)
REM ##############################################################################
REM
REM このスクリプトは、Smart Review System をプロジェクトにインストールします。
REM
REM 使用方法:
REM   install.bat
REM
REM 注意: PowerShellが使用可能な場合は install.ps1 の使用を推奨します
REM
REM ##############################################################################

setlocal enabledelayedexpansion

REM スクリプトのディレクトリを取得
set SCRIPT_DIR=%~dp0
set TARGET_DIR=%CD%

echo ================================
echo Smart Review System Installer
echo ================================
echo.

REM 引数のチェック
if "%1"=="--help" goto :show_help
if "%1"=="-h" goto :show_help
if "%1"=="/?" goto :show_help

goto :main

:show_help
echo Smart Review System - インストールスクリプト (Windows)
echo.
echo 使用方法:
echo     install.bat
echo.
echo このスクリプトはカレントディレクトリにSkillsをインストールします。
echo.
echo オプション:
echo     --help, -h, /?    このヘルプを表示
echo.
echo 例:
echo     # プロジェクトディレクトリに移動してインストール
echo     cd C:\Projects\MyProject
echo     C:\path\to\smart-review-system\install.bat
echo.
echo 注意:
echo     PowerShellが使用可能な場合は install.ps1 の使用を推奨します
echo     install.ps1 には追加オプションがあります
echo.
goto :eof

:main
echo [INFO] インストール先: %TARGET_DIR%
echo.

REM 前提条件チェック
echo [INFO] 前提条件をチェックしています...

REM Claude Code CLI のチェック
where claude >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Claude Code CLI が見つかりました
) else (
    echo [WARNING] Claude Code CLI が見つかりません
    echo [INFO] Claude Code CLI がインストールされている場合は無視してください
)
echo.

REM ソースファイルの検証
echo [INFO] ソースファイルを検証しています...

set SOURCE_SKILLS=%SCRIPT_DIR%.claude\skills

if not exist "%SOURCE_SKILLS%" (
    echo [ERROR] ソースディレクトリが見つかりません: %SOURCE_SKILLS%
    echo [INFO] このスクリプトは smart-review-system ディレクトリで実行してください
    exit /b 1
)

REM 各Skillの存在確認
set SKILLS=smart-review-security smart-review-debug smart-review-quality smart-review-docs
set ALL_OK=1

for %%s in (%SKILLS%) do (
    if not exist "%SOURCE_SKILLS%\%%s" (
        echo [ERROR] Skillが見つかりません: %%s
        set ALL_OK=0
    )
    if not exist "%SOURCE_SKILLS%\%%s\SKILL.md" (
        echo [ERROR] SKILL.mdが見つかりません: %%s
        set ALL_OK=0
    )
)

if %ALL_OK% equ 0 (
    echo [ERROR] 必要なファイルが見つかりません
    exit /b 1
)

echo [OK] すべてのSkillファイルが確認されました
echo.

REM ディレクトリ作成
echo [INFO] ディレクトリを作成しています...

set TARGET_SKILLS=%TARGET_DIR%\.claude\skills

if not exist "%TARGET_SKILLS%" (
    mkdir "%TARGET_SKILLS%"
    if %errorlevel% neq 0 (
        echo [ERROR] ディレクトリの作成に失敗しました
        exit /b 1
    )
)

echo [OK] ディレクトリを作成しました: %TARGET_SKILLS%
echo.

REM Skillsをコピー
echo [INFO] Skillsをコピーしています...

for %%s in (%SKILLS%) do (
    echo [INFO] コピー中: %%s

    REM 既存のディレクトリを削除
    if exist "%TARGET_SKILLS%\%%s" (
        echo [WARNING] %%s は既に存在します（上書きします）
        rmdir /s /q "%TARGET_SKILLS%\%%s"
    )

    REM コピー
    xcopy /E /I /Y /Q "%SOURCE_SKILLS%\%%s" "%TARGET_SKILLS%\%%s" >nul
    if %errorlevel% neq 0 (
        echo [ERROR] %%s のコピーに失敗しました
        exit /b 1
    )
    echo [OK] コピー完了: %%s
)

echo.

REM インストール確認
echo [INFO] インストールを確認しています...

set ALL_OK=1

for %%s in (%SKILLS%) do (
    if exist "%TARGET_SKILLS%\%%s\SKILL.md" (
        echo [OK] %%s: OK
    ) else (
        echo [ERROR] %%s: SKILL.md が見つかりません
        set ALL_OK=0
    )
)

echo.

if %ALL_OK% equ 0 (
    echo [ERROR] 一部のSkillのインストールに失敗しました
    exit /b 1
)

echo ================================
echo インストール完了！
echo ================================
echo.
echo 次のステップ:
echo.
echo 1. Claude Code を起動:
echo    ^> cd %TARGET_DIR%
echo    ^> claude
echo.
echo 2. Skillsをテスト:
echo    ^> このプロジェクトのセキュリティ分析をお願いします
echo.
echo 3. ドキュメントを確認:
echo    ^> type %TARGET_SKILLS%\smart-review-security\SKILL.md
echo.
echo 4. テストサンプルで動作確認（オプション）:
echo    ^> copy %SCRIPT_DIR%test\vulnerable-sample.js .\test\
echo    ^> claude
echo    ^> test/vulnerable-sample.js をレビューしてください
echo.
echo インストールが完了しました！
echo.

goto :eof

endlocal
