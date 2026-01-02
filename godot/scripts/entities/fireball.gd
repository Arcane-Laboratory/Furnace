extends Node2D
class_name Fireball
## The fireball projectile that travels through the grid and activates runes


## Current movement direction (cardinal only)
var direction: Vector2 = Vector2.DOWN

## Current speed (can be modified by Acceleration Runes)
var current_speed: float = 0.0

## Whether the fireball is currently active/moving
var is_active: bool = false

## Track which tiles we've already activated (to prevent double-activation)
var activated_tiles: Array[Vector2i] = []

signal fireball_destroyed
signal enemy_hit(enemy: Node2D, damage: int)
signal rune_ignited(rune: RuneBase)


func _ready() -> void:
	current_speed = GameConfig.fireball_speed
	add_to_group("fireball")


func _physics_process(delta: float) -> void:
	if not is_active:
		return
	
	# Move in current direction
	position += direction * current_speed * delta
	
	# Check for tile center crossing (for rune activation)
	_check_tile_activation()
	
	# Check for boundary collision
	_check_boundaries()


## Launch the fireball from the furnace
func launch(start_position: Vector2) -> void:
	position = start_position
	direction = Vector2.DOWN  # Always starts going down from furnace
	current_speed = GameConfig.fireball_speed
	is_active = true
	activated_tiles.clear()


## Set a new direction (called by redirect runes)
func set_direction(new_direction: Vector2) -> void:
	# Ensure cardinal direction only
	if new_direction in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		direction = new_direction


## Increase speed (called by acceleration runes)
func accelerate(amount: float) -> void:
	current_speed = min(current_speed + amount, GameConfig.fireball_max_speed)


## Check if we've crossed a tile center and should activate runes
func _check_tile_activation() -> void:
	# Convert world position to grid position
	# Note: This assumes GameBoard is at a known offset - adjust as needed
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


## Check if fireball has left the play area
func _check_boundaries() -> void:
	var grid_bounds := Rect2(
		0, 0,
		GameConfig.GRID_WIDTH,
		GameConfig.GRID_HEIGHT
	)
	
	# Add some margin for the fireball to fully exit
	var margin := 32.0
	var expanded_bounds := grid_bounds.grow(margin)
	
	if not expanded_bounds.has_point(position):
		_destroy()


## Destroy the fireball
func _destroy() -> void:
	is_active = false
	fireball_destroyed.emit()
	queue_free()


## Convert world position to grid position
func _world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		int(world_pos.x / GameConfig.TILE_SIZE),
		int(world_pos.y / GameConfig.TILE_SIZE)
	)


## Convert grid position to world position (tile center)
func _grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2,
		grid_pos.y * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2
	)
