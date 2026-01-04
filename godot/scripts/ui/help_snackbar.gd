extends Control
class_name HelpSnackbar
## Help snackbar - shows level hint text at start of build phase


signal dismissed


## Auto-hide timeout in seconds
const AUTO_HIDE_SECONDS: float = 8.0

## Reference to the label showing the hint text
@onready var hint_label: Label = $MarginContainer/VBoxContainer/Label3

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


func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	# Dismiss on escape
	if event.is_action_pressed("ui_cancel"):
		hide_snackbar()
		get_viewport().set_input_as_handled()
		return
	
	# Dismiss on click outside
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Check if click is outside this control
		var local_pos := get_local_mouse_position()
		var rect := get_rect()
		# Adjust rect to local coordinates (0, 0 based)
		rect.position = Vector2.ZERO
		if not rect.has_point(local_pos):
			hide_snackbar()
			# Don't consume the click - let it pass through to game


## Show the snackbar with hint text
func show_hint(text: String) -> void:
	if text.is_empty():
		return
	
	if hint_label:
		hint_label.text = text
	
	# Cancel any existing animation
	if animation_tween and animation_tween.is_valid():
		animation_tween.kill()
	
	# Show and animate in
	visible = true
	modulate.a = 0.0
	
	animation_tween = create_tween()
	animation_tween.tween_property(self, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT)
	
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
	animation_tween.tween_property(self, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_IN)
	animation_tween.tween_callback(func():
		visible = false
		dismissed.emit()
	)


## Handle auto-hide timeout
func _on_auto_hide_timeout() -> void:
	hide_snackbar()
