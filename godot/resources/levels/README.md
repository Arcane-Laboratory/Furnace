# Level Resource Files

This directory contains designer-modifiable `.tres` resource files that define level layouts, enemy waves, and gameplay configurations.

## Overview

Each level is defined by a `.tres` resource file that uses the `LevelData` resource class. Designers can create and edit levels by modifying these files directly in the Godot editor or in a text editor.

## Grid Coordinate System

The game uses a **13x7 grid**:
- **X-axis**: 0 to 12 (13 columns)
- **Y-axis**: 0 to 6 (7 rows)
- **Tile Size**: 32x32 pixels

**Important Coordinates**:
- **Top row**: y = 0 (furnace typically placed here)
- **Bottom row**: y = 6 (spawn points typically placed here)
- **Center column**: x = 6 (common for furnace placement)

## File Naming Conventions

Level files should follow this naming pattern:
- `level_1.tres` - Level 1
- `level_2.tres` - Level 2
- `level_3.tres` - Level 3
- `level_N.tres` - For additional levels (where N is the level number)

The game loads levels using the pattern: `res://resources/levels/level_%d.tres` where `%d` is the level number.

**Note**: The descriptive name (e.g., "Tutorial", "Challenge", "Expert") should be set in the `level_name` property, not in the filename.

## Level Data Properties

### Basic Properties

- **level_number** (int): Unique identifier for the level (1, 2, 3, etc.)
- **level_name** (String): Display name shown to players (e.g., "Tutorial", "Challenge")
- **starting_resources** (int): Initial resource budget for the player (e.g., 100, 120, 150)
- **par_time_seconds** (float): Target completion time in seconds (optional, for scoring)
- **hint_text** (String): Optional hint shown at level start (can be empty)

### Layout Properties

- **furnace_position** (Vector2i): Grid position where the fireball launches from (typically top center: `Vector2i(6, 0)`)
- **spawn_points** (Array[Vector2i]): Enemy spawn locations (typically bottom row: `Vector2i(x, 6)`)
- **terrain_blocked** (Array[Vector2i]): Impassable terrain tiles (rocks/mountains) - cannot be built on
- **preset_walls** (Array[Vector2i]): Pre-placed walls that cannot be edited by the player
- **preset_runes** (Array[Dictionary]): Pre-placed runes that cannot be edited by the player

### Enemy Configuration

- **enemy_waves** (Array[EnemyWaveEntry]): Enemy spawn configuration using typed resource entries

**Enemy Wave Entry Properties**:
- **enemy_type** (EnemyType enum): Enemy type selection
  - `BASIC` (0) - Standard enemy
  - `FAST` (1) - Fast enemy (low health, high speed)
  - `TANK` (2) - Tank enemy (high health, low speed)
- **spawn_point** (int): Index into spawn_points array (0-based)
- **delay** (float): Delay in seconds before this enemy spawns

**In Godot Editor**: The `enemy_type` property appears as a dropdown menu with enum names (BASIC, FAST, TANK).

**In Text Files**: Enum values are stored as integers (0, 1, 2).

**Example** (as it appears in Godot editor):
- Enemy Type: BASIC, Spawn Point: 0, Delay: 0.0
- Enemy Type: FAST, Spawn Point: 0, Delay: 1.5
- Enemy Type: BASIC, Spawn Point: 1, Delay: 2.0

### Rune Availability

- **allowed_runes** (Array[RuneType]): Which runes are available in this level (uses enum values)

**Rune Type Enum Values**:
- `REDIRECT` (0) - Basic redirect rune
- `ADVANCED_REDIRECT` (1) - Advanced redirect (can change direction during active phase)
- `WALL` (2) - Wall (blocks enemy movement)
- `REFLECT` (3) - Reflect rune (bounces fireball back)
- `EXPLOSIVE` (4) - Explosive rune (area damage)
- `ACCELERATION` (5) - Acceleration rune (speeds up fireball)
- `PORTAL` (6) - Portal rune (teleports fireball)

**In Godot Editor**: The `allowed_runes` array shows dropdown menus for each element with enum names (REDIRECT, WALL, etc.).

**In Text Files**: Enum values are stored as integers (0, 1, 2, etc.). For example: `allowed_runes = [0, 2, 3]` means REDIRECT, WALL, and REFLECT.

**Note**: Empty array `[]` means all default unlocked runes are available. Non-empty array restricts to only those runes.

## Examples

### Example 1: Simple Tutorial Level

**In Godot Editor**:
- Level Number: 1
- Level Name: "Tutorial"
- Starting Resources: 100
- Spawn Points: [Vector2i(6, 6)]
- Furnace Position: Vector2i(6, 0)
- Enemy Waves: 
  - Entry 1: Enemy Type = BASIC, Spawn Point = 0, Delay = 0.0
  - Entry 2: Enemy Type = BASIC, Spawn Point = 0, Delay = 2.0
  - Entry 3: Enemy Type = BASIC, Spawn Point = 0, Delay = 4.0
- Allowed Runes: [REDIRECT, WALL]
- Hint Text: "Welcome! Place redirect runes to guide the fireball."

**Note**: In the Godot editor, you'll see dropdown menus for enum values. When editing `.tres` files as text, enum values appear as integers.

### Example 2: Multi-Spawn Challenge Level

**In Godot Editor**:
- Level Number: 2
- Level Name: "Challenge"
- Starting Resources: 120
- Spawn Points: [Vector2i(3, 6), Vector2i(9, 6)]
- Furnace Position: Vector2i(6, 0)
- Enemy Waves:
  - Entry 1: Enemy Type = BASIC, Spawn Point = 0, Delay = 0.0
  - Entry 2: Enemy Type = FAST, Spawn Point = 0, Delay = 1.5
  - Entry 3: Enemy Type = BASIC, Spawn Point = 1, Delay = 2.0
  - Entry 4: Enemy Type = FAST, Spawn Point = 1, Delay = 3.5
- Allowed Runes: [REDIRECT, WALL, REFLECT]
- Hint Text: "Fast enemies move quickly! Use reflect runes."

### Example 3: Level with Preset Elements

**In Godot Editor**:
- Level Number: 3
- Level Name: "Expert"
- Starting Resources: 150
- Spawn Points: [Vector2i(2, 6), Vector2i(6, 6), Vector2i(10, 6)]
- Furnace Position: Vector2i(6, 0)
- Terrain Blocked: [Vector2i(3, 3), Vector2i(9, 3)]
- Preset Walls: [Vector2i(6, 2)]
- Preset Runes: [Dictionary with position, type (RuneType enum), direction, uses]
- Enemy Waves:
  - Entry 1: Enemy Type = TANK, Spawn Point = 0, Delay = 0.0
  - Entry 2: Enemy Type = FAST, Spawn Point = 1, Delay = 1.0
  - Entry 3: Enemy Type = TANK, Spawn Point = 2, Delay = 2.0
- Allowed Runes: [REDIRECT, WALL, REFLECT, EXPLOSIVE]

## Preset Runes Format

Preset runes use a dictionary format:

```gdscript
{
    "position": Vector2i(x, y),    # Grid position
    "type": "redirect",            # Rune type string
    "direction": "south",          # Direction: "north", "south", "east", "west"
    "uses": 0                      # Number of uses (0 = infinite)
}
```

**Direction Values**:
- `"north"` - Up (negative Y)
- `"south"` - Down (positive Y)
- `"east"` - Right (positive X)
- `"west"` - Left (negative X)

## Enemy Types (EnemyType Enum)

- **BASIC** (0): Standard enemy with balanced health and speed
- **FAST** (1): Low health, high speed - moves quickly
- **TANK** (2): High health, low speed - hard to kill but slow

**Note**: When editing in the Godot editor, you'll see these as dropdown options. In text files, they're stored as integers.

## Best Practices for Level Design

1. **Spawn Points**: Place spawn points at the bottom row (y = 6) for enemies to walk upward
2. **Furnace**: Typically place at top center (6, 0) for balanced gameplay
3. **Enemy Waves**: 
   - Start with basic enemies in tutorial levels
   - Introduce fast enemies gradually
   - Use tank enemies sparingly (they're tough!)
   - Space out spawn delays to create pacing
4. **Resources**: Balance starting resources with level difficulty
   - Tutorial: 100 resources
   - Challenge: 120-150 resources
   - Expert: 150+ resources
5. **Rune Restrictions**: 
   - Tutorial levels should limit runes to teach basics
   - Expert levels can allow all runes
   - Empty array `[]` = all default unlocked runes
6. **Hints**: Provide helpful hints for new mechanics or enemy types
7. **Par Time**: Set reasonable par times based on enemy count and difficulty

## Editing Levels

### Method 1: Godot Editor (Recommended)

1. Open the `.tres` file in Godot
2. Use the Inspector to modify properties
3. **Enum Properties**: Enemy types and rune types appear as dropdown menus - simply select from the list
4. For arrays (spawn_points, enemy_waves, etc.), use the array editor
5. **Enemy Waves**: Click the array to expand, then add/edit EnemyWaveEntry resources. Each entry has:
   - Enemy Type dropdown (BASIC, FAST, TANK)
   - Spawn Point (integer index)
   - Delay (float)
6. **Allowed Runes**: Add elements to the array, each showing a dropdown with rune type options
7. Save the file

### Method 2: Text Editor

1. Open the `.tres` file in a text editor
2. Edit the property values directly
3. **Enum Values**: Remember that enums are stored as integers:
   - EnemyType: 0=BASIC, 1=FAST, 2=TANK
   - RuneType: 0=REDIRECT, 1=ADVANCED_REDIRECT, 2=WALL, 3=REFLECT, 4=EXPLOSIVE, 5=ACCELERATION, 6=PORTAL
4. **Enemy Waves**: Each wave entry is a SubResource with `enemy_type = 0` (or 1, 2), `spawn_point = 0`, `delay = 0.0`
5. **Allowed Runes**: Array of integers, e.g., `allowed_runes = [0, 2, 3]` for REDIRECT, WALL, REFLECT
6. Save the file
7. Reload in Godot to verify

**Note**: When editing arrays in text format, be careful with syntax. Arrays use `[item1, item2, ...]` format. Enum values are integers in text files but appear as names in the Godot editor.

## Validation

Level files are automatically validated when loaded. A level must have:
- At least one spawn point
- At least one enemy in enemy_waves
- Furnace position within grid bounds (x: 0-12)

Invalid levels will show warnings in the console.

## Integration

Levels are loaded by `game_scene.gd` using:
```gdscript
var level_path := "res://resources/levels/level_%d.tres" % level_number
```

If a level file doesn't exist, the game falls back to creating default level data.

## See Also

- `godot/scripts/resources/level_data.gd` - LevelData resource class definition
- `godot/scripts/game/game_scene.gd` - Level loading logic
- `godot/resources/enemies/README.md` - Enemy definition documentation
