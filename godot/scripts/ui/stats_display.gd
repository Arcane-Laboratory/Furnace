extends Control
class_name StatsDisplay
## Stats display - tracks and displays game statistics (soot vanquished, sparks used, damage dealt)
## This component can be used standalone or controlled by a parent script.


## Reference to UI elements (using unique names)
@onready var level_value: Label = %LevelValue
@onready var money_value: Label = %MoneyValue
@onready var heat_value: Label = %HeatValue

## Track previous resources for calculating spent amount
var previous_resources: int = 0

## Cumulative sparks spent during the session
var sparks_spent: int = 0

## Animation tween reference
var currency_tween: Tween


func _ready() -> void:
	# Connect to GameManager resources signal to track spending
	GameManager.resources_changed.connect(_on_resources_changed)
	
	# Initialize with current resources value
	previous_resources = GameManager.resources
	
	# Initialize display
	_update_display()


## Update all display labels
func _update_display() -> void:
	_update_sparks_display()


## Handle resources changed signal - track spending
func _on_resources_changed(new_amount: int) -> void:
	var delta := new_amount - previous_resources
	previous_resources = new_amount
	
	# If delta is negative, money was spent
	if delta < 0:
		sparks_spent += abs(delta)
		_update_sparks_display()
		_animate_currency_change(delta)


## Update sparks spent display
func _update_sparks_display() -> void:
	if money_value:
		money_value.text = str(sparks_spent)


## Set level/soot vanquished display
func set_level(value: int) -> void:
	if level_value:
		level_value.text = str(value)


## Set sparks spent display directly
func set_sparks_spent(value: int) -> void:
	sparks_spent = value
	_update_sparks_display()


## Add to sparks spent
func add_sparks_spent(amount: int) -> void:
	sparks_spent += amount
	_update_sparks_display()


## Set damage dealt display
func set_damage(value: int) -> void:
	if heat_value:
		heat_value.text = str(value)


## Reset active phase stats (soot and damage) but preserve sparks spent
## Sparks spent persists across build/active phases since spending happens in build phase
func reset_stats() -> void:
	# Don't reset sparks_spent - it tracks spending from build phase
	# Only reset level and heat which are active-phase stats
	if level_value:
		level_value.text = "0"
	if heat_value:
		heat_value.text = "0"


## Full reset - call this when starting a new level
func reset_all() -> void:
	sparks_spent = 0
	previous_resources = GameManager.resources
	if level_value:
		level_value.text = "0"
	if money_value:
		money_value.text = "0"
	if heat_value:
		heat_value.text = "0"


## Animate currency change with color flash and scale pulse
func _animate_currency_change(delta: int) -> void:
	if not money_value or delta == 0:
		return
	
	# Cancel any existing animation
	if currency_tween and currency_tween.is_valid():
		currency_tween.kill()
	
	# Red flash for spending
	var flash_color := Color(1.0, 0.3, 0.3)
	
	# Store original pivot for scaling from center
	money_value.pivot_offset = money_value.size / 2.0
	
	# Create animation tween
	currency_tween = create_tween()
	currency_tween.set_parallel(true)
	
	# Color flash animation
	currency_tween.tween_property(money_value, "modulate", flash_color, 0.1)
	currency_tween.chain().tween_property(money_value, "modulate", Color.WHITE, 0.2)
	
	# Scale pulse animation (shrink for spending)
	currency_tween.tween_property(money_value, "scale", Vector2(0.9, 0.9), 0.1)
	currency_tween.chain().tween_property(money_value, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
