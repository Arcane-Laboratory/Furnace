extends Node2D
## Main game scene controller - handles build and active phases


@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var right_panel: PanelContainer = $UILayer/RightPanel
@onready var active_ui: Control = $UILayer/ActiveUI
@onready var grid_overlay: Node2D = $GameBoard/GridOverlay
@onready var background: Sprite2D = $Background
@onready var game_board: Node2D = $GameBoard
@onready var tiles_container: Node2D = $GameBoard/Tiles
@onready var spawn_points_container: Node2D = $GameBoard/SpawnPoints

# Stats labels
@onready var level_value: Label = $UILayer/RightPanel/VBoxContainer/StatsContainer/LevelRow/LevelValue
@onready var money_value: Label = $UILayer/RightPanel/VBoxContainer/StatsContainer/MoneyRow/MoneyValue
@onready var heat_value: Label = $UILayer/RightPanel/VBoxContainer/StatsContainer/HeatRow/HeatValue
@onready var start_button: Button = $UILayer/RightPanel/VBoxContainer/StartButton

var is_paused: bool = false
var selected_rune_type: String = ""

# Level data
var current_level_data: LevelData = null

# Hover highlight
var hover_highlight: ColorRect
var current_hover_cell: Vector2i = Vector2i(-1, -1)
var highlight_tween: Tween


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
	
	start_button.pressed.connect(_on_start_pressed)
	
	_update_ui()
	_start_build_phase()


func _process(_delta: float) -> void:
	_update_hover_highlight()


func _load_background() -> void:
	var bg_path := "res://assets/sprites/board_background.png"
	if ResourceLoader.exists(bg_path):
		background.texture = load(bg_path)


func _load_level_data() -> void:
	# Try to load level data resource, or create default
	var level_path := "res://levels/level_%d.tres" % GameManager.current_level
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
	
	# Default enemy wave
	level_data.enemy_waves = [
		{"enemy_type": "basic", "spawn_point": 0, "delay": 0.0},
		{"enemy_type": "basic", "spawn_point": 1, "delay": 1.0},
		{"enemy_type": "basic", "spawn_point": 2, "delay": 2.0},
	]
	
	return level_data


func _initialize_tile_system() -> void:
	# Initialize TileManager with level data
	TileManager.initialize_from_level_data(current_level_data)
	
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
		# Clear tile highlights
		if current_hover_cell != Vector2i(-1, -1):
			var tile := TileManager.get_tile(current_hover_cell)
			if tile:
				tile.set_highlight(false)
			current_hover_cell = Vector2i(-1, -1)
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
			
			# Update tile highlight based on buildability
			var tile := TileManager.get_tile(new_cell)
			if tile:
				if TileManager.is_buildable(new_cell):
					tile.set_highlight(true, "hover")
				else:
					tile.set_highlight(true, "invalid")
	else:
		# Mouse outside grid
		if current_hover_cell != Vector2i(-1, -1):
			var tile := TileManager.get_tile(current_hover_cell)
			if tile:
				tile.set_highlight(false)
			current_hover_cell = Vector2i(-1, -1)
			_fade_out_highlight()


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


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()


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


func _start_active_phase() -> void:
	GameManager.start_active_phase()
	right_panel.hide()
	active_ui.show()
	_launch_fireball()


func _launch_fireball() -> void:
	# Placeholder - will spawn and launch fireball from furnace
	print("Fireball launched!")


func _on_start_pressed() -> void:
	_start_active_phase()


func _on_resources_changed(_new_amount: int) -> void:
	_update_ui()


func _on_state_changed(new_state: GameManager.GameState) -> void:
	match new_state:
		GameManager.GameState.BUILD_PHASE:
			right_panel.show()
			active_ui.hide()
		GameManager.GameState.ACTIVE_PHASE:
			right_panel.hide()
			active_ui.show()
		GameManager.GameState.GAME_OVER:
			SceneManager.goto_game_over(GameManager.game_won)


func _update_ui() -> void:
	level_value.text = str(GameManager.current_level)
	money_value.text = str(GameManager.resources)
	heat_value.text = "3"  # Placeholder - heat system TBD


# Called when level is won
func win_level() -> void:
	GameManager.end_game(true)


# Called when furnace is destroyed
func lose_level() -> void:
	GameManager.end_game(false)
