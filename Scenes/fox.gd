extends Area2D
class_name fox

signal ate_dice(points: int)

@export var speed: float = 400.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# connect area_entered so we can detect when a Dice enters the fox area
	if not is_connected("area_entered", Callable(self , "_on_area_entered")):
		self.connect("area_entered", Callable(self , "_on_area_entered"))


# Physics step — move with collisions handled by Area2D overlap checks
func _physics_process(delta: float) -> void:
	var dir := Input.get_axis("ui_left", "ui_right")
	position.x += dir * speed * delta
	# flip sprite horizontally when moving right — ignore near-zero with is_zero_approx
	if has_node("Sprite2D") and $Sprite2D is Sprite2D:
		if not is_zero_approx(dir):
			$Sprite2D.flip_h = dir > 0
	# keep fox inside viewport
	var vr := get_viewport().get_visible_rect()
	position.x = clamp(position.x, vr.position.x, vr.end.x)


func _on_area_entered(area: Area2D) -> void:
	# When a Dice enters the fox area, play eating sound and remove the dice
	if area is Dice:
		if has_node("AudioStreamPlayer2D") and $AudioStreamPlayer2D is AudioStreamPlayer2D:
			$AudioStreamPlayer2D.play()
		emit_signal("ate_dice", 1)
		area.queue_free()
