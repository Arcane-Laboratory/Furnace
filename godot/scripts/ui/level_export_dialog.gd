extends PanelContainer
class_name LevelExportDialog
## Dialog for exporting level data to clipboard


signal export_completed(success: bool)
signal cancelled

@onready var level_name_input: LineEdit = $MarginContainer/VBoxContainer/LevelNameRow/LevelNameInput
@onready var level_number_input: SpinBox = $MarginContainer/VBoxContainer/LevelNumberRow/LevelNumberInput
@onready var starting_resources_input: SpinBox = $MarginContainer/VBoxContainer/ResourcesRow/StartingResourcesInput
@onready var hint_text_input: TextEdit = $MarginContainer/VBoxContainer/HintTextInput
@onready var export_button: Button = $MarginContainer/VBoxContainer/ButtonRow/ExportButton
@onready var cancel_button: Button = $MarginContainer/VBoxContainer/ButtonRow/CancelButton


func _ready() -> void:
	hide()
	
	# Connect button signals
	export_button.pressed.connect(_on_export_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)


## Store spawn points and furnace position for export
var export_spawn_points: Array[Vector2i] = []
var export_furnace_position: Vector2i = Vector2i(-1, -1)

func show_dialog(spawn_points: Array[Vector2i], furnace_position: Vector2i) -> void:
	export_spawn_points = spawn_points
	export_furnace_position = furnace_position
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
	
	# Generate level data JSON
	var level_data := _generate_level_data(level_name, level_number, starting_resources, hint_text)
	
	# Copy to clipboard
	DisplayServer.clipboard_set(level_data)
	
	export_completed.emit(true)
	hide_dialog()


func _on_cancel_pressed() -> void:
	cancelled.emit()
	hide_dialog()


func _generate_level_data(level_name: String, level_number: int, starting_resources: int, hint_text: String) -> String:
	# Build level data structure
	var data := {
		"level_number": level_number,
		"level_name": level_name,
		"starting_resources": starting_resources,
		"spawn_points": export_spawn_points,
		"furnace_position": export_furnace_position,
		"terrain_blocked": [],
		"preset_walls": [],
		"preset_runes": [],
		"enemy_waves": [],
		"allowed_runes": [],
		"hint_text": hint_text,
		"par_time_seconds": 60.0
	}
	
	# Convert to JSON
	var json_string := JSON.stringify(data, "\t")
	return json_string
