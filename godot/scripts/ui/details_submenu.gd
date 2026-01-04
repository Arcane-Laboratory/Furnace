extends Control
## Details submenu - shows detailed information about a selected buildable item


signal close_requested


## Reference to UI elements
@onready var details_item: Control = $VBoxContainer/MarginContainer/DetailsSubmenuItem
@onready var close_button: Button = $MarginContainer2/Button


func _ready() -> void:
	if close_button:
		close_button.pressed.connect(_on_close_pressed)


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
	close_requested.emit()
