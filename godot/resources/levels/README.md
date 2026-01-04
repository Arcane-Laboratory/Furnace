# Level Resources

This folder contains all level definition files (`.tres`) for the game.

## Level Data Structure

Each level is defined as a `LevelData` resource with the following properties:

### Basic Properties

| Property | Type | Description |
|----------|------|-------------|
| `level_number` | int | Level identifier (0 = debug, 1+ = main game) |
| `level_name` | String | Display name for the level |
| `starting_resources` | int | Sparks available at level start |
| `difficulty` | int (0-50) | Health multiplier for enemies (exponential: 1.15^difficulty) |
| `heat_increase_interval` | float | Seconds between heat increases during active phase (0 = disabled) |
| `par_time_seconds` | float | Target completion time (for scoring) |
| `hint_text` | String | Hint shown at level start |

### Layout Properties

| Property | Type | Description |
|----------|------|-------------|
| `spawn_points` | Array[Vector2i] | Grid positions where enemies spawn |
| `furnace_position` | Vector2i | Grid position of the furnace (default: top center) |
| `terrain_blocked` | Array[Vector2i] | Impassable terrain tiles |
| `preset_items` | Array[Dictionary] | Pre-placed items (walls, runes) that cannot be edited |

### Spawn Rules

Enemy spawning is configured per spawn point using `SpawnEnemyRule` resources:

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `spawn_point_index` | int | 0 | Index into `spawn_points` array |
| `enemy_type` | EnemyType | BASIC | Enemy type (BASIC, FAST, TANK) |
| `spawn_delay` | float | 0.0 | Seconds before first spawn |
| `spawn_count` | int | 6 | Number of enemies to spawn |
| `spawn_time` | float | 60.0 | Total duration to stagger spawns |

**Spawn Interval Calculation:**
```
interval = spawn_time / (spawn_count - 1)
```

For example, with default settings (spawn_count=6, spawn_time=60):
- First enemy spawns at spawn_delay (0s)
- Subsequent enemies spawn every 12 seconds (60/5 = 12)
- Last enemy spawns at 60 seconds

**Multiple Rules Per Spawn Point:**
A spawn point can have multiple rules to spawn different enemy types:

```gdscript
# Spawn basics immediately, then fast enemies after 30 seconds
[sub_resource type="Resource" id="rule0"]
spawn_point_index = 0
enemy_type = 0  # BASIC
spawn_delay = 0.0
spawn_count = 4
spawn_time = 30.0

[sub_resource type="Resource" id="rule1"]
spawn_point_index = 0
enemy_type = 1  # FAST
spawn_delay = 30.0
spawn_count = 6
spawn_time = 60.0
```

### Preset Items Format

```gdscript
{
    "position": Vector2i(x, y),
    "type": "wall" | "redirect" | "power" | "portal" | "mud_tile" | ...,
    "direction": "north" | "south" | "east" | "west",
    "uses": int  # Remaining uses (0 = unlimited)
}
```

### Allowed Runes

| Property | Type | Description |
|----------|------|-------------|
| `allowed_runes` | Array[RuneType] | Runes available in this level (empty = all unlocked runes) |
| `unlock_all_items` | bool | Override to unlock all items regardless of defaults |

## Level Files

| File | Description |
|------|-------------|
| `level_0.tres` | Debug/test level with all items unlocked |
| `level_1.tres` - `level_12.tres` | Main game levels with increasing difficulty |

## Creating New Levels

### Using the Debug Editor

1. Enable debug mode (`GameConfig.debug_mode = true`)
2. Play any level and click the DEBUG button
3. Use "Place Spawn Point" and "Place Terrain" to edit the layout
4. Click on spawn points to configure enemy waves
5. Use "Export Level" to save changes

### Manual Creation

1. Copy an existing level file
2. Update the UID in the header
3. Modify properties as needed
4. Ensure spawn rules reference valid spawn point indices

## Enemy Types

| Type | Value | Description |
|------|-------|-------------|
| BASIC | 0 | Standard enemy |
| FAST | 1 | High speed, low health |
| TANK | 2 | Low speed, high health |

## Tips

- Spawn rules run in parallel - all rules with the same spawn_delay start together
- Higher difficulty values exponentially increase enemy health
- Heat increase interval adds dynamic difficulty during active phase
- Debug level (level_0) is good for testing new mechanics
