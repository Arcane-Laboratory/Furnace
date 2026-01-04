extends Node
class_name VisualEffectsManager
## Manages all visual effects: vignette, bloom, heat haze, and ash particles

## References set during initialization
var ui_layer: CanvasLayer = null
var game_board: Node2D = null

## Effect nodes
var post_process_rect: ColorRect = null
var heat_haze_rect: ColorRect = null
var ash_particles: AshParticles = null

## Post-process canvas layer (renders above game, below UI)
var post_process_layer: CanvasLayer = null

## Shader materials
var post_process_material: ShaderMaterial = null
var heat_haze_material: ShaderMaterial = null

## Effect enabled states
var vignette_enabled: bool = true
var bloom_enabled: bool = true
var heat_haze_enabled: bool = true
var ash_particles_enabled: bool = true

## Default effect intensities
var vignette_intensity: float = 0.05
var bloom_intensity: float = 0.15
var heat_haze_strength: float = 0.005
var ash_intensity: float = 0.7

## Signals for effect state changes
signal effects_initialized


## Initialize all visual effects
func initialize(p_ui_layer: CanvasLayer, p_game_board: Node2D) -> void:
	ui_layer = p_ui_layer
	game_board = p_game_board
	
	# Create effects in correct z-order
	_create_ash_particles()
	_create_heat_haze()
	_create_post_process()
	
	effects_initialized.emit()
	print("VisualEffectsManager: All effects initialized")


## Create the post-processing layer with vignette and bloom
func _create_post_process() -> void:
	# Load shader
	var shader := load("res://shaders/post_process.gdshader") as Shader
	if not shader:
		push_warning("VisualEffectsManager: Failed to load post_process.gdshader")
		return
	
	# Create canvas layer that renders above game but below UI
	post_process_layer = CanvasLayer.new()
	post_process_layer.name = "PostProcessLayer"
	post_process_layer.layer = 50  # Above game (0), below UI layer which should be higher
	get_tree().root.add_child(post_process_layer)
	
	# Create fullscreen ColorRect
	post_process_rect = ColorRect.new()
	post_process_rect.name = "PostProcessRect"
	post_process_rect.anchors_preset = Control.PRESET_FULL_RECT
	post_process_rect.offset_right = GameConfig.VIEWPORT_WIDTH
	post_process_rect.offset_bottom = GameConfig.VIEWPORT_HEIGHT
	post_process_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Create and apply shader material
	post_process_material = ShaderMaterial.new()
	post_process_material.shader = shader
	post_process_material.set_shader_parameter("vignette_intensity", vignette_intensity)
	post_process_material.set_shader_parameter("vignette_softness", 0.15)  # Tight edge fade
	post_process_material.set_shader_parameter("bloom_threshold", 0.75)   # Only brightest pixels
	post_process_material.set_shader_parameter("bloom_intensity", bloom_intensity)
	post_process_material.set_shader_parameter("bloom_spread", 2.5)
	
	post_process_rect.material = post_process_material
	post_process_layer.add_child(post_process_rect)
	
	print("VisualEffectsManager: Post-process effects created")


## Create the heat haze distortion effect near furnace
func _create_heat_haze() -> void:
	# Load shader
	var shader := load("res://shaders/heat_haze.gdshader") as Shader
	if not shader:
		push_warning("VisualEffectsManager: Failed to load heat_haze.gdshader")
		return
	
	# Create canvas layer for heat haze (between game and post-process)
	var heat_haze_layer := CanvasLayer.new()
	heat_haze_layer.name = "HeatHazeLayer"
	heat_haze_layer.layer = 40  # Above game, below post-process
	get_tree().root.add_child(heat_haze_layer)
	
	# Create fullscreen ColorRect for heat haze
	heat_haze_rect = ColorRect.new()
	heat_haze_rect.name = "HeatHazeRect"
	heat_haze_rect.anchors_preset = Control.PRESET_FULL_RECT
	heat_haze_rect.offset_right = GameConfig.VIEWPORT_WIDTH
	heat_haze_rect.offset_bottom = GameConfig.VIEWPORT_HEIGHT
	heat_haze_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Create and apply shader material
	heat_haze_material = ShaderMaterial.new()
	heat_haze_material.shader = shader
	heat_haze_material.set_shader_parameter("distortion_strength", heat_haze_strength)
	heat_haze_material.set_shader_parameter("wave_speed", 1.5)
	heat_haze_material.set_shader_parameter("wave_frequency", 20.0)
	heat_haze_material.set_shader_parameter("vertical_frequency", 8.0)
	heat_haze_material.set_shader_parameter("fade_start", 0.0)
	heat_haze_material.set_shader_parameter("fade_end", 0.35)  # Effect covers top ~35% of screen
	
	heat_haze_rect.material = heat_haze_material
	heat_haze_layer.add_child(heat_haze_rect)
	
	print("VisualEffectsManager: Heat haze effect created")


## Create floating ash/ember particles
func _create_ash_particles() -> void:
	# Create ash particles node
	ash_particles = AshParticles.new()
	ash_particles.name = "AshParticles"
	
	# Position emitter at top of screen (near furnace area)
	# Furnace is at approximately y=49 in the scene, but we want particles to cover more area
	ash_particles.position = Vector2(GameConfig.VIEWPORT_WIDTH / 2.0, 80)
	
	# Configure emission area to span across the game area
	ash_particles.emission_width = GameConfig.VIEWPORT_WIDTH * 0.9
	ash_particles.emission_height = 150.0
	
	# Set z_index to be behind game elements but visible
	ash_particles.z_index = -50
	
	# Add to game board so it's part of the game world
	if game_board:
		# Add at world position instead of relative to game board
		get_tree().root.add_child(ash_particles)
	else:
		get_tree().root.add_child(ash_particles)
	
	print("VisualEffectsManager: Ash particles created")


## Toggle vignette effect
func set_vignette_enabled(enabled: bool) -> void:
	vignette_enabled = enabled
	_update_post_process()


## Toggle bloom effect
func set_bloom_enabled(enabled: bool) -> void:
	bloom_enabled = enabled
	_update_post_process()


## Toggle heat haze effect
func set_heat_haze_enabled(enabled: bool) -> void:
	heat_haze_enabled = enabled
	if heat_haze_rect:
		heat_haze_rect.visible = enabled


## Toggle ash particles
func set_ash_particles_enabled(enabled: bool) -> void:
	ash_particles_enabled = enabled
	if ash_particles:
		ash_particles.set_enabled(enabled)


## Set vignette intensity (0.0 to 1.0)
func set_vignette_intensity(intensity: float) -> void:
	vignette_intensity = clamp(intensity, 0.0, 1.0)
	if post_process_material and vignette_enabled:
		post_process_material.set_shader_parameter("vignette_intensity", vignette_intensity)


## Set bloom intensity (0.0 to 2.0)
func set_bloom_intensity(intensity: float) -> void:
	bloom_intensity = clamp(intensity, 0.0, 2.0)
	if post_process_material and bloom_enabled:
		post_process_material.set_shader_parameter("bloom_intensity", bloom_intensity)


## Set heat haze distortion strength (0.0 to 0.05)
func set_heat_haze_strength(strength: float) -> void:
	heat_haze_strength = clamp(strength, 0.0, 0.05)
	if heat_haze_material:
		heat_haze_material.set_shader_parameter("distortion_strength", heat_haze_strength)


## Set ash particle intensity (0.0 to 2.0)
func set_ash_intensity(intensity: float) -> void:
	ash_intensity = clamp(intensity, 0.0, 2.0)
	if ash_particles:
		ash_particles.set_intensity(intensity)


## Update post-process shader based on enabled states
func _update_post_process() -> void:
	if not post_process_material:
		return
	
	# Set vignette
	if vignette_enabled:
		post_process_material.set_shader_parameter("vignette_intensity", vignette_intensity)
	else:
		post_process_material.set_shader_parameter("vignette_intensity", 0.0)
	
	# Set bloom
	if bloom_enabled:
		post_process_material.set_shader_parameter("bloom_intensity", bloom_intensity)
	else:
		post_process_material.set_shader_parameter("bloom_intensity", 0.0)


## Enable all effects
func enable_all_effects() -> void:
	set_vignette_enabled(true)
	set_bloom_enabled(true)
	set_heat_haze_enabled(true)
	set_ash_particles_enabled(true)


## Disable all effects
func disable_all_effects() -> void:
	set_vignette_enabled(false)
	set_bloom_enabled(false)
	set_heat_haze_enabled(false)
	set_ash_particles_enabled(false)


## Intensify effects (e.g., during active phase)
func set_active_phase_intensity() -> void:
	set_vignette_intensity(0.07)
	set_bloom_intensity(0.2)
	set_heat_haze_strength(0.006)
	set_ash_intensity(0.9)


## Reset to normal intensity (e.g., during build phase)
func set_build_phase_intensity() -> void:
	set_vignette_intensity(0.05)
	set_bloom_intensity(0.15)
	set_heat_haze_strength(0.005)
	set_ash_intensity(0.7)


## Cleanup when scene changes
func cleanup() -> void:
	if ash_particles and is_instance_valid(ash_particles):
		ash_particles.queue_free()
	
	if heat_haze_rect and is_instance_valid(heat_haze_rect):
		var parent := heat_haze_rect.get_parent()
		if parent:
			parent.queue_free()  # Free the canvas layer too
	
	if post_process_layer and is_instance_valid(post_process_layer):
		post_process_layer.queue_free()


func _exit_tree() -> void:
	cleanup()
