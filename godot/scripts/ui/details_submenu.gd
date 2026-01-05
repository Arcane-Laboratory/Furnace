extends Control
## Details submenu - shows detailed information about a selected buildable item


signal close_requested


## Debounce cooldown to prevent rapid inputs (especially on mobile)
var _input_cooldown: float = 0.0
const INPUT_DEBOUNCE_TIME: float = 0.15  # 150ms debounce

## Reference to UI elements
@onready var details_item: Control = $VBoxContainer/MarginContainer/DetailsSubmenuItem
@onready var close_button: Button = $MarginContainer2/Button


func _ready() -> void:
	if close_button:
		close_button.pressed.connect(_on_close_pressed)


func _process(delta: float) -> void:
	# Decrement input cooldown
	if _input_cooldown > 0.0:
		_input_cooldown -= delta


## Show item details for the given definition
func show_item_details(definition: BuildableItemDefinition) -> void:
	if not definition:
		return
	
	if details_item and details_item.has_method("configure"):
		details_item.configure(
			definition.item_type,
			definition.display_name,
			definition.cost,
			definition.icon_color,
			definition.description
		)


## Handle close button pressed
func _on_close_pressed() -> void:
	# Debounce to prevent rapid inputs on mobile
	if _input_cooldown > 0.0:
		return
	_input_cooldown = INPUT_DEBOUNCE_TIME
	AudioManager.play_ui_click()
	close_requested.emit()
