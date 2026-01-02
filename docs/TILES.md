# Tiles - Content Design

**Version**: 1.0  
**Last Updated**: [Current Date]  
**Purpose**: Tile system, terrain types, and placement rules

---

## Grid System

### Grid Specifications
- **Grid Size**: 13 columns x 8 rows
- **Tile Size**: 32x32 pixels
- **Total Playable Area**: 416 x 256 pixels (within 640x360 window)
- **Placement**: Grid-based placement (all structures align to grid)

---

## Tile Occupancy Rules

### Single Element Per Tile
- **Rule**: Each tile can contain **only one** of the following:
  - A rune, OR
  - A wall, OR
  - An enemy spawn point
- **No Overlap**: Never more than one element per tile
- **Cannot Overlap**: Structures cannot overlap

### Tile Contents
- **Runes**: Can be placed on tiles (various rune types)
- **Walls**: Can be placed on tiles (blocks enemy movement)
- **Spawn Points**: Enemy starting locations (spawning tiles)
- **Terrain**: Base terrain type (Rock/Mountain, Open Terrain)

---

## Terrain Types

### Open Terrain
- **Buildable**: Yes - players can build walls and runes on open terrain
- **Crossable**: Yes - enemies can cross open terrain
- **Purpose**: Standard buildable terrain for player structures
- **Visual**: Standard terrain tile

### Rock/Mountain
- **Buildable**: No - players cannot build walls or runes on rock/mountain
- **Crossable**: No - enemies cannot cross rock/mountain (blocks pathfinding)
- **Purpose**: Unbuildable terrain that blocks both building and enemy movement
- **Visual**: Rock/mountain terrain tile

### Spawn Point (Spawning Tile)
- **Function**: Enemy starting location
- **Placement**: Designers can place multiple spawn points per level
- **Spawning**: Enemies spawn staggered from these tiles
- **Flexible Number**: Flexible number of spawn points per level
- **Visual**: Spawn point indicator/marker

### Void Hole (Post-MVP)
- **Status**: Post-MVP feature (not in MVP scope)
- **Buildable**: No - players cannot build walls or runes on void holes
- **Crossable**: Yes - enemies can pass through void holes
- **Purpose**: Level design variety, strategic constraints
- **Visual**: Void hole terrain tile

---

## Placement Rules

### Valid Placement Rules
- **Cannot Block Path Completely**: 
  - Walls can block enemy path (that's their purpose)
  - Runes cannot block enemy path (enemies can pass through)
- **Cannot Place on Unbuildable Terrain**: 
  - Cannot place on Rock/Mountain
  - Cannot place on Void Holes (post-MVP)
- **Must Have Valid Path**: Must have valid path from spawn to furnace
- **Grid Alignment**: All structures must align to grid

### Placement Validation
- **Path Validation**: System validates that valid path exists before allowing placement
- **Resource Check**: System checks if player has enough resources before allowing placement
- **Terrain Check**: System checks if terrain is buildable before allowing placement
- **Occupancy Check**: System checks if tile is already occupied before allowing placement

---

## Tile Types Summary

### Buildable Tiles
- **Open Terrain**: Can place walls and runes
- **Spawn Points**: Can place walls and runes (spawn point is separate layer)

### Unbuildable Tiles
- **Rock/Mountain**: Cannot place walls or runes, blocks enemy movement
- **Void Holes** (Post-MVP): Cannot place walls or runes, enemies can pass through

### Special Tiles
- **Spawn Points**: Enemy starting locations (can coexist with structures)
- **Furnace Location**: Fixed at top of screen (not a tile, but a location)

---

## Visual Design

### Visual Elements Needed
- Open Terrain tile sprite
- Rock/Mountain tile sprite
- Spawn Point indicator/marker
- Void Hole tile sprite (post-MVP)
- Grid overlay (for placement visualization)

### Visual Feedback
- **Buildable Indicator**: Visual feedback showing buildable tiles
- **Occupied Indicator**: Visual feedback showing occupied tiles
- **Invalid Placement**: Visual feedback showing invalid placement locations
- **Path Preview**: Visual preview of enemy path (dotted line arrow overlay)

---

## Implementation Notes

### Grid System
- **TileMap**: Use Godot's TileMap or custom grid system
- **Tile Coordinates**: Track tile occupancy using grid coordinates
- **Tile Center**: Fireball activation checks tile center (grid-aligned collision)

### Tile Occupancy Tracking
- **Data Structure**: Track which tiles contain which elements
- **Validation**: Check occupancy before allowing placement
- **Updates**: Update occupancy when structures are placed/removed

### Pathfinding Integration
- **Terrain Blocking**: Rock/Mountain blocks pathfinding
- **Wall Blocking**: Walls block pathfinding
- **Rune Non-Blocking**: Runes do not block pathfinding
- **Path Calculation**: Calculate path from spawn points to furnace

---

## Level Editor Integration

### Tile Placement Tools
- **Terrain Placement**: Place terrain types (Open, Rock/Mountain)
- **Spawn Point Placement**: Place spawn points (spawning tiles)
- **Structure Placement**: Place walls and runes (validates placement rules)
- **Grid Visualization**: Show grid overlay for placement

### Validation Tools
- **Path Validation**: Validate path exists from spawn to furnace
- **Occupancy Check**: Check tile occupancy before placement
- **Terrain Check**: Check terrain type before placement

---

**Status**: Ready for implementation. Tile system and terrain types defined.
