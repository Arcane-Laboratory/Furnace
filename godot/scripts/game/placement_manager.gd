extends Node
class_name PlacementManager
## Manages item placement during build phase - selection, validation, and execution


## Emitted when placement fails (for error snackbar)
signal placement_failed(reason: String)

## Emitted when placement succeeds
signal placement_succeeded(item_type: String, grid_pos: Vector2i)

## Emitted when an item is sold
signal item_sold(item_type: String, grid_pos: Vector2i, refund_amount: int)

## Emitted when selection changes
signal selection_changed(item_type: String)


## Currently selected item type (empty if none)
var selected_item_type: String = ""

## Reference to the game board for coordinate conversion
var game_board: Node2D = null

## Reference to the build submenu
var build_submenu: Control = null

## Reference to the runes container (where placed items go)
var runes_container: Node2D = null

## Ghost preview node for showing placement preview
var ghost_preview: Node2D = null

## Reference to level data (for pathfinding validation)
var level_data: LevelData = null


func _ready() -> void:
	pass


## Initialize with required node references
func initialize(board: Node2D, submenu: Control, runes_node: Node2D, p_level_data: LevelData = null) -> void:
	game_board = board
	build_submenu = submenu
	runes_container = runes_node
	level_data = p_level_data
	
	# Connect to build submenu selection changes
	if build_submenu and build_submenu.has_signal("item_selection_changed"):
		build_submenu.item_selection_changed.connect(_on_item_selection_changed)


## Set level data (can be called after initialize)
func set_level_data(p_level_data: LevelData) -> void:
	level_data = p_level_data


## Set the selected item type
func set_selected_item(item_type: String) -> void:
	selected_item_type = item_type
	selection_changed.emit(item_type)
	
	# Clear ghost preview when deselecting
	if item_type.is_empty():
		_clear_ghost_preview()


## Clear the current selection
func clear_selection() -> void:
	selected_item_type = ""
	_clear_ghost_preview()
	
	if build_submenu and build_submenu.has_method("clear_selection"):
		build_submenu.clear_selection()
	
	selection_changed.emit("")


## Check if an item is currently selected
func has_selection() -> bool:
	return not selected_item_type.is_empty()


## Get the currently selected item definition
func get_selected_definition() -> Resource:
	if selected_item_type.is_empty():
		return null
	return GameConfig.get_item_definition(selected_item_type)


## Validate if placement is allowed at position
func can_place_at(grid_pos: Vector2i) -> bool:
	# Check if tile is buildable
	if not TileManager.is_buildable(grid_pos):
		return false
	
	# Check if player has enough money
	var definition := get_selected_definition()
	if not definition:
		return false
	
	if GameManager.resources < definition.cost:
		return false
	
	# Check if this would block all paths (only for path-blocking items)
	if definition.blocks_path:
		if would_block_all_paths(grid_pos):
			return false
	
	return true


## Check if placing a path-blocking item at this position would block all spawn paths
func would_block_all_paths(grid_pos: Vector2i) -> bool:
	if not level_data:
		return false  # Can't validate without level data, allow placement
	
	# Temporarily mark the tile as a wall to test pathfinding
	var tile := TileManager.get_tile(grid_pos)
	if not tile:
		return false
	
	# Save original state
	var original_occupancy := tile.occupancy
	var original_structure := tile.structure
	var original_player_placed := tile.is_player_placed
	var original_item_type := tile.placed_item_type
	
	# Temporarily set as wall (blocks path)
	tile.occupancy = TileBase.OccupancyType.WALL
	
	# Check if all spawn points can still reach the furnace
	var all_paths_valid := true
	for spawn_pos in level_data.spawn_points:
		var path := PathfindingManager.find_path(spawn_pos, level_data.furnace_position)
		if path.is_empty():
			all_paths_valid = false
			break
	
	# Restore original state
	tile.occupancy = original_occupancy
	tile.structure = original_structure
	tile.is_player_placed = original_player_placed
	tile.placed_item_type = original_item_type
	
	return not all_paths_valid


## Attempt to place the selected item at a grid position
func try_place_item(grid_pos: Vector2i) -> bool:
	if selected_item_type.is_empty():
		placement_failed.emit("No item selected")
		return false
	
	var definition := get_selected_definition()
	if not definition:
		placement_failed.emit("Invalid item type")
		return false
	
	# Check if tile is buildable
	if not TileManager.is_buildable(grid_pos):
		placement_failed.emit("Cannot build here")
		return false
	
	# Check if player has enough money
	if GameManager.resources < definition.cost:
		placement_failed.emit("Not enough money!")
		return false
	
	# Check if this would block all paths (only for path-blocking items)
	if definition.blocks_path:
		if would_block_all_paths(grid_pos):
			placement_failed.emit("Would block all paths!")
			return false
	
	# Execute placement
	var success := _execute_placement(grid_pos, definition)
	if success:
		placement_succeeded.emit(selected_item_type, grid_pos)
	
	return success


## Execute the actual placement
func _execute_placement(grid_pos: Vector2i, definition: Resource) -> bool:
	# Spend resources
	if not GameManager.spend_resources(definition.cost):
		placement_failed.emit("Not enough money!")
		return false
	
	# Determine occupancy type based on item
	var occupancy_type: TileBase.OccupancyType
	if definition.item_type == "wall":
		occupancy_type = TileBase.OccupancyType.WALL
	else:
		occupancy_type = TileBase.OccupancyType.RUNE
	
	# Create structure node
	var structure_node: Node = null
	if not definition.scene_path.is_empty():
		# Load from scene
		var scene := load(definition.scene_path) as PackedScene
		if scene:
			structure_node = scene.instantiate()
	
	# If no scene or scene failed to load, create a fallback visual
	if not structure_node:
		structure_node = _create_fallback_visual(definition)
	
	# Add to scene and position
	if structure_node and runes_container:
		runes_container.add_child(structure_node)
		
		# Set grid position for runes (required for fireball collision detection)
		if structure_node is RuneBase:
			(structure_node as RuneBase).set_grid_position(grid_pos)
		elif structure_node is Node2D:
			# For non-rune items (like walls), just set world position
			(structure_node as Node2D).position = Vector2(
				grid_pos.x * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0,
				grid_pos.y * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0
			)
	
	# Update tile occupancy (mark as player-placed)
	TileManager.set_occupancy(grid_pos, occupancy_type, structure_node, true, definition.item_type)
	
	return true


## Create a fallback visual for items without a scene
func _create_fallback_visual(definition: Resource) -> Node2D:
	var visual := Node2D.new()
	visual.name = "PlacedItem_%s" % definition.item_type
	
	# Create a colored rectangle as placeholder
	var rect := ColorRect.new()
	var size := Vector2(GameConfig.TILE_SIZE - 4, GameConfig.TILE_SIZE - 4)
	rect.size = size
	rect.position = -size / 2.0
	rect.color = definition.icon_color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visual.add_child(rect)
	
	# Add a simple icon/label to indicate the item type
	var label := Label.new()
	label.text = definition.item_type.substr(0, 1).to_upper()  # First letter
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = size
	label.position = -size / 2.0
	label.add_theme_color_override("font_color", Color.WHITE)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visual.add_child(label)
	
	return visual


## Attempt to sell an item at a grid position
func try_sell_item(grid_pos: Vector2i) -> bool:
	# Check if tile has a player-placed item
	if not TileManager.can_sell_tile(grid_pos):
		return false
	
	# Get the item type for refund calculation
	var item_type := TileManager.get_placed_item_type(grid_pos)
	var definition := GameConfig.get_item_definition(item_type)
	
	if not definition:
		return false
	
	# Calculate refund (100% of cost)
	var refund_amount: int = definition.cost
	
	# Clear the tile
	TileManager.clear_tile(grid_pos)
	
	# Add resources back
	GameManager.add_resources(refund_amount)
	
	item_sold.emit(item_type, grid_pos, refund_amount)
	return true


## Update ghost preview at a grid position
func update_ghost_preview(grid_pos: Vector2i) -> void:
	if selected_item_type.is_empty():
		_clear_ghost_preview()
		return
	
	var definition := get_selected_definition()
	if not definition:
		_clear_ghost_preview()
		return
	
	# Create ghost preview if it doesn't exist
	if not ghost_preview:
		_create_ghost_preview(definition)
	
	if ghost_preview:
		# Position at tile
		ghost_preview.position = Vector2(
			grid_pos.x * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0,
			grid_pos.y * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0
		)
		ghost_preview.visible = true
		
		# Update opacity based on validity
		if can_place_at(grid_pos):
			ghost_preview.modulate.a = 0.5
		else:
			ghost_preview.modulate.a = 0.25


## Create ghost preview from item definition
func _create_ghost_preview(definition: Resource) -> void:
	_clear_ghost_preview()
	
	# Try to load the scene for preview
	if not definition.scene_path.is_empty():
		var scene := load(definition.scene_path) as PackedScene
		if scene:
			var instance := scene.instantiate()
			if instance is Node2D:
				ghost_preview = instance as Node2D
				if ghost_preview and runes_container:
					ghost_preview.modulate.a = 0.5
					runes_container.add_child(ghost_preview)
					return
			else:
				# If it's not a Node2D, free it
				instance.queue_free()
	
	# Fallback: create a simple colored rect preview
	ghost_preview = Node2D.new()
	var rect := ColorRect.new()
	rect.size = Vector2(GameConfig.TILE_SIZE - 4, GameConfig.TILE_SIZE - 4)
	rect.position = -rect.size / 2
	rect.color = definition.icon_color
	rect.color.a = 0.5
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ghost_preview.add_child(rect)
	
	if runes_container:
		runes_container.add_child(ghost_preview)


## Clear the ghost preview
func _clear_ghost_preview() -> void:
	if ghost_preview and is_instance_valid(ghost_preview):
		ghost_preview.queue_free()
	ghost_preview = null


## Hide the ghost preview (without destroying it)
func hide_ghost_preview() -> void:
	if ghost_preview:
		ghost_preview.visible = false


## Handle selection changes from build submenu
func _on_item_selection_changed(item_type: String) -> void:
	selected_item_type = item_type
	
	if item_type.is_empty():
		_clear_ghost_preview()
	
	selection_changed.emit(item_type)


## Convert screen position to grid position
func screen_to_grid(screen_pos: Vector2) -> Vector2i:
	if not game_board:
		return Vector2i(-1, -1)
	
	var local_pos := screen_pos - game_board.global_position
	var cell_x := int(local_pos.x / GameConfig.TILE_SIZE)
	var cell_y := int(local_pos.y / GameConfig.TILE_SIZE)
	
	# Validate bounds
	if cell_x < 0 or cell_x >= GameConfig.GRID_COLUMNS:
		return Vector2i(-1, -1)
	if cell_y < 0 or cell_y >= GameConfig.GRID_ROWS:
		return Vector2i(-1, -1)
	
	return Vector2i(cell_x, cell_y)


## Check if a grid position is valid
func is_valid_grid_pos(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < GameConfig.GRID_COLUMNS \
		and grid_pos.y >= 0 and grid_pos.y < GameConfig.GRID_ROWS
