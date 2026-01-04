extends AnimatedSprite2D
## Ensures title background animation plays automatically


func _ready() -> void:
	# Ensure animation plays
	if sprite_frames and sprite_frames.has_animation("title_loop"):
		play("title_loop")
