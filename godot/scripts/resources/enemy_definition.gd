extends Resource
class_name EnemyDefinition
## Resource definition for enemy types
## Designers can create .tres files from this resource to configure each enemy type


@export var enemy_type: String = ""  # e.g., "basic", "fast", "tank"
@export var display_name: String = ""  # e.g., "Basic Enemy"
@export var health: int = 50
@export var speed: float = 50.0  # pixels per second
@export var scene_path: String = ""  # Path to the scene file (e.g., "res://scenes/entities/enemies/basic_enemy.tscn")
@export var color: Color = Color.WHITE  # Visual color for this enemy type
@export var introduction_level: int = 1  # Which level this enemy type is first introduced


func _init(
	p_enemy_type: String = "",
	p_display_name: String = "",
	p_health: int = 50,
	p_speed: float = 50.0,
	p_scene_path: String = "",
	p_color: Color = Color.WHITE,
	p_introduction_level: int = 1
) -> void:
	enemy_type = p_enemy_type
	display_name = p_display_name
	health = p_health
	speed = p_speed
	scene_path = p_scene_path
	color = p_color
	introduction_level = p_introduction_level
