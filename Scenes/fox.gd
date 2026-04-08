extends Area2D
class_name fox

signal ate_dice(points: int)

@export var speed: float = 400.0


@onready var sprite: Sprite2D = $Sprite2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	var dir := Input.get_axis("ui_left", "ui_right")
	position.x += dir * speed * delta

	if not is_zero_approx(dir):
		sprite.flip_h = dir > 0

	var vr := get_viewport().get_visible_rect()
	position.x = clamp(position.x, vr.position.x, vr.end.x)


func _on_area_entered(area: Area2D) -> void:
	if area is Dice:
		audio.play()
		ate_dice.emit(1)
		area.queue_free()
