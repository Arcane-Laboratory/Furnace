extends PanelContainer
class_name LevelExportDialog
## Dialog for exporting level data to clipboard or file


signal export_completed(success: bool)
signal save_completed(success: bool, file_path: String)
signal cancelled

@onready var level_name_input: LineEdit = $MarginContainer/VBoxContainer/LevelNameRow/LevelNameInput
@onready var level_number_input: SpinBox = $MarginContainer/VBoxContainer/LevelNumberRow/LevelNumberInput
@onready var starting_resources_input: SpinBox = $MarginContainer/VBoxContainer/ResourcesRow/StartingResourcesInput
@onready var hint_text_input: TextEdit = $MarginContainer/VBoxContainer/HintTextInput
@onready var export_button: Button = $MarginContainer/VBoxContainer/ButtonRow/ExportButton
@onready var save_button: Button = $MarginContainer/VBoxContainer/ButtonRow/SaveButton
@onready var cancel_button: Button = $MarginContainer/VBoxContainer/ButtonRow/CancelButton


func _ready() -> void:
	hide()
	
	# Connect button signals
	export_button.pressed.connect(_on_export_pressed)
	save_button.pressed.connect(_on_save_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)


## Store spawn points and terrain for export
var export_spawn_points: Array[Vector2i] = []
var export_terrain_tiles: Array[Vector2i] = []

func show_dialog(spawn_points: Array[Vector2i], terrain_tiles: Array[Vector2i] = []) -> void:
	export_spawn_points = spawn_points
	export_terrain_tiles = terrain_tiles
	show()
	level_name_input.grab_focus()


func hide_dialog() -> void:
	hide()


func _on_export_pressed() -> void:
	var level_name := level_name_input.text.strip_edges()
	if level_name.is_empty():
		level_name = "New Level"
	
	var level_number := int(level_number_input.value)
	var starting_resources := int(starting_resources_input.value)
	var hint_text := hint_text_input.text.strip_edges()
	
	# Generate level data in .tres format using LevelExporter
	var level_data := LevelExporter.export_current_level(
		level_name,
		level_number,
		starting_resources,
		hint_text,
		export_spawn_points,
		Vector2i(-1, -1),  # No furnace override
		export_terrain_tiles
	)
	
	# Copy to clipboard
	DisplayServer.clipboard_set(level_data)
	
	export_completed.emit(true)
	hide_dialog()


func _on_save_pressed() -> void:
	var level_name := level_name_input.text.strip_edges()
	if level_name.is_empty():
		level_name = "New Level"
	
	var level_number := int(level_number_input.value)
	var starting_resources := int(starting_resources_input.value)
	var hint_text := hint_text_input.text.strip_edges()
	
	# Generate level data in .tres format using LevelExporter
	var level_data := LevelExporter.export_current_level(
		level_name,
		level_number,
		starting_resources,
		hint_text,
		export_spawn_points,
		Vector2i(-1, -1),  # No furnace override
		export_terrain_tiles
	)
	
	# Save to file
	var file_path := "res://resources/levels/level_%d.tres" % level_number
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(level_data)
		file.close()
		print("LevelExportDialog: Saved level to %s" % file_path)
		save_completed.emit(true, file_path)
	else:
		push_error("LevelExportDialog: Failed to save level to %s" % file_path)
		save_completed.emit(false, file_path)
	
	hide_dialog()


func _on_cancel_pressed() -> void:
	cancelled.emit()
	hide_dialog()
