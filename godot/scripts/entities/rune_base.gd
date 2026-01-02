extends Node2D
class_name RuneBase
## Base class for all runes - extend this to create specific rune types


## Rune type identifier - override in subclasses
@export var rune_type: String = "base"

## Number of uses remaining (0 = infinite)
@export var uses_remaining: int = 0

## Grid position of this rune
var grid_position: Vector2i = Vector2i.ZERO

## Whether this rune has been used up
var is_depleted: bool = false

## Visual representation
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null

signal rune_activated(rune: RuneBase)
signal rune_depleted(rune: RuneBase)


func _ready() -> void:
	add_to_group("runes")
	_on_rune_ready()


## Override in subclasses for custom initialization
func _on_rune_ready() -> void:
	pass


## Called when fireball passes over this rune's tile center
## Override in subclasses to implement rune behavior
func activate(fireball: Node2D) -> void:
	if is_depleted:
		return
	
	_on_activate(fireball)
	rune_activated.emit(self)
	
	# Handle uses
	if uses_remaining > 0:
		uses_remaining -= 1
		if uses_remaining == 0:
			_on_depleted()


## Override in subclasses to implement the rune's effect
func _on_activate(_fireball: Node2D) -> void:
	pass


## Called when rune runs out of uses
func _on_depleted() -> void:
	is_depleted = true
	rune_depleted.emit(self)
	# Subclasses can override to add visual feedback


## Set the grid position and update world position
func set_grid_position(pos: Vector2i) -> void:
	grid_position = pos
	position = Vector2(
		pos.x * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2,
		pos.y * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2
	)


## Get the resource cost for this rune type
func get_cost() -> int:
	return GameConfig.get_rune_cost(rune_type)
