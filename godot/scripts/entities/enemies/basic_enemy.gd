extends EnemyBase
class_name BasicEnemy
## Basic enemy type - standard health and speed


func _on_enemy_ready() -> void:
	health = GameConfig.basic_enemy_health
	max_health = GameConfig.basic_enemy_health
	speed = GameConfig.basic_enemy_speed
