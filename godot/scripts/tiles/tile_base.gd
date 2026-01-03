extends Node2D
class_name TileBase
## Base tile class - manages terrain type, occupancy, and visual state


enum TerrainType {
	OPEN,    # Buildable and crossable
	ROCK,    # Unbuildable and impassable
	VOID,    # Unbuildable but crossable (future)
}

enum OccupancyType {
	EMPTY,       # No structure
	WALL,        # Wall placed
	RUNE,        # Rune placed
	SPAWN_POINT, # Enemy spawn point
	FURNACE,     # Furnace location
}

## Grid position of this tile
var grid_position: Vector2i = Vector2i.ZERO

## Terrain type of this tile
var terrain_type: TerrainType = TerrainType.OPEN

## Current occupancy state
var occupancy: OccupancyType = OccupancyType.EMPTY

## Reference to the structure on this tile (rune, wall, etc.)
var structure: Node = null

## Whether this structure was placed by the player (vs preset by level designer)
var is_player_placed: bool = false

## The item type placed on this tile (for selling/refund lookup)
var placed_item_type: String = ""

## Visual elements
var terrain_visual: ColorRect
var overlay: ColorRect

## Highlight state
var is_highlighted: bool = false
var highlight_type: String = ""  # "buildable", "invalid", "hover", "valid_placement"


func _ready() -> void:
	# Get visual nodes (they should exist in the scene)
	terrain_visual = get_node_or_null("TerrainVisual") as ColorRect
	overlay = get_node_or_null("Overlay") as ColorRect
	_update_visuals()
	_update_position()


## Set the grid position and update world position
func set_grid_position(pos: Vector2i) -> void:
	grid_position = pos
	_update_position()


## Update world position based on grid position
func _update_position() -> void:
	position = Vector2(
		grid_position.x * GameConfig.TILE_SIZE,
		grid_position.y * GameConfig.TILE_SIZE
	)


## Set the terrain type
func set_terrain_type(type: TerrainType) -> void:
	terrain_type = type
	_update_visuals()


## Set the occupancy state
func set_occupancy(type: OccupancyType, structure_node: Node = null, player_placed: bool = false, item_type: String = "") -> void:
	occupancy = type
	structure = structure_node
	is_player_placed = player_placed
	placed_item_type = item_type
	_update_visuals()


## Clear the occupancy (for selling items)
func clear_occupancy() -> void:
	# Remove the structure node if it exists
	if structure and is_instance_valid(structure):
		structure.queue_free()
	
	occupancy = OccupancyType.EMPTY
	structure = null
	is_player_placed = false
	placed_item_type = ""
	_update_visuals()


## Check if this tile is buildable
func is_buildable() -> bool:
	# Cannot build on rock or void terrain
	if terrain_type == TerrainType.ROCK or terrain_type == TerrainType.VOID:
		return false
	
	# Cannot build if already occupied
	if occupancy != OccupancyType.EMPTY:
		return false
	
	return true


## Check if this tile is crossable (for pathfinding)
func is_crossable() -> bool:
	# Cannot cross rock terrain
	if terrain_type == TerrainType.ROCK:
		return false
	
	# Cannot cross walls
	if occupancy == OccupancyType.WALL:
		return false
	
	# Can cross open terrain, runes, spawn points, and furnace
	return true


## Set highlight state
func set_highlight(highlight: bool, type: String = "") -> void:
	is_highlighted = highlight
	highlight_type = type
	_update_visuals()


## Update visual representation
func _update_visuals() -> void:
	# Ensure we have references to visual nodes
	if not terrain_visual and is_inside_tree():
		terrain_visual = get_node_or_null("TerrainVisual") as ColorRect
	if not overlay and is_inside_tree():
		overlay = get_node_or_null("Overlay") as ColorRect
	
	if not is_inside_tree():
		return
	
	# Update terrain color
	if terrain_visual:
		match terrain_type:
			TerrainType.OPEN:
				terrain_visual.color = Color(0.55, 0.45, 0.33)  # Light brown
			TerrainType.ROCK:
				terrain_visual.color = Color(0.29, 0.29, 0.29)  # Dark gray
			TerrainType.VOID:
				terrain_visual.color = Color(0.1, 0.0, 0.2)  # Dark purple
	
	# Update overlay for highlights
	if overlay:
		if is_highlighted:
			match highlight_type:
				"buildable":
					overlay.color = Color(1.0, 1.0, 0.5, 0.3)  # Yellow tint
				"valid_placement":
					overlay.color = Color(0.3, 1.0, 0.3, 0.35)  # Green tint for valid placement
				"invalid":
					overlay.color = Color(1.0, 0.3, 0.3, 0.3)  # Red tint
				"hover":
					overlay.color = Color(1.0, 0.9, 0.5, 0.25)  # Light yellow
				_:
					overlay.color = Color(1.0, 1.0, 1.0, 0.1)  # Default highlight
		else:
			overlay.color = Color(0, 0, 0, 0)  # Transparent


## Get a string representation for debugging
func get_debug_string() -> String:
	return "Tile(%d, %d) [%s, %s]" % [
		grid_position.x,
		grid_position.y,
		TerrainType.keys()[terrain_type],
		OccupancyType.keys()[occupancy]
	]
