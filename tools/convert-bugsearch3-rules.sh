#!/bin/bash
################################################################################
# BugSearch3 YAML Rules → Smart Review JSON Converter (Unix/Linux/macOS)
################################################################################

set -e

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# デフォルト値
BUGSEARCH3_DIR=""
OUTPUT_DIR="./.claude/skills"
DRY_RUN=false

# 統計
TOTAL_FILES=0
CONVERTED_RULES=0
SKIPPED_RULES=0

################################################################################
# ヘルプ
################################################################################

show_help() {
    cat << EOF
BugSearch3 YAML Rules Converter

Usage:
    $0 -s <bugsearch3-rules-dir> [-o <output-dir>] [-d] [-h]

Options:
    -s PATH     BugSearch3 rules directory (required)
    -o PATH     Output directory (default: ./.claude/skills)
    -d          Dry run mode
    -h          Show this help

Examples:
    # Convert all BugSearch3 rules
    $0 -s /path/to/BugSearch3/rules

    # Dry run
    $0 -s /path/to/BugSearch3/rules -d

    # Custom output directory
    $0 -s /path/to/BugSearch3/rules -o ./custom-output
EOF
}

################################################################################
# ユーティリティ
################################################################################

print_header() {
    echo ""
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}[OK] $1${NC}"
}

print_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

print_warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

print_info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

################################################################################
# YAMLパーサー（簡易版）
################################################################################

parse_yaml() {
    local file=$1
    local key=$2

    # 簡易的なYAMLパーサー
    # 注意: これは基本的なYAMLのみサポート
    grep "^${key}:" "$file" | sed "s/^${key}:\s*//" | tr -d '"' | tr -d "'"
}

################################################################################
# YAML → JSON 変換
################################################################################

convert_yaml_file() {
    local yaml_file=$1
    local output_file=$2

    # YAMLから必要なフィールドを抽出
    local id=$(parse_yaml "$yaml_file" "id")
    local name=$(parse_yaml "$yaml_file" "name")
    local severity=$(parse_yaml "$yaml_file" "severity")
    local pattern=$(parse_yaml "$yaml_file" "pattern")
    local description=$(parse_yaml "$yaml_file" "description")
    local recommendation=$(parse_yaml "$yaml_file" "recommendation")

    # パターンがない場合はスキップ
    if [ -z "$pattern" ]; then
        ((SKIPPED_RULES++))
        return 1
    fi

    # severityのマッピング
    case "$severity" in
        critical) severity="critical" ;;
        high) severity="high" ;;
        medium|warning) severity="medium" ;;
        low|info) severity="low" ;;
        *) severity="medium" ;;
    esac

    # JSON生成
    cat > "$output_file" << EOF
{
    "pattern": "$pattern",
    "description": "$description",
    "severity": "$severity",
    "recommendation": "$recommendation",
    "metadata": {
        "id": "$id",
        "name": "$name"
    }
}
EOF

    ((CONVERTED_RULES++))
    return 0
}

################################################################################
# メイン処理
################################################################################

main() {
    print_header "BugSearch3 YAML Rules Converter"

    # 入力チェック
    if [ ! -d "$BUGSEARCH3_DIR" ]; then
        print_error "BugSearch3 rules directory not found: $BUGSEARCH3_DIR"
        exit 1
    fi

    print_info "Source: $BUGSEARCH3_DIR"
    print_info "Output: $OUTPUT_DIR"
    if [ "$DRY_RUN" = true ]; then
        print_warn "DRY RUN MODE - No files will be written"
    fi
    echo ""

    # YAMLファイルを検索
    print_info "Scanning YAML files..."

    # 一時ディレクトリ
    TEMP_DIR=$(mktemp -d)

    # YAMLファイルを処理
    while IFS= read -r yaml_file; do
        ((TOTAL_FILES++))

        # 出力ファイル名
        local basename=$(basename "$yaml_file" .yaml)
        local json_file="$TEMP_DIR/${basename}.json"

        # 変換
        if convert_yaml_file "$yaml_file" "$json_file"; then
            if [ "$DRY_RUN" = false ]; then
                # 出力ディレクトリの作成
                mkdir -p "$OUTPUT_DIR/rules-bugsearch3"
            fi
        fi
    done < <(find "$BUGSEARCH3_DIR" -name "*.yaml" -type f)

    # 統計表示
    print_header "Conversion Summary"
    echo "Total YAML files: $TOTAL_FILES"
    echo "Converted rules: $CONVERTED_RULES"
    echo "Skipped rules: $SKIPPED_RULES"
    echo ""

    # クリーンアップ
    rm -rf "$TEMP_DIR"

    if [ $CONVERTED_RULES -gt 0 ]; then
        print_success "Conversion completed successfully!"
    fi
}

################################################################################
# 引数解析
################################################################################

while getopts "s:o:dh" opt; do
    case $opt in
        s) BUGSEARCH3_DIR="$OPTARG" ;;
        o) OUTPUT_DIR="$OPTARG" ;;
        d) DRY_RUN=true ;;
        h) show_help; exit 0 ;;
        *) show_help; exit 1 ;;
    esac
done

if [ -z "$BUGSEARCH3_DIR" ]; then
    print_error "BugSearch3 rules directory is required (-s option)"
    show_help
    exit 1
fi

# 実行
main
