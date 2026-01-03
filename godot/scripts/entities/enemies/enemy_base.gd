extends CharacterBody2D
class_name EnemyBase
## Base class for all enemies - handles movement, health, and pathfinding


signal died
signal reached_furnace

## Current health
@export var health: int = 50

## Maximum health
@export var max_health: int = 50

## Movement speed in pixels per second
@export var speed: float = 50.0

## Current path to follow (array of grid positions)
var current_path: Array[Vector2i] = []

## Current index in the path
var current_path_index: int = 0

## Grid position (updated as enemy moves)
var grid_position: Vector2i = Vector2i.ZERO

## Whether the enemy is currently moving
var is_active: bool = false

## Reference to health bar node (if present)
@onready var health_bar: EnemyHealthBar = $HealthBar


func _ready() -> void:
	# Configure collision layers so enemies don't collide with each other
	# Enemies are on layer 1, but don't check for collisions (mask = 0)
	# This allows enemies to pass through each other while still being detectable by Area2D
	collision_layer = 1
	collision_mask = 0
	
	# Call subclass initialization first so it can set health/max_health/speed
	_on_enemy_ready()
	# Then set max_health to health if max_health wasn't explicitly set
	if max_health == 50:  # Still default value
		max_health = health
	add_to_group("enemies")
	
	# Initialize health bar if present
	if health_bar:
		health_bar.update_health(health, max_health)


## Override in subclasses for custom initialization
func _on_enemy_ready() -> void:
	pass


## Set the path for this enemy to follow
func set_path(path: Array[Vector2i]) -> void:
	current_path = path
	current_path_index = 0
	is_active = path.size() > 0
	
	if is_active and path.size() > 0:
		# Set initial position to first path node
		var start_pos := _grid_to_world(path[0])
		position = start_pos
		grid_position = path[0]


## Take damage from fireball or explosion
func take_damage(amount: int) -> void:
	health -= amount
	
	# Update health bar if present
	if health_bar:
		health_bar.update_health(health, max_health)
	
	if health <= 0:
		_die()
	else:
		_on_damaged(amount)


## Called when enemy takes damage (override for visual feedback)
func _on_damaged(_amount: int) -> void:
	# Flash red or play hit animation
	# Health bar is already updated in take_damage()
	pass


## Handle enemy death
func _die() -> void:
	health = 0
	is_active = false
	died.emit()
	_on_death()
	queue_free()


## Override in subclasses for death effects
func _on_death() -> void:
	# Play death animation, spawn particles, etc.
	pass


## Called when enemy reaches the furnace
func _on_furnace_reached() -> void:
	is_active = false
	reached_furnace.emit()
	queue_free()


func _physics_process(_delta: float) -> void:
	if not is_active or current_path.is_empty():
		return
	
	# Check if we've reached the current path node
	var target_pos := _grid_to_world(current_path[current_path_index])
	var distance_to_target := position.distance_to(target_pos)
	
	# Move toward current target
	if distance_to_target > 2.0:  # Small threshold for "reached"
		var direction := (target_pos - position).normalized()
		velocity = direction * speed
		move_and_slide()
	else:
		# Reached current node, move to next
		current_path_index += 1
		
		# Check if we've reached the end (furnace)
		if current_path_index >= current_path.size():
			_on_furnace_reached()
			return
		
		# Update grid position
		if current_path_index < current_path.size():
			grid_position = current_path[current_path_index]


## Get current grid position (for fireball collision detection)
func get_grid_position() -> Vector2i:
	return grid_position


## Convert grid position to world position (tile center)
func _grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0,
		grid_pos.y * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0
	)
