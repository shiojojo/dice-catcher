extends Node2D


const DiceScene: PackedScene = preload("res://Scenes/dice.tscn")

var rng := RandomNumberGenerator.new()
var score: int = 0
@export var score_label_path: NodePath = NodePath("")
const SPAWN_MARGIN: int = 50


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	if has_node("SpawnTimer"):
		var st := $SpawnTimer
		st.connect("timeout", Callable(self , "_spawn_dice"))
	else:
		_spawn_dice()
	# connect Fox ate_dice signal to update score
	if has_node("Fox"):
		var fox_node := $Fox
		if not fox_node.is_connected("ate_dice", Callable(self , "_on_fox_ate_dice")):
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

	# Play game over sound (one-shot)
	var sfx := AudioStreamPlayer.new()
	var over_stream = load("res://Assets/game_over.wav")
	if over_stream:
		sfx.stream = over_stream
		add_child(sfx)
		sfx.play()

	pause_all()


func pause_all(group_name: String = "stoppable") -> void:
	# Stop the spawn timer if present (it may not be in the group)
	if has_node("SpawnTimer") and $SpawnTimer is Timer:
		$SpawnTimer.stop()

	var nodes := get_tree().get_nodes_in_group(group_name)
	for n in nodes:
		if n is Node:
			# Stop Timer nodes so time-based callbacks don't continue
			# if n is Timer:
			# 	n.stop()
			# Stop physics processing (Dice uses _physics_process)
			n.set_physics_process(false)

	# Optionally pause the entire SceneTree instead of per-node processing
	# get_tree().paused = true
	
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
