extends Control
## Individual build menu item - displays rune/wall with name, cost, and details button


signal item_selected(item_type: String)

## Item type identifier (e.g., "redirect", "wall", "portal")
var item_type: String = ""

## Item display name
var item_name: String = ""

## Item cost
var item_cost: int = 0

## Reference to UI elements
@onready var menu_rune: Control = $VBoxContainer/MenuRune
@onready var name_label: Label = $VBoxContainer/Label
@onready var details_button: Button = $VBoxContainer/Button


func _ready() -> void:
	if details_button:
		details_button.pressed.connect(_on_details_pressed)
	
	# Make the whole item clickable
	mouse_filter = Control.MOUSE_FILTER_STOP


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		item_selected.emit(item_type)


## Configure this menu item with item data
func configure(type: String, display_name: String, cost: int, icon_color: Color) -> void:
	item_type = type
	item_name = display_name
	item_cost = cost
	
	# Update name label
	if name_label:
		name_label.text = display_name
	
	# Update cost display in MenuRune
	if menu_rune:
		var cost_label := menu_rune.get_node_or_null("ColorRect/Label") as Label
		if cost_label:
			cost_label.text = "$%d" % cost
		
		# Update icon color
		var icon_rect := menu_rune.get_node_or_null("ColorRect") as ColorRect
		if icon_rect:
			icon_rect.color = icon_color


## Handle details button press
func _on_details_pressed() -> void:
	# Placeholder - show item details/info
	print("Details for %s (Cost: %d)" % [item_name, item_cost])
