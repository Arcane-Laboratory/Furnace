extends CanvasLayer
## Pause menu overlay


@onready var resume_button: Button = $PanelContainer/VBoxContainer/ResumeButton
@onready var restart_button: Button = $PanelContainer/VBoxContainer/RestartButton
@onready var menu_button: Button = $PanelContainer/VBoxContainer/MenuButton


func _ready() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	hide()


func show_pause_menu() -> void:
	show()
	resume_button.grab_focus()


func hide_pause_menu() -> void:
	hide()


func _on_resume_pressed() -> void:
	AudioManager.play_ui_click()
	hide_pause_menu()
	GameManager.resume_game()


func _on_restart_pressed() -> void:
	AudioManager.play_ui_click()
	hide_pause_menu()
	get_tree().paused = false
	SceneManager.reload_current_scene()


func _on_menu_pressed() -> void:
	AudioManager.play_ui_click()
	hide_pause_menu()
	get_tree().paused = false
	SceneManager.goto_menu()
