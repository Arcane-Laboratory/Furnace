extends RuneBase
class_name PowerRune
## Grants a stacking damage bonus to fireballs that pass over it


func _on_rune_ready() -> void:
	rune_type = "power"


func _on_activate(fireball: Node2D) -> void:
	# Apply power stack to fireball (increases damage)
	# Pass rune's global position so status text appears above the rune
	if fireball.has_method("add_power_stack"):
		fireball.add_power_stack(global_position)
	
	# Play activation sound
	AudioManager.play_sound_effect("rune-generic")
	
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
