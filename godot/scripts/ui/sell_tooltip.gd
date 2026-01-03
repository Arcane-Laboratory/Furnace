extends PanelContainer
class_name SellTooltip
## Tooltip shown when clicking a sellable tile - allows selling placed items


## Emitted when sell button is pressed, with the grid position
signal sell_requested(grid_pos: Vector2i)


## The grid position this tooltip is showing for
var current_grid_pos: Vector2i = Vector2i(-1, -1)

## Reference to sell button
@onready var sell_button: Button = %SellButton


func _ready() -> void:
	# Ensure tooltip receives input and is on top
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 100
	visible = false
	
	if sell_button:
		sell_button.pressed.connect(_on_sell_button_pressed)


## Show the tooltip for a specific tile
func show_for_tile(grid_pos: Vector2i, refund_amount: int, screen_pos: Vector2) -> void:
	current_grid_pos = grid_pos
	
	# Update button text with refund amount
	if sell_button:
		sell_button.text = "Sell %d" % refund_amount
	
	# Position the tooltip (caller provides screen position)
	position = screen_pos
	visible = true


## Hide the tooltip
func hide_tooltip() -> void:
	visible = false
	current_grid_pos = Vector2i(-1, -1)


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
