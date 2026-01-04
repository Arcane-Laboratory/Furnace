extends RuneBase
class_name RedirectRune
## Redirects the fireball to a fixed direction when activated
## Level 1: Direction can only be changed during build phase
## Level 2: Direction can be changed during active phase (like Advanced Redirect)


enum Direction { NORTH, SOUTH, EAST, WEST }

@export var direction: Direction = Direction.SOUTH

## Reference to the direction indicator visual
@onready var direction_indicator: ColorRect = $DirectionIndicator

## Reference to optional level indicator
var level_indicator: ColorRect = null


func _on_rune_ready() -> void:
	rune_type = "redirect"
	_update_direction_visual()
	_update_level_visual()
	# Update sprite rotation after a frame to ensure sprite node is ready
	call_deferred("_update_sprite_rotation")


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
	# Update sprite rotation (deferred to ensure sprite is ready)
	call_deferred("_update_sprite_rotation")


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


## Update visual indicator for current level
func _update_level_visual() -> void:
	# Add corner markers for level 2+ to visually distinguish
	if current_level >= 2:
		if not level_indicator:
			level_indicator = ColorRect.new()
			level_indicator.name = "LevelIndicator"
			add_child(level_indicator)
		
		# Small marker in corner to indicate upgraded
		level_indicator.offset_left = -12.0
		level_indicator.offset_top = -12.0
		level_indicator.offset_right = -8.0
		level_indicator.offset_bottom = -8.0
		level_indicator.color = Color(0.2, 0.2, 0.2, 1.0)
		level_indicator.visible = true
	elif level_indicator:
		level_indicator.visible = false


## Override: Called when rune is upgraded
func _on_upgrade(new_level: int) -> void:
	_update_level_visual()
	print("RedirectRune upgraded to level %d" % new_level)


## Override: Level 2 redirect runes can be edited during active phase
func is_editable_in_active_phase() -> bool:
	return current_level >= 2


## Update sprite rotation based on direction
func _update_sprite_rotation() -> void:
	# Get sprite node directly from the scene tree
	var sprite_node := get_node_or_null("Sprite2D") as Sprite2D
	if not sprite_node:
		# Try using the sprite from parent class if direct access fails
		if sprite:
			sprite_node = sprite
		else:
			return
	
	# Rotate sprite to face the direction
	# Sprite asset has base rotation of -90 degrees (90° clockwise) in scene file
	# Base rotation makes sprite face WEST. Add rotation relative to that.
	# Base rotation: -90° (sprite faces WEST after base rotation)
	match direction:
		Direction.NORTH:
			sprite_node.rotation_degrees = -90.0 + 90.0  # = 0° (rotate 90° CCW from base to face north)
		Direction.SOUTH:
			sprite_node.rotation_degrees = -90.0 + (-90.0)  # = -180° (rotate 90° CW from base to face south)
		Direction.EAST:
			sprite_node.rotation_degrees = -90.0 + 180.0  # = 90° (rotate 180° from base to face east)
		Direction.WEST:
			sprite_node.rotation_degrees = -90.0  # Base rotation (face west)
