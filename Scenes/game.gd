extends Node2D


const DiceScene: PackedScene = preload("res://Scenes/dice.tscn")

var rng := RandomNumberGenerator.new()
var score: int = 0
@export var score_label_path: NodePath = NodePath("")
const SPAWN_MARGIN: int = 50

# Cached node references for clarity and to avoid repeated lookups.
@onready var spawn_timer := get_node_or_null("Pausable/SpawnTimer") as Timer
@onready var fox_node := get_node_or_null("Pausable/Fox")
var score_label: Label = null


func _ready() -> void:
	rng.randomize()

	# Connect spawn timer if present.
	if spawn_timer and not spawn_timer.is_connected("timeout", Callable(self , "_spawn_dice")):
		spawn_timer.connect("timeout", Callable(self , "_spawn_dice"))

	# Connect fox signal if present.
	if fox_node and not fox_node.is_connected("ate_dice", Callable(self , "_on_fox_ate_dice")):
		fox_node.connect("ate_dice", Callable(self , "_on_fox_ate_dice"))

	# Resolve score label: try exported path first, then fallback to node named "ScoreLabel".
	var maybe_label := get_node_or_null(score_label_path)
	if maybe_label and maybe_label is Label:
		score_label = maybe_label
	if not score_label:
		var fallback := get_node_or_null("ScoreLabel")
		if fallback and fallback is Label:
			score_label = fallback

	_update_score_label()


func spawn_dice_at(spawn_pos: Vector2) -> Dice:
	var dice := DiceScene.instantiate() as Dice
	dice.position = spawn_pos
	dice.connect("game_over", Callable(self , "_on_dice_game_over"))
	add_child(dice)
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


func _on_dice_game_over() -> void:
	var music := get_node_or_null("Music") as AudioStreamPlayer
	if music:
		music.stop()

	var go_player := get_node_or_null("GameOver") as AudioStreamPlayer
	if go_player:
		go_player.play()

	pause_all()


func pause_all() -> void:
	if spawn_timer:
		spawn_timer.stop()

	for child in get_children():
		if child is Dice:
			child.set_physics_process(false)
			child.set_process(false)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()


func _on_fox_ate_dice(points: int) -> void:
	score += points
	_update_score_label()


func _update_score_label() -> void:
	if not score_label:
		var maybe_label := get_node_or_null(score_label_path)
		if maybe_label and maybe_label is Label:
			score_label = maybe_label
		else:
			var fallback := get_node_or_null("ScoreLabel")
			if fallback and fallback is Label:
				score_label = fallback
	if score_label:
		score_label.text = "%04d" % score
