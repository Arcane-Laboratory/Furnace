extends Control
## Level in progress submenu - tracks and displays active phase statistics


signal restart_requested


## Current stats
var soot_vanquished: int = 0
var sparks_earned: int = 0
var damage_dealt: int = 0

## Reference to UI elements (using unique names)
@onready var soot_value: Label = %LevelValue
@onready var sparks_value: Label = %MoneyValue
@onready var heat_value: Label = %HeatValue
@onready var restart_button: Button = $MarginContainer2/Button
@onready var progress_bar: TextureProgressBar = $CenterContainer/VBoxContainer/MarginContainer/TextureProgressBar


func _ready() -> void:
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	
	# Initialize display
	_update_display()


## Reset all stats to zero
func reset_stats() -> void:
	soot_vanquished = 0
	sparks_earned = 0
	damage_dealt = 0
	_update_display()


## Add to soot vanquished count
func add_soot_vanquished(count: int = 1) -> void:
	soot_vanquished += count
	_update_soot_display()


## Set sparks earned (total earned during active phase)
func set_sparks_earned(amount: int) -> void:
	sparks_earned = amount
	_update_sparks_display()


## Add to sparks earned
func add_sparks_earned(amount: int) -> void:
	sparks_earned += amount
	_update_sparks_display()


## Add to damage dealt
func add_damage_dealt(amount: int) -> void:
	damage_dealt += amount
	_update_damage_display()


## Update all display labels
func _update_display() -> void:
	_update_soot_display()
	_update_sparks_display()
	_update_damage_display()


## Update soot vanquished display
func _update_soot_display() -> void:
	if soot_value:
		soot_value.text = str(soot_vanquished)


## Update sparks earned display
func _update_sparks_display() -> void:
	if sparks_value:
		sparks_value.text = str(sparks_earned)


## Update damage dealt display
func _update_damage_display() -> void:
	if heat_value:
		heat_value.text = str(damage_dealt)


## Set wave progress (0.0 to 1.0)
func set_wave_progress(progress: float) -> void:
	if progress_bar:
		progress_bar.value = progress * 100.0


## Handle restart button pressed
func _on_restart_pressed() -> void:
	restart_requested.emit()
