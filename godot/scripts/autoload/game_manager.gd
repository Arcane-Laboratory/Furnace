extends Node
## Global game state manager


enum GameState {
	TITLE,
	MENU,
	BUILD_PHASE,
	ACTIVE_PHASE,
	PAUSED,
	GAME_OVER
}

var current_state: GameState = GameState.TITLE
var _state_before_pause: GameState = GameState.BUILD_PHASE
var current_level: int = 1
var resources: int = 0
var game_won: bool = false
var infinite_money: bool = false  # Debug flag: when true, placements don't cost resources

signal state_changed(new_state: GameState)
signal resources_changed(new_amount: int)


func _ready() -> void:
	pass


func set_state(new_state: GameState) -> void:
	current_state = new_state
	state_changed.emit(new_state)


func add_resources(amount: int) -> void:
	resources += amount
	resources_changed.emit(resources)


func spend_resources(amount: int) -> bool:
	if infinite_money:
		return true  # Skip spending when infinite money is enabled
	if resources >= amount:
		resources -= amount
		resources_changed.emit(resources)
		return true
	return false


func reset_for_level(level: int) -> void:
	current_level = level
	resources = GameConfig.get_level_resources(level)
	game_won = false
	resources_changed.emit(resources)


func start_build_phase() -> void:
	set_state(GameState.BUILD_PHASE)


func start_active_phase() -> void:
	set_state(GameState.ACTIVE_PHASE)


func pause_game() -> void:
	if current_state == GameState.BUILD_PHASE or current_state == GameState.ACTIVE_PHASE:
		_state_before_pause = current_state
		set_state(GameState.PAUSED)
		get_tree().paused = true


func resume_game() -> void:
	if current_state == GameState.PAUSED:
		get_tree().paused = false
		set_state(_state_before_pause)


func end_game(won: bool) -> void:
	game_won = won
	set_state(GameState.GAME_OVER)
