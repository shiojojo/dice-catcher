extends Area2D
class_name Dice

signal game_over

@export var speed: float = 200.0
@export var rotation_speed: float = 3.0
@export var bottom_margin: float = 0.0


func _ready() -> void:
	rotation_speed *= [-1, 1].pick_random()


func _physics_process(delta: float) -> void:
	position.y += speed * delta
	rotate(rotation_speed * delta)

	var bottom_y := get_viewport().get_visible_rect().end.y
	if position.y > bottom_y + bottom_margin:
		game_over.emit()
		queue_free()
