extends Control
## Individual build menu item - displays rune/wall with name, cost, and details button


signal item_selected(item_type: String)
signal item_drag_started(item_type: String)

## Item type identifier (e.g., "redirect", "wall", "portal")
var item_type: String = ""

## Item display name
var item_name: String = ""

## Item cost
var item_cost: int = 0

## Item icon color
var item_icon_color: Color = Color.WHITE

## Selection state
var is_selected: bool = false

## Reference to UI elements
@onready var menu_rune: Control = $VBoxContainer/MenuRune
@onready var name_label: Label = $VBoxContainer/Label
@onready var details_button: Button = $VBoxContainer/Button

## Selection highlight border
var selection_border: ColorRect


func _ready() -> void:
	if details_button:
		details_button.pressed.connect(_on_details_pressed)
	
	# Make the whole item clickable
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Make child controls pass through clicks to this control
	_setup_click_passthrough()
	
	# Create selection border (drawn behind content)
	_create_selection_border()


## Setup child controls to pass clicks through to parent
func _setup_click_passthrough() -> void:
	# VBoxContainer should pass through
	var vbox := get_node_or_null("VBoxContainer") as Control
	if vbox:
		vbox.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# MenuRune and its children should pass through
	if menu_rune:
		menu_rune.mouse_filter = Control.MOUSE_FILTER_PASS
		var color_rect := menu_rune.get_node_or_null("ColorRect") as Control
		if color_rect:
			color_rect.mouse_filter = Control.MOUSE_FILTER_PASS
			# Also the label inside ColorRect
			var label := color_rect.get_node_or_null("Label") as Control
			if label:
				label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Name label should pass through
	if name_label:
		name_label.mouse_filter = Control.MOUSE_FILTER_PASS


## Create the selection border visual
func _create_selection_border() -> void:
	selection_border = ColorRect.new()
	selection_border.color = Color(1.0, 0.8, 0.2, 0.0)  # Yellow, starts invisible
	selection_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selection_border.set_anchors_preset(Control.PRESET_FULL_RECT)
	selection_border.offset_left = -2
	selection_border.offset_top = -2
	selection_border.offset_right = 2
	selection_border.offset_bottom = 2
	add_child(selection_border)
	move_child(selection_border, 0)  # Move to back


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		item_selected.emit(item_type)


## Configure this menu item with item data
func configure(type: String, display_name: String, cost: int, icon_color: Color) -> void:
	item_type = type
	item_name = display_name
	item_cost = cost
	item_icon_color = icon_color
	
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


## Set selection state with visual feedback
func set_selected(selected: bool) -> void:
	is_selected = selected
	_update_selection_visual()


## Update selection visual (border highlight)
func _update_selection_visual() -> void:
	if not selection_border:
		return
	
	if is_selected:
		selection_border.color = Color(1.0, 0.8, 0.2, 0.6)  # Visible yellow border
	else:
		selection_border.color = Color(1.0, 0.8, 0.2, 0.0)  # Invisible


## Drag and drop support - provides drag data
func _get_drag_data(_at_position: Vector2) -> Variant:
	if item_type.is_empty():
		return null
	
	# Create drag preview
	var preview := _create_drag_preview()
	set_drag_preview(preview)
	
	item_drag_started.emit(item_type)
	
	# Return drag data
	return {
		"type": "buildable_item",
		"item_type": item_type,
		"item_name": item_name,
		"item_cost": item_cost,
		"icon_color": item_icon_color
	}


## Create a visual preview for dragging
func _create_drag_preview() -> Control:
	var preview := ColorRect.new()
	preview.size = Vector2(32, 32)
	preview.color = item_icon_color
	preview.color.a = 0.7
	
	# Center the preview on the cursor
	preview.position = -preview.size / 2
	
	return preview


## Handle details button press
func _on_details_pressed() -> void:
	# Placeholder - show item details/info
	print("Details for %s (Cost: %d)" % [item_name, item_cost])
