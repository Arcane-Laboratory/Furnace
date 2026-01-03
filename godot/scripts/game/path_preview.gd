extends Node2D
## Path preview visualization - draws enemy paths from spawn points to furnace


## Path data: Dictionary mapping spawn_point_index -> Array[Vector2i] path
var paths: Dictionary = {}

## Whether preview is visible (uses built-in visible property)

## Visual properties
var line_color: Color = Color(1.0, 0.8, 0.0, 0.6)  # Orange-yellow, semi-transparent
var line_width: float = 2.0
var arrow_size: float = 8.0
var dot_spacing: float = 4.0  # Spacing between dots for dotted line effect

## Reference to level data
var current_level_data: LevelData = null


func _ready() -> void:
	# Set up drawing layer
	z_index = 10  # Draw above tiles but below UI


func _draw() -> void:
	if not visible or paths.is_empty():
		return
	
	# Draw each path
	for spawn_index in paths:
		var path: Array = paths[spawn_index]
		if path.is_empty():
			continue
		
		_draw_path(path)


## Draw a single path with dotted line and arrows
func _draw_path(path: Array[Vector2i]) -> void:
	if path.size() < 2:
		return
	
	# Convert grid positions to world positions
	var world_points: Array[Vector2] = []
	for grid_pos in path:
		var world_pos := _grid_to_world(grid_pos)
		world_points.append(world_pos)
	
	# Draw dotted line
	_draw_dotted_line(world_points)
	
	# Draw arrows at path segments
	_draw_path_arrows(world_points)


## Draw a dotted line connecting points
func _draw_dotted_line(points: Array[Vector2]) -> void:
	for i in range(points.size() - 1):
		var start: Vector2 = points[i]
		var end: Vector2 = points[i + 1]
		var direction: Vector2 = (end - start).normalized()
		var distance: float = start.distance_to(end)
		var current_pos: Vector2 = start
		
		# Draw dots along the line
		while current_pos.distance_to(start) < distance:
			var next_pos: Vector2 = current_pos + direction * dot_spacing
			if next_pos.distance_to(start) > distance:
				next_pos = end
			
			# Draw a small circle (dot)
			draw_circle(current_pos, line_width / 2.0, line_color)
			
			current_pos = next_pos


## Draw arrows at path segments
func _draw_path_arrows(points: Array[Vector2]) -> void:
	# Draw arrows at regular intervals (every 3-4 segments)
	var arrow_interval: int = 3
	
	for i in range(0, points.size() - 1, arrow_interval):
		var start: Vector2 = points[i]
		var end: Vector2 = points[i + 1]
		var direction: Vector2 = (end - start).normalized()
		
		# Draw arrow at midpoint of segment
		var arrow_pos: Vector2 = start + (end - start) * 0.5
		_draw_arrow(arrow_pos, direction)


## Draw an arrow pointing in a direction
func _draw_arrow(pos: Vector2, direction: Vector2) -> void:
	# Arrow points in the direction of movement
	var _angle: float = direction.angle()
	
	# Arrow shape: triangle pointing forward
	var arrow_points: PackedVector2Array = PackedVector2Array()
	var tip: Vector2 = pos + direction * arrow_size
	var left: Vector2 = pos + Vector2(-direction.y, direction.x) * arrow_size * 0.5
	var right: Vector2 = pos + Vector2(direction.y, -direction.x) * arrow_size * 0.5
	
	arrow_points.append(tip)
	arrow_points.append(left)
	arrow_points.append(right)
	
	# Draw filled arrow
	draw_colored_polygon(arrow_points, line_color)


## Update paths from spawn points to furnace
func update_paths(level_data: LevelData) -> void:
	current_level_data = level_data
	paths.clear()
	
	if not level_data:
		queue_redraw()
		return
	
	var furnace_pos: Vector2i = level_data.furnace_position
	
	# Calculate path for each spawn point
	for i in range(level_data.spawn_points.size()):
		var spawn_pos: Vector2i = level_data.spawn_points[i]
		var path: Array[Vector2i] = PathfindingManager.find_path(spawn_pos, furnace_pos)
		
		if not path.is_empty():
			paths[i] = path
	
	queue_redraw()


## Clear all paths
func clear_paths() -> void:
	paths.clear()
	queue_redraw()


## Show/hide preview
func set_preview_visible(should_visible: bool) -> void:
	visible = should_visible
	queue_redraw()


## Convert grid position to world position
## Note: PathPreview is a child of GameBoard, so coordinates are relative to GameBoard
func _grid_to_world(grid_pos: Vector2i) -> Vector2:
	# Grid coordinates are already relative to GameBoard (which is at position (40, 96))
	var world_x: float = grid_pos.x * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0
	var world_y: float = grid_pos.y * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2.0
	return Vector2(world_x, world_y)
