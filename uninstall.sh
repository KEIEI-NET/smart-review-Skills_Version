#!/bin/bash

################################################################################
# Smart Review System - アンインストールスクリプト (Linux/macOS)
################################################################################

set -e

# 色の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TARGET_DIR="$(pwd)"

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}Smart Review System Uninstaller${NC}"
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

confirm() {
    read -p "$1 (y/N): " response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

uninstall_skills() {
    local target="$TARGET_DIR/.claude/skills"

    print_info "以下のSkillsを削除します:"
    echo ""

    local skills=("smart-review-security" "smart-review-debug" "smart-review-quality" "smart-review-docs")
    local found_count=0

    for skill in "${skills[@]}"; do
        if [ -d "$target/$skill" ]; then
            echo "  - $skill"
            ((found_count++))
        fi
    done

    echo ""

    if [ $found_count -eq 0 ]; then
        print_warning "削除するSkillsが見つかりませんでした"
        return 0
    fi

    if ! confirm "本当に削除してもよろしいですか？"; then
        print_info "アンインストールをキャンセルしました"
        exit 0
    fi

    echo ""
    print_info "Skillsを削除しています..."

    for skill in "${skills[@]}"; do
        if [ -d "$target/$skill" ]; then
            rm -rf "$target/$skill"
            print_success "削除完了: $skill"
        fi
    done

    # .claude/skills が空なら削除
    if [ -d "$target" ] && [ -z "$(ls -A "$target")" ]; then
        rmdir "$target"
        print_info ".claude/skills ディレクトリを削除しました（空のため）"
    fi

    echo ""
    print_success "アンインストールが完了しました"
}

main() {
    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        cat << EOF
Smart Review System - アンインストールスクリプト

使用方法:
    $0

このスクリプトは、カレントディレクトリから Smart Review Skills を削除します。
EOF
        exit 0
    fi

    print_header
    print_info "対象ディレクトリ: $TARGET_DIR"
    echo ""

    uninstall_skills
}

main "$@"
