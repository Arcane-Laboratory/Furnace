extends Node2D
class_name Fireball
## The fireball projectile that travels through the grid and activates runes


## Current movement direction (cardinal only)
var direction: Vector2 = Vector2.DOWN

## Current speed (can be modified by Acceleration Runes)
var current_speed: float = 0.0

## Base speed (without boosts)
var base_speed: float = 0.0

## Active speed boost amount
var speed_boost: float = 0.0

## Timer for speed boost duration
var boost_timer: float = 0.0

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


func _physics_process(delta: float) -> void:
	if not is_active:
		return
	
	# Update boost timer
	if boost_timer > 0.0:
		boost_timer -= delta
		if boost_timer <= 0.0:
			_remove_speed_boost()
	
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
	
	# Check for wall collision (destroy at walls)
	if _has_wall_at(next_grid_pos) and next_grid_pos != current_grid_pos:
		_destroy()
		return
	
	# Move to next position
	position = next_pos
	current_grid_pos = _world_to_grid(position)
	
	# Check for tile center crossing (for rune activation)
	_check_tile_activation()


## Launch the fireball from the furnace
func launch(start_position: Vector2) -> void:
	position = start_position
	direction = Vector2.DOWN  # Always starts going down from furnace
	base_speed = GameConfig.fireball_speed
	current_speed = base_speed
	speed_boost = 0.0
	boost_timer = 0.0
	is_active = true
	activated_tiles.clear()
	current_grid_pos = _world_to_grid(position)
	
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
		direction = new_direction
		_update_rotation()


## Increase speed permanently (called by acceleration runes if needed)
func accelerate(amount: float) -> void:
	base_speed = min(base_speed + amount, GameConfig.fireball_max_speed)
	_update_current_speed()


## Apply a temporary speed boost for a duration
func apply_speed_boost(amount: float, duration: float) -> void:
	speed_boost = amount
	boost_timer = duration
	_update_current_speed()
	print("Fireball: Speed boost applied! +%d for %.1fs (speed: %d)" % [amount, duration, current_speed])


## Remove the speed boost
func _remove_speed_boost() -> void:
	speed_boost = 0.0
	boost_timer = 0.0
	_update_current_speed()
	print("Fireball: Speed boost expired (speed: %d)" % current_speed)


## Update current speed based on base speed and boost
func _update_current_speed() -> void:
	current_speed = min(base_speed + speed_boost, GameConfig.fireball_max_speed)


## Check if we've crossed a tile center and should activate runes
func _check_tile_activation() -> void:
	# Convert world position to grid position
	var grid_pos := _world_to_grid(position)
	
	if grid_pos in activated_tiles:
		return
	
	# Check if we're near the center of a tile
	var tile_center := _grid_to_world(grid_pos)
	if position.distance_to(tile_center) < 4.0:  # Small threshold
		activated_tiles.append(grid_pos)
		_activate_tile(grid_pos)


## Activate any runes on the given tile
func _activate_tile(grid_pos: Vector2i) -> void:
	# Find runes at this position
	var runes := get_tree().get_nodes_in_group("runes")
	for rune in runes:
		if rune is RuneBase and rune.grid_position == grid_pos:
			rune.activate(self)
			rune_ignited.emit(rune)
	
	# Check for enemies to damage
	var enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.has_method("get_grid_position") and enemy.get_grid_position() == grid_pos:
			_hit_enemy(enemy)


## Hit an enemy with the fireball
func _hit_enemy(enemy: Node2D) -> void:
	if enemy.has_method("take_damage"):
		enemy.take_damage(GameConfig.fireball_damage)
		enemy_hit.emit(enemy, GameConfig.fireball_damage)


## Check if a grid position is out of bounds
func _is_out_of_bounds(grid_pos: Vector2i) -> bool:
	return (grid_pos.x < 0 or grid_pos.x >= GameConfig.GRID_COLUMNS or
			grid_pos.y < 0 or grid_pos.y >= GameConfig.GRID_ROWS)


## Check if there is a wall at the given grid position
func _has_wall_at(grid_pos: Vector2i) -> bool:
	# Use TileManager to check for walls
	var tile := TileManager.get_tile(grid_pos)
	if tile:
		return tile.occupancy == TileBase.OccupancyType.WALL
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
	
	fireball_teleported.emit(old_position, new_position)


## Destroy the fireball
func _destroy() -> void:
	is_active = false
	
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
