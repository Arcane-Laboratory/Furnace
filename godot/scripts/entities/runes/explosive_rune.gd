extends RuneBase
class_name ExplosiveRune
## Explodes when fireball passes over, dealing damage to all enemies on the same tile


func _on_rune_ready() -> void:
	rune_type = "explosive"
	# Explosive runes are single-use by default
	uses_remaining = 1


func _on_activate(fireball: Node2D) -> void:
	# Deal damage to all enemies on this tile
	var enemies := get_tree().get_nodes_in_group("enemies")
	var enemies_hit: int = 0
	
	for enemy in enemies:
		if enemy.has_method("get_grid_position") and enemy.get_grid_position() == grid_position:
			if enemy.has_method("take_damage"):
				enemy.take_damage(GameConfig.explosive_damage)
				enemies_hit += 1
	
	# Play explosion effect
	_play_explosion_effect()
	
	# Log for debugging
	if enemies_hit > 0:
		print("ExplosiveRune: Hit %d enemies for %d damage each" % [enemies_hit, GameConfig.explosive_damage])


func _play_explosion_effect() -> void:
	# Get the visual node
	var visual := get_node_or_null("RuneVisual") as ColorRect
	if not visual:
		return
	
	# Create expanding explosion circle
	var explosion := ColorRect.new()
	explosion.size = Vector2(8, 8)
	explosion.position = Vector2(-4, -4)
	explosion.color = Color(1.0, 0.6, 0.2, 0.8)
	add_child(explosion)
	
	# Animate explosion expanding and fading
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(explosion, "size", Vector2(48, 48), 0.3)
	tween.tween_property(explosion, "position", Vector2(-24, -24), 0.3)
	tween.tween_property(explosion, "color:a", 0.0, 0.3)
	tween.chain().tween_callback(explosion.queue_free)
	
	# Flash the rune visual
	var original_color := visual.color
	visual.color = Color.WHITE
	
	var visual_tween := create_tween()
	visual_tween.tween_property(visual, "color", original_color, 0.2)


func _on_depleted() -> void:
	super._on_depleted()
	# Fade out and remove the rune when depleted
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
