extends Control
## Main menu with game options


@onready var start_button: Button = get_node_or_null("CenterContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/StartButton") as Button
@onready var settings_button: Button = get_node_or_null("CenterContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/SettingsButton") as Button
@onready var quit_button: Button = get_node_or_null("CenterContainer/HBoxContainer/VBoxContainer/CenterContainer/HBoxContainer/QuitButton") as Button


func _ready() -> void:
	GameManager.set_state(GameManager.GameState.MENU)
	if start_button:
		start_button.pressed.connect(_on_start_pressed)
		start_button.grab_focus()
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)


func _on_start_pressed() -> void:
	AudioManager.play_ui_click()
	SceneManager.goto_game()


func _on_settings_pressed() -> void:
	AudioManager.play_ui_click()
	# Placeholder - settings not implemented yet
	pass


func _on_quit_pressed() -> void:
	AudioManager.play_ui_click()
	get_tree().quit()
