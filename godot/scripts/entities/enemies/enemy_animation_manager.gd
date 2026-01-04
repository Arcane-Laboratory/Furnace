extends Node2D
class_name EnemyAnimationManager
## Manages enemy animations using AnimatedSprite2D with SpriteFrames resource


## Reference to the AnimatedSprite2D node
var animated_sprite: AnimatedSprite2D = null


func _ready() -> void:
	# Get reference to AnimatedSprite2D (should be a child of this node)
	animated_sprite = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if not animated_sprite:
		push_error("EnemyAnimationManager: AnimatedSprite2D node not found!")
		return
	
	# Ensure z_index is set
	animated_sprite.z_index = 0
	
	# Play spawn animation by default (will transition to walk when complete)
	play_spawn()


## Play walk animation
func play_walk() -> void:
	if animated_sprite and animated_sprite.sprite_frames:
		animated_sprite.play("walk")


## Play death animation with optional callback
func play_death(on_complete: Callable = Callable()) -> void:
	if not animated_sprite or not animated_sprite.sprite_frames:
		if on_complete.is_valid():
			on_complete.call()
		return
	
	# Ensure death animation doesn't loop so it can finish
	if animated_sprite.sprite_frames.has_animation("death"):
		animated_sprite.sprite_frames.set_animation_loop("death", false)
	
	# Connect to animation finished signal if callback provided
	if on_complete.is_valid():
		if not animated_sprite.animation_finished.is_connected(_on_death_animation_finished):
			animated_sprite.animation_finished.connect(_on_death_animation_finished.bind(on_complete), CONNECT_ONE_SHOT)
	
	animated_sprite.play("death")


## Handle death animation finished
func _on_death_animation_finished(on_complete: Callable) -> void:
	if on_complete.is_valid():
		on_complete.call()


## Play spawn animation (transitions to walk when complete)
func play_spawn() -> void:
	if not animated_sprite or not animated_sprite.sprite_frames:
		return
	
	# Check if spawn animation exists, otherwise skip to walk
	if not animated_sprite.sprite_frames.has_animation("spawn"):
		play_walk()
		return
	
	# Connect to animation finished to transition to walk
	if not animated_sprite.animation_finished.is_connected(_on_spawn_animation_finished):
		animated_sprite.animation_finished.connect(_on_spawn_animation_finished, CONNECT_ONE_SHOT)
	
	animated_sprite.play("spawn")


## Handle spawn animation finished - transition to walk
func _on_spawn_animation_finished() -> void:
	play_walk()


## Set horizontal flip based on movement direction
## flip_left: true to flip horizontally (for left movement), false for right
func set_flip_h(flip_left: bool) -> void:
	if animated_sprite:
		animated_sprite.flip_h = flip_left
