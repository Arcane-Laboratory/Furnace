extends Node
## Manager for floating numbers with object pooling


## Designer-tunable properties
@export var initial_pool_size: int = 10
@export var max_pool_size: int = 50  # 0 = unlimited
@export var default_duration: float = 1.0
@export var default_move_distance: float = 50.0
@export var default_font_size: int = 8
@export var default_text_color: Color = Color.WHITE
@export var default_start_scale: float = 1.0
@export var default_end_scale: float = 1.0
@export var default_random_offset_range: float = 10.0

var _pool: Array[FloatingNumber] = []
var _active_numbers: Array[FloatingNumber] = []
var _container: Node2D
var _floating_number_scene: PackedScene


func _ready() -> void:
	# Load the floating number scene
	_floating_number_scene = preload("res://scenes/ui/floating_number.tscn")
	
	# Create container for floating numbers (will be added to current scene)
	_container = Node2D.new()
	_container.name = "FloatingNumberContainer"
	
	# Try to add container immediately if scene is ready
	call_deferred("_ensure_container_in_tree")
	call_deferred("_expand_pool", initial_pool_size)


func _ensure_container_in_tree() -> void:
	# Recreate container if it was freed (e.g., when scene changed)
	if not is_instance_valid(_container):
		_container = Node2D.new()
		_container.name = "FloatingNumberContainer"
		# Clear pool and active numbers since their nodes were freed with the old container
		_pool.clear()
		_active_numbers.clear()
	
	# Add container to the current scene tree if not already there
	if not _container.get_parent():
		var current_scene = get_tree().current_scene
		if current_scene:
			current_scene.add_child(_container)


func show_number(text: Variant, world_pos: Vector2, color_override: Color = Color.WHITE, sprite_texture: Texture2D = null, sprite_scale: float = 1.0, use_random_offset: bool = false) -> void:
	# Ensure container is in tree
	_ensure_container_in_tree()
	
	var floating_number = _get_number()
	if not floating_number:
		return
	
	# Apply default properties
	floating_number.duration = default_duration
	floating_number.move_distance = default_move_distance
	floating_number.font_size = default_font_size
	floating_number.text_color = default_text_color
	floating_number.start_scale = default_start_scale
	floating_number.end_scale = default_end_scale
	floating_number.random_offset_range = default_random_offset_range
	
	# Show the number/text
	floating_number.show_number(text, world_pos, color_override, sprite_texture, sprite_scale, use_random_offset)
	_active_numbers.append(floating_number)


func show_damage(amount: int, world_pos: Vector2) -> void:
	show_number(amount, world_pos, Color.RED)


func show_resource_gain(amount: int, world_pos: Vector2) -> void:
	show_number("+%d" % amount, world_pos, Color.GREEN)


func show_resource_loss(amount: int, world_pos: Vector2) -> void:
	show_number("-%d" % amount, world_pos, Color.ORANGE)


func _get_number() -> FloatingNumber:
	# Ensure container exists
	_ensure_container_in_tree()
	
	# Try to get from pool
	if _pool.size() > 0:
		var number = _pool.pop_back()
		return number
	
	# Create new if pool is empty and under max size
	if max_pool_size == 0 or (_pool.size() + _active_numbers.size()) < max_pool_size:
		var number = _floating_number_scene.instantiate() as FloatingNumber
		if number:
			number.set_manager(self)
			_container.add_child(number)
			return number
	
	# Pool exhausted, return null (could optionally create anyway)
	return null


func recycle_number(number: FloatingNumber) -> void:
	# Remove from active list
	var index = _active_numbers.find(number)
	if index >= 0:
		_active_numbers.remove_at(index)
	
	# Return to pool
	if max_pool_size == 0 or _pool.size() < max_pool_size:
		_pool.append(number)
	else:
		# Pool full, free the number
		number.queue_free()


func _expand_pool(count: int) -> void:
	# Ensure container is in tree before adding children
	_ensure_container_in_tree()
	
	for i in range(count):
		var number = _floating_number_scene.instantiate() as FloatingNumber
		if number:
			number.set_manager(self)
			_container.add_child(number)
			number.visible = false
			_pool.append(number)
