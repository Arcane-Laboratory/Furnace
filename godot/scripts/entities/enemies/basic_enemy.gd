extends EnemyBase
class_name BasicEnemy
## Basic enemy type - standard health and speed
## Stats are configured via EnemyDefinition resource (basic_enemy_definition.tres)
## Falls back to GameConfig values for backward compatibility


func _on_enemy_ready() -> void:
	# Only set default stats if EnemyManager hasn't already set them from definition
	# EnemyManager will set stats after _ready() completes, so this is just a fallback
	# for cases where enemies are instantiated directly (not via EnemyManager)
	if health == 50 and speed == 50.0:  # Still at default values
		var definition := GameConfig.get_enemy_definition("basic")
		if definition:
			health = definition.health
			max_health = definition.health
			speed = definition.speed
		else:
			# Fallback to GameConfig for backward compatibility
			health = GameConfig.basic_enemy_health
			max_health = GameConfig.basic_enemy_health
			speed = GameConfig.basic_enemy_speed
