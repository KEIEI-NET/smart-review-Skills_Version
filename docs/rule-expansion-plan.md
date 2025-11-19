# Smart Review System - ルール拡張実装計画

**ドキュメントバージョン:** 1.0.0
**作成日:** 2025年11月18日 (JST)
**ステータス:** 計画段階（未実装）
**著作権:** (c) 2025 KEIEI.NET INC.
**作成者:** KENJI OYAMA

---

## 📋 目次

- [概要](#概要)
- [現状分析](#現状分析)
- [ルールが少ない理由](#ルールが少ない理由)
- [実装フェーズ](#実装フェーズ)
- [ルール定義方針](#ルール定義方針)
- [具体的なルール例](#具体的なルール例)
- [参照ソース一覧](#参照ソース一覧)
- [実装手順](#実装手順)
- [期待される効果](#期待される効果)
- [その他の拡張提案](#その他の拡張提案)

---

## 概要

Smart Review Systemの現在のルール数は**368+**ですが、TypeScript（1ルール）、C++（6ルール）、Swift（4ルール）のルール数が不足しています。本計画では、これらの言語のルールを大幅に拡張し、言語固有の問題を包括的に検出可能にします。

### 目的

1. **TypeScript**: 型安全性問題を包括的に検出（1 → 31-51ルール）
2. **C++**: メモリ安全性・セキュリティ脆弱性を検出（6 → 46-66ルール）
3. **Swift**: iOS開発での安定性向上（4 → 34-44ルール）
4. **総ルール数**: 368+ → **468-568+ルール**（+100-150ルール）

### 対象読者

- プロジェクト管理者
- ルール作成担当者
- 将来の実装担当者

---

## 現状分析

### 言語別ルール数（v1.1.0時点）

| 言語 | Debug | Quality | Security | 合計 | 状態 |
|------|-------|---------|----------|------|------|
| **JavaScript** | 10 | 5 | 3 | **18** | ✓ 十分 |
| **TypeScript** | - | 1 | - | **1** | ⚠️ 不足 |
| **Python** | 10 | 3 | 3 | **16** | ✓ 十分 |
| **C++** | - | 4 | 2 | **6** | ⚠️ 不足 |
| **C** | - | 6 | - | **6** | ○ 普通 |
| **Swift** | - | 3 | 1 | **4** | ⚠️ 不足 |
| **Go** | 9 | 4 | 3 | **16** | ✓ 十分 |
| **Java** | 10 | 3 | 3 | **16** | ✓ 十分 |
| **C#** | 10 | 4 | 3 | **17** | ✓ 十分 |
| **PHP** | 8 | 3 | 3 | **14** | ✓ 十分 |

**総計:** 368+ ルール
- コアルール（手動定義）: 210+
- BugSearch3統合ルール: 158+

### ルールソースの内訳

#### 手動定義ルール（patterns.json等）

| Skill | ファイル | ルール数 | 特徴 |
|-------|---------|---------|------|
| Security | patterns.json | 60+ | 言語非依存の一般的パターン |
| Debug | common-patterns.json | 70+ | JavaScript/TypeScript中心 |
| Quality | code-smells.json + metrics.json | 50+ | 言語非依存の設計原則 |
| Docs | - | 30+ | ドキュメント完全性チェック |

#### BugSearch3統合ルール

| カテゴリ | ルール数 | ファイル数 |
|---------|---------|-----------|
| Security | 28+ | 22ファイル |
| Debug | 58+ | 7ファイル |
| Quality | 70+ | 37ファイル |

---

## ルールが少ない理由

### TypeScript（1ルールのみ）

**理由:**
1. **BugSearch3の制約**: TypeScript固有のルールが非常に少ない
2. **JavaScriptとの重複**: 多くのパターンがJavaScriptと共通
3. **型システムの複雑性**: 正規表現だけでは検出困難な型問題が多い

**現在のルール:**
- `window/global`への直接代入のみ

**影響:**
- JavaScriptルールが適用されるため、一般的なパターンは検出可能
- しかし、TypeScript固有の**型安全性問題**（型アサーション、型ガード不足など）は検出不可

### C++（6ルールのみ）

**理由:**
1. **BugSearch3のフォーカス**: Web開発に重点、システムプログラミングは後回し
2. **既存ツールの存在**: Clang Static Analyzer、Clang-Tidyなどが強力
3. **言語の複雑性**: メモリ管理、テンプレート、UBなど検出が困難

**現在のルール:**
- Security: バッファオーバーフロー、未初期化変数（2ルール）
- Quality: メモリリーク、RAW pointer、RAII違反、extern変数（4ルール）

**不足している検出:**
- **Use-after-free**: `delete`後のポインタ使用
- **Double-free**: 同一ポインタへの複数`delete`
- **Rule of Three/Five違反**: コピーコンストラクタ/代入演算子の未実装
- **例外安全性**: RAII不使用でのリソース管理

### Swift（4ルールのみ）

**理由:**
1. **BugSearch3の優先度**: モバイル開発の優先度が低い
2. **既存ツールの存在**: SwiftLintが標準的に使用される
3. **言語の新しさ**: ルール蓄積が少ない

**現在のルール:**
- Security: 強制アンラップ（1ルール）
- Quality: Retain cycle、Main thread blocking、命名規則（3ルール）

**不足している検出:**
- **暗黙的アンラップOptional**: `var x: Type!`
- **Unowned参照の誤用**: 長期参照での`[unowned self]`
- **強制try**: `try!`の使用
- **Optional Binding不使用**: `if let`, `guard let`を使わないOptional処理

---

## 実装フェーズ

### フェーズ1: TypeScript拡張【最優先】

**工数:** 3-4日
**追加ルール数:** +30-50ルール（1 → 31-51ルール）
**目標:** TypeScript型安全性問題の包括的検出

#### 1.1 Security Skill拡張

**追加ルール（10-15個）:**

1. **Unsafe Any Type Usage** (TS-SEC-001)
   - パターン: `:\s*any\b`
   - 深刻度: High
   - 説明: `any`型の使用は型安全性を損なう
   - 推奨: 具体的な型または`unknown`を使用

2. **Type Assertion Abuse** (TS-SEC-002)
   - パターン: `as\s+(any|unknown)`
   - 深刻度: High
   - 説明: 型アサーションの濫用は型チェックをバイパス
   - 推奨: 型ガードを使用

3. **Non-Null Assertion Abuse** (TS-SEC-003)
   - パターン: `!\s*[\.\[]`
   - 深刻度: Medium
   - 説明: 非null assertion(`!`)の濫用
   - 推奨: Optional chaining(`?.`)を使用

4. **Unsafe Array Access** (TS-SEC-004)
   - パターン: `\[\d+\](?!\?)`
   - 深刻度: Medium
   - 説明: 配列の範囲外アクセスの可能性
   - 推奨: Optional chaining または範囲チェック

5. **Strict Mode Disabled** (TS-SEC-005)
   - ファイル: `tsconfig.json`
   - パターン: `"strict":\s*false`
   - 深刻度: High
   - 説明: 厳格モードが無効化されている
   - 推奨: `"strict": true`を設定

6. **Type Guard Missing** (TS-SEC-006)
   - パターン: `(typeof|instanceof)\s+\w+\s*===`の不使用
   - 深刻度: Medium
   - 説明: 型ガード不使用でのキャスト
   - 推奨: `typeof`, `instanceof`を使用

7. **Unsafe Object Property Access** (TS-SEC-007)
   - パターン: `\w+\.\w+\.\w+(?!\?)`
   - 深刻度: Low
   - 説明: 深いプロパティアクセスでnull/undefined考慮なし
   - 推奨: Optional chainingを使用

8. **Implicit Any Return** (TS-SEC-008)
   - パターン: `function\s+\w+\s*\([^)]*\)\s*\{`（戻り値型なし）
   - 深刻度: Medium
   - 説明: 関数の戻り値型が暗黙的に`any`
   - 推奨: 明示的な戻り値型を指定

9. **Unsafe Generic Constraints** (TS-SEC-009)
   - パターン: `<\w+>`（制約なしのジェネリック）
   - 深刻度: Low
   - 説明: ジェネリック型パラメータに制約がない
   - 推奨: `extends`で制約を追加

10. **NoUncheckedIndexedAccess Disabled** (TS-SEC-010)
    - ファイル: `tsconfig.json`
    - パターン: `"noUncheckedIndexedAccess":\s*false`
    - 深刻度: Medium
    - 説明: インデックスアクセスのundefinedチェックが無効
    - 推奨: `"noUncheckedIndexedAccess": true`を設定

#### 1.2 Debug Skill拡張

**追加ルール（15-20個）:**

1. **Unhandled Promise** (TS-DBG-001)
   - パターン: `async\s+function.*\(.*\).*(?!await)`
   - 深刻度: High
   - 説明: `async`関数呼び出しで`await`なし
   - 推奨: `await`を使用、またはエラーハンドリング

2. **Promise Float** (TS-DBG-002)
   - パターン: `\.\s*then\s*\(`（末尾に`.catch()`なし）
   - 深刻度: High
   - 説明: Promise chainに`.catch()`がない
   - 推奨: `.catch()`でエラーハンドリング

3. **This Context Loss** (TS-DBG-003)
   - パターン: `this\.\w+\s*\(`（クラスメソッド内）
   - 深刻度: High
   - 説明: クラスメソッドをコールバックとして渡すと`this`喪失
   - 推奨: アロー関数または`.bind(this)`

4. **Async Without Await** (TS-DBG-004)
   - パターン: `async\s+function.*\{[^}]*\}`（`await`なし）
   - 深刻度: Medium
   - 説明: `async`関数内に`await`がない
   - 推奨: `async`を削除、または`await`を追加

5. **Void Return Assignment** (TS-DBG-005)
   - パターン: `const\s+\w+\s*=\s*\w+\s*\(`（戻り値が`void`）
   - 深刻度: Low
   - 説明: `void`を返す関数の戻り値を代入
   - 推奨: 代入を削除

6. **Race Condition in Async** (TS-DBG-006)
   - パターン: 複数の`await`なし`async`呼び出し
   - 深刻度: High
   - 説明: 非同期処理の競合状態
   - 推奨: `Promise.all()`を使用

7. **Unused Promise** (TS-DBG-007)
   - パターン: `^\s*\w+\s*\(`（Promiseを返す関数の呼び出しのみ）
   - 深刻度: Medium
   - 説明: Promiseを返す関数の結果を使用していない
   - 推奨: `await`または`.then()`を使用

8. **Missing Type Annotations** (TS-DBG-008)
   - パターン: `let\s+\w+\s*=`（型注釈なし）
   - 深刻度: Low
   - 説明: 変数の型注釈がない
   - 推奨: 明示的な型注釈を追加

9. **Incorrect Async/Await Usage** (TS-DBG-009)
   - パターン: `await\s+\w+\s*\(`（非async関数内）
   - 深刻度: High
   - 説明: 非`async`関数内で`await`を使用
   - CWE: CWE-691

10. **Type Inference Failure** (TS-DBG-010)
    - パターン: 型が`any`に推論される状況
    - 深刻度: Medium
    - 説明: TypeScriptが型を推論できない
    - 推奨: 明示的な型注釈を追加

#### 1.3 Quality Skill拡張

**追加ルール（10-15個）:**

1. **Enum vs Union Types** (TS-QLT-001)
   - パターン: `enum\s+\w+\s*\{`
   - 深刻度: Low
   - 説明: `enum`の過度な使用
   - 推奨: Union Types + `as const`を検討

2. **Unnecessary Type Assertion** (TS-QLT-002)
   - パターン: `as\s+\w+`（型が明らかな場合）
   - 深刻度: Low
   - 説明: 不要な型アサーション
   - 推奨: 型アサーションを削除

3. **Missing Nullish Coalescing** (TS-QLT-003)
   - パターン: `\|\|\s*`（falsy値の扱い）
   - 深刻度: Low
   - 説明: `||`の使用、`??`推奨
   - 推奨: Nullish coalescing(`??`)を使用

4. **Missing Optional Chaining** (TS-QLT-004)
   - パターン: `\w+\s*&&\s*\w+\.\w+`
   - 深刻度: Low
   - 説明: 条件チェック後のプロパティアクセス
   - 推奨: Optional chaining(`?.`)を使用

5. **Duplicate Type Definitions** (TS-QLT-005)
   - 複数箇所での同一型定義
   - 深刻度: Low
   - 説明: 型定義の重複
   - 推奨: 共通の型ファイルに集約

6. **Missing Readonly Modifiers** (TS-QLT-006)
   - パターン: `interface.*\{[^}]*\w+:\s*\w+`（`readonly`なし）
   - 深刻度: Low
   - 説明: 変更されないプロパティに`readonly`がない
   - 推奨: `readonly`修飾子を追加

7. **Prefer Interface Over Type** (TS-QLT-007)
   - パターン: `type\s+\w+\s*=\s*\{`（オブジェクト型）
   - 深刻度: Low
   - 説明: オブジェクト型に`type`を使用
   - 推奨: `interface`を使用

8. **Missing Generic Constraints** (TS-QLT-008)
   - パターン: `<\w+>`（制約なし）
   - 深刻度: Low
   - 説明: ジェネリック型に制約がない
   - 推奨: `extends`で制約を追加

9. **Type Duplication** (TS-QLT-009)
   - Union/Intersection typeの重複
   - 深刻度: Low
   - 説明: 型定義の重複
   - 推奨: DRY原則に従う

10. **Missing Utility Types** (TS-QLT-010)
    - パターン: 手動での型変換（`Partial`, `Pick`, `Omit`等が使える）
    - 深刻度: Low
    - 説明: TypeScript Utility Typesの未活用
    - 推奨: 組み込みUtility Typesを使用

---

### フェーズ2: C++セキュリティ＆メモリ安全性拡張【高優先度】

**工数:** 5-6日
**追加ルール数:** +40-60ルール（6 → 46-66ルール）
**目標:** C++の致命的脆弱性の包括的検出

#### 2.1 Security Skill拡張

**追加ルール（15-20個）:**

1. **Use After Free** (CPP-SEC-001)
   - パターン: `delete\s+\w+;.*\*?\w+`
   - 深刻度: Critical
   - 説明: `delete`後のポインタ使用（Use-after-free）
   - 推奨: スマートポインタ（`unique_ptr`, `shared_ptr`）を使用
   - CWE: CWE-416

2. **Double Free** (CPP-SEC-002)
   - パターン: `delete\s+\w+;.*delete\s+\w+;`
   - 深刻度: Critical
   - 説明: 同一ポインタへの複数`delete`（Double-free）
   - 推奨: スマートポインタを使用、または`nullptr`チェック
   - CWE: CWE-415

3. **Integer Overflow** (CPP-SEC-003)
   - パターン: `int\s+\w+\s*=.*\+.*\+`（整数演算）
   - 深刻度: High
   - 説明: 符号付き整数オーバーフロー（Undefined Behavior）
   - 推奨: `<limits>`でチェック、または安全な型を使用
   - CWE: CWE-190

4. **Format String Vulnerability** (CPP-SEC-004)
   - パターン: `printf\s*\([^"]*\w+`
   - 深刻度: Critical
   - 説明: Format string vulnerabilityの可能性
   - 推奨: `std::format`（C++20）または`std::cout`を使用
   - CWE: CWE-134

5. **Null Pointer Dereference** (CPP-SEC-005)
   - パターン: `\*\w+`（nullチェックなし）
   - 深刻度: High
   - 説明: nullポインタのデリファレンス
   - 推奨: nullチェックを追加
   - CWE: CWE-476

6. **Array Bounds Violation** (CPP-SEC-006)
   - パターン: `\w+\[\d+\]`（範囲チェックなし）
   - 深刻度: Critical
   - 説明: 配列の範囲外アクセス（Undefined Behavior）
   - 推奨: `std::array`、`std::vector`、またはat()を使用
   - CWE: CWE-119

7. **Unsafe String Functions** (CPP-SEC-007)
   - パターン: `strcpy|strcat|gets|sprintf`
   - 深刻度: Critical
   - 説明: 安全でない文字列関数の使用
   - 推奨: `strncpy`, `strncat`, `fgets`, `snprintf`を使用
   - CWE: CWE-120
   - **既存対応あり**（強化版）

8. **Uninitialized Variable** (CPP-SEC-008)
   - パターン: `int\s+\w+;`（初期化なし）
   - 深刻度: High
   - 説明: 未初期化変数の使用（Undefined Behavior）
   - 推奨: 宣言時に初期化
   - CWE: CWE-457
   - **既存対応あり**（強化版）

9. **Dangling Pointer** (CPP-SEC-009)
   - パターン: ローカル変数のアドレスを返す
   - 深刻度: Critical
   - 説明: ダングリングポインタの生成
   - 推奨: スタック変数のアドレスを返さない

10. **Type Confusion** (CPP-SEC-010)
    - パターン: `reinterpret_cast`の使用
    - 深刻度: High
    - 説明: 型の混乱（Type Confusion）
    - 推奨: `static_cast`, `dynamic_cast`を使用
    - CWE: CWE-843

11. **Signed-Unsigned Comparison** (CPP-SEC-011)
    - パターン: `(signed|int)\s+\w+.*<.*unsigned`
    - 深刻度: Medium
    - 説明: 符号付き・符号なし比較の危険性
    - 推奨: 同じ符号性の型を使用

12. **Time-of-Check Time-of-Use (TOCTOU)** (CPP-SEC-012)
    - パターン: ファイルチェック後の操作
    - 深刻度: High
    - 説明: TOCTOU脆弱性
    - 推奨: アトミック操作を使用
    - CWE: CWE-367

#### 2.2 Debug Skill新規追加

**追加ルール（20-25個）:**

1. **Rule of Three Violation** (CPP-DBG-001)
   - パターン: ポインタメンバ保持クラスでコピーコンストラクタ未実装
   - 深刻度: High
   - 説明: Rule of Threeの違反
   - 推奨: コピーコンストラクタ、代入演算子、デストラクタを実装

2. **Rule of Five Violation** (CPP-DBG-002)
   - パターン: ムーブコンストラクタ、ムーブ代入演算子の未実装
   - 深刻度: Medium
   - 説明: Rule of Fiveの違反
   - 推奨: ムーブセマンティクスを実装

3. **Exception Safety Violation** (CPP-DBG-003)
   - パターン: 例外スロー可能な関数でのリソース管理
   - 深刻度: Medium
   - 説明: 例外安全性の欠如
   - 推奨: RAIIを使用

4. **Implicit Type Conversion** (CPP-DBG-004)
   - パターン: `int`⇔`bool`、ポインタ⇔`bool`
   - 深刻度: Medium
   - 説明: 暗黙的型変換の危険性
   - 推奨: 明示的変換を使用

5. **Slicing Problem** (CPP-DBG-005)
   - パターン: 派生クラスの値渡し
   - 深刻度: Medium
   - 説明: スライシング問題
   - 推奨: ポインタ、参照、またはスマートポインタを使用

6. **Missing Virtual Destructor** (CPP-DBG-006)
   - パターン: 仮想関数を持つクラスで仮想デストラクタなし
   - 深刻度: High
   - 説明: 仮想デストラクタの欠如
   - 推奨: `virtual ~ClassName()`を追加

7. **Copy Elision Assumption** (CPP-DBG-007)
   - パターン: RVO/NRVOへの過度な依存
   - 深刻度: Low
   - 説明: コピー省略の仮定
   - 推奨: ムーブセマンティクスを明示

8. **Undefined Behavior** (CPP-DBG-008)
   - 複数のパターン（UB全般）
   - 深刻度: Critical
   - 説明: 未定義動作
   - 推奨: 言語仕様に準拠

9. **Memory Leak** (CPP-DBG-009)
   - パターン: `new`後に`delete`なし
   - 深刻度: High
   - 説明: メモリリーク
   - 推奨: スマートポインタを使用
   - **既存対応あり**（強化版）

10. **Resource Leak** (CPP-DBG-010)
    - パターン: `fopen`, `malloc`の直接使用
    - 深刻度: High
    - 説明: リソースリーク
    - 推奨: RAII、スマートポインタを使用
    - **既存対応あり**（強化版）

#### 2.3 Quality Skill拡張

**追加ルール（15-20個）:**

1. **Prefer Auto** (CPP-QLT-001)
   - パターン: 明らかな型での冗長な型指定
   - 深刻度: Low
   - 説明: `auto`を使用すべき場面
   - 推奨: `auto`を使用

2. **Prefer Range-Based For** (CPP-QLT-002)
   - パターン: インデックスベースのforループ
   - 深刻度: Low
   - 説明: 範囲for推奨
   - 推奨: `for (auto& item : container)`を使用

3. **Prefer nullptr** (CPP-QLT-003)
   - パターン: `NULL`, `0`のポインタとしての使用
   - 深刻度: Low
   - 説明: `nullptr`推奨
   - 推奨: `nullptr`を使用

4. **Unnecessary Copy** (CPP-QLT-004)
   - パターン: 値渡しでのコピー
   - 深刻度: Medium
   - 説明: 不要なコピー
   - 推奨: `const&`または`&&`（ムーブ）を使用

5. **Missing Move Semantic** (CPP-QLT-005)
   - パターン: ムーブ可能な場面でコピー
   - 深刻度: Medium
   - 説明: ムーブセマンティクスの未活用
   - 推奨: `std::move()`を使用

6. **C-Style Cast** (CPP-QLT-006)
   - パターン: `(type)`形式のキャスト
   - 深刻度: Medium
   - 説明: C形式キャスト
   - 推奨: `static_cast`, `dynamic_cast`等を使用

7. **Missing const** (CPP-QLT-007)
   - パターン: 変更されない変数・メンバ関数
   - 深刻度: Low
   - 説明: `const`修飾子の欠如
   - 推奨: `const`を追加

8. **Global Variable** (CPP-QLT-008)
   - パターン: グローバル変数の使用
   - 深刻度: Medium
   - 説明: グローバル変数の危険性
   - 推奨: クラスのstaticメンバ、または名前空間を使用

9. **Magic Number** (CPP-QLT-009)
   - パターン: コード内のマジックナンバー
   - 深刻度: Low
   - 説明: マジックナンバー
   - 推奨: 名前付き定数を使用

10. **Deep Inheritance** (CPP-QLT-010)
    - パターン: 3階層以上の継承
    - 深刻度: Medium
    - 説明: 深い継承階層
    - 推奨: コンポジションを検討

---

### フェーズ3: Swift拡張【中優先度】

**工数:** 3-4日
**追加ルール数:** +30-40ルール（4 → 34-44ルール）
**目標:** iOS開発での安定性向上

#### 3.1 Security Skill拡張

**追加ルール（10-12個）:**

1. **Force Unwrapping** (SWIFT-SEC-001)
   - パターン: `!`（強制アンラップ）
   - 深刻度: High
   - 説明: 強制アンラップはクラッシュの原因
   - 推奨: Optional Binding（`if let`, `guard let`）を使用
   - **既存対応あり**（強化版）

2. **Implicitly Unwrapped Optional** (SWIFT-SEC-002)
   - パターン: `var\s+\w+:\s*\w+!`
   - 深刻度: Medium
   - 説明: 暗黙的アンラップOptionalの危険性
   - 推奨: 通常のOptional（`?`）を使用

3. **Unowned Reference Misuse** (SWIFT-SEC-003)
   - パターン: `[unowned self]`（長期参照）
   - 深刻度: High
   - 説明: `unowned`の誤用（アクセス時にクラッシュ）
   - 推奨: `weak`を使用、またはライフサイクルを確認

4. **Force Try** (SWIFT-SEC-004)
   - パターン: `try!`
   - 深刻度: Medium
   - 説明: 強制tryはクラッシュの原因
   - 推奨: `do-catch`、または`try?`を使用

5. **Force Cast** (SWIFT-SEC-005)
   - パターン: `as!`
   - 深刻度: High
   - 説明: 強制キャストはクラッシュの原因
   - 推奨: `as?`（Optional cast）を使用

6. **Unsafe Pointer Usage** (SWIFT-SEC-006)
   - パターン: `UnsafePointer`, `UnsafeMutablePointer`
   - 深刻度: High
   - 説明: 安全でないポインタの使用
   - 推奨: Swiftのメモリ安全機能を使用

7. **@objc Dynamic Dispatch** (SWIFT-SEC-007)
   - パターン: `@objc dynamic`の過度な使用
   - 深刻度: Low
   - 説明: 動的ディスパッチによる型安全性の低下
   - 推奨: Swiftネイティブの機能を使用

8. **Missing Optional Binding** (SWIFT-SEC-008)
   - パターン: Optional値の直接使用
   - 深刻度: Medium
   - 説明: Optional Bindingの不使用
   - 推奨: `if let`, `guard let`を使用

9. **Failable Initializer Abuse** (SWIFT-SEC-009)
   - パターン: `init?()`の過度な使用
   - 深刻度: Low
   - 説明: 失敗可能イニシャライザの濫用
   - 推奨: `throws`を検討

10. **NSAttributedString Injection** (SWIFT-SEC-010)
    - パターン: ユーザー入力からの`NSAttributedString`生成
    - 深刻度: High
    - 説明: HTMLインジェクションの可能性
    - 推奨: サニタイゼーションを実装
    - CWE: CWE-79

#### 3.2 Debug Skill新規追加

**追加ルール（12-15個）:**

1. **Retain Cycle** (SWIFT-DBG-001)
   - パターン: クロージャ内での`self`強参照
   - 深刻度: High
   - 説明: Retain cycle（循環参照）の可能性
   - 推奨: `[weak self]`または`[unowned self]`を使用
   - **既存対応あり**（強化版）

2. **Main Thread Blocking** (SWIFT-DBG-002)
   - パターン: `DispatchQueue.main`内での重い処理
   - 深刻度: High
   - 説明: Main threadブロッキング
   - 推奨: バックグラウンドキューで処理
   - **既存対応あり**（強化版）

3. **Async/Await Misuse** (SWIFT-DBG-003)
   - パターン: `async`関数で`await`なし
   - 深刻度: Medium
   - 説明: `async`関数の誤用
   - 推奨: `await`を使用

4. **Task Detached Overuse** (SWIFT-DBG-004)
   - パターン: `Task.detached`の過度な使用
   - 深刻度: Medium
   - 説明: タスクの分離による追跡困難
   - 推奨: 構造化並行性を使用

5. **Actor Isolation Violation** (SWIFT-DBG-005)
   - パターン: Actor外からの直接アクセス
   - 深刻度: High
   - 説明: Actorの分離違反
   - 推奨: `await`を使用

6. **Optional Chaining Overuse** (SWIFT-DBG-006)
   - パターン: 深いOptional chaining
   - 深刻度: Low
   - 説明: 可読性の低下
   - 推奨: 中間変数を使用

7. **Unused Closure Parameter** (SWIFT-DBG-007)
   - パターン: 未使用のクロージャパラメータ
   - 深刻度: Low
   - 説明: 未使用パラメータ
   - 推奨: `_`で明示

8. **Missing Error Handling** (SWIFT-DBG-008)
   - パターン: `try?`の過度な使用（エラー無視）
   - 深刻度: Medium
   - 説明: エラーハンドリングの欠如
   - 推奨: `do-catch`で適切に処理

9. **SwiftUI State Management Issue** (SWIFT-DBG-009)
   - パターン: `@State`の誤用
   - 深刻度: Medium
   - 説明: SwiftUI状態管理の誤用
   - 推奨: `@StateObject`, `@ObservedObject`を適切に使用

10. **Combine Memory Leak** (SWIFT-DBG-010)
    - パターン: `sink`のストレージ忘れ
    - 深刻度: High
    - 説明: Combineのメモリリーク
    - 推奨: `AnyCancellable`を保持

#### 3.3 Quality Skill拡張

**追加ルール（10-13個）:**

1. **Struct vs Class Misuse** (SWIFT-QLT-001)
   - パターン: 大きなStructの値渡し
   - 深刻度: Medium
   - 説明: 大きなStructのコピーコスト
   - 推奨: Classまたは参照渡しを検討

2. **Redundant Nil Initialization** (SWIFT-QLT-002)
   - パターン: `var x: Type? = nil`
   - 深刻度: Low
   - 説明: 冗長なnil初期化
   - 推奨: `var x: Type?`のみで十分

3. **Empty Count** (SWIFT-QLT-003)
   - パターン: `count == 0`
   - 深刻度: Low
   - 説明: `isEmpty`推奨
   - 推奨: `isEmpty`を使用

4. **Closure Parameter Position** (SWIFT-QLT-004)
   - パターン: 末尾以外のクロージャパラメータ
   - 深刻度: Low
   - 説明: クロージャは末尾推奨
   - 推奨: Trailing closureを使用

5. **Missing Protocol Conformance** (SWIFT-QLT-005)
   - パターン: プロトコル指向プログラミングの未活用
   - 深刻度: Low
   - 説明: 継承の過度な使用
   - 推奨: Protocol-oriented programmingを活用

6. **Magic Number** (SWIFT-QLT-006)
   - パターン: コード内のマジックナンバー
   - 深刻度: Low
   - 説明: マジックナンバー
   - 推奨: 名前付き定数を使用
   - **既存対応あり**（強化版）

7. **Excessive Force Unwrapping** (SWIFT-QLT-007)
   - パターン: 連続した`!`
   - 深刻度: Medium
   - 説明: 強制アンラップの連続使用
   - 推奨: Optional chainingまたはBindingを使用

8. **Large View Struct** (SWIFT-QLT-008)
   - パターン: SwiftUIのView構造体が大きすぎる
   - 深刻度: Medium
   - 説明: Viewの肥大化
   - 推奨: サブビューに分割

9. **Missing Equatable** (SWIFT-QLT-009)
   - パターン: 比較が必要な型で`Equatable`未実装
   - 深刻度: Low
   - 説明: `Equatable`の未実装
   - 推奨: `Equatable`プロトコルを実装

10. **Overuse of Inheritance** (SWIFT-QLT-010)
    - パターン: 深い継承階層
    - 深刻度: Medium
    - 説明: 継承の過度な使用
    - 推奨: プロトコルとコンポジションを使用

---

## ルール定義方針

### ハイブリッドアプローチ（推奨）

参照ソース（ESLint、Clang-Tidy、SwiftLint）をベースにしつつ、Smart Review System独自の改良を加える方針。

#### 1. 参照ソースからの移植

**利点:**
- 実績のあるルールセット
- コミュニティで検証済み
- ドキュメント豊富

**手順:**
1. 参照ソースのルールリストを確認
2. Smart Review Systemに適したルールを選定
3. 正規表現パターンに変換
4. CWEマッピングを追加

#### 2. 独自の改良

**改良ポイント:**

1. **深刻度の細分化**
   - 参照ソース: `error`, `warning`, `info`
   - Smart Review: `critical`, `high`, `medium`, `low`

2. **CWE/OWASPマッピング**
   - セキュリティルールに必須
   - 既存ツールにはない付加価値

3. **推奨修正の具体化**
   - 参照ソース: 「使用しないでください」
   - Smart Review: 「`std::unique_ptr`を使用してください」

4. **コンテキストの考慮**
   - 単純な正規表現マッチングではなく、コンテキストを考慮
   - 例: `any`型の使用（テストコードでは許容）

5. **言語横断的なルール統合**
   - 複数言語で共通の問題パターンを統一的に定義
   - 例: Magic Number、Deep Inheritance

#### 3. ルールファイル構造

```json
{
  "language": "typescript|cpp|swift",
  "category": "security|debug|quality",
  "rules": [
    {
      "id": "LANG-CAT-NNN",
      "name": "Rule Name",
      "severity": "critical|high|medium|low",
      "pattern": "regex pattern",
      "description": "問題の説明",
      "recommendation": "具体的な修正推奨",
      "cwe": "CWE-XXX",
      "owasp": "A01:2021",
      "tags": ["tag1", "tag2"],
      "autoFixable": true|false,
      "referenceSource": "eslint:rule-name",
      "examples": {
        "bad": "悪い例のコード",
        "good": "良い例のコード"
      }
    }
  ]
}
```

#### 4. ルール品質基準

**必須項目:**
- `id`: 一意の識別子
- `name`: ルール名（英語）
- `severity`: 深刻度
- `pattern`: 検出パターン（正規表現）
- `description`: 問題の説明
- `recommendation`: 修正推奨

**推奨項目:**
- `cwe`: CWE番号（セキュリティルール）
- `owasp`: OWASP Top 10分類（セキュリティルール）
- `tags`: タグ（検索性向上）
- `referenceSource`: 参照元（トレーサビリティ）
- `examples`: コード例（理解促進）

**オプション項目:**
- `autoFixable`: 自動修正可能性
- `excludePatterns`: 除外パターン（false positive削減）
- `relatedRules`: 関連ルール

---

## 具体的なルール例

### TypeScript: Unsafe Any Type Usage

**参照元:** ESLint `@typescript-eslint/no-explicit-any`

**Smart Review版:**

```json
{
  "id": "TS-SEC-001",
  "name": "Unsafe Any Type Usage",
  "severity": "high",
  "pattern": ":\\s*any\\b",
  "description": "any型の使用は型安全性を損ないます。any型はTypeScriptの型チェックをバイパスし、ランタイムエラーの原因となります。",
  "recommendation": "具体的な型、またはunknown型を使用してください。unknown型は型ガードを強制するため、より安全です。",
  "cwe": "CWE-20",
  "tags": ["typescript", "type-safety", "any"],
  "autoFixable": false,
  "referenceSource": "eslint:@typescript-eslint/no-explicit-any",
  "examples": {
    "bad": "function processData(data: any) { return data.value; }",
    "good": "function processData(data: unknown) { if (typeof data === 'object' && data !== null && 'value' in data) { return data.value; } }"
  },
  "excludePatterns": [
    "test/.*\\.spec\\.ts$",
    ".*\\.test\\.ts$"
  ]
}
```

**改良点:**
1. CWEマッピング追加（CWE-20: Improper Input Validation）
2. 詳細な説明（なぜ危険か）
3. 具体的な推奨（`unknown`型の提案）
4. コード例の追加
5. テストファイルの除外

---

### C++: Use After Free

**参照元:** Clang-Tidy `bugprone-use-after-move`

**Smart Review版:**

```json
{
  "id": "CPP-SEC-001",
  "name": "Use After Free",
  "severity": "critical",
  "pattern": "delete\\s+(\\w+);[^}]{0,200}\\*?\\1\\b",
  "description": "delete後のポインタ使用（Use-after-free）は、解放済みメモリへのアクセスを引き起こし、クラッシュやセキュリティ脆弱性の原因となります。",
  "recommendation": "スマートポインタ（std::unique_ptr、std::shared_ptr）を使用してください。スマートポインタはスコープを抜けた時点で自動的にメモリを解放し、Use-after-freeを防ぎます。",
  "cwe": "CWE-416",
  "owasp": "A01:2021",
  "tags": ["cpp", "memory-safety", "use-after-free"],
  "autoFixable": false,
  "referenceSource": "clang-tidy:bugprone-use-after-move",
  "examples": {
    "bad": "int* ptr = new int(10); delete ptr; int value = *ptr;",
    "good": "auto ptr = std::make_unique<int>(10); int value = *ptr; // ptrはスコープを抜けると自動解放"
  }
}
```

**改良点:**
1. CWEとOWASPマッピング追加
2. より具体的なパターン（変数名の一致をキャプチャ）
3. スマートポインタの具体的な使用例
4. セキュリティ影響の明記

---

### Swift: Force Unwrapping

**参照元:** SwiftLint `force_unwrapping`

**Smart Review版:**

```json
{
  "id": "SWIFT-SEC-001",
  "name": "Force Unwrapping",
  "severity": "high",
  "pattern": "!(?=\\s*[.\\[])",
  "description": "強制アンラップ（!）は、Optional値がnilの場合にクラッシュを引き起こします。プロダクションコードでの使用は避けるべきです。",
  "recommendation": "Optional Binding（if let、guard let）またはOptional chaining（?.）を使用してください。これにより、nil時の安全な処理が可能になります。",
  "tags": ["swift", "optional", "force-unwrap", "crash"],
  "autoFixable": false,
  "referenceSource": "swiftlint:force_unwrapping",
  "examples": {
    "bad": "let name = user.name!",
    "good": "if let name = user.name { print(name) } または let name = user.name ?? \"Unknown\""
  },
  "excludePatterns": [
    "Tests/.*\\.swift$"
  ]
}
```

**改良点:**
1. より精確なパターン（後続の`.`または`[`を確認）
2. nil時の安全な処理方法の提案
3. テストコードの除外

---

## 参照ソース一覧

### TypeScript

#### ESLint TypeScript Plugin

**URL:** https://typescript-eslint.io/rules/

**参照ルール（30-50個を選定）:**

| カテゴリ | ルール | Smart Review ID | 優先度 |
|---------|-------|----------------|-------|
| Type Safety | `no-explicit-any` | TS-SEC-001 | 高 |
| Type Safety | `no-unsafe-assignment` | TS-SEC-002 | 高 |
| Type Safety | `no-unsafe-call` | TS-SEC-003 | 高 |
| Type Safety | `no-unsafe-member-access` | TS-SEC-004 | 高 |
| Type Safety | `no-unsafe-return` | TS-SEC-005 | 高 |
| Type Safety | `strict-boolean-expressions` | TS-SEC-006 | 中 |
| Async | `no-floating-promises` | TS-DBG-001 | 高 |
| Async | `no-misused-promises` | TS-DBG-002 | 高 |
| Async | `await-thenable` | TS-DBG-003 | 中 |
| Async | `require-await` | TS-DBG-004 | 低 |
| Type Assertion | `no-unnecessary-type-assertion` | TS-QLT-002 | 低 |
| Best Practices | `prefer-nullish-coalescing` | TS-QLT-003 | 低 |
| Best Practices | `prefer-optional-chain` | TS-QLT-004 | 低 |
| Best Practices | `prefer-readonly` | TS-QLT-006 | 低 |

**選定基準:**
- 型安全性に関連するルール: 最優先
- 非同期処理の問題: 高優先度
- コード品質改善: 中優先度

---

### C++

#### Clang-Tidy

**URL:** https://clang.llvm.org/extra/clang-tidy/checks/list.html

**参照ルール（50-80個を選定）:**

| カテゴリ | ルール | Smart Review ID | 優先度 |
|---------|-------|----------------|-------|
| bugprone | `bugprone-use-after-move` | CPP-SEC-001 | Critical |
| bugprone | `bugprone-dangling-handle` | CPP-SEC-009 | Critical |
| bugprone | `bugprone-infinite-loop` | CPP-DBG-011 | 高 |
| bugprone | `bugprone-suspicious-memset-usage` | CPP-SEC-012 | 高 |
| cert | `cert-err34-c` | CPP-SEC-004 | 高 |
| cert | `cert-err58-cpp` | CPP-DBG-012 | 中 |
| cppcoreguidelines | `cppcoreguidelines-owning-memory` | CPP-QLT-011 | 高 |
| cppcoreguidelines | `cppcoreguidelines-pro-type-reinterpret-cast` | CPP-SEC-010 | 高 |
| cppcoreguidelines | `cppcoreguidelines-pro-bounds-array-to-pointer-decay` | CPP-SEC-006 | 中 |
| modernize | `modernize-use-auto` | CPP-QLT-001 | 低 |
| modernize | `modernize-use-nullptr` | CPP-QLT-003 | 低 |
| modernize | `modernize-loop-convert` | CPP-QLT-002 | 低 |
| performance | `performance-unnecessary-copy-initialization` | CPP-QLT-004 | 中 |
| performance | `performance-move-const-arg` | CPP-QLT-005 | 中 |

**選定基準:**
- `bugprone-*`: 最優先（バグ・脆弱性）
- `cert-*`: 高優先度（CERT C/C++ Coding Standards）
- `cppcoreguidelines-*`: 高優先度（C++ Core Guidelines）
- `modernize-*`: 中優先度（モダンC++）
- `performance-*`: 中優先度（パフォーマンス）

---

### Swift

#### SwiftLint

**URL:** https://realm.github.io/SwiftLint/rule-directory.html

**参照ルール（40-60個を選定）:**

| カテゴリ | ルール | Smart Review ID | 優先度 |
|---------|-------|----------------|-------|
| Idiomatic | `force_unwrapping` | SWIFT-SEC-001 | 高 |
| Idiomatic | `force_cast` | SWIFT-SEC-005 | 高 |
| Idiomatic | `force_try` | SWIFT-SEC-004 | 中 |
| Idiomatic | `implicitly_unwrapped_optional` | SWIFT-SEC-002 | 中 |
| Lint | `unused_closure_parameter` | SWIFT-DBG-007 | 低 |
| Lint | `weak_delegate` | SWIFT-QLT-012 | 高 |
| Performance | `empty_count` | SWIFT-QLT-003 | 低 |
| Performance | `contains_over_first_not_nil` | SWIFT-QLT-013 | 低 |
| Style | `closure_parameter_position` | SWIFT-QLT-004 | 低 |
| Style | `redundant_optional_initialization` | SWIFT-QLT-002 | 低 |

**選定基準:**
- `force_*`: 最優先（クラッシュ原因）
- `weak_delegate`: 高優先度（メモリリーク）
- `implicitly_unwrapped_optional`: 中優先度
- パフォーマンス、スタイル: 低優先度

---

## 実装手順

### ステップ1: 参照ソースの調査（1日）

#### 1.1 ESLint TypeScript Plugin

```bash
# ルールリストを取得
curl https://typescript-eslint.io/rules/ > eslint-ts-rules.html

# 重要なルールを抽出（手動）
# - Type Safety（最優先）
# - Async/Await（高優先度）
# - Best Practices（中優先度）
```

#### 1.2 Clang-Tidy

```bash
# ルールリストを取得
curl https://clang.llvm.org/extra/clang-tidy/checks/list.html > clang-tidy-rules.html

# 重要なカテゴリ:
# - bugprone-*
# - cert-*
# - cppcoreguidelines-*
# - modernize-*
# - performance-*
```

#### 1.3 SwiftLint

```bash
# ルールリストを取得
curl https://realm.github.io/SwiftLint/rule-directory.html > swiftlint-rules.html

# 重要なカテゴリ:
# - Idiomatic（force_*, implicitly_unwrapped_optional）
# - Lint（weak_delegate）
# - Performance
```

---

### ステップ2: ルール選定とマッピング（1-2日）

#### 2.1 選定基準

**優先度1（Critical/High）:**
- セキュリティ脆弱性に直結
- クラッシュの原因
- データ破損の可能性

**優先度2（Medium）:**
- バグの可能性
- パフォーマンス問題
- 保守性の低下

**優先度3（Low）:**
- コードスタイル
- ベストプラクティス

#### 2.2 マッピング表作成

**フォーマット:**

| 参照ソース | ルール名 | Smart Review ID | カテゴリ | 深刻度 | 実装難易度 |
|-----------|---------|----------------|---------|--------|-----------|
| ESLint | no-explicit-any | TS-SEC-001 | Security | High | 簡単 |
| Clang-Tidy | bugprone-use-after-move | CPP-SEC-001 | Security | Critical | 中 |
| SwiftLint | force_unwrapping | SWIFT-SEC-001 | Security | High | 簡単 |

---

### ステップ3: 正規表現パターンの作成（2-3日）

#### 3.1 パターン作成の原則

**1. シンプルさ優先**
```regex
# 悪い例（複雑すぎ）
(?<!const\s+)(?<!let\s+)var\s+(\w+):\s*any\b(?!\s*=\s*\w+\s*as\s+any)

# 良い例（シンプル）
:\s*any\b
```

**2. False Positive削減**
```regex
# 改良前（too many false positives）
delete\s+\w+;

# 改良後（変数名一致チェック）
delete\s+(\\w+);[^}]{0,200}\\*?\\1\\b
```

**3. パフォーマンス考慮**
```regex
# 悪い例（バックトラッキング多）
.*delete.*

# 良い例（明示的な範囲制限）
[^}]{0,200}
```

#### 3.2 パターンテスト

**テストケース作成:**

```javascript
// TypeScript: TS-SEC-001テスト

// Should match:
function test1(data: any) {}
const value: any = getData();

// Should NOT match:
function test2(data: unknown) {}
const value: string = getData();
```

**検証ツール:**
- https://regex101.com/
- VS Code正規表現検索

---

### ステップ4: JSONファイル作成（2-3日）

#### 4.1 ファイル構造

```
.claude/skills/
├── smart-review-security/
│   ├── bugsearch3-typescript-extended.json  # 新規
│   ├── bugsearch3-cpp-extended.json         # 新規
│   └── bugsearch3-swift-extended.json       # 新規
├── smart-review-debug/
│   ├── bugsearch3-typescript-extended.json  # 新規
│   ├── bugsearch3-cpp-extended.json         # 新規
│   └── bugsearch3-swift-extended.json       # 新規
└── smart-review-quality/
    ├── bugsearch3-typescript-extended.json  # 新規
    ├── bugsearch3-cpp-extended.json         # 新規（拡張）
    └── bugsearch3-swift-extended.json       # 新規（拡張）
```

#### 4.2 ファイル作成手順

**1. テンプレートファイルを作成:**

```json
{
  "language": "typescript",
  "category": "security",
  "version": "1.2.0",
  "source": "ESLint TypeScript Plugin",
  "rules": []
}
```

**2. ルールを追加:**

各ルールを以下の形式で追加:

```json
{
  "id": "TS-SEC-001",
  "name": "Unsafe Any Type Usage",
  "severity": "high",
  "pattern": ":\\s*any\\b",
  "description": "...",
  "recommendation": "...",
  "cwe": "CWE-20",
  "tags": ["typescript", "type-safety"],
  "referenceSource": "eslint:@typescript-eslint/no-explicit-any",
  "examples": {
    "bad": "...",
    "good": "..."
  }
}
```

**3. JSON構文検証:**

```bash
# PowerShell
Get-Content file.json | ConvertFrom-Json

# Bash
cat file.json | jq .
```

---

### ステップ5: ドキュメント作成（1-2日）

#### 5.1 ルール詳細ドキュメント

**ファイル:**
- `docs/rules/typescript-rules.md`
- `docs/rules/cpp-rules.md`
- `docs/rules/swift-rules.md`

**内容:**
- 各ルールの詳細説明
- コード例（悪い例・良い例）
- 参照元リンク
- CWE/OWASPマッピング

#### 5.2 CHANGELOG更新

```markdown
## [1.2.0] - 2025-XX-XX

### Added
- TypeScript拡張: 30-50ルール追加
  - Security: 10-15ルール
  - Debug: 15-20ルール
  - Quality: 10-15ルール
- C++拡張: 40-60ルール追加
  - Security: 15-20ルール（Use-after-free、Double-free等）
  - Debug: 20-25ルール（Rule of Three/Five等）
  - Quality: 15-20ルール（モダンC++推奨等）
- Swift拡張: 30-40ルール追加
  - Security: 10-12ルール（強制アンラップ等）
  - Debug: 12-15ルール（Retain cycle等）
  - Quality: 10-13ルール（Struct vs Class等）

### Changed
- 総ルール数: 368+ → 468-568+
```

#### 5.3 README更新

言語別ルール数表を更新:

```markdown
| 言語 | Debug | Quality | Security | 合計 |
|------|-------|---------|----------|------|
| TypeScript | 15-20 | 10-15 | 10-15 | **35-50** ⬆️ |
| C++ | 20-25 | 19-24 | 17-22 | **56-71** ⬆️ |
| Swift | 12-15 | 13-16 | 11-13 | **36-44** ⬆️ |
```

---

### ステップ6: テスト・検証（1-2日）

#### 6.1 テストサンプル作成

**TypeScript:**
```typescript
// test/typescript-sample.ts

// TS-SEC-001: Unsafe Any Type Usage
function processData(data: any) {  // Should detect
  return data.value;
}

// TS-DBG-001: Unhandled Promise
async function fetchData() {
  const promise = fetch('/api/data');  // Should detect
}

// TS-QLT-003: Missing Nullish Coalescing
const value = data || 'default';  // Should suggest ??
```

**C++:**
```cpp
// test/cpp-sample.cpp

// CPP-SEC-001: Use After Free
void example1() {
  int* ptr = new int(10);
  delete ptr;
  int value = *ptr;  // Should detect
}

// CPP-DBG-001: Rule of Three Violation
class MyClass {
  int* data;
public:
  MyClass() : data(new int(0)) {}
  ~MyClass() { delete data; }
  // Missing copy constructor and assignment operator
};

// CPP-QLT-001: Prefer Auto
std::vector<int> vec = getVector();  // Should suggest auto
```

**Swift:**
```swift
// test/swift-sample.swift

// SWIFT-SEC-001: Force Unwrapping
let name = user.name!  // Should detect

// SWIFT-DBG-001: Retain Cycle
class MyClass {
  var closure: (() -> Void)?
  func setup() {
    closure = {
      self.doSomething()  // Should detect
    }
  }
}

// SWIFT-QLT-003: Empty Count
if array.count == 0 {  // Should suggest isEmpty
  print("Empty")
}
```

#### 6.2 検証手順

```bash
# 1. Claude Codeでテストサンプルをレビュー
claude

> test/typescript-sample.ts をセキュリティ分析してください
> test/cpp-sample.cpp をデバッグ分析してください
> test/swift-sample.swift を品質分析してください

# 2. 期待される検出数を確認
# - TypeScript: 各ファイルあたり3件以上
# - C++: 各ファイルあたり3件以上
# - Swift: 各ファイルあたり3件以上

# 3. False Positiveチェック
# - 正常なコードが誤検出されていないか確認
```

---

### ステップ7: リリース準備（1日）

#### 7.1 バージョニング

**現在:** v1.1.0
**次期:** v1.2.0

**Semantic Versioning:**
- MAJOR: 破壊的変更
- MINOR: 後方互換性のある機能追加 ← **今回**
- PATCH: バグ修正

#### 7.2 リリースノート作成

```markdown
# Smart Review System v1.2.0

## 概要

TypeScript、C++、Swiftのルールを大幅に拡張し、総ルール数を368+から468-568+に増加しました。

## 主な変更

### TypeScript拡張（+30-50ルール）
- 型安全性問題の包括的検出
- 非同期処理の問題検出強化
- ベストプラクティスの推奨

### C++拡張（+40-60ルール）
- Use-after-free、Double-free等の致命的脆弱性検出
- Rule of Three/Five違反検出
- モダンC++推奨

### Swift拡張（+30-40ルール）
- 強制アンラップ・キャスト検出強化
- Retain cycle検出
- Optional処理のベストプラクティス

## インストール

[INSTALL.md](INSTALL.md)を参照してください。

## アップグレード

既存のv1.1.0からのアップグレード:

\`\`\`bash
# グローバルインストールの場合
cd /path/to/smart-review-system
git pull origin main
cp -r .claude/skills/* ~/.claude/skills/
\`\`\`

## 互換性

- 後方互換性: あり
- 既存ルールへの影響: なし
- Claude Code CLI: v1.0以上

## 既知の問題

- なし

## 今後の予定

- v1.3.0: OWASP Top 10完全対応
- v1.4.0: 主要フレームワーク拡張（React、Angular、Vue等）
```

---

## 期待される効果

### フェーズ1: TypeScript拡張

**検出精度の向上:**
- Before: 型安全性問題をほぼ検出できない
- After: 30-50パターンで包括的に検出

**具体的な効果:**
1. ランタイムエラーの削減（型関連）
2. 非同期処理のバグ削減
3. 開発者の型安全性意識向上

**ROI:**
- 工数: 3-4日
- 効果: TypeScriptプロジェクトでの品質向上（大）

---

### フェーズ2: C++拡張

**検出精度の向上:**
- Before: メモリ安全性の基本的な問題のみ検出
- After: Use-after-free、Double-free等の致命的脆弱性を検出

**具体的な効果:**
1. セキュリティ脆弱性の早期発見
2. クラッシュの削減
3. メモリリークの削減

**ROI:**
- 工数: 5-6日
- 効果: C++プロジェクトでの安全性向上（大）

---

### フェーズ3: Swift拡張

**検出精度の向上:**
- Before: 強制アンラップのみ検出
- After: Optional処理全般、メモリ管理問題を検出

**具体的な効果:**
1. iOSアプリのクラッシュ削減
2. メモリリークの削減
3. App Storeレビューの通過率向上

**ROI:**
- 工数: 3-4日
- 効果: iOSアプリ開発での安定性向上（大）

---

### 全体の効果

**総ルール数の変化:**
- Before: 368+
- After: 468-568+
- 増加率: +27-54%

**言語カバレッジの向上:**
| 言語 | Before | After | 増加率 |
|------|--------|-------|--------|
| TypeScript | 1 | 31-51 | **+3000-5000%** |
| C++ | 6 | 46-66 | **+667-1000%** |
| Swift | 4 | 34-44 | **+750-1000%** |

**ユーザーへの価値:**
1. より包括的なコードレビュー
2. 言語固有の問題の早期発見
3. セキュリティ脆弱性の削減
4. 開発者の学習効果（推奨修正から学ぶ）

---

## その他の拡張提案

### 優先度2（次のバージョンで検討）

#### 1. OWASP Top 10 完全対応

**目標:** OWASP Top 10 2021の全項目を網羅

**現在未対応:**
- A04: Insecure Design
- A05: Security Misconfiguration
- A06: Vulnerable and Outdated Components
- A08: Software and Data Integrity Failures
- A09: Security Logging and Monitoring Failures
- A10: Server-Side Request Forgery (SSRF)

**予想ルール数:** +50-80ルール

**工数:** 6-8日

**期待効果:**
- Webアプリケーションセキュリティの大幅強化
- エンタープライズ向けアピール

---

#### 2. フレームワーク固有ルール

**対象:**
- **React**: 非推奨API、Hooks違反、パフォーマンスアンチパターン
- **Angular**: 非推奨API、依存性注入の誤用、Change Detection問題
- **Vue**: Reactivity問題、Composition API vs Options API
- **Django**: セキュリティ設定、ORM N+1問題
- **Spring Boot**: セキュリティ設定、トランザクション管理

**予想ルール数:** +20-30ルール/フレームワーク

**工数:** 2-3日/フレームワーク

---

#### 3. パフォーマンス最適化ルール

**カテゴリ:**
1. アルゴリズム効率（O(n²) → O(n log n)）
2. データベースクエリ最適化（N+1問題等）
3. キャッシュ戦略
4. 非同期処理の最適化
5. メモリ使用量削減

**予想ルール数:** +40-60ルール

**工数:** 4-5日

---

### 優先度3（将来的に検討）

#### 1. アクセシビリティルール

**対象:**
- WCAG 2.1準拠
- ARIA属性の正しい使用
- セマンティックHTML
- キーボード操作対応
- スクリーンリーダー対応

**予想ルール数:** +30-50ルール

**工数:** 4-5日

---

#### 2. テストコード品質ルール

**カテゴリ:**
- テストカバレッジ
- テスト可読性
- モックの適切な使用
- テストの独立性
- Given-When-Then構造

**予想ルール数:** +20-30ルール

**工数:** 2-3日

---

#### 3. Google Style Guide統合

**対応言語:**
- C++
- Python
- Java
- JavaScript
- TypeScript
- Go

**各言語:**
- 命名規則
- フォーマット
- コメント規則
- 言語固有のイディオム

**予想ルール数:** +20-40ルール/言語

**工数:** 2-3日/言語

---

## 実装ロードマップ

### v1.2.0（短期 - 1-2ヶ月）

| フェーズ | 内容 | 工数 | 優先度 |
|---------|------|------|--------|
| Phase 1 | TypeScript拡張 | 3-4日 | 高 |
| Phase 2 | C++拡張 | 5-6日 | 高 |
| Phase 3 | Swift拡張 | 3-4日 | 中 |
| **合計** | - | **11-14日** | - |

**リリース目標:** 2025年12月

**総ルール数:** 468-568+（+100-150ルール）

---

### v1.3.0（中期 - 3-4ヶ月）

| 項目 | 工数 | 優先度 |
|------|------|--------|
| OWASP Top 10完全対応 | 6-8日 | 高 |
| React拡張 | 2-3日 | 中 |
| Angular拡張 | 2-3日 | 中 |
| Vue拡張 | 2-3日 | 中 |
| **合計** | **12-17日** | - |

**リリース目標:** 2026年2月

**総ルール数:** 600-700+（+130-180ルール）

---

### v2.0.0（長期 - 6-12ヶ月）

| 項目 | 工数 | 優先度 |
|------|------|--------|
| パフォーマンス最適化ルール | 4-5日 | 中 |
| アクセシビリティルール | 4-5日 | 低 |
| テストコード品質ルール | 2-3日 | 低 |
| Google Style Guide統合 | 10-15日 | 低 |
| CI/CD統合（GitHub Actions） | 5-7日 | 中 |
| **合計** | **25-35日** | - |

**リリース目標:** 2026年6月

**総ルール数:** 800-1000+（+200-300ルール）

---

## 参考資料

### 公式ドキュメント

- [ESLint TypeScript Plugin](https://typescript-eslint.io/)
- [Clang-Tidy](https://clang.llvm.org/extra/clang-tidy/)
- [SwiftLint](https://realm.github.io/SwiftLint/)
- [OWASP Top 10 2021](https://owasp.org/Top10/)
- [CWE - Common Weakness Enumeration](https://cwe.mitre.org/)

### プロジェクト内ドキュメント

- [BUGSEARCH3-INTEGRATION-GUIDE.md](./BUGSEARCH3-INTEGRATION-GUIDE.md)
- [YAML-RULES-INTEGRATION.md](./YAML-RULES-INTEGRATION.md)
- [smart-review-implementation-plan.md](./smart-review-implementation-plan.md)

### 外部リソース

- [C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/)
- [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- [Google Style Guides](https://google.github.io/styleguide/)

---

## 更新履歴

| バージョン | 日付 | 変更内容 | 作成者 |
|-----------|------|---------|-------|
| 1.0.0 | 2025-11-18 | 初版作成 | KENJI OYAMA |

---

## ライセンス・著作権

**著作権:** (c) 2025 KEIEI.NET INC.
**作成者:** KENJI OYAMA
**ライセンス:** MIT License（プロジェクトルートのLICENSEファイルを参照）

---

**注意事項:**
- このドキュメントは計画段階のものであり、実装は未完了です
- 実装時は最新の参照ソース（ESLint、Clang-Tidy、SwiftLint）を確認してください
- ルール数や工数は見積もりであり、実際には変動する可能性があります
- 実装前にテスト環境での検証を推奨します

**質問・フィードバック:**
- Issues: https://github.com/KEIEI-NET/smart-review-Skills_Version/issues
- Discussions: https://github.com/KEIEI-NET/smart-review-Skills_Version/discussions
