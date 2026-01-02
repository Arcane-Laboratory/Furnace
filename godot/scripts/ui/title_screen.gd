extends Control
## Title screen - displays game title and waits for input


func _ready() -> void:
	GameManager.set_state(GameManager.GameState.TITLE)


func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		if event.pressed:
			SceneManager.goto_menu()
