#!/bin/bash

################################################################################
# Smart Review System - インストールスクリプト (Linux/macOS)
################################################################################
#
# このスクリプトは、Smart Review System をプロジェクトにインストールします。
#
# 使用方法:
#   chmod +x install.sh
#   ./install.sh
#
# オプション:
#   ./install.sh --target /path/to/project
#   ./install.sh --global (ホームディレクトリに共通インストール)
#   ./install.sh --help
#
################################################################################

set -e  # エラー時に終了

# 色の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# デフォルト値
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$(pwd)"
GLOBAL_INSTALL=false
DRY_RUN=false

################################################################################
# 関数定義
################################################################################

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}Smart Review System Installer${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

show_help() {
    cat << EOF
Smart Review System - インストールスクリプト

使用方法:
    $0 [OPTIONS]

オプション:
    --target PATH       インストール先ディレクトリを指定（デフォルト: カレントディレクトリ）
    --global            ホームディレクトリに共通インストール (~/.claude-skills/)
    --dry-run           実際にインストールせず、実行内容のみ表示
    --help              このヘルプを表示

例:
    # カレントディレクトリにインストール
    $0

    # 特定のディレクトリにインストール
    $0 --target /path/to/project

    # グローバルインストール
    $0 --global

    # ドライラン
    $0 --dry-run
EOF
}

check_prerequisites() {
    print_info "前提条件をチェックしています..."

    # Claude Code CLI のチェック
    if ! command -v claude &> /dev/null; then
        print_warning "Claude Code CLI が見つかりません"
        print_info "Claude Code CLI がインストールされている場合は無視してください"
    else
        local version=$(claude --version 2>&1 || echo "unknown")
        print_success "Claude Code CLI: $version"
    fi

    # 必要なコマンドのチェック
    local required_commands=("cp" "mkdir" "chmod")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            print_error "必要なコマンドが見つかりません: $cmd"
            exit 1
        fi
    done
}

validate_source() {
    print_info "ソースファイルを検証しています..."

    local source_skills="$SCRIPT_DIR/.claude/skills"

    if [ ! -d "$source_skills" ]; then
        print_error "ソースディレクトリが見つかりません: $source_skills"
        print_info "このスクリプトは smart-review-system ディレクトリで実行してください"
        exit 1
    fi

    # 各Skillの存在確認
    local skills=("smart-review-security" "smart-review-debug" "smart-review-quality" "smart-review-docs")
    for skill in "${skills[@]}"; do
        if [ ! -d "$source_skills/$skill" ]; then
            print_error "Skillが見つかりません: $skill"
            exit 1
        fi

        if [ ! -f "$source_skills/$skill/SKILL.md" ]; then
            print_error "SKILL.mdが見つかりません: $skill"
            exit 1
        fi
    done

    print_success "すべてのSkillファイルが確認されました"
}

create_directories() {
    local target="$1"

    print_info "ディレクトリを作成しています..."

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] mkdir -p \"$target/.claude/skills\""
        return
    fi

    mkdir -p "$target/.claude/skills"
    print_success "ディレクトリを作成しました: $target/.claude/skills"
}

copy_skills() {
    local source="$SCRIPT_DIR/.claude/skills"
    local target="$1/.claude/skills"

    print_info "Skillsをコピーしています..."

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] cp -r \"$source\"/* \"$target/\""
        return
    fi

    # 各Skillをコピー
    local skills=("smart-review-security" "smart-review-debug" "smart-review-quality" "smart-review-docs")
    for skill in "${skills[@]}"; do
        if [ -d "$target/$skill" ]; then
            print_warning "$skill は既に存在します（上書きします）"
            rm -rf "$target/$skill"
        fi

        cp -r "$source/$skill" "$target/"
        print_success "コピー完了: $skill"
    done
}

set_permissions() {
    local target="$1/.claude/skills"

    print_info "権限を設定しています..."

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] chmod -R 755 \"$target\""
        return
    fi

    chmod -R 755 "$target"
    print_success "権限を設定しました"
}

verify_installation() {
    local target="$1/.claude/skills"

    print_info "インストールを確認しています..."

    local skills=("smart-review-security" "smart-review-debug" "smart-review-quality" "smart-review-docs")
    local all_ok=true

    for skill in "${skills[@]}"; do
        if [ -f "$target/$skill/SKILL.md" ]; then
            print_success "$skill: OK"
        else
            print_error "$skill: SKILL.md が見つかりません"
            all_ok=false
        fi
    done

    if [ "$all_ok" = true ]; then
        print_success "すべてのSkillが正常にインストールされました"
        return 0
    else
        print_error "一部のSkillのインストールに失敗しました"
        return 1
    fi
}

create_symlinks() {
    local source="$1"
    local target="$2"

    print_info "シンボリックリンクを作成しています..."

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] シンボリックリンクを作成"
        return
    fi

    mkdir -p "$target/.claude/skills"

    local skills=("smart-review-security" "smart-review-debug" "smart-review-quality" "smart-review-docs")
    for skill in "${skills[@]}"; do
        local link="$target/.claude/skills/$skill"
        if [ -L "$link" ]; then
            rm "$link"
        elif [ -d "$link" ]; then
            print_warning "$link は既に存在します（シンボリックリンクではありません）"
            continue
        fi

        ln -s "$source/.claude/skills/$skill" "$link"
        print_success "シンボリックリンク作成: $skill"
    done
}

show_next_steps() {
    echo ""
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}インストール完了！${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
    echo "次のステップ:"
    echo ""
    echo "1. Claude Code を起動:"
    echo "   $ cd $TARGET_DIR"
    echo "   $ claude"
    echo ""
    echo "2. Skillsをテスト:"
    echo "   > このプロジェクトのセキュリティ分析をお願いします"
    echo ""
    echo "3. ドキュメントを確認:"
    echo "   $ cat $TARGET_DIR/.claude/skills/smart-review-security/SKILL.md"
    echo ""
    echo "4. テストサンプルで動作確認（オプション）:"
    echo "   $ cp $SCRIPT_DIR/test/vulnerable-sample.js ./test/"
    echo "   $ claude"
    echo "   > test/vulnerable-sample.js をレビューしてください"
    echo ""

    if [ "$GLOBAL_INSTALL" = true ]; then
        echo "グローバルインストールされました: ~/.claude-skills/"
        echo "他のプロジェクトで使用するには、シンボリックリンクを作成してください:"
        echo "   $ cd /path/to/your/project"
        echo "   $ $0 --link-global"
    fi
    echo ""
}

################################################################################
# メイン処理
################################################################################

main() {
    # 引数解析
    while [[ $# -gt 0 ]]; do
        case $1 in
            --target)
                TARGET_DIR="$2"
                shift 2
                ;;
            --global)
                GLOBAL_INSTALL=true
                TARGET_DIR="$HOME/.claude-skills"
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                print_error "不明なオプション: $1"
                show_help
                exit 1
                ;;
        esac
    done

    print_header

    if [ "$DRY_RUN" = true ]; then
        print_warning "ドライランモード（実際にはインストールされません）"
        echo ""
    fi

    print_info "インストール先: $TARGET_DIR"
    echo ""

    # 前提条件チェック
    check_prerequisites
    echo ""

    # ソースファイルの検証
    validate_source
    echo ""

    # ディレクトリ作成
    create_directories "$TARGET_DIR"
    echo ""

    # Skillsをコピー
    copy_skills "$TARGET_DIR"
    echo ""

    # 権限設定
    set_permissions "$TARGET_DIR"
    echo ""

    # インストール確認
    if [ "$DRY_RUN" = false ]; then
        verify_installation "$TARGET_DIR"
        echo ""
        show_next_steps
    else
        print_info "ドライランが完了しました"
        print_info "実際にインストールするには --dry-run オプションを外して実行してください"
    fi
}

# スクリプト実行
main "$@"
