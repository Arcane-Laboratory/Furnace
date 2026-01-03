extends RuneBase
class_name ReflectRune
## Reflects the fireball 180-degrees when activated (like bouncing off a wall)


## Cooldown timer to prevent rapid re-activation (stuck bouncing)
var cooldown_timer: float = 0.0

## Whether the rune is currently on cooldown
var is_on_cooldown: bool = false


func _on_rune_ready() -> void:
	rune_type = "reflect"


func _process(delta: float) -> void:
	if is_on_cooldown:
		cooldown_timer -= delta
		if cooldown_timer <= 0.0:
			is_on_cooldown = false
			cooldown_timer = 0.0


func _on_activate(fireball: Node2D) -> void:
	# Check cooldown to prevent stuck bouncing
	if is_on_cooldown:
		return
	
	# Reflect the fireball (180-degree turn)
	if fireball.has_method("reflect"):
		fireball.reflect()
	
	# Start cooldown
	is_on_cooldown = true
	cooldown_timer = GameConfig.reflect_rune_cooldown
	
	# Visual feedback (optional - flash the rune)
	_play_activation_effect()


func _play_activation_effect() -> void:
	# Simple flash effect
	var visual := get_node_or_null("RuneVisual") as ColorRect
	if visual:
		var original_color := visual.color
		visual.color = Color.WHITE
		
		var tween := create_tween()
		tween.tween_property(visual, "color", original_color, 0.2)


func _on_depleted() -> void:
	super._on_depleted()
	# Fade out the rune when depleted
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.3, 0.3)
