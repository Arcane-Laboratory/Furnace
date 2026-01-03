extends Node
class_name DebugModeController
## Handles all debug-mode functionality: spawn point/terrain placement, level export


## Emitted when info snackbar should be shown
signal show_info_requested(message: String)

## Emitted when info snackbar should be hidden
signal hide_info_requested()

## Emitted when error snackbar should be shown
signal show_error_requested(message: String)


## Debug placement mode (for placing spawn points, terrain, etc.)
enum DebugPlacementMode { NONE, SPAWN_POINT, TERRAIN }
var debug_placement_mode: DebugPlacementMode = DebugPlacementMode.NONE

## Debug-placed spawn points (additional spawn points placed by editor)
var debug_spawn_points: Array[Vector2i] = []

## Debug-placed terrain tiles (additional terrain placed by editor)
var debug_terrain_tiles: Array[Vector2i] = []

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


## Handle debug placement click at grid position
func handle_placement_click(grid_pos: Vector2i) -> void:
	match debug_placement_mode:
		DebugPlacementMode.SPAWN_POINT:
			_place_debug_spawn_point(grid_pos)
		DebugPlacementMode.TERRAIN:
			_place_debug_terrain(grid_pos)


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
		level_export_dialog.show_dialog(debug_spawn_points, debug_terrain_tiles)


## Handle go to level requested from debug modal
func _on_go_to_level_requested(level_number: int) -> void:
	print("DebugModeController: Going to level %d" % level_number)
	GameManager.current_level = level_number
	# Reset to build phase so player needs to click start again
	GameManager.current_state = GameManager.GameState.BUILD_PHASE
	SceneManager.reload_current_scene()


## Handle place spawn point requested from debug modal
func _on_place_spawn_point_requested() -> void:
	debug_placement_mode = DebugPlacementMode.SPAWN_POINT
	show_info_requested.emit("Click to place spawn point (ESC to cancel)")
	# Highlight all tiles as potential placement spots
	TileManager.highlight_tiles(func(tile): return tile.is_buildable() or tile.occupancy == TileBase.OccupancyType.EMPTY, "buildable")


## Handle place terrain requested from debug modal
func _on_place_terrain_requested() -> void:
	debug_placement_mode = DebugPlacementMode.TERRAIN
	show_info_requested.emit("Click to place terrain (ESC to cancel)")
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
	var marker := ColorRect.new()
	marker.name = "DebugSpawn_%d_%d" % [grid_pos.x, grid_pos.y]
	marker.size = Vector2(GameConfig.TILE_SIZE - 4, GameConfig.TILE_SIZE - 4)
	marker.position = Vector2(
		grid_pos.x * GameConfig.TILE_SIZE + 2,
		grid_pos.y * GameConfig.TILE_SIZE + 2
	)
	marker.color = Color(1.0, 0.5, 0.0, 0.6)  # Orange
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
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
	
	# Add the terrain tile
	debug_terrain_tiles.append(grid_pos)
	
	# Create visual marker
	_create_debug_terrain_marker(grid_pos)
	
	print("DebugModeController: Placed debug terrain at %s" % grid_pos)
	show_info_requested.emit("Terrain placed! Click to add more, ESC to finish")


## Create a visual marker for debug terrain
func _create_debug_terrain_marker(grid_pos: Vector2i) -> void:
	var marker := ColorRect.new()
	marker.name = "DebugTerrain_%d_%d" % [grid_pos.x, grid_pos.y]
	marker.size = Vector2(GameConfig.TILE_SIZE - 4, GameConfig.TILE_SIZE - 4)
	marker.position = Vector2(
		grid_pos.x * GameConfig.TILE_SIZE + 2,
		grid_pos.y * GameConfig.TILE_SIZE + 2
	)
	marker.color = Color(0.4, 0.35, 0.3, 0.7)  # Dark gray/brown for terrain
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Add to game board
	if game_board:
		game_board.add_child(marker)


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
		show_info_requested.emit("Level saved to %s" % file_path)
	else:
		show_error_requested.emit("Failed to save level!")
	# Auto-hide after 3 seconds
	var tween := create_tween()
	tween.tween_interval(3.0)
	tween.tween_callback(func(): hide_info_requested.emit())


## Handle level export cancelled
func _on_level_export_cancelled() -> void:
	pass  # Nothing needed
