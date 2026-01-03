extends PanelContainer
class_name TileTooltip
## Tooltip shown when clicking a tile - allows actions like selling placed items and changing direction


## Emitted when sell button is pressed, with the grid position
signal sell_requested(grid_pos: Vector2i)

## Emitted when direction is changed, with the grid position and new direction
signal direction_changed(grid_pos: Vector2i, direction: String)


## The grid position this tooltip is showing for
var current_grid_pos: Vector2i = Vector2i(-1, -1)

## Reference to the current structure (rune) if any
var current_structure: Node = null

## Reference to sell button
@onready var sell_button: Button = %SellButton

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
	
	# Connect direction buttons
	if up_button:
		up_button.pressed.connect(_on_direction_pressed.bind("north"))
	if down_button:
		down_button.pressed.connect(_on_direction_pressed.bind("south"))
	if left_button:
		left_button.pressed.connect(_on_direction_pressed.bind("west"))
	if right_button:
		right_button.pressed.connect(_on_direction_pressed.bind("east"))


## Show the tooltip for a specific tile
## show_sell: Whether to show the sell button (set to false during active phase)
func show_for_tile(grid_pos: Vector2i, refund_amount: int, screen_pos: Vector2, has_direction: bool = false, structure: Node = null, show_sell: bool = true) -> void:
	current_grid_pos = grid_pos
	current_structure = structure
	
	# Update button text with refund amount and visibility
	if sell_button:
		sell_button.text = "Sell %d" % refund_amount
		sell_button.visible = show_sell
	
	# Show/hide direction controls based on item type
	if direction_container:
		direction_container.visible = has_direction
	
	# Position the tooltip (caller provides screen position)
	position = screen_pos
	visible = true


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
	if current_grid_pos != Vector2i(-1, -1):
		sell_requested.emit(current_grid_pos)
	hide_tooltip()


## Handle direction button press
func _on_direction_pressed(direction: String) -> void:
	if current_grid_pos == Vector2i(-1, -1):
		return
	
	# Update the structure's direction if it has the method
	if current_structure and current_structure.has_method("set_direction_by_string"):
		current_structure.set_direction_by_string(direction)
	
	# Emit signal for any other listeners
	direction_changed.emit(current_grid_pos, direction)
