extends Node2D
## Main game scene controller - handles build and active phases


@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var right_panel: PanelContainer = $UILayer/RightPanel
@onready var active_ui: Control = $UILayer/ActiveUI
@onready var grid_overlay: Node2D = $GameBoard/GridOverlay
@onready var background: Sprite2D = $Background
@onready var game_board: Node2D = $GameBoard

# Stats labels
@onready var level_value: Label = $UILayer/RightPanel/VBoxContainer/StatsContainer/LevelRow/LevelValue
@onready var money_value: Label = $UILayer/RightPanel/VBoxContainer/StatsContainer/MoneyRow/MoneyValue
@onready var heat_value: Label = $UILayer/RightPanel/VBoxContainer/StatsContainer/HeatRow/HeatValue
@onready var start_button: Button = $UILayer/RightPanel/VBoxContainer/StartButton

var is_paused: bool = false
var selected_rune_type: String = ""

# Grid state: 2D array tracking what's placed on each tile
var grid_state: Array = []

# Hover highlight
var hover_highlight: ColorRect
var current_hover_cell: Vector2i = Vector2i(-1, -1)
var highlight_tween: Tween


func _ready() -> void:
	_load_background()
	_init_grid_state()
	_draw_grid()
	_create_hover_highlight()
	
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


func _init_grid_state() -> void:
	grid_state.clear()
	for x in range(GameConfig.GRID_COLUMNS):
		var column: Array = []
		for y in range(GameConfig.GRID_ROWS):
			column.append(null)  # null = empty, or store rune/wall data
		grid_state.append(column)


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
	if GameManager.current_state != GameManager.GameState.BUILD_PHASE:
		hover_highlight.color.a = 0.0
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
			current_hover_cell = new_cell
			_animate_highlight_to_cell(cell_x, cell_y)
	else:
		# Mouse outside grid
		if current_hover_cell != Vector2i(-1, -1):
			current_hover_cell = Vector2i(-1, -1)
			_fade_out_highlight()


func _animate_highlight_to_cell(cell_x: int, cell_y: int) -> void:
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
	if highlight_tween and highlight_tween.is_valid():
		highlight_tween.kill()
	
	highlight_tween = create_tween()
	highlight_tween.tween_property(hover_highlight, "color", Color(1.0, 0.9, 0.5, 0.0), 0.15)


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
