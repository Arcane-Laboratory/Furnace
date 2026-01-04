extends Node
## Centralized scene manager for handling scene transitions


const TITLE_SCREEN := "res://scenes/ui/title_screen.tscn"
const MAIN_MENU := "res://scenes/ui/main_menu.tscn"
const GAME_SCENE := "res://scenes/game/game_scene.tscn"
const GAME_OVER := "res://scenes/ui/game_over.tscn"


func _ready() -> void:
	pass


func goto_title() -> void:
	get_tree().change_scene_to_file(TITLE_SCREEN)


func goto_menu() -> void:
	get_tree().change_scene_to_file(MAIN_MENU)


func goto_game() -> void:
	# In debug mode, start at level 0 (debug level)
	if GameConfig.debug_mode:
		GameManager.current_level = 0
	get_tree().change_scene_to_file(GAME_SCENE)


func goto_game_over(won: bool = false) -> void:
	GameManager.game_won = won
	get_tree().change_scene_to_file(GAME_OVER)


func reload_current_scene() -> void:
	get_tree().reload_current_scene()


func goto_next_level() -> void:
	GameManager.current_level += 1
	get_tree().change_scene_to_file(GAME_SCENE)
