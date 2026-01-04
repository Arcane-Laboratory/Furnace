extends RuneBase
class_name PortalRune
## Portal rune - teleports fireball from entrance to exit


enum Direction { NORTH, SOUTH, EAST, WEST }

## Whether this is a portal entrance (true) or exit (false)
@export var is_entrance: bool = true

## The configured direction for this portal
## Entrance: only activates when fireball enters FROM this direction
## Exit: fireball exits IN this direction
@export var direction: Direction = Direction.SOUTH

## Reference to the linked portal (entrance links to exit, exit links to entrance)
var linked_portal: PortalRune = null

## Reference to the direction indicator visual
@onready var direction_indicator: ColorRect = $DirectionIndicator


func _on_rune_ready() -> void:
	rune_type = "portal"
	_update_direction_visual()
	_update_portal_visual()
	# Up5date sprite after a frame to ensure sprite node is ready
	call_deferred("_update_portal_sprite")


func _on_activate(fireball: Node2D) -> void:
	# Check if fireball is traveling FROM the configured direction
	# Entrance: fireball comes FROM entrance direction (opposite to configured direction)
	# Exit: fireball comes FROM exit direction (opposite to configured direction, i.e., traveling INTO exit)
	if not _is_fireball_from_configured_direction(fireball):
		return
	
	# Check if we have a linked portal
	if not linked_portal or not is_instance_valid(linked_portal):
		print("PortalRune: No linked portal!")
		return
	
	# Calculate destination position (center of linked portal tile)
	var destination_position := Vector2(
		linked_portal.grid_position.x * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0,
		linked_portal.grid_position.y * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0
	)
	
	# Get exit direction from destination portal
	var exit_direction := linked_portal.get_direction_vector()
	
	# Teleport fireball
	if fireball.has_method("teleport_to"):
		fireball.teleport_to(destination_position, exit_direction)
	
	# Play teleport effects on both portals
	_play_teleport_effect()
	linked_portal._play_teleport_effect()


## Check if the fireball is traveling FROM the configured portal direction
## Works for both entrance and exit portals:
## - Entrance configured as NORTH: fireball should be traveling SOUTH (coming from north)
## - Exit configured as SOUTH: fireball should be traveling NORTH (coming from south, going back through exit)
func _is_fireball_from_configured_direction(fireball: Node2D) -> bool:
	# Get current fireball direction
	var fireball_direction: Vector2 = fireball.direction
	
	# Get the configured portal direction
	var portal_direction := get_direction_vector()
	
	# Fireball direction should be OPPOSITE to portal direction
	# This means fireball is coming FROM the portal direction
	return fireball_direction == -portal_direction


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
	_update_portal_sprite()


## Link this portal to another portal
func link_to(other_portal: PortalRune) -> void:
	linked_portal = other_portal
	other_portal.linked_portal = self


## Update the visual indicator to show current direction
func _update_direction_visual() -> void:
	if not direction_indicator:
		return
	
	# Hide direction indicator
	direction_indicator.visible = false
	return
	
	# Reset position and set based on direction
	# Indicator is 8x8 pixels, positioned at edge of rune
	match direction:
		Direction.NORTH:
			direction_indicator.offset_left = -4.0
			direction_indicator.offset_top = -12.0
			direction_indicator.offset_right = 4.0
			direction_indicator.offset_bottom = -4.0
		Direction.SOUTH:
			direction_indicator.offset_left = -4.0
			direction_indicator.offset_top = 4.0
			direction_indicator.offset_right = 4.0
			direction_indicator.offset_bottom = 12.0
		Direction.EAST:
			direction_indicator.offset_left = 4.0
			direction_indicator.offset_top = -4.0
			direction_indicator.offset_right = 12.0
			direction_indicator.offset_bottom = 4.0
		Direction.WEST:
			direction_indicator.offset_left = -12.0
			direction_indicator.offset_top = -4.0
			direction_indicator.offset_right = -4.0
			direction_indicator.offset_bottom = 4.0


## Update portal visual based on entrance/exit type
func _update_portal_visual() -> void:
	var visual := get_node_or_null("RuneVisual") as ColorRect
	if visual:
		if is_entrance:
			# Entrance portal - darker purple
			visual.color = Color(0.5, 0.15, 0.75, 1.0)
		else:
			# Exit portal - lighter purple
			visual.color = Color(0.7, 0.3, 0.95, 1.0)


## Update portal sprite based on direction
func _update_portal_sprite() -> void:
	if not sprite:
		return
	
	# Load the appropriate directional sprite
	var sprite_path: String
	match direction:
		Direction.NORTH:
			sprite_path = "res://assets/sprites/portal-up.png"
		Direction.SOUTH:
			sprite_path = "res://assets/sprites/portal-down.png"
		Direction.EAST:
			sprite_path = "res://assets/sprites/portal-right.png"
		Direction.WEST:
			sprite_path = "res://assets/sprites/portal-left.png"
	
	var texture := load(sprite_path) as Texture2D
	if texture:
		sprite.texture = texture
		# Position sprite so bottom aligns with tile bottom (for taller sprites)
		# Sprite is taller than tile, so offset upward by half the extra height
		var sprite_height := texture.get_height()
		var tile_height := GameConfig.TILE_SIZE
		var offset_y := (sprite_height - tile_height) / 2.0
		sprite.position = Vector2(0, -offset_y)


## Play teleport effect
func _play_teleport_effect() -> void:
	var visual := get_node_or_null("RuneVisual") as ColorRect
	if not visual:
		return
	
	# Flash effect
	var original_color := visual.color
	visual.color = Color.WHITE
	
	var tween := create_tween()
	tween.tween_property(visual, "color", original_color, 0.3)
