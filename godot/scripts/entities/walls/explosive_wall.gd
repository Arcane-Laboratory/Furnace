extends Node2D
class_name ExplosiveWall
## Wall that explodes when fireball passes adjacent, dealing damage in 8 surrounding tiles


var grid_position: Vector2i = Vector2i.ZERO
var cooldown_timer: float = 0.0
var is_on_cooldown: bool = false
var has_exploded_for_current_fireball: bool = false
var was_fireball_adjacent_last_frame: bool = false


func _ready() -> void:
	add_to_group("explosive_walls")
	# Update sprite position after a frame to ensure sprite node is ready
	call_deferred("_update_sprite_position")


func _process(delta: float) -> void:
	if is_on_cooldown:
		cooldown_timer -= delta
		if cooldown_timer <= 0.0:
			is_on_cooldown = false
			cooldown_timer = 0.0
	
	# Check if fireball is currently adjacent
	var fireball_adjacent_now: bool = false
	var fireballs := get_tree().get_nodes_in_group("fireball")
	for fireball in fireballs:
		if fireball is Fireball:
			if check_fireball_adjacent(fireball.current_grid_pos):
				fireball_adjacent_now = true
				break
	
	# Reset explosion flag when fireball is no longer adjacent
	if was_fireball_adjacent_last_frame and not fireball_adjacent_now:
		has_exploded_for_current_fireball = false
	
	was_fireball_adjacent_last_frame = fireball_adjacent_now


func set_grid_position(pos: Vector2i) -> void:
	grid_position = pos
	position = Vector2(
		pos.x * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2,
		pos.y * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2
	)
	# Set z_index for depth sorting (same as regular walls)
	z_index = pos.y * 10 + 5
	
	# Position sprite so bottom aligns with tile bottom (for taller sprites)
	_update_sprite_position()


func check_fireball_adjacent(fireball_pos: Vector2i) -> bool:
	## Check if fireball is directly adjacent (cardinal directions only)
	var distance := fireball_pos - grid_position
	return abs(distance.x) + abs(distance.y) == 1


func explode() -> void:
	if is_on_cooldown:
		return
	
	# Prevent multiple explosions per fireball pass
	if has_exploded_for_current_fireball:
		return
	
	has_exploded_for_current_fireball = true
	
	# Deal damage to enemies in 8 surrounding tiles (3x3 area)
	var enemies := get_tree().get_nodes_in_group("enemies")
	var enemies_hit: int = 0
	
	for enemy in enemies:
		# Skip if enemy is not valid
		if not is_instance_valid(enemy):
			continue
		
		# Skip if enemy is already dead (don't show damage numbers on dead enemies)
		# Check if enemy has health property and if it's <= 0
		if "health" in enemy and enemy.health <= 0:
			continue
		
		if enemy.has_method("get_grid_position"):
			var enemy_pos: Vector2i = enemy.get_grid_position()
			var distance: Vector2i = enemy_pos - grid_position
			# Check if enemy is in 3x3 area (including center)
			if abs(distance.x) <= 1 and abs(distance.y) <= 1:
				if enemy.has_method("take_damage"):
					# Store health before damage to check if this kills the enemy
					var health_before: int = enemy.health if "health" in enemy else 0
					enemy.take_damage(GameConfig.explosive_wall_damage)
					# Only count as hit if enemy was alive before taking damage
					if health_before > 0:
						enemies_hit += 1
	
	# Play explosion effect
	_play_explosion_effect()
	
	# Start cooldown (post-MVP: will have cooldown, MVP: no cooldown or very short)
	# is_on_cooldown = true
	# cooldown_timer = GameConfig.explosive_wall_cooldown
	
	if enemies_hit > 0:
		print("ExplosiveWall: Hit %d enemies for %d damage each" % [enemies_hit, GameConfig.explosive_wall_damage])


func _update_sprite_position() -> void:
	## Position sprite so bottom aligns with tile bottom (for taller sprites)
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if not sprite or not sprite.texture:
		return
	
	var sprite_height := sprite.texture.get_height()
	var tile_height := GameConfig.TILE_SIZE
	var offset_y := (sprite_height - tile_height) / 2.0
	sprite.position = Vector2(0, -offset_y)


func _play_explosion_effect() -> void:
	## Visual effect similar to explosive rune
	var explosion := ColorRect.new()
	explosion.size = Vector2(8, 8)
	explosion.position = Vector2(-4, -4)
	explosion.color = Color(1.0, 0.6, 0.2, 0.8)
	add_child(explosion)
	
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(explosion, "size", Vector2(96, 96), 0.3)  # 3x3 tiles
	tween.tween_property(explosion, "position", Vector2(-48, -48), 0.3)
	tween.tween_property(explosion, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(explosion.queue_free)
