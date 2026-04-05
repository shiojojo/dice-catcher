extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect to any child Dice instances that emit `game_over`.
	for child in get_children():
		if child.has_signal("game_over"):
			child.connect("game_over", Callable(self , "_on_dice_game_over"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_dice_game_over() -> void:
	print("Game Over")
