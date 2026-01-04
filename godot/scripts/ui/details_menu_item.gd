extends Control
## Details menu item - displays detailed information about a buildable item


## Reference to UI elements
@onready var menu_rune: Control = $CenterContainer/VBoxContainer/MenuRune
@onready var name_label: Label = $CenterContainer/VBoxContainer/Label
@onready var description_label: Label = $CenterContainer/VBoxContainer/CenterContainer/Panel/MarginContainer/Label2


func _ready() -> void:
	pass


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
	
	# Update MenuRune icon color and cost
	if menu_rune:
		var color_rect := menu_rune.get_node_or_null("ColorRect") as ColorRect
		if color_rect:
			color_rect.color = icon_color
			
			# Update cost label (hidden in details view, but set it anyway)
			var cost_label := color_rect.get_node_or_null("Label") as Label
			if cost_label:
				cost_label.text = "$%d" % cost
