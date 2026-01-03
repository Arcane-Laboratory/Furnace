extends Control
## Game over screen - shows win/lose state


@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel
@onready var retry_button: Button = $CenterContainer/VBoxContainer/RetryButton
@onready var menu_button: Button = $CenterContainer/VBoxContainer/MenuButton


func _ready() -> void:
	GameManager.set_state(GameManager.GameState.GAME_OVER)
	
	if GameManager.game_won:
		title_label.text = "Victory!"
		AudioManager.play_victory_music()
	else:
		title_label.text = "Game Over"
		AudioManager.play_defeat_music()
	
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	retry_button.grab_focus()


func _on_retry_pressed() -> void:
	SceneManager.goto_game()


func _on_menu_pressed() -> void:
	SceneManager.goto_menu()
