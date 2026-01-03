extends Node
## Autoload class for managing enemy spawning and lifecycle


signal enemy_spawned(enemy: EnemyBase)
signal enemy_died(enemy: EnemyBase)
signal enemy_reached_furnace(enemy: EnemyBase)
signal all_enemies_defeated()
signal furnace_destroyed()
signal debug_wave_restarted()  # Emitted in debug mode when wave restarts

## Current level data
var current_level_data: LevelData = null

## All spawned enemies (for tracking)
var active_enemies: Array[EnemyBase] = []

## Total enemies to spawn in this wave
var total_enemies_to_spawn: int = 0

## Enemies spawned so far
var enemies_spawned: int = 0

## Whether wave is currently active
var is_wave_active: bool = false

## Reference to enemies container in game scene
var enemies_container: Node2D = null


func _ready() -> void:
	pass


## Initialize wave with level data
func initialize_wave(level_data: LevelData, container: Node2D) -> void:
	current_level_data = level_data
	enemies_container = container
	active_enemies.clear()
	enemies_spawned = 0
	is_wave_active = false
	
	# Count total enemies
	total_enemies_to_spawn = level_data.enemy_waves.size()
	
	# Validate paths exist
	if not PathfindingManager.validate_all_spawn_paths(level_data):
		push_warning("EnemyManager: Not all spawn points have valid paths to furnace!")


## Start spawning enemies for the current wave
func start_wave() -> void:
	if not current_level_data:
		push_error("EnemyManager: Cannot start wave - no level data!")
		return
	
	if not enemies_container:
		push_error("EnemyManager: Cannot start wave - no enemies container!")
		return
	
	is_wave_active = true
	enemies_spawned = 0
	
	# Spawn all enemies with their delays
	for i in range(current_level_data.enemy_waves.size()):
		var wave_entry: EnemyWaveEntry = current_level_data.enemy_waves[i]
		var delay: float = wave_entry.delay
		
		# Create spawn task with delay
		await get_tree().create_timer(delay).timeout
		_spawn_enemy_from_entry(wave_entry)


## Apply enemy definition stats and path (called deferred after _ready())
func _apply_enemy_definition(enemy: EnemyBase, definition: EnemyDefinition, path: Array[Vector2i]) -> void:
	if not is_instance_valid(enemy):
		return
	
	# Set enemy stats from definition - this overrides any defaults set in _on_enemy_ready()
	enemy.health = definition.health
	enemy.max_health = definition.health
	enemy.speed = definition.speed
	
	# Set enemy path
	enemy.set_path(path)


## Spawn a single enemy based on wave entry (new enum-based system)
func _spawn_enemy_from_entry(wave_entry: EnemyWaveEntry) -> void:
	if not current_level_data or not enemies_container:
		return
	
	var enemy_type: String = wave_entry.get_enemy_type_string()
	var spawn_point_index: int = wave_entry.spawn_point
	
	_spawn_enemy_by_type(enemy_type, spawn_point_index)


## Spawn a single enemy based on wave data (legacy Dictionary format - kept for compatibility)
func _spawn_enemy(wave_data: Dictionary) -> void:
	if not current_level_data or not enemies_container:
		return
	
	var enemy_type: String = wave_data.get("enemy_type", "basic")
	var spawn_point_index: int = wave_data.get("spawn_point", 0)
	
	_spawn_enemy_by_type(enemy_type, spawn_point_index)


## Internal helper to spawn an enemy by type and spawn point index
func _spawn_enemy_by_type(enemy_type: String, spawn_point_index: int) -> void:
	if not current_level_data or not enemies_container:
		return
	
	# Validate spawn point index
	if spawn_point_index < 0 or spawn_point_index >= current_level_data.spawn_points.size():
		push_error("EnemyManager: Invalid spawn point index: %d" % spawn_point_index)
		return
	
	var spawn_pos: Vector2i = current_level_data.spawn_points[spawn_point_index]
	var furnace_pos: Vector2i = current_level_data.furnace_position
	
	# Load enemy definition
	var enemy_definition := GameConfig.get_enemy_definition(enemy_type)
	if not enemy_definition:
		push_error("EnemyManager: Enemy definition not found for type: %s" % enemy_type)
		return
	
	# Get scene path from definition
	var enemy_scene_path: String = enemy_definition.scene_path
	if enemy_scene_path.is_empty():
		# Fallback to default path pattern
		enemy_scene_path = "res://scenes/entities/enemies/%s_enemy.tscn" % enemy_type
	
	# If the specific enemy scene doesn't exist, fallback to basic enemy scene
	# This allows levels to use any enemy type even if the scene file doesn't exist yet
	if not ResourceLoader.exists(enemy_scene_path):
		push_warning("EnemyManager: Enemy scene not found: %s, falling back to basic_enemy.tscn" % enemy_scene_path)
		enemy_scene_path = "res://scenes/entities/enemies/basic_enemy.tscn"
		if not ResourceLoader.exists(enemy_scene_path):
			push_error("EnemyManager: Basic enemy scene also not found: %s" % enemy_scene_path)
			return
	
	var enemy_scene := load(enemy_scene_path)
	if not enemy_scene:
		push_error("EnemyManager: Failed to load enemy scene: %s" % enemy_scene_path)
		return
	
	# Instantiate enemy
	var enemy_node: Node = enemy_scene.instantiate()
	if not enemy_node:
		push_error("EnemyManager: Failed to instantiate enemy")
		return
	
	var enemy: EnemyBase = enemy_node as EnemyBase
	if not enemy:
		push_error("EnemyManager: Instantiated node is not an EnemyBase")
		return
	
	# Get path from spawn to furnace
	var path: Array[Vector2i] = PathfindingManager.find_path(spawn_pos, furnace_pos)
	if path.is_empty():
		push_error("EnemyManager: No path found from spawn %s to furnace %s" % [spawn_pos, furnace_pos])
		enemy.queue_free()
		return
	
	# Connect signals BEFORE adding to scene tree
	enemy.died.connect(_on_enemy_died.bind(enemy))
	enemy.reached_furnace.connect(_on_enemy_reached_furnace.bind(enemy))
	
	# Add to scene tree first (this triggers _ready() synchronously)
	enemies_container.add_child(enemy)
	
	# Set enemy stats from definition AFTER _ready() completes
	# Using call_deferred ensures _ready() has finished before we override stats
	var definition := enemy_definition as EnemyDefinition
	if definition:
		call_deferred("_apply_enemy_definition", enemy, definition, path)
	else:
		push_error("EnemyManager: Enemy definition is not an EnemyDefinition resource")
	
	# Track enemy
	active_enemies.append(enemy)
	enemies_spawned += 1
	
	# Emit spawn signal
	enemy_spawned.emit(enemy)
	
	print("EnemyManager: Spawned %s enemy at %s (path length: %d, health: %d, speed: %.1f)" % [enemy_type, spawn_pos, path.size(), enemy_definition.health, enemy_definition.speed])


## Called when an enemy dies
func _on_enemy_died(enemy: EnemyBase) -> void:
	# Remove from active enemies
	var index := active_enemies.find(enemy)
	if index >= 0:
		active_enemies.remove_at(index)
	
	enemy_died.emit(enemy)
	
	# Check if all enemies are defeated
	_check_win_condition()


## Called when an enemy reaches the furnace
func _on_enemy_reached_furnace(enemy: EnemyBase) -> void:
	enemy_reached_furnace.emit(enemy)
	
	# In debug mode, don't end the game when enemies reach furnace
	if GameConfig.debug_mode:
		print("EnemyManager: [DEBUG] Enemy reached furnace - ignoring (debug mode)")
		# Remove enemy from tracking so win condition can still trigger
		var index := active_enemies.find(enemy)
		if index >= 0:
			active_enemies.remove_at(index)
		_check_win_condition()
		return
	
	furnace_destroyed.emit()
	
	# Game over - enemy reached furnace
	print("EnemyManager: Enemy reached furnace - GAME OVER")


## Check if all enemies are defeated (win condition)
func _check_win_condition() -> void:
	# Check if wave is active, all enemies spawned, and all defeated
	if is_wave_active and enemies_spawned >= total_enemies_to_spawn and active_enemies.is_empty():
		# In debug mode, respawn the wave instead of ending the game
		if GameConfig.debug_mode:
			print("EnemyManager: [DEBUG] All enemies defeated - respawning wave...")
			_restart_wave_debug()
			return
		
		is_wave_active = false
		all_enemies_defeated.emit()
		print("EnemyManager: All enemies defeated - VICTORY!")


## [DEBUG ONLY] Restart the wave after a short delay
func _restart_wave_debug() -> void:
	# Reset spawn count but keep wave active
	enemies_spawned = 0
	
	# Wait a moment before respawning
	await get_tree().create_timer(2.0).timeout
	
	# Emit signal so game_scene can respawn fireball
	debug_wave_restarted.emit()
	
	# Respawn all enemies from the wave
	for i in range(current_level_data.enemy_waves.size()):
		var wave_entry: EnemyWaveEntry = current_level_data.enemy_waves[i]
		var delay: float = wave_entry.delay
		
		await get_tree().create_timer(delay).timeout
		_spawn_enemy_from_entry(wave_entry)


## Get count of active enemies
func get_active_enemy_count() -> int:
	return active_enemies.size()


## Clear all enemies (for cleanup)
func clear_enemies() -> void:
	for enemy in active_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	active_enemies.clear()
	is_wave_active = false
