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
	removed_items: Array[Vector2i] = [],
	spawn_rules: Array[SpawnEnemyRule] = []
) -> String:
	# Collect data from current game state
	var items: Array[Dictionary] = []
	var spawn_points: Array[Vector2i] = []
	var furnace_position: Vector2i = Vector2i(6, 0)
	var terrain_blocked: Array[Vector2i] = []
	var rules_to_export: Array[SpawnEnemyRule] = []
	var allowed_runes: Array[int] = []
	var difficulty: int = 0
	var heat_increase_interval: float = 0.0
	var unlock_all_items: bool = false
	var par_time_seconds: float = 60.0
	
	# Get spawn points and furnace from current level data
	if TileManager.current_level_data:
		spawn_points = TileManager.current_level_data.spawn_points.duplicate()
		furnace_position = TileManager.current_level_data.furnace_position
		terrain_blocked = TileManager.current_level_data.terrain_blocked.duplicate()
		# Preserve allowed_runes and other level properties
		allowed_runes = TileManager.current_level_data.allowed_runes.duplicate()
		difficulty = TileManager.current_level_data.difficulty
		heat_increase_interval = TileManager.current_level_data.heat_increase_interval
		unlock_all_items = TileManager.current_level_data.unlock_all_items
		par_time_seconds = TileManager.current_level_data.par_time_seconds
	
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
	
	# Use provided spawn rules or get from current level data
	if spawn_rules.size() > 0:
		rules_to_export = spawn_rules
	elif TileManager.current_level_data:
		rules_to_export = TileManager.current_level_data.spawn_rules.duplicate()
	
	# If no rules exist, create default rules for each spawn point
	if rules_to_export.is_empty():
		for i in range(spawn_points.size()):
			var default_rule := SpawnEnemyRule.new()
			default_rule.spawn_point_index = i
			default_rule.enemy_type = SpawnEnemyRule.EnemyType.BASIC
			default_rule.spawn_delay = 0.0
			default_rule.spawn_count = 6
			default_rule.spawn_time = 60.0
			rules_to_export.append(default_rule)
	
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
		hint_text,
		rules_to_export,
		allowed_runes,
		difficulty,
		heat_increase_interval,
		unlock_all_items,
		par_time_seconds
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
	hint_text: String,
	spawn_rules: Array[SpawnEnemyRule],
	allowed_runes: Array[int] = [],
	difficulty: int = 0,
	heat_increase_interval: float = 0.0,
	unlock_all_items: bool = false,
	par_time_seconds: float = 60.0
) -> String:
	# Calculate load_steps based on spawn rule entries
	var num_rule_entries := spawn_rules.size()
	if num_rule_entries < 1:
		num_rule_entries = 1  # At least one default rule
	var load_steps := 2 + num_rule_entries
	
	var content := ""
	
	# Header - generate a unique UID for this resource
	var resource_uid := "uid://%s" % _generate_uid()
	content += "[gd_resource type=\"Resource\" script_class=\"LevelData\" load_steps=%d format=3 uid=\"%s\"]\n\n" % [load_steps, resource_uid]
	
	# External resources (Godot resolves UIDs from paths automatically)
	content += "[ext_resource type=\"Script\" uid=\"uid://bbkvpakf3hhjq\" path=\"res://scripts/resources/level_data.gd\" id=\"1\"]\n"
	content += "[ext_resource type=\"Script\" path=\"res://scripts/resources/spawn_enemy_rule.gd\" id=\"2\"]\n\n"
	
	# Sub-resources (spawn rules)
	for i in range(spawn_rules.size()):
		var rule := spawn_rules[i]
		content += "[sub_resource type=\"Resource\" id=\"Resource_rule%d\"]\n" % i
		content += "script = ExtResource(\"2\")\n"
		content += "spawn_point_index = %d\n" % rule.spawn_point_index
		content += "enemy_type = %d\n" % rule.enemy_type
		content += "spawn_delay = %.1f\n" % rule.spawn_delay
		content += "spawn_count = %d\n" % rule.spawn_count
		content += "spawn_time = %.1f\n\n" % rule.spawn_time
	
	# If no rules, create a default one
	if spawn_rules.is_empty():
		content += "[sub_resource type=\"Resource\" id=\"Resource_rule0\"]\n"
		content += "script = ExtResource(\"2\")\n"
		content += "spawn_point_index = 0\n"
		content += "enemy_type = 0\n"
		content += "spawn_delay = 0.0\n"
		content += "spawn_count = 6\n"
		content += "spawn_time = 60.0\n\n"
	
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
	
	# Spawn rules (typed array format)
	var rule_refs: Array[String] = []
	var rule_count := spawn_rules.size() if spawn_rules.size() > 0 else 1
	for i in range(rule_count):
		rule_refs.append("SubResource(\"Resource_rule%d\")" % i)
	content += "spawn_rules = Array[ExtResource(\"2\")]([%s])\n" % ", ".join(rule_refs)
	
	# Allowed runes (preserve from original level data)
	content += "allowed_runes = Array[int]([%s])\n" % _format_int_array(allowed_runes)
	
	# Difficulty
	content += "difficulty = %d\n" % difficulty
	
	# Heat increase interval
	content += "heat_increase_interval = %.1f\n" % heat_increase_interval
	
	# Unlock all items
	content += "unlock_all_items = %s\n" % ("true" if unlock_all_items else "false")
	
	# Hint text
	content += "hint_text = \"%s\"\n" % _escape_string(hint_text)
	
	# Par time (preserve from original level data)
	content += "par_time_seconds = %.1f\n" % par_time_seconds
	
	return content


## Format an array of Vector2i for .tres output
static func _format_vector2i_array(arr: Array[Vector2i]) -> String:
	if arr.is_empty():
		return ""
	
	var parts: Array[String] = []
	for vec in arr:
		parts.append("Vector2i(%d, %d)" % [vec.x, vec.y])
	
	return ", ".join(parts)


## Format an array of ints for .tres output
static func _format_int_array(arr: Array[int]) -> String:
	if arr.is_empty():
		return ""
	
	var parts: Array[String] = []
	for val in arr:
		parts.append("%d" % val)
	
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
