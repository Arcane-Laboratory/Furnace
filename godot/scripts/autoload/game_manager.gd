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


## Get the highest level number available (excluding level 0 which is debug)
## Checks for level files using ResourceLoader.exists() which works in both editor and web builds
## DirAccess doesn't work reliably in web exports, so we check each level file explicitly
func get_max_level() -> int:
	var max_level: int = 1
	
	# Check levels up to a reasonable maximum (e.g., 20)
	# Start from 1 and work upwards to find the highest existing level
	for level_num in range(1, 21):  # Check levels 1-20
		var level_path := "res://resources/levels/level_%d.tres" % level_num
		if ResourceLoader.exists(level_path):
			max_level = level_num
		else:
			# Once we hit a missing level, we can stop (assuming levels are sequential)
			# But continue checking in case there are gaps
			pass
	
	return max_level


## Check if the given level is the final level (highest numbered level)
func is_final_level(level: int) -> bool:
	return level == get_max_level()