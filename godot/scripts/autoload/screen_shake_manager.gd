extends Node
## Global screen shake manager - call ScreenShakeManager.shake() from anywhere


var shake_tween: Tween = null
var original_offset: Vector2 = Vector2.ZERO


func shake(intensity: float = 3.0, duration: float = 0.2) -> void:
	## Trigger a screen shake effect
	## intensity: Maximum pixel offset for the shake
	## duration: How long the shake lasts in seconds
	
	# Cancel any existing shake
	if shake_tween and shake_tween.is_valid():
		shake_tween.kill()
		_reset_offset()
	
	# Store original offset (should be zero)
	original_offset = Vector2.ZERO
	
	# Create shake tween
	shake_tween = create_tween()
	shake_tween.set_loops(int(duration / 0.03))  # ~30fps shake updates
	
	# Each loop: random offset then quick return
	shake_tween.tween_callback(_apply_random_offset.bind(intensity))
	shake_tween.tween_interval(0.03)
	
	# When done, reset to original position
	shake_tween.finished.connect(_reset_offset)


func _apply_random_offset(intensity: float) -> void:
	## Apply a random offset to the viewport
	var offset := Vector2(
		randf_range(-intensity, intensity),
		randf_range(-intensity, intensity)
	)
	
	var viewport := get_viewport()
	if viewport:
		var transform := viewport.canvas_transform
		transform.origin = offset
		viewport.canvas_transform = transform


func _reset_offset() -> void:
	## Reset the viewport to its original position
	var viewport := get_viewport()
	if viewport:
		var transform := viewport.canvas_transform
		transform.origin = original_offset
		viewport.canvas_transform = transform
