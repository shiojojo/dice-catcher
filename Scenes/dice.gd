extends Area2D
class_name Dice

@export var SPEED: float = 200.0
@export var ROTATION_SPEED: float = 3.0


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
