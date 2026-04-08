extends Node2D


const DiceScene: PackedScene = preload("res://Scenes/dice.tscn")

var rng := RandomNumberGenerator.new()
var score: int = 0
const SPAWN_MARGIN: int = 50

# Cached node references for clarity and to avoid repeated lookups.
@onready var spawn_timer: Timer = get_node("Pausable/SpawnTimer") as Timer
@onready var fox_node: fox = get_node("Pausable/Fox") as fox
@onready var music: AudioStreamPlayer = get_node("Music") as AudioStreamPlayer
@onready var go_player: AudioStreamPlayer = get_node("GameOver") as AudioStreamPlayer
@onready var score_label: Label = $ScoreLabel
@onready var pausable: Node = get_node("Pausable") as Node


func _ready() -> void:
	rng.randomize()

	# Connect spawn timer.
	spawn_timer.connect("timeout", Callable(self , "_spawn_dice"))

	# Connect fox signal.
	fox_node.connect("ate_dice", Callable(self , "_on_fox_ate_dice"))

	_update_score_label()


func spawn_dice_at(spawn_pos: Vector2) -> Dice:
	var dice := DiceScene.instantiate() as Dice
	# place as global so parent doesn't affect intended spawn coordinates
	dice.global_position = spawn_pos
	dice.connect("game_over", Callable(self , "_on_dice_game_over"))
	pausable.add_child(dice)
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
	music.stop()
	go_player.play()

	pause_all()


func pause_all() -> void:
	# Pause the whole scene tree; nodes with `pause_mode = Node.PAUSE_MODE_PROCESS` keep running (e.g. UI)
	get_tree().paused = true


func resume_all() -> void:
	# Resume the whole scene tree
	get_tree().paused = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		# Ensure the tree is resumed so timers and nodes restart correctly
		resume_all()
		get_tree().reload_current_scene()


func _on_fox_ate_dice(points: int) -> void:
	score += points
	_update_score_label()


func _update_score_label() -> void:
	if score_label:
		score_label.text = "%04d" % score
