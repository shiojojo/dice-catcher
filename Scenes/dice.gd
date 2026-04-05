extends Area2D
class_name Dice

signal game_over

@export var SPEED: float = 200.0
@export var ROTATION_SPEED: float = 3.0
@export var BOTTOM_MARGIN: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	# Randomly choose rotation direction (clockwise or counter-clockwise)
	if rng.randi_range(0, 1) == 0:
		ROTATION_SPEED = - abs(ROTATION_SPEED)
	else:
		ROTATION_SPEED = abs(ROTATION_SPEED)


# Physics step (fixed timestep) — use for movement with collisions.
func _physics_process(delta: float) -> void:
	position.y += SPEED * delta
	rotate(ROTATION_SPEED * delta)
	_check_game_over()

func _check_game_over() -> void:
	var visible_rect := get_viewport().get_visible_rect()
	var bottom_y := visible_rect.end.y
	if position.y > bottom_y + BOTTOM_MARGIN:
		emit_signal("game_over")
		queue_free()
