extends AnimatedSprite2D
## Ensures furnace animation plays automatically


func _ready() -> void:
	# Ensure animation plays
	if sprite_frames and sprite_frames.has_animation("furnace_loop"):
		play("furnace_loop")
