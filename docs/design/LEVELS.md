# Levels - Content Design

**Version**: 1.0  
**Last Updated**: [Current Date]  
**Purpose**: Level structure, progression, and design specifications

---

## Level Structure

### Core Components
- **Grid**: Each level is a blank grid (13x8, 32x32 tiles)
- **Initial Elements**: Some walls and runes pre-placed (cannot be edited by player)
- **Player Resources**: Fixed resources per level to construct additional walls or place additional runes
- **One Level = One Wave**: Level ends when wave completes or furnace destroyed

### Level Start
- **Fireball Launch**: Fireball automatically shoots when level begins (no player input needed)
- **Direction**: Always starts downward from furnace at top of screen

### Level Components
- **Pre-set Enemy Wave**: One wave per level
- **Initial Walls**: Non-editable, pre-placed walls
- **Initial Runes**: Non-editable, pre-placed runes
- **Spawn Points**: Enemy starting locations (flexible number per level)
- **Furnace Location**: Fixed at top of screen

### Difficulty Factors
- **Mob Timings**: When enemies spawn during the wave
- **Multiple Spawn Points**: Enemies from different places (varied entry points)
- **Limited Resources**: Fixed resource budget per level
- **Limited Walls**: Constraint on wall placement (resource-limited)

---

## Level Count (MVP)

### Total Levels: 3

#### Level 1: Tutorial Level
- **Purpose**: Hands-off teaching, nearly guaranteed win
- **Teaching Focus**: 
  - Fireball kills enemies, enemies kill furnace
  - Main runes: Redirect runes and editing them
- **Difficulty**: Nearly guaranteed win (just rotate runes properly)
- **Enemies**: Basic Enemy only, minimal count
- **Resources**: Generous allocation (allows experimentation)

#### Level 2: Challenge Level
- **Purpose**: Increasing difficulty
- **Enemies**: Introduce Fast Enemy
- **Difficulty**: Moderate challenge

#### Level 3: Challenge Level
- **Purpose**: Highest difficulty
- **Enemies**: Introduce Tank Enemy (if implemented)
- **Difficulty**: Highest challenge

---

## Design Principles

### Core Principles
1. **Valid Path Required**: Must always have valid path from spawn to furnace
2. **Strategic Choices**: Give player meaningful decisions
3. **Progressive Teaching**: Introduce mechanics gradually
4. **Balanced Challenge**: Difficulty should scale appropriately
5. **Clear Goals**: Player should understand what to do

### Best Practices
- Start simple, increase complexity
- Use initial elements to guide or challenge
- Test pathfinding before finalizing level
- Balance resources vs challenge
- Ensure fireball can reach all enemies (or make it a puzzle)

---

## Level Progression

### Tutorial Level (Level 1)
- **Teaching Approach**: Hands-off, guided by level design
- **First Mechanic**: Fireball kills enemies, enemies kill furnace
- **Main Runes**: Redirect runes and editing them to point at each other
- **Success Condition**: Nearly guaranteed win (players just need to rotate runes properly)
- **Enemy Setup**: 
  - Few enemies (minimal count)
  - Basic Enemy only
  - Simple path
- **Resources**: Generous (more than enough to complete level)

### Difficulty Scaling
- **Designer-Controlled**: All difficulty factors are set by level designers per level
- **No Fixed Formulas**: Designers configure enemy counts, resources, spawn points individually
- **General Guidance**: Difficulty increases through:
  - More spawn points
  - More enemies
  - More enemy types
  - Fewer resources
  - Strategic initial elements

### Progression Path
- **Level 1 (Tutorial)**: Basic Enemy only, more resources, fewer enemies
- **Level 2**: Introduce Fast Enemy, moderate difficulty
- **Level 3**: Introduce Tank Enemy (if implemented), highest difficulty

---

## Progression Elements

### Level Progression (MVP)
- **Start**: Player begins at Level 1
- **Unlock**: Must clear level to unlock next level
- **Linear**: Levels unlock sequentially (Level 1 → Level 2 → Level 3)
- **No Level Select**: MVP has no level select menu (post-MVP feature)

### Rune Unlocks
- **Rune Availability**: Runes have `unlocked_by_default` property (designer-configurable)
- **Level-Specific**: Levels can specify `allowed_runes` (which runes are available)
- **Availability Logic**: Rune available if: (unlocked_by_default OR in level's allowed_runes)

### Post-MVP
- **Level Select Menu**: Level select menu with unlocks system
- **Additional Features**: To be defined post-MVP

---

## Level Editor Requirements

### Required Features
- **Grid Editor**: Place walls, runes, spawn points, initial elements
- **Enemy Wave Designer**: Define enemy types, counts, spawn timing
- **Pathfinding Preview**: Show enemy path before level starts
- **Resource Allocation**: Set fixed resources per level
- **Validation**: Ensure valid path exists from spawn to furnace

### Designer Tools Needed
- Place spawning tiles (enemy spawn points)
- Place initial walls/runes (non-editable)
- Define enemy wave (types, counts, timing)
- Set resource amount
- Test pathfinding

---

## Level Variety

### Design Considerations
- **Different Layouts**: Vary grid layouts across levels
- **Enemy Compositions**: Different enemy type combinations
- **Initial Elements**: Vary initial element placement and purpose
- **Resource Budgets**: Different resource allocations per level
- **Spawn Configurations**: Vary spawn point locations and timing

---

**Status**: Ready for level designers to begin creating levels.
