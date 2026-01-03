extends Resource
class_name LevelData
## Custom resource for defining level layouts and configurations


## Level identifier
@export var level_number: int = 1

## Display name for the level
@export var level_name: String = "Level 1"

## Starting resources for this level
@export var starting_resources: int = 100

## Pre-placed walls (grid positions that are blocked)
## These cannot be edited by the player
@export var preset_walls: Array[Vector2i] = []

## Pre-placed runes (grid position + rune type)
## These cannot be edited by the player
@export var preset_runes: Array[Dictionary] = []
# Format: [{ "position": Vector2i, "type": "redirect", "direction": "south", "uses": 0 }]

## Impassable terrain tiles (rock/mountain)
@export var terrain_blocked: Array[Vector2i] = []

## Enemy spawn points
@export var spawn_points: Array[Vector2i] = []

## Furnace entry position (where fireball launches from)
@export var furnace_position: Vector2i = Vector2i(6, 0)  # Top center default

## Enemy wave data
@export var enemy_waves: Array[Dictionary] = []
# Format: [{ "enemy_type": "basic", "spawn_point": 0, "delay": 0.0 }]

## Par time for level (optional, for scoring)
@export var par_time_seconds: float = 60.0

## Hint text shown at level start (optional)
@export var hint_text: String = ""

## Allowed runes for this level (empty array = all default runes available)
## Format: Array of rune type strings (e.g., ["redirect", "wall", "portal"])
@export var allowed_runes: Array[String] = []


## Validate that the level data is properly configured
func is_valid() -> bool:
	# Must have at least one spawn point
	if spawn_points.is_empty():
		push_warning("Level %d has no spawn points" % level_number)
		return false
	
	# Must have at least one enemy
	if enemy_waves.is_empty():
		push_warning("Level %d has no enemies" % level_number)
		return false
	
	# Furnace must be within grid bounds
	if furnace_position.x < 0 or furnace_position.x >= GameConfig.GRID_COLUMNS:
		push_warning("Level %d furnace position out of bounds" % level_number)
		return false
	
	return true


## Get all blocked tiles (terrain + preset walls)
func get_blocked_tiles() -> Array[Vector2i]:
	var blocked: Array[Vector2i] = []
	blocked.append_array(terrain_blocked)
	blocked.append_array(preset_walls)
	return blocked


## Check if a tile is buildable (not blocked by terrain or preset elements)
func is_tile_buildable(grid_pos: Vector2i) -> bool:
	# Check bounds
	if grid_pos.x < 0 or grid_pos.x >= GameConfig.GRID_COLUMNS:
		return false
	if grid_pos.y < 0 or grid_pos.y >= GameConfig.GRID_ROWS:
		return false
	
	# Check terrain
	if grid_pos in terrain_blocked:
		return false
	
	# Check preset walls
	if grid_pos in preset_walls:
		return false
	
	# Check preset runes
	for rune_data in preset_runes:
		if rune_data.get("position") == grid_pos:
			return false
	
	# Check spawn points
	if grid_pos in spawn_points:
		return false
	
	# Check furnace position
	if grid_pos == furnace_position:
		return false
	
	return true
