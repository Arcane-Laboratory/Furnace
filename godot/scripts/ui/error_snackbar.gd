extends Control
class_name ErrorSnackbar
## Error snackbar - shows placement/action error messages


signal dismissed


## Auto-hide timeout in seconds (shorter than help snackbar)
const AUTO_HIDE_SECONDS: float = 2.0

## Reference to the label showing the error text
@onready var error_label: Label = $MarginContainer/VBoxContainer/Label3

## Timer for auto-hide
var auto_hide_timer: Timer = null

## Tween for animations
var animation_tween: Tween = null


func _ready() -> void:
	# Start hidden
	visible = false
	modulate.a = 0.0
	
	# Create auto-hide timer
	auto_hide_timer = Timer.new()
	auto_hide_timer.one_shot = true
	auto_hide_timer.timeout.connect(_on_auto_hide_timeout)
	add_child(auto_hide_timer)


## Show the snackbar with error text
func show_error(text: String) -> void:
	if text.is_empty():
		return
	
	if error_label:
		error_label.text = text
	
	# Cancel any existing animation
	if animation_tween and animation_tween.is_valid():
		animation_tween.kill()
	
	# Show and animate in
	visible = true
	modulate.a = 0.0
	
	animation_tween = create_tween()
	animation_tween.tween_property(self, "modulate:a", 1.0, 0.15).set_ease(Tween.EASE_OUT)
	
	# Start auto-hide timer
	auto_hide_timer.start(AUTO_HIDE_SECONDS)


## Hide the snackbar with animation
func hide_snackbar() -> void:
	if not visible:
		return
	
	# Stop auto-hide timer
	auto_hide_timer.stop()
	
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


## Handle auto-hide timeout
func _on_auto_hide_timeout() -> void:
	hide_snackbar()
