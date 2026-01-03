extends Control
class_name DebugModal
## Debug modal dialog for debug mode features


signal export_level_requested
signal go_to_level_requested(level_number: int)
signal place_spawn_point_requested
signal place_terrain_requested

@onready var background: ColorRect = $Background
@onready var panel: PanelContainer = $Panel
@onready var main_menu: VBoxContainer = $Panel/MarginContainer/VBoxContainer/MainMenu
@onready var level_submenu: VBoxContainer = $Panel/MarginContainer/VBoxContainer/LevelSubmenu
@onready var level_list: VBoxContainer = $Panel/MarginContainer/VBoxContainer/LevelSubmenu/ScrollContainer/LevelList
@onready var export_button: Button = $Panel/MarginContainer/VBoxContainer/MainMenu/ExportButton
@onready var go_to_level_button: Button = $Panel/MarginContainer/VBoxContainer/MainMenu/GoToLevelButton
@onready var place_spawn_button: Button = $Panel/MarginContainer/VBoxContainer/MainMenu/PlaceSpawnButton
@onready var place_terrain_button: Button = $Panel/MarginContainer/VBoxContainer/MainMenu/PlaceTerrainButton
@onready var back_button: Button = $Panel/MarginContainer/VBoxContainer/LevelSubmenu/BackButton


func _ready() -> void:
	hide()
	
	# Connect button signals
	export_button.pressed.connect(_on_export_pressed)
	go_to_level_button.pressed.connect(_on_go_to_level_pressed)
	place_spawn_button.pressed.connect(_on_place_spawn_pressed)
	place_terrain_button.pressed.connect(_on_place_terrain_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	# Connect background click to close modal
	background.gui_input.connect(_on_background_input)
	
	# Populate level list
	_populate_level_list()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event.is_action_pressed("ui_cancel"):
		# If in submenu, go back; otherwise close modal
		if level_submenu.visible:
			_on_back_pressed()
		else:
			hide_modal()
		get_viewport().set_input_as_handled()


func _on_background_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide_modal()


func show_modal() -> void:
	show()
	main_menu.visible = true
	level_submenu.visible = false
	export_button.grab_focus()


func hide_modal() -> void:
	hide()


func _populate_level_list() -> void:
	# Clear existing buttons
	for child in level_list.get_children():
		child.queue_free()
	
	# Create buttons for levels 0-10
	for i in range(11):
		var button := Button.new()
		button.text = "Level %d" % i
		button.custom_minimum_size = Vector2(150, 24)
		button.pressed.connect(func(): _on_level_selected(i))
		level_list.add_child(button)


func _on_export_pressed() -> void:
	export_level_requested.emit()
	hide_modal()


func _on_go_to_level_pressed() -> void:
	main_menu.visible = false
	level_submenu.visible = true


func _on_place_spawn_pressed() -> void:
	place_spawn_point_requested.emit()
	hide_modal()


func _on_place_terrain_pressed() -> void:
	place_terrain_requested.emit()
	hide_modal()


func _on_back_pressed() -> void:
	main_menu.visible = true
	level_submenu.visible = false


func _on_level_selected(level_number: int) -> void:
	go_to_level_requested.emit(level_number)
	hide_modal()
