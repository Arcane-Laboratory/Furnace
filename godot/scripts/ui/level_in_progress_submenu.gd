extends Control
## Level in progress submenu - tracks and displays active phase statistics


signal restart_requested


## Current stats
var soot_vanquished: int = 0
var damage_dealt: int = 0

## Reference to StatsDisplay child (handles sparks spent tracking)
@onready var stats_display: StatsDisplay = $CenterContainer/VBoxContainer/StatsDisplay

## Reference to UI elements (soot and damage - sparks handled by StatsDisplay)
@onready var soot_value: Label = null
@onready var heat_value: Label = null
@onready var restart_button: Button = $MarginContainer2/Button
@onready var progress_bar: TextureProgressBar = $CenterContainer/VBoxContainer/MarginContainer/TextureProgressBar


func _ready() -> void:
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	
	# Get label references from StatsDisplay child
	_ensure_labels_ready()
	
	# Initialize display
	_update_display()


## Ensure label references are initialized (handles timing issues)
func _ensure_labels_ready() -> void:
	# Get labels from the StatsDisplay child instance
	if stats_display:
		if not soot_value:
			soot_value = stats_display.get_node_or_null("%LevelValue") as Label
		if not heat_value:
			heat_value = stats_display.get_node_or_null("%HeatValue") as Label
	else:
		# Fallback: try to find in our own tree
		if not soot_value:
			soot_value = get_node_or_null("%LevelValue") as Label
		if not heat_value:
			heat_value = get_node_or_null("%HeatValue") as Label


## Reset all stats to zero
func reset_stats() -> void:
	soot_vanquished = 0
	damage_dealt = 0
	_update_display()
	# Reset StatsDisplay sparks tracking
	if stats_display:
		stats_display.reset_stats()


## Add to soot vanquished count
func add_soot_vanquished(count: int = 1) -> void:
	soot_vanquished += count
	_ensure_labels_ready()
	_update_soot_display()


## Set sparks spent (delegates to StatsDisplay)
func set_sparks_earned(amount: int) -> void:
	# Note: This is kept for backwards compatibility but "sparks used" now means sparks spent
	# The StatsDisplay tracks this automatically via GameManager.resources_changed
	pass


## Add to sparks spent (delegates to StatsDisplay)
func add_sparks_earned(amount: int) -> void:
	# Note: This is kept for backwards compatibility
	# The StatsDisplay tracks sparks spent automatically
	pass


## Add to damage dealt
func add_damage_dealt(amount: int) -> void:
	damage_dealt += amount
	_ensure_labels_ready()
	_update_damage_display()


## Update all display labels
func _update_display() -> void:
	_update_soot_display()
	_update_damage_display()
	# Sparks display is handled by StatsDisplay script


## Update soot vanquished display
func _update_soot_display() -> void:
	_ensure_labels_ready()
	if soot_value:
		soot_value.text = str(soot_vanquished)
	else:
		push_warning("LevelInProgressSubmenu: soot_value label not found! Value: %d" % soot_vanquished)


## Update damage dealt display
func _update_damage_display() -> void:
	_ensure_labels_ready()
	if heat_value:
		heat_value.text = str(damage_dealt)
	else:
		push_warning("LevelInProgressSubmenu: heat_value label not found! Value: %d" % damage_dealt)


## Set wave progress (0.0 to 1.0)
func set_wave_progress(progress: float) -> void:
	if progress_bar:
		progress_bar.value = progress * 100.0


## Handle restart button pressed
func _on_restart_pressed() -> void:
	AudioManager.play_ui_click()
	restart_requested.emit()
