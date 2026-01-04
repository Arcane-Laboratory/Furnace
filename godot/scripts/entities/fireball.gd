extends Node2D
class_name Fireball
## The fireball projectile that travels through the grid and activates runes


## Current movement direction (cardinal only)
var direction: Vector2 = Vector2.DOWN

## Current speed (can be modified by Acceleration Runes)
var current_speed: float = 0.0

## Base speed (without stacks)
var base_speed: float = 0.0

## Speed stacks (permanent speed increase) - stacks when passing over Acceleration Runes
var speed_stacks: int = 0

## Whether the fireball is currently active/moving
var is_active: bool = false

## Track which tiles we've already activated (to prevent double-activation)
var activated_tiles: Array[Vector2i] = []

## Track current grid position for collision detection
var current_grid_pos: Vector2i = Vector2i(-1, -1)

## Reference to the AnimatedSprite2D node
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

## Reference to the smoke particles
@onready var smoke_particles: GPUParticles2D = $SmokeParticles

## Reference to the collision Area2D
@onready var collision_area: Area2D = $Area2D

## Track currently overlapping enemies to prevent double damage
var overlapping_enemies: Dictionary = {}

## Power stacks (damage bonus) - stacks when passing over Power Runes
var power_stacks: int = 0

signal fireball_destroyed
signal enemy_hit(enemy: Node2D, damage: int)
signal rune_ignited(rune: RuneBase)
signal fireball_reflected
signal fireball_teleported(from_pos: Vector2, to_pos: Vector2)


func _ready() -> void:
	current_speed = GameConfig.fireball_speed
	add_to_group("fireball")
	
	# Ensure animation is playing (use get_node as fallback if @onready isn't ready)
	var sprite := animated_sprite if animated_sprite else get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if sprite:
		sprite.play("default")
		sprite.visible = true
	
	# Start with particles disabled (will be enabled when launched)
	var particles := smoke_particles if smoke_particles else get_node_or_null("SmokeParticles") as GPUParticles2D
	if particles:
		particles.emitting = false
	
	# Connect Area2D collision signals
	var area := collision_area if collision_area else get_node_or_null("Area2D") as Area2D
	if area:
		# Ensure monitoring is enabled for collision detection
		area.monitoring = true
		area.monitorable = false  # Fireball doesn't need to be detected by other areas
		
		# Connect signals (Godot 4 safely handles already-connected signals)
		area.body_entered.connect(_on_enemy_entered)
		area.body_exited.connect(_on_enemy_exited)
	else:
		push_warning("Fireball: Area2D node not found - enemy collision detection will not work")


func _physics_process(delta: float) -> void:
	if not is_active:
		return
	
	# Store previous position for sweep testing
	var prev_pos := position
	var prev_grid_pos := current_grid_pos
	
	# Calculate next position
	var next_pos := position + direction * current_speed * delta
	var next_grid_pos := _world_to_grid(next_pos)
	
	# Check for boundary collision (destroy at grid edges)
	# Only destroy if we're currently IN bounds and about to go OUT
	# This allows the fireball to enter the grid from outside (spawn position)
	var current_in_bounds := not _is_out_of_bounds(current_grid_pos)
	if current_in_bounds and _is_out_of_bounds(next_grid_pos):
		_destroy()
		return
	
	# Check all tiles between current and next position for walls (sweep test)
	# This prevents skipping over walls at high speeds
	var tiles_passed := _get_tiles_between(prev_grid_pos, next_grid_pos)
	for tile_pos in tiles_passed:
		if _has_wall_at(tile_pos) and tile_pos != prev_grid_pos:
			_destroy()
			return
	
	# Move to next position
	position = next_pos
	current_grid_pos = _world_to_grid(position)
	
	# Check all tiles passed through for activation (sweep test)
	# This prevents skipping runes at high speeds
	_check_tiles_activation(tiles_passed, prev_pos, position)
	
	# Check for adjacent explosive walls
	_check_explosive_walls()


## Launch the fireball from the furnace
func launch(start_position: Vector2) -> void:
	position = start_position
	direction = Vector2.DOWN  # Always starts going down from furnace
	base_speed = GameConfig.fireball_speed
	current_speed = base_speed
	speed_stacks = 0  # Reset speed stacks
	power_stacks = 0  # Reset power stacks
	is_active = true
	activated_tiles.clear()
	overlapping_enemies.clear()  # Reset collision tracking
	current_grid_pos = _world_to_grid(position)
	
	# Reset sprite scale to base (power stacks affect scale)
	_update_power_scale()
	
	# Ensure animation is playing (use get_node as fallback if @onready isn't ready)
	var sprite := animated_sprite if animated_sprite else get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if sprite:
		sprite.play("default")
		sprite.visible = true
	
	# Enable smoke particles
	var particles := smoke_particles if smoke_particles else get_node_or_null("SmokeParticles") as GPUParticles2D
	if particles:
		particles.emitting = true
	
	# Update rotation to face direction
	_update_rotation()


## Set a new direction (called by redirect runes)
func set_direction(new_direction: Vector2) -> void:
	# Ensure cardinal direction only
	if new_direction in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		# Only clear activated tiles if direction actually changed
		if direction != new_direction:
			direction = new_direction
			# Clear activated tiles to allow re-activation of runes
			# This enables bouncing between redirect runes and re-entering portals
			activated_tiles.clear()
			_update_rotation()


## Add a speed stack (called by Acceleration Rune)
## display_position: Optional position to display the status modifier (defaults to fireball position)
func add_speed_stack(amount: float, display_position: Vector2 = Vector2.ZERO) -> void:
	# Use provided position or default to fireball position
	var text_position := display_position if display_position != Vector2.ZERO else position
	
	# Check if already at cap
	if speed_stacks >= GameConfig.acceleration_max_stacks:
		# Show "Speed max!" message in yellow
		FloatingNumberManager.show_status_modifier("Speed max!", text_position, Color(1.0, 0.9, 0.2, 1.0))  # Yellow
		return
	
	speed_stacks += 1
	_update_current_speed()
	print("Fireball: Speed stack added! Total stacks: %d (speed: %d)" % [speed_stacks, current_speed])
	
	# Show "Speed up!" message in blue
	FloatingNumberManager.show_status_modifier("Speed up!", text_position, Color(0.2, 0.7, 1.0, 1.0))  # Cyan/blue


## Remove a speed stack (called when hitting an enemy - loses 1 stack per hit)
func remove_speed_stack() -> void:
	if speed_stacks > 0:
		speed_stacks -= 1
		_update_current_speed()
		# Speed down messages are hidden for now (as requested)


## Update current speed based on base speed and stacks
func _update_current_speed() -> void:
	# Cap speed stacks at maximum allowed (safety check)
	var capped_stacks: int = min(speed_stacks, GameConfig.acceleration_max_stacks)
	var speed_from_stacks: float = capped_stacks * GameConfig.acceleration_speed_increase
	current_speed = min(base_speed + speed_from_stacks, GameConfig.fireball_max_speed)


## Check all tiles passed through for activation (sweep test for high speeds)
## Checks if the movement line segment crosses through tile centers
func _check_tiles_activation(tiles_passed: Array[Vector2i], start_pos: Vector2, end_pos: Vector2) -> void:
	for grid_pos in tiles_passed:
		if grid_pos in activated_tiles:
			continue
		
		# Check if the line segment from start_pos to end_pos crosses through the tile center
		var tile_center := _grid_to_world(grid_pos)
		
		# Check if line segment intersects tile center region (small circle around center)
		# Use a threshold that scales with speed but has a minimum
		var threshold: float = max(8.0, current_speed * 0.01)  # Minimum 8px, scales with speed
		
		# Check if line segment passes near tile center
		# Calculate closest point on line segment to tile center
		var line_vec := end_pos - start_pos
		var to_center := tile_center - start_pos
		
		# If line is very short, just check distance
		if line_vec.length_squared() < 0.1:
			if start_pos.distance_to(tile_center) < threshold:
				activated_tiles.append(grid_pos)
				_activate_tile(grid_pos)
			continue
		
		# Project to_center onto line_vec to find closest point
		var t := to_center.dot(line_vec) / line_vec.length_squared()
		t = clamp(t, 0.0, 1.0)  # Clamp to line segment
		
		var closest_point := start_pos + line_vec * t
		var distance_to_center := closest_point.distance_to(tile_center)
		
		# If line segment passes through tile center region, activate
		if distance_to_center < threshold:
			activated_tiles.append(grid_pos)
			_activate_tile(grid_pos)


## Get all grid positions between start and end (inclusive)
## Handles cardinal movement (no diagonals)
func _get_tiles_between(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	
	# If start and end are the same, return just that tile
	if start == end:
		tiles.append(start)
		return tiles
	
	# Determine direction of movement
	var dx := end.x - start.x
	var dy := end.y - start.y
	
	# Handle horizontal movement
	if dx != 0 and dy == 0:
		var step := 1 if dx > 0 else -1
		for x in range(start.x, end.x + step, step):
			tiles.append(Vector2i(x, start.y))
	# Handle vertical movement
	elif dy != 0 and dx == 0:
		var step := 1 if dy > 0 else -1
		for y in range(start.y, end.y + step, step):
			tiles.append(Vector2i(start.x, y))
	# Handle case where we haven't moved yet (shouldn't happen, but safety check)
	else:
		tiles.append(start)
	
	return tiles


## Activate any runes on the given tile
func _activate_tile(grid_pos: Vector2i) -> void:
	# Find runes at this position
	var runes := get_tree().get_nodes_in_group("runes")
	for rune in runes:
		if rune is RuneBase and rune.grid_position == grid_pos:
			rune.activate(self)
			rune_ignited.emit(rune)
	
	# Enemy collision detection is now handled by Area2D signals
	# Removed grid-based enemy check to prevent double damage and missed collisions


## Check for explosive walls adjacent to current position
func _check_explosive_walls() -> void:
	var explosive_walls := get_tree().get_nodes_in_group("explosive_walls")
	for wall in explosive_walls:
		if wall is ExplosiveWall:
			if wall.check_fireball_adjacent(current_grid_pos):
				wall.explode()


## Hit an enemy with the fireball
func _hit_enemy(enemy: Node2D) -> void:
	# Don't hit dead enemies
	if "health" in enemy and enemy.health <= 0:
		return
	if "is_active" in enemy and not enemy.is_active:
		return
	
	if enemy.has_method("take_damage"):
		# Calculate damage with power stacks (2 damage per stack)
		var capped_power_stacks: int = min(power_stacks, GameConfig.power_max_stacks)
		var damage: int = GameConfig.fireball_damage + (capped_power_stacks * GameConfig.power_damage_increase)
		# Store health before damage to check if enemy was alive
		var health_before: int = enemy.health if "health" in enemy else 0
		enemy.take_damage(damage)
		# Only emit hit signal if enemy was alive before taking damage
		if health_before > 0:
			enemy_hit.emit(enemy, damage)


## Called when an enemy enters the fireball's collision area
func _on_enemy_entered(body: Node2D) -> void:
	# Validate body exists and is valid
	if not is_instance_valid(body):
		return
	
	# Check if body is an enemy (has take_damage method)
	if not body.has_method("take_damage"):
		return
	
	# Check if enemy is valid and not already overlapping (prevent double damage)
	if not body.is_inside_tree():
		return
	
	if body in overlapping_enemies:
		return
	
	# Add enemy to tracking dictionary
	overlapping_enemies[body] = true
	
	# Deal damage to enemy
	_hit_enemy(body)
	
	# Remove one stack per hit (as per plan: 1 stack per hit)
	remove_power_stack()
	remove_speed_stack()


## Called when an enemy exits the fireball's collision area
func _on_enemy_exited(body: Node2D) -> void:
	# Remove enemy from tracking dictionary
	# This allows re-hitting if enemy enters again later
	# Check if valid first to avoid warnings with freed nodes
	if is_instance_valid(body) and body in overlapping_enemies:
		overlapping_enemies.erase(body)


## Check if a grid position is out of bounds
func _is_out_of_bounds(grid_pos: Vector2i) -> bool:
	return (grid_pos.x < 0 or grid_pos.x >= GameConfig.GRID_COLUMNS or
			grid_pos.y < 0 or grid_pos.y >= GameConfig.GRID_ROWS)


## Check if there is a wall or terrain blocking at the given grid position
func _has_wall_at(grid_pos: Vector2i) -> bool:
	# Use TileManager to check for walls and terrain
	var tile := TileManager.get_tile(grid_pos)
	if tile:
		# is_crossable returns false for walls (occupancy) and rock terrain
		return not tile.is_crossable()
	return false


## Reflect the fireball (180-degree turn) - called by Reflect Rune
func reflect() -> void:
	direction = -direction  # Reverse direction
	fireball_reflected.emit()
	
	# Update rotation to face new direction
	_update_rotation()
	
	# Clear activated tiles when reflecting to allow re-activation
	# This prevents getting stuck in loops where runes can't activate again
	activated_tiles.clear()
	
	# Clear overlapping enemies to allow re-hitting after reflection
	overlapping_enemies.clear()


## Teleport the fireball to a new position with a new direction - called by Portal Rune
func teleport_to(new_position: Vector2, new_direction: Vector2) -> void:
	var old_position := position
	position = new_position
	current_grid_pos = _world_to_grid(position)
	
	# Set new direction (must be cardinal)
	if new_direction in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		direction = new_direction
	
	# Update rotation to face new direction
	_update_rotation()
	
	# Clear activated tiles to allow activation at new location
	activated_tiles.clear()
	
	# Clear overlapping enemies to allow re-hitting after teleport
	overlapping_enemies.clear()
	
	fireball_teleported.emit(old_position, new_position)


## Destroy the fireball
func _destroy() -> void:
	is_active = false
	
	# Clean up collision tracking
	overlapping_enemies.clear()
	
	# Stop smoke particles
	var particles := smoke_particles if smoke_particles else get_node_or_null("SmokeParticles") as GPUParticles2D
	if particles:
		particles.emitting = false
	
	fireball_destroyed.emit()
	queue_free()


## Convert world position to grid position
func _world_to_grid(world_pos: Vector2) -> Vector2i:
	# Use floori to correctly handle negative positions (left/top of grid)
	# int() truncates toward zero, so int(-0.5) = 0, but we need -1
	return Vector2i(
		floori(world_pos.x / GameConfig.TILE_SIZE),
		floori(world_pos.y / GameConfig.TILE_SIZE)
	)


## Convert grid position to world position (tile center)
func _grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2,
		grid_pos.y * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2
	)


## Update sprite rotation to face movement direction
func _update_rotation() -> void:
	var sprite := animated_sprite if animated_sprite else get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if not sprite:
		return
	
	# Calculate rotation angle based on direction
	# DOWN (0, 1) = 0 radians (default, facing down)
	# UP (0, -1) = PI radians (180 degrees, facing up)
	# RIGHT (1, 0) = -PI/2 radians (-90 degrees, facing right)
	# LEFT (-1, 0) = PI/2 radians (90 degrees, facing left)
	var rotation_angle: float = 0.0
	if direction == Vector2.UP:
		rotation_angle = PI
	elif direction == Vector2.RIGHT:
		rotation_angle = -PI / 2.0
	elif direction == Vector2.LEFT:
		rotation_angle = PI / 2.0
	# DOWN is already 0.0
	
	sprite.rotation = rotation_angle
	
	# Update smoke particle direction to trail behind fireball (opposite direction)
	_update_smoke_direction()


## Add a power stack (called by Power Rune)
## display_position: Optional position to display the status modifier (defaults to fireball position)
func add_power_stack(display_position: Vector2 = Vector2.ZERO) -> void:
	# Use provided position or default to fireball position
	var text_position := display_position if display_position != Vector2.ZERO else position
	
	# Check if already at cap
	if power_stacks >= GameConfig.power_max_stacks:
		# Show "Power max!" message in yellow
		FloatingNumberManager.show_status_modifier("Power max!", text_position, Color(1.0, 0.9, 0.2, 1.0))  # Yellow
		return
	
	power_stacks += 1
	var capped_stacks: int = min(power_stacks, GameConfig.power_max_stacks)
	print("Fireball: Power stack added! Total stacks: %d (damage: %d)" % [capped_stacks, GameConfig.fireball_damage + (capped_stacks * GameConfig.power_damage_increase)])
	
	# Update sprite scale based on power stacks (5% per stack, visual only)
	_update_power_scale()
	
	# Show status modifier VFX
	FloatingNumberManager.show_status_modifier("+Power x%d" % capped_stacks, text_position, Color(1.0, 0.6, 0.2, 1.0))  # Orange/red


## Remove a power stack (called when hitting an enemy - loses 1 stack per hit)
func remove_power_stack() -> void:
	if power_stacks > 0:
		power_stacks -= 1
		# Update sprite scale based on power stacks (5% per stack, visual only)
		_update_power_scale()
		# Show status modifier VFX when stack is lost
		if power_stacks > 0:
			FloatingNumberManager.show_status_modifier("Power x%d" % power_stacks, position, Color(1.0, 0.4, 0.1, 1.0))  # Darker orange


## Update sprite scale based on power stacks (5% per stack, visual only)
func _update_power_scale() -> void:
	var sprite := animated_sprite if animated_sprite else get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if not sprite:
		return
	
	# Calculate scale: base scale (1.0) + (power_stacks * 0.05)
	# Cap stacks at max for safety
	var capped_stacks: int = min(power_stacks, GameConfig.power_max_stacks)
	var scale_multiplier: float = 1.0 + (capped_stacks * 0.05)
	sprite.scale = Vector2(scale_multiplier, scale_multiplier)


## Update smoke particle direction to trail behind fireball
func _update_smoke_direction() -> void:
	var particles := smoke_particles if smoke_particles else get_node_or_null("SmokeParticles") as GPUParticles2D
	if not particles or not particles.process_material:
		return
	
	var material := particles.process_material as ParticleProcessMaterial
	if not material:
		return
	
	# Calculate direction vector opposite to fireball movement (smoke trails behind)
	# DOWN (0, 1) -> particles go UP (0, -1) -> Vector3(0, -1, 0)
	# UP (0, -1) -> particles go DOWN (0, 1) -> Vector3(0, 1, 0)
	# RIGHT (1, 0) -> particles go LEFT (-1, 0) -> Vector3(-1, 0, 0)
	# LEFT (-1, 0) -> particles go RIGHT (1, 0) -> Vector3(1, 0, 0)
	var particle_direction: Vector3 = Vector3(-direction.x, -direction.y, 0)
	
	# Normalize and set direction (with some spread handled by the material's spread property)
	material.direction = particle_direction.normalized()
