extends RuneBase
class_name RedirectRune
## Redirects the fireball to a fixed direction when activated


enum Direction { NORTH, SOUTH, EAST, WEST }

@export var direction: Direction = Direction.SOUTH

## Reference to the direction indicator visual
@onready var direction_indicator: ColorRect = $DirectionIndicator


func _on_rune_ready() -> void:
	rune_type = "redirect"
	_update_direction_visual()


func _on_activate(fireball: Node2D) -> void:
	# Change fireball direction based on this rune's setting
	var new_direction: Vector2
	match direction:
		Direction.NORTH:
			new_direction = Vector2.UP
		Direction.SOUTH:
			new_direction = Vector2.DOWN
		Direction.EAST:
			new_direction = Vector2.RIGHT
		Direction.WEST:
			new_direction = Vector2.LEFT
	
	# Fireball should have a set_direction method
	if fireball.has_method("set_direction"):
		fireball.set_direction(new_direction)


## Set direction using string (for UI interaction)
func set_direction_by_string(dir_string: String) -> void:
	match dir_string.to_lower():
		"north":
			direction = Direction.NORTH
		"south":
			direction = Direction.SOUTH
		"east":
			direction = Direction.EAST
		"west":
			direction = Direction.WEST
	_update_direction_visual()


## Get direction as Vector2
func get_direction_vector() -> Vector2:
	match direction:
		Direction.NORTH:
			return Vector2.UP
		Direction.SOUTH:
			return Vector2.DOWN
		Direction.EAST:
			return Vector2.RIGHT
		Direction.WEST:
			return Vector2.LEFT
	return Vector2.DOWN


## Update the visual indicator to show current direction
func _update_direction_visual() -> void:
	if not direction_indicator:
		return
	
	# Reset position and set based on direction
	# Indicator is 8x8 pixels, positioned at edge of rune
	match direction:
		Direction.NORTH:
			# Top edge, pointing up
			direction_indicator.offset_left = -4.0
			direction_indicator.offset_top = -12.0
			direction_indicator.offset_right = 4.0
			direction_indicator.offset_bottom = -4.0
		Direction.SOUTH:
			# Bottom edge, pointing down
			direction_indicator.offset_left = -4.0
			direction_indicator.offset_top = 4.0
			direction_indicator.offset_right = 4.0
			direction_indicator.offset_bottom = 12.0
		Direction.EAST:
			# Right edge, pointing right
			direction_indicator.offset_left = 4.0
			direction_indicator.offset_top = -4.0
			direction_indicator.offset_right = 12.0
			direction_indicator.offset_bottom = 4.0
		Direction.WEST:
			# Left edge, pointing left
			direction_indicator.offset_left = -12.0
			direction_indicator.offset_top = -4.0
			direction_indicator.offset_right = -4.0
			direction_indicator.offset_bottom = 4.0
