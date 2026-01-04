extends Node
## Autoload class for managing tile grid state and queries

signal occupancy_changed(grid_pos: Vector2i)

## Dictionary mapping grid positions to tile instances
var tiles: Dictionary = {}

## Current level data
var current_level_data: LevelData = null


func _ready() -> void:
	pass


## Initialize grid from level data
func initialize_from_level_data(level_data: LevelData) -> void:
	current_level_data = level_data
	clear_grid()
	
	# Create tiles for all grid positions
	for x in range(GameConfig.GRID_COLUMNS):
		for y in range(GameConfig.GRID_ROWS):
			var grid_pos := Vector2i(x, y)
			var tile := _create_tile_for_position(grid_pos, level_data)
			if tile:
				register_tile(grid_pos, tile)


## Create appropriate tile type for a position based on level data
func _create_tile_for_position(grid_pos: Vector2i, level_data: LevelData) -> TileBase:
	# Check if this is blocked terrain (rock)
	if grid_pos in level_data.terrain_blocked:
		var rock_scene := load("res://scenes/tiles/terrain_rock.tscn")
		if not rock_scene:
			push_error("Failed to load terrain_rock.tscn")
			return null
		var rock_tile_node: Node = rock_scene.instantiate()
		if not rock_tile_node:
			push_error("Failed to instantiate terrain_rock.tscn")
			return null
		var rock_tile := rock_tile_node as TileBase
		if not rock_tile:
			push_error("Instantiated node is not a TileBase: %s" % rock_tile_node.get_class())
			return null
		return rock_tile
	
	# Default to open terrain
	var open_scene := load("res://scenes/tiles/terrain_open.tscn")
	if not open_scene:
		push_error("Failed to load terrain_open.tscn")
		return null
	var open_tile_node: Node = open_scene.instantiate()
	if not open_tile_node:
		push_error("Failed to instantiate terrain_open.tscn")
		return null
	var open_tile := open_tile_node as TileBase
	if not open_tile:
		push_error("Instantiated node is not a TileBase: %s" % open_tile_node.get_class())
		return null
	return open_tile


## Register a tile at a grid position
func register_tile(grid_pos: Vector2i, tile: TileBase) -> void:
	tiles[grid_pos] = tile
	
	# Set occupancy based on level data if available
	if current_level_data:
		_update_tile_occupancy_from_level_data(grid_pos, tile)


## Update tile occupancy from level data (presets are not player-placed)
func _update_tile_occupancy_from_level_data(grid_pos: Vector2i, tile: TileBase) -> void:
	if not current_level_data:
		return
	
	# Check for preset walls (not player-placed)
	if grid_pos in current_level_data.preset_walls:
		tile.set_occupancy(TileBase.OccupancyType.WALL, null, false, "wall")
		return
	
	# Check for preset runes (not player-placed)
	for rune_data in current_level_data.preset_runes:
		if rune_data.get("position") == grid_pos:
			var rune_type: String = rune_data.get("type", "")
			tile.set_occupancy(TileBase.OccupancyType.RUNE, null, false, rune_type)
			return
	
	# Check for spawn points
	if grid_pos in current_level_data.spawn_points:
		tile.set_occupancy(TileBase.OccupancyType.SPAWN_POINT)
		return
	
	# Check for furnace position
	# Note: Furnace is off-grid, so we don't mark the tile as FURNACE occupancy
	# This allows building on the tile in front of the furnace
	# if grid_pos == current_level_data.furnace_position:
	#	tile.set_occupancy(TileBase.OccupancyType.FURNACE)
	#	return


## Get tile at grid position
func get_tile(grid_pos: Vector2i) -> TileBase:
	return tiles.get(grid_pos)


## Check if a position is buildable
func is_buildable(grid_pos: Vector2i) -> bool:
	var tile := get_tile(grid_pos)
	if not tile:
		return false
	
	return tile.is_buildable()


## Check if a position is crossable (for pathfinding)
func is_crossable(grid_pos: Vector2i) -> bool:
	# Check bounds
	if grid_pos.x < 0 or grid_pos.x >= GameConfig.GRID_COLUMNS:
		return false
	if grid_pos.y < 0 or grid_pos.y >= GameConfig.GRID_ROWS:
		return false
	
	var tile := get_tile(grid_pos)
	if not tile:
		return false
	
	return tile.is_crossable()


## Set occupancy at a position (for player-placed items)
func set_occupancy(grid_pos: Vector2i, occupancy_type: TileBase.OccupancyType, structure: Node = null, player_placed: bool = true, item_type: String = "") -> void:
	var tile := get_tile(grid_pos)
	if tile:
		tile.set_occupancy(occupancy_type, structure, player_placed, item_type)
		occupancy_changed.emit(grid_pos)


## Clear a tile's occupancy (for selling items)
## Returns the item_type that was cleared (for refund calculation)
func clear_tile(grid_pos: Vector2i) -> String:
	var tile := get_tile(grid_pos)
	if not tile:
		return ""
	
	var item_type := tile.placed_item_type
	tile.clear_occupancy()
	occupancy_changed.emit(grid_pos)
	return item_type


## Check if a tile has a player-placed item that can be sold
func can_sell_tile(grid_pos: Vector2i) -> bool:
	var tile := get_tile(grid_pos)
	if not tile:
		return false
	
	return tile.is_player_placed and tile.occupancy != TileBase.OccupancyType.EMPTY


## Get the item type placed on a tile
func get_placed_item_type(grid_pos: Vector2i) -> String:
	var tile := get_tile(grid_pos)
	if not tile:
		return ""
	return tile.placed_item_type


## Clear the grid
func clear_grid() -> void:
	for tile in tiles.values():
		if is_instance_valid(tile):
			tile.queue_free()
	tiles.clear()


## Get all tiles
func get_all_tiles() -> Array:
	return tiles.values()


## Get tiles matching a condition
func get_tiles_matching(condition: Callable) -> Array:
	var matching: Array = []
	for tile in tiles.values():
		if condition.call(tile):
			matching.append(tile)
	return matching


## Highlight tiles matching a condition
func highlight_tiles(condition: Callable, highlight_type: String = "buildable") -> void:
	for tile in tiles.values():
		if condition.call(tile):
			tile.set_highlight(true, highlight_type)
		else:
			tile.set_highlight(false)


## Clear all highlights
func clear_highlights() -> void:
	for tile in tiles.values():
		tile.set_highlight(false)
