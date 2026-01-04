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
	# Check if we have a linked portal
	if not linked_portal or not is_instance_valid(linked_portal):
		print("PortalRune: No linked portal!")
		return
	
	# Check if fireball is a Fireball instance
	if not fireball is Fireball:
		return
	
	var fireball_instance := fireball as Fireball
	
	# Prevent infinite teleport loop: don't teleport if the destination portal
	# is the same as the last portal the fireball teleported to
	if fireball_instance.last_destination_portal == linked_portal.grid_position:
		return
	
	# Calculate destination position (center of linked portal tile)
	var destination_position := Vector2(
		linked_portal.grid_position.x * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0,
		linked_portal.grid_position.y * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0
	)
	
	# Get fireball's current direction to maintain it through the portal
	var fireball_direction: Vector2 = fireball_instance.direction if "direction" in fireball_instance else Vector2.DOWN
	
	# Teleport fireball, maintaining its current direction
	# Pass the destination portal's grid position so it can track it
	if fireball_instance.has_method("teleport_to"):
		fireball_instance.teleport_to(destination_position, fireball_direction, linked_portal.grid_position)
	
	# Play activation sound (use accelerate sound for portal teleportation)
	AudioManager.play_sound_effect("rune-accelerate")
	
	# Play teleport effects on both portals
	_play_teleport_effect()
	linked_portal._play_teleport_effect()


## Get direction as Vector2 (kept for backwards compatibility with existing levels)
## Note: Direction is no longer used for entry/exit restrictions - fireball maintains its direction
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


## Update portal visual - use the same visual for both entry and exit portals
func _update_portal_visual() -> void:
	var visual := get_node_or_null("RuneVisual") as ColorRect
	if visual:
		# Use the same color for both entry and exit portals
		visual.color = Color(0.6, 0.2, 0.9, 1.0)


## Update portal sprite - use rune-magic sprite for all portals
func _update_portal_sprite() -> void:
	if not sprite:
		return
	
	# Use rune-magic sprite for all portals (entry and exit)
	var sprite_path: String = "res://assets/sprites/rune-magic.png"
	
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
