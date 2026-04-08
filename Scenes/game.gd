extends Node2D

const DiceScene: PackedScene = preload("res://Scenes/dice.tscn")

var score: int = 0
const SPAWN_MARGIN: int = 50

@onready var spawn_timer: Timer = $Pausable/SpawnTimer
@onready var fox_node: Fox = $Pausable/Fox
@onready var music: AudioStreamPlayer = $Music
@onready var go_player: AudioStreamPlayer = $GameOver
@onready var score_label: Label = $ScoreLabel
@onready var pausable: Node = $Pausable


func _ready() -> void:
	spawn_timer.timeout.connect(_spawn_dice)
	fox_node.ate_dice.connect(_on_fox_ate_dice)
	_update_score_label()


func spawn_dice_at(spawn_pos: Vector2) -> Dice:
	var dice := DiceScene.instantiate()
	dice.global_position = spawn_pos
	dice.game_over.connect(_on_dice_game_over)
	pausable.add_child(dice)
	return dice


func _spawn_dice() -> void:
	var vr := get_viewport().get_visible_rect()
	var left := int(vr.position.x) + SPAWN_MARGIN
	var right := int(vr.end.x) - SPAWN_MARGIN

	if left > right:
		left = int(vr.position.x)
		right = int(vr.end.x)

	var x := randi_range(left, right)
	var pos := Vector2(x, vr.position.y - SPAWN_MARGIN)
	spawn_dice_at(pos)


func _on_dice_game_over() -> void:
	music.stop()
	go_player.play()
	get_tree().paused = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().paused = false
		get_tree().reload_current_scene()


func _on_fox_ate_dice(points: int) -> void:
	score += points
	_update_score_label()


func _update_score_label() -> void:
	score_label.text = "%04d" % score
