---
name: "smart-review-security"
description: "セキュリティ脆弱性を検出します。XSS、SQLインジェクション、コマンドインジェクション、認証・認可の問題、機密情報の露出などを分析する際に使用してください。"
---

# Smart Review - Security Analysis

## 概要
コードのセキュリティ脆弱性を包括的に分析します。OWASP Top 10に基づく脆弱性検出、CWEマッピング、修正推奨を提供します。

## 使用タイミング
- セキュリティレビューが必要な時
- ユーザー入力を扱うコードの分析
- 認証・認可機能の実装確認
- APIエンドポイントのレビュー
- プロダクション前の最終チェック

## 分析観点

### 1. XSS (Cross-Site Scripting) - CWE-79
**検出項目:**
- DOMへの直接挿入（innerHTML, outerHTML）
- React の dangerouslySetInnerHTML 使用
- 未エスケープの出力
- テンプレートエンジンでのエスケープ漏れ
- ユーザー入力のHTMLレンダリング

**重要度:** High

### 2. SQLインジェクション - CWE-89
**検出項目:**
- 文字列連結によるクエリ構築
- プリペアドステートメント未使用
- ORMの不適切な使用（raw query）
- 動的SQLの構築
- NoSQLインジェクション（MongoDB等）

**重要度:** Critical

### 3. コマンドインジェクション - CWE-78
**検出項目:**
- eval() の使用
- exec(), spawn() へのユーザー入力
- シェルコマンドの動的構築
- child_process の不適切な使用
- サーバーサイドでのコード実行

**重要度:** Critical

### 4. 認証・認可
**検出項目:**
- JWT の署名検証漏れ
- セッション管理の問題
- アクセス制御の不備（IDOR）
- 認証バイパスの可能性
- 弱い認証機構
- 適切な権限チェック不足

**重要度:** High

### 5. 機密情報の露出
**検出項目:**
- ハードコードされた認証情報（API keys, passwords）
- ログへの機密情報出力
- エラーメッセージでの情報漏洩
- 不適切な暗号化
- 機密データの平文保存
- .env ファイルのハードコード

**重要度:** Critical

### 6. 暗号化の不備
**検出項目:**
- 弱い暗号化アルゴリズム（MD5, SHA1）
- ハードコードされた暗号化キー
- 不適切なランダム値生成
- HTTPS未使用
- 暗号化されていないデータ送信

**重要度:** High

### 7. パストラバーサル - CWE-22
**検出項目:**
- ユーザー入力を使用したファイルパス構築
- 相対パス（../）の未検証使用
- ファイルアップロードの不適切な処理

**重要度:** High

## 実行手順

1. **ファイルリストの取得**
   - 対象ディレクトリのスキャン
   - 分析対象ファイルの特定（.js, .ts, .jsx, .tsx, .py, .java, etc.）

2. **パターンマッチング**
   - patterns.json の読み込み
   - 各ファイルに対してパターン適用
   - マッチした箇所の記録

3. **コンテキスト分析**
   - コード前後を確認
   - false positive の除外
   - 実際の脆弱性確度の判定

4. **CWEマッピング**
   - cwe-mapping.json を参照
   - 適切なCWE番号の割り当て

5. **修正推奨の生成**
   - ベストプラクティスに基づく推奨
   - コード例の提示
   - 自動修正可能性の判定

6. **結果の構造化**
   - JSON形式で出力
   - 重要度別にソート

## 出力形式

**必ず以下のJSON形式で出力してください:**

```json
{
  "category": "security",
  "issuesFound": 3,
  "issues": [
    {
      "severity": "critical",
      "type": "SQLi",
      "cwe": "CWE-89",
      "file": "src/api/users.js",
      "line": 42,
      "code": "SELECT * FROM users WHERE id = ' + userId + '",
      "description": "文字列連結によるSQLクエリ構築。SQLインジェクションの脆弱性があります。",
      "recommendation": "プリペアドステートメントを使用してください。例: db.query('SELECT * FROM users WHERE id = ?', [userId])",
      "autoFixable": true,
      "estimatedEffort": "30m"
    },
    {
      "severity": "high",
      "type": "XSS",
      "cwe": "CWE-79",
      "file": "src/components/UserProfile.jsx",
      "line": 28,
      "code": "element.innerHTML = userInput",
      "description": "ユーザー入力が直接DOMに挿入されています。XSS攻撃のリスクがあります。",
      "recommendation": "textContent を使用するか、DOMPurify でサニタイズしてください。",
      "autoFixable": true,
      "estimatedEffort": "15m"
    },
    {
      "severity": "critical",
      "type": "Hardcoded Credentials",
      "cwe": "CWE-798",
      "file": "src/config/database.js",
      "line": 5,
      "code": "const API_KEY = 'sk-1234567890abcdef'",
      "description": "APIキーがハードコードされています。機密情報の露出リスクがあります。",
      "recommendation": "環境変数を使用してください。例: process.env.API_KEY",
      "autoFixable": false,
      "estimatedEffort": "1h"
    }
  ],
  "summary": {
    "critical": 2,
    "high": 1,
    "medium": 0,
    "low": 0
  },
  "scanInfo": {
    "filesScanned": 15,
    "linesAnalyzed": 2450,
    "timestamp": "2025-11-17T12:00:00Z"
  }
}
```

## 参照ファイル

### patterns.json
検出パターンの定義。各脆弱性タイプごとに正規表現パターンを定義しています。

### cwe-mapping.json
CWE（Common Weakness Enumeration）のマッピング情報。脆弱性タイプとCWE番号の対応表です。

## 重要な注意事項

1. **False Positive の最小化**
   - コンテキストを考慮した分析
   - コメントアウトされたコードは除外
   - テストコード内の意図的な脆弱性は低優先度

2. **プライオリティ付け**
   - Critical: 即座に修正が必要（SQLi, Command Injection, 機密情報露出）
   - High: 早急に修正すべき（XSS, 認証問題）
   - Medium: 改善が望ましい（弱い暗号化）
   - Low: 将来的に改善（古いライブラリ）

3. **自動修正可能性**
   - 単純なパターン置換で修正可能な場合は autoFixable: true
   - 設計変更が必要な場合は autoFixable: false

4. **工数見積もり**
   - 15m: 単純な置換
   - 30m: 軽微なコード変更
   - 1h: 関数の書き換え
   - 2h+: 設計変更が必要

## ベストプラクティス

### XSS対策
```javascript
// 悪い例
element.innerHTML = userInput;

// 良い例
element.textContent = userInput;
// または
import DOMPurify from 'dompurify';
element.innerHTML = DOMPurify.sanitize(userInput);
```

### SQLインジェクション対策
```javascript
// 悪い例
db.query('SELECT * FROM users WHERE id = ' + userId);

// 良い例
db.query('SELECT * FROM users WHERE id = ?', [userId]);
```

### コマンドインジェクション対策
```javascript
// 悪い例
exec('ls ' + userInput);

// 良い例
import { spawn } from 'child_process';
spawn('ls', [userInput]);
```

### 機密情報管理
```javascript
// 悪い例
const API_KEY = 'sk-1234567890';

// 良い例
const API_KEY = process.env.API_KEY;
```

## 分析の実行

このSkillは以下のように使用されます：

1. **明示的な呼び出し**
   ```
   このプロジェクトのセキュリティ分析をお願いします
   ```

2. **包括的レビューの一部として**
   ```
   包括的なコードレビューをお願いします
   （セキュリティ → デバッグ → 品質 → ドキュメントの順で実行）
   ```

3. **特定ファイル/ディレクトリのみ**
   ```
   src/api/ 配下のファイルについてセキュリティレビューをお願いします
   ```

---

**注意:** このSkillは静的解析を行います。完全な脆弱性検出には、動的解析やペネトレーションテストも併用してください。
