extends Resource
class_name SpawnEnemyRule
## Resource class for defining enemy spawn rules per spawn point
## Each rule defines a group of enemies that spawn from a specific spawn point over time

enum EnemyType {
	BASIC,  # Standard enemy
	FAST,   # Fast enemy (low health, high speed)
	TANK,   # Tank enemy (high health, low speed)
}

## Index into LevelData.spawn_points array (0-based)
@export var spawn_point_index: int = 0

## Enemy type to spawn
@export var enemy_type: EnemyType = EnemyType.BASIC

## Seconds before this rule starts spawning (default 0)
@export var spawn_delay: float = 0.0

## How many enemies to spawn (default 6)
@export var spawn_count: int = 6

## Total duration in seconds to stagger spawns over (default 60)
## Interval between spawns = spawn_time / spawn_count
@export var spawn_time: float = 60.0


## Convert enemy type enum to string for compatibility with existing systems
func get_enemy_type_string() -> String:
	match enemy_type:
		EnemyType.BASIC:
			return "basic"
		EnemyType.FAST:
			return "fast"
		EnemyType.TANK:
			return "tank"
		_:
			return "basic"


## Calculate the interval between spawns in seconds
func get_spawn_interval() -> float:
	if spawn_count <= 1:
		return 0.0
	return spawn_time / float(spawn_count - 1)


## Get the time when a specific enemy index should spawn
func get_spawn_time_for_index(index: int) -> float:
	if index <= 0:
		return spawn_delay
	if spawn_count <= 1:
		return spawn_delay
	return spawn_delay + (float(index) * get_spawn_interval())
