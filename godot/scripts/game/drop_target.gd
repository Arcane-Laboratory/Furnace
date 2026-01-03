extends Control
## Drop target overlay for receiving drag-and-drop from build menu


signal drop_received(data: Dictionary, at_position: Vector2)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS


## Check if we can accept this drag data
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data is Dictionary:
		return data.get("type") == "buildable_item"
	return false


## Handle the drop
func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is Dictionary:
		# Pass local position (relative to drop target, which matches game board)
		drop_received.emit(data as Dictionary, at_position)
