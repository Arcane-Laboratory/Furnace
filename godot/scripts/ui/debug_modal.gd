extends Control
class_name DebugModal
## Debug modal with various debug options


signal export_level_requested
signal go_to_level_requested(level_number: int)
signal place_spawn_point_requested
signal place_furnace_requested
signal closed


## References
@onready var panel: PanelContainer = %Panel
@onready var main_menu: VBoxContainer = %MainMenu
@onready var level_submenu: VBoxContainer = %LevelSubmenu
@onready var export_button: Button = %ExportButton
@onready var go_to_level_button: Button = %GoToLevelButton
@onready var place_spawn_button: Button = %PlaceSpawnButton
@onready var place_furnace_button: Button = %PlaceFurnaceButton
@onready var back_button: Button = %BackButton
@onready var level_list: VBoxContainer = %LevelList


func _ready() -> void:
	visible = false
	
	# Connect main menu buttons
	if export_button:
		export_button.pressed.connect(_on_export_pressed)
	if go_to_level_button:
		go_to_level_button.pressed.connect(_on_go_to_level_pressed)
	if place_spawn_button:
		place_spawn_button.pressed.connect(_on_place_spawn_pressed)
	if place_furnace_button:
		place_furnace_button.pressed.connect(_on_place_furnace_pressed)
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	
	# Don't populate here - wait until modal is shown (resources may not be ready yet)
	# _populate_level_list() is called in show_modal()
	
	# Start with main menu visible
	_show_main_menu()


## Show the modal
func show_modal() -> void:
	# Refresh level list every time modal is shown (in case files changed)
	_populate_level_list()
	_show_main_menu()
	visible = true


## Hide the modal
func hide_modal() -> void:
	visible = false
	closed.emit()


## Show main menu, hide submenu
func _show_main_menu() -> void:
	if main_menu:
		main_menu.visible = true
	if level_submenu:
		level_submenu.visible = false


## Show level submenu, hide main menu
func _show_level_submenu() -> void:
	if main_menu:
		main_menu.visible = false
	if level_submenu:
		level_submenu.visible = true


## Populate the level list with available levels
func _populate_level_list() -> void:
	if not level_list:
		return
	
	# Clear existing entries immediately (not queue_free which defers)
	for child in level_list.get_children():
		child.free()
	
	# Get all level files
	var level_dir := "res://resources/levels/"
	var dir := DirAccess.open(level_dir)
	if not dir:
		push_warning("DebugModal: Could not open levels directory")
		return
	
	var level_files: Array[String] = []
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		print("DebugModal: Found file: %s" % file_name)
		if file_name.ends_with(".tres") and file_name.begins_with("level_"):
			level_files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	print("DebugModal: Level files to process: %s" % str(level_files))
	
	# Sort level files
	level_files.sort()
	
	# Create buttons for each level
	for file in level_files:
		var level_path := level_dir + file
		var level_data := load(level_path) as LevelData
		if not level_data:
			push_warning("DebugModal: Failed to load level from %s" % level_path)
			continue
		
		var btn := Button.new()
		btn.text = "Level %d: %s" % [level_data.level_number, level_data.level_name]
		btn.pressed.connect(_on_level_selected.bind(level_data.level_number))
		level_list.add_child(btn)
	
	print("DebugModal: Found %d valid levels" % level_list.get_child_count())


## Handle export button pressed
func _on_export_pressed() -> void:
	export_level_requested.emit()
	hide_modal()


## Handle go to level button pressed
func _on_go_to_level_pressed() -> void:
	_show_level_submenu()


## Handle place spawn point button pressed
func _on_place_spawn_pressed() -> void:
	place_spawn_point_requested.emit()
	hide_modal()


## Handle place furnace button pressed
func _on_place_furnace_pressed() -> void:
	place_furnace_requested.emit()
	hide_modal()


## Handle back button pressed
func _on_back_pressed() -> void:
	_show_main_menu()


## Handle level selected from list
func _on_level_selected(level_number: int) -> void:
	go_to_level_requested.emit(level_number)
	hide_modal()


## Handle input for closing modal
func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	# Close on escape
	if event.is_action_pressed("ui_cancel"):
		hide_modal()
		get_viewport().set_input_as_handled()


## Handle GUI input for click outside
func _gui_input(event: InputEvent) -> void:
	if not visible:
		return
	
	# Close on click outside panel
	if event is InputEventMouseButton and event.pressed:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			# Check if click is outside the panel
			if panel and not _is_point_in_panel(mouse_event.position):
				hide_modal()
				accept_event()


## Check if a point is inside the panel
func _is_point_in_panel(point: Vector2) -> bool:
	if not panel:
		return false
	
	var panel_rect := Rect2(panel.global_position, panel.size)
	return panel_rect.has_point(point)
