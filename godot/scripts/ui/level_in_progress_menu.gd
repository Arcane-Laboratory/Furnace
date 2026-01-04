extends Control
## Level in progress menu - shown during active phase, combines GameSubmenu and stats tracking


signal pause_pressed
signal restart_requested


## Reference to sub-components
@onready var game_submenu: GameSubmenu = $CenterContainer/VBoxContainer/GameSubmenu
@onready var in_progress_submenu: Control = $CenterContainer/VBoxContainer/InProgressSubmenu


func _ready() -> void:
	# Connect GameSubmenu start button (which says "Pause" in this context)
	if game_submenu:
		game_submenu.start_pressed.connect(_on_pause_pressed)
	
	# Connect InProgressSubmenu restart button
	if in_progress_submenu and in_progress_submenu.has_signal("restart_requested"):
		in_progress_submenu.restart_requested.connect(_on_restart_requested)


## Set the current level display
func set_level(level: int) -> void:
	if game_submenu:
		game_submenu.set_level(level)


## Reset all active phase stats
func reset_stats() -> void:
	if in_progress_submenu and in_progress_submenu.has_method("reset_stats"):
		in_progress_submenu.reset_stats()


## Get the in progress submenu for direct stat updates
func get_in_progress_submenu() -> Control:
	return in_progress_submenu


## Handle pause button pressed
func _on_pause_pressed() -> void:
	pause_pressed.emit()


## Handle restart requested from submenu
func _on_restart_requested() -> void:
	restart_requested.emit()
