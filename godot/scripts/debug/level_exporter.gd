extends RefCounted
class_name LevelExporter
## Utility class to export current board state to a .tres level file format


## Export the current level state to a .tres file string
static func export_current_level(
	level_name: String,
	level_number: int,
	starting_resources: int = 100,
	hint_text: String = "",
	additional_spawn_points: Array[Vector2i] = [],
	override_furnace_position: Vector2i = Vector2i(-1, -1),
	additional_terrain_tiles: Array[Vector2i] = [],
	removed_spawn_points: Array[Vector2i] = [],
	removed_terrain_tiles: Array[Vector2i] = [],
	removed_items: Array[Vector2i] = []
) -> String:
	# Collect data from current game state
	var items: Array[Dictionary] = []
	var spawn_points: Array[Vector2i] = []
	var furnace_position: Vector2i = Vector2i(6, 0)
	var terrain_blocked: Array[Vector2i] = []
	
	# Get spawn points and furnace from current level data
	if TileManager.current_level_data:
		spawn_points = TileManager.current_level_data.spawn_points.duplicate()
		furnace_position = TileManager.current_level_data.furnace_position
		terrain_blocked = TileManager.current_level_data.terrain_blocked.duplicate()
	
	# Remove items that were deleted
	for sp in removed_spawn_points:
		spawn_points.erase(sp)
	
	for terrain_pos in removed_terrain_tiles:
		terrain_blocked.erase(terrain_pos)
	
	# Add additional debug-placed spawn points
	for sp in additional_spawn_points:
		if sp not in spawn_points:
			spawn_points.append(sp)
	
	# Add additional debug-placed terrain tiles
	for terrain_pos in additional_terrain_tiles:
		if terrain_pos not in terrain_blocked:
			terrain_blocked.append(terrain_pos)
	
	# Override furnace position if specified
	if override_furnace_position != Vector2i(-1, -1):
		furnace_position = override_furnace_position
	
	# Iterate through all tiles to collect placed items
	for grid_pos in TileManager.tiles.keys():
		var tile: TileBase = TileManager.tiles[grid_pos]
		if not tile:
			continue
		
		# Skip items that were removed
		if grid_pos in removed_items:
			continue
		
		match tile.occupancy:
			TileBase.OccupancyType.WALL:
				# Use actual placed_item_type (could be "wall" or "explosive_wall")
				# Only fallback to "wall" if placed_item_type is empty
				var fallback_type := "wall" if tile.placed_item_type.is_empty() else ""
				var item_data := _extract_item_data(tile, grid_pos, fallback_type)
				items.append(item_data)
			TileBase.OccupancyType.RUNE:
				var item_data := _extract_item_data(tile, grid_pos)
				if not item_data.is_empty():
					items.append(item_data)
	
	# Generate the .tres file content
	return _generate_tres_content(
		level_name,
		level_number,
		starting_resources,
		spawn_points,
		furnace_position,
		terrain_blocked,
		items,
		hint_text
	)


## Extract item data from a tile
static func _extract_item_data(tile: TileBase, grid_pos: Vector2i, override_type: String = "") -> Dictionary:
	var item_type := override_type if not override_type.is_empty() else tile.placed_item_type
	if item_type.is_empty():
		return {}
	
	var item_data: Dictionary = {
		"position": grid_pos,
		"type": item_type,
	}
	
	# Try to get direction from structure if it has one
	if tile.structure and tile.structure.has_method("get_direction_vector"):
		var dir_vector: Vector2 = tile.structure.get_direction_vector()
		item_data["direction"] = _vector_to_direction_string(dir_vector)
	else:
		item_data["direction"] = "south"
	
	# Get uses if applicable
	if tile.structure and "uses_remaining" in tile.structure:
		item_data["uses"] = tile.structure.uses_remaining
	else:
		item_data["uses"] = 0
	
	return item_data


## Convert direction vector to string
static func _vector_to_direction_string(dir: Vector2) -> String:
	if dir == Vector2.UP:
		return "north"
	elif dir == Vector2.DOWN:
		return "south"
	elif dir == Vector2.LEFT:
		return "west"
	elif dir == Vector2.RIGHT:
		return "east"
	return "south"


## Generate the .tres file content string
static func _generate_tres_content(
	level_name: String,
	level_number: int,
	starting_resources: int,
	spawn_points: Array[Vector2i],
	furnace_position: Vector2i,
	terrain_blocked: Array[Vector2i],
	items: Array[Dictionary],
	hint_text: String
) -> String:
	# Calculate load_steps based on enemy wave entries
	# Base: 2 (level_data script + enemy_wave_entry script) + number of wave entries
	var num_wave_entries := 1  # Default to 1 basic enemy
	var load_steps := 2 + num_wave_entries
	
	var content := ""
	
	# Header - generate a unique UID for this resource
	var resource_uid := "uid://%s" % _generate_uid()
	content += "[gd_resource type=\"Resource\" script_class=\"LevelData\" load_steps=%d format=3 uid=\"%s\"]\n\n" % [load_steps, resource_uid]
	
	# External resources with UIDs (these are the actual UIDs from the project)
	content += "[ext_resource type=\"Script\" uid=\"uid://bbkvpakf3hhjq\" path=\"res://scripts/resources/level_data.gd\" id=\"1\"]\n"
	content += "[ext_resource type=\"Script\" uid=\"uid://oi70e4rojnys\" path=\"res://scripts/resources/enemy_wave_entry.gd\" id=\"2\"]\n\n"
	
	# Sub-resources (enemy waves) - create a default basic enemy wave
	content += "[sub_resource type=\"Resource\" id=\"Resource_wave1\"]\n"
	content += "script = ExtResource(\"2\")\n"
	content += "enemy_type = 0\n"
	content += "spawn_point = 0\n"
	content += "delay = 0.0\n"
	content += "metadata/_custom_type_script = \"uid://oi70e4rojnys\"\n\n"
	
	# Main resource
	content += "[resource]\n"
	content += "script = ExtResource(\"1\")\n"
	content += "level_number = %d\n" % level_number
	content += "level_name = \"%s\"\n" % _escape_string(level_name)
	content += "starting_resources = %d\n" % starting_resources
	
	# Spawn points (use typed array format like Godot generates)
	content += "spawn_points = Array[Vector2i]([%s])\n" % _format_vector2i_array(spawn_points)
	
	# Furnace position
	content += "furnace_position = Vector2i(%d, %d)\n" % [furnace_position.x, furnace_position.y]
	
	# Terrain blocked
	content += "terrain_blocked = Array[Vector2i]([%s])\n" % _format_vector2i_array(terrain_blocked)
	
	# Preset items (walls, runes, etc.)
	content += "preset_items = Array[Dictionary]([%s])\n" % _format_item_array(items)
	
	# Enemy waves (typed array format like Godot generates)
	content += "enemy_waves = Array[ExtResource(\"2\")]([SubResource(\"Resource_wave1\")])\n"
	
	# Allowed runes (empty = all available)
	content += "allowed_runes = Array[int]([])\n"
	
	# Hint text
	content += "hint_text = \"%s\"\n" % _escape_string(hint_text)
	
	# Par time
	content += "par_time_seconds = 60.0\n"
	
	return content


## Format an array of Vector2i for .tres output
static func _format_vector2i_array(arr: Array[Vector2i]) -> String:
	if arr.is_empty():
		return ""
	
	var parts: Array[String] = []
	for vec in arr:
		parts.append("Vector2i(%d, %d)" % [vec.x, vec.y])
	
	return ", ".join(parts)


## Format an array of item dictionaries for .tres output
static func _format_item_array(items: Array[Dictionary]) -> String:
	if items.is_empty():
		return ""
	
	var parts: Array[String] = []
	for item in items:
		var pos: Vector2i = item.get("position", Vector2i.ZERO)
		var item_type: String = item.get("type", "wall")
		var direction: String = item.get("direction", "south")
		var uses: int = item.get("uses", 0)
		
		# Format as dictionary literal
		var dict_str := "{"
		dict_str += "\"position\": Vector2i(%d, %d), " % [pos.x, pos.y]
		dict_str += "\"type\": \"%s\", " % item_type
		dict_str += "\"direction\": \"%s\", " % direction
		dict_str += "\"uses\": %d" % uses
		dict_str += "}"
		parts.append(dict_str)
	
	return ", ".join(parts)


## Escape special characters in strings for .tres format
static func _escape_string(s: String) -> String:
	s = s.replace("\\", "\\\\")
	s = s.replace("\"", "\\\"")
	s = s.replace("\n", "\\n")
	s = s.replace("\t", "\\t")
	return s


## Copy content to system clipboard
static func copy_to_clipboard(content: String) -> void:
	DisplayServer.clipboard_set(content)


## Generate a random UID string (similar to Godot's format)
static func _generate_uid() -> String:
	var chars := "abcdefghijklmnopqrstuvwxyz0123456789"
	var uid := ""
	for i in range(12):
		uid += chars[randi() % chars.length()]
	return uid
