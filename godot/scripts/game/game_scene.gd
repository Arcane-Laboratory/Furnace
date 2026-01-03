extends Node2D
## Main game scene controller - handles build and active phases


@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var right_panel: PanelContainer = $UILayer/RightPanel
@onready var active_ui: Control = $UILayer/ActiveUI
@onready var grid_overlay: Node2D = $GameBoard/GridOverlay
@onready var path_preview: Node2D = $GameBoard/PathPreview
@onready var background: Sprite2D = $Background
@onready var game_board: Node2D = $GameBoard
@onready var tiles_container: Node2D = $GameBoard/Tiles
@onready var spawn_points_container: Node2D = $GameBoard/SpawnPoints
@onready var enemies_container: Node2D = $GameBoard/Enemies
@onready var runes_container: Node2D = $GameBoard/Runes

## Reference to the game submenu (handles stats display and start button)
var game_submenu: GameSubmenu = null

## Reference to the build submenu
var build_submenu: Control = null

## Placement manager for handling item placement
var placement_manager: PlacementManager = null

## Error snackbar for showing placement errors
var error_snackbar: Control = null

## Tile tooltip for tile actions (sell, etc.)
var tile_tooltip: TileTooltip = null

var is_paused: bool = false

## Level data
var current_level_data: LevelData = null

## Hover highlight
var hover_highlight: ColorRect
var current_hover_cell: Vector2i = Vector2i(-1, -1)
var highlight_tween: Tween

## Drop target control for drag-and-drop
var drop_target: Control = null

## Track if we're currently dragging
var is_dragging: bool = false


func _ready() -> void:
	_load_background()
	_load_level_data()
	_initialize_tile_system()
	_draw_grid()
	_create_hover_highlight()
	_create_spawn_point_markers()
	
	GameManager.reset_for_level(GameManager.current_level)
	GameManager.resources_changed.connect(_on_resources_changed)
	GameManager.state_changed.connect(_on_state_changed)
	
	# Find and connect to GameSubmenu and BuildSubmenu
	_setup_ui_references()
	
	# Initialize placement manager
	_setup_placement_manager()
	
	# Create error snackbar
	_create_error_snackbar()
	
	# Create sell tooltip
	_create_tile_tooltip()
	
	# Create drop target for drag-and-drop
	_create_drop_target()
	
	_update_ui()
	_start_build_phase()


## Find and setup UI references (GameSubmenu, BuildSubmenu)
func _setup_ui_references() -> void:
	# Path: UILayer/RightPanel/CenterContainer/VBoxContainer/GameMenu/ColorRect/CenterContainer/VBoxContainer/...
	var game_menu := get_node_or_null("UILayer/RightPanel/CenterContainer/VBoxContainer/GameMenu") as Control
	if game_menu:
		game_submenu = game_menu.get_node_or_null("ColorRect/CenterContainer/VBoxContainer/GameSubmenu") as GameSubmenu
		if game_submenu:
			game_submenu.start_pressed.connect(_on_start_pressed)
			game_submenu.set_level(GameManager.current_level)
		else:
			push_warning("GameScene: GameSubmenu not found")
		
		build_submenu = game_menu.get_node_or_null("ColorRect/CenterContainer/VBoxContainer/BuildSubmenu") as Control
		if not build_submenu:
			push_warning("GameScene: BuildSubmenu not found")


## Setup the placement manager
func _setup_placement_manager() -> void:
	placement_manager = PlacementManager.new()
	add_child(placement_manager)
	placement_manager.initialize(game_board, build_submenu, runes_container, current_level_data)

	# Connect placement manager signals
	placement_manager.placement_failed.connect(_on_placement_failed)
	placement_manager.placement_succeeded.connect(_on_placement_succeeded)
	placement_manager.item_sold.connect(_on_item_sold)
	placement_manager.selection_changed.connect(_on_selection_changed)


func _process(_delta: float) -> void:
	_update_hover_highlight()




func _load_background() -> void:
	var bg_path := "res://assets/sprites/board_background.png"
	if ResourceLoader.exists(bg_path):
		background.texture = load(bg_path)


func _load_level_data() -> void:
	# Try to load level data resource, or create default
	var level_path := "res://resources/levels/level_%d.tres" % GameManager.current_level
	if ResourceLoader.exists(level_path):
		current_level_data = load(level_path) as LevelData
	else:
		# Create default level data for testing
		current_level_data = _create_default_level_data()


func _create_default_level_data() -> LevelData:
	var level_data := LevelData.new()
	level_data.level_number = GameManager.current_level
	level_data.level_name = "Level %d" % GameManager.current_level
	level_data.starting_resources = GameConfig.get_level_resources(GameManager.current_level)
	
	# Default spawn points (bottom of grid)
	level_data.spawn_points = [
		Vector2i(3, GameConfig.GRID_ROWS - 1),
		Vector2i(6, GameConfig.GRID_ROWS - 1),
		Vector2i(9, GameConfig.GRID_ROWS - 1),
	]
	
	# Default furnace position (top center)
	level_data.furnace_position = Vector2i(6, 0)
	
	# Default enemy wave (using EnemyWaveEntry resources)
	var wave1 := EnemyWaveEntry.new()
	wave1.enemy_type = EnemyWaveEntry.EnemyType.BASIC
	wave1.spawn_point = 0
	wave1.delay = 0.0
	
	var wave2 := EnemyWaveEntry.new()
	wave2.enemy_type = EnemyWaveEntry.EnemyType.BASIC
	wave2.spawn_point = 1
	wave2.delay = 1.0
	
	var wave3 := EnemyWaveEntry.new()
	wave3.enemy_type = EnemyWaveEntry.EnemyType.BASIC
	wave3.spawn_point = 2
	wave3.delay = 2.0
	
	level_data.enemy_waves = [wave1, wave2, wave3]
	
	return level_data


func _initialize_tile_system() -> void:
	# Initialize TileManager with level data
	TileManager.initialize_from_level_data(current_level_data)
	
	# Initialize path preview (if it exists)
	if path_preview:
		path_preview.update_paths(current_level_data)
		# Connect to tile occupancy changes to update paths
		TileManager.occupancy_changed.connect(_on_tile_occupancy_changed)
	
	# Add all tiles to the scene and set their positions
	# We need to iterate through the tiles dictionary to get both position and tile
	for x in range(GameConfig.GRID_COLUMNS):
		for y in range(GameConfig.GRID_ROWS):
			var grid_pos := Vector2i(x, y)
			var tile := TileManager.get_tile(grid_pos)
			if tile and is_instance_valid(tile):
				tiles_container.add_child(tile)
				# Set grid position after adding to tree (ensures node is ready)
				tile.set_grid_position(grid_pos)
	
	# Initialize EnemyManager with level data
	EnemyManager.initialize_wave(current_level_data, enemies_container)
	
	# Connect EnemyManager signals
	EnemyManager.all_enemies_defeated.connect(_on_all_enemies_defeated)
	EnemyManager.furnace_destroyed.connect(_on_furnace_destroyed)
	
	# Update build menu with level data
	_update_build_menu()
	
	# Test pathfinding for all spawn points
	_test_pathfinding()


func _draw_grid() -> void:
	# Clear existing grid visuals
	for child in grid_overlay.get_children():
		child.queue_free()
	
	# Draw grid lines (not filled cells) so background shows through
	var line_color := Color(0.4, 0.4, 0.4, 0.5)
	var grid_width := GameConfig.GRID_COLUMNS * GameConfig.TILE_SIZE
	var grid_height := GameConfig.GRID_ROWS * GameConfig.TILE_SIZE
	
	# Vertical lines
	for x in range(GameConfig.GRID_COLUMNS + 1):
		var line := ColorRect.new()
		line.size = Vector2(1, grid_height)
		line.position = Vector2(x * GameConfig.TILE_SIZE, 0)
		line.color = line_color
		grid_overlay.add_child(line)
	
	# Horizontal lines
	for y in range(GameConfig.GRID_ROWS + 1):
		var line := ColorRect.new()
		line.size = Vector2(grid_width, 1)
		line.position = Vector2(0, y * GameConfig.TILE_SIZE)
		line.color = line_color
		grid_overlay.add_child(line)


func _create_hover_highlight() -> void:
	hover_highlight = ColorRect.new()
	hover_highlight.size = Vector2(GameConfig.TILE_SIZE - 2, GameConfig.TILE_SIZE - 2)
	hover_highlight.color = Color(1.0, 1.0, 1.0, 0.0)  # Start invisible
	hover_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_board.add_child(hover_highlight)


func _update_hover_highlight() -> void:
	if not hover_highlight:
		return
	
	if GameManager.current_state != GameManager.GameState.BUILD_PHASE:
		hover_highlight.color.a = 0.0
		# Clear tile highlights and ghost preview
		if current_hover_cell != Vector2i(-1, -1):
			var tile := TileManager.get_tile(current_hover_cell)
			if tile:
				tile.set_highlight(false)
			current_hover_cell = Vector2i(-1, -1)
		if placement_manager:
			placement_manager.hide_ghost_preview()
		return
	
	var mouse_pos := get_global_mouse_position()
	var grid_pos := mouse_pos - game_board.global_position
	
	# Calculate which cell the mouse is over
	var cell_x := int(grid_pos.x / GameConfig.TILE_SIZE)
	var cell_y := int(grid_pos.y / GameConfig.TILE_SIZE)
	
	# Check if within grid bounds
	if cell_x >= 0 and cell_x < GameConfig.GRID_COLUMNS and cell_y >= 0 and cell_y < GameConfig.GRID_ROWS:
		var new_cell := Vector2i(cell_x, cell_y)
		
		if new_cell != current_hover_cell:
			# Clear previous tile highlight
			if current_hover_cell != Vector2i(-1, -1):
				var prev_tile := TileManager.get_tile(current_hover_cell)
				if prev_tile:
					prev_tile.set_highlight(false)
			
			current_hover_cell = new_cell
			
			# Update hover highlight position
			_animate_highlight_to_cell(cell_x, cell_y)
			
			# Update tile highlight based on context
			var tile := TileManager.get_tile(new_cell)
			if tile:
				_update_tile_highlight(tile, new_cell)
		
		# Update ghost preview position (even if cell hasn't changed, for smooth movement)
		if placement_manager and placement_manager.has_selection():
			placement_manager.update_ghost_preview(new_cell)
	else:
		# Mouse outside grid
		if current_hover_cell != Vector2i(-1, -1):
			var tile := TileManager.get_tile(current_hover_cell)
			if tile:
				tile.set_highlight(false)
			current_hover_cell = Vector2i(-1, -1)
			_fade_out_highlight()
		if placement_manager:
			placement_manager.hide_ghost_preview()


## Update tile highlight based on selection state and buildability
func _update_tile_highlight(tile: TileBase, grid_pos: Vector2i) -> void:
	if not placement_manager:
		# Fallback to basic highlight
		if TileManager.is_buildable(grid_pos):
			tile.set_highlight(true, "hover")
		else:
			tile.set_highlight(true, "invalid")
		return
	
	# If an item is selected, show placement-specific highlights
	if placement_manager.has_selection():
		if placement_manager.can_place_at(grid_pos):
			tile.set_highlight(true, "valid_placement")
		else:
			tile.set_highlight(true, "invalid")
	else:
		# No item selected - basic hover
		if TileManager.is_buildable(grid_pos):
			tile.set_highlight(true, "hover")
		elif TileManager.can_sell_tile(grid_pos):
			tile.set_highlight(true, "hover")  # Sellable item
		else:
			tile.set_highlight(true, "invalid")


func _animate_highlight_to_cell(cell_x: int, cell_y: int) -> void:
	if not hover_highlight:
		return
	
	# Position the highlight
	hover_highlight.position = Vector2(
		cell_x * GameConfig.TILE_SIZE + 1,
		cell_y * GameConfig.TILE_SIZE + 1
	)
	
	# Cancel any existing tween
	if highlight_tween and highlight_tween.is_valid():
		highlight_tween.kill()
	
	# Create pulse animation
	highlight_tween = create_tween()
	highlight_tween.set_loops()
	highlight_tween.tween_property(hover_highlight, "color", Color(1.0, 0.9, 0.5, 0.25), 0.4)
	highlight_tween.tween_property(hover_highlight, "color", Color(1.0, 0.9, 0.5, 0.15), 0.4)


func _fade_out_highlight() -> void:
	if not hover_highlight:
		return
	
	if highlight_tween and highlight_tween.is_valid():
		highlight_tween.kill()
	
	highlight_tween = create_tween()
	highlight_tween.tween_property(hover_highlight, "color", Color(1.0, 0.9, 0.5, 0.0), 0.15)


func _update_build_menu() -> void:
	# Find and update build submenu with level data
	# Path: UILayer/RightPanel/CenterContainer/VBoxContainer/GameMenu/ColorRect/CenterContainer/VBoxContainer/BuildSubmenu
	var game_menu := get_node_or_null("UILayer/RightPanel/CenterContainer/VBoxContainer/GameMenu") as Control
	if game_menu:
		var build_submenu := game_menu.get_node_or_null("ColorRect/CenterContainer/VBoxContainer/BuildSubmenu") as Control
		if build_submenu and build_submenu.has_method("set_level_data"):
			build_submenu.set_level_data(current_level_data)


func _test_pathfinding() -> void:
	# Test pathfinding from each spawn point to furnace
	if not current_level_data:
		return
	
	var furnace_pos := current_level_data.furnace_position
	print("Testing pathfinding to furnace at: ", furnace_pos)
	
	for i in range(current_level_data.spawn_points.size()):
		var spawn_pos := current_level_data.spawn_points[i]
		var path := PathfindingManager.find_path(spawn_pos, furnace_pos)
		
		if path.is_empty():
			push_warning("No path found from spawn point %d (%s) to furnace (%s)" % [i, spawn_pos, furnace_pos])
		else:
			print("Path found from spawn %d (%s): %d tiles" % [i, spawn_pos, path.size()])


func _create_spawn_point_markers() -> void:
	if not current_level_data:
		return
	
	# Clear existing markers
	for child in spawn_points_container.get_children():
		child.queue_free()
	
	# Create markers for each spawn point
	var marker_scene := load("res://scenes/tiles/spawn_point_marker.tscn")
	if marker_scene:
		for spawn_pos in current_level_data.spawn_points:
			var marker_node: Node = marker_scene.instantiate()
			if not marker_node:
				push_error("Failed to instantiate spawn_point_marker.tscn")
				continue
			var marker: Node2D = marker_node as Node2D
			if not marker:
				push_error("Spawn point marker is not a Node2D")
				continue
			marker.position = Vector2(
				spawn_pos.x * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0,
				spawn_pos.y * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0
			)
			spawn_points_container.add_child(marker)


# Called when all enemies are defeated
func _on_all_enemies_defeated() -> void:
	print("GameScene: All enemies defeated - VICTORY!")
	win_level()


# Called when enemy reaches furnace
func _on_furnace_destroyed() -> void:
	print("GameScene: Furnace destroyed - DEFEAT!")
	lose_level()


func _input(event: InputEvent) -> void:
	# Toggle path preview with 'P' key (only in build phase)
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		if GameManager.current_state == GameManager.GameState.BUILD_PHASE and path_preview:
			path_preview.visible = not path_preview.visible
			path_preview.queue_redraw()
	
	# Handle escape key - cancel selection or open pause menu
	if event.is_action_pressed("ui_cancel"):
		if GameManager.current_state == GameManager.GameState.BUILD_PHASE:
			# First, try to cancel any active selection
			if placement_manager and placement_manager.has_selection():
				placement_manager.clear_selection()
				_hide_tile_tooltip()
				get_viewport().set_input_as_handled()
				return
			# If sell tooltip is visible, hide it
			if tile_tooltip and tile_tooltip.visible:
				_hide_tile_tooltip()
				get_viewport().set_input_as_handled()
				return
		# Otherwise, toggle pause menu
		_toggle_pause()
	
	# Handle mouse clicks during build phase
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if GameManager.current_state == GameManager.GameState.BUILD_PHASE:
			# Skip if click is over the sell tooltip (let button handle it)
			if _is_mouse_over_tile_tooltip():
				return
			_handle_build_phase_click()


func _toggle_pause() -> void:
	if GameManager.current_state == GameManager.GameState.PAUSED:
		pause_menu.hide_pause_menu()
		GameManager.resume_game()
		is_paused = false
	elif GameManager.current_state == GameManager.GameState.BUILD_PHASE or GameManager.current_state == GameManager.GameState.ACTIVE_PHASE:
		GameManager.pause_game()
		pause_menu.show_pause_menu()
		is_paused = true


func _start_build_phase() -> void:
	GameManager.start_build_phase()
	right_panel.show()
	active_ui.hide()
	# Show path preview in build phase
	if path_preview:
		path_preview.set_visible(true)
		path_preview.update_paths(current_level_data)


func _start_active_phase() -> void:
	GameManager.start_active_phase()
	right_panel.hide()
	active_ui.show()
	
	# Start enemy wave
	EnemyManager.start_wave()
	
	_launch_fireball()


func _launch_fireball() -> void:
	# Wait 1 second before launching
	await get_tree().create_timer(1.0).timeout
	
	# Don't launch if game state changed (e.g., paused or game over)
	if GameManager.current_state != GameManager.GameState.ACTIVE_PHASE:
		return
	
	# Load fireball scene
	var fireball_scene := load("res://scenes/entities/fireball.tscn") as PackedScene
	if not fireball_scene:
		push_error("GameScene: Failed to load fireball scene")
		return
	
	var fireball := fireball_scene.instantiate() as Fireball
	if not fireball:
		push_error("GameScene: Failed to instantiate fireball")
		return
	
	# Calculate spawn position (above furnace tile)
	var furnace_pos := current_level_data.furnace_position
	var spawn_world_pos := Vector2(
		furnace_pos.x * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0,
		-GameConfig.TILE_SIZE / 2.0  # Above the grid
	)
	
	# Add to game board and launch
	game_board.add_child(fireball)
	fireball.launch(spawn_world_pos)
	
	# Connect fireball signals
	fireball.fireball_destroyed.connect(_on_fireball_destroyed)
	fireball.enemy_hit.connect(_on_fireball_enemy_hit)
	
	print("Fireball launched from position: %s" % spawn_world_pos)


func _on_start_pressed() -> void:
	_start_active_phase()


func _on_resources_changed(_new_amount: int) -> void:
	_update_ui()


func _on_state_changed(new_state: GameManager.GameState) -> void:
	match new_state:
		GameManager.GameState.BUILD_PHASE:
			right_panel.show()
			active_ui.hide()
			# Show path preview in build phase (if it exists)
			if path_preview:
				path_preview.set_preview_visible(true)
		GameManager.GameState.ACTIVE_PHASE:
			right_panel.hide()
			active_ui.show()
			# Hide path preview in active phase (if it exists)
			if path_preview:
				path_preview.set_preview_visible(false)
		GameManager.GameState.GAME_OVER:
			SceneManager.goto_game_over(GameManager.game_won)


func _update_ui() -> void:
	# GameSubmenu handles its own updates via GameManager signals
	# This is now just for any other UI elements that need updating
	if game_submenu:
		game_submenu.set_level(GameManager.current_level)


## Handle tile occupancy changes - update path preview
func _on_tile_occupancy_changed(_grid_pos: Vector2i) -> void:
	# Update path preview when tiles change
	if path_preview and GameManager.current_state == GameManager.GameState.BUILD_PHASE:
		# Use call_deferred to batch updates within the same frame
		call_deferred("_update_path_preview_deferred")


func _update_path_preview_deferred() -> void:
	if path_preview and current_level_data:
		path_preview.update_paths(current_level_data)


## Called when level is won
func win_level() -> void:
	GameManager.end_game(true)


## Called when furnace is destroyed
func lose_level() -> void:
	GameManager.end_game(false)


## Handle clicks during build phase
func _handle_build_phase_click() -> void:
	if not placement_manager:
		return
	
	# Check if click is on the game board (not UI)
	var mouse_pos := get_global_mouse_position()
	var grid_pos_local := mouse_pos - game_board.global_position
	
	# Check if within grid bounds
	var cell_x := int(grid_pos_local.x / GameConfig.TILE_SIZE)
	var cell_y := int(grid_pos_local.y / GameConfig.TILE_SIZE)
	
	if cell_x < 0 or cell_x >= GameConfig.GRID_COLUMNS or cell_y < 0 or cell_y >= GameConfig.GRID_ROWS:
		# Click outside grid - hide sell tooltip
		_hide_tile_tooltip()
		return
	
	var grid_pos := Vector2i(cell_x, cell_y)
	
	# Hide sell tooltip on any click
	_hide_tile_tooltip()
	
	# If item is selected, try to place it
	if placement_manager.has_selection():
		placement_manager.try_place_item(grid_pos)
	else:
		# No item selected - check if clicking on a sellable tile
		if TileManager.can_sell_tile(grid_pos):
			_show_tile_tooltip(grid_pos)


## Create the error snackbar
func _create_error_snackbar() -> void:
	# Create a simple error snackbar (can be replaced with scene later)
	error_snackbar = PanelContainer.new()
	error_snackbar.name = "ErrorSnackbar"
	
	var label := Label.new()
	label.name = "Label"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	error_snackbar.add_child(label)
	
	# Style
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.8, 0.2, 0.2, 0.9)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(8)
	error_snackbar.add_theme_stylebox_override("panel", style)
	
	# Position at bottom center
	error_snackbar.anchors_preset = Control.PRESET_CENTER_BOTTOM
	error_snackbar.position = Vector2(GameConfig.VIEWPORT_WIDTH / 2.0 - 100, GameConfig.VIEWPORT_HEIGHT - 50)
	error_snackbar.custom_minimum_size = Vector2(200, 30)
	error_snackbar.visible = false
	
	# Add to UI layer
	var ui_layer := get_node_or_null("UILayer") as CanvasLayer
	if ui_layer:
		ui_layer.add_child(error_snackbar)


## Show error snackbar with message
func _show_error_snackbar(message: String) -> void:
	if not error_snackbar:
		return
	
	var label := error_snackbar.get_node_or_null("Label") as Label
	if label:
		label.text = message
	
	error_snackbar.visible = true
	
	# Auto-hide after 2 seconds
	var tween := create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(error_snackbar, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): 
		error_snackbar.visible = false
		error_snackbar.modulate.a = 1.0
	)


## Create the sell tooltip
func _create_tile_tooltip() -> void:
	var tile_tooltip_scene := load("res://scenes/ui/tile_tooltip.tscn") as PackedScene
	if not tile_tooltip_scene:
		push_error("GameScene: Failed to load tile_tooltip.tscn")
		return
	
	tile_tooltip = tile_tooltip_scene.instantiate() as TileTooltip
	if not tile_tooltip:
		push_error("GameScene: Failed to instantiate sell tooltip")
		return
	
	# Connect to sell request signal
	tile_tooltip.sell_requested.connect(_on_sell_requested)
	
	# Add to UILayer so it's above game board and handles input correctly
	var ui_layer := get_node_or_null("UILayer") as CanvasLayer
	if ui_layer:
		ui_layer.add_child(tile_tooltip)
	else:
		# Fallback to game_board with high z_index
		game_board.add_child(tile_tooltip)


## Show sell tooltip at tile position
func _show_tile_tooltip(grid_pos: Vector2i) -> void:
	if not tile_tooltip:
		return
	
	var item_type := TileManager.get_placed_item_type(grid_pos)
	var definition := GameConfig.get_item_definition(item_type)
	
	if not definition:
		return
	
	# Get the tile and its structure (rune) if any
	var tile := TileManager.get_tile(grid_pos)
	var structure: Node = null
	var has_direction: bool = false
	
	if tile:
		structure = tile.structure
	
	if definition.has_method("get") or "has_direction" in definition:
		has_direction = definition.has_direction
	
	# Calculate screen position (tile position + game board offset)
	var tile_screen_pos := Vector2(
		grid_pos.x * GameConfig.TILE_SIZE + game_board.position.x,
		grid_pos.y * GameConfig.TILE_SIZE + game_board.position.y
	)
	
	# Position above the tile, centered horizontally
	# Adjust position based on whether direction controls are shown
	var tooltip_height := 26  # Base height
	if has_direction:
		tooltip_height = 70  # Taller with direction buttons
	
	var tooltip_pos := Vector2(
		tile_screen_pos.x + GameConfig.TILE_SIZE / 2.0 - 30,  # Center the ~60px button
		tile_screen_pos.y - tooltip_height  # Above the tile
	)
	
	tile_tooltip.show_for_tile(grid_pos, definition.cost, tooltip_pos, has_direction, structure)


## Hide the sell tooltip
func _hide_tile_tooltip() -> void:
	if tile_tooltip:
		tile_tooltip.hide_tooltip()


## Check if mouse is over the sell tooltip
func _is_mouse_over_tile_tooltip() -> bool:
	if not tile_tooltip:
		return false
	return tile_tooltip.is_mouse_over()


## Handle sell request from tooltip
func _on_sell_requested(grid_pos: Vector2i) -> void:
	if not placement_manager:
		return
	
	placement_manager.try_sell_item(grid_pos)


## Handle placement failed signal
func _on_placement_failed(reason: String) -> void:
	_show_error_snackbar(reason)


## Handle placement succeeded signal
func _on_placement_succeeded(_item_type: String, _grid_pos: Vector2i) -> void:
	# Placement successful - could add sound effect here
	pass


## Handle item sold signal
func _on_item_sold(_item_type: String, _grid_pos: Vector2i, _refund_amount: int) -> void:
	# Item sold - could add sound effect here
	pass


## Handle selection changed signal
func _on_selection_changed(_item_type: String) -> void:
	# Selection changed - hide sell tooltip when selecting an item
	_hide_tile_tooltip()


## Handle fireball destroyed signal
func _on_fireball_destroyed() -> void:
	print("GameScene: Fireball destroyed")
	# Could respawn fireball or end level here if needed


## Handle fireball enemy hit signal
func _on_fireball_enemy_hit(enemy: Node2D, damage: int) -> void:
	print("GameScene: Fireball hit enemy for %d damage" % damage)


## Create drop target overlay for drag-and-drop
func _create_drop_target() -> void:
	drop_target = Control.new()
	drop_target.name = "DropTarget"
	drop_target.position = game_board.position
	drop_target.size = Vector2(
		GameConfig.GRID_COLUMNS * GameConfig.TILE_SIZE,
		GameConfig.GRID_ROWS * GameConfig.TILE_SIZE
	)
	drop_target.mouse_filter = Control.MOUSE_FILTER_PASS  # Pass through but receive drops
	
	# Load and set the script for drop handling
	var drop_script := load("res://scripts/game/drop_target.gd")
	if drop_script:
		drop_target.set_script(drop_script)
		drop_target.drop_received.connect(_on_drop_received)
	
	# Add to scene
	add_child(drop_target)


## Handle drop received from drop target
func _on_drop_received(data: Dictionary, at_position: Vector2) -> void:
	if GameManager.current_state != GameManager.GameState.BUILD_PHASE:
		return
	
	if not placement_manager:
		return
	
	# at_position is already in drop_target local coordinates, which matches game_board
	var cell_x := int(at_position.x / GameConfig.TILE_SIZE)
	var cell_y := int(at_position.y / GameConfig.TILE_SIZE)
	
	# Check bounds
	if cell_x < 0 or cell_x >= GameConfig.GRID_COLUMNS or cell_y < 0 or cell_y >= GameConfig.GRID_ROWS:
		return
	
	var grid_pos := Vector2i(cell_x, cell_y)
	
	# Get item type from drag data
	var item_type: String = data.get("item_type", "")
	if item_type.is_empty():
		return
	
	# Temporarily set selection and try to place
	placement_manager.set_selected_item(item_type)
	placement_manager.try_place_item(grid_pos)
	
	# Clear selection after drop
	placement_manager.clear_selection()
