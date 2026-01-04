extends PanelContainer
class_name TileTooltip
## Tooltip shown when clicking a tile - allows actions like selling placed items and changing direction


## Emitted when sell button is pressed, with the grid position
signal sell_requested(grid_pos: Vector2i)

## Emitted when direction is changed, with the grid position and new direction
signal direction_changed(grid_pos: Vector2i, direction: String)

## Emitted when upgrade button is pressed
signal upgrade_requested(grid_pos: Vector2i)


## The grid position this tooltip is showing for
var current_grid_pos: Vector2i = Vector2i(-1, -1)

## Reference to the current structure (rune) if any
var current_structure: Node = null

## Reference to sell button
@onready var sell_button: Button = %SellButton

## Reference to upgrade button (created dynamically if needed)
var upgrade_button: Button = null

## Reference to direction controls container
@onready var direction_container: VBoxContainer = %DirectionContainer

## Reference to direction buttons
@onready var up_button: Button = %UpButton
@onready var down_button: Button = %DownButton
@onready var left_button: Button = %LeftButton
@onready var right_button: Button = %RightButton


func _ready() -> void:
	# Ensure tooltip receives input and is on top
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 100
	visible = false
	
	if sell_button:
		sell_button.pressed.connect(_on_sell_button_pressed)
	
	# Create upgrade button (insert after sell button)
	_create_upgrade_button()
	
	# Connect direction buttons
	if up_button:
		up_button.pressed.connect(_on_direction_pressed.bind("north"))
	if down_button:
		down_button.pressed.connect(_on_direction_pressed.bind("south"))
	if left_button:
		left_button.pressed.connect(_on_direction_pressed.bind("west"))
	if right_button:
		right_button.pressed.connect(_on_direction_pressed.bind("east"))


## Create the upgrade button dynamically
func _create_upgrade_button() -> void:
	if upgrade_button:
		return
	
	upgrade_button = Button.new()
	upgrade_button.name = "UpgradeButton"
	upgrade_button.custom_minimum_size = Vector2(60, 14)
	upgrade_button.text = "Upgrade 0"
	upgrade_button.visible = false
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)
	
	# Insert after sell button in the same container
	if sell_button and sell_button.get_parent():
		var parent := sell_button.get_parent()
		var sell_index := sell_button.get_index()
		parent.add_child(upgrade_button)
		parent.move_child(upgrade_button, sell_index + 1)


## Show the tooltip for a specific tile
## show_sell: Whether to show the sell button (set to false during active phase)
## show_upgrade: Whether to show the upgrade button (set to false during active phase)
func show_for_tile(grid_pos: Vector2i, refund_amount: int, screen_pos: Vector2, has_direction: bool = false, structure: Node = null, show_sell: bool = true, show_upgrade: bool = true) -> void:
	current_grid_pos = grid_pos
	current_structure = structure
	
	# Update button text with refund amount and visibility
	if sell_button:
		sell_button.text = "Sell %d" % refund_amount
		sell_button.visible = show_sell
	
	# Update upgrade button visibility and text
	_update_upgrade_button(structure, show_upgrade)
	
	# Show/hide direction controls based on item type
	if direction_container:
		direction_container.visible = has_direction
	
	# Position the tooltip (caller provides screen position)
	position = screen_pos
	visible = true


## Update upgrade button based on structure's upgrade capability
func _update_upgrade_button(structure: Node, show_upgrade: bool) -> void:
	if not upgrade_button:
		return
	
	# Hide by default
	upgrade_button.visible = false
	
	if not show_upgrade or not structure:
		return
	
	# Check if structure is a rune that can be upgraded
	if structure is RuneBase:
		var rune := structure as RuneBase
		if rune.can_upgrade():
			var upgrade_cost := rune.get_upgrade_cost()
			upgrade_button.text = "Upgrade %d" % upgrade_cost
			upgrade_button.visible = true


## Hide the tooltip
func hide_tooltip() -> void:
	visible = false
	current_grid_pos = Vector2i(-1, -1)
	current_structure = null


## Check if mouse is currently over this tooltip
func is_mouse_over() -> bool:
	if not visible:
		return false
	
	var mouse_pos := get_viewport().get_mouse_position()
	var tooltip_rect := Rect2(global_position, size)
	return tooltip_rect.has_point(mouse_pos)


## Get the current grid position
func get_grid_pos() -> Vector2i:
	return current_grid_pos


## Handle sell button press
func _on_sell_button_pressed() -> void:
	AudioManager.play_ui_click()
	if current_grid_pos != Vector2i(-1, -1):
		sell_requested.emit(current_grid_pos)
	hide_tooltip()


## Handle direction button press
func _on_direction_pressed(direction: String) -> void:
	AudioManager.play_ui_click()
	if current_grid_pos == Vector2i(-1, -1):
		return
	
	# Update the structure's direction if it has the method
	if current_structure and current_structure.has_method("set_direction_by_string"):
		current_structure.set_direction_by_string(direction)
	
	# Emit signal for any other listeners
	direction_changed.emit(current_grid_pos, direction)


## Handle upgrade button press
func _on_upgrade_button_pressed() -> void:
	AudioManager.play_ui_click()
	if current_grid_pos == Vector2i(-1, -1):
		return
	
	upgrade_requested.emit(current_grid_pos)
	
	# Update the upgrade button after upgrade (it may no longer be upgradable)
	_update_upgrade_button(current_structure, true)
