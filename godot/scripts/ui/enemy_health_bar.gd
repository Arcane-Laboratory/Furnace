extends Control
class_name EnemyHealthBar
## Health bar that displays above enemies, showing current health as a percentage

## Size of the health bar
const BAR_WIDTH: int = 24
const BAR_HEIGHT: int = 4

## Offset above the enemy sprite
const OFFSET_Y: float = -20.0

## Current health percentage (0.0 to 1.0)
var health_percentage: float = 1.0

## Reference to the enemy node (parent CharacterBody2D)
var enemy: CharacterBody2D


func _ready() -> void:
	# Set size and position
	custom_minimum_size = Vector2(BAR_WIDTH, BAR_HEIGHT)
	size = Vector2(BAR_WIDTH, BAR_HEIGHT)
	
	# Get reference to parent enemy
	enemy = get_parent() as CharacterBody2D
	
	# Initially hide if at full health
	visible = false
	
	# Set initial position
	_update_position()


func _process(_delta: float) -> void:
	# Keep health bar positioned above enemy
	if enemy:
		_update_position()


## Update health bar based on current and max health
func update_health(current: int, max_hp: int) -> void:
	if max_hp <= 0:
		health_percentage = 0.0
	else:
		health_percentage = float(current) / float(max_hp)
	
	# Show health bar only when damaged (health < max)
	visible = current < max_hp
	
	# Trigger redraw
	queue_redraw()


## Update position to stay above enemy
func _update_position() -> void:
	if not enemy:
		return
	
	# Position above enemy sprite, centered horizontally
	position = Vector2(
		-BAR_WIDTH / 2.0,
		OFFSET_Y
	)


## Draw the health bar
func _draw() -> void:
	# Draw background (dark gray/black)
	var bg_rect := Rect2(0, 0, BAR_WIDTH, BAR_HEIGHT)
	draw_rect(bg_rect, Color(0.1, 0.1, 0.1, 0.8))
	
	# Draw foreground (health bar)
	var health_width := BAR_WIDTH * health_percentage
	var health_rect := Rect2(0, 0, health_width, BAR_HEIGHT)
	
	# Color based on health percentage
	var health_color: Color
	if health_percentage > 0.6:
		# Green when healthy (>60%)
		health_color = Color(0.2, 0.8, 0.2, 1.0)
	elif health_percentage > 0.3:
		# Yellow when moderate (30-60%)
		health_color = Color(0.8, 0.8, 0.2, 1.0)
	else:
		# Red when low (<30%)
		health_color = Color(0.8, 0.2, 0.2, 1.0)
	
	draw_rect(health_rect, health_color)
