---
name: "smart-review-quality"
description: "コード品質を評価します。循環的複雑度、保守性、設計パターン、コードスメル、命名規則などのMedium優先度問題を分析する際に使用してください。"
---

# Smart Review - Quality Analysis

## 概要
コードの品質と保守性を総合的に評価します。長期的なメンテナンス性、可読性、拡張性の観点からコードを分析し、改善提案を行います。

## 使用タイミング
- リファクタリングの計画時
- コードレビュー時
- 技術的負債の評価
- 新しいチームメンバーのオンボーディング前
- プロジェクト品質基準の確認

## 分析観点

### 1. 循環的複雑度 (Cyclomatic Complexity)

**検出項目:**
- 関数の複雑度測定（McCabe Complexity）
- ネストレベルの深さ
- 分岐の数（if, switch, ternary）
- ループの数
- 複雑な条件式

**重要度:** Medium

**基準:**
- 1-10: シンプル（理想）
- 11-20: やや複雑（要注意）
- 21-50: 複雑（リファクタリング推奨）
- 51+: 非常に複雑（即座にリファクタリング）

### 2. コードスメル (Code Smells)

**検出項目:**

#### 長すぎる関数 (Long Method)
- 50行を超える関数
- 複数の責任を持つ関数
- 抽象化レベルが混在

#### 長すぎるクラス (Large Class)
- 300行を超えるクラス
- 多数のメソッドやプロパティ
- 複数の責任

#### 重複コード (Duplicated Code)
- コピー&ペーストされたコード
- 類似のロジック
- パターンの繰り返し

#### デッドコード (Dead Code)
- 使用されていない関数
- 到達不可能なコード
- コメントアウトされたコード

#### マジックナンバー (Magic Numbers)
- ハードコードされた数値
- 意味不明な定数
- 名前のない設定値

#### 神オブジェクト (God Object)
- すべてを知り、すべてをする
- 多数の依存関係
- 変更の影響範囲が広い

**重要度:** Medium to High

### 3. 設計原則

**SOLID原則:**

#### S - Single Responsibility Principle（単一責任原則）
- 1つのクラス/関数は1つの責任のみ
- 変更理由は1つだけ

#### O - Open/Closed Principle（開放閉鎖原則）
- 拡張に開いている
- 修正に閉じている

#### L - Liskov Substitution Principle（リスコフの置換原則）
- 派生クラスは基底クラスと置換可能

#### I - Interface Segregation Principle（インターフェース分離原則）
- 小さく特化したインターフェース
- 不要なメソッドを強制しない

#### D - Dependency Inversion Principle（依存性逆転原則）
- 抽象に依存
- 具象に依存しない

**DRY原則（Don't Repeat Yourself）:**
- コードの重複を避ける
- 再利用可能なコンポーネント

**KISS原則（Keep It Simple, Stupid）:**
- シンプルに保つ
- 過度な抽象化を避ける

**重要度:** Medium

### 4. 命名規則

**検出項目:**
- 変数名の明確性（意味のある名前）
- 関数名の適切性（動詞で始まる）
- クラス名の適切性（名詞）
- 一貫性のある命名パターン
- 省略形の適切な使用
- 型情報を含む名前（ハンガリアン記法は非推奨）

**アンチパターン:**
- 1文字変数（ループ変数以外）
- 意味不明な省略形
- temp, data, info などの曖昧な名前
- 否定形の boolean（isNotValid ではなく isValid）

**重要度:** Low to Medium

### 5. 関数とメソッド

**検出項目:**
- 引数の数（理想は3つ以下）
- 戻り値の一貫性
- 副作用の明示性
- Pure Function の推奨
- 高階関数の適切な使用

**重要度:** Medium

### 6. クラス設計

**検出項目:**
- カプセル化（private, protected, public）
- 継承の適切性
- コンポジションの活用
- インターフェースの設計
- 抽象クラスの使用

**重要度:** Medium

### 7. モジュール化

**検出項目:**
- ファイルサイズ（500行以下推奨）
- モジュール間の依存関係
- 循環依存の検出
- 凝集度（Cohesion）
- 結合度（Coupling）

**重要度:** Medium

### 8. パフォーマンス考慮

**検出項目:**
- O(n²) 以上のアルゴリズム
- 不要な計算の繰り返し
- メモ化の機会
- 遅延評価の活用
- 早期リターン

**重要度:** Low to Medium

## 実行手順

1. **ファイルスキャン**
   - プロジェクト全体の構造把握
   - 各ファイルのサイズと行数

2. **メトリクス測定**
   - metrics.json の基準を適用
   - 循環的複雑度の計算
   - 関数・クラスのサイズ測定

3. **コードスメル検出**
   - code-smells.json のパターン適用
   - 重複コードの検出
   - デッドコードの特定

4. **設計原則の評価**
   - SOLID原則の遵守度
   - DRY原則の確認
   - 依存関係の分析

5. **命名規則チェック**
   - 識別子の命名パターン
   - 一貫性の確認

6. **結果の優先度付け**
   - 影響度の評価
   - リファクタリングの優先順位

7. **改善提案の生成**
   - 具体的なリファクタリング案
   - コード例の提示

## 出力形式

**必ず以下のJSON形式で出力してください:**

```json
{
  "category": "quality",
  "issuesFound": 8,
  "issues": [
    {
      "severity": "high",
      "type": "HighComplexity",
      "file": "src/services/OrderProcessor.js",
      "line": 45,
      "functionName": "processOrder",
      "metric": {
        "complexity": 25,
        "linesOfCode": 120,
        "nestingLevel": 5
      },
      "description": "関数の循環的複雑度が25と高く、理解・テストが困難です",
      "recommendation": "関数を小さな関数に分割してください。抽出候補: validateOrder, calculateTotal, applyDiscounts",
      "autoFixable": false,
      "estimatedEffort": "2h"
    },
    {
      "severity": "medium",
      "type": "DuplicatedCode",
      "files": [
        "src/utils/formatDate.js:12",
        "src/helpers/dateUtils.js:34"
      ],
      "description": "日付フォーマット処理が2箇所で重複しています",
      "recommendation": "共通のユーティリティ関数に抽出してください",
      "autoFixable": false,
      "estimatedEffort": "30m"
    },
    {
      "severity": "medium",
      "type": "LongClass",
      "file": "src/models/User.js",
      "line": 1,
      "metric": {
        "linesOfCode": 450,
        "methods": 32,
        "properties": 18
      },
      "description": "Userクラスが大きすぎます（450行、32メソッド）",
      "recommendation": "責任を分離してください。例: UserProfile, UserPermissions, UserPreferences",
      "autoFixable": false,
      "estimatedEffort": "4h"
    },
    {
      "severity": "low",
      "type": "MagicNumber",
      "file": "src/config/limits.js",
      "line": 15,
      "code": "if (count > 100)",
      "description": "マジックナンバー 100 が使用されています",
      "recommendation": "定数として定義してください: const MAX_ITEMS = 100",
      "autoFixable": true,
      "estimatedEffort": "5m"
    },
    {
      "severity": "low",
      "type": "PoorNaming",
      "file": "src/utils/helpers.js",
      "line": 23,
      "code": "function fn(x, y)",
      "description": "関数名と引数名が不明確です",
      "recommendation": "意味のある名前に変更: function calculateDistance(pointA, pointB)",
      "autoFixable": false,
      "estimatedEffort": "10m"
    },
    {
      "severity": "medium",
      "type": "TooManyParameters",
      "file": "src/api/userController.js",
      "line": 78,
      "code": "function createUser(name, email, age, address, phone, role, department)",
      "description": "関数の引数が7つあります（推奨: 3つ以下）",
      "recommendation": "オブジェクトとしてまとめてください: function createUser(userData)",
      "autoFixable": false,
      "estimatedEffort": "30m"
    },
    {
      "severity": "low",
      "type": "DeadCode",
      "file": "src/legacy/oldApi.js",
      "line": 45,
      "description": "使用されていない関数が検出されました",
      "recommendation": "削除するか、使用する予定があればコメントで説明してください",
      "autoFixable": false,
      "estimatedEffort": "5m"
    },
    {
      "severity": "medium",
      "type": "GodObject",
      "file": "src/core/Application.js",
      "line": 1,
      "metric": {
        "dependencies": 25,
        "responsibilityCount": 8
      },
      "description": "Applicationクラスが多くの責任を持ちすぎています",
      "recommendation": "責任を分離: Router, Logger, ConfigManager, EventBus など",
      "autoFixable": false,
      "estimatedEffort": "8h"
    }
  ],
  "summary": {
    "critical": 0,
    "high": 1,
    "medium": 4,
    "low": 3
  },
  "metrics": {
    "averageComplexity": 8.5,
    "averageFunctionLength": 25,
    "averageClassLength": 180,
    "duplicateCodePercentage": 5.2,
    "testCoverage": null
  },
  "scanInfo": {
    "filesScanned": 45,
    "linesAnalyzed": 8500,
    "timestamp": "2025-11-17T12:00:00Z"
  }
}
```

## 参照ファイル

### metrics.json
品質メトリクスの基準値定義。複雑度、関数サイズ、クラスサイズなどの閾値。

### code-smells.json
コードスメルのパターン定義。各スメルの検出ルールと修正推奨。

## 品質スコアリング

各ファイルに対して品質スコアを算出（0-100）：

- **90-100**: 優秀（Excellent）
- **70-89**: 良好（Good）
- **50-69**: 改善の余地あり（Fair）
- **30-49**: 要改善（Poor）
- **0-29**: 緊急対応必要（Critical）

**スコア計算要素:**
- 複雑度（30%）
- コードスメル（25%）
- 命名規則（15%）
- モジュール化（15%）
- 設計原則遵守（15%）

## ベストプラクティス

### 関数の分割
```javascript
// ❌ 悪い例
function processOrder(order) {
  // 100行の処理...
  // バリデーション、計算、保存、通知すべてを含む
}

// ✅ 良い例
function processOrder(order) {
  validateOrder(order);
  const total = calculateTotal(order);
  const savedOrder = saveOrder(order, total);
  notifyCustomer(savedOrder);
  return savedOrder;
}
```

### マジックナンバーの排除
```javascript
// ❌ 悪い例
if (user.age > 18 && score > 75) {
  // ...
}

// ✅ 良い例
const ADULT_AGE = 18;
const PASSING_SCORE = 75;

if (user.age > ADULT_AGE && score > PASSING_SCORE) {
  // ...
}
```

### 適切な命名
```javascript
// ❌ 悪い例
function calc(x, y) {
  return x * y + 10;
}

// ✅ 良い例
function calculateTotalWithTax(price, quantity) {
  const TAX_AMOUNT = 10;
  return price * quantity + TAX_AMOUNT;
}
```

### 引数の整理
```javascript
// ❌ 悪い例
function createUser(name, email, age, address, phone, role) {
  // ...
}

// ✅ 良い例
function createUser(userData) {
  const { name, email, age, address, phone, role } = userData;
  // ...
}
```

## リファクタリング優先度

### 高優先度
1. 複雑度が20以上の関数
2. 500行以上のクラス
3. 神オブジェクト（多数の責任）
4. 重複コード（3箇所以上）

### 中優先度
1. 複雑度が10-20の関数
2. 200-500行のクラス
3. 長い引数リスト（5個以上）
4. デッドコード

### 低優先度
1. マジックナンバー
2. 不明確な命名
3. コメント不足
4. 軽微なコードスメル

## 分析の実行

このSkillは以下のように使用されます：

1. **明示的な呼び出し**
   ```
   このコードの品質をチェックしてください
   ```

2. **包括的レビューの一部として**
   ```
   包括的なコードレビューをお願いします
   （セキュリティ → デバッグ → 品質 → ドキュメントの順で実行）
   ```

3. **特定の観点のみ**
   ```
   コードの複雑度と保守性を評価してください
   ```

---

**注意:** 品質評価は主観的な側面も含みます。プロジェクトの文脈、チームの慣習、ビジネス要件を考慮して判断してください。
