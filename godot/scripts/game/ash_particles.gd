extends GPUParticles2D
class_name AshParticles
## Floating ash/ember particles that drift upward from the furnace area

## Particle texture (uses particle-cluster.png)
@export var particle_texture: Texture2D

## Emission area dimensions
@export var emission_width: float = 500.0
@export var emission_height: float = 100.0

## Whether particles should be more concentrated near furnace
@export var concentrate_at_top: bool = true

## Base particle count
@export var base_amount: int = 50

## Speed range for upward drift
@export var min_speed: float = 10.0
@export var max_speed: float = 30.0

## Horizontal sway amount
@export var sway_amount: float = 20.0

## Particle scale range
@export var min_scale: float = 0.3
@export var max_scale: float = 0.8

## Particle lifetime
@export var particle_lifetime: float = 8.0


func _ready() -> void:
	_setup_particles()


func _setup_particles() -> void:
	# Load particle texture if not set
	if not particle_texture:
		particle_texture = load("res://assets/sprites/particle-cluster.png")
	
	# Basic particle settings
	amount = base_amount
	lifetime = particle_lifetime
	preprocess = 2.0  # Pre-warm particles so they're visible immediately
	explosiveness = 0.0  # Continuous emission
	randomness = 1.0
	local_coords = false  # World coordinates for consistent movement
	
	# Create the process material
	var material := ParticleProcessMaterial.new()
	process_material = material
	
	# Emission shape - rectangle at top of screen
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	material.emission_box_extents = Vector3(emission_width / 2.0, emission_height / 2.0, 0.0)
	
	# Direction - particles drift upward
	material.direction = Vector3(0, -1, 0)  # Negative Y is up in Godot
	material.spread = 15.0  # Slight spread angle
	
	# Velocity (speed)
	material.initial_velocity_min = min_speed
	material.initial_velocity_max = max_speed
	
	# Gravity - slight downward pull creates floating feel
	# But we want upward drift, so use negative gravity or turbulence
	material.gravity = Vector3(0, -5, 0)  # Slight upward boost
	
	# Add turbulence for organic swaying motion
	material.turbulence_enabled = true
	material.turbulence_noise_strength = sway_amount
	material.turbulence_noise_scale = 2.0
	material.turbulence_noise_speed = Vector3(0.5, 0.3, 0)
	material.turbulence_influence_min = 0.3
	material.turbulence_influence_max = 0.6
	
	# Scale
	material.scale_min = min_scale
	material.scale_max = max_scale
	
	# Scale over lifetime - fade out as particles rise
	var scale_curve := Curve.new()
	scale_curve.add_point(Vector2(0.0, 0.0))   # Start small
	scale_curve.add_point(Vector2(0.1, 1.0))   # Quickly grow
	scale_curve.add_point(Vector2(0.8, 1.0))   # Stay full size
	scale_curve.add_point(Vector2(1.0, 0.0))   # Fade out at end
	var scale_curve_texture := CurveTexture.new()
	scale_curve_texture.curve = scale_curve
	material.scale_curve = scale_curve_texture
	
	# Color/alpha over lifetime
	var color_gradient := Gradient.new()
	# Warm ember colors: orange to red with alpha fade (subtle)
	color_gradient.add_point(0.0, Color(1.0, 0.6, 0.3, 0.0))   # Fade in, orange
	color_gradient.add_point(0.15, Color(1.0, 0.5, 0.2, 0.35)) # Visible, warm orange
	color_gradient.add_point(0.5, Color(0.9, 0.4, 0.2, 0.3))   # Mid-life, slightly dimmer
	color_gradient.add_point(0.85, Color(0.7, 0.3, 0.1, 0.15)) # Fading, darker red
	color_gradient.add_point(1.0, Color(0.5, 0.2, 0.1, 0.0))   # Fade out, dark ember
	var gradient_texture := GradientTexture1D.new()
	gradient_texture.gradient = color_gradient
	material.color_ramp = gradient_texture
	
	# Rotation - slight random spin
	material.angular_velocity_min = -30.0
	material.angular_velocity_max = 30.0
	
	# Create canvas item material with texture
	var canvas_material := CanvasItemMaterial.new()
	canvas_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD  # Additive for glow effect
	self.material = canvas_material
	
	# Set the texture
	texture = particle_texture
	
	# Start emitting
	emitting = true


## Adjust particle intensity (0.0 to 1.0)
func set_intensity(intensity: float) -> void:
	amount = int(base_amount * clamp(intensity, 0.0, 2.0))
	
	# Also adjust alpha in the color ramp
	if process_material is ParticleProcessMaterial:
		var mat := process_material as ParticleProcessMaterial
		if mat.color_ramp is GradientTexture1D:
			var grad_tex := mat.color_ramp as GradientTexture1D
			if grad_tex.gradient:
				# Modulate all alpha values
				var grad := grad_tex.gradient
				for i in range(grad.get_point_count()):
					var color := grad.get_color(i)
					# Base alpha values multiplied by intensity
					var base_alphas := [0.0, 0.35, 0.3, 0.15, 0.0]
					if i < base_alphas.size():
						color.a = base_alphas[i] * intensity
						grad.set_color(i, color)


## Enable or disable particles
func set_enabled(enabled: bool) -> void:
	emitting = enabled
	visible = enabled


## Set emission area (useful for different screen sizes)
func set_emission_area(width: float, height: float) -> void:
	emission_width = width
	emission_height = height
	
	if process_material is ParticleProcessMaterial:
		var mat := process_material as ParticleProcessMaterial
		mat.emission_box_extents = Vector3(width / 2.0, height / 2.0, 0.0)
