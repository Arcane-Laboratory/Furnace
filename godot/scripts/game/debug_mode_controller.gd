extends Node
class_name DebugModeController
## Handles all debug-mode functionality: spawn point/terrain placement, level export


## Emitted when info snackbar should be shown
signal show_info_requested(message: String)

## Emitted when info snackbar should be hidden
signal hide_info_requested()

## Emitted when error snackbar should be shown
signal show_error_requested(message: String)

## Emitted when level should be reloaded (after save)
signal reload_level_requested(level_number: int)

## Emitted when a structure should be removed from the game board
signal structure_removal_requested(grid_pos: Vector2i)


## Debug placement mode (for placing spawn points, terrain, etc.)
enum DebugPlacementMode { NONE, SPAWN_POINT, TERRAIN }
var debug_placement_mode: DebugPlacementMode = DebugPlacementMode.NONE

## Debug-placed spawn points (additional spawn points placed by editor)
var debug_spawn_points: Array[Vector2i] = []

## Debug-placed terrain tiles (additional terrain placed by editor)
var debug_terrain_tiles: Array[Vector2i] = []

## Removed original spawn points (from level data)
var removed_spawn_points: Array[Vector2i] = []

## Removed original terrain tiles (from level data)
var removed_terrain_tiles: Array[Vector2i] = []

## Removed original walls (from level data or player-placed)
var removed_walls: Array[Vector2i] = []

## Removed original runes (from level data or player-placed)
var removed_runes: Array[Vector2i] = []

## Level export dialog
var level_export_dialog: LevelExportDialog = null

## Debug FAB button
var debug_fab: Button = null

## Debug modal
var debug_modal: DebugModal = null

## References injected from game_scene
var ui_layer: CanvasLayer = null
var game_board: Node2D = null
var spawn_points_container: Node2D = null
var current_level_data: LevelData = null


func _ready() -> void:
	pass


## Initialize with required node references
func initialize(p_ui_layer: CanvasLayer, p_game_board: Node2D, p_spawn_points_container: Node2D, p_level_data: LevelData) -> void:
	ui_layer = p_ui_layer
	game_board = p_game_board
	spawn_points_container = p_spawn_points_container
	current_level_data = p_level_data
	
	_create_debug_ui()


## Check if we're in debug placement mode
func is_in_placement_mode() -> bool:
	return debug_placement_mode != DebugPlacementMode.NONE


## Cancel debug placement mode
func cancel_placement() -> void:
	debug_placement_mode = DebugPlacementMode.NONE
	hide_info_requested.emit()
	TileManager.clear_highlights()


## Handle debug placement click at grid position (left click = place)
func handle_placement_click(grid_pos: Vector2i) -> void:
	match debug_placement_mode:
		DebugPlacementMode.SPAWN_POINT:
			_place_debug_spawn_point(grid_pos)
		DebugPlacementMode.TERRAIN:
			_place_debug_terrain(grid_pos)


## Handle debug removal click at grid position (right click = remove)
func handle_removal_click(grid_pos: Vector2i) -> void:
	match debug_placement_mode:
		DebugPlacementMode.SPAWN_POINT:
			_remove_debug_spawn_point(grid_pos)
		DebugPlacementMode.TERRAIN:
			_remove_debug_terrain(grid_pos)


## Create debug UI elements
func _create_debug_ui() -> void:
	# Create the debug FAB (floating action button) in bottom-left corner
	debug_fab = Button.new()
	debug_fab.name = "DebugFAB"
	debug_fab.text = "DEBUG"
	debug_fab.custom_minimum_size = Vector2(60, 24)
	debug_fab.pressed.connect(_on_debug_fab_pressed)
	
	# Position in bottom-left corner
	debug_fab.anchors_preset = Control.PRESET_BOTTOM_LEFT
	debug_fab.position = Vector2(10, GameConfig.VIEWPORT_HEIGHT - 34)
	
	# Add to UI layer
	if ui_layer:
		ui_layer.add_child(debug_fab)
	
	# Create the debug modal
	_create_debug_modal()
	
	# Create the export dialog
	_create_level_export_dialog()


## Create the debug modal
func _create_debug_modal() -> void:
	var modal_scene := load("res://scenes/ui/debug_modal.tscn") as PackedScene
	if not modal_scene:
		push_error("DebugModeController: Failed to load debug_modal.tscn")
		return
	
	debug_modal = modal_scene.instantiate() as DebugModal
	if not debug_modal:
		push_error("DebugModeController: Failed to instantiate debug modal")
		return
	
	# Connect signals
	debug_modal.export_level_requested.connect(_on_export_level_requested)
	debug_modal.go_to_level_requested.connect(_on_go_to_level_requested)
	debug_modal.restart_level_requested.connect(_on_restart_level_requested)
	debug_modal.place_spawn_point_requested.connect(_on_place_spawn_point_requested)
	debug_modal.place_terrain_requested.connect(_on_place_terrain_requested)
	
	# Add to UI layer so it's on top
	if ui_layer:
		ui_layer.add_child(debug_modal)


## Create the level export dialog
func _create_level_export_dialog() -> void:
	var dialog_scene := load("res://scenes/ui/level_export_dialog.tscn") as PackedScene
	if not dialog_scene:
		push_error("DebugModeController: Failed to load level_export_dialog.tscn")
		return
	
	level_export_dialog = dialog_scene.instantiate() as LevelExportDialog
	if not level_export_dialog:
		push_error("DebugModeController: Failed to instantiate level export dialog")
		return
	
	# Connect signals
	level_export_dialog.export_completed.connect(_on_level_export_completed)
	level_export_dialog.save_completed.connect(_on_level_save_completed)
	level_export_dialog.cancelled.connect(_on_level_export_cancelled)
	
	# Add to UI layer so it's on top
	if ui_layer:
		ui_layer.add_child(level_export_dialog)


## Handle debug FAB pressed
func _on_debug_fab_pressed() -> void:
	if debug_modal:
		debug_modal.show_modal()


## Handle export level requested from debug modal
func _on_export_level_requested() -> void:
	if level_export_dialog:
		level_export_dialog.show_dialog(
			debug_spawn_points,
			debug_terrain_tiles,
			current_level_data,
			removed_spawn_points,
			removed_terrain_tiles,
			removed_walls,
			removed_runes
		)


## Handle go to level requested from debug modal
func _on_go_to_level_requested(level_number: int) -> void:
	print("DebugModeController: Going to level %d" % level_number)
	GameManager.current_level = level_number
	# Reset to build phase so player needs to click start again
	GameManager.current_state = GameManager.GameState.BUILD_PHASE
	SceneManager.reload_current_scene()


## Handle restart level requested from debug modal
func _on_restart_level_requested() -> void:
	print("DebugModeController: Restarting level %d (maintaining layout)" % GameManager.current_level)
	
	# Cancel any active debug placement mode
	cancel_placement()
	
	# Reset game state to build phase (this will also unpause if paused)
	GameManager.set_state(GameManager.GameState.BUILD_PHASE)
	
	# Reset resources to starting resources for this level
	GameManager.reset_for_level(GameManager.current_level)
	
	# Clear all enemies using EnemyManager
	EnemyManager.clear_enemies()
	
	# Also manually clear enemies container if available
	if game_board:
		var enemies_container := game_board.get_node_or_null("Enemies")
		if enemies_container:
			for child in enemies_container.get_children():
				if is_instance_valid(child):
					child.queue_free()
	
	# Clear all fireballs
	var fireballs := get_tree().get_nodes_in_group("fireball")
	for fireball in fireballs:
		if is_instance_valid(fireball):
			fireball.queue_free()
	
	# Also check the game board's fireball container
	if game_board:
		var fireball_container := game_board.get_node_or_null("Fireball")
		if fireball_container:
			for child in fireball_container.get_children():
				if is_instance_valid(child):
					child.queue_free()
	
	show_info_requested.emit("Level restarted! Layout preserved.")


## Handle place spawn point requested from debug modal
func _on_place_spawn_point_requested() -> void:
	debug_placement_mode = DebugPlacementMode.SPAWN_POINT
	show_info_requested.emit("Left-click to place, right-click to remove (ESC to cancel)")
	# Highlight all tiles as potential placement spots
	TileManager.highlight_tiles(func(tile): return tile.is_buildable() or tile.occupancy == TileBase.OccupancyType.EMPTY, "buildable")


## Handle place terrain requested from debug modal
func _on_place_terrain_requested() -> void:
	debug_placement_mode = DebugPlacementMode.TERRAIN
	show_info_requested.emit("Left-click to place, right-click to remove (ESC to cancel)")
	# Highlight all tiles as potential placement spots
	TileManager.highlight_tiles(func(tile): return tile.is_buildable() or tile.occupancy == TileBase.OccupancyType.EMPTY, "buildable")


## Place a debug spawn point
func _place_debug_spawn_point(grid_pos: Vector2i) -> void:
	# Check if already a spawn point
	if grid_pos in debug_spawn_points:
		show_error_requested.emit("Spawn point already exists here!")
		return
	
	# Check if valid position
	if current_level_data and grid_pos in current_level_data.spawn_points:
		show_error_requested.emit("Original spawn point already here!")
		return
	
	# Add the spawn point
	debug_spawn_points.append(grid_pos)
	
	# Create visual marker
	_create_debug_spawn_marker(grid_pos)
	
	print("DebugModeController: Placed debug spawn point at %s" % grid_pos)
	show_info_requested.emit("Spawn point placed! Click to add more, ESC to finish")


## Create a visual marker for debug spawn point
func _create_debug_spawn_marker(grid_pos: Vector2i) -> void:
	# Use the proper spawn point marker scene
	var marker_scene := load("res://scenes/tiles/spawn_point_marker.tscn") as PackedScene
	if not marker_scene:
		push_error("DebugModeController: Failed to load spawn_point_marker.tscn")
		return
	
	var marker_node: Node = marker_scene.instantiate()
	if not marker_node:
		push_error("DebugModeController: Failed to instantiate spawn point marker")
		return
	
	var marker: Node2D = marker_node as Node2D
	if not marker:
		push_error("DebugModeController: Spawn point marker is not a Node2D")
		marker_node.queue_free()
		return
	
	marker.name = "DebugSpawn_%d_%d" % [grid_pos.x, grid_pos.y]
	marker.position = Vector2(
		grid_pos.x * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0,
		grid_pos.y * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0
	)
	
	# Add to spawn points container
	if spawn_points_container:
		spawn_points_container.add_child(marker)


## Place a debug terrain tile
func _place_debug_terrain(grid_pos: Vector2i) -> void:
	# Check if already a terrain tile
	if grid_pos in debug_terrain_tiles:
		show_error_requested.emit("Terrain already exists here!")
		return
	
	# Check if terrain already exists in level data
	if current_level_data and grid_pos in current_level_data.terrain_blocked:
		show_error_requested.emit("Original terrain already here!")
		return
	
	# Check if tile is already occupied (by player-placed items or preset walls)
	var tile := TileManager.get_tile(grid_pos)
	if tile and tile.occupancy != TileBase.OccupancyType.EMPTY:
		show_error_requested.emit("Tile already occupied!")
		return
	
	# Add the terrain tile
	debug_terrain_tiles.append(grid_pos)
	
	# Set tile occupancy to WALL (not player-placed, so it can't be sold)
	TileManager.set_occupancy(grid_pos, TileBase.OccupancyType.WALL, null, false, "terrain")
	
	# Create visual marker
	_create_debug_terrain_marker(grid_pos)
	
	print("DebugModeController: Placed debug terrain at %s" % grid_pos)
	show_info_requested.emit("Terrain placed! Click to add more, ESC to finish")


## Create a visual marker for debug terrain
func _create_debug_terrain_marker(grid_pos: Vector2i) -> void:
	# Use the same wall visual as preset walls
	var visual := Node2D.new()
	visual.name = "DebugTerrain_%d_%d" % [grid_pos.x, grid_pos.y]
	
	# Set z_index based on Y position for Y-sorting (same as preset walls)
	visual.z_index = grid_pos.y * 10 + 5
	
	# Load wall sprite
	var wall_texture := load("res://assets/sprites/wall.png") as Texture2D
	if wall_texture:
		var sprite := Sprite2D.new()
		sprite.texture = wall_texture
		# Position sprite so bottom aligns with tile bottom (for taller sprites)
		var sprite_height := wall_texture.get_height()
		var tile_height := GameConfig.TILE_SIZE
		var offset_y := (sprite_height - tile_height) / 2.0
		sprite.position = Vector2(0, -offset_y)
		visual.add_child(sprite)
	else:
		# Fallback: Create a colored rectangle
		var rect := ColorRect.new()
		var size := Vector2(GameConfig.TILE_SIZE - 4, GameConfig.TILE_SIZE - 4)
		rect.size = size
		rect.position = -size / 2.0
		rect.color = Color(0.4, 0.35, 0.3, 1.0)  # Dark gray/brown for terrain
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		visual.add_child(rect)
	
	# Position the visual
	visual.position = Vector2(
		grid_pos.x * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0,
		grid_pos.y * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0
	)
	
	# Add to game board
	if game_board:
		game_board.add_child(visual)


## Remove a spawn point (right-click) - handles both debug-placed and original
func _remove_debug_spawn_point(grid_pos: Vector2i) -> void:
	# Check if it's a debug-placed spawn point
	if grid_pos in debug_spawn_points:
		debug_spawn_points.erase(grid_pos)
		
		# Remove visual marker
		if spawn_points_container:
			var marker := spawn_points_container.get_node_or_null("DebugSpawn_%d_%d" % [grid_pos.x, grid_pos.y])
			if marker:
				marker.queue_free()
		
		print("DebugModeController: Removed debug spawn point at %s" % grid_pos)
		show_info_requested.emit("Spawn point removed!")
		return
	
	# Check if it's an original spawn point from level data
	if current_level_data and grid_pos in current_level_data.spawn_points:
		# Add to removed list (will be excluded from export)
		if grid_pos not in removed_spawn_points:
			removed_spawn_points.append(grid_pos)
		
		# Remove the visual marker (original spawn markers have a different name pattern)
		if spawn_points_container:
			# Find and remove the spawn point marker at this position
			for child in spawn_points_container.get_children():
				if child is Node2D:
					var marker_pos := Vector2i(
						int(child.position.x / GameConfig.TILE_SIZE),
						int(child.position.y / GameConfig.TILE_SIZE)
					)
					if marker_pos == grid_pos:
						child.queue_free()
						break
		
		print("DebugModeController: Marked original spawn point at %s for removal" % grid_pos)
		show_info_requested.emit("Original spawn point removed!")
		return
	
	# Also check if we can remove a rune/wall at this position (convenience for level editing)
	_try_remove_structure(grid_pos)


## Remove a terrain tile (right-click) - handles both debug-placed and original
func _remove_debug_terrain(grid_pos: Vector2i) -> void:
	# Check if it's a debug-placed terrain tile
	if grid_pos in debug_terrain_tiles:
		debug_terrain_tiles.erase(grid_pos)
		
		# Remove visual marker
		if game_board:
			var marker := game_board.get_node_or_null("DebugTerrain_%d_%d" % [grid_pos.x, grid_pos.y])
			if marker:
				marker.queue_free()
		
		print("DebugModeController: Removed debug terrain at %s" % grid_pos)
		show_info_requested.emit("Terrain removed!")
		return
	
	# Check if it's original terrain from level data
	if current_level_data and grid_pos in current_level_data.terrain_blocked:
		# Add to removed list (will be excluded from export)
		if grid_pos not in removed_terrain_tiles:
			removed_terrain_tiles.append(grid_pos)
		
		# Remove the visual tile (terrain_rock tile)
		var tile := TileManager.get_tile(grid_pos)
		if tile and is_instance_valid(tile):
			# Mark for visual removal - the tile system will handle this
			tile.queue_free()
			TileManager.tiles.erase(grid_pos)
			
			# Create an open terrain tile in its place
			var open_scene := load("res://scenes/tiles/terrain_open.tscn")
			if open_scene:
				var open_tile := open_scene.instantiate() as TileBase
				if open_tile:
					# Get the tiles container from game_board
					var tiles_container := game_board.get_node_or_null("Tiles")
					if tiles_container:
						tiles_container.add_child(open_tile)
						open_tile.set_grid_position(grid_pos)
						TileManager.tiles[grid_pos] = open_tile
		
		print("DebugModeController: Marked original terrain at %s for removal" % grid_pos)
		show_info_requested.emit("Original terrain removed!")
		return
	
	# Also check if we can remove a rune/wall at this position (convenience for level editing)
	_try_remove_structure(grid_pos)


## Try to remove a rune or wall structure at a position
func _try_remove_structure(grid_pos: Vector2i) -> void:
	var tile := TileManager.get_tile(grid_pos)
	if not tile:
		show_error_requested.emit("Nothing to remove here!")
		return
	
	# Check if there's a structure to remove
	match tile.occupancy:
		TileBase.OccupancyType.WALL:
			# Add to removed walls list
			if grid_pos not in removed_walls:
				removed_walls.append(grid_pos)
			
			# Remove the structure visually
			structure_removal_requested.emit(grid_pos)
			
			# Clear the tile occupancy
			tile.clear_occupancy()
			TileManager.occupancy_changed.emit(grid_pos)
			
			print("DebugModeController: Removed wall at %s" % grid_pos)
			show_info_requested.emit("Wall removed!")
			
		TileBase.OccupancyType.RUNE:
			# Add to removed runes list
			if grid_pos not in removed_runes:
				removed_runes.append(grid_pos)
			
			# Remove the structure visually
			structure_removal_requested.emit(grid_pos)
			
			# Clear the tile occupancy
			tile.clear_occupancy()
			TileManager.occupancy_changed.emit(grid_pos)
			
			print("DebugModeController: Removed rune at %s" % grid_pos)
			show_info_requested.emit("Rune removed!")
			
		_:
			show_error_requested.emit("Nothing to remove here!")


## Handle level export completed (copy to clipboard)
func _on_level_export_completed(success: bool) -> void:
	if success:
		show_info_requested.emit("Level copied to clipboard!")
		# Auto-hide after 3 seconds
		var tween := create_tween()
		tween.tween_interval(3.0)
		tween.tween_callback(func(): hide_info_requested.emit())


## Handle level save completed (save to file)
func _on_level_save_completed(success: bool, file_path: String) -> void:
	if success:
		show_info_requested.emit("Level saved! Reloading...")
		# Extract level number from file path (e.g., "res://resources/levels/level_2.tres" -> 2)
		var level_number := _extract_level_number_from_path(file_path)
		# Short delay to show the message, then reload
		var tween := create_tween()
		tween.tween_interval(0.5)
		tween.tween_callback(func(): reload_level_requested.emit(level_number))
	else:
		show_error_requested.emit("Failed to save level!")
		# Auto-hide after 3 seconds
		var tween := create_tween()
		tween.tween_interval(3.0)
		tween.tween_callback(func(): hide_info_requested.emit())


## Extract level number from file path
func _extract_level_number_from_path(file_path: String) -> int:
	# Extract from path like "res://resources/levels/level_2.tres"
	var regex := RegEx.new()
	regex.compile("level_(\\d+)\\.tres$")
	var result := regex.search(file_path)
	if result:
		return int(result.get_string(1))
	return GameManager.current_level  # Fallback to current level


## Handle level export cancelled
func _on_level_export_cancelled() -> void:
	pass  # Nothing needed
