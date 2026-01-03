extends Control
class_name GameSubmenu
## Game submenu - displays level info, money, and start button with currency animation


signal start_pressed


## Reference to UI elements
@onready var money_value: Label = $MarginContainer/CenterContainer/VBoxContainer/MoneyRow/Panel/CenterContainer/MoneyValue
@onready var level_value: Label = $MarginContainer/CenterContainer/VBoxContainer/LevelRow/Panel/CenterContainer/LevelValue
@onready var start_button: Button = $MarginContainer/CenterContainer/VBoxContainer/StartButton

## Track previous resources for animation direction
var previous_resources: int = 0

## Animation tween reference
var currency_tween: Tween


func _ready() -> void:
	if start_button:
		start_button.pressed.connect(_on_start_button_pressed)
	
	# Connect to GameManager resources signal
	GameManager.resources_changed.connect(_on_resources_changed)
	
	# Initialize with current values
	_update_display()


## Update display with current GameManager values
func _update_display() -> void:
	if money_value:
		money_value.text = "$%d" % GameManager.resources
		previous_resources = GameManager.resources
	if level_value:
		level_value.text = str(GameManager.current_level)


## Set the level display
func set_level(level: int) -> void:
	if level_value:
		level_value.text = str(level)


## Set the money display (without animation)
func set_money(amount: int) -> void:
	if money_value:
		money_value.text = "$%d" % amount
		previous_resources = amount


## Handle resources changed signal with animation
func _on_resources_changed(new_amount: int) -> void:
	var delta := new_amount - previous_resources
	previous_resources = new_amount
	
	if money_value:
		money_value.text = "$%d" % new_amount
		_animate_currency_change(delta)


## Animate currency change with color flash and scale pulse
func _animate_currency_change(delta: int) -> void:
	if not money_value or delta == 0:
		return
	
	# Cancel any existing animation
	if currency_tween and currency_tween.is_valid():
		currency_tween.kill()
	
	# Determine flash color based on delta direction
	var flash_color: Color
	if delta > 0:
		flash_color = Color(0.3, 1.0, 0.3)  # Green for gain
	else:
		flash_color = Color(1.0, 0.3, 0.3)  # Red for spend
	
	# Store original pivot for scaling from center
	money_value.pivot_offset = money_value.size / 2.0
	
	# Create animation tween
	currency_tween = create_tween()
	currency_tween.set_parallel(true)
	
	# Color flash animation
	currency_tween.tween_property(money_value, "modulate", flash_color, 0.1)
	currency_tween.chain().tween_property(money_value, "modulate", Color.WHITE, 0.2)
	
	# Scale pulse animation
	var target_scale: Vector2
	if delta > 0:
		target_scale = Vector2(1.15, 1.15)  # Scale up for gain
	else:
		target_scale = Vector2(0.9, 0.9)  # Scale down for spend
	
	currency_tween.tween_property(money_value, "scale", target_scale, 0.1)
	currency_tween.chain().tween_property(money_value, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


## Handle start button pressed
func _on_start_button_pressed() -> void:
	start_pressed.emit()
