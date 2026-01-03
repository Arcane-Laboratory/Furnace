extends PanelContainer
class_name LevelExportDialog
## Dialog for exporting current level to clipboard


signal export_completed(success: bool)
signal cancelled


## UI references
@onready var level_name_input: LineEdit = %LevelNameInput
@onready var level_number_input: SpinBox = %LevelNumberInput
@onready var starting_resources_input: SpinBox = %StartingResourcesInput
@onready var hint_text_input: TextEdit = %HintTextInput
@onready var export_button: Button = %ExportButton
@onready var cancel_button: Button = %CancelButton

## Additional spawn points from debug placement
var additional_spawn_points: Array[Vector2i] = []

## Override furnace position from debug placement
var override_furnace_position: Vector2i = Vector2i(-1, -1)


func _ready() -> void:
	visible = false
	
	# Connect buttons
	if export_button:
		export_button.pressed.connect(_on_export_pressed)
	if cancel_button:
		cancel_button.pressed.connect(_on_cancel_pressed)
	
	# Set default values
	_set_defaults()


## Set default values for the inputs
func _set_defaults() -> void:
	if level_name_input:
		level_name_input.text = "New Level"
	if level_number_input:
		level_number_input.value = 2
	if starting_resources_input:
		starting_resources_input.value = 100
	if hint_text_input:
		hint_text_input.text = ""


## Show the dialog with optional debug placement data
func show_dialog(spawn_points: Array[Vector2i] = [], furnace_pos: Vector2i = Vector2i(-1, -1)) -> void:
	additional_spawn_points = spawn_points
	override_furnace_position = furnace_pos
	
	_set_defaults()
	visible = true
	
	# Focus the level name input
	if level_name_input:
		level_name_input.grab_focus()
		level_name_input.select_all()


## Hide the dialog
func hide_dialog() -> void:
	visible = false


## Handle export button pressed
func _on_export_pressed() -> void:
	var level_name := level_name_input.text if level_name_input else "New Level"
	var level_number := int(level_number_input.value) if level_number_input else 2
	var starting_resources := int(starting_resources_input.value) if starting_resources_input else 100
	var hint_text := hint_text_input.text if hint_text_input else ""
	
	# Generate the .tres content with debug placement data
	var content := LevelExporter.export_current_level(
		level_name,
		level_number,
		starting_resources,
		hint_text,
		additional_spawn_points,
		override_furnace_position
	)
	
	# Copy to clipboard
	LevelExporter.copy_to_clipboard(content)
	
	print("LevelExportDialog: Level exported to clipboard!")
	if not additional_spawn_points.is_empty():
		print("  - Includes %d additional spawn points" % additional_spawn_points.size())
	if override_furnace_position != Vector2i(-1, -1):
		print("  - Custom furnace position: %s" % override_furnace_position)
	print("Save as: res://resources/levels/level_%d.tres" % level_number)
	
	hide_dialog()
	export_completed.emit(true)


## Handle cancel button pressed
func _on_cancel_pressed() -> void:
	hide_dialog()
	cancelled.emit()


## Handle input for closing with escape
func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event.is_action_pressed("ui_cancel"):
		_on_cancel_pressed()
		get_viewport().set_input_as_handled()
