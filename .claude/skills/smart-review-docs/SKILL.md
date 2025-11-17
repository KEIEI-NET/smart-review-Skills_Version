---
name: "smart-review-docs"
description: "ドキュメントの完全性をチェックします。JSDoc、コメント、README、型定義、API仕様などのLow優先度問題を分析する際に使用してください。"
---

# Smart Review - Documentation Analysis

## 概要
コードドキュメントの完全性と品質を評価します。関数ドキュメント、インラインコメント、プロジェクトドキュメント、API仕様などを包括的にチェックします。

## 使用タイミング
- ドキュメント整備時
- API公開前の確認
- チーム拡大時のナレッジ共有準備
- オープンソースプロジェクトの公開前
- 新規メンバーのオンボーディング準備

## 分析観点

### 1. 関数・メソッドドキュメント

**検出項目:**
- JSDoc/TSDoc の完全性
- パラメータの説明
- 戻り値の説明
- 例外・エラーの説明
- 使用例の提供
- 型情報の正確性

**重要度:** Medium

**良いドキュメントの例:**
```javascript
/**
 * ユーザーを作成し、データベースに保存します
 *
 * @param {Object} userData - ユーザー情報
 * @param {string} userData.name - ユーザーの名前（必須）
 * @param {string} userData.email - メールアドレス（必須、ユニーク）
 * @param {number} [userData.age] - 年齢（オプション）
 * @returns {Promise<User>} 作成されたユーザーオブジェクト
 * @throws {ValidationError} バリデーションエラー時
 * @throws {DatabaseError} データベースエラー時
 *
 * @example
 * const user = await createUser({
 *   name: 'John Doe',
 *   email: 'john@example.com',
 *   age: 30
 * });
 */
async function createUser(userData) {
  // ...
}
```

### 2. クラス・インターフェースドキュメント

**検出項目:**
- クラスの目的と責任
- プロパティの説明
- メソッドの説明
- 継承関係の説明
- 使用例

**重要度:** Medium

**良いドキュメントの例:**
```typescript
/**
 * ユーザー認証を管理するクラス
 *
 * このクラスは、ユーザーのログイン、ログアウト、
 * セッション管理を担当します。
 *
 * @example
 * const auth = new AuthManager(config);
 * await auth.login('user@example.com', 'password');
 * const isAuthenticated = auth.isLoggedIn();
 */
class AuthManager {
  /**
   * @param {AuthConfig} config - 認証設定
   */
  constructor(config) {
    // ...
  }
}
```

### 3. インラインコメント

**検出項目:**
- 複雑なロジックの説明
- なぜそうするのか（Why）の説明
- アルゴリズムの説明
- ハックや回避策の理由
- TODOコメントの管理
- 不要なコメントの検出

**重要度:** Low

**ベストプラクティス:**
```javascript
// ❌ 悪い例（何をしているかを説明）
// i に 1 を加算
i = i + 1;

// ✅ 良い例（なぜそうするかを説明）
// サーバーのタイムゾーンがUTCのため、ローカル時間に9時間追加
const localTime = serverTime + 9 * 60 * 60 * 1000;

// ✅ 良い例（複雑なロジックの説明）
// XYZライブラリのバグ (#123) を回避するため、
// 一時的にこの方法を使用。v2.0で修正予定
const workaround = hackySolution();
```

### 4. プロジェクトドキュメント

**検出項目:**

#### README.md
- プロジェクトの説明
- インストール手順
- 使用方法
- 設定方法
- 貢献ガイドライン
- ライセンス情報

#### CONTRIBUTING.md
- 開発環境のセットアップ
- コーディング規約
- プルリクエストのガイドライン
- テストの書き方

#### CHANGELOG.md
- バージョン履歴
- 変更内容の記録

#### API.md
- APIエンドポイントの一覧
- リクエスト/レスポンスの形式
- エラーコード

**重要度:** High（プロジェクトルートのドキュメント）

### 5. 型定義とインターフェース

**検出項目:**
- TypeScript型定義の完全性
- インターフェースの説明
- ジェネリクスの説明
- 型エイリアスの目的

**重要度:** Medium

```typescript
/**
 * API レスポンスの共通構造
 *
 * @template T - レスポンスデータの型
 */
interface ApiResponse<T> {
  /** HTTP ステータスコード */
  status: number;

  /** レスポンスデータ（成功時のみ） */
  data?: T;

  /** エラーメッセージ（失敗時のみ） */
  error?: string;

  /** タイムスタンプ（ISO 8601形式） */
  timestamp: string;
}
```

### 6. コードサンプルとチュートリアル

**検出項目:**
- examples/ ディレクトリの存在
- 実行可能なサンプルコード
- ユースケースのカバレッジ
- サンプルコードの動作確認

**重要度:** Low

### 7. TODO/FIXME コメント

**検出項目:**
- 未解決のTODO
- FIXMEの期限管理
- HACKの文書化
- XXXの理由

**重要度:** Low

**推奨フォーマット:**
```javascript
// TODO(username): タスクの説明 - 期限: 2025-12-31
// FIXME: 緊急度の高い修正が必要
// HACK: 一時的な回避策、理由を説明
// NOTE: 重要な注意事項
```

## 実行手順

1. **ファイルスキャン**
   - プロジェクトルートのドキュメント確認
   - ソースファイルのスキャン

2. **関数・クラスドキュメントチェック**
   - public な関数・メソッドの文書化率
   - JSDoc/TSDoc の形式確認
   - 必須要素（param, returns）の存在

3. **インラインコメント評価**
   - コメント密度の測定
   - 不要なコメントの検出
   - TODO/FIXME の集計

4. **プロジェクトドキュメント確認**
   - README.md の完全性
   - API ドキュメントの存在
   - 設定ファイルの説明

5. **サンプルコード検証**
   - examples/ の存在確認
   - サンプルの実行可能性

6. **結果の構造化**
   - 優先度別に整理
   - 改善推奨の生成

## 出力形式

**必ず以下のJSON形式で出力してください:**

```json
{
  "category": "documentation",
  "issuesFound": 6,
  "issues": [
    {
      "severity": "high",
      "type": "MissingReadme",
      "file": "README.md",
      "description": "README.md が存在しないか、内容が不十分です",
      "recommendation": "プロジェクトの概要、インストール方法、使用方法を含む README.md を作成してください",
      "autoFixable": false,
      "estimatedEffort": "2h",
      "template": "readme_template.md"
    },
    {
      "severity": "medium",
      "type": "MissingFunctionDoc",
      "file": "src/utils/parser.js",
      "line": 45,
      "functionName": "parseData",
      "description": "public関数 parseData にドキュメントがありません",
      "recommendation": "JSDoc を追加してください。パラメータ、戻り値、例外を説明してください",
      "autoFixable": false,
      "estimatedEffort": "15m",
      "template": "jsdoc_template.md"
    },
    {
      "severity": "medium",
      "type": "IncompleteJSDoc",
      "file": "src/api/userController.js",
      "line": 23,
      "functionName": "createUser",
      "missing": ["@returns", "@throws"],
      "description": "JSDoc が不完全です。@returns と @throws が不足しています",
      "recommendation": "戻り値とスローされる例外を文書化してください",
      "autoFixable": false,
      "estimatedEffort": "10m"
    },
    {
      "severity": "low",
      "type": "TodoComments",
      "file": "src/services/payment.js",
      "line": 67,
      "code": "// TODO: リファクタリング",
      "description": "未解決のTODOコメントがあります",
      "recommendation": "タスク管理ツールに移行するか、対応してください",
      "autoFixable": false,
      "estimatedEffort": "variable"
    },
    {
      "severity": "low",
      "type": "ObsoleteComment",
      "file": "src/utils/format.js",
      "line": 34,
      "code": "// この関数は使われていません",
      "description": "コメントアウトされたコードまたは古いコメント",
      "recommendation": "不要なコメントは削除してください",
      "autoFixable": true,
      "estimatedEffort": "2m"
    },
    {
      "severity": "medium",
      "type": "MissingApiDoc",
      "description": "APIエンドポイントのドキュメントがありません",
      "recommendation": "OpenAPI (Swagger) 仕様または API.md を作成してください",
      "autoFixable": false,
      "estimatedEffort": "4h",
      "template": "api_template.md"
    }
  ],
  "summary": {
    "critical": 0,
    "high": 1,
    "medium": 3,
    "low": 2
  },
  "coverage": {
    "functionsDocumented": 65,
    "classesDocumented": 80,
    "publicApiDocumented": 70,
    "overallCoverage": 72
  },
  "todoStats": {
    "total": 15,
    "todo": 10,
    "fixme": 3,
    "hack": 2
  },
  "scanInfo": {
    "filesScanned": 50,
    "linesAnalyzed": 6000,
    "timestamp": "2025-11-17T12:00:00Z"
  }
}
```

## 参照ファイル

### templates/
各種ドキュメントのテンプレート集：
- readme_template.md
- jsdoc_template.md
- api_template.md
- contributing_template.md

## ドキュメント品質スコア

### 評価基準（0-100点）

**90-100点: 優秀**
- すべてのpublic APIが文書化
- プロジェクトドキュメント完備
- サンプルコード充実

**70-89点: 良好**
- 主要なAPIが文書化
- README が充実
- 基本的な使用例あり

**50-69点: 改善の余地**
- 一部のAPIが文書化
- README が基本的
- サンプル不足

**30-49点: 要改善**
- ドキュメント不足
- README が不十分
- サンプルなし

**0-29点: 緊急対応**
- ほぼドキュメントなし
- READMEなし

## ベストプラクティス

### 1. README.md の構成

```markdown
# プロジェクト名

簡潔な説明（1-2文）

## 特徴

- 主要な機能1
- 主要な機能2

## インストール

\`\`\`bash
npm install project-name
\`\`\`

## クイックスタート

\`\`\`javascript
// 簡単な使用例
\`\`\`

## ドキュメント

詳細なドキュメントへのリンク

## ライセンス

MIT
```

### 2. JSDoc の完全な例

```javascript
/**
 * データを変換して保存します
 *
 * 入力データを検証し、指定された形式に変換した後、
 * データベースに保存します。
 *
 * @param {Object} data - 入力データ
 * @param {string} data.id - 一意の識別子
 * @param {string} data.name - 名前（最大100文字）
 * @param {Object} [options={}] - オプション設定
 * @param {boolean} [options.validate=true] - バリデーションを実行するか
 * @param {string} [options.format='json'] - 出力形式
 *
 * @returns {Promise<TransformedData>} 変換されたデータ
 *
 * @throws {ValidationError} 入力データが無効な場合
 * @throws {DatabaseError} データベースエラー時
 *
 * @example
 * // 基本的な使用例
 * const result = await transformAndSave({
 *   id: '123',
 *   name: 'Example'
 * });
 *
 * @example
 * // オプション指定
 * const result = await transformAndSave(
 *   { id: '123', name: 'Example' },
 *   { format: 'xml', validate: false }
 * );
 *
 * @see {@link https://docs.example.com/api|API Documentation}
 * @since 1.0.0
 */
async function transformAndSave(data, options = {}) {
  // ...
}
```

### 3. API ドキュメントの例

```markdown
## POST /api/users

ユーザーを作成します。

### リクエスト

\`\`\`json
{
  "name": "John Doe",
  "email": "john@example.com"
}
\`\`\`

### レスポンス

**Success (201)**

\`\`\`json
{
  "id": "123",
  "name": "John Doe",
  "email": "john@example.com",
  "createdAt": "2025-11-17T12:00:00Z"
}
\`\`\`

**Error (400)**

\`\`\`json
{
  "error": "Invalid email format"
}
\`\`\`
```

## ドキュメント自動生成ツール

### 推奨ツール

1. **JSDoc**: JavaScript ドキュメント生成
2. **TypeDoc**: TypeScript ドキュメント生成
3. **Swagger/OpenAPI**: API ドキュメント
4. **Storybook**: コンポーネントドキュメント
5. **Docusaurus**: プロジェクトサイト

### 設定例

```json
{
  "scripts": {
    "docs": "jsdoc -c jsdoc.json",
    "docs:api": "swagger-jsdoc -d swaggerDef.js -o api-docs.json"
  }
}
```

## 分析の実行

このSkillは以下のように使用されます：

1. **明示的な呼び出し**
   ```
   ドキュメントの完全性をチェックしてください
   ```

2. **包括的レビューの一部として**
   ```
   包括的なコードレビューをお願いします
   （セキュリティ → デバッグ → 品質 → ドキュメントの順で実行）
   ```

3. **特定のドキュメントタイプのみ**
   ```
   README.md とAPI仕様を確認してください
   ```

---

**注意:** ドキュメントは生きたドキュメントであるべきです。コードと同時に更新し、常に最新の状態を保ってください。
