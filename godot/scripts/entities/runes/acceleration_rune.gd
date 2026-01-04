extends RuneBase
class_name PowerRune
## Permanently increases fireball speed and damage when activated (stacking system)
## Combines speed boost (half rate) and damage boost (+1 per stack)


func _on_rune_ready() -> void:
	rune_type = "power"


func _on_activate(fireball: Node2D) -> void:
	# Check if fireball is already at max power before adding stack
	var is_at_max_power: bool = false
	if fireball is Fireball:
		var fireball_instance := fireball as Fireball
		is_at_max_power = fireball_instance.power_stacks >= GameConfig.acceleration_max_stacks
	
	# Add power stack to fireball (permanent until lost on hit)
	# Power stacks now provide both speed boost (half rate) and damage boost (+1)
	# Pass rune's global position so status text appears above the rune
	if fireball.has_method("add_power_stack"):
		fireball.add_power_stack(global_position)
	
	# Only play activation sound if fireball was not already at max power
	if not is_at_max_power:
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
