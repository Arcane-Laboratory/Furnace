extends Control
## Build submenu - populates and displays available buildable items


## Available buildable items (runes + wall)
## Array of Resource (BuildableItemDefinition) resources
var available_items: Array = []

## Current level data (set by game_scene)
var current_level_data: LevelData = null

## Reference to grid containers
@onready var grid_container_1: GridContainer = $VBoxContainer/CenterContainer/GridContainer
@onready var grid_container_2: GridContainer = $VBoxContainer/CenterContainer2/GridContainer
@onready var grid_container_3: GridContainer = $VBoxContainer/CenterContainer3/GridContainer


func _ready() -> void:
	# Wait for level data to be set, then populate
	call_deferred("_populate_menu")


## Set level data and refresh menu
func set_level_data(level_data: LevelData) -> void:
	current_level_data = level_data
	_populate_menu()


## Check if an item definition is available in the current level
func _is_item_available(definition: Resource) -> bool:
	if not definition:
		return false
	
	# Access properties directly (they're @export properties on BuildableItemDefinition)
	var item_type: String = definition.item_type
	var unlocked_by_default: bool = definition.unlocked_by_default
	
	# If no level data, show all default unlocked items (fallback)
	if not current_level_data:
		return unlocked_by_default
	
	# Check if item is in level's allowed_runes
	# Empty allowed_runes array means all default runes are available
	if current_level_data.allowed_runes.is_empty():
		# All default unlocked items are available
		return unlocked_by_default
	else:
		# Only items in allowed_runes are available
		return item_type in current_level_data.allowed_runes


## Initialize list of available buildable items (filtered by level)
func _initialize_available_items() -> void:
	available_items.clear()
	
	# Get all item definitions from GameConfig
	var all_definitions: Array = GameConfig.get_all_item_definitions()
	
	# Filter items based on availability
	for definition in all_definitions:
		if definition and _is_item_available(definition as Resource):
			available_items.append(definition)


## Populate the menu with available items
func _populate_menu() -> void:
	# Initialize available items (filtered by level)
	_initialize_available_items()
	# Get all grid containers
	var grid_containers: Array[GridContainer] = [
		grid_container_1,
		grid_container_2,
		grid_container_3,
	]
	
	# Clear existing items (keep structure, remove extra items)
	# Also disconnect signals from existing items to avoid duplicate connections
	for grid in grid_containers:
		if not grid:
			continue
		# Disconnect signals from existing placeholder items
		var children := grid.get_children()
		for child in children:
			if child.has_signal("item_selected"):
				if child.item_selected.is_connected(_on_item_selected):
					child.item_selected.disconnect(_on_item_selected)
		# Remove all children except the first two (which are placeholders)
		for i in range(2, children.size()):
			children[i].queue_free()
	
	# Load build menu item scene
	var item_scene := load("res://scenes/ui/build_menu_item.tscn")
	if not item_scene:
		push_error("BuildSubmenu: Failed to load build_menu_item.tscn")
		return
	
	# Populate each grid container with items
	var item_index := 0
	for grid in grid_containers:
		if not grid or item_index >= available_items.size():
			break
		
		# Get existing placeholder items
		var placeholders := grid.get_children()
		
		# Configure first placeholder
		if placeholders.size() > 0 and item_index < available_items.size():
			var definition: Resource = available_items[item_index] as Resource
			var item1: Control = placeholders[0] as Control
			if item1 and item1.has_method("configure") and definition:
				# Access properties directly (they're @export properties on BuildableItemDefinition)
				item1.configure(
					definition.item_type,
					definition.display_name,
					definition.cost,
					definition.icon_color
				)
				if item1.has_signal("item_selected") and not item1.item_selected.is_connected(_on_item_selected):
					item1.item_selected.connect(_on_item_selected)
			item_index += 1
		
		# Configure second placeholder
		if placeholders.size() > 1 and item_index < available_items.size():
			var definition: Resource = available_items[item_index] as Resource
			var item2: Control = placeholders[1] as Control
			if item2 and item2.has_method("configure") and definition:
				# Access properties directly (they're @export properties on BuildableItemDefinition)
				item2.configure(
					definition.item_type,
					definition.display_name,
					definition.cost,
					definition.icon_color
				)
				if item2.has_signal("item_selected") and not item2.item_selected.is_connected(_on_item_selected):
					item2.item_selected.connect(_on_item_selected)
			item_index += 1
	
	# Hide unused grid containers
	if item_index >= available_items.size():
		if grid_container_2 and item_index <= 2:
			grid_container_2.get_parent().visible = false
		if grid_container_3 and item_index <= 4:
			grid_container_3.get_parent().visible = false


## Handle item selection
func _on_item_selected(item_type: String) -> void:
	print("BuildSubmenu: Item selected: %s" % item_type)
	# Emit signal or call game_scene to handle selection
	# This will be connected to game_scene for placement logic
