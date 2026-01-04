extends Resource
class_name LevelData
## Custom resource for defining level layouts and configurations


## Enemy type enum (matches EnemyWaveEntry.EnemyType)
enum EnemyType {
	BASIC,  # Standard enemy
	FAST,   # Fast enemy (low health, high speed)
	TANK,   # Tank enemy (high health, low speed)
}

## Rune type enum
enum RuneType {
	REDIRECT,          # Basic redirect rune
	ADVANCED_REDIRECT, # Advanced redirect (can change direction during active phase)
	WALL,              # Wall (blocks enemy movement)
	REFLECT,           # Reflect rune (bounces fireball back)
	EXPLOSIVE,         # Explosive rune (area damage)
	ACCELERATION,      # Acceleration rune (speeds up fireball)
	PORTAL,            # Portal rune (teleports fireball)
}


## Level identifier
@export var level_number: int = 1

## Display name for the level
@export var level_name: String = "Level 1"

## Starting resources for this level
@export var starting_resources: int = 100

## Pre-placed buildable items (walls, runes, etc.)
## These cannot be edited by the player
@export var preset_items: Array[Dictionary] = []
# Format: [{ "position": Vector2i, "type": String, "direction": String, "uses": int }]
# type: item_type from BuildableItemDefinition (e.g., "wall", "redirect", "portal")

## Impassable terrain tiles (rock/mountain)
@export var terrain_blocked: Array[Vector2i] = []

## Enemy spawn points
@export var spawn_points: Array[Vector2i] = []

## Furnace entry position (where fireball launches from)
@export var furnace_position: Vector2i = Vector2i(6, 0)  # Top center default

## Enemy wave data (using typed resource entries)
@export var enemy_waves: Array[EnemyWaveEntry] = []

## Par time for level (optional, for scoring)
@export var par_time_seconds: float = 60.0

## Hint text shown at level start (optional)
@export var hint_text: String = ""

## Allowed runes for this level (empty array = all default runes available)
## Uses enum values for type safety
@export var allowed_runes: Array[RuneType] = []

## Difficulty knob (0-50) - multiplies enemy health via exponential formula
## 0 = 1x health (normal), 50 = 100x health (very hard)
@export_range(0, 50, 1) var difficulty: int = 0

## Heat increase interval (seconds) - how often heat increases by 1 during active phase
## Set to 0.0 to disable heat increase over time
@export_range(0.0, 60.0, 0.1) var heat_increase_interval: float = 0.0

## Unlock all buildable items for this level (overrides unlocked_by_default)
@export var unlock_all_items: bool = false


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


## Get all blocked tiles (terrain + items that block paths)
func get_blocked_tiles() -> Array[Vector2i]:
	var blocked: Array[Vector2i] = []
	blocked.append_array(terrain_blocked)
	
	# Add preset items that block paths (walls, explosive walls, etc.)
	for item_data in preset_items:
		var item_type: String = item_data.get("type", "")
		if _item_blocks_path(item_type):
			var pos: Vector2i = item_data.get("position", Vector2i.ZERO)
			blocked.append(pos)
	
	return blocked


## Check if an item type blocks pathfinding
func _item_blocks_path(item_type: String) -> bool:
	# Try to get definition from GameConfig if available
	if GameConfig and GameConfig.buildable_item_definitions.has(item_type):
		var definition = GameConfig.buildable_item_definitions[item_type]
		if definition:
			return definition.blocks_path
	
	# Fallback: known blocking item types
	return item_type in ["wall", "explosive_wall"]


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
	
	# Check preset items (walls, runes, etc.)
	for item_data in preset_items:
		if item_data.get("position") == grid_pos:
			return false
	
	# Check spawn points
	if grid_pos in spawn_points:
		return false
	
	# Check furnace position
	if grid_pos == furnace_position:
		return false
	
	return true


## Convert rune type enum to string for compatibility with existing systems
static func rune_type_to_string(rune_type: RuneType) -> String:
	match rune_type:
		RuneType.REDIRECT:
			return "redirect"
		RuneType.ADVANCED_REDIRECT:
			return "advanced_redirect"
		RuneType.WALL:
			return "wall"
		RuneType.REFLECT:
			return "reflect"
		RuneType.EXPLOSIVE:
			return "explosive"
		RuneType.ACCELERATION:
			return "acceleration"
		RuneType.PORTAL:
			return "portal"
		_:
			return "redirect"


## Get allowed runes as string array (for compatibility with existing code)
func get_allowed_runes_strings() -> Array[String]:
	var result: Array[String] = []
	for rune_type in allowed_runes:
		result.append(rune_type_to_string(rune_type))
	return result


## Check if a rune type is allowed (by string)
func is_rune_allowed(rune_type_string: String) -> bool:
	if allowed_runes.is_empty():
		# Empty array means all default unlocked runes are available
		return true
	
	# Convert string to enum and check
	var rune_type: RuneType = string_to_rune_type(rune_type_string)
	return rune_type in allowed_runes


## Convert string to rune type enum
static func string_to_rune_type(rune_type_string: String) -> RuneType:
	match rune_type_string:
		"redirect":
			return RuneType.REDIRECT
		"advanced_redirect":
			return RuneType.ADVANCED_REDIRECT
		"wall":
			return RuneType.WALL
		"reflect":
			return RuneType.REFLECT
		"explosive":
			return RuneType.EXPLOSIVE
		"acceleration":
			return RuneType.ACCELERATION
		"portal":
			return RuneType.PORTAL
		_:
			return RuneType.REDIRECT
