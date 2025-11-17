# Claude Code CLI 引き継ぎ手順書

*Claude.ai Web → Claude Code CLI への移行ガイド*

## 📥 ステップ1: ファイルのダウンロード

### Claude.ai Webから以下をダウンロード

1. **設計ドキュメント（3ファイル）**
   - smart-review-implementation-plan.md
   - smart-review-subagent-approach.md
   - subagents-vs-skills-comparison.md

2. **プロジェクト設定ファイル**
   - CLAUDE.md

### ダウンロード方法

各ファイルのリンクをクリック：
- [smart-review-implementation-plan.md](computer:///mnt/user-data/outputs/smart-review-implementation-plan.md)
- [smart-review-subagent-approach.md](computer:///mnt/user-data/outputs/smart-review-subagent-approach.md)
- [subagents-vs-skills-comparison.md](computer:///mnt/user-data/outputs/subagents-vs-skills-comparison.md)
- [CLAUDE.md](computer:///mnt/user-data/outputs/CLAUDE.md)

ブラウザの「ダウンロード」ボタンまたは「名前を付けて保存」を使用してください。

## 🏗️ ステップ2: プロジェクト構造の作成

```bash
# プロジェクトディレクトリを作成
mkdir smart-review-system
cd smart-review-system

# 必要なディレクトリ構造を作成
mkdir -p .claude/commands
mkdir -p .claude/skills/smart-review-security
mkdir -p docs
mkdir -p test

# ダウンロードしたファイルを配置
cp ~/Downloads/smart-review-*.md docs/
cp ~/Downloads/subagents-*.md docs/
cp ~/Downloads/CLAUDE.md .claude/
```

## 📝 ステップ3: 初期ファイルの作成

### 3-1. README.md

```bash
cat > README.md << 'EOF'
# Smart Review System

複数の専門Skillsによる包括的コードレビューシステム

## 概要

このプロジェクトは、Claude Skillsを活用した自動コードレビューシステムです。

- **Security Analysis**: セキュリティ脆弱性の検出
- **Debug Analysis**: バグとロジックエラーの検出
- **Quality Analysis**: コード品質の評価
- **Documentation Analysis**: ドキュメント完全性のチェック

## 現在の実装状況

- [ ] Phase 1: Security Skill（進行中）
- [ ] Phase 2: Debug Skill
- [ ] Phase 3: Quality & Documentation Skills
- [ ] Phase 4: 統合テスト & レポート生成

## 使用方法

```bash
# Claude Code を起動
claude

# レビュー実行
> /smart-review
```

## ドキュメント

詳細は `docs/` ディレクトリを参照してください。

- [実装計画](docs/smart-review-implementation-plan.md)
- [アプローチ比較](docs/subagents-vs-skills-comparison.md)
EOF
```

### 3-2. テスト用サンプルファイル

```bash
cat > test/vulnerable-sample.js << 'EOF'
// このファイルは意図的に脆弱性を含むテストサンプルです

// 1. XSS脆弱性 - innerHTML への直接代入
function displayUserInput(userInput) {
    document.getElementById('output').innerHTML = userInput;
}

// 2. SQLインジェクション - 文字列連結
function getUserById(userId) {
    const query = "SELECT * FROM users WHERE id = " + userId;
    return db.execute(query);
}

// 3. コマンドインジェクション - eval使用
function calculateExpression(expression) {
    return eval(expression);
}

// 4. 機密情報の露出 - ハードコードされた認証情報
const config = {
    apiKey: "sk-1234567890abcdef",
    password: "admin123",
    secret: "my-secret-key"
};

// 5. null参照の可能性
function processUser(user) {
    console.log(user.profile.name); // user または profile が null の可能性
}

// 6. 型エラー
function addNumbers(a, b) {
    return a + b; // 数値と文字列が混在する可能性
}
EOF
```

## 🚀 ステップ4: Claude Codeの起動

```bash
# プロジェクトディレクトリで Claude Code を起動
cd smart-review-system
claude
```

## 💬 ステップ5: 引き継ぎの確認

Claude Code起動後、以下を確認：

```
> 現在のプロジェクトについて説明してください
```

**期待される応答例：**
```
このプロジェクトは Smart Review System の実装プロジェクトです。
Claude.ai Web での設計を基に、複数の専門Skillsによる
包括的コードレビューシステムを構築します。

現在は Phase 1（Security Skill の実装）を進めています。
詳細は CLAUDE.md と docs/ ディレクトリを参照してください。
```

## 🎯 ステップ6: 実装の開始

### Phase 1 タスクの確認

```
> Phase 1 で実装するべきタスクをリストアップしてください
```

### Security Skill の実装開始

```
> smart-review-security Skill を実装してください。
> 
> 以下を作成してください：
> 1. .claude/skills/smart-review-security/SKILL.md
> 2. .claude/skills/smart-review-security/patterns.json
> 3. .claude/skills/smart-review-security/cwe-mapping.json
> 
> 仕様は docs/smart-review-implementation-plan.md を参照してください。
```

### オーケストレーターの実装

```
> .claude/commands/smart-review.md を作成してください。
> 
> Security Skill のみを呼び出すシンプルなバージョンで、
> test/vulnerable-sample.js を分析するようにしてください。
```

## ✅ ステップ7: 動作確認

### Skillの認識確認

```bash
# デバッグモードで起動
claude --debug
```

ログで以下を確認：
- smart-review-security Skill が読み込まれているか
- SKILL.md の description が認識されているか

### 実際にレビューを実行

```
> /smart-review
```

**期待される動作：**
1. smart-review-security Skill が起動
2. test/vulnerable-sample.js を分析
3. 6件程度の脆弱性を検出
4. JSON形式で結果を出力
5. 修正推奨を提示

## 🔄 ステップ8: 結果の確認と調整

### 結果が期待通りでない場合

```
> 検出された問題が少なすぎます。
> patterns.json のパターンを見直して、
> より多くの脆弱性を検出できるようにしてください。
```

### JSON出力形式が不正な場合

```
> SKILL.md で出力形式の指示を強化してください。
> 必ず JSON のみを出力し、説明文は後に続けるようにしてください。
```

## 📊 ステップ9: 進捗の記録

実装が完了したら、README.md を更新：

```bash
# Claude Code内で
> README.md の実装状況を更新してください。
> Phase 1 を完了としてマークしてください。
```

## 🎓 ヒント

### Claude Codeの便利な機能

1. **@ファイル参照**
   ```
   > @docs/smart-review-implementation-plan.md の仕様に従って実装してください
   ```

2. **複数ファイルの参照**
   ```
   > @.claude/skills/smart-review-security/SKILL.md と
   > @test/vulnerable-sample.js を確認して、
   > 検出漏れがないか教えてください
   ```

3. **Git統合**
   ```
   > 現在の実装をコミットしてください。
   > コミットメッセージ: "Phase 1: Security Skill 実装完了"
   ```

### よくある問題と解決策

#### 問題1: Skillが認識されない

```bash
# SKILL.md の YAML フロントマターを確認
cat .claude/skills/smart-review-security/SKILL.md | head -5

# 期待される出力:
---
name: "smart-review-security"
description: "セキュリティ脆弱性を検出します..."
---
```

#### 問題2: patterns.json が読み込めない

```
> SKILL.md で patterns.json を読み込む方法を教えてください。
> Code Execution Tool を使う必要がありますか？
```

#### 問題3: 出力が不安定

```
> SKILL.md に以下を追加してください：
> 
> ## 出力ルール（厳守）
> 
> 1. 必ず JSON のみを最初に出力
> 2. JSONは ```json で囲む
> 3. 説明文は JSON の後に記述
```

## 🎉 成功の確認

以下が全て動作すれば Phase 1 完了：

- [x] Security Skill が認識される
- [x] /smart-review コマンドが動作
- [x] test/vulnerable-sample.js を正しく分析
- [x] 6件程度の脆弱性を検出
- [x] JSON形式で結果を出力
- [x] 修正推奨が適切

## 📞 次のアクション

Phase 1 完了後、以下のいずれかを選択：

### Option A: Phase 2へ進む

```
> Phase 2 に進みます。
> smart-review-debug Skill を実装してください。
> 仕様は docs/smart-review-implementation-plan.md を参照してください。
```

### Option B: Phase 1 の改善

```
> Phase 1 をさらに改善します。
> 
> 1. 誤検出を減らすために除外ルールを追加
> 2. 新しい脆弱性パターンを追加
> 3. テストケースを増やす
```

### Option C: 中間レビュー

```
> これまでの実装をレビューしてください。
> 
> 1. コード品質
> 2. ドキュメント完全性
> 3. テストカバレッジ
> 4. 改善提案
```

## 📝 トラブルシューティング

問題が発生した場合は、以下を確認：

1. **CLAUDE.md が正しく配置されているか**
   ```bash
   ls -la .claude/CLAUDE.md
   ```

2. **ディレクトリ構造が正しいか**
   ```bash
   tree .claude/
   ```

3. **ファイルの内容が正しいか**
   ```bash
   head -20 .claude/skills/smart-review-security/SKILL.md
   ```

---

**重要**: この引き継ぎ手順により、Claude.ai Web での設計セッションの成果を
Claude Code CLI で完全に活用できます。

CLAUDE.md と docs/ ディレクトリが、設計意図を伝える重要な役割を果たします。

*作成日: 2025年11月17日*
*対象: Claude.ai Web → Claude Code CLI 移行*
