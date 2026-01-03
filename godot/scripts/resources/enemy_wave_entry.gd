extends Resource
class_name EnemyWaveEntry
## Resource class for a single enemy wave entry
## Used in LevelData to define enemy spawns with type-safe enums


enum EnemyType {
	BASIC,  # Standard enemy
	FAST,   # Fast enemy (low health, high speed)
	TANK,   # Tank enemy (high health, low speed)
}


## Enemy type (enum)
@export var enemy_type: EnemyType = EnemyType.BASIC

## Spawn point index (0-based index into LevelData.spawn_points array)
@export var spawn_point: int = 0

## Delay in seconds before this enemy spawns
@export var delay: float = 0.0


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
