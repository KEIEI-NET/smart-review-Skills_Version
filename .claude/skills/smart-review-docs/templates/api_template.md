# API仕様書

**バージョン:** 1.0.0
**ベースURL:** `https://api.example.com/v1`
**認証:** Bearer Token

## 目次

- [認証](#認証)
- [共通仕様](#共通仕様)
- [エラーハンドリング](#エラーハンドリング)
- [レート制限](#レート制限)
- [エンドポイント一覧](#エンドポイント一覧)

---

## 認証

すべてのAPIリクエストには、Authorizationヘッダーに Bearer Token が必要です。

```http
Authorization: Bearer YOUR_API_TOKEN
```

### トークンの取得

```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**レスポンス:**

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 3600
}
```

---

## 共通仕様

### リクエストヘッダー

| ヘッダー | 必須 | 説明 |
|---------|------|------|
| Authorization | ○ | Bearer Token |
| Content-Type | ○ | application/json |
| Accept | ○ | application/json |
| X-Request-ID | △ | リクエスト追跡用の一意なID |

### レスポンス形式

すべてのレスポンスは以下の共通フォーマットに従います：

```json
{
  "status": 200,
  "data": {},
  "message": "Success",
  "timestamp": "2025-11-17T12:00:00Z"
}
```

### ページネーション

リスト取得APIは以下のクエリパラメータをサポートします：

| パラメータ | 型 | デフォルト | 説明 |
|-----------|-----|-----------|------|
| page | integer | 1 | ページ番号 |
| limit | integer | 20 | 1ページあたりのアイテム数（最大100） |
| sort | string | created_at | ソートフィールド |
| order | string | desc | ソート順序（asc/desc） |

**レスポンス例:**

```json
{
  "status": 200,
  "data": {
    "items": [...],
    "pagination": {
      "currentPage": 1,
      "totalPages": 10,
      "totalItems": 200,
      "itemsPerPage": 20
    }
  }
}
```

---

## エラーハンドリング

### エラーレスポンス形式

```json
{
  "status": 400,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  },
  "timestamp": "2025-11-17T12:00:00Z"
}
```

### HTTPステータスコード

| コード | 説明 |
|-------|------|
| 200 | 成功 |
| 201 | 作成成功 |
| 204 | 成功（レスポンスボディなし） |
| 400 | リクエストエラー |
| 401 | 認証エラー |
| 403 | 権限エラー |
| 404 | リソースが見つからない |
| 409 | 競合エラー |
| 422 | バリデーションエラー |
| 429 | レート制限超過 |
| 500 | サーバーエラー |

### エラーコード一覧

| コード | 説明 |
|-------|------|
| VALIDATION_ERROR | バリデーションエラー |
| AUTHENTICATION_FAILED | 認証失敗 |
| AUTHORIZATION_FAILED | 権限不足 |
| RESOURCE_NOT_FOUND | リソースが見つからない |
| DUPLICATE_RESOURCE | リソースが既に存在 |
| RATE_LIMIT_EXCEEDED | レート制限超過 |
| INTERNAL_SERVER_ERROR | サーバー内部エラー |

---

## レート制限

| プラン | リクエスト数 | 期間 |
|-------|------------|------|
| Free | 100 | 1時間 |
| Basic | 1,000 | 1時間 |
| Pro | 10,000 | 1時間 |

レート制限に関する情報はレスポンスヘッダーに含まれます：

```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1637164800
```

---

## エンドポイント一覧

### ユーザー管理

#### ユーザー一覧取得

```http
GET /users
```

**クエリパラメータ:**

| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| page | integer | × | ページ番号 |
| limit | integer | × | 1ページあたりのアイテム数 |
| search | string | × | 検索キーワード |

**レスポンス例:**

```json
{
  "status": 200,
  "data": {
    "items": [
      {
        "id": "usr_123",
        "name": "John Doe",
        "email": "john@example.com",
        "createdAt": "2025-11-17T12:00:00Z",
        "updatedAt": "2025-11-17T12:00:00Z"
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 5,
      "totalItems": 100,
      "itemsPerPage": 20
    }
  }
}
```

#### ユーザー詳細取得

```http
GET /users/{id}
```

**パスパラメータ:**

| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| id | string | ○ | ユーザーID |

**レスポンス例:**

```json
{
  "status": 200,
  "data": {
    "id": "usr_123",
    "name": "John Doe",
    "email": "john@example.com",
    "profile": {
      "bio": "Software Developer",
      "location": "Tokyo, Japan",
      "website": "https://example.com"
    },
    "createdAt": "2025-11-17T12:00:00Z",
    "updatedAt": "2025-11-17T12:00:00Z"
  }
}
```

**エラーレスポンス:**

```json
{
  "status": 404,
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "User not found"
  }
}
```

#### ユーザー作成

```http
POST /users
```

**リクエストボディ:**

```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "SecurePassword123!",
  "profile": {
    "bio": "Software Developer",
    "location": "Tokyo, Japan"
  }
}
```

**リクエストスキーマ:**

| フィールド | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| name | string | ○ | 名前（3-100文字） |
| email | string | ○ | メールアドレス（一意） |
| password | string | ○ | パスワード（8-100文字） |
| profile | object | × | プロフィール情報 |
| profile.bio | string | × | 自己紹介（最大500文字） |
| profile.location | string | × | 所在地 |

**レスポンス例:**

```json
{
  "status": 201,
  "data": {
    "id": "usr_124",
    "name": "John Doe",
    "email": "john@example.com",
    "createdAt": "2025-11-17T12:00:00Z"
  }
}
```

**バリデーションエラー:**

```json
{
  "status": 422,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "field": "email",
        "message": "Email is already taken"
      },
      {
        "field": "password",
        "message": "Password must be at least 8 characters"
      }
    ]
  }
}
```

#### ユーザー更新

```http
PUT /users/{id}
PATCH /users/{id}
```

**パスパラメータ:**

| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| id | string | ○ | ユーザーID |

**リクエストボディ (PATCH):**

```json
{
  "name": "Jane Doe",
  "profile": {
    "bio": "Updated bio"
  }
}
```

**レスポンス例:**

```json
{
  "status": 200,
  "data": {
    "id": "usr_123",
    "name": "Jane Doe",
    "email": "john@example.com",
    "profile": {
      "bio": "Updated bio",
      "location": "Tokyo, Japan"
    },
    "updatedAt": "2025-11-17T13:00:00Z"
  }
}
```

#### ユーザー削除

```http
DELETE /users/{id}
```

**パスパラメータ:**

| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| id | string | ○ | ユーザーID |

**レスポンス例:**

```json
{
  "status": 204
}
```

---

## Webhook

### Webhook登録

```http
POST /webhooks
```

**リクエストボディ:**

```json
{
  "url": "https://your-server.com/webhook",
  "events": ["user.created", "user.updated"],
  "secret": "your_webhook_secret"
}
```

### Webhookペイロード

```json
{
  "id": "evt_123",
  "type": "user.created",
  "data": {
    "id": "usr_124",
    "name": "John Doe",
    "email": "john@example.com"
  },
  "timestamp": "2025-11-17T12:00:00Z"
}
```

### Webhook署名検証

```javascript
const crypto = require('crypto');

function verifyWebhookSignature(payload, signature, secret) {
  const hash = crypto
    .createHmac('sha256', secret)
    .update(payload)
    .digest('hex');

  return hash === signature;
}
```

---

## SDK とサンプルコード

### JavaScript/Node.js

```javascript
const ApiClient = require('@example/api-client');

const client = new ApiClient({
  apiKey: 'YOUR_API_KEY'
});

// ユーザー取得
const users = await client.users.list({ page: 1, limit: 20 });

// ユーザー作成
const newUser = await client.users.create({
  name: 'John Doe',
  email: 'john@example.com',
  password: 'password123'
});
```

### Python

```python
from example_api import ApiClient

client = ApiClient(api_key='YOUR_API_KEY')

# ユーザー取得
users = client.users.list(page=1, limit=20)

# ユーザー作成
new_user = client.users.create(
    name='John Doe',
    email='john@example.com',
    password='password123'
)
```

### cURL

```bash
# ユーザー一覧取得
curl -X GET https://api.example.com/v1/users \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json"

# ユーザー作成
curl -X POST https://api.example.com/v1/users \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123"
  }'
```

---

## 変更履歴

### v1.0.0 (2025-11-17)
- 初回リリース
- ユーザー管理API
- 認証機能

---

## サポート

質問やフィードバックは以下までお願いします：

- **Email:** api-support@example.com
- **Documentation:** https://docs.example.com/api
- **Status Page:** https://status.example.com
