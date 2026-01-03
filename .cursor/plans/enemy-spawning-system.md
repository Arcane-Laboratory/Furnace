# Enemy Spawning System Implementation Plan

## Overview
This document outlines the implementation of the enemy spawning system for Furnace. The system spawns enemies based on LevelData enemy_waves, assigns paths using PathfindingManager, and manages win/lose conditions.

## Files to Create

### 1. Plan Document
- `.cursor/plans/enemy-spawning-system.md` - This plan document

### 2. Scripts (in `godot/scripts/autoload/`)
- `enemy_manager.gd` - Autoload class for:
  - Enemy spawning from LevelData enemy_waves
  - Enemy lifecycle management
  - Win/lose condition tracking
  - Integration with PathfindingManager
  - Signal emission for game events

## Implementation Details

### EnemyManager Features:
- **Spawn Management**: Spawns enemies based on enemy_waves data
- **Path Assignment**: Uses PathfindingManager to assign paths from spawn to furnace
- **Enemy Tracking**: Tracks all active enemies
- **Win/Lose Conditions**: 
  - Win: All enemies defeated
  - Lose: Enemy reaches furnace
- **Signals**: 
  - `enemy_spawned(enemy: EnemyBase)`
  - `enemy_died(enemy: EnemyBase)`
  - `enemy_reached_furnace(enemy: EnemyBase)`
  - `all_enemies_defeated()`
  - `furnace_destroyed()`

### Spawning Logic:
1. Read `enemy_waves` from LevelData
2. For each wave entry:
   - Get spawn point index
   - Get spawn position from LevelData.spawn_points
   - Wait for delay
   - Instantiate enemy scene
   - Get path from PathfindingManager
   - Assign path to enemy
   - Add enemy to scene and tracking

### Enemy Wave Format:
```gdscript
{
  "enemy_type": "basic",  # Enemy type string
  "spawn_point": 0,        # Index into spawn_points array
  "delay": 0.0             # Delay before spawning (seconds)
}
```

### Integration Points:
- **LevelData**: Reads enemy_waves and spawn_points
- **PathfindingManager**: Gets paths from spawn to furnace
- **GameScene**: Adds enemies to Enemies container
- **EnemyBase**: Connects to died/reached_furnace signals
- **GameManager**: Handles win/lose state changes

## Usage Flow:

1. **Initialize**: `EnemyManager.initialize_wave(level_data: LevelData)`
2. **Start Spawning**: `EnemyManager.start_wave()`
3. **Track Enemies**: Manager tracks all spawned enemies
4. **Handle Events**: 
   - Enemy dies → check if all defeated → win
   - Enemy reaches furnace → lose

## Next Steps After Creation:
1. ✅ Register EnemyManager in project.godot autoloads
2. Integrate with game_scene (call start_wave when active phase starts)
3. Connect win/lose conditions to GameManager
4. Test with default level data
5. Add visual feedback for spawning
