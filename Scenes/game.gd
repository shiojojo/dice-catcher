extends Node2D


const DiceScene: PackedScene = preload("res://Scenes/dice.tscn")

var rng := RandomNumberGenerator.new()
var score: int = 0
@export var score_label_path: NodePath = NodePath("")
const SPAWN_MARGIN: int = 50


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	# Pause settings configured in the TSCN; no runtime change here.
	# Connect only to Pausable/SpawnTimer (avoid path assumptions)
	var st := get_node_or_null("Pausable/SpawnTimer")
	if st and st is Timer:
		if not st.is_connected("timeout", Callable(self , "_spawn_dice")):
			st.connect("timeout", Callable(self , "_spawn_dice"))

	# Connect fox signal under Pausable
	var fox_node := get_node_or_null("Pausable/Fox")
	if fox_node and not fox_node.is_connected("ate_dice", Callable(self , "_on_fox_ate_dice")):
		fox_node.connect("ate_dice", Callable(self , "_on_fox_ate_dice"))
	# initialize score label display (shows 0000 initially)
	_update_score_label()


func spawn_dice_at(spawn_pos: Vector2) -> Dice:
	var dice: Dice = DiceScene.instantiate()
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
	# Stop background music if present
	if has_node("Music") and $Music is AudioStreamPlayer:
		$Music.stop()

	# Play game over sound using the scene's persistent player
	if has_node("GameOver") and $GameOver is AudioStreamPlayer:
		$GameOver.play()

	pause_all()


func pause_all() -> void:
	# Stop spawning and freeze active dice; Pausable subtree is managed in the TSCN.
	# Stop the spawn timer so no new dice are created.
	var st := get_node_or_null("Pausable/SpawnTimer")
	if st and st is Timer:
		st.stop()

	# Freeze all existing dice instances (they use _physics_process for movement).
	for child in get_children():
		if child is Dice:
			if child.has_method("set_physics_process"):
				child.set_physics_process(false)
			if child.has_method("set_process"):
				child.set_process(false)


# Note: _pause_subtree removed — pausing is targeted to SpawnTimer and Dice instances.
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()


func _on_fox_ate_dice(points: int) -> void:
	score += points
	_update_score_label()


func _update_score_label() -> void:
	var lbl := get_node_or_null(score_label_path)
	if lbl == null:
		lbl = get_node_or_null("ScoreLabel")
	if lbl and lbl is Label:
		lbl.text = "%04d" % score
