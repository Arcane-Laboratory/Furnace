# Enemy Definitions

This directory contains designer-modifiable `.tres` resource files that define enemy types and their properties.

## Structure

Each enemy type has a corresponding `.tres` file:
- `basic_enemy_definition.tres` - Basic Enemy (baseline enemy type)
- `fast_enemy_definition.tres` - Fast Enemy (low health, high speed)
- `tank_enemy_definition.tres` - Tank Enemy (high health, low speed)

## Properties

Each enemy definition contains:
- **enemy_type**: String identifier (e.g., "basic", "fast", "tank")
- **display_name**: Human-readable name (e.g., "Basic Enemy")
- **health**: Health points (int)
- **speed**: Movement speed in pixels per second (float)
- **scene_path**: Path to the enemy scene file
- **color**: Visual color for this enemy type (Color)
- **introduction_level**: Which level this enemy type is first introduced (int)

## Usage

Enemy definitions are automatically loaded by `GameConfig` on game start. The `EnemyManager` uses these definitions when spawning enemies, setting their health and speed from the definition files.

## Editing

Designers can modify enemy stats by editing the `.tres` files in the Godot editor:
1. Open the `.tres` file in Godot
2. Modify the exported properties
3. Save the file

Changes take effect immediately on next game run (no code changes needed).

## Backward Compatibility

The system maintains backward compatibility with `GameConfig` hardcoded values. If a definition is missing or fails to load, the system falls back to the old `GameConfig` values.
