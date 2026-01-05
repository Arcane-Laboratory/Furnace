extends CanvasLayer
## Final victory screen overlay - shown when all levels are cleared


signal menu_pressed
signal free_play_pressed


@onready var menu_button: Button = $PanelContainer/VBoxContainer/ResumeButton
@onready var free_play_button: Button = $PanelContainer/VBoxContainer/ResumeButton2


func _ready() -> void:
	menu_button.pressed.connect(_on_menu_pressed)
	free_play_button.pressed.connect(_on_free_play_pressed)
	hide()


## Show the final victory screen
func show_screen() -> void:
	show()
	menu_button.grab_focus()


## Hide the final victory screen
func hide_screen() -> void:
	hide()


func _on_menu_pressed() -> void:
	AudioManager.play_ui_click()
	hide_screen()
	menu_pressed.emit()


func _on_free_play_pressed() -> void:
	AudioManager.play_ui_click()
	hide_screen()
	free_play_pressed.emit()
