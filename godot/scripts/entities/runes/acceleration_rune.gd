extends RuneBase
class_name AccelerationRune
## Permanently increases fireball speed when activated (stacking system)


func _on_rune_ready() -> void:
	rune_type = "acceleration"


func _on_activate(fireball: Node2D) -> void:
	# Check if fireball is already at max speed before adding stack
	var is_at_max_speed: bool = false
	if fireball.has("speed_stacks"):
		is_at_max_speed = fireball.speed_stacks >= GameConfig.acceleration_max_stacks
	
	# Add speed stack to fireball (permanent until lost on hit)
	# Pass rune's global position so status text appears above the rune
	if fireball.has_method("add_speed_stack"):
		fireball.add_speed_stack(GameConfig.acceleration_speed_increase, global_position)
	
	# Only play activation sound if fireball was not already at max speed
	if not is_at_max_speed:
		AudioManager.play_sound_effect("rune-accelerate")
	
	_play_activation_effect()


## Play visual feedback when activated
func _play_activation_effect() -> void:
	var visual := get_node_or_null("RuneVisual") as ColorRect
	if not visual:
		return
	
	# Flash white then return to original color
	var original_color := visual.color
	visual.color = Color.WHITE
	
	var tween := create_tween()
	tween.tween_property(visual, "color", original_color, 0.2)
