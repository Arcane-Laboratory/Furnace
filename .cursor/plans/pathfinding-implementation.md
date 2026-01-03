# Pathfinding System Implementation Plan

## Overview
This document outlines the implementation of the A* pathfinding system for Furnace. The pathfinding system enables enemies to navigate from spawn points to the furnace, and provides path validation for the build phase.

## Files to Create

### 1. Plan Document
- `.cursor/plans/pathfinding-implementation.md` - This plan document

### 2. Scripts (in `godot/scripts/autoload/`)
- `pathfinding_manager.gd` - Autoload class for:
  - A* pathfinding algorithm
  - Path queries (find_path, validate_path)
  - Integration with TileManager
  - Path caching (optional optimization)

## Implementation Details

### PathfindingManager Features:
- A* pathfinding algorithm implementation
- Integration with TileManager.is_crossable()
- Path queries: `find_path(start, end)` -> Array[Vector2i]
- Path validation: `validate_path(start, end)` -> bool
- Support for multiple spawn points
- Grid-based navigation (4-directional movement)

### A* Algorithm:
- Uses TileManager to check if tiles are crossable
- Heuristic: Manhattan distance
- Movement: 4-directional (up, down, left, right)
- Returns path as array of grid positions
- Returns empty array if no path exists

### Integration Points:
- **TileManager**: Uses `is_crossable()` to check valid movement
- **LevelData**: Uses spawn_points and furnace_position
- **Enemy System**: Enemies will use paths from PathfindingManager
- **Build Phase**: Validates paths before allowing level start

## Algorithm Details

### A* Implementation:
```gdscript
# Pseudocode
func find_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
    open_set = PriorityQueue()
    closed_set = Set()
    came_from = Dictionary()
    g_score = Dictionary()  # Cost from start
    f_score = Dictionary()   # Estimated total cost
    
    open_set.add(start, heuristic(start, end))
    g_score[start] = 0
    f_score[start] = heuristic(start, end)
    
    while not open_set.is_empty():
        current = open_set.pop()
        
        if current == end:
            return reconstruct_path(came_from, current)
        
        closed_set.add(current)
        
        for neighbor in get_neighbors(current):
            if neighbor in closed_set:
                continue
            if not TileManager.is_crossable(neighbor):
                continue
            
            tentative_g = g_score[current] + 1
            
            if neighbor not in g_score or tentative_g < g_score[neighbor]:
                came_from[neighbor] = current
                g_score[neighbor] = tentative_g
                f_score[neighbor] = tentative_g + heuristic(neighbor, end)
                open_set.add(neighbor, f_score[neighbor])
    
    return []  # No path found
```

### Helper Functions:
- `heuristic(a: Vector2i, b: Vector2i) -> int` - Manhattan distance
- `get_neighbors(pos: Vector2i) -> Array[Vector2i]` - Get 4 adjacent tiles
- `reconstruct_path(came_from: Dictionary, current: Vector2i) -> Array[Vector2i]` - Build path from end to start

## Usage Examples

### Find Path from Spawn to Furnace:
```gdscript
var path = PathfindingManager.find_path(spawn_pos, furnace_pos)
if path.is_empty():
    print("No valid path!")
else:
    print("Path found: ", path)
```

### Validate All Spawn Points:
```gdscript
func validate_all_paths(level_data: LevelData) -> bool:
    for spawn_pos in level_data.spawn_points:
        var path = PathfindingManager.find_path(spawn_pos, level_data.furnace_position)
        if path.is_empty():
            return false
    return true
```

## Next Steps After Creation:
1. ✅ Register PathfindingManager in project.godot autoloads
2. Test pathfinding with default level data
3. Integrate with enemy system (when implemented)
4. Add path validation to build phase
5. Add path visualization (future feature)
