extends RuneBase
class_name RedirectRune
## Redirects the fireball to a fixed direction when activated


enum Direction { NORTH, SOUTH, EAST, WEST }

@export var direction: Direction = Direction.SOUTH


func _on_rune_ready() -> void:
	rune_type = "redirect"


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
