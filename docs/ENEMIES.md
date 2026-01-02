# Enemies - Content Design

**Version**: 1.0  
**Last Updated**: [Current Date]  
**Purpose**: Enemy types, behavior, and wave system specifications

---

## Enemy Types (MVP)

### Total Types: 2-3

#### Basic Enemy
- **Role**: Baseline enemy type
- **Health**: Standard health (developer tunable)
- **Speed**: Standard speed (developer tunable)
- **Visual**: Unique appearance/color
- **Purpose**: Standard enemy, introduced in Level 1

#### Fast Enemy
- **Role**: Speed-focused enemy
- **Health**: Lower health than Basic Enemy (developer tunable)
- **Speed**: Higher speed than Basic Enemy (developer tunable)
- **Visual**: Unique appearance/color (distinct from Basic)
- **Purpose**: Introduced in Level 2, increases difficulty through speed

#### Tank Enemy (Optional)
- **Role**: Health-focused enemy
- **Health**: Higher health than Basic Enemy (developer tunable)
- **Speed**: Lower speed than Basic Enemy (developer tunable)
- **Visual**: Unique appearance/color (distinct from Basic and Fast)
- **Purpose**: Introduced in Level 3 (if implemented), increases difficulty through durability
- **Status**: Optional third type for MVP

---

## Enemy Behavior

### Pathfinding
- **Route**: Follow predetermined route to furnace
- **Method**: Grid-based pathfinding (A* or similar)
- **Blocking**: Walls block pathfinding, runes do not
- **Validation**: Path must exist from spawn to furnace

### Spawning
- **Method**: Staggered spawning (not all at once)
- **Spawn Points**: Flexible number of spawn points per level
- **Spawn Tiles**: Spawn points defined as spawning tiles on grid
- **Designer Control**: Level designers can place multiple spawn points
- **Timing**: Spawn timing/delays are developer tunable per level

### Attack
- **Contact**: Destroy furnace on contact
- **Damage**: One touch = game over (furnace has 1 HP)
- **No Attack Animation**: Instant destruction on contact

### Special Abilities
- **MVP**: None (no special abilities for MVP)
- **Post-MVP**: Enemy power ups may be added

---

## Wave System

### Level Structure
- **One Level = One Wave**: Each level contains exactly one wave
- **Wave End**: Level completes when:
  - All enemies defeated (victory)
  - Furnace destroyed (defeat)

### Enemy Wave Design
- **Level Interface**: Level editor/interface for designers to create enemy waves
- **Designer Control**: Designers define:
  - Enemy types (which types spawn)
  - Enemy counts (how many of each type)
  - Spawn timing (when enemies spawn)
  - Spawn points (where enemies spawn)

### Difficulty Progression (by Level Design)
- **More Spawn Points**: Increased spawn locations
- **More Enemies**: Higher enemy counts per level
- **More Enemy Types**: Introduce new types in later levels
- **Post-MVP**: Enemy power ups

### Developer Tunable Parameters
- **Enemy Count**: Per level (varies by difficulty)
- **Spawn Timing**: Spawn delays/timing per level
- **Spawn Point Locations**: Per level (designer-placed)
- **Health Values**: Per enemy type
- **Movement Speed**: Per enemy type

---

## Enemy Introduction Progression

### Level 1 (Tutorial)
- **Enemy Type**: Basic Enemy only
- **Count**: Minimal (just enough to demonstrate mechanics)
- **Purpose**: Focus on mechanics, not challenge

### Level 2 (Challenge)
- **Enemy Type**: Basic Enemy + Fast Enemy
- **Count**: Moderate (increased from Level 1)
- **Purpose**: Introduce speed challenge

### Level 3 (Challenge)
- **Enemy Type**: Basic Enemy + Fast Enemy + Tank Enemy (if implemented)
- **Count**: High (highest count)
- **Purpose**: Maximum difficulty with all enemy types

---

## Visual Design

### Visual Distinction
- **Unique Appearance**: Each enemy type has unique appearance
- **Color Coding**: Each type has distinct color scheme
- **Visual Clarity**: Players should easily distinguish enemy types
- **Art Style**: Pixel art (matches game's 640x360 resolution)

### Visual Elements Needed
- Basic Enemy sprite
- Fast Enemy sprite
- Tank Enemy sprite (if implemented)
- Enemy death animations/effects
- Enemy spawn effects

---

## Combat Interaction

### Fireball Interaction
- **Damage**: Fireball deals fixed damage per hit (developer tunable)
- **Piercing**: Fireball pierces through enemies (infinite piercing)
- **Double Damage**: Enemies hit by both fireball and Explosive Rune explosion take damage twice
- **Death**: Enemy dies when health reaches 0

### Explosive Rune Interaction
- **Area Damage**: Explosive Rune deals fixed damage to all enemies within 1 tile radius
- **Radius**: 1 tile (affects enemies on adjacent tiles)
- **Double Damage**: Enemies hit by both fireball piercing AND explosion take damage twice

---

## Post-MVP Considerations

### Enemy Power Ups
- **Status**: Post-MVP feature
- **Purpose**: Additional difficulty and variety
- **Details**: To be defined post-MVP

### Additional Enemy Types
- **Status**: Post-MVP consideration
- **Purpose**: More variety and challenge
- **Details**: To be defined post-MVP

---

**Status**: Ready for implementation. Enemy types and behaviors defined for MVP.
