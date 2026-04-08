# 開発者向け README — dice-catcher (Godot 4.6)

## 概要

- 小さな Godot 4.6 プロジェクト。プレイヤーはフォックスを左右に動かして落ちてくるダイスを捕まえます。
- このファイルは開発者向けの手順・コーディング規約・最近のリファクタ履歴をまとめたものです。

## 必要環境

- Godot 4.6.x（エディタは 4.6 系を推奨）
- 開発マシン（macOS/Windows/Linux のいずれでも可）

## クイックスタート

1. Godot 4.6 を起動し、リポジトリ直下の `project.godot` を開く。
2. メインシーンは `Scenes/game.tscn`。エディタ上で再生して動作確認。
3. 変更を試す手順：編集 → エディタ上で再生 → 必要に応じて `get_tree().reload_current_scene()` を利用。

（CLIでの起動は環境に依存します。ローカルに `godot` コマンドがある場合は `godot --path .` でプロジェクトを開けます。）

## 主要ファイル（抜粋）

- [Scenes/game.gd](Scenes/game.gd#L1-L200) — ゲーム全体のロジック（スポーン、スコア、ポーズなど）
- [Scenes/dice.gd](Scenes/dice.gd#L1-L200) — 落ちるダイスの振る舞い（速度・回転・画面外判定）
- [Scenes/fox.gd](Scenes/fox.gd#L1-L200) — プレイヤー（フォックス）の入力と当たり判定
- [Scenes/fox.tscn](Scenes/fox.tscn#L1-L200), [Scenes/dice.tscn](Scenes/dice.tscn#L1-L200) — シーンファイル
- `Assets/` — 音声・画像などのリソース

## コーディング規約（このプロジェクトの推奨スタイル）

- ノード参照はキャッシュする
  - `@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D` のように書き、毎フレームの `$` 探索を避ける。
- 静的な子ノードは `$` を使う（`get_node(...) as Type` は冗長）
  - 例: `@onready var spawn_timer: Timer = $Pausable/SpawnTimer`
- シグナル接続は Godot 4 スタイルで書く
  - 例: `spawn_timer.timeout.connect(_spawn_dice)` / `fox_node.ate_dice.connect(_on_fox_ate_dice)`
- シグナル発火は `signal.emit(...)` を使う
  - 例: `game_over.emit()` / `ate_dice.emit(1)`（`emit_signal("name")` はレガシー）
- 命名規則
  - 変数・関数: `snake_case`
  - 定数: `const NAME: Type = value`（大文字スネーク推奨）
  - `class_name` はプロジェクト内で一貫性を持たせる（TitleCase 推奨）
- 入力処理
  - ポーズ状態でも確実に受け取りたい入力は `_input(event)` を使う。
- パフォーマンス
  - 毎フレームでのノード検索や不要な型チェック（`has_node` + `is`）は避ける。シーン構成が前提なら早期に例外で気づいた方が安全。
- シーンのインスタンス化
  - `const DiceScene: PackedScene = preload("res://Scenes/dice.tscn")`
  - `var dice := DiceScene.instantiate()` / `dice.global_position = pos` / `pausable.add_child(dice)`

## 最近のリファクタ（このブランチ/作業での変更点）

- [Scenes/fox.gd](Scenes/fox.gd#L1-L200)
  - `@onready` で `sprite` / `audio` をキャッシュ。`has_node` と都度の `$` 探索を削除。
  - `area_entered.connect(_on_area_entered)` のように接続を簡素化。
  - シグナルは `ate_dice.emit(1)` を利用。
- [Scenes/dice.gd](Scenes/dice.gd#L1-L200)
  - exported 変数を `speed` / `rotation_speed` / `bottom_margin` に命名変更（snake_case）。
  - RNG の処理を `rotation_speed *= [-1, 1].pick_random()` に簡素化。
  - ゲームオーバー判定を `_physics_process` 内にインライン化し、`game_over.emit()` を使用。
- [Scenes/game.gd](Scenes/game.gd#L1-L200)
  - `get_node(...) as Type` を `$` に置換して簡潔化。
  - `spawn_timer.timeout.connect(_spawn_dice)` など Godot4 風に接続。
  - `_process` の `restart` 判定を `_input(event)` に移動し、ポーズ時の挙動を安定化。
  - ポーズ関連のロジックを直接 `get_tree().paused = true/false` で扱うように整理。

## 注意事項 / 例外

- `has_node` や動的なノード参照が必要な場合（外部から差し替えられる、あるいはオプションの子ノード）は、存在チェックや安全策を残してください。今回のリファクタは「静的に存在する前提」の下で簡素化しています。
- `class_name` を変更する場合は、型注釈や参照しているコード（例: `@onready var fox_node: fox = $Pausable/Fox`）も合わせて更新が必要です。

## 貢献フロー（推奨）

1. ブランチを切る（`feature/...` や `fix/...`）
2. Godot で動作確認（該当シーンを実行）
3. 小さな単位で Pull Request を出す。変更点には必ず簡単な説明を付ける。

---

## チェックリスト（実務用）

以下は上から順に確認するだけで、古いスタイルや生成AIが出しがちなコードを高確率で検出できる実務向けチェックリストです。

1. Signalまわり（最優先）

- 古い書き方（アウト）: `connect("signal_name", Callable(self, "_func"))` / `emit_signal("signal_name")`
- 推奨（OK）: `node.signal_name.connect(_func)` / `signal_name.emit()`
- 文字列でシグナル名を扱っている箇所は要レビュー。

2. Callableの多用

- 古い: `Callable(self, "_func")`
- 推奨: 直接 `_func` を渡す。

3. ノード取得が古い

- 古い: `get_node("Path") as Label`
- 推奨: `@onready var label: Label = $Path`（さらに堅牢にするなら `%UniqueName` を検討）

4. yield を使っている

- 古い: `yield(timer, "timeout")`
- 推奨: `await timer.timeout`

5. instance()/instantiate の差

- 古い: `scene.instance()`
- 推奨: `scene.instantiate()`

6. 入力処理の場所

- 古い: `_process()` 内での `Input.is_action_pressed()`
- 推奨: `_input(event)` を使う（ポーズやイベント駆動の観点で重要）

7. 不要な null チェック

- 古い: `if node:` の多用
- 推奨: 静的に存在する前提ならチェックを省く（壊れたら早く検出する）

8. has_node の乱用

- `has_node("Child")` が頻出しているコードは要警戒（ほぼ古い防御的パターン）

9. API 名や定数名の差分

- 例: `Node.PAUSE_MODE_PROCESS`（古い） vs `Node.PROCESS_MODE_ALWAYS`（4.x）

10. connect の文字列シグナル

- 古い: `connect("timeout", ...)`
- 推奨: `timer.timeout.connect(...)`

11. 型推論の活用

- 古い: `var x = 10`
- 推奨: `var x := 10`（4.x は型推論が標準）

12. `$` を毎回使っている箇所

- 古い: 毎フレーム `$Child` を呼ぶ
- 推奨: `@onready var child: NodeType = $Child` でキャッシュ

13. 過剰なラップ関数

- 中身が1行だけのヘルパー関数は冗長な場合がある（状況に応じて統合を検討）

14. 過剰防御コード

- `if node and node is Something:` のような過剰なチェックはWeb的で冗長。シーン前提でシンプルに。

合格ライン（自動チェックの目安）

- `.connect()` / `.emit()` を使っている
- `$` や `%` + `@onready` が使われている
- `await` が使われている（`yield` はなし）
- `_input` を使っている
- 不要な `if` / `has_node` がない

AI が書いたコードの典型パターン（要疑い）

- 「安全のために if を追加」している箇所
- `Callable(self, ...)` を多用している箇所
- `connect("文字列")` / `get_node + as` を使っている箇所

見抜くコツ: 「文字列ベースかプロパティベースか」を見る。文字列が多ければ旧式／AI由来の可能性高。

## Godot 4.x — 実務で差が出るポイント

このプロジェクトでは特に以下の点に注意してください（実務で差が出やすい事項を厳選）。

1. connect の完全モダン化

- 推奨: `timer.timeout.connect(_on_timeout)`（古い `connect("timeout", Callable(...))` は避ける）
- 引数ありのコールバックはラムダを活用: `button.pressed.connect(func(): do_something(42))`

2. Signal の発火

- 推奨: `game_over.emit()`（`emit_signal("game_over")` は旧式）

3. ノード取得（$ / % / @onready）

- 推奨: `@onready var label: Label = $Path`
- より堅牢にする場合は Unique Name `%NodeName` を活用（パス変更に強い）

4. 入力処理

- 推奨: `_input(event)` を使う（`_process()` での入力チェックはポーズやフレーム依存の問題を招きやすい）

5. await / yield

- 推奨: `await timer.timeout`（`yield` は廃止）

6. PackedScene の生成

- 推奨: `var obj = scene.instantiate()`（`instance()` は旧式）

7. そのほか注意点（短く）

- `Callable` の多用は不要になった（多くは直接関数参照で代替可）
- `move_and_slide` 等、3.x → 4.x で破壊的に挙動が変わっている API に注意

短く言うと: 「文字列ベースの書き方から型安全でプロパティベースなスタイルへ移行している」ため、これらを踏まえたコーディングを推奨します。

---
