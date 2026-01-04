extends Resource
class_name BuildableItemDefinition
## Resource definition for buildable items (runes and walls)
## Designers can create .tres files from this resource to configure each item type


@export var item_type: String = ""  # e.g., "redirect", "wall", "portal"
@export var display_name: String = ""  # e.g., "Redirect Rune"
@export var cost: int = 10
@export var unlocked_by_default: bool = false
@export var icon_color: Color = Color.WHITE
@export var scene_path: String = ""  # Path to the scene file for this item (e.g., "res://scenes/entities/runes/redirect_rune.tscn")
@export var blocks_path: bool = false  # Whether this item blocks enemy/fireball pathfinding (walls = true, runes = false)
@export var has_direction: bool = false  # Whether this item can be rotated (e.g., redirect rune)
@export var default_direction: String = "south"  # Default direction: "north", "south", "east", "west"
@export var requires_paired_placement: bool = false  # Whether this item requires a second placement (e.g., portal entrance/exit)
@export var paired_scene_path: String = ""  # Path to the paired scene (e.g., portal exit scene)
@export var max_level: int = 1  # Maximum level for this item (1 = no upgrades)
@export var upgrade_cost: int = 0  # Cost to upgrade to next level
@export_multiline var description: String = ""  # Item description for details panel
## Sprite overrides per level. Key = level number (int), Value = sprite resource path (String)
## If not specified for a level, the base sprite from the scene file is used.
## Example: {2: "res://assets/sprites/rune-advanced-redirect.png"}
@export var sprite_overrides: Dictionary = {}  # Level -> Sprite path


func _init(
	p_item_type: String = "",
	p_display_name: String = "",
	p_cost: int = 10,
	p_unlocked_by_default: bool = false,
	p_icon_color: Color = Color.WHITE,
	p_scene_path: String = "",
	p_blocks_path: bool = false,
	p_has_direction: bool = false,
	p_default_direction: String = "south",
	p_requires_paired_placement: bool = false,
	p_paired_scene_path: String = "",
	p_max_level: int = 1,
	p_upgrade_cost: int = 0,
	p_description: String = "",
	p_sprite_overrides: Dictionary = {}
) -> void:
	item_type = p_item_type
	display_name = p_display_name
	cost = p_cost
	unlocked_by_default = p_unlocked_by_default
	icon_color = p_icon_color
	scene_path = p_scene_path
	blocks_path = p_blocks_path
	has_direction = p_has_direction
	default_direction = p_default_direction
	requires_paired_placement = p_requires_paired_placement
	paired_scene_path = p_paired_scene_path
	max_level = p_max_level
	upgrade_cost = p_upgrade_cost
	description = p_description
	sprite_overrides = p_sprite_overrides


## Get the sprite path for a specific level.
## Returns empty string if no override is defined for that level (use default sprite).
func get_sprite_for_level(level: int) -> String:
	if sprite_overrides.has(level):
		return sprite_overrides[level]
	return ""
