# dice-catcher

# dice-catcher

## 概要

シンプルな Godot 製のミニゲーム（Godot 4.6 想定）。上から落ちてくるダイスをキツネで受け止めて得点を稼ぐカジュアルゲーム。

## 遊び方（ユーザー向け）

- 移動: `ui_left` / `ui_right`（デフォルトは左右キー、必要なら InputMap で変更）
- リスタート: `restart` アクション（プロジェクト設定で割当）
- ルール: ダイスをキツネで受け取ると得点 +1。ダイスが画面下まで落ちるとゲームオーバー。

## 主要なファイル・構成

- [Scenes/game.tscn](Scenes/game.tscn) — ゲーム管理（スポーン、スコア、ゲームオーバー処理）
- [Scenes/game.gd](Scenes/game.gd) — スポーン処理、スコア管理、`_on_dice_game_over()` でゲームオーバーを扱う。
- [Scenes/fox.tscn](Scenes/fox.tscn) — プレイヤー（キツネ）ノード
- [Scenes/fox.gd](Scenes/fox.gd) — プレイヤー移動と当たり判定。ダイスを受け取ると `ate_dice(points)` を emit（現状は `1`）。
- [Scenes/dice.tscn](Scenes/dice.tscn) — ダイスのノード
- [Scenes/dice.gd](Scenes/dice.gd) — 落下と回転、画面下到達で `game_over` を emit
- Assets/ — 画像・音声・フォントなどのアセット（例: `Dice.png`, `eating.wav`, `tetris.mp3`, `LuckiestGuy-Regular.ttf`）
