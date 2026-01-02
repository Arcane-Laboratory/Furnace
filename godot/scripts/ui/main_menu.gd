extends Control
## Main menu with game options


@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var settings_button: Button = $CenterContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton


func _ready() -> void:
	GameManager.set_state(GameManager.GameState.MENU)
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	start_button.grab_focus()


func _on_start_pressed() -> void:
	SceneManager.goto_game()


func _on_settings_pressed() -> void:
	# Placeholder - settings not implemented yet
	pass


func _on_quit_pressed() -> void:
	get_tree().quit()
