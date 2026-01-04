extends Node
## Developer tunable parameters - all game balance values in one place

## Developer debug mode - when true, starts at debug level with all items unlocked
## Set to true in editor for testing, leave false for production
var debug_mode: bool = true

# Grid Configuration
const GRID_COLUMNS: int = 13
const GRID_ROWS: int = 7
const TILE_SIZE: int = 32
const GRID_WIDTH: int = GRID_COLUMNS * TILE_SIZE  # 416
const GRID_HEIGHT: int = GRID_ROWS * TILE_SIZE    # 224

# Display Configuration
const VIEWPORT_WIDTH: int = 640
const VIEWPORT_HEIGHT: int = 360

# Fireball Parameters
var fireball_damage: int = 10
var fireball_speed: float = 200.0
var fireball_max_speed: float = 5000.0  # Increased 10x for stacking system

# Rune Cooldowns
var reflect_rune_cooldown: float = 0.5

# Explosive Rune Parameters
var explosive_damage: int = 15
var explosive_radius: int = 1  # In tiles

# Acceleration Rune Parameters
var acceleration_speed_increase: float = 50.0

# Power Rune Parameters
var power_damage_increase: int = 5  # Damage increase per power stack

# Explosive Wall Parameters
var explosive_wall_damage: int = 15
var explosive_wall_cooldown: float = 0.0  # MVP: no cooldown, post-MVP: add cooldown

# Enemy Parameters
var basic_enemy_health: int = 50
var basic_enemy_speed: float = 50.0  # pixels per second
var fast_enemy_health: int = 30
var fast_enemy_speed: float = 80.0
var tank_enemy_health: int = 150
var tank_enemy_speed: float = 30.0

# Buildable Item Definitions
# These are loaded from resource files in godot/resources/buildable_items/
var buildable_item_definitions: Dictionary = {}  # Key: item_type, Value: Resource (BuildableItemDefinition)

# Enemy Definitions
# These are loaded from resource files in godot/resources/enemies/
var enemy_definitions: Dictionary = {}  # Key: enemy_type, Value: Resource (EnemyDefinition)

# Level Resources (indexed by level number)
var level_resources: Array[int] = [
	1000, # Level 0 (debug) - generous resources for testing
	100,  # Level 1 - Tutorial
	120,  # Level 2
	150,  # Level 3
	180,  # Level 4
	200,  # Level 5
]


func _ready() -> void:
	_load_buildable_item_definitions()
	_load_enemy_definitions()


func get_level_resources(level: int) -> int:
	if level >= 0 and level < level_resources.size():
		return level_resources[level]
	return 100  # Default fallback


## Load all buildable item definitions from resource files
func _load_buildable_item_definitions() -> void:
	var definition_paths: Array[String] = [
		"res://resources/buildable_items/wall_definition.tres",
		"res://resources/buildable_items/explosive_wall_definition.tres",
		"res://resources/buildable_items/mud_tile_definition.tres",
		"res://resources/buildable_items/redirect_rune_definition.tres",
		"res://resources/buildable_items/portal_rune_definition.tres",
		"res://resources/buildable_items/reflect_rune_definition.tres",
		"res://resources/buildable_items/explosive_rune_definition.tres",
		"res://resources/buildable_items/acceleration_rune_definition.tres",
		"res://resources/buildable_items/power_rune_definition.tres",
	]
	
	for path in definition_paths:
		var definition: Resource = load(path) as Resource
		if definition:
			# Access property directly (it's an @export property on BuildableItemDefinition)
			var item_type: String = definition.item_type
			if item_type != "":
				buildable_item_definitions[item_type] = definition
			else:
				push_error("GameConfig: Loaded definition missing item_type: %s" % path)
		else:
			push_error("GameConfig: Failed to load buildable item definition: %s" % path)


## Get a buildable item definition by type
func get_item_definition(item_type: String) -> Resource:
	return buildable_item_definitions.get(item_type, null)


## Get all buildable item definitions
func get_all_item_definitions() -> Array:
	var definitions: Array = []
	for item_type in buildable_item_definitions:
		definitions.append(buildable_item_definitions[item_type])
	return definitions


## Backward compatibility: Get rune cost (delegates to definition)
func get_rune_cost(rune_type: String) -> int:
	var definition := get_item_definition(rune_type)
	if definition:
		return definition.cost
	return 0


## Backward compatibility: Get wall cost (delegates to definition)
func get_wall_cost() -> int:
	var definition := get_item_definition("wall")
	if definition:
		return definition.cost
	return 5  # Fallback


## Backward compatibility: Check if a rune type is unlocked by default (delegates to definition)
func is_rune_unlocked_by_default(rune_type: String) -> bool:
	var definition := get_item_definition(rune_type)
	if definition:
		return definition.unlocked_by_default
	return false


## Load all enemy definitions from resource files
func _load_enemy_definitions() -> void:
	var definition_paths: Array[String] = [
		"res://resources/enemies/basic_enemy_definition.tres",
		"res://resources/enemies/fast_enemy_definition.tres",
		"res://resources/enemies/tank_enemy_definition.tres",
	]
	
	for path in definition_paths:
		var definition: Resource = load(path) as Resource
		if definition:
			var enemy_type: String = definition.enemy_type
			if enemy_type != "":
				enemy_definitions[enemy_type] = definition
			else:
				push_error("GameConfig: Loaded enemy definition missing enemy_type: %s" % path)
		else:
			push_error("GameConfig: Failed to load enemy definition: %s" % path)


## Get an enemy definition by type
func get_enemy_definition(enemy_type: String) -> Resource:
	return enemy_definitions.get(enemy_type, null)


## Get all enemy definitions
func get_all_enemy_definitions() -> Array:
	var definitions: Array = []
	for enemy_type in enemy_definitions:
		definitions.append(enemy_definitions[enemy_type])
	return definitions


## Backward compatibility: Get enemy health (delegates to definition)
func get_enemy_health(enemy_type: String) -> int:
	var definition := get_enemy_definition(enemy_type)
	if definition:
		return definition.health
	# Fallback to old hardcoded values
	match enemy_type:
		"basic":
			return basic_enemy_health
		"fast":
			return fast_enemy_health
		"tank":
			return tank_enemy_health
	return 50  # Default fallback


## Backward compatibility: Get enemy speed (delegates to definition)
func get_enemy_speed(enemy_type: String) -> float:
	var definition := get_enemy_definition(enemy_type)
	if definition:
		return definition.speed
	# Fallback to old hardcoded values
	match enemy_type:
		"basic":
			return basic_enemy_speed
		"fast":
			return fast_enemy_speed
		"tank":
			return tank_enemy_speed
	return 50.0  # Default fallback
