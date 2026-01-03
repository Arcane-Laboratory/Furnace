extends RuneBase
class_name AccelerationRune
## Temporarily boosts fireball speed when activated


## Speed boost amount
const SPEED_BOOST: float = 200.0

## Duration of the speed boost in seconds
const BOOST_DURATION: float = 3.0


func _on_rune_ready() -> void:
	rune_type = "acceleration"


func _on_activate(fireball: Node2D) -> void:
	# Apply temporary speed boost to fireball
	if fireball.has_method("apply_speed_boost"):
		fireball.apply_speed_boost(SPEED_BOOST, BOOST_DURATION)
	
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
