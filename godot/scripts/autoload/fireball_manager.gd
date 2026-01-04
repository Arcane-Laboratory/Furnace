extends Node
## Manager for fireball spawning and tracking - prevents multiple concurrent fireballs


## Reference to the current active fireball (if any)
var active_fireball: Fireball = null

## Signal emitted when fireball is destroyed
signal fireball_destroyed
signal fireball_enemy_hit(enemy: Node2D, damage: int)


func _ready() -> void:
	pass


## Check if there's an active fireball
func has_active_fireball() -> bool:
	# Clean up invalid references
	if active_fireball and not is_instance_valid(active_fireball):
		active_fireball = null
	
	# Check if we have a valid active fireball
	if active_fireball and active_fireball.is_active:
		return true
	
	# Also check the scene tree for any active fireballs (safety check)
	var fireballs := get_tree().get_nodes_in_group("fireball")
	for fireball in fireballs:
		if is_instance_valid(fireball) and fireball.has_method("is_active"):
			if fireball.is_active:
				# Update our reference if we found one
				if not active_fireball:
					active_fireball = fireball as Fireball
				return true
	
	return false


## Clear all fireballs (cleanup)
func clear_all_fireballs() -> void:
	# Clear reference
	active_fireball = null
	
	# Find and destroy all fireballs in the scene
	var fireballs := get_tree().get_nodes_in_group("fireball")
	for fireball in fireballs:
		if is_instance_valid(fireball):
			fireball.queue_free()


## Force spawn a new fireball, cleaning up any existing ones first
## Use this when you explicitly want to replace an existing fireball
func force_spawn_fireball(spawn_position: Vector2, parent_node: Node2D) -> Fireball:
	# Clean up any existing fireballs first
	if has_active_fireball():
		print("FireballManager: Force spawning - cleaning up existing fireball...")
		clear_all_fireballs()
		await get_tree().process_frame
	
	# Now spawn normally
	return await spawn_fireball(spawn_position, parent_node)


## Spawn a new fireball at the given position
## Returns the fireball if spawned, null if one already exists
## Only spawns if there are no active fireballs (does not delete existing ones)
func spawn_fireball(spawn_position: Vector2, parent_node: Node2D) -> Fireball:
	# Check if there's already an active fireball - if so, don't spawn
	if has_active_fireball():
		print("FireballManager: Active fireball already exists, skipping spawn")
		return null
	
	# Load fireball scene
	var fireball_scene := load("res://scenes/entities/fireball.tscn") as PackedScene
	if not fireball_scene:
		push_error("FireballManager: Failed to load fireball scene")
		return null
	
	# Instantiate fireball
	var fireball := fireball_scene.instantiate() as Fireball
	if not fireball:
		push_error("FireballManager: Failed to instantiate fireball")
		return null
	
	# Add to parent node
	parent_node.add_child(fireball)
	
	# Launch the fireball
	fireball.launch(spawn_position)
	
	# Store reference
	active_fireball = fireball
	
	# Connect signals
	fireball.fireball_destroyed.connect(_on_fireball_destroyed.bind(fireball))
	fireball.enemy_hit.connect(_on_fireball_enemy_hit)
	
	print("FireballManager: Fireball spawned at %s" % spawn_position)
	return fireball


## Handle fireball destroyed signal
func _on_fireball_destroyed(fireball: Fireball) -> void:
	# Clear reference if it's our tracked fireball
	if active_fireball == fireball:
		active_fireball = null
	
	# Emit signal for game scene
	fireball_destroyed.emit()


## Handle fireball enemy hit signal
func _on_fireball_enemy_hit(enemy: Node2D, damage: int) -> void:
	# Forward signal to game scene
	fireball_enemy_hit.emit(enemy, damage)
