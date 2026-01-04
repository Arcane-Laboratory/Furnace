extends Node
## Shader Manager
## Centralized control for shader effects
## Can toggle bloom/posterization on/off and adjust shader parameters at runtime

@export var bloom_enabled: bool = true
@export var posterization_enabled: bool = false

# References to shader materials (set in editor or via code)
var bloom_material: ShaderMaterial
var posterization_material: ShaderMaterial

# Bloom parameters
@export_range(0.0, 2.0) var bloom_threshold: float = 0.8
@export_range(0.0, 5.0) var bloom_intensity: float = 1.5
@export_range(0.0, 10.0) var bloom_size: float = 2.0

# Posterization parameters
@export_range(2, 16) var posterization_color_levels: int = 8

func _ready():
	# Find bloom and posterization ColorRect nodes in the scene
	var bloom_effect = get_tree().get_first_node_in_group("bloom_effect")
	var posterization_effect = get_tree().get_first_node_in_group("posterization_effect")
	
	if bloom_effect:
		bloom_material = bloom_effect.material as ShaderMaterial
		update_bloom_parameters()
	
	if posterization_effect:
		posterization_material = posterization_effect.material as ShaderMaterial
		update_posterization_parameters()

func set_bloom_enabled(enabled: bool):
	bloom_enabled = enabled
	if bloom_material:
		var bloom_effect = get_tree().get_first_node_in_group("bloom_effect")
		if bloom_effect:
			bloom_effect.visible = enabled

func set_posterization_enabled(enabled: bool):
	posterization_enabled = enabled
	if posterization_material:
		var posterization_effect = get_tree().get_first_node_in_group("posterization_effect")
		if posterization_effect:
			posterization_effect.visible = enabled

func set_bloom_threshold(value: float):
	bloom_threshold = clamp(value, 0.0, 2.0)
	update_bloom_parameters()

func set_bloom_intensity(value: float):
	bloom_intensity = clamp(value, 0.0, 5.0)
	update_bloom_parameters()

func set_bloom_size(value: float):
	bloom_size = clamp(value, 0.0, 10.0)
	update_bloom_parameters()

func set_posterization_color_levels(value: int):
	posterization_color_levels = clamp(value, 2, 16)
	update_posterization_parameters()

func update_bloom_parameters():
	if bloom_material:
		bloom_material.set_shader_parameter("threshold", bloom_threshold)
		bloom_material.set_shader_parameter("intensity", bloom_intensity)
		bloom_material.set_shader_parameter("size", bloom_size)

func update_posterization_parameters():
	if posterization_material:
		posterization_material.set_shader_parameter("color_levels", posterization_color_levels)
