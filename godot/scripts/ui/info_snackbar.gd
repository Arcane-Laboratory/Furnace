extends Control
class_name InfoSnackbar
## Info snackbar - shows informational messages (e.g., portal placement instructions)


signal dismissed


## Reference to the label showing the info text
@onready var info_label: Label = $MarginContainer/VBoxContainer/Label3

## Tween for animations
var animation_tween: Tween = null


func _ready() -> void:
	# Start hidden
	visible = false
	modulate.a = 0.0


## Show the snackbar with info text
func show_info(text: String) -> void:
	if text.is_empty():
		return
	
	if info_label:
		info_label.text = text
	
	# Cancel any existing animation
	if animation_tween and animation_tween.is_valid():
		animation_tween.kill()
	
	# Show and animate in
	visible = true
	modulate.a = 0.0
	
	animation_tween = create_tween()
	animation_tween.tween_property(self, "modulate:a", 1.0, 0.15).set_ease(Tween.EASE_OUT)


## Hide the snackbar with animation
func hide_snackbar() -> void:
	if not visible:
		return
	
	# Cancel any existing animation
	if animation_tween and animation_tween.is_valid():
		animation_tween.kill()
	
	# Animate out
	animation_tween = create_tween()
	animation_tween.tween_property(self, "modulate:a", 0.0, 0.3).set_ease(Tween.EASE_IN)
	animation_tween.tween_callback(func():
		visible = false
		dismissed.emit()
	)
