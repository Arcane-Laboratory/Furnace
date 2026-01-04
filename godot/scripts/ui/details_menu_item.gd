extends Control
## Details menu item - displays detailed information about a buildable item


## Reference to UI elements
@onready var menu_rune: Control = $CenterContainer/VBoxContainer/MenuRune
@onready var name_label: Label = $CenterContainer/VBoxContainer/Label
@onready var description_label: Label = $CenterContainer/VBoxContainer/CenterContainer/Panel/MarginContainer/Label2


func _ready() -> void:
	pass


## Get sprite path for a rune type (same logic as build_menu_item)
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
		"acceleration":
			return "res://assets/sprites/rune-accelerate.png"
		"portal":
			return "res://assets/sprites/rune-magic.png"  # Portal uses rune-magic sprite
		"wall":
			return "res://assets/sprites/wall.png"
		"explosive_wall":
			return "res://assets/sprites/wall.png"  # Use same sprite as regular wall
		"mud_tile":
			return "res://assets/sprites/wall.png"  # Use wall sprite with brown tint
		_:
			return ""  # No sprite, use color fallback


## Configure this details item with item data
func configure(item_type: String, display_name: String, cost: int, icon_color: Color, description: String) -> void:
	# Update name label
	if name_label:
		name_label.text = display_name
	
	# Update description label
	if description_label:
		if description.is_empty():
			description_label.text = "No description available."
		else:
			description_label.text = description
	
	# Update MenuRune icon and cost
	if menu_rune:
		var cost_label := menu_rune.get_node_or_null("ColorRect/Label") as Label
		if cost_label:
			cost_label.text = "$%d" % cost
		
		# Try to load and display rune sprite instead of just color
		var sprite_path := _get_rune_sprite_path(item_type)
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
				
				# Hide ColorRect completely when showing sprite
				if icon_rect:
					icon_rect.visible = false
					# Ensure ColorRect is behind TextureRect in draw order
					var color_rect_index := icon_rect.get_index()
					var texture_rect_index := texture_rect.get_index()
					if color_rect_index > texture_rect_index:
						menu_rune.move_child(icon_rect, 0)  # Move ColorRect to back
		else:
			# No sprite available, use color fallback
			if icon_rect:
				icon_rect.color = icon_color
				icon_rect.visible = true  # Show ColorRect again
			
			# Hide TextureRect if it exists
			var texture_rect := menu_rune.get_node_or_null("TextureRect") as TextureRect
			if texture_rect:
				texture_rect.visible = false
