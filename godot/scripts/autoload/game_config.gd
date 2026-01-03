extends Node
## Developer tunable parameters - all game balance values in one place


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
var fireball_max_speed: float = 500.0

# Rune Cooldowns
var reflect_rune_cooldown: float = 0.5

# Explosive Rune Parameters
var explosive_damage: int = 15
var explosive_radius: int = 1  # In tiles

# Acceleration Rune Parameters
var acceleration_speed_increase: float = 50.0

# Enemy Parameters
var basic_enemy_health: int = 50
var basic_enemy_speed: float = 50.0  # pixels per second
var fast_enemy_health: int = 30
var fast_enemy_speed: float = 80.0
var tank_enemy_health: int = 150
var tank_enemy_speed: float = 30.0

# Resource Costs
var wall_cost: int = 5
var redirect_rune_cost: int = 10
var advanced_redirect_rune_cost: int = 15
var portal_rune_cost: int = 20
var reflect_rune_cost: int = 12
var explosive_rune_cost: int = 18
var acceleration_rune_cost: int = 15

# Level Resources (indexed by level number)
var level_resources: Array[int] = [
	0,    # Level 0 (unused)
	100,  # Level 1 - Tutorial
	120,  # Level 2
	150,  # Level 3
	180,  # Level 4
	200,  # Level 5
]


func _ready() -> void:
	pass


func get_level_resources(level: int) -> int:
	if level > 0 and level < level_resources.size():
		return level_resources[level]
	return 100  # Default fallback


func get_rune_cost(rune_type: String) -> int:
	match rune_type:
		"redirect":
			return redirect_rune_cost
		"advanced_redirect":
			return advanced_redirect_rune_cost
		"portal":
			return portal_rune_cost
		"reflect":
			return reflect_rune_cost
		"explosive":
			return explosive_rune_cost
		"acceleration":
			return acceleration_rune_cost
		_:
			return 0


func get_wall_cost() -> int:
	return wall_cost
