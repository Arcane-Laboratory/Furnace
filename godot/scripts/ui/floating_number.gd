extends Node2D
class_name FloatingNumber
## Individual floating number node that animates upward while fading out


## Designer-tunable properties
@export var duration: float = 1.0
@export var move_distance: float = 50.0
@export var font_size: int = 8
@export var text_color: Color = Color.WHITE
@export var start_scale: float = 1.0
@export var end_scale: float = 1.0
@export var easing_type: Tween.EaseType = Tween.EASE_OUT
@export var transition_type: Tween.TransitionType = Tween.TRANS_CUBIC
@export var random_offset_range: float = 10.0  # Maximum random offset distance

var _label: Label
var _sprite: Sprite2D
var _tween: Tween
var _start_position: Vector2
var _manager: Node  # FloatingNumberManager (autoload singleton)
var _game_font: FontFile


func _ready() -> void:
	# Load game font
	_game_font = load("res://theme/Tiny5-Regular.ttf") as FontFile
	
	# Create label dynamically
	_label = Label.new()
	if _game_font:
		_label.add_theme_font_override("font", _game_font)
	_label.add_theme_font_size_override("font_size", font_size)
	_label.modulate = text_color
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(_label)
	
	# Create sprite for optional icon (initially hidden)
	_sprite = Sprite2D.new()
	_sprite.visible = false
	add_child(_sprite)
	
	# Initially hidden
	visible = false


func show_number(text: Variant, world_pos: Vector2, color_override: Color = Color.WHITE, sprite_texture: Texture2D = null, sprite_scale: float = 1.0, use_random_offset: bool = false) -> void:
	# Set text (supports both numbers and text)
	_label.text = str(text)
	_label.modulate = color_override
	
	# Update sprite if provided
	if sprite_texture:
		_sprite.texture = sprite_texture
		_sprite.scale = Vector2(sprite_scale, sprite_scale)
		_sprite.visible = true
		
		# Calculate label size - estimate based on text length and font
		# Label needs explicit size calculation since it's in a Node2D
		var text_str = str(text)
		var estimated_label_width = text_str.length() * font_size * 0.6
		var estimated_label_height = font_size * 1.2
		var label_size = Vector2(estimated_label_width, estimated_label_height)
		
		# Try to get actual size if available
		var actual_size = _label.get_combined_minimum_size()
		if actual_size.x > 0:
			label_size.x = actual_size.x
		if actual_size.y > 0:
			label_size.y = actual_size.y
		
		var sprite_width = _sprite.texture.get_width() * sprite_scale
		var total_width = label_size.x + sprite_width + 4  # 4px spacing between text and sprite
		
		# Position label and sprite relative to center, vertically aligned
		# Label's pivot is at top-left, sprite's pivot is at center
		# To center both vertically: offset label by half its height, sprite stays at y=0
		var label_x = -total_width / 2.0
		var label_y = -label_size.y / 2.0  # Offset to center label vertically
		var sprite_x = -total_width / 2.0 + label_size.x + 4
		var sprite_y = 0.0  # Sprite is centered by default
		
		_label.position = Vector2(label_x, label_y)
		_sprite.position = Vector2(sprite_x, sprite_y)
	else:
		_sprite.visible = false
		_label.position = Vector2.ZERO
	
	# Apply random offset if enabled
	var final_position = world_pos
	if use_random_offset:
		var random_offset = Vector2(
			randf_range(-random_offset_range, random_offset_range),
			randf_range(-random_offset_range, random_offset_range)
		)
		final_position = world_pos + random_offset
	
	# Set position
	global_position = final_position
	_start_position = final_position
	
	# Reset state
	scale = Vector2(start_scale, start_scale)
	modulate.a = 1.0
	visible = true
	
	# Start animation
	_start_animation()


func _start_animation() -> void:
	# Stop any existing tween
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_parallel(true)
	
	# Animate position upward
	var end_position = _start_position + Vector2(0, -move_distance)
	_tween.tween_property(self, "global_position", end_position, duration)
	
	# Animate scale
	_tween.tween_property(self, "scale", Vector2(end_scale, end_scale), duration).set_ease(easing_type).set_trans(transition_type)
	
	# Animate alpha fade
	_tween.tween_property(self, "modulate:a", 0.0, duration)
	
	# Callback when finished
	_tween.finished.connect(_on_animation_finished)


func _stop_animation() -> void:
	if _tween:
		_tween.kill()
		_tween = null
	
	visible = false
	scale = Vector2(start_scale, start_scale)
	modulate.a = 1.0
	_sprite.visible = false
	_label.position = Vector2.ZERO
	_sprite.position = Vector2.ZERO


func _on_animation_finished() -> void:
	_stop_animation()
	
	# Recycle through manager if available
	if _manager:
		_manager.recycle_number(self)
	else:
		# Fallback: queue free if no manager
		queue_free()


func set_manager(manager: Node) -> void:
	_manager = manager
