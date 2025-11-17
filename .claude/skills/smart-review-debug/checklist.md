# Debug Analysis Checklist

このチェックリストは、コードレビュー時に確認すべきデバッグ観点をまとめたものです。

## 1. Null/Undefined 参照エラー

### 必須チェック項目
- [ ] オブジェクトプロパティアクセス前のnullチェック
- [ ] Optional chaining (?.) の適切な使用
- [ ] Nullish coalescing (??) でのデフォルト値設定
- [ ] 配列アクセス時の境界チェック
- [ ] 関数引数のデフォルト値設定
- [ ] DOM要素取得後の存在確認

### コード例
```javascript
// ❌ 悪い例
const name = user.profile.name;
const item = array[index];

// ✅ 良い例
const name = user?.profile?.name ?? 'Unknown';
const item = array[index] ?? null;
if (index >= 0 && index < array.length) {
  const item = array[index];
}
```

## 2. 型の不一致

### 必須チェック項目
- [ ] 厳密等価演算子 (===, !==) の使用
- [ ] TypeScript の型定義との整合性
- [ ] as any の使用を最小限に
- [ ] any[] や Array<any> の使用を避ける
- [ ] 数値と文字列の明示的な変換
- [ ] boolean 型の適切な使用
- [ ] typeof チェックの実施

### コード例
```typescript
// ❌ 悪い例
if (value == null) // undefined も true
const result = '5' + 3; // '53'
const items: any[] = []; // 型安全性が失われる
const data: Array<any> = []; // 型安全性が失われる

// ✅ 良い例
if (value === null)
const result = Number('5') + 3; // 8
const items: string[] = []; // 具体的な型を指定
const data: Array<User> = []; // 具体的な型を指定
```

## 3. ロジックエラー

### 必須チェック項目
- [ ] 条件分岐の網羅性（すべてのケースを考慮）
- [ ] switch 文の default ケース
- [ ] ループの終了条件の正確性
- [ ] off-by-one エラーの確認
- [ ] 論理演算子の正確性 (&&, ||, !)
- [ ] 代入演算子 (=) と比較演算子 (==, ===) の区別
- [ ] デッドコードの削除

### コード例
```javascript
// ❌ 悪い例
for (let i = 0; i <= array.length; i++) // off-by-one
if (x = 5) // 代入演算子

// ✅ 良い例
for (let i = 0; i < array.length; i++)
if (x === 5)
```

## 4. 例外処理

### 必須チェック項目
- [ ] try-catch の適切な配置
- [ ] catch ブロックでのエラーログ記録
- [ ] 空の catch ブロックを避ける
- [ ] finally ブロックでのリソース解放
- [ ] カスタムエラーの適切な使用
- [ ] エラーメッセージの有用性
- [ ] エラーの適切な伝播

### コード例
```javascript
// ❌ 悪い例
try {
  riskyOperation();
} catch (e) {} // エラー無視

// ✅ 良い例
try {
  riskyOperation();
} catch (error) {
  logger.error('Operation failed', { error });
  throw new CustomError('Failed to process', { cause: error });
}
```

## 5. 非同期処理

### 必須チェック項目
- [ ] async 関数内での await 使用
- [ ] Promise の適切なチェーン
- [ ] .catch() によるエラーハンドリング
- [ ] unhandled rejection の防止
- [ ] レースコンディションの考慮
- [ ] Promise.all の適切な使用
- [ ] タイムアウト処理の実装

### コード例
```javascript
// ❌ 悪い例
async function bad() {
  fetchData(); // await 忘れ
  return result;
}

// ✅ 良い例
async function good() {
  try {
    const data = await fetchData();
    return data;
  } catch (error) {
    logger.error('Fetch failed', error);
    throw error;
  }
}

// 並列実行の例
const [result1, result2] = await Promise.all([
  fetch1(),
  fetch2()
]);
```

## 6. メモリリーク

### 必須チェック項目
- [ ] イベントリスナーの登録と解除のペア
- [ ] setInterval/setTimeout のクリア
- [ ] クロージャでの大きなオブジェクト参照
- [ ] グローバル変数の最小化
- [ ] DOM 参照の適切な管理
- [ ] WeakMap/WeakSet の活用

### コード例
```javascript
// ❌ 悪い例
element.addEventListener('click', handler);
// 解除されない

// ✅ 良い例
element.addEventListener('click', handler);
// クリーンアップ時
element.removeEventListener('click', handler);

// React の例
useEffect(() => {
  const timer = setInterval(doSomething, 1000);
  return () => clearInterval(timer); // クリーンアップ
}, []);
```

## 7. エッジケース

### 必須チェック項目
- [ ] 空配列の処理
- [ ] 空文字列の処理
- [ ] 0 や false の特別扱い
- [ ] 最大値・最小値の境界条件
- [ ] 特殊文字の処理
- [ ] ネットワークエラーのハンドリング
- [ ] タイムアウトの考慮

### コード例
```javascript
// ❌ 悪い例
if (array.length) {
  const first = array[0];
}
if (value) { // 0 や '' も false
  process(value);
}

// ✅ 良い例
if (array.length > 0) {
  const first = array[0];
}
if (value !== null && value !== undefined) {
  process(value);
}
```

## 8. データ検証

### 必須チェック項目
- [ ] ユーザー入力の検証
- [ ] API レスポンスの検証
- [ ] 型ガードの実装
- [ ] スキーマ検証（Zod, Yup など）
- [ ] 範囲チェック
- [ ] フォーマット検証

### コード例
```typescript
// ✅ 良い例
function processUser(data: unknown) {
  if (!isValidUser(data)) {
    throw new ValidationError('Invalid user data');
  }
  // data は User 型として扱える
}

function isValidUser(data: unknown): data is User {
  return (
    typeof data === 'object' &&
    data !== null &&
    'id' in data &&
    'name' in data
  );
}
```

## 9. 並行処理

### 必須チェック項目
- [ ] 共有状態への同時アクセス
- [ ] レースコンディションの防止
- [ ] ロックまたはセマフォの使用
- [ ] トランザクションの適切な使用
- [ ] 冪等性の保証

### コード例
```javascript
// ❌ 悪い例
let counter = 0;
async function increment() {
  const current = counter;
  await delay(10);
  counter = current + 1; // レースコンディション
}

// ✅ 良い例
let counter = 0;
const lock = new Mutex();
async function increment() {
  await lock.acquire();
  try {
    counter++;
  } finally {
    lock.release();
  }
}
```

## 10. リソース管理

### 必須チェック項目
- [ ] ファイルハンドルのクローズ
- [ ] データベース接続のクローズ
- [ ] ストリームの適切な終了
- [ ] try-finally でのリソース解放
- [ ] using 構文の活用（対応言語）

### コード例
```javascript
// ✅ 良い例
async function processFile(path) {
  const file = await fs.open(path);
  try {
    const data = await file.readFile();
    return process(data);
  } finally {
    await file.close(); // 必ず実行される
  }
}
```

## 11. 状態管理

### 必須チェック項目
- [ ] 状態の一貫性
- [ ] 不変性の保持（イミュータブル）
- [ ] 状態遷移の妥当性
- [ ] 副作用の明示的な管理
- [ ] Redux/Zustand などの適切な使用

### コード例
```javascript
// ❌ 悪い例
function addItem(state, item) {
  state.items.push(item); // ミューテーション
  return state;
}

// ✅ 良い例
function addItem(state, item) {
  return {
    ...state,
    items: [...state.items, item]
  };
}
```

## 12. パフォーマンス関連のバグ

### 必須チェック項目
- [ ] 無限ループの防止
- [ ] N+1 問題の回避
- [ ] 不要な再レンダリング
- [ ] メモ化の適切な使用
- [ ] 遅延ロード・遅延実行
- [ ] デバウンス・スロットルの使用

### コード例
```javascript
// ❌ 悪い例
users.forEach(user => {
  const posts = await fetchPosts(user.id); // N+1
});

// ✅ 良い例
const userIds = users.map(u => u.id);
const posts = await fetchPostsByUserIds(userIds);
```

## チェックリスト使用ガイド

### レビューの流れ
1. **ファイル全体のスキャン**: まず全体を俯瞰
2. **カテゴリごとにチェック**: 上記1-12を順番に
3. **問題の記録**: 発見した問題をリスト化
4. **優先度付け**: 重要度と影響度で並び替え
5. **修正推奨の作成**: 具体的な修正方法を提示

### 優先度の判断
- **Critical**: システムクラッシュやデータ損失
- **High**: 特定条件下で確実に発生する問題
- **Medium**: 発生頻度は低いが影響は大きい
- **Low**: コード品質の問題、将来的なリスク

---

**このチェックリストは定期的に更新してください。**
**プロジェクト固有のチェック項目を追加することを推奨します。**
