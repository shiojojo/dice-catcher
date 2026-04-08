# copilot-instructions.md — Cross-project (Godot 4.x)

このファイルは複数プロジェクトで再利用可能な、生成AI（Copilot 等）向けの指示テンプレートです。
対象は主に Godot 4.x 系（4.0〜4.6）で、プロジェクトごとの固有要素は含めません。

---

## 目的

- 生成AIにコードを出力させる際の共通ルールを明文化し、古いスタイルや非推奨パターンを自動生成させない。
- 人手レビュー時に「AIが出した古いコード」を素早く見抜けるようガイドラインを与える。

---

## 要約（最重要）

生成AIに対して常に以下を要求してください：

- Godot 4.x スタイルで書くこと（プロパティ／型安全な API を優先）
- `@onready` + `$`/`%` を使ったノード参照（`get_node("...") as ...` は避ける）
- シグナルは `.connect()` / `.emit()` を使用（`connect("sig", Callable(...))` / `emit_signal(...)` は避ける）
- `await` を使う（`yield` は使わない）
- `instantiate()` を使う（`instance()` は使わない）
- 変数は `snake_case`、`class_name` は TitleCase

---

## 詳細ルール（チェックリストとして使う）

上から順にチェックすれば、古いスタイルをほぼ検出できます。

1. シグナル関連（最優先）

- NG: `connect("signal_name", Callable(self, "_func"))` / `emit_signal("signal_name")`
- OK: `node.signal_name.connect(_func)` / `signal_name.emit()`

2. `Callable` の多用は避ける

- NG: `Callable(self, "_func")`
- OK: 直接 `_func` を渡す

3. ノード取得

- NG: `get_node("Path") as Label`
- OK: `@onready var label: Label = $Path`
- さらに堅牢にするなら Unique Name (`%Name`) を使う

4. 非同期待ち

- NG: `yield(timer, "timeout")`
- OK: `await timer.timeout`

5. シーン生成

- NG: `scene.instance()`
- OK: `scene.instantiate()`

6. 入力処理

- NG: `_process()` 内で `Input.is_action_pressed()` を使う
- OK: `_input(event)` を使う（ポーズやイベントハンドリングで安定）

7. 型推論と代入

- NG: `var x = 10`
- OK: `var x := 10`

8. `$` を毎回呼び出すコード

- NG: 毎フレーム `$Child` を参照する
- OK: `@onready var child: NodeType = $Child` でキャッシュ

9. 過剰防御・冗長チェック

- NG: `if has_node("Child"):` / `if node and node is Something:`（静的に存在するなら不要）
- 理由: Godot では "壊れるなら壊れて気づく" 設計を優先する方が安全でシンプル

10. その他 API 変化に注意

- 例: `move_and_slide()` の挙動や pause 関連定数名は 3.x と 4.x で差があるため、AI に生成させる際は必ず "Godot 4.x" を明記する

---

## Prompt テンプレ（Copilot に与える例）

以下をプロンプトの先頭に付けてから具体的な実装指示を書くと安定します。

"Write GDScript for Godot 4.x (4.0–4.6). Follow these rules: use `@onready` with `$` or `%` for node access; prefer `.connect()` on signal properties and `.emit()` to fire signals; use `await` for async waits; use `instantiate()` for PackedScene creation; use `var x :=` for type inference; use snake_case for variables and TitleCase for `class_name`; avoid `get_node(... ) as Type`, `instance()`, `yield`, `emit_signal("...")`, and `Callable(self, ...)`. Keep functions concise and avoid unnecessary defensive null checks for static nodes."

（上の文をプロンプト先頭に入れておくだけで、古いパターンの生成が大幅に減ります。）

---

## 生成後のレビューポイント（チェックリストとして）

- 文字列ベースの `connect("...")` が残っていないか
- `emit_signal("...")` が使われていないか
- `get_node(...) as ...` が残っていないか
- `yield` / `instance()` / `Callable` の使用がないか
- `_input` を入力ハンドルに使っているか
- `@onready` でノードをキャッシュしているか
