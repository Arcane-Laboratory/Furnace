# Archived Plans

This directory contains implementation plans that have been **completed** and are archived for reference.

## Archived Plans

### ✅ initial_scaffold.md
**Status**: Complete  
**Completed**: All Phase 0 tasks  
**Summary**: Core project structure, autoloads (SceneManager, GameManager, GameConfig), UI scenes (title_screen, main_menu, game_over, pause_menu), and game scene foundation.

### ✅ tile-system-scaffold.md
**Status**: Complete  
**Completed**: Full tile system implementation  
**Summary**: 
- TileBase class with terrain/occupancy management
- TileManager autoload for grid state tracking
- Terrain types (OPEN, ROCK) with scenes
- Spawn point markers
- Integration with LevelData

### ✅ pathfinding-implementation.md
**Status**: Complete  
**Completed**: A* pathfinding system  
**Summary**:
- PathfindingManager autoload
- A* algorithm with Manhattan distance heuristic
- Path validation for spawn points
- Integration with TileManager

### ✅ enemy-spawning-system.md
**Status**: Complete  
**Completed**: Enemy spawning and lifecycle management  
**Summary**:
- EnemyManager autoload
- EnemyBase and BasicEnemy classes
- Wave-based spawning from LevelData
- Win/lose condition tracking
- Signal system for game events

## Current Active Plans

See `../implementation-status.md` and `../systems-integration-plan.md` for ongoing work.
