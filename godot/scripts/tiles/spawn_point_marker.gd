extends Node2D
class_name SpawnPointMarker
## Visual marker for enemy spawn points with state-based sprite changes


enum SpawnState {
	IDLE,      # No spawning activity
	SOON,      # Enemy about to spawn (2-3 seconds before)
	SPAWNING,  # Currently spawning enemies
}

## Current spawn state
var current_state: SpawnState = SpawnState.IDLE

## Spawn point index in the level data
var spawn_index: int = -1

## Reference to the sprite node
@onready var sprite: Sprite2D = $Sprite2D

## Textures for different states
var texture_idle: Texture2D = null
var texture_soon: Texture2D = null

## Timer for returning to idle state after spawning
var spawn_cooldown_timer: float = 0.0


func _ready() -> void:
	# Load textures
	texture_idle = load("res://assets/sprites/spawn-idle.png")
	texture_soon = load("res://assets/sprites/spawn-soon.png")
	
	# Set initial texture
	if sprite and texture_idle:
		sprite.texture = texture_idle


func _process(delta: float) -> void:
	# Handle cooldown timer for returning to idle state
	if spawn_cooldown_timer > 0.0:
		spawn_cooldown_timer -= delta
		if spawn_cooldown_timer <= 0.0 and current_state == SpawnState.SPAWNING:
			set_state(SpawnState.IDLE)


## Set the spawn state and update visuals accordingly
func set_state(new_state: SpawnState) -> void:
	if current_state == new_state:
		return
	
	current_state = new_state
	_update_visuals()


## Update visual appearance based on current state
func _update_visuals() -> void:
	if not sprite:
		return
	
	match current_state:
		SpawnState.IDLE:
			if texture_idle:
				sprite.texture = texture_idle
			sprite.modulate = Color.WHITE
		SpawnState.SOON:
			if texture_soon:
				sprite.texture = texture_soon
			sprite.modulate = Color.WHITE
		SpawnState.SPAWNING:
			if texture_soon:
				sprite.texture = texture_soon
			sprite.modulate = Color.WHITE


## Called when an enemy is about to spawn (2-3 seconds before)
func notify_spawn_soon() -> void:
	set_state(SpawnState.SOON)


## Called when an enemy is actively spawning
func notify_spawning() -> void:
	set_state(SpawnState.SPAWNING)
	# Reset cooldown timer - stay in spawning state for a short duration
	spawn_cooldown_timer = 0.5


## Called when spawning is complete and should return to idle
func notify_spawn_complete() -> void:
	set_state(SpawnState.IDLE)


## Get the grid position of this spawn point
func get_grid_position() -> Vector2i:
	return Vector2i(
		int(position.x / GameConfig.TILE_SIZE),
		int(position.y / GameConfig.TILE_SIZE)
	)
