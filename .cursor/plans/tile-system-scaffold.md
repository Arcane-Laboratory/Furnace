# Tile System Implementation Plan

## Overview
This document outlines the implementation plan for the tile system in Furnace. The tile system manages terrain types, occupancy states, and provides a foundation for pathfinding and building mechanics.

## Files Created

### 1. Plan Document
- `.cursor/plans/tile-system-scaffold.md` - This plan document

### 2. Scripts (in `godot/scripts/tiles/`)
- `tile_base.gd` - Base tile class with:
  - TerrainType enum (OPEN, ROCK, VOID)
  - OccupancyType enum (EMPTY, WALL, RUNE, SPAWN_POINT, FURNACE)
  - Grid position management
  - Visual update system
  - State management (buildable, crossable)
  
- `terrain_open.gd` - Extends TileBase, sets terrain to OPEN
- `terrain_rock.gd` - Extends TileBase, sets terrain to ROCK
- `tile_manager.gd` - Autoload class for:
  - Grid state tracking
  - Tile registration
  - State queries (is_buildable, is_crossable, etc.)
  - LevelData integration

### 3. Scenes (in `godot/scenes/tiles/`)
- `base_tile.tscn` - Template scene with:
  - Node2D root
  - Sprite2D (optional)
  - TerrainVisual ColorRect (32x32)
  - Overlay ColorRect (32x32) for state indicators
  
- `terrain_open.tscn` - Uses base_tile, scripted with terrain_open.gd
- `terrain_rock.tscn` - Uses base_tile, scripted with terrain_rock.gd
- `spawn_point_marker.tscn` - Visual marker for spawn points

### 4. Updated Files
- `project.godot` - Registered TileManager as autoload

## Implementation Details

### TileBase Features:
- Grid position tracking (Vector2i)
- Terrain type management (TerrainType enum)
- Occupancy tracking (OccupancyType enum)
- Visual state updates (ColorRect-based)
- Highlight system (buildable/invalid)
- State queries (is_buildable(), is_crossable())

### TileManager Features:
- Dictionary-based grid state (Vector2i -> TileBase)
- Fast lookups for terrain/occupancy
- Integration with LevelData
- Query methods for pathfinding (is_crossable, is_buildable)
- Tile registration and management

### Visual System:
- ColorRect-based placeholders (32x32 pixels)
- Color coding for different states:
  - OPEN terrain: Light brown/green
  - ROCK terrain: Dark gray
  - Buildable highlight: Yellow tint
  - Invalid highlight: Red tint
- Overlay system for highlights

## Terrain Types

### OPEN
- Buildable: Yes
- Crossable: Yes
- Color: Light brown/green (#8B7355 or similar)

### ROCK
- Buildable: No
- Crossable: No
- Color: Dark gray (#4A4A4A or similar)

### VOID (Future)
- Buildable: No
- Crossable: Yes
- Color: Black/dark purple

## Occupancy Types

### EMPTY
- No structure on tile
- Can be built on (if terrain allows)

### WALL
- Wall structure placed
- Blocks enemy movement
- Blocks building

### RUNE
- Rune placed on tile
- Does not block enemy movement
- Blocks building

### SPAWN_POINT
- Enemy spawn location
- Can coexist with structures (separate layer)
- Blocks building

### FURNACE
- Furnace location
- Fixed position
- Blocks building

## Integration Points

### LevelData Integration
- TileManager loads terrain_blocked from LevelData
- TileManager loads spawn_points from LevelData
- TileManager loads preset_walls and preset_runes from LevelData
- TileManager sets furnace_position from LevelData

### GameScene Integration
- GameScene will use TileManager for grid queries
- GameScene will register tiles with TileManager
- GameScene will use TileManager for build validation

### Pathfinding Integration
- Pathfinding will query TileManager.is_crossable()
- Pathfinding will respect terrain_blocked and walls
- Pathfinding will ignore runes (non-blocking)

## Next Steps After Creation:
1. ✅ Register TileManager in project.godot autoloads
2. Update game_scene.gd to use TileManager
3. Create spawn point marker scene
4. Test tile system with level data
5. Integrate with pathfinding system
6. Add visual sprites (replace ColorRect placeholders)
