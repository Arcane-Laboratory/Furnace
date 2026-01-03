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
	additional_terrain_tiles: Array[Vector2i] = []
) -> String:
	# Collect data from current game state
	var walls: Array[Vector2i] = []
	var runes: Array[Dictionary] = []
	var spawn_points: Array[Vector2i] = []
	var furnace_position: Vector2i = Vector2i(6, 0)
	var terrain_blocked: Array[Vector2i] = []
	
	# Get spawn points and furnace from current level data
	if TileManager.current_level_data:
		spawn_points = TileManager.current_level_data.spawn_points.duplicate()
		furnace_position = TileManager.current_level_data.furnace_position
		terrain_blocked = TileManager.current_level_data.terrain_blocked.duplicate()
	
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
		
		match tile.occupancy:
			TileBase.OccupancyType.WALL:
				walls.append(grid_pos)
			TileBase.OccupancyType.RUNE:
				var rune_data := _extract_rune_data(tile, grid_pos)
				if not rune_data.is_empty():
					runes.append(rune_data)
	
	# Generate the .tres file content
	return _generate_tres_content(
		level_name,
		level_number,
		starting_resources,
		spawn_points,
		furnace_position,
		terrain_blocked,
		walls,
		runes,
		hint_text
	)


## Extract rune data from a tile
static func _extract_rune_data(tile: TileBase, grid_pos: Vector2i) -> Dictionary:
	var rune_type := tile.placed_item_type
	if rune_type.is_empty():
		return {}
	
	var rune_data: Dictionary = {
		"position": grid_pos,
		"type": rune_type,
	}
	
	# Try to get direction from structure if it has one
	if tile.structure and tile.structure.has_method("get_direction_vector"):
		var dir_vector: Vector2 = tile.structure.get_direction_vector()
		rune_data["direction"] = _vector_to_direction_string(dir_vector)
	else:
		rune_data["direction"] = "south"
	
	# Get uses if applicable
	if tile.structure and "uses_remaining" in tile.structure:
		rune_data["uses"] = tile.structure.uses_remaining
	else:
		rune_data["uses"] = 0
	
	return rune_data


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
	walls: Array[Vector2i],
	runes: Array[Dictionary],
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
	
	# Preset walls
	content += "preset_walls = Array[Vector2i]([%s])\n" % _format_vector2i_array(walls)
	
	# Preset runes
	content += "preset_runes = Array[Dictionary]([%s])\n" % _format_rune_array(runes)
	
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


## Format an array of rune dictionaries for .tres output
static func _format_rune_array(runes: Array[Dictionary]) -> String:
	if runes.is_empty():
		return ""
	
	var parts: Array[String] = []
	for rune in runes:
		var pos: Vector2i = rune.get("position", Vector2i.ZERO)
		var rune_type: String = rune.get("type", "redirect")
		var direction: String = rune.get("direction", "south")
		var uses: int = rune.get("uses", 0)
		
		# Format as dictionary literal
		var dict_str := "{"
		dict_str += "\"position\": Vector2i(%d, %d), " % [pos.x, pos.y]
		dict_str += "\"type\": \"%s\", " % rune_type
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
