/**
 * テスト用のサンプルファイル
 *
 * このファイルは意図的にセキュリティ脆弱性、バグ、品質問題、
 * ドキュメント不足を含んでいます。
 *
 * Smart Review Skillsの動作検証用です。
 */

// ========================================
// セキュリティの問題（smart-review-security）
// ========================================

// 1. XSS脆弱性
function renderUserProfile(userInput) {
  const element = document.getElementById('profile');
  element.innerHTML = userInput; // XSS脆弱性
}

// 2. SQLインジェクション
function getUserById(userId) {
  const query = 'SELECT * FROM users WHERE id = ' + userId; // SQLインジェクション
  return db.query(query);
}

// 3. コマンドインジェクション
const { exec } = require('child_process');

function listFiles(directory) {
  exec('ls ' + directory, (error, stdout) => { // コマンドインジェクション
    console.log(stdout);
  });
}

// 4. ハードコードされた認証情報
const API_KEY = 'sk-1234567890abcdefghijklmnopqrstuvwxyz'; // 機密情報の露出
const DB_PASSWORD = 'super_secret_password'; // 機密情報の露出

// 5. eval() の使用
function executeCode(code) {
  eval(code); // 危険なコード実行
}

// 6. 弱い暗号化
const crypto = require('crypto');

function hashPassword(password) {
  return crypto.createHash('md5').update(password).digest('hex'); // 弱いハッシュアルゴリズム
}

// ========================================
// デバッグの問題（smart-review-debug）
// ========================================

// 1. Null参照エラー
function getUserName(user) {
  return user.profile.name; // user または profile が null の可能性
}

// 2. 非同期処理のawait忘れ
async function fetchUserData(id) {
  const data = fetchFromApi(id); // await 忘れ
  return data;
}

// 3. 空のcatchブロック
function riskyOperation() {
  try {
    dangerousFunction();
  } catch (e) {} // エラーを無視
}

// 4. 型の不一致
function compareValues(a, b) {
  if (a == b) { // 緩い等価演算子
    return true;
  }
  return false;
}

// 5. ループのoff-by-one
function processArray(arr) {
  for (let i = 0; i <= arr.length; i++) { // off-by-one エラー
    console.log(arr[i]);
  }
}

// 6. イベントリスナーの解除漏れ
function setupEventListener() {
  const button = document.getElementById('btn');
  button.addEventListener('click', handleClick); // removeEventListener がない
}

// ========================================
// 品質の問題（smart-review-quality）
// ========================================

// 1. 長すぎる関数（80行以上）
function processOrder(order) {
  // バリデーション
  if (!order) return null;
  if (!order.items) return null;
  if (order.items.length === 0) return null;

  // 計算
  let total = 0;
  for (let i = 0; i < order.items.length; i++) {
    if (order.items[i].price) {
      total += order.items[i].price * order.items[i].quantity;
    }
  }

  // 割引適用
  if (order.coupon) {
    if (order.coupon.type === 'percentage') {
      total = total - (total * order.coupon.value / 100);
    } else if (order.coupon.type === 'fixed') {
      total = total - order.coupon.value;
    }
  }

  // 税金計算
  const tax = total * 0.1;
  total += tax;

  // 送料計算
  let shipping = 0;
  if (total < 5000) {
    shipping = 500;
  } else if (total < 10000) {
    shipping = 300;
  }
  total += shipping;

  // ポイント計算
  const points = Math.floor(total / 100);

  // 保存
  order.total = total;
  order.tax = tax;
  order.shipping = shipping;
  order.points = points;

  // データベースに保存
  db.save(order);

  // メール送信
  sendEmail(order.email, 'Order confirmation', generateEmailBody(order));

  // 在庫更新
  for (let i = 0; i < order.items.length; i++) {
    updateInventory(order.items[i].id, order.items[i].quantity);
  }

  return order;
}

// 2. マジックナンバー
function calculateDiscount(price) {
  if (price > 10000) {
    return price * 0.1; // マジックナンバー
  } else if (price > 5000) {
    return price * 0.05; // マジックナンバー
  }
  return 0;
}

// 3. 不明確な変数名
function fn(x, y) {
  const a = x + y;
  const b = a * 2;
  return b;
}

// 4. 引数が多すぎる関数
function createUser(name, email, age, address, phone, role, department, startDate) {
  // 7つの引数
}

// 5. 重複コード
function formatDate1(date) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

function formatDate2(date) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

// 6. 深いネスト
function complexLogic(data) {
  if (data) {
    if (data.items) {
      for (let item of data.items) {
        if (item.active) {
          if (item.quantity > 0) {
            if (item.price > 100) {
              // 深すぎるネスト
              console.log(item);
            }
          }
        }
      }
    }
  }
}

// ========================================
// ドキュメントの問題（smart-review-docs）
// ========================================

// 1. ドキュメントがない関数
function calculateTotalPrice(items, taxRate, discountRate) {
  // ドキュメントなし
  const subtotal = items.reduce((sum, item) => sum + item.price, 0);
  const discount = subtotal * discountRate;
  const tax = (subtotal - discount) * taxRate;
  return subtotal - discount + tax;
}

// 2. 不完全なJSDoc
/**
 * データを変換します
 */
function transformData(input, options) {
  // @param と @returns が不足
}

// 3. TODOコメント
function incompleteFeature() {
  // TODO: この機能を実装する
  // FIXME: バグを修正する必要がある
  // HACK: 一時的な回避策
}

// 4. 古いコメント
function processData(data) {
  // この関数は使われていません
  // 削除予定
  return data;
}

// ========================================
// 追加のテストケース
// ========================================

// レースコンディション
let counter = 0;
async function incrementCounter() {
  const current = counter;
  await delay(10);
  counter = current + 1; // レースコンディション
}

// JSON.parse without try-catch
function parseJson(str) {
  return JSON.parse(str); // エラーハンドリングなし
}

// switch without default
function getStatusMessage(status) {
  switch (status) {
    case 'active':
      return 'アクティブ';
    case 'inactive':
      return '非アクティブ';
    // default ケースがない
  }
}

// Promise without catch
function fetchData() {
  fetch('https://api.example.com/data')
    .then(response => response.json())
    .then(data => console.log(data));
  // .catch() がない
}

// console.log with password
function login(username, password) {
  console.log('Login attempt:', username, password); // パスワードをログ出力
  // 認証処理
}

module.exports = {
  renderUserProfile,
  getUserById,
  calculateTotalPrice,
  processOrder
};
