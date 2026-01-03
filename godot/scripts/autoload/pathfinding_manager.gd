extends Node
## Autoload class for A* pathfinding - finds paths from spawn points to furnace


## Find a path from start to end using A* algorithm
## Returns an array of grid positions (Vector2i) representing the path
## Returns empty array if no path exists
func find_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	if start == end:
		return [start]
	
	# Check if start and end are crossable
	if not TileManager.is_crossable(start):
		push_warning("Pathfinding: Start position is not crossable: %s" % start)
		return []
	if not TileManager.is_crossable(end):
		push_warning("Pathfinding: End position is not crossable: %s" % end)
		return []
	
	# A* algorithm
	var open_set: Array[Dictionary] = []  # Array of {pos: Vector2i, f_score: int}
	var closed_set: Dictionary = {}  # Set of visited positions
	var came_from: Dictionary = {}  # pos -> previous pos
	var g_score: Dictionary = {}  # pos -> cost from start
	var f_score: Dictionary = {}  # pos -> estimated total cost
	
	# Initialize start node
	g_score[start] = 0
	f_score[start] = _heuristic(start, end)
	open_set.append({"pos": start, "f_score": f_score[start]})
	
	# Sort open_set by f_score (priority queue simulation)
	open_set.sort_custom(func(a, b): return a.f_score < b.f_score)
	
	while not open_set.is_empty():
		# Get node with lowest f_score
		var current_dict: Dictionary = open_set.pop_front()
		var current: Vector2i = current_dict.get("pos", Vector2i.ZERO) as Vector2i
		
		# Check if we reached the goal
		if current == end:
			return _reconstruct_path(came_from, current)
		
		# Mark current as visited
		closed_set[current] = true
		
		# Check all neighbors
		for neighbor in _get_neighbors(current):
			# Skip if already visited
			if neighbor in closed_set:
				continue
			
			# Skip if not crossable
			if not TileManager.is_crossable(neighbor):
				continue
			
			# Calculate tentative g_score
			var tentative_g: int = g_score.get(current, 999999) + 1
			
			# Check if this is a better path
			if neighbor not in g_score or tentative_g < g_score[neighbor]:
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g
				f_score[neighbor] = tentative_g + _heuristic(neighbor, end)
				
				# Add to open set if not already there
				var in_open: bool = false
				for i in range(open_set.size()):
					var node_dict: Dictionary = open_set[i]
					if node_dict.get("pos", Vector2i.ZERO) as Vector2i == neighbor:
						node_dict["f_score"] = f_score[neighbor]
						open_set[i] = node_dict
						in_open = true
						break
				
				if not in_open:
					open_set.append({"pos": neighbor, "f_score": f_score[neighbor]})
				
				# Re-sort open set
				open_set.sort_custom(func(a, b): return a.f_score < b.f_score)
	
	# No path found
	return []


## Validate that a path exists from start to end
func validate_path(start: Vector2i, end: Vector2i) -> bool:
	var path := find_path(start, end)
	return not path.is_empty()


## Validate all spawn points have valid paths to furnace
func validate_all_spawn_paths(level_data: LevelData) -> bool:
	if not level_data:
		return false
	
	for spawn_pos in level_data.spawn_points:
		if not validate_path(spawn_pos, level_data.furnace_position):
			return false
	
	return true


## Get valid neighbors (4-directional movement)
func _get_neighbors(pos: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	
	# Check bounds and add valid neighbors
	var directions := [
		Vector2i(0, -1),  # Up
		Vector2i(1, 0),   # Right
		Vector2i(0, 1),   # Down
		Vector2i(-1, 0),  # Left
	]
	
	for dir in directions:
		var neighbor: Vector2i = pos + dir
		# Bounds checking is done in TileManager.is_crossable()
		neighbors.append(neighbor)
	
	return neighbors


## Heuristic function (Manhattan distance)
func _heuristic(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)


## Reconstruct path from came_from dictionary
func _reconstruct_path(came_from: Dictionary, current: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = [current]
	
	while current in came_from:
		current = came_from[current] as Vector2i
		path.insert(0, current)  # Insert at beginning
	
	return path


## Get path length (number of tiles)
func get_path_length(path: Array[Vector2i]) -> int:
	return path.size()


## Check if a position is on a given path
func is_position_on_path(pos: Vector2i, path: Array[Vector2i]) -> bool:
	return pos in path
