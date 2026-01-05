extends Control
## Individual build menu item - displays rune/wall with name, cost, and details button


signal item_selected(item_type: String)
signal item_drag_started(item_type: String)
signal details_requested(item_type: String)

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


## Get sprite path for a rune type
func _get_rune_sprite_path(rune_type: String) -> String:
	match rune_type:
		"redirect":
			return "res://assets/sprites/rune-redirect.png"
		"advanced_redirect":
			return "res://assets/sprites/rune-advanced-redirect.png"
		"reflect":
			return "res://assets/sprites/rune-magic.png"
		"explosive":
			return "res://assets/sprites/rune-explosion.png"
		"power":
			return "res://assets/sprites/rune-accelerate.png"
		"acceleration":  # Legacy support (should not be used)
			return "res://assets/sprites/rune-accelerate.png"
		"portal":
			return "res://assets/sprites/rune-magic.png"  # Portal uses rune-magic sprite
		"wall":
			return "res://assets/sprites/wall.png"
		"explosive_wall":
			return "res://assets/sprites/explosive-wall.png"
		"mud_tile":
			return "res://assets/sprites/rune-mud.png"
		_:
			return ""  # No sprite, use color fallback


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
			cost_label.text = "%d" % cost
		
		# Try to load and display rune sprite instead of just color
		var sprite_path := _get_rune_sprite_path(type)
		var icon_rect := menu_rune.get_node_or_null("ColorRect") as ColorRect
		
		if sprite_path != "" and ResourceLoader.exists(sprite_path):
			# Load sprite texture
			var sprite_texture := load(sprite_path) as Texture2D
			if sprite_texture:
				# Check if there's already a TextureRect, if not create one
				var texture_rect := menu_rune.get_node_or_null("TextureRect") as TextureRect
				if not texture_rect:
					# Create TextureRect to display sprite
					texture_rect = TextureRect.new()
					texture_rect.name = "TextureRect"
					texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
					texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
					texture_rect.mouse_filter = Control.MOUSE_FILTER_PASS
					# Fill the entire MenuRune control
					texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
					texture_rect.texture = sprite_texture
					menu_rune.add_child(texture_rect)
					# Move TextureRect to render on top (after all other children)
					menu_rune.move_child(texture_rect, -1)
				
				# Ensure texture is set and visible
				texture_rect.texture = sprite_texture
				texture_rect.visible = true
				texture_rect.show()
				
				# Make ColorRect transparent but keep it visible so the cost Label shows
				if icon_rect:
					icon_rect.color.a = 0.0  # Transparent background
					icon_rect.visible = true  # Keep visible for the Label child
					# Ensure the cost Label renders on top of the TextureRect
					if cost_label:
						cost_label.z_index = 10  # Render above the sprite
		else:
			# No sprite available, use color fallback
			if icon_rect:
				icon_rect.color = icon_color  # This sets full opacity with the icon_color
				icon_rect.visible = true  # Show ColorRect
				# Reset Label z_index to normal
				var fallback_cost_label := icon_rect.get_node_or_null("Label") as Label
				if fallback_cost_label:
					fallback_cost_label.z_index = 0
			
			# Hide TextureRect if it exists
			var existing_texture_rect := menu_rune.get_node_or_null("TextureRect") as TextureRect
			if existing_texture_rect:
				existing_texture_rect.visible = false


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
	# Try to use sprite if available
	var sprite_path := _get_rune_sprite_path(item_type)
	if sprite_path != "" and ResourceLoader.exists(sprite_path):
		var sprite_texture := load(sprite_path) as Texture2D
		if sprite_texture:
			var preview := TextureRect.new()
			preview.size = Vector2(32, 32)
			preview.texture = sprite_texture
			preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			preview.modulate.a = 0.8
			preview.position = -preview.size / 2
			return preview
	
	# Fallback to colored rectangle
	var preview := ColorRect.new()
	preview.size = Vector2(32, 32)
	preview.color = item_icon_color
	preview.color.a = 0.7
	
	# Center the preview on the cursor
	preview.position = -preview.size / 2
	
	return preview


## Handle details button press
func _on_details_pressed() -> void:
	AudioManager.play_ui_click()
	details_requested.emit(item_type)
