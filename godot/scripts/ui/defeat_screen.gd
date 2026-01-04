extends CanvasLayer
## Defeat screen overlay - shown when furnace is overrun


signal menu_pressed
signal restart_pressed


@onready var title_label: Label = $PanelContainer/VBoxContainer/VBoxContainer/PausedLabel
@onready var stats_display: Control = $PanelContainer/VBoxContainer/VBoxContainer/StatsDisplay
@onready var menu_button: Button = $PanelContainer/VBoxContainer/ResumeButton
@onready var restart_button: Button = $PanelContainer/VBoxContainer/ResumeButton2


func _ready() -> void:
	menu_button.pressed.connect(_on_menu_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	hide()


## Show the defeat screen with level info and stats
## stats should contain: { soot: int, sparks: int, damage: int }
func show_screen(level: int, stats: Dictionary) -> void:
	# Mute gameplay sounds (fireball bouncing, runes, etc.) while modal is shown
	AudioManager.mute_gameplay_sounds()
	
	# Update title with level number
	title_label.text = "LEVEL %d\nOVERRUN" % level
	
	# Update stats display
	if stats_display and stats_display.has_method("set_stats"):
		var soot: int = stats.get("soot", 0)
		var sparks: int = stats.get("sparks", 0)
		var damage: int = stats.get("damage", 0)
		stats_display.set_stats(soot, sparks, damage)
	
	# Play defeat sound (allowed even when gameplay sounds are muted)
	AudioManager.play_sound_effect("level-failed")
	
	# Show the overlay
	show()
	restart_button.grab_focus()


## Hide the defeat screen
func hide_screen() -> void:
	hide()


func _on_menu_pressed() -> void:
	AudioManager.play_ui_click()
	hide_screen()
	menu_pressed.emit()


func _on_restart_pressed() -> void:
	AudioManager.play_ui_click()
	hide_screen()
	restart_pressed.emit()
