extends Node2D
class_name MudTile
## Tile that slows enemies on top of it by 50%


var grid_position: Vector2i = Vector2i.ZERO


func _ready() -> void:
	add_to_group("mud_tiles")


func set_grid_position(pos: Vector2i) -> void:
	grid_position = pos
	position = Vector2(
		pos.x * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0,
		pos.y * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0
	)
	# Set z_index below runes and walls but above base tiles
	z_index = -1
