# Designer Guide - Editing Rune Properties

## Overview
This guide explains where and how designers can edit rune properties, costs, and unlock status using resource-based definitions.

## Editing Rune Properties

### Location: `godot/resources/buildable_items/`

Each buildable item (rune or wall) has its own resource file (`.tres`) that defines all its properties. These files are editable directly in the Godot editor's Inspector.

### Available Resource Files

- `wall_definition.tres` - Wall properties
- `redirect_rune_definition.tres` - Basic redirect rune
- `advanced_redirect_rune_definition.tres` - Advanced redirect rune
- `portal_rune_definition.tres` - Portal rune
- `reflect_rune_definition.tres` - Reflect rune
- `explosive_rune_definition.tres` - Explosive rune
- `acceleration_rune_definition.tres` - Acceleration rune

### How to Edit

#### Method 1: Edit Resource Files in Godot Editor (Recommended)
1. Open the Godot editor
2. Navigate to `godot/resources/buildable_items/` in the FileSystem dock
3. Double-click the resource file you want to edit (e.g., `advanced_redirect_rune_definition.tres`)
4. In the Inspector panel, you'll see all editable properties:
   - **Item Type**: Internal identifier (e.g., "advanced_redirect")
   - **Display Name**: Name shown in UI (e.g., "Advanced Redirect")
   - **Cost**: Resource cost to build (e.g., 15)
   - **Unlocked By Default**: Whether this item is available by default in all levels
   - **Icon Color**: Color used for the item icon in the build menu
   - **Scene Path**: Path to the scene file for this item (if applicable)
5. Make your changes
6. Save the file (Ctrl+S or File → Save)

#### Method 2: Edit Resource Files as Text
1. Open the `.tres` file in a text editor
2. Edit the property values directly
3. Save the file

### Example: Making Advanced Redirect Available by Default

To make the Advanced Redirect rune available by default in all levels:

**Method 1 (Godot Editor):**
1. Open `godot/resources/buildable_items/advanced_redirect_rune_definition.tres` in Godot
2. In the Inspector, find **Unlocked By Default**
3. Check the checkbox (set to `true`)
4. Save the file

**Method 2 (Text Editor):**
1. Open `godot/resources/buildable_items/advanced_redirect_rune_definition.tres` in a text editor
2. Find the line: `unlocked_by_default = false`
3. Change to: `unlocked_by_default = true`
4. Save the file

Now Advanced Redirect will appear in the build menu for all levels (unless a level specifically restricts it via `allowed_runes`).

### Example: Changing Rune Cost

To change the cost of the Advanced Redirect rune:

1. Open `advanced_redirect_rune_definition.tres` in Godot editor
2. Find **Cost** in the Inspector
3. Change the value (e.g., from `15` to `20`)
4. Save the file

### Resource File Structure

Each resource file follows this structure:
```
[gd_resource type="Resource" script_class="BuildableItemDefinition" ...]

[ext_resource type="Script" path="res://scripts/resources/buildable_item_definition.gd" id="1"]

[resource]
script = ExtResource("1")
item_type = "advanced_redirect"
display_name = "Advanced Redirect"
cost = 15
unlocked_by_default = false
icon_color = Color(0.9, 0.7, 0.1, 1)
scene_path = "res://scenes/entities/runes/redirect_rune.tscn"
```

## Level-Specific Rune Availability

### Location: Level Data Resources (`.tres` files)

Each level can specify which runes are available via the `allowed_runes` array in LevelData.

### How to Edit Level Data

1. Create or open a level resource file (e.g., `godot/levels/level_1.tres`)
2. In the Inspector, find the **Allowed Runes** property
3. Add rune type strings to the array (e.g., `["redirect", "wall", "portal"]`)
4. Empty array = all default unlocked runes available
5. Non-empty array = only those runes available

### Example Level Data Structure
```
Level Number: 1
Level Name: "Tutorial"
Starting Resources: 100
Allowed Runes: []  # Empty = all default unlocked runes
```

Or for a restricted level:
```
Allowed Runes: ["redirect", "wall"]  # Only these two available
```

## Creating New Buildable Items

To add a new buildable item type:

1. Create a new resource file in `godot/resources/buildable_items/` (e.g., `new_rune_definition.tres`)
2. Set the resource type to `BuildableItemDefinition` (or inherit from `buildable_item_definition.gd`)
3. Configure all properties:
   - `item_type`: Unique identifier (e.g., "new_rune")
   - `display_name`: Display name (e.g., "New Rune")
   - `cost`: Resource cost
   - `unlocked_by_default`: Default unlock status
   - `icon_color`: Icon color
   - `scene_path`: Path to scene file (if applicable)
4. Add the new definition path to `GameConfig._load_buildable_item_definitions()` in `game_config.gd`

## Summary

- **Item properties**: Edit `.tres` files in `godot/resources/buildable_items/`
- **Level-specific availability**: Edit LevelData `.tres` files (allowed_runes array)
- **Availability logic**: Item available if (unlocked_by_default OR in level's allowed_runes)
- **Benefits**: Each item is a separate resource file, making it easy to configure properties without touching code
