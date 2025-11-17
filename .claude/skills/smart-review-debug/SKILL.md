---
name: "smart-review-debug"
description: "バグとロジックエラーを検出します。null参照、型エラー、例外処理の不備、非同期処理の問題などのHigh優先度問題を分析する際に使用してください。"
---

# Smart Review - Debug Analysis

## 概要
潜在的なバグとロジックエラーを検出します。プロダクション環境で発生する可能性のある問題を事前に発見し、コードの堅牢性を向上させます。

## 使用タイミング
- バグ調査時
- リファクタリング前の品質確認
- Pull Requestレビュー
- プロダクション問題の事前検出
- 新機能実装後の安定性チェック

## 分析観点

### 1. null/undefined 参照エラー

**検出項目:**
- オブジェクトアクセス前のnullチェック漏れ
- Optional chaining (?.) 未使用
- デフォルト値の未設定
- 配列アクセスの境界チェック不足
- プロパティ存在確認の欠如

**重要度:** High

**よくあるパターン:**
```javascript
// 危険
const name = user.profile.name;

// 安全
const name = user?.profile?.name ?? 'Unknown';
```

### 2. 型の不一致

**検出項目:**
- TypeScript型定義との不整合
- 暗黙的な型変換（== vs ===）
- 型アサーションの誤用（as any）
- any[] や Array<any> の使用（型安全性の喪失）
- 不適切な型キャスト
- 数値と文字列の混在演算

**重要度:** Medium to High

**よくあるパターン:**
```typescript
// 危険
if (value == null) // undefined も true になる
const items: any[] = []; // 型安全性が失われる
const data: Array<any> = []; // 型安全性が失われる

// 安全
if (value === null)
const items: string[] = []; // 具体的な型を指定
const data: Array<User> = []; // 具体的な型を指定
```

### 3. ロジックエラー

**検出項目:**
- 条件分岐の漏れ（switch の default 不足）
- ループの無限実行リスク
- 演算子の誤用（= vs ==）
- 論理演算子の誤用（&& vs ||）
- off-by-one エラー
- デッドコード

**重要度:** High

### 4. 例外処理の不備

**検出項目:**
- try-catch の不足
- エラーの握りつぶし（空の catch）
- 適切なエラーハンドリング不足
- finally ブロックの未使用
- エラーの再スローなし
- カスタムエラーの未使用

**重要度:** High

**よくあるパターン:**
```javascript
// 危険
try {
  risky();
} catch (e) {} // エラーを無視

// 安全
try {
  risky();
} catch (error) {
  logger.error('Error in risky operation', error);
  throw error; // または適切に処理
}
```

### 5. 非同期処理の問題

**検出項目:**
- Promise の未処理（unhandled rejection）
- async/await の誤用
- レースコンディション
- await 忘れ
- Promise チェーンの途中で例外が失われる
- 並列処理すべき箇所での逐次処理

**重要度:** High

**よくあるパターン:**
```javascript
// 危険
async function bad() {
  doAsync(); // await 忘れ
}

// 安全
async function good() {
  await doAsync();
}
```

### 6. メモリリーク

**検出項目:**
- イベントリスナーの解除漏れ
- タイマーのクリア忘れ（setInterval, setTimeout）
- クロージャでの大きなオブジェクト保持
- グローバル変数の濫用
- DOM参照の保持

**重要度:** Medium

### 7. エッジケースの未処理

**検出項目:**
- 空配列・空文字列のハンドリング不足
- 0 や false の特別扱い漏れ
- 最大値・最小値の境界条件
- ネットワークエラーのハンドリング
- タイムアウト処理の欠如

**重要度:** Medium

## 実行手順

1. **ファイルスキャン**
   - 対象ファイルの特定
   - 言語に応じたパターン選択

2. **静的解析**
   - common-patterns.json のパターン適用
   - AST解析（可能な場合）
   - 型チェック（TypeScript）

3. **コンテキスト分析**
   - 関数の複雑度測定
   - データフローの追跡
   - エラーハンドリングパスの確認

4. **チェックリスト照合**
   - checklist.md の項目を順次確認
   - 各カテゴリの問題を収集

5. **優先度付け**
   - 影響度に基づいてソート
   - クリティカルパスの問題を上位に

6. **結果の構造化**
   - JSON形式で出力

## 出力形式

**必ず以下のJSON形式で出力してください:**

```json
{
  "category": "debug",
  "issuesFound": 5,
  "issues": [
    {
      "severity": "high",
      "type": "NullReference",
      "file": "src/utils/parser.js",
      "line": 45,
      "code": "const name = user.profile.name",
      "description": "user.profile が null/undefined の場合にエラーが発生します",
      "recommendation": "Optional chaining を使用してください: user?.profile?.name",
      "autoFixable": true,
      "estimatedEffort": "5m"
    },
    {
      "severity": "high",
      "type": "AsyncAwaitMissing",
      "file": "src/api/handler.js",
      "line": 78,
      "code": "fetchData()",
      "description": "非同期関数の呼び出しで await が不足しています",
      "recommendation": "await fetchData() に修正してください",
      "autoFixable": true,
      "estimatedEffort": "5m"
    },
    {
      "severity": "medium",
      "type": "EmptyCatch",
      "file": "src/services/api.js",
      "line": 120,
      "code": "} catch (e) {}",
      "description": "例外が握りつぶされています",
      "recommendation": "エラーをログに記録するか、適切に処理してください",
      "autoFixable": false,
      "estimatedEffort": "15m"
    },
    {
      "severity": "medium",
      "type": "TypeCoercion",
      "file": "src/validators/input.js",
      "line": 55,
      "code": "if (value == null)",
      "description": "暗黙的な型変換が発生します",
      "recommendation": "厳密等価演算子 === を使用してください",
      "autoFixable": true,
      "estimatedEffort": "2m"
    },
    {
      "severity": "low",
      "type": "MissingDefault",
      "file": "src/utils/formatter.js",
      "line": 92,
      "code": "switch (type) { case 'a': ... case 'b': ... }",
      "description": "switch 文に default ケースがありません",
      "recommendation": "default ケースを追加してください",
      "autoFixable": false,
      "estimatedEffort": "10m"
    }
  ],
  "summary": {
    "critical": 0,
    "high": 2,
    "medium": 2,
    "low": 1
  },
  "scanInfo": {
    "filesScanned": 25,
    "linesAnalyzed": 3200,
    "timestamp": "2025-11-17T12:00:00Z"
  }
}
```

## 参照ファイル

### checklist.md
詳細なチェック項目リスト。カテゴリごとに確認すべき項目を網羅。

### common-patterns.json
よくあるバグパターンの定義。正規表現ベースの検出ルール。

## 重要な注意事項

1. **False Positive の管理**
   - テストコードは別扱い
   - 意図的な null チェックスキップ（!! 演算子など）を考慮
   - フレームワーク固有のパターンを理解

2. **優先度の判断基準**
   - High: クラッシュやデータ損失に直結
   - Medium: 特定条件下で問題が発生
   - Low: コード品質の問題だが動作には影響小

3. **自動修正の可否**
   - 単純な構文変更は autoFixable: true
   - ロジック変更が必要なものは false

4. **言語別の考慮事項**
   - JavaScript/TypeScript: 型の柔軟性に注意
   - Python: インデントエラー、型ヒント
   - Java: Null Pointer Exception
   - Go: error チェック漏れ

## ベストプラクティス

### Null チェック
```javascript
// 危険
const value = obj.prop;

// 安全
const value = obj?.prop ?? defaultValue;
```

### 非同期処理
```javascript
// 危険
async function bad() {
  const data = getData(); // await 忘れ
  return data;
}

// 安全
async function good() {
  const data = await getData();
  return data;
}
```

### 例外処理
```javascript
// 危険
try {
  risky();
} catch (e) {
  // 無視
}

// 安全
try {
  risky();
} catch (error) {
  logger.error('Error:', error);
  // 適切に処理または再スロー
}
```

### 型チェック
```javascript
// 危険
if (value == null)

// 安全
if (value === null || value === undefined)
// または
if (value == null) // null と undefined のみを検出したい場合
```

## 高度な分析

### データフロー解析
変数の初期化から使用までの経路を追跡し、未初期化変数の使用を検出。

### 制御フロー解析
すべての実行パスで適切なエラーハンドリングがあるか確認。

### タイプナローイング
TypeScript の型ガードが適切に使用されているか確認。

## 分析の実行

このSkillは以下のように使用されます：

1. **明示的な呼び出し**
   ```
   このコードにバグがないかチェックしてください
   ```

2. **包括的レビューの一部として**
   ```
   包括的なコードレビューをお願いします
   （セキュリティ → デバッグ → 品質 → ドキュメントの順で実行）
   ```

3. **特定の問題タイプのみ**
   ```
   非同期処理のエラーハンドリングをチェックしてください
   ```

---

**注意:** このSkillは静的解析を行います。実行時のみ発生する問題は、実際のテストやプロファイリングで検出してください。
