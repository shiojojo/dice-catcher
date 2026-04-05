extends Node2D


const DiceScene: PackedScene = preload("res://Scenes/dice.tscn")

var rng := RandomNumberGenerator.new()
const SPAWN_MARGIN: int = 50


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	if has_node("SpawnTimer"):
		var st := $SpawnTimer
		st.connect("timeout", Callable(self , "_spawn_dice"))
	else:
		_spawn_dice()


func spawn_dice_at(spawn_pos: Vector2) -> Dice:
	var dice: Dice = DiceScene.instantiate()
	dice.position = spawn_pos
	add_child(dice)
	dice.connect("game_over", Callable(self , "_on_dice_game_over"))
	return dice


func _spawn_dice() -> void:
	var visible_rect := get_viewport().get_visible_rect()
	var min_x = int(visible_rect.position.x)
	var max_x = int(visible_rect.end.x)
	var left = min_x + SPAWN_MARGIN
	var right = max_x - SPAWN_MARGIN
	if left > right:
		left = min_x
		right = max_x
	var x = rng.randi_range(left, right)
	var pos = Vector2(x, visible_rect.position.y - SPAWN_MARGIN)
	spawn_dice_at(pos)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_dice_game_over() -> void:
	print("Game Over")
