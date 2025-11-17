# JSDoc テンプレート集

このドキュメントは、JSDoc コメントの書き方のテンプレート集です。

## 基本的な関数

```javascript
/**
 * 関数の簡潔な説明（1行）
 *
 * より詳細な説明（必要に応じて複数行）。
 * 関数の動作、アルゴリズム、注意点などを記述。
 *
 * @param {string} param1 - パラメータ1の説明
 * @param {number} param2 - パラメータ2の説明
 * @returns {boolean} 戻り値の説明
 *
 * @example
 * // 使用例
 * const result = myFunction('value', 42);
 * console.log(result); // true
 */
function myFunction(param1, param2) {
  // 実装
}
```

## オプションパラメータ

```javascript
/**
 * オプションパラメータを持つ関数
 *
 * @param {string} required - 必須パラメータ
 * @param {string} [optional] - オプションパラメータ
 * @param {number} [optionalWithDefault=10] - デフォルト値を持つオプションパラメータ
 * @returns {string} 結果
 */
function withOptional(required, optional, optionalWithDefault = 10) {
  // 実装
}
```

## オブジェクトパラメータ

```javascript
/**
 * オブジェクトをパラメータとして受け取る関数
 *
 * @param {Object} options - オプション設定
 * @param {string} options.name - 名前（必須）
 * @param {number} options.age - 年齢（必須）
 * @param {string} [options.email] - メールアドレス（オプション）
 * @param {boolean} [options.active=true] - アクティブ状態
 * @returns {User} ユーザーオブジェクト
 */
function createUser(options) {
  // 実装
}
```

## 非同期関数 (Promise)

```javascript
/**
 * 非同期でデータを取得します
 *
 * @async
 * @param {string} id - データID
 * @returns {Promise<Data>} データオブジェクトを含むPromise
 * @throws {NotFoundError} データが見つからない場合
 * @throws {NetworkError} ネットワークエラーが発生した場合
 *
 * @example
 * // async/await を使用
 * try {
 *   const data = await fetchData('123');
 *   console.log(data);
 * } catch (error) {
 *   console.error(error);
 * }
 *
 * @example
 * // Promise チェーンを使用
 * fetchData('123')
 *   .then(data => console.log(data))
 *   .catch(error => console.error(error));
 */
async function fetchData(id) {
  // 実装
}
```

## コールバック関数

```javascript
/**
 * コールバック関数を受け取る関数
 *
 * @param {Array} items - 処理対象の配列
 * @param {Function} callback - 各要素に適用するコールバック
 * @param {*} callback.item - 配列の各要素
 * @param {number} callback.index - インデックス
 * @param {Array} callback.array - 元の配列
 * @returns {Array} 処理後の配列
 */
function processItems(items, callback) {
  // 実装
}
```

## クラス

```javascript
/**
 * ユーザーを表すクラス
 *
 * このクラスは、ユーザーの情報を管理し、
 * 基本的な操作を提供します。
 *
 * @class
 * @example
 * const user = new User('John', 'john@example.com');
 * user.setAge(30);
 * console.log(user.getInfo());
 */
class User {
  /**
   * Userクラスのコンストラクタ
   *
   * @constructor
   * @param {string} name - ユーザーの名前
   * @param {string} email - メールアドレス
   * @throws {ValidationError} バリデーションエラー時
   */
  constructor(name, email) {
    /** @private {string} */
    this.name = name;

    /** @private {string} */
    this.email = email;

    /** @private {number} */
    this.age = 0;
  }

  /**
   * 年齢を設定します
   *
   * @param {number} age - 年齢（0以上）
   * @throws {RangeError} 年齢が負の値の場合
   * @returns {void}
   */
  setAge(age) {
    // 実装
  }

  /**
   * ユーザー情報を取得します
   *
   * @returns {Object} ユーザー情報
   * @returns {string} returns.name - 名前
   * @returns {string} returns.email - メールアドレス
   * @returns {number} returns.age - 年齢
   */
  getInfo() {
    // 実装
  }

  /**
   * 静的メソッドの例
   *
   * @static
   * @param {string} id - ユーザーID
   * @returns {Promise<User>} ユーザーオブジェクト
   */
  static async findById(id) {
    // 実装
  }
}
```

## TypeScript 型定義

```javascript
/**
 * @typedef {Object} UserData
 * @property {string} id - 一意の識別子
 * @property {string} name - 名前
 * @property {number} age - 年齢
 * @property {string[]} [tags] - タグ（オプション）
 */

/**
 * @typedef {Object} ApiResponse
 * @property {number} status - HTTPステータスコード
 * @property {*} data - レスポンスデータ
 * @property {string} [error] - エラーメッセージ（エラー時のみ）
 */

/**
 * ユーザーデータを処理します
 *
 * @param {UserData} userData - ユーザーデータ
 * @returns {ApiResponse} APIレスポンス
 */
function processUser(userData) {
  // 実装
}
```

## ジェネリック型

```javascript
/**
 * @template T
 * @param {T[]} items - アイテムの配列
 * @param {function(T): boolean} predicate - フィルター条件
 * @returns {T[]} フィルター後の配列
 */
function filter(items, predicate) {
  // 実装
}
```

## 列挙型 (Enum)

```javascript
/**
 * ユーザーの役割
 *
 * @enum {string}
 * @readonly
 */
const UserRole = {
  /** 管理者 */
  ADMIN: 'admin',

  /** 編集者 */
  EDITOR: 'editor',

  /** 閲覧者 */
  VIEWER: 'viewer'
};
```

## イベント

```javascript
/**
 * データ変更時に発火するイベント
 *
 * @event DataManager#dataChanged
 * @type {Object}
 * @property {string} id - データID
 * @property {*} newValue - 新しい値
 * @property {*} oldValue - 古い値
 */

/**
 * データマネージャー
 *
 * @fires DataManager#dataChanged
 */
class DataManager {
  /**
   * データを更新します
   *
   * @param {string} id - データID
   * @param {*} value - 新しい値
   */
  updateData(id, value) {
    // 実装
    // this.emit('dataChanged', { id, newValue: value, oldValue });
  }
}
```

## 継承

```javascript
/**
 * 基底クラス
 *
 * @class
 */
class Animal {
  /**
   * @param {string} name - 名前
   */
  constructor(name) {
    this.name = name;
  }
}

/**
 * 犬クラス
 *
 * @class
 * @extends Animal
 */
class Dog extends Animal {
  /**
   * @param {string} name - 名前
   * @param {string} breed - 犬種
   */
  constructor(name, breed) {
    super(name);
    this.breed = breed;
  }

  /**
   * 吠えます
   *
   * @override
   * @returns {string} 吠え声
   */
  makeSound() {
    return 'Woof!';
  }
}
```

## 複雑な戻り値

```javascript
/**
 * ユーザー情報を取得します
 *
 * @param {string} id - ユーザーID
 * @returns {Object} ユーザー情報とメタデータ
 * @returns {Object} returns.user - ユーザーオブジェクト
 * @returns {string} returns.user.id - ユーザーID
 * @returns {string} returns.user.name - 名前
 * @returns {Object} returns.meta - メタデータ
 * @returns {Date} returns.meta.fetchedAt - 取得日時
 * @returns {number} returns.meta.cacheHit - キャッシュヒット数
 */
function getUserWithMeta(id) {
  // 実装
}
```

## リンクと参照

```javascript
/**
 * データを検証します
 *
 * @see {@link https://example.com/validation|バリデーションガイド}
 * @see {@link Validator} - 関連するクラス
 * @see module:utils/validator
 *
 * @param {*} data - 検証対象データ
 * @returns {boolean} 検証結果
 */
function validate(data) {
  // 実装
}
```

## バージョン情報

```javascript
/**
 * 新機能の関数
 *
 * @since 1.2.0
 * @version 1.2.0
 * @param {string} param - パラメータ
 * @returns {string} 結果
 */
function newFeature(param) {
  // 実装
}

/**
 * 非推奨の関数
 *
 * @deprecated since version 2.0.0 - 代わりに {@link newFunction} を使用してください
 * @param {string} param - パラメータ
 * @returns {string} 結果
 */
function oldFunction(param) {
  // 実装
}
```

## TODO と FIXME

```javascript
/**
 * 未完成の機能
 *
 * @todo パフォーマンス最適化が必要
 * @todo エラーハンドリングの追加
 *
 * @param {string} data - データ
 * @returns {string} 結果
 */
function incompleteFeature(data) {
  // 実装
}
```

## カスタムタグ

```javascript
/**
 * カスタムタグを持つ関数
 *
 * @param {string} input - 入力
 * @returns {string} 出力
 *
 * @complexity O(n)
 * @performance Critical path
 * @security Input should be sanitized
 */
function criticalFunction(input) {
  // 実装
}
```

---

**ベストプラクティス:**

1. すべての public 関数・メソッドを文書化
2. パラメータと戻り値を必ず説明
3. 例外・エラーを文書化
4. 実用的な例を含める
5. 複雑なロジックには詳細な説明を追加
6. 型情報を正確に記述
7. リンクを活用して関連情報を提供

**避けるべきこと:**

1. コードを繰り返すだけのコメント
2. 古くなった情報
3. 不正確な型情報
4. 説明のない @param や @returns
5. 例のないドキュメント
