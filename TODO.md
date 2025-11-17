# Smart Review System - TODO List

## 📋 今後の改善・拡張予定

**最終更新:** 2025年11月17日 13:30 JST
**著作権:** (c) 2025 KEIEI.NET INC.
**作成者:** KENJI OYAMA

---

## 🔴 High Priority（早急に対応）

### 1. Python検証スクリプトのエンコーディング修正
**工数:** 15分
**担当:** 次期メンテナー

```python
# 現在の問題
json.load(open("file.json"))  # エンコーディング指定なし

# 修正
with open("file.json", encoding='utf-8') as f:
    json.load(f)
```

**影響範囲:**
- tools/convert-yaml-simple.py
- その他のPython検証スクリプト

**優先度:** High（検証ツール実行時にエラーが出る）

---

### 2. CONTRIBUTING.mdの作成
**工数:** 30分
**テンプレート:** `.claude/skills/smart-review-docs/templates/contributing_template.md`

**内容:**
- 貢献ガイドライン
- コーディング規約
- Pull Requestプロセス
- 新Skillの追加方法
- BugSearch3ルールの更新方法

**優先度:** High（オープンソースプロジェクトとして必須）

---

## 🟡 Medium Priority（計画的に対応）

### 3. CI/CD統合
**工数:** 2-3時間

**実装項目:**
- [x] GitHub Actionsワークフロー作成
  - Skills検証（validate-skills.ps1）
  - エンコーディングチェック
  - JSON構文チェック
  - テストサンプルのレビュー実行
- [ ] Pre-commit hook設定
- [ ] 自動リリースタグ生成

**ファイル:**
```yaml
# .github/workflows/validate.yml
name: Validate Skills

on: [push, pull_request]

jobs:
  validate:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - name: Validate Skills
        run: |
          pwsh -File validate-skills.ps1
      - name: Check Encoding
        run: |
          pwsh -File check-encoding.ps1
```

**優先度:** Medium

---

### 4. BugSearch3ルールの定期更新
**工数:** 30分/月

**実装:**
- [ ] 自動更新スクリプト作成
- [ ] GitHub Actionsでの自動実行（週次または月次）
- [ ] バージョン管理

```yaml
# .github/workflows/update-bugsearch3.yml
name: Update BugSearch3 Rules

on:
  schedule:
    - cron: '0 0 1 * *'  # 毎月1日

jobs:
  update-rules:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Clone BugSearch3
        run: git clone https://github.com/KEIEI-NET/BugSearch3.git
      - name: Convert Rules
        run: python tools/convert-yaml-simple.py BugSearch3/services/analysis-service-go/rules
      - name: Create PR
        run: gh pr create --title "Update BugSearch3 rules"
```

**優先度:** Medium

---

### 5. GitHubリリースページの作成
**工数:** 1時間

**タスク:**
- [ ] v1.0.0リリースタグ作成
- [ ] v1.1.0リリースタグ作成
- [ ] リリースノート作成
- [ ] バイナリアセット添付（ZIPパッケージ）

**コマンド:**
```bash
git tag -a v1.1.0 -m "Release v1.1.0 - BugSearch3 Integration"
git push origin v1.1.0
```

**優先度:** Medium

---

### 6. テストスイートの拡充
**工数:** 4-6時間

**実装項目:**
- [ ] 言語別テストサンプル作成
  - test/samples/javascript/
  - test/samples/python/
  - test/samples/go/
  - test/samples/java/
- [ ] フレームワーク別テストサンプル
  - test/samples/react/
  - test/samples/django/
- [ ] 自動テスト実行スクリプト
- [ ] 期待結果の定義

**優先度:** Medium

---

## 🟢 Low Priority（将来的に検討）

### 7. 多言語ドキュメント
**工数:** 8-10時間

- [ ] 英語版README作成（README.en.md）
- [ ] 英語版INSTALL作成
- [ ] 英語版QUICKSTART作成

**優先度:** Low（日本語で十分機能している）

---

### 8. Web UIダッシュボード
**工数:** 20-30時間

**機能:**
- [ ] レビュー結果の可視化
- [ ] トレンド分析
- [ ] HTMLレポート生成
- [ ] チャート・グラフ表示

**技術スタック:**
- Next.js / React
- Chart.js / Recharts
- Tailwind CSS

**優先度:** Low（将来的な拡張）

---

### 9. VS Code拡張機能
**工数:** 30-40時間

**機能:**
- [ ] エディタ内でリアルタイムレビュー
- [ ] 問題のインライン表示
- [ ] ワンクリック修正
- [ ] 設定UI

**優先度:** Low（大規模拡張）

---

### 10. 追加Skillsの開発
**工数:** 各2-3時間

**候補:**
- [ ] smart-review-performance（パフォーマンス専門）
- [ ] smart-review-accessibility（アクセシビリティ）
- [ ] smart-review-i18n（国際化）
- [ ] smart-review-testing（テストコード品質）

**優先度:** Low

---

### 11. カスタムルールUI
**工数:** 10-15時間

**機能:**
- [ ] GUIでルール編集
- [ ] パターンテスト
- [ ] ルールのインポート/エクスポート

**優先度:** Low

---

### 12. レポート生成機能
**工数:** 8-10時間

**機能:**
- [ ] PDF/HTMLレポート生成
- [ ] エグゼクティブサマリー
- [ ] 詳細な問題リスト
- [ ] グラフ・チャート
- [ ] 時系列トレンド

**優先度:** Low

---

## 🐛 既知の問題

### 1. Windowsでのエンコーディング警告
**現象:** Python検証スクリプトでUnicodeDecodeError
**影響:** 検証ツール実行時のみ（Claude Code使用には影響なし）
**回避策:** encoding='utf-8'を明示的に指定
**優先度:** Medium

### 2. 日本語ファイル名の文字化け
**現象:** BugSearch3ルール変換時、日本語ルール名がファイル名に
**影響:** 見た目のみ（機能には影響なし）
**回避策:** ルール名を英語に統一するか、IDベースのファイル名に
**優先度:** Low

---

## 📊 メトリクス目標

### Phase 2 目標（1-2ヶ月後）

| 項目 | 現在 | 目標 | 増加 |
|------|------|------|------|
| 総ルール数 | 368 | 500+ | +35% |
| 対応言語 | 10 | 15+ | +50% |
| ドキュメント | 12 | 15+ | +25% |
| テストサンプル | 1 | 10+ | +900% |
| GitHub Stars | 0 | 50+ | - |

---

## 🎯 ロードマップ

### Q1 2026（1-3月）
- [ ] CONTRIBUTING.md作成
- [ ] CI/CD統合
- [ ] GitHubリリース作成
- [ ] テストスイート拡充
- [ ] エンコーディング問題修正

### Q2 2026（4-6月）
- [ ] 多言語ドキュメント
- [ ] 追加Skillsの検討・開発
- [ ] パフォーマンス最適化
- [ ] コミュニティフィードバック反映

### Q3 2026（7-9月）
- [ ] Web UIダッシュボード検討
- [ ] VS Code拡張検討
- [ ] エンタープライズ機能検討

---

## 💡 改善アイデア

### アイデア1: 自動修正機能
**説明:** autoFixable: true の問題を自動修正
**工数:** 15-20時間
**技術:** AST解析、コード生成
**メリット:** 開発者の負担を大幅に軽減

### アイデア2: チーム統計ダッシュボード
**説明:** チーム全体の問題傾向を可視化
**工数:** 20-25時間
**技術:** データ集約、グラフ生成
**メリット:** マネジメント層への可視性向上

### アイデア3: AI学習モデル統合
**説明:** Claude APIで高度な分析
**工数:** 30-40時間
**技術:** Claude API、プロンプトエンジニアリング
**メリット:** 検出精度の向上

---

## 🔧 メンテナンス計画

### 月次
- [ ] BugSearch3ルールの更新確認
- [ ] 新しいCWEの追加
- [ ] ドキュメントの更新

### 四半期
- [ ] パフォーマンス測定
- [ ] ユーザーフィードバックの収集
- [ ] 優先度の見直し

### 年次
- [ ] メジャーバージョンアップ検討
- [ ] アーキテクチャレビュー
- [ ] 技術スタックの更新

---

## 📚 参考資料

### 設計ドキュメント
- ocs/smart-review-implementation-plan.md
- ocs/subagents-vs-skills-comparison.md
- docs/YAML-RULES-INTEGRATION.md

### 外部リンク
- [Claude Code Documentation](https://docs.claude.com/en/docs/claude-code)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CWE List](https://cwe.mitre.org/)
- [BugSearch3 Project](https://github.com/KEIEI-NET/BugSearch3)

---

**最終更新:** 2025年11月17日 13:30 JST
**著作権:** (c) 2025 KEIEI.NET INC.
**作成者:** KENJI OYAMA
