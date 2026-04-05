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
	# register spawned dice to the global stoppable group
	dice.add_to_group("global_group")
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


func _on_dice_game_over() -> void:
	pause_all()


func pause_all(group_name: String = "global_group") -> void:
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
