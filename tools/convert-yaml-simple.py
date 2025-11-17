#!/usr/bin/env python3
"""
Simple YAML to JSON converter without external dependencies
"""

import os
import sys
import json
import re
from pathlib import Path


def parse_simple_yaml(content):
    """Simple YAML parser for basic key-value structure"""
    result = {}
    lines = content.split('\n')
    current_key = None
    multiline_value = []
    in_multiline = False
    in_list = False
    list_key = None
    list_items = []

    for line in lines:
        # Skip comments and empty lines
        if line.strip().startswith('#') or not line.strip():
            continue

        # List items (- item)
        if re.match(r'^\s*-\s+(.+)', line):
            match = re.match(r'^\s*-\s+(.+)', line)
            if match:
                if not in_list and current_key:
                    list_key = current_key
                    in_list = True
                    list_items = []
                list_items.append(match.group(1).strip())
            continue

        # Key: value pair
        match = re.match(r'^(\w+):\s*(.*)$', line)
        if match:
            # Save previous list if any
            if in_list and list_key:
                result[list_key] = list_items
                in_list = False
                list_key = None

            key = match.group(1)
            value = match.group(2).strip()

            if value:
                # Remove quotes
                value = value.strip('"').strip("'")
                result[key] = value
            else:
                current_key = key

    # Save last list if any
    if in_list and list_key:
        result[list_key] = list_items

    return result


def convert_yaml_file(yaml_path):
    """Convert single YAML file to JSON dict"""
    try:
        with open(yaml_path, 'r', encoding='utf-8') as f:
            content = f.read()

        yaml_data = parse_simple_yaml(content)

        # Check required fields
        if 'pattern' not in yaml_data:
            return None

        # Get languages
        languages = yaml_data.get('language', ['general'])
        if isinstance(languages, str):
            languages = [languages]

        # Severity mapping
        severity_map = {
            'critical': 'critical',
            'high': 'high',
            'medium': 'medium',
            'low': 'low',
            'info': 'low',
            'warning': 'medium',
            'error': 'high'
        }

        severity = severity_map.get(
            yaml_data.get('severity', 'medium').lower(),
            'medium'
        )

        # Determine category from path
        path_str = str(yaml_path).lower()
        if 'security' in path_str:
            category = 'security'
        elif 'performance' in path_str:
            category = 'quality'
        elif 'quality' in path_str or 'best_practices' in path_str or 'solid' in path_str:
            category = 'quality'
        elif 'database' in path_str:
            category = 'debug'
        else:
            category = 'debug'

        # Convert to JSON format
        rules = []
        for language in languages:
            json_rule = {
                'pattern': yaml_data['pattern'],
                'description': yaml_data.get('description', yaml_data.get('name', 'No description')),
                'severity': severity,
                'recommendation': yaml_data.get('recommendation', 'Review this pattern'),
                'metadata': {
                    'id': yaml_data.get('id', Path(yaml_path).stem),
                    'name': yaml_data.get('name', Path(yaml_path).stem),
                    'language': language,
                    'category': category,
                    'source': 'BugSearch3',
                    'source_file': Path(yaml_path).name
                }
            }

            if 'message' in yaml_data:
                json_rule['message'] = yaml_data['message']

            if 'cwe' in yaml_data:
                json_rule['metadata']['cwe'] = yaml_data['cwe']

            rules.append({
                'rule': json_rule,
                'language': language,
                'category': category
            })

        return rules

    except Exception as e:
        print(f"[ERROR] Failed to convert {yaml_path}: {e}", file=sys.stderr)
        return None


def main():
    if len(sys.argv) < 2:
        print("Usage: python convert-yaml-simple.py <bugsearch3_rules_dir> [output_dir]")
        sys.exit(1)

    bugsearch3_dir = Path(sys.argv[1])
    output_dir = Path(sys.argv[2]) if len(sys.argv) > 2 else Path('./.claude/skills')

    print("\n" + "="*50)
    print("BugSearch3 YAML Rules Converter (Simple)")
    print("="*50 + "\n")

    if not bugsearch3_dir.exists():
        print(f"[ERROR] Directory not found: {bugsearch3_dir}")
        sys.exit(1)

    print(f"[INFO] Source: {bugsearch3_dir}")
    print(f"[INFO] Output: {output_dir}\n")

    # Find YAML files
    yaml_files = list(bugsearch3_dir.rglob("*.yaml"))
    print(f"[OK] Found {len(yaml_files)} YAML files\n")

    # Convert
    all_rules = []
    converted = 0
    skipped = 0

    for yaml_file in yaml_files:
        rules = convert_yaml_file(yaml_file)
        if rules:
            all_rules.extend(rules)
            converted += len(rules)
        else:
            skipped += 1

    print(f"[OK] Converted {converted} rules")
    if skipped > 0:
        print(f"[WARNING] Skipped {skipped} files\n")

    # Group by category and language
    grouped = {}
    for item in all_rules:
        key = f"{item['category']}-{item['language']}"
        if key not in grouped:
            grouped[key] = {
                'category': item['category'],
                'language': item['language'],
                'rules': []
            }
        grouped[key]['rules'].append(item['rule'])

    # Write JSON files
    print("[INFO] Writing JSON files...\n")
    for key, group in grouped.items():
        skill_dir = output_dir / f"smart-review-{group['category']}"
        rules_dir = skill_dir / "rules-bugsearch3"
        rules_dir.mkdir(parents=True, exist_ok=True)

        # Clean language name for filename (remove non-ASCII, spaces, special chars)
        clean_language = re.sub(r'[^\w\-]', '_', group['language'])
        clean_language = re.sub(r'_+', '_', clean_language).strip('_').lower()

        file_path = rules_dir / f"bugsearch3-{clean_language}.json"

        output_data = {
            'source': 'BugSearch3',
            'language': group['language'],
            'category': group['category'],
            'rules_count': len(group['rules']),
            'rules': group['rules']
        }

        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(output_data, f, indent=2, ensure_ascii=False)

        try:
            rel_path = file_path.relative_to(Path.cwd())
        except:
            rel_path = file_path
        print(f"[OK] Created: {rel_path} ({len(group['rules'])} rules)")

    print("\n" + "="*50)
    print("Conversion Summary")
    print("="*50)
    print(f"Total YAML files: {len(yaml_files)}")
    print(f"Converted rules: {converted}")
    print(f"Skipped: {skipped}")
    print(f"\nRules by Category & Language:")
    for key in sorted(grouped.keys()):
        print(f"  {key} : {len(grouped[key]['rules'])}")
    print("\n[OK] Conversion completed!\n")


if __name__ == '__main__':
    main()
