# 貢献ガイドライン

このプロジェクトへの貢献に興味を持っていただきありがとうございます！

このガイドラインは、プロジェクトへの貢献方法を説明するものです。

## 目次

- [行動規範](#行動規範)
- [貢献の種類](#貢献の種類)
- [開発環境のセットアップ](#開発環境のセットアップ)
- [開発ワークフロー](#開発ワークフロー)
- [コーディング規約](#コーディング規約)
- [テスト](#テスト)
- [プルリクエスト](#プルリクエスト)
- [コミットメッセージ](#コミットメッセージ)
- [ドキュメント](#ドキュメント)

---

## 行動規範

このプロジェクトは [Contributor Covenant](https://www.contributor-covenant.org/) の行動規範を採用しています。
参加することで、この規範を遵守することが期待されます。

### 期待される行動

- 歓迎的で包括的な言葉を使用する
- 異なる視点や経験を尊重する
- 建設的な批判を受け入れる
- コミュニティの利益を最優先にする

### 許容されない行動

- 性的な言葉や画像の使用
- トローリング、侮辱的なコメント、個人攻撃
- 公的または私的な嫌がらせ
- 他者の私的情報の公開

---

## 貢献の種類

### バグ報告

バグを発見した場合は、[Issues](https://github.com/[username]/[repository]/issues) で報告してください。

**バグレポートに含める情報:**
- 明確で説明的なタイトル
- 再現手順の詳細
- 期待される動作
- 実際の動作
- スクリーンショット（該当する場合）
- 環境情報（OS、Node.jsバージョンなど）

**テンプレート:**

```markdown
## バグの説明
簡潔な説明

## 再現手順
1. '...' に移動
2. '...' をクリック
3. '...' まで下にスクロール
4. エラーを確認

## 期待される動作
何が起こるべきかの明確な説明

## 実際の動作
実際に何が起こったか

## スクリーンショット
該当する場合

## 環境
- OS: [例: macOS 13.0]
- Node.js: [例: 18.17.0]
- npm: [例: 9.6.7]
- ブラウザ: [例: Chrome 118]

## 追加情報
その他の関連情報
```

### 機能提案

新機能を提案する場合は、まずIssueで議論してください。

**機能提案に含める情報:**
- 明確で説明的なタイトル
- 機能の詳細な説明
- なぜこの機能が必要か
- 実装案（任意）
- 代替案（任意）

### コード貢献

コードの貢献は大歓迎です！

1. まず既存のIssueを確認
2. 新しい機能の場合は、事前にIssueを作成
3. 以下の開発ワークフローに従う

---

## 開発環境のセットアップ

### 前提条件

- Node.js 18.x 以上
- npm 9.x 以上
- Git

### セットアップ手順

```bash
# 1. リポジトリをフォーク
# GitHubのウェブUIでフォークボタンをクリック

# 2. フォークしたリポジトリをクローン
git clone https://github.com/YOUR_USERNAME/[repository].git
cd [repository]

# 3. upstream を追加
git remote add upstream https://github.com/[username]/[repository].git

# 4. 依存関係をインストール
npm install

# 5. ビルド
npm run build

# 6. テストを実行して動作確認
npm test
```

### 開発サーバーの起動

```bash
npm run dev
```

---

## 開発ワークフロー

### 1. ブランチの作成

```bash
# 最新のmainブランチを取得
git checkout main
git pull upstream main

# 新しいブランチを作成
git checkout -b feature/your-feature-name
# または
git checkout -b fix/bug-description
```

### ブランチ命名規則

- `feature/` - 新機能
- `fix/` - バグ修正
- `docs/` - ドキュメントのみの変更
- `refactor/` - リファクタリング
- `test/` - テスト追加・修正
- `chore/` - その他の変更

### 2. 開発

```bash
# コードを変更

# 変更をステージング
git add .

# コミット
git commit -m "feat: add new feature"

# テストを実行
npm test

# リントを実行
npm run lint
```

### 3. プッシュ

```bash
# 変更をプッシュ
git push origin feature/your-feature-name
```

### 4. プルリクエストの作成

GitHubのウェブUIでプルリクエストを作成してください。

---

## コーディング規約

### JavaScript/TypeScript

```javascript
// ✅ 良い例
function calculateTotal(items, taxRate = 0.1) {
  const subtotal = items.reduce((sum, item) => sum + item.price, 0);
  const tax = subtotal * taxRate;
  return subtotal + tax;
}

// ❌ 悪い例
function calc(i,t){
  var s=0;
  for(var x=0;x<i.length;x++){
    s+=i[x].price;
  }
  return s+(s*t);
}
```

### スタイルガイド

- **インデント:** スペース2つ
- **セミコロン:** 必須
- **クォート:** シングルクォート
- **末尾カンマ:** ES5準拠
- **ブレース:** K&Rスタイル

**ESLint設定:**

```json
{
  "extends": ["eslint:recommended", "prettier"],
  "rules": {
    "semi": ["error", "always"],
    "quotes": ["error", "single"],
    "indent": ["error", 2]
  }
}
```

### 命名規則

| 種類 | 規則 | 例 |
|------|------|-----|
| 変数 | camelCase | `userName`, `totalAmount` |
| 関数 | camelCase | `calculateTotal`, `fetchUserData` |
| クラス | PascalCase | `UserManager`, `DataProcessor` |
| 定数 | UPPER_SNAKE_CASE | `MAX_RETRY`, `API_BASE_URL` |
| ファイル | kebab-case | `user-manager.js`, `data-processor.ts` |

### コメント

```javascript
// ✅ なぜそうするかを説明
// Safari のバグ (#123) を回避するため、一時的にこの実装を使用
const workaround = hackySolution();

// ❌ 何をしているかを繰り返すだけ
// iに1を加算
i = i + 1;
```

---

## テスト

### テストの実行

```bash
# すべてのテストを実行
npm test

# 特定のテストファイルを実行
npm test -- path/to/test.js

# ウォッチモード
npm test -- --watch

# カバレッジレポート
npm run test:coverage
```

### テストの書き方

```javascript
describe('CalculateTotal', () => {
  it('should calculate total with default tax rate', () => {
    const items = [
      { price: 100 },
      { price: 200 }
    ];

    const result = calculateTotal(items);

    expect(result).toBe(330); // (100 + 200) * 1.1
  });

  it('should calculate total with custom tax rate', () => {
    const items = [{ price: 100 }];

    const result = calculateTotal(items, 0.2);

    expect(result).toBe(120);
  });

  it('should handle empty array', () => {
    const result = calculateTotal([]);

    expect(result).toBe(0);
  });
});
```

### テストカバレッジ

- **最低要件:** 80%
- **推奨:** 90%以上

---

## プルリクエスト

### プルリクエストの作成

1. わかりやすいタイトルをつける
2. 変更内容を詳しく説明する
3. 関連するIssueをリンクする
4. スクリーンショットを添付（UI変更の場合）
5. チェックリストを確認

**プルリクエストテンプレート:**

```markdown
## 概要
変更内容の簡潔な説明

## 変更の種類
- [ ] バグ修正
- [ ] 新機能
- [ ] ドキュメント更新
- [ ] リファクタリング
- [ ] その他 (説明してください):

## 関連Issue
Closes #123

## 変更内容
- 変更1の詳細
- 変更2の詳細

## テスト
- [ ] すべてのテストが通過
- [ ] 新しいテストを追加
- [ ] カバレッジが80%以上

## チェックリスト
- [ ] コードがコーディング規約に従っている
- [ ] 自己レビューを実施
- [ ] コメントを追加（特に理解しにくい部分）
- [ ] ドキュメントを更新
- [ ] 変更によって新しい警告が発生しない
- [ ] テストを追加
- [ ] すべてのテストが通過

## スクリーンショット（該当する場合）

## 追加情報
その他の関連情報
```

### レビュープロセス

1. 少なくとも1人のメンテナーの承認が必要
2. すべてのCIチェックが通過する必要がある
3. コンフリクトを解決する必要がある
4. レビュアーのフィードバックに対応する

---

## コミットメッセージ

### Conventional Commits

このプロジェクトは [Conventional Commits](https://www.conventionalcommits.org/) を採用しています。

**フォーマット:**

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type:**
- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメントのみの変更
- `style`: コードの意味に影響しない変更（空白、フォーマットなど）
- `refactor`: バグ修正や機能追加ではないコード変更
- `perf`: パフォーマンス改善
- `test`: テストの追加・修正
- `chore`: ビルドプロセスやツールの変更

**例:**

```bash
feat(auth): add OAuth2 authentication

Implement OAuth2 authentication flow with Google and GitHub providers.
This allows users to sign in using their existing accounts.

Closes #123
```

```bash
fix(api): resolve race condition in user creation

Fixed a race condition that occurred when multiple requests
tried to create the same user simultaneously.

The issue was caused by checking user existence and creating
the user in separate database queries.

Fixes #456
```

---

## ドキュメント

### ドキュメントの更新

コードの変更には、対応するドキュメントの更新も含めてください。

**更新が必要なドキュメント:**
- README.md
- API.md
- JSDoc/TSDoc コメント
- CHANGELOG.md

### JSDocの書き方

```javascript
/**
 * ユーザーを作成します
 *
 * @param {Object} userData - ユーザーデータ
 * @param {string} userData.name - 名前
 * @param {string} userData.email - メールアドレス
 * @returns {Promise<User>} 作成されたユーザー
 * @throws {ValidationError} バリデーションエラー時
 *
 * @example
 * const user = await createUser({
 *   name: 'John Doe',
 *   email: 'john@example.com'
 * });
 */
async function createUser(userData) {
  // 実装
}
```

---

## リリースプロセス

### バージョニング

このプロジェクトは [Semantic Versioning](https://semver.org/) に従います。

**MAJOR.MINOR.PATCH**
- MAJOR: 破壊的変更
- MINOR: 後方互換性のある機能追加
- PATCH: 後方互換性のあるバグ修正

### CHANGELOG

すべての変更は CHANGELOG.md に記録されます。

---

## 質問やサポート

質問がある場合は：

1. まず [既存のIssue](https://github.com/[username]/[repository]/issues) を検索
2. 見つからない場合は新しいIssueを作成
3. [Discussion](https://github.com/[username]/[repository]/discussions) で質問

---

## ライセンス

このプロジェクトに貢献することで、あなたの貢献が [MIT License](../LICENSE) の下でライセンスされることに同意したものとみなされます。

---

**貢献いただきありがとうございます！** 🎉
