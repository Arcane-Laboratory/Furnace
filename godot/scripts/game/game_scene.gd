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

## Reference to the details submenu
var details_submenu: Control = null

## Reference to the submenu container (for adding/swapping submenus)
var submenu_container: VBoxContainer = null

## Reference to the level in progress menu (shown during active phase)
var level_in_progress_menu: Control = null

## Track sparks at active phase start to calculate earned amount
var sparks_at_phase_start: int = 0

## Placement manager for handling item placement
var placement_manager: PlacementManager = null

## Error snackbar for showing placement errors
var error_snackbar: Control = null

## Info snackbar for showing portal placement messages
var info_snackbar: Control = null

## Tile tooltip for tile actions (sell, etc.)
var tile_tooltip: TileTooltip = null

## Debug mode controller (only instantiated when debug_mode is true)
var debug_controller: DebugModeController = null

## Help snackbar for showing level hints
var help_snackbar: HelpSnackbar = null

## Victory screen overlay (shown when level is cleared)
var victory_screen: CanvasLayer = null

## Defeat screen overlay (shown when furnace is destroyed)
var defeat_screen: CanvasLayer = null


## Track if we've shown the level hint (only show once per level load)
var has_shown_level_hint: bool = false

var is_paused: bool = false

## Saved player-placed tile data for soft restart (preserves placements after defeat)
## Array of dictionaries with keys: position (Vector2i), item_type (String), direction (String, optional), level (int, optional)
var saved_player_tiles: Array = []

## Level data
var current_level_data: LevelData = null

## Current heat value (starts at difficulty, increases over time during active phase)
var current_heat: int = 0

## Timer for heat increase during active phase
var heat_timer: Timer = null

## Hover highlight
var hover_highlight: ColorRect
var current_hover_cell: Vector2i = Vector2i(-1, -1)
var highlight_tween: Tween

## Drop target control for drag-and-drop
var drop_target: Control = null

## Track if we're currently dragging
var is_dragging: bool = false

## Bulk placement state - for click-to-select then drag-to-place workflow
var is_bulk_placing: bool = false
var bulk_placed_tiles: Array[Vector2i] = []
var had_selection_before_drag: bool = false


func _ready() -> void:
	_load_background()
	_load_level_data()
	_initialize_tile_system()
	# Hide grid overlay - grid is hidden on background
	grid_overlay.visible = false
	# _draw_grid()  # Disabled - grid is hidden
	_create_hover_highlight()
	_create_spawn_point_markers()
	
	# Reset game state for level, then override resources from level data if available
	GameManager.reset_for_level(GameManager.current_level)
	if current_level_data and current_level_data.starting_resources > 0:
		GameManager.resources = current_level_data.starting_resources
		GameManager.resources_changed.emit(GameManager.resources)
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
	
	# Create help snackbar
	_create_help_snackbar()
	
	# Create drop target for drag-and-drop
	_create_drop_target()
	
	# Create victory and defeat screen overlays
	_setup_victory_screen()
	_setup_defeat_screen()
	
	
	# Create debug controller (only in debug mode)
	if GameConfig.debug_mode:
		_setup_debug_controller()
	
	_update_ui()
	_start_build_phase()


## Find and setup UI references (GameSubmenu, BuildSubmenu)
func _setup_ui_references() -> void:
	# Path: UILayer/RightPanel/VBoxContainer/GameMenu/CenterContainer/VBoxContainer/...
	var game_menu := get_node_or_null("UILayer/RightPanel/VBoxContainer/GameMenu") as Control
	if game_menu:
		submenu_container = game_menu.get_node_or_null("CenterContainer/VBoxContainer") as VBoxContainer
		
		game_submenu = game_menu.get_node_or_null("CenterContainer/VBoxContainer/GameSubmenu") as GameSubmenu
		if game_submenu:
			game_submenu.start_pressed.connect(_on_start_pressed)
			game_submenu.set_level(GameManager.current_level)
			# Heat will be set after level data is loaded in _load_level_data()
		else:
			push_warning("GameScene: GameSubmenu not found")
		
		build_submenu = game_menu.get_node_or_null("CenterContainer/VBoxContainer/BuildSubmenu") as Control
		if not build_submenu:
			push_warning("GameScene: BuildSubmenu not found")
		else:
			# Connect details requested signal
			if build_submenu.has_signal("show_details_requested"):
				build_submenu.show_details_requested.connect(_on_show_details_requested)
		
		# Create and add details submenu
		_setup_details_submenu()
		
		# Create and add level in progress menu
		_setup_level_in_progress_menu()


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
	
	# Connect portal placement signals
	placement_manager.portal_placement_started.connect(_on_portal_placement_started)
	placement_manager.portal_placement_completed.connect(_on_portal_placement_completed)
	placement_manager.portal_placement_cancelled.connect(_on_portal_placement_cancelled)


## Setup the details submenu
func _setup_details_submenu() -> void:
	if not submenu_container:
		push_warning("GameScene: Cannot setup details submenu - no submenu container")
		return
	
	# Load and instantiate details submenu
	var details_scene := load("res://scenes/ui/details_submenu.tscn") as PackedScene
	if not details_scene:
		push_warning("GameScene: Failed to load details_submenu.tscn")
		return
	
	details_submenu = details_scene.instantiate() as Control
	if not details_submenu:
		push_warning("GameScene: Failed to instantiate details submenu")
		return
	
	# Add to container but hide initially
	submenu_container.add_child(details_submenu)
	details_submenu.visible = false
	
	# Connect close signal
	if details_submenu.has_signal("close_requested"):
		details_submenu.close_requested.connect(_on_details_close_requested)


## Handle show details requested from build submenu
func _on_show_details_requested(definition: BuildableItemDefinition) -> void:
	if not details_submenu or not build_submenu:
		return
	
	# Configure details submenu with item data
	if details_submenu.has_method("show_item_details"):
		details_submenu.show_item_details(definition)
	
	# Swap visibility
	build_submenu.visible = false
	details_submenu.visible = true


## Handle details submenu close requested
func _on_details_close_requested() -> void:
	if not details_submenu or not build_submenu:
		return
	
	# Swap visibility back
	details_submenu.visible = false
	build_submenu.visible = true


## Setup the level in progress menu (shown during active phase)
func _setup_level_in_progress_menu() -> void:
	if not submenu_container:
		push_warning("GameScene: Cannot setup level in progress menu - no submenu container")
		return
	
	# Load and instantiate level in progress menu
	var progress_scene := load("res://scenes/ui/level_in_progress_menu.tscn") as PackedScene
	if not progress_scene:
		push_warning("GameScene: Failed to load level_in_progress_menu.tscn")
		return
	
	level_in_progress_menu = progress_scene.instantiate() as Control
	if not level_in_progress_menu:
		push_warning("GameScene: Failed to instantiate level in progress menu")
		return
	
	# Add to container but hide initially
	submenu_container.add_child(level_in_progress_menu)
	level_in_progress_menu.visible = false
	
	# Connect signals
	if level_in_progress_menu.has_signal("pause_pressed"):
		level_in_progress_menu.pause_pressed.connect(_on_level_progress_pause_pressed)
	if level_in_progress_menu.has_signal("restart_requested"):
		level_in_progress_menu.restart_requested.connect(_on_level_progress_restart_requested)


## Handle pause pressed from level in progress menu
func _on_level_progress_pause_pressed() -> void:
	_toggle_pause()


## Handle restart requested from level in progress menu
func _on_level_progress_restart_requested() -> void:
	# Use soft restart to preserve player-placed tiles
	soft_restart_level()


## Setup the victory screen overlay
func _setup_victory_screen() -> void:
	var victory_scene := load("res://scenes/ui/victory_screen.tscn") as PackedScene
	if not victory_scene:
		push_warning("GameScene: Failed to load victory_screen.tscn")
		return
	
	victory_screen = victory_scene.instantiate() as CanvasLayer
	if not victory_screen:
		push_warning("GameScene: Failed to instantiate victory screen")
		return
	
	# Add to scene tree
	add_child(victory_screen)
	victory_screen.hide()
	
	# Connect signals
	if victory_screen.has_signal("continue_pressed"):
		victory_screen.continue_pressed.connect(_on_victory_continue)
	if victory_screen.has_signal("restart_pressed"):
		victory_screen.restart_pressed.connect(_on_victory_restart)


## Setup the defeat screen overlay
func _setup_defeat_screen() -> void:
	var defeat_scene := load("res://scenes/ui/defeat_screen.tscn") as PackedScene
	if not defeat_scene:
		push_warning("GameScene: Failed to load defeat_screen.tscn")
		return
	
	defeat_screen = defeat_scene.instantiate() as CanvasLayer
	if not defeat_screen:
		push_warning("GameScene: Failed to instantiate defeat screen")
		return
	
	# Add to scene tree
	add_child(defeat_screen)
	defeat_screen.hide()
	
	# Connect signals
	if defeat_screen.has_signal("menu_pressed"):
		defeat_screen.menu_pressed.connect(_on_defeat_menu)
	if defeat_screen.has_signal("restart_pressed"):
		defeat_screen.restart_pressed.connect(_on_defeat_restart)


## Handle victory screen continue button
func _on_victory_continue() -> void:
	SceneManager.goto_next_level()


## Handle victory screen restart button
func _on_victory_restart() -> void:
	# Use soft restart to preserve player-placed tiles
	soft_restart_level()


## Handle defeat screen main menu button
func _on_defeat_menu() -> void:
	SceneManager.goto_menu()


## Handle defeat screen restart button
func _on_defeat_restart() -> void:
	# Use soft restart to preserve player-placed tiles
	soft_restart_level()




func _process(_delta: float) -> void:
	_update_hover_highlight()




func _load_background() -> void:
	var bg_path := "res://assets/sprites/blast-deck-bg-full.png"
	if ResourceLoader.exists(bg_path):
		background.texture = load(bg_path)


func _load_level_data() -> void:
	# Try to load level data resource, or create default
	var level_path := "res://resources/levels/level_%d.tres" % GameManager.current_level
	if ResourceLoader.exists(level_path):
		current_level_data = load(level_path) as LevelData
		if not current_level_data:
			push_error("GameScene: Failed to load level data from %s, using default" % level_path)
			current_level_data = _create_default_level_data()
	else:
		# Create default level data for testing
		current_level_data = _create_default_level_data()
	
	# Initialize current heat from difficulty
	if current_level_data:
		current_heat = current_level_data.difficulty
		# Update EnemyManager with initial heat
		EnemyManager.current_heat = current_heat
		# Update heat display
		if game_submenu:
			game_submenu.set_heat(current_heat)


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
	
	# Default spawn rules (one rule per spawn point)
	var rule1 := SpawnEnemyRule.new()
	rule1.spawn_point_index = 0
	rule1.enemy_type = SpawnEnemyRule.EnemyType.BASIC
	rule1.spawn_delay = 0.0
	rule1.spawn_count = 6
	rule1.spawn_time = 60.0
	
	var rule2 := SpawnEnemyRule.new()
	rule2.spawn_point_index = 1
	rule2.enemy_type = SpawnEnemyRule.EnemyType.BASIC
	rule2.spawn_delay = 0.0
	rule2.spawn_count = 6
	rule2.spawn_time = 60.0
	
	var rule3 := SpawnEnemyRule.new()
	rule3.spawn_point_index = 2
	rule3.enemy_type = SpawnEnemyRule.EnemyType.BASIC
	rule3.spawn_delay = 0.0
	rule3.spawn_count = 6
	rule3.spawn_time = 60.0
	
	level_data.spawn_rules = [rule1, rule2, rule3]
	
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
	
	# Create visuals for preset walls and runes from level data
	_create_preset_structures()
	
	# Initialize EnemyManager with level data
	EnemyManager.initialize_wave(current_level_data, enemies_container)
	# Set initial heat value
	EnemyManager.current_heat = current_heat
	
	# Connect EnemyManager signals
	EnemyManager.all_enemies_defeated.connect(_on_all_enemies_defeated)
	EnemyManager.furnace_destroyed.connect(_on_furnace_destroyed)
	EnemyManager.debug_wave_restarted.connect(_on_debug_wave_restarted)
	EnemyManager.enemy_died.connect(_on_enemy_died)
	
	# Connect FireballManager signals
	FireballManager.fireball_destroyed.connect(_on_fireball_destroyed)
	FireballManager.fireball_enemy_hit.connect(_on_fireball_enemy_hit)
	
	# Update build menu with level data
	_update_build_menu()
	
	# Test pathfinding for all spawn points
	_test_pathfinding()


## Create visual structures for preset items and terrain from level data
func _create_preset_structures() -> void:
	if not current_level_data:
		return
	
	# Track portal runes for linking after creation
	var portal_entrances: Array[PortalRune] = []
	var portal_exits: Array[PortalRune] = []
	
	# Create wall visuals for terrain_blocked (immovable walls/terrain)
	if current_level_data.terrain_blocked.size() > 0:
		for terrain_pos in current_level_data.terrain_blocked:
			var wall_visual := _create_wall_visual(terrain_pos)
			if wall_visual:
				runes_container.add_child(wall_visual)
				# Update tile to reference this structure
				var tile := TileManager.get_tile(terrain_pos)
				if tile:
					tile.structure = wall_visual
	
	# Track all portals for smart linking (handles legacy levels without is_entrance)
	var all_portals: Array[PortalRune] = []
	
	# Create preset item visuals (walls, runes, etc.)
	for item_data in current_level_data.preset_items:
		var item_pos: Vector2i = item_data.get("position", Vector2i.ZERO)
		var item_type: String = item_data.get("type", "")
		var item_direction: String = item_data.get("direction", "south")
		var has_is_entrance: bool = item_data.has("is_entrance")
		var is_entrance: bool = item_data.get("is_entrance", true)  # Default to entrance for backwards compatibility
		
		# Get item definition to check if it has a scene
		var definition := GameConfig.get_item_definition(item_type)
		var item_visual: Node2D = null
		
		if definition and not definition.scene_path.is_empty():
			# Item has a scene - use scene-based visual (runes, explosive walls, etc.)
			item_visual = _create_item_visual(item_pos, item_type, item_direction, is_entrance)
		else:
			# No scene - use basic wall visual (for "wall" type)
			item_visual = _create_wall_visual(item_pos)
		
		if item_visual:
			runes_container.add_child(item_visual)
			
			# Determine occupancy type for TileManager
			var occupancy_type: TileBase.OccupancyType
			if item_type == "wall" or item_type == "explosive_wall":
				occupancy_type = TileBase.OccupancyType.WALL
			else:
				occupancy_type = TileBase.OccupancyType.RUNE
			
			# Register with TileManager so editing works
			# Mark as NOT player-placed (preset items can be edited but not sold)
			TileManager.set_occupancy(item_pos, occupancy_type, item_visual, false, item_type)
			
			# Verify occupancy was set correctly (defensive check)
			var verify_tile := TileManager.get_tile(item_pos)
			if verify_tile and verify_tile.occupancy == TileBase.OccupancyType.EMPTY:
				push_warning("GameScene: Occupancy not set correctly for preset item at %s (type: %s)" % [item_pos, item_type])
			
			# Track portal runes for linking
			if item_visual is PortalRune:
				var portal := item_visual as PortalRune
				all_portals.append(portal)
				
				# Only use entrance/exit tracking if level data explicitly specifies is_entrance
				if has_is_entrance:
					if portal.is_entrance:
						portal_entrances.append(portal)
					else:
						portal_exits.append(portal)
	
	# Link portal pairs
	# If we have explicit entrance/exit pairs, use those
	# Otherwise, link portals in order (1st with 2nd, 3rd with 4th, etc.)
	if portal_entrances.size() > 0 and portal_exits.size() > 0:
		_link_portal_pairs(portal_entrances, portal_exits)
	elif all_portals.size() >= 2:
		# Legacy mode: pair portals in order they appear
		_link_portal_pairs_legacy(all_portals)


## Create a visual for a preset wall
func _create_wall_visual(grid_pos: Vector2i) -> Node2D:
	var visual := Node2D.new()
	visual.name = "PresetWall_%d_%d" % [grid_pos.x, grid_pos.y]
	
	# Set z_index based on Y position for Y-sorting (higher Y = higher z_index, renders on top)
	# Walls should occlude enemies that are higher up on screen (lower Y) than the wall
	# Enemies use z_index = grid_y * 10, so walls use grid_pos.y * 10 + 5 to render above
	# This ensures walls at Y=5 (z_index=55) render above enemies at Y=3 (z_index=30)
	visual.z_index = grid_pos.y * 10 + 5
	
	# Load wall sprite
	var wall_texture := load("res://assets/sprites/wall.png") as Texture2D
	if wall_texture:
		var sprite := Sprite2D.new()
		sprite.texture = wall_texture
		# Position sprite so bottom aligns with tile bottom (for taller sprites)
		# Sprite is taller than tile, so offset upward by half the extra height
		var sprite_height := wall_texture.get_height()
		var tile_height := GameConfig.TILE_SIZE
		var offset_y := (sprite_height - tile_height) / 2.0
		sprite.position = Vector2(0, -offset_y)
		visual.add_child(sprite)
	else:
		# Fallback: Create a colored rectangle matching the wall definition
		var rect := ColorRect.new()
		var size := Vector2(GameConfig.TILE_SIZE - 4, GameConfig.TILE_SIZE - 4)
		rect.size = size
		rect.position = -size / 2.0
		rect.color = Color(0.5, 0.5, 0.5, 1.0)  # Gray for walls
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		visual.add_child(rect)
		
		# Add a "W" label
		var label := Label.new()
		label.text = "W"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size = size
		label.position = -size / 2.0
		label.add_theme_color_override("font_color", Color.WHITE)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		visual.add_child(label)
	
	# Position the visual
	visual.position = Vector2(
		grid_pos.x * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0,
		grid_pos.y * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0
	)
	
	return visual


## Create a visual for a preset item with a scene (runes, explosive walls, etc.)
func _create_item_visual(grid_pos: Vector2i, item_type: String, direction: String, is_entrance: bool = true) -> Node2D:
	# Get the item definition to find the scene path
	var definition := GameConfig.get_item_definition(item_type)
	if not definition:
		push_warning("GameScene: No definition found for item type: %s" % item_type)
		return null
	
	if definition.scene_path.is_empty():
		push_warning("GameScene: No scene path for item type: %s" % item_type)
		return null
	
	# For portals, use the correct scene based on is_entrance
	var scene_path: String = definition.scene_path
	if item_type == "portal" and not is_entrance:
		# Use paired_scene_path for portal exits
		if not definition.paired_scene_path.is_empty():
			scene_path = definition.paired_scene_path
	
	var scene := load(scene_path) as PackedScene
	if not scene:
		push_warning("GameScene: Failed to load item scene: %s" % scene_path)
		return null
	
	var item_node := scene.instantiate()
	if not item_node:
		push_warning("GameScene: Failed to instantiate item scene")
		return null
	
	# Set position and direction
	if item_node is RuneBase:
		var rune := item_node as RuneBase
		rune.set_grid_position(grid_pos)
		
		# Set direction (redirect runes and portal runes use set_direction_by_string)
		if rune.has_method("set_direction_by_string"):
			rune.set_direction_by_string(direction)
		elif rune.has_method("set_direction"):
			# Fallback for other item types that might use Vector2 direction
			var dir_vector := _direction_string_to_vector(direction)
			rune.set_direction(dir_vector)
	elif item_node.has_method("set_grid_position"):
		# Handle other entities that have set_grid_position (like ExplosiveWall)
		item_node.set_grid_position(grid_pos)
	elif item_node is Node2D:
		(item_node as Node2D).position = Vector2(
			grid_pos.x * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0,
			grid_pos.y * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0
		)
	
	return item_node


## Link portal pairs (entrance to exit in order of creation)
func _link_portal_pairs(entrances: Array[PortalRune], exits: Array[PortalRune]) -> void:
	var pair_count := mini(entrances.size(), exits.size())
	
	if entrances.size() != exits.size():
		push_warning("GameScene: Mismatched portal count - %d entrances, %d exits" % [entrances.size(), exits.size()])
	
	for i in range(pair_count):
		var entrance := entrances[i]
		var exit := exits[i]
		entrance.link_to(exit)
		print("GameScene: Linked portal pair %d - entrance at %s, exit at %s" % [i, entrance.grid_position, exit.grid_position])


## Link portal pairs for legacy levels without is_entrance field
## Pairs portals in order: 1st with 2nd, 3rd with 4th, etc.
## Both portals in a pair can teleport to each other (bidirectional)
func _link_portal_pairs_legacy(portals: Array[PortalRune]) -> void:
	var pair_count := portals.size() / 2
	
	if portals.size() % 2 != 0:
		push_warning("GameScene: Odd number of portals (%d) - last one will be unlinked" % portals.size())
	
	for i in range(pair_count):
		var portal_a := portals[i * 2]
		var portal_b := portals[i * 2 + 1]
		portal_a.link_to(portal_b)  # This also sets portal_b.linked_portal = portal_a
		print("GameScene: Linked legacy portal pair %d - %s <-> %s" % [i, portal_a.grid_position, portal_b.grid_position])


## Convert direction string to Vector2
func _direction_string_to_vector(direction: String) -> Vector2:
	match direction:
		"north":
			return Vector2.UP
		"south":
			return Vector2.DOWN
		"east":
			return Vector2.RIGHT
		"west":
			return Vector2.LEFT
		_:
			return Vector2.DOWN


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
	
	# Skip hover highlight updates when in debug placement mode (let debug highlights stay)
	if debug_controller and debug_controller.is_in_placement_mode():
		hover_highlight.color.a = 0.0
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
		elif tile.structure:
			tile.set_highlight(true, "hover")  # Has structure (editable)
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
	# Path: UILayer/RightPanel/VBoxContainer/GameMenu/CenterContainer/VBoxContainer/BuildSubmenu
	var game_menu := get_node_or_null("UILayer/RightPanel/VBoxContainer/GameMenu") as Control
	if game_menu:
		var build_submenu := game_menu.get_node_or_null("CenterContainer/VBoxContainer/BuildSubmenu") as Control
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
	
	# Clear registered spawn markers in EnemyManager
	EnemyManager.clear_spawn_markers()
	
	# Create markers for each spawn point
	var marker_scene := load("res://scenes/tiles/spawn_point_marker.tscn")
	if marker_scene:
		for i in range(current_level_data.spawn_points.size()):
			var spawn_pos := current_level_data.spawn_points[i]
			var marker_node: Node = marker_scene.instantiate()
			if not marker_node:
				push_error("Failed to instantiate spawn_point_marker.tscn")
				continue
			var marker: SpawnPointMarker = marker_node as SpawnPointMarker
			if not marker:
				push_error("Spawn point marker is not a SpawnPointMarker")
				continue
			marker.position = Vector2(
				spawn_pos.x * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0,
				spawn_pos.y * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0
			)
			marker.spawn_index = i
			spawn_points_container.add_child(marker)
			
			# Register marker with EnemyManager for spawn notifications
			EnemyManager.register_spawn_marker(i, marker)


# Called when all enemies are defeated
func _on_all_enemies_defeated() -> void:
	print("GameScene: All enemies defeated - VICTORY!")
	win_level()


# Called when enemy reaches furnace
func _on_furnace_destroyed() -> void:
	print("GameScene: Furnace destroyed - DEFEAT!")
	AudioManager.play_sound_effect("furnace-death")
	lose_level()


# Called when debug wave restarts (immune mode only)
func _on_debug_wave_restarted() -> void:
	print("GameScene: [DEBUG] Wave restarted - clearing fireball and respawning...")
	# Clear existing fireball before spawning new one (full level reset)
	FireballManager.clear_all_fireballs()
	_launch_fireball()


# Called when an enemy dies
func _on_enemy_died(enemy: EnemyBase) -> void:
	# Validate enemy is actually dead (safety check)
	if not is_instance_valid(enemy):
		return
	
	# Update soot vanquished stat in level progress menu
	# Note: EnemyManager already validates death before emitting signal, so we can trust this
	if GameManager.current_state == GameManager.GameState.ACTIVE_PHASE:
		if level_in_progress_menu:
			var in_progress: Control = null
			if level_in_progress_menu.has_method("get_in_progress_submenu"):
				in_progress = level_in_progress_menu.get_in_progress_submenu()
			if in_progress and in_progress.has_method("add_soot_vanquished"):
				in_progress.add_soot_vanquished(1)


func _input(event: InputEvent) -> void:
	# Toggle path preview with 'P' key (only in build phase)
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		if GameManager.current_state == GameManager.GameState.BUILD_PHASE and path_preview:
			path_preview.visible = not path_preview.visible
			path_preview.queue_redraw()
	
	# Handle escape key - cancel selection or open pause menu
	if event.is_action_pressed("ui_cancel"):
		# First, check if we're in debug placement mode
		if debug_controller and debug_controller.is_in_placement_mode():
			debug_controller.cancel_placement()
			get_viewport().set_input_as_handled()
			return
		
		if GameManager.current_state == GameManager.GameState.BUILD_PHASE:
			# End any bulk placement in progress
			_end_bulk_placement()
			
			# First, check if we're in portal exit placement mode
			if placement_manager and placement_manager.is_in_portal_exit_mode():
				placement_manager.cancel_portal_placement()
				_hide_tile_tooltip()
				get_viewport().set_input_as_handled()
				return
			# Next, try to cancel any active selection
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
		elif GameManager.current_state == GameManager.GameState.ACTIVE_PHASE:
			# In active phase, just hide tile tooltip if visible
			if tile_tooltip and tile_tooltip.visible:
				_hide_tile_tooltip()
				get_viewport().set_input_as_handled()
				return
		# Otherwise, toggle pause menu
		_toggle_pause()
	
	# Handle mouse clicks during build phase
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Handle debug placement mode clicks first (left click = place)
			if debug_controller and debug_controller.is_in_placement_mode():
				var grid_pos := _get_grid_pos_from_mouse()
				if grid_pos != Vector2i(-1, -1):
					debug_controller.handle_placement_click(grid_pos)
				return
			
			if GameManager.current_state == GameManager.GameState.BUILD_PHASE:
				# Skip if click is over the sell tooltip (let button handle it)
				if _is_mouse_over_tile_tooltip():
					return
				
				# Check if we have a selection BEFORE processing the click
				# This enables bulk placement only for "click to select, then drag to place" workflow
				had_selection_before_drag = placement_manager and placement_manager.has_selection()
				
				_handle_build_phase_click()
				
				# Start bulk placement if we had a selection and placed successfully
				if had_selection_before_drag and placement_manager and placement_manager.has_selection():
					var grid_pos := _get_grid_pos_from_mouse()
					if grid_pos != Vector2i(-1, -1):
						is_bulk_placing = true
						bulk_placed_tiles.clear()
						bulk_placed_tiles.append(grid_pos)
			elif GameManager.current_state == GameManager.GameState.ACTIVE_PHASE:
				# Skip if click is over the tile tooltip (let button handle it)
				if _is_mouse_over_tile_tooltip():
					return
				_handle_active_phase_click()
		else:
			# Mouse button released - end bulk placement
			_end_bulk_placement()
	
	# Handle mouse motion for bulk placement during drag
	if event is InputEventMouseMotion:
		if is_bulk_placing and GameManager.current_state == GameManager.GameState.BUILD_PHASE:
			_handle_bulk_placement_drag()
	
	# Handle right-click for debug placement mode (right click = remove)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if debug_controller and debug_controller.is_in_placement_mode():
			var grid_pos := _get_grid_pos_from_mouse()
			if grid_pos != Vector2i(-1, -1):
				debug_controller.handle_removal_click(grid_pos)
			return


func _toggle_pause() -> void:
	if GameManager.current_state == GameManager.GameState.PAUSED:
		pause_menu.hide_pause_menu()
		GameManager.resume_game()
		is_paused = false
		# Resume heat timer if in active phase
		if GameManager.current_state == GameManager.GameState.ACTIVE_PHASE:
			_start_heat_timer()
	elif GameManager.current_state == GameManager.GameState.BUILD_PHASE or GameManager.current_state == GameManager.GameState.ACTIVE_PHASE:
		GameManager.pause_game()
		pause_menu.show_pause_menu()
		is_paused = true
		# Pause heat timer
		_stop_heat_timer()


func _start_build_phase() -> void:
	GameManager.start_build_phase()
	right_panel.show()
	active_ui.hide()
	# Show path preview in build phase
	if path_preview:
		path_preview.set_visible(true)
		path_preview.update_paths(current_level_data)
	
	# Stop heat increase timer
	_stop_heat_timer()
	
	# Reset heat to base difficulty when returning to build phase
	if current_level_data:
		current_heat = current_level_data.difficulty
		EnemyManager.current_heat = current_heat
		if game_submenu:
			game_submenu.set_heat(current_heat)
	
	# Show build submenu, hide level in progress menu
	if build_submenu:
		build_submenu.visible = true
	if details_submenu:
		details_submenu.visible = false
	if level_in_progress_menu:
		level_in_progress_menu.visible = false
	if game_submenu:
		game_submenu.visible = true
	
	# Show level hint snackbar (only on initial level start, not when returning from active phase)
	_show_level_hint()
	


func _start_active_phase() -> void:
	GameManager.start_active_phase()
	right_panel.show()  # Keep right panel visible but swap content
	# active_ui.hide()  # Removed - no longer needed with level progress menu
	
	# Track sparks at phase start for earned calculation
	sparks_at_phase_start = GameManager.resources
	
	# Initialize heat to base difficulty
	if current_level_data:
		current_heat = current_level_data.difficulty
		EnemyManager.current_heat = current_heat
	
	# Start heat increase timer if configured
	if current_level_data and current_level_data.heat_increase_interval > 0.0:
		_start_heat_timer()
	
	# Hide build submenus, show level in progress menu
	if build_submenu:
		build_submenu.visible = false
	if details_submenu:
		details_submenu.visible = false
	if game_submenu:
		game_submenu.visible = false
	if level_in_progress_menu:
		level_in_progress_menu.visible = true
		# Set current level and reset stats
		if level_in_progress_menu.has_method("set_level"):
			level_in_progress_menu.set_level(GameManager.current_level)
		if level_in_progress_menu.has_method("reset_stats"):
			level_in_progress_menu.reset_stats()
		# Set total enemies for progress bar
		if level_in_progress_menu.has_method("set_total_enemies") and current_level_data:
			level_in_progress_menu.set_total_enemies(current_level_data.get_total_enemy_count())
		# Set initial heat display
		if level_in_progress_menu.has_method("set_heat"):
			level_in_progress_menu.set_heat(current_heat)
	
	# Start enemy wave
	EnemyManager.start_wave()
	
	_launch_fireball()


func _launch_fireball() -> void:
	# Wait 1 second before launching
	await get_tree().create_timer(1.0).timeout
	
	# Don't launch if game state changed (e.g., paused or game over)
	if GameManager.current_state != GameManager.GameState.ACTIVE_PHASE:
		return
	
	# Calculate spawn position (above furnace tile)
	var furnace_pos := current_level_data.furnace_position
	var spawn_world_pos := Vector2(
		furnace_pos.x * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0,
		-GameConfig.TILE_SIZE / 2.0  # Above the grid
	)
	
	# Use FireballManager to spawn (handles cleanup and prevents duplicates)
	var fireball := await FireballManager.spawn_fireball(spawn_world_pos, game_board)
	if not fireball:
		print("GameScene: Failed to spawn fireball (may already be active)")
		return
	
	# Play fireball spawn sound
	AudioManager.play_sound_effect("fireball-spawn")


func _on_start_pressed() -> void:
	_start_active_phase()


func _on_resources_changed(new_amount: int) -> void:
	_update_ui()
	
	# Track sparks earned during active phase
	if GameManager.current_state == GameManager.GameState.ACTIVE_PHASE and level_in_progress_menu:
		var delta := new_amount - sparks_at_phase_start
		if delta > 0:
			var in_progress: Control = null
			if level_in_progress_menu.has_method("get_in_progress_submenu"):
				in_progress = level_in_progress_menu.get_in_progress_submenu()
			if in_progress and in_progress.has_method("set_sparks_earned"):
				in_progress.set_sparks_earned(delta)


func _on_state_changed(new_state: GameManager.GameState) -> void:
	# End bulk placement on any state change
	_end_bulk_placement()
	
	match new_state:
		GameManager.GameState.BUILD_PHASE:
			right_panel.show()
			active_ui.hide()
			# Show path preview in build phase (if it exists)
			if path_preview:
				path_preview.set_preview_visible(true)
			# Show build submenus, hide level in progress menu
			if build_submenu:
				build_submenu.visible = true
			if game_submenu:
				game_submenu.visible = true
			if details_submenu:
				details_submenu.visible = false
			if level_in_progress_menu:
				level_in_progress_menu.visible = false
		GameManager.GameState.ACTIVE_PHASE:
			right_panel.show()  # Keep visible for level in progress menu
			# active_ui.hide()  # Removed - no longer needed with level progress menu
			# Hide path preview in active phase (if it exists)
			if path_preview:
				path_preview.set_preview_visible(false)
			# Hide build submenus, show level in progress menu
			if build_submenu:
				build_submenu.visible = false
			if game_submenu:
				game_submenu.visible = false
			if details_submenu:
				details_submenu.visible = false
			if level_in_progress_menu:
				level_in_progress_menu.visible = true
		GameManager.GameState.GAME_OVER:
			SceneManager.goto_game_over(GameManager.game_won)


func _update_ui() -> void:
	# GameSubmenu handles its own updates via GameManager signals
	# This is now just for any other UI elements that need updating
	if game_submenu:
		game_submenu.set_level(GameManager.current_level)
		if current_level_data:
			game_submenu.set_heat(current_heat)


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
	# Stop heat timer
	_stop_heat_timer()
	
	# Get stats from active phase
	var stats := _get_active_phase_stats()
	
	# Show victory screen overlay (don't navigate away)
	if victory_screen:
		victory_screen.show_screen(GameManager.current_level, stats)


## Called when furnace is destroyed
func lose_level() -> void:
	# Stop heat timer
	_stop_heat_timer()
	
	# Get stats from active phase
	var stats := _get_active_phase_stats()
	
	# Show defeat screen overlay (don't navigate away)
	if defeat_screen:
		defeat_screen.show_screen(GameManager.current_level, stats)


## Get stats from the active phase for end-of-level screens
func _get_active_phase_stats() -> Dictionary:
	var stats := {
		"soot": 0,
		"sparks": 0,
		"damage": 0
	}
	
	if level_in_progress_menu:
		var in_progress: Control = null
		if level_in_progress_menu.has_method("get_in_progress_submenu"):
			in_progress = level_in_progress_menu.get_in_progress_submenu()
		if in_progress:
			if "soot_vanquished" in in_progress:
				stats["soot"] = in_progress.soot_vanquished
			if "damage_dealt" in in_progress:
				stats["damage"] = in_progress.damage_dealt
			# Get sparks_spent from the StatsDisplay child component
			if "stats_display" in in_progress and in_progress.stats_display:
				if "sparks_spent" in in_progress.stats_display:
					stats["sparks"] = in_progress.stats_display.sparks_spent
	
	return stats


## Get grid position from current mouse position
func _get_grid_pos_from_mouse() -> Vector2i:
	var mouse_pos := get_global_mouse_position()
	var grid_pos_local := mouse_pos - game_board.global_position
	
	var cell_x := int(grid_pos_local.x / GameConfig.TILE_SIZE)
	var cell_y := int(grid_pos_local.y / GameConfig.TILE_SIZE)
	
	if cell_x < 0 or cell_x >= GameConfig.GRID_COLUMNS or cell_y < 0 or cell_y >= GameConfig.GRID_ROWS:
		return Vector2i(-1, -1)
	
	return Vector2i(cell_x, cell_y)


## Handle clicks during build phase
func _handle_build_phase_click() -> void:
	if not placement_manager:
		return
	
	# Prevent tile placement when debug menu is open
	if debug_controller and debug_controller.debug_modal and debug_controller.debug_modal.visible:
		return
	
	# Prevent tile placement when spawn edit modal is open
	if debug_controller and debug_controller.spawn_edit_modal and debug_controller.spawn_edit_modal.visible:
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
	
	# In debug mode, check if clicking on a spawn point
	if GameConfig.debug_mode and debug_controller:
		if debug_controller.try_handle_spawn_point_click(grid_pos):
			# Mark input as handled so it doesn't propagate to the modal's background
			get_viewport().set_input_as_handled()
			return  # Spawn edit modal was opened
	
	# If item is selected, try to place it
	if placement_manager.has_selection():
		placement_manager.try_place_item(grid_pos)
	else:
		# No item selected - check if clicking on a tile with a structure (for editing/selling)
		var tile := TileManager.get_tile(grid_pos)
		if tile and tile.structure:
			_show_tile_tooltip(grid_pos)


## Handle clicks during active phase (for runes editable during active phase)
func _handle_active_phase_click() -> void:
	# Check if click is on the game board
	var mouse_pos := get_global_mouse_position()
	var grid_pos_local := mouse_pos - game_board.global_position
	
	# Check if within grid bounds
	var cell_x := int(grid_pos_local.x / GameConfig.TILE_SIZE)
	var cell_y := int(grid_pos_local.y / GameConfig.TILE_SIZE)
	
	if cell_x < 0 or cell_x >= GameConfig.GRID_COLUMNS or cell_y < 0 or cell_y >= GameConfig.GRID_ROWS:
		_hide_tile_tooltip()
		return
	
	var grid_pos := Vector2i(cell_x, cell_y)
	
	# Hide any existing tooltip first
	_hide_tile_tooltip()
	
	# Check if there's a rune that's editable during active phase
	var tile := TileManager.get_tile(grid_pos)
	if not tile or not tile.structure:
		return
	
	# Check if the structure is a rune that can be edited during active phase
	if tile.structure is RuneBase:
		var rune := tile.structure as RuneBase
		if rune.is_editable_in_active_phase():
			_show_tile_tooltip_active_phase(grid_pos, tile.structure)


## Handle mouse drag during bulk placement
func _handle_bulk_placement_drag() -> void:
	if not placement_manager or not placement_manager.has_selection():
		_end_bulk_placement()
		return
	
	var grid_pos := _get_grid_pos_from_mouse()
	if grid_pos == Vector2i(-1, -1):
		return
	
	# Skip if we've already placed on this tile during this drag
	if grid_pos in bulk_placed_tiles:
		return
	
	# Skip items that require paired placement (portals) - bulk placement doesn't make sense for these
	var definition := placement_manager.get_selected_definition()
	if definition and definition.requires_paired_placement:
		_end_bulk_placement()
		return
	
	# Try to place the item
	if placement_manager.try_place_item(grid_pos):
		bulk_placed_tiles.append(grid_pos)


## End bulk placement mode
func _end_bulk_placement() -> void:
	is_bulk_placing = false
	bulk_placed_tiles.clear()
	had_selection_before_drag = false


## Show tile tooltip during active phase (direction controls only, no sell/upgrade buttons)
func _show_tile_tooltip_active_phase(grid_pos: Vector2i, structure: Node) -> void:
	if not tile_tooltip:
		return
	
	# Calculate tile's screen position (top-left corner)
	var tile_screen_pos := Vector2(
		grid_pos.x * GameConfig.TILE_SIZE + game_board.position.x,
		grid_pos.y * GameConfig.TILE_SIZE + game_board.position.y
	)
	
	# Calculate best position using helper (avoids covering tile and stays on screen)
	var tile_size := Vector2(GameConfig.TILE_SIZE, GameConfig.TILE_SIZE)
	var viewport_size := Vector2(GameConfig.VIEWPORT_WIDTH, GameConfig.VIEWPORT_HEIGHT)
	var tooltip_pos := tile_tooltip.calculate_best_position(tile_screen_pos, tile_size, viewport_size)
	
	# Show tooltip with direction controls but NO sell button and NO upgrade button
	tile_tooltip.show_for_tile(grid_pos, 0, tooltip_pos, true, structure, false, false)


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
	
	# Also create the info snackbar
	_create_info_snackbar()


## Create the info snackbar (for portal placement messages)
func _create_info_snackbar() -> void:
	info_snackbar = PanelContainer.new()
	info_snackbar.name = "InfoSnackbar"
	
	var label := Label.new()
	label.name = "Label"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	info_snackbar.add_child(label)
	
	# Style (blue/info color)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.5, 0.8, 0.9)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(8)
	info_snackbar.add_theme_stylebox_override("panel", style)
	
	# Position at top center (above game board)
	info_snackbar.position = Vector2(GameConfig.VIEWPORT_WIDTH / 2.0 - 100, 10)
	info_snackbar.custom_minimum_size = Vector2(200, 30)
	info_snackbar.visible = false
	
	# Add to UI layer
	var ui_layer := get_node_or_null("UILayer") as CanvasLayer
	if ui_layer:
		ui_layer.add_child(info_snackbar)


## Create the help snackbar (for level hints at start)
func _create_help_snackbar() -> void:
	var help_scene := load("res://scenes/ui/help_snackbar.tscn") as PackedScene
	if not help_scene:
		push_warning("GameScene: Failed to load help_snackbar.tscn")
		return
	
	help_snackbar = help_scene.instantiate() as HelpSnackbar
	if not help_snackbar:
		push_warning("GameScene: Failed to instantiate help snackbar")
		return
	
	# Add to UI layer
	var ui_layer := get_node_or_null("UILayer") as CanvasLayer
	if ui_layer:
		ui_layer.add_child(help_snackbar)


## Show help snackbar with level hint (if available, only once per level load)
func _show_level_hint() -> void:
	if has_shown_level_hint:
		return
	
	if not help_snackbar or not current_level_data:
		return
	
	if current_level_data.hint_text.is_empty():
		return
	
	has_shown_level_hint = true
	help_snackbar.show_hint(current_level_data.hint_text)


## Show info snackbar with message (stays visible until hidden)
func _show_info_snackbar(message: String) -> void:
	if not info_snackbar:
		return
	
	var label := info_snackbar.get_node_or_null("Label") as Label
	if label:
		label.text = message
	
	info_snackbar.modulate.a = 1.0
	info_snackbar.visible = true


## Hide info snackbar
func _hide_info_snackbar() -> void:
	if info_snackbar:
		info_snackbar.visible = false


## Handle portal placement started
func _on_portal_placement_started() -> void:
	_show_info_snackbar("Place portal exit (ESC to cancel)")


## Handle portal placement completed
func _on_portal_placement_completed() -> void:
	_hide_info_snackbar()


## Handle portal placement cancelled
func _on_portal_placement_cancelled() -> void:
	_hide_info_snackbar()


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
	
	# Connect to upgrade request signal
	tile_tooltip.upgrade_requested.connect(_on_upgrade_requested)
	
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
	var is_player_placed: bool = false
	
	if tile:
		structure = tile.structure
		is_player_placed = tile.is_player_placed
	
	if definition.has_method("get") or "has_direction" in definition:
		has_direction = definition.has_direction
	
	# Calculate tile's screen position (top-left corner)
	var tile_screen_pos := Vector2(
		grid_pos.x * GameConfig.TILE_SIZE + game_board.position.x,
		grid_pos.y * GameConfig.TILE_SIZE + game_board.position.y
	)
	
	# Calculate best position using helper (avoids covering tile and stays on screen)
	var tile_size := Vector2(GameConfig.TILE_SIZE, GameConfig.TILE_SIZE)
	var viewport_size := Vector2(GameConfig.VIEWPORT_WIDTH, GameConfig.VIEWPORT_HEIGHT)
	var tooltip_pos := tile_tooltip.calculate_best_position(tile_screen_pos, tile_size, viewport_size)
	
	# Only show sell button for player-placed items (not preset items)
	tile_tooltip.show_for_tile(grid_pos, definition.cost, tooltip_pos, has_direction, structure, is_player_placed)


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


## Handle upgrade request from tooltip
func _on_upgrade_requested(grid_pos: Vector2i) -> void:
	# Get the tile and structure
	var tile := TileManager.get_tile(grid_pos)
	if not tile or not tile.structure:
		return
	
	# Check if structure is a rune that can be upgraded
	if tile.structure is RuneBase:
		var rune := tile.structure as RuneBase
		if rune.can_upgrade():
			var upgrade_cost := rune.get_upgrade_cost()
			
			# Check if player has enough resources
			if not GameManager.infinite_money and GameManager.resources < upgrade_cost:
				_show_error_snackbar("Not enough money!")
				return
			
			# Spend resources and upgrade
			if GameManager.spend_resources(upgrade_cost):
				rune.upgrade()
				print("GameScene: Upgraded rune at %s to level %d" % [grid_pos, rune.current_level])


## Handle placement failed signal
func _on_placement_failed(reason: String) -> void:
	AudioManager.play_sound_effect("invalid-action")
	_show_error_snackbar(reason)


## Handle placement succeeded signal
func _on_placement_succeeded(_item_type: String, _grid_pos: Vector2i) -> void:
	AudioManager.play_sound_effect("structure-buy")


## Handle item sold signal
func _on_item_sold(_item_type: String, _grid_pos: Vector2i, _refund_amount: int) -> void:
	AudioManager.play_sound_effect("structure-sell")
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
	# Basic validation - fireball already checks enemy was alive before emitting
	if not is_instance_valid(enemy):
		return
	
	# Track damage dealt during active phase (including killing blows)
	if GameManager.current_state == GameManager.GameState.ACTIVE_PHASE:
		if level_in_progress_menu:
			var in_progress: Control = null
			if level_in_progress_menu.has_method("get_in_progress_submenu"):
				in_progress = level_in_progress_menu.get_in_progress_submenu()
			if in_progress and in_progress.has_method("add_damage_dealt"):
				in_progress.add_damage_dealt(damage)


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
	
	# Prevent tile placement when debug menu is open
	if debug_controller and debug_controller.debug_modal and debug_controller.debug_modal.visible:
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
	
	# Clear selection after drop, BUT NOT if we're now in portal exit placement mode
	# (Portal placement is a two-step process - entrance then exit)
	if not placement_manager.is_in_portal_exit_mode():
		placement_manager.clear_selection()


## Setup the debug mode controller (only called when debug_mode is true)
func _setup_debug_controller() -> void:
	debug_controller = DebugModeController.new()
	add_child(debug_controller)
	
	# Get UI layer reference
	var ui_layer := get_node_or_null("UILayer") as CanvasLayer
	
	# Initialize with required references
	debug_controller.initialize(ui_layer, game_board, spawn_points_container, current_level_data)
	
	# Connect signals to snackbar display
	debug_controller.show_info_requested.connect(_show_info_snackbar)
	debug_controller.hide_info_requested.connect(_hide_info_snackbar)
	debug_controller.show_error_requested.connect(_show_error_snackbar)
	
	# Connect level reload signal
	debug_controller.reload_level_requested.connect(_on_reload_level_requested)
	
	# Connect structure removal signal
	debug_controller.structure_removal_requested.connect(_on_structure_removal_requested)
	
	# Connect items unlocked changed signal
	debug_controller.items_unlocked_changed.connect(_on_items_unlocked_changed)


## Handle items unlocked changed (refresh build menu)
func _on_items_unlocked_changed() -> void:
	if build_submenu and build_submenu.has_method("set_level_data"):
		build_submenu.set_level_data(current_level_data)
		print("GameScene: Build menu refreshed due to items unlocked change")


## Handle structure removal request (remove rune/wall visual from game board)
func _on_structure_removal_requested(grid_pos: Vector2i) -> void:
	# Find and remove the structure node from runes_container
	for child in runes_container.get_children():
		if child is Node2D:
			# Check position (structures are positioned at tile center)
			var expected_pos := Vector2(
				grid_pos.x * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0,
				grid_pos.y * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0
			)
			if child.position.distance_to(expected_pos) < 1.0:
				child.queue_free()
				print("GameScene: Removed structure visual at %s" % grid_pos)
				return
	
	# Also check if it's a RuneBase with grid position
	for child in runes_container.get_children():
		if child is RuneBase:
			var rune := child as RuneBase
			if rune.grid_position == grid_pos:
				child.queue_free()
				print("GameScene: Removed rune visual at %s" % grid_pos)
				return


## Handle reload level request (hot-reload after level save)
func _on_reload_level_requested(level_number: int) -> void:
	print("GameScene: Hot-reloading level %d..." % level_number)
	reload_level(level_number)


## Hot-reload a level without restarting the scene
func reload_level(level_number: int) -> void:
	# Clear current game state
	_clear_game_state()
	
	# Reset hint flag so it shows again after reload
	has_shown_level_hint = false
	
	# Force-reload the level resource (bypass cache)
	var level_path := "res://resources/levels/level_%d.tres" % level_number
	current_level_data = ResourceLoader.load(level_path, "", ResourceLoader.CACHE_MODE_REPLACE) as LevelData
	
	if not current_level_data:
		push_error("GameScene: Failed to reload level data from %s" % level_path)
		current_level_data = _create_default_level_data()
	
	# Update game manager
	GameManager.current_level = level_number
	GameManager.reset_for_level(level_number)
	# Override resources from level data if available
	if current_level_data and current_level_data.starting_resources > 0:
		GameManager.resources = current_level_data.starting_resources
		GameManager.resources_changed.emit(GameManager.resources)
	
	# Reinitialize the tile system
	_initialize_tile_system()
	
	# Recreate spawn point markers
	_create_spawn_point_markers()
	
	# Update build menu
	_update_build_menu()
	
	# Update placement manager with new level data
	if placement_manager:
		placement_manager.set_level_data(current_level_data)
	
	# Update debug controller with new level data
	if debug_controller:
		debug_controller.current_level_data = current_level_data
		# Clear debug-placed spawn points and terrain (they're now in the level file)
		debug_controller.debug_spawn_points.clear()
		debug_controller.debug_terrain_tiles.clear()
		# Clear removed items (they're now removed from the level file)
		debug_controller.removed_spawn_points.clear()
		debug_controller.removed_terrain_tiles.clear()
		debug_controller.removed_items.clear()
	
	# Update path preview
	if path_preview:
		path_preview.update_paths(current_level_data)
	
	# Update game submenu
	if game_submenu:
		game_submenu.set_level(level_number)
		if current_level_data:
			current_heat = current_level_data.difficulty
			EnemyManager.current_heat = current_heat
			game_submenu.set_heat(current_heat)
	
	# Ensure we're in build phase
	_start_build_phase()
	
	print("GameScene: Level %d hot-reloaded successfully!" % level_number)
	_show_info_snackbar("Level %d reloaded!" % level_number)
	
	# Auto-hide after 2 seconds
	var tween := create_tween()
	tween.tween_interval(2.0)
	tween.tween_callback(func(): _hide_info_snackbar())


## Start heat increase timer
func _start_heat_timer() -> void:
	if not current_level_data or current_level_data.heat_increase_interval <= 0.0:
		return
	
	# Stop existing timer if any
	_stop_heat_timer()
	
	# Create new timer
	heat_timer = Timer.new()
	heat_timer.wait_time = current_level_data.heat_increase_interval
	heat_timer.timeout.connect(_on_heat_timer_timeout)
	heat_timer.autostart = true
	add_child(heat_timer)


## Stop heat increase timer
func _stop_heat_timer() -> void:
	if heat_timer:
		if is_instance_valid(heat_timer):
			heat_timer.queue_free()
		heat_timer = null


## Handle heat timer timeout - increase heat by 1
func _on_heat_timer_timeout() -> void:
	if GameManager.current_state != GameManager.GameState.ACTIVE_PHASE:
		_stop_heat_timer()
		return
	
	current_heat += 1
	
	# Update EnemyManager with new heat value (affects future spawns)
	EnemyManager.current_heat = current_heat
	
	# Update heat display - use level_in_progress_menu during active phase
	if level_in_progress_menu and level_in_progress_menu.has_method("set_heat"):
		level_in_progress_menu.set_heat(current_heat)
	elif game_submenu:
		# Fallback to game_submenu if level_in_progress_menu not available
		game_submenu.set_heat(current_heat)
	
	print("GameScene: Heat increased to %d" % current_heat)


## Save the current player-placed tile state for restoration after restart
func _save_player_placed_tiles() -> void:
	saved_player_tiles.clear()
	
	for x in range(GameConfig.GRID_COLUMNS):
		for y in range(GameConfig.GRID_ROWS):
			var grid_pos := Vector2i(x, y)
			var tile := TileManager.get_tile(grid_pos)
			
			if not tile or not tile.is_player_placed:
				continue
			
			if tile.occupancy == TileBase.OccupancyType.EMPTY:
				continue
			
			var tile_data := {
				"position": grid_pos,
				"item_type": tile.placed_item_type,
			}
			
			# Save direction if this is a redirect rune
			if tile.structure is RedirectRune:
				var redirect := tile.structure as RedirectRune
				var dir_str: String
				match redirect.direction:
					RedirectRune.Direction.NORTH:
						dir_str = "north"
					RedirectRune.Direction.SOUTH:
						dir_str = "south"
					RedirectRune.Direction.EAST:
						dir_str = "east"
					RedirectRune.Direction.WEST:
						dir_str = "west"
				tile_data["direction"] = dir_str
			
			# Save current level if upgraded
			if tile.structure is RuneBase:
				var rune := tile.structure as RuneBase
				if rune.current_level > 1:
					tile_data["level"] = rune.current_level
			
			# Save portal links - we need to track paired portals
			if tile.structure is PortalRune:
				var portal := tile.structure as PortalRune
				tile_data["is_entrance"] = portal.is_entrance
				if portal.linked_portal and is_instance_valid(portal.linked_portal):
					tile_data["linked_position"] = portal.linked_portal.grid_position
			
			saved_player_tiles.append(tile_data)
	
	print("GameScene: Saved %d player-placed tiles" % saved_player_tiles.size())


## Restore player-placed tiles from saved state
func _restore_player_placed_tiles() -> void:
	if saved_player_tiles.is_empty():
		return
	
	# Track portals for linking after all are placed
	var portal_links: Dictionary = {}  # entrance_pos -> exit_pos
	
	for tile_data in saved_player_tiles:
		var grid_pos: Vector2i = tile_data["position"]
		var item_type: String = tile_data["item_type"]
		var direction: String = tile_data.get("direction", "")
		var level: int = tile_data.get("level", 1)
		
		# Get item definition
		var definition := GameConfig.get_item_definition(item_type)
		if not definition:
			push_warning("GameScene: Failed to find definition for saved item: %s" % item_type)
			continue
		
		# Skip if tile is not buildable (preset items may have been placed there)
		if not TileManager.is_buildable(grid_pos):
			continue
		
		# Create structure node
		var structure_node: Node = null
		
		# For portals, use entrance or exit scene based on saved data
		if item_type == "portal":
			var is_entrance: bool = tile_data.get("is_entrance", true)
			var scene_path: String = definition.scene_path if is_entrance else definition.paired_scene_path
			var scene := load(scene_path) as PackedScene
			if scene:
				structure_node = scene.instantiate()
			
			# Track portal links
			if tile_data.has("linked_position"):
				if is_entrance:
					portal_links[grid_pos] = tile_data["linked_position"]
		elif not definition.scene_path.is_empty():
			var scene := load(definition.scene_path) as PackedScene
			if scene:
				structure_node = scene.instantiate()
		
		# Fallback to basic visual
		if not structure_node and placement_manager:
			structure_node = placement_manager._create_fallback_visual(definition)
		
		if not structure_node:
			continue
		
		# Add to scene
		runes_container.add_child(structure_node)
		
		# Set position and properties
		if structure_node is RuneBase:
			var rune := structure_node as RuneBase
			rune.set_grid_position(grid_pos)
			
			# Set direction for redirect runes
			if not direction.is_empty() and rune.has_method("set_direction_by_string"):
				rune.set_direction_by_string(direction)
			
			# Apply upgrades if level > 1
			while rune.current_level < level and rune.can_upgrade():
				rune.upgrade()
		elif structure_node.has_method("set_grid_position"):
			# Handle other entities with set_grid_position (like ExplosiveWall)
			structure_node.set_grid_position(grid_pos)
		elif structure_node is Node2D:
			var node_2d := structure_node as Node2D
			node_2d.position = Vector2(
				grid_pos.x * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0,
				grid_pos.y * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0
			)
			node_2d.z_index = grid_pos.y * 10 + 5
		
		# Determine occupancy type
		var occupancy_type: TileBase.OccupancyType
		if item_type == "wall" or item_type == "explosive_wall":
			occupancy_type = TileBase.OccupancyType.WALL
		else:
			occupancy_type = TileBase.OccupancyType.RUNE
		
		# Register with TileManager (marked as player-placed)
		TileManager.set_occupancy(grid_pos, occupancy_type, structure_node, true, item_type)
	
	# Link portal pairs
	for entrance_pos in portal_links.keys():
		var exit_pos: Vector2i = portal_links[entrance_pos]
		
		var entrance_tile := TileManager.get_tile(entrance_pos)
		var exit_tile := TileManager.get_tile(exit_pos)
		
		if entrance_tile and entrance_tile.structure is PortalRune:
			if exit_tile and exit_tile.structure is PortalRune:
				var entrance_portal := entrance_tile.structure as PortalRune
				var exit_portal := exit_tile.structure as PortalRune
				entrance_portal.link_to(exit_portal)
	
	print("GameScene: Restored %d player-placed tiles" % saved_player_tiles.size())


## Soft restart - reset game state but preserve player-placed tiles
## Used after defeat to let players make minor adjustments
func soft_restart_level() -> void:
	print("GameScene: Soft restarting level (preserving player placements)...")
	
	# Save current player placements before clearing
	_save_player_placed_tiles()
	
	# Calculate how much the player spent on saved tiles for resource adjustment
	var spent_on_tiles: int = 0
	for tile_data in saved_player_tiles:
		var item_type: String = tile_data["item_type"]
		var definition := GameConfig.get_item_definition(item_type)
		if definition:
			spent_on_tiles += definition.cost
			# Add upgrade costs
			var level: int = tile_data.get("level", 1)
			if level > 1 and definition.upgrade_cost > 0:
				spent_on_tiles += definition.upgrade_cost * (level - 1)
	
	# Clear game state (enemies, fireballs, etc.)
	_clear_game_state()
	
	# Reset hint flag so it shows again
	has_shown_level_hint = false
	
	# Reinitialize tile system (creates fresh tiles)
	_initialize_tile_system()
	
	# Recreate spawn point markers
	_create_spawn_point_markers()
	
	# Restore player-placed tiles BEFORE resetting resources
	_restore_player_placed_tiles()
	
	# Reset resources to starting amount minus what was spent on restored tiles
	if current_level_data and current_level_data.starting_resources > 0:
		GameManager.resources = current_level_data.starting_resources - spent_on_tiles
	else:
		GameManager.resources = GameConfig.get_level_resources(GameManager.current_level) - spent_on_tiles
	GameManager.resources_changed.emit(GameManager.resources)
	
	# Update build menu
	_update_build_menu()
	
	# Update placement manager with level data
	if placement_manager:
		placement_manager.set_level_data(current_level_data)
	
	# Update path preview
	if path_preview:
		path_preview.update_paths(current_level_data)
	
	# Update game submenu
	if game_submenu:
		game_submenu.set_level(GameManager.current_level)
		if current_level_data:
			current_heat = current_level_data.difficulty
			EnemyManager.current_heat = current_heat
			game_submenu.set_heat(current_heat)
	
	# Clear saved tiles (they've been restored)
	saved_player_tiles.clear()
	
	# Ensure we're in build phase
	_start_build_phase()
	
	print("GameScene: Soft restart complete!")


## Clear all game state for hot-reload
func _clear_game_state() -> void:
	# Stop heat timer
	_stop_heat_timer()
	
	# Clear all enemies and stop wave
	EnemyManager.clear_enemies()
	
	# Clear all enemies from container
	for child in enemies_container.get_children():
		child.queue_free()
	
	# Clear all runes from container
	for child in runes_container.get_children():
		child.queue_free()
	
	# Clear spawn point markers
	for child in spawn_points_container.get_children():
		child.queue_free()
	
	# Clear debug markers and fireballs from game_board
	for child in game_board.get_children():
		if child.name.begins_with("DebugTerrain_") or child.name.begins_with("DebugSpawn_"):
			child.queue_free()
		elif child is Fireball:
			child.queue_free()
	
	# Clear the tile manager (this will also free all tiles)
	TileManager.clear_grid()
	
	# Clear tiles container
	for child in tiles_container.get_children():
		child.queue_free()
	
	# Disconnect tile occupancy signal temporarily (will reconnect in _initialize_tile_system)
	if TileManager.occupancy_changed.is_connected(_on_tile_occupancy_changed):
		TileManager.occupancy_changed.disconnect(_on_tile_occupancy_changed)
	
	# Disconnect EnemyManager signals (will reconnect in _initialize_tile_system)
	if EnemyManager.all_enemies_defeated.is_connected(_on_all_enemies_defeated):
		EnemyManager.all_enemies_defeated.disconnect(_on_all_enemies_defeated)
	if EnemyManager.furnace_destroyed.is_connected(_on_furnace_destroyed):
		EnemyManager.furnace_destroyed.disconnect(_on_furnace_destroyed)
	if EnemyManager.debug_wave_restarted.is_connected(_on_debug_wave_restarted):
		EnemyManager.debug_wave_restarted.disconnect(_on_debug_wave_restarted)
	if EnemyManager.enemy_died.is_connected(_on_enemy_died):
		EnemyManager.enemy_died.disconnect(_on_enemy_died)
	
	# Disconnect FireballManager signals (will reconnect in _initialize_tile_system)
	if FireballManager.fireball_destroyed.is_connected(_on_fireball_destroyed):
		FireballManager.fireball_destroyed.disconnect(_on_fireball_destroyed)
	if FireballManager.fireball_enemy_hit.is_connected(_on_fireball_enemy_hit):
		FireballManager.fireball_enemy_hit.disconnect(_on_fireball_enemy_hit)
