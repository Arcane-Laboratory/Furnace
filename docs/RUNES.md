# Runes - Content Design

**Version**: 1.0  
**Last Updated**: [Current Date]  
**Purpose**: Complete rune system specifications and mechanics

---

## Rune System Overview

### Activation Method
- **Trigger**: Fireball ignites runes to activate them
- **Activation Point**: Fireball activates/ignites a tile when it goes over the center of that tile
- **Grid-Aligned**: Fireball travels between tiles in cardinal directions, always moving along tile grids
- **Collision Detection**: Grid-aligned collision (fireball position matches tile grid)

### Rune Placement
- **Grid-Based**: 13x8 grid, 32x32 tiles
- **Tile Occupancy**: Each tile can contain: a rune, OR a wall, OR an enemy spawn point (never more than one)
- **Resource Costs**: All rune costs are developer tunable parameters (varies by rune type)
- **Initial Elements**: Some runes are pre-placed and cannot be edited

---

## Rune Types (MVP)

### Redirect Runes

#### Redirect Rune
- **Function**: Changes fireball to a specific direction (can be used as bounce)
- **Trigger**: When fireball ignites rune
- **Uses**: Fixed number of uses (0 = infinite uses)
- **Direction Change**: 
  - Can change direction during build phase only
  - Can change direction multiple times during build phase
  - Fireball changes direction automatically when it hits the rune
- **Visual**: Rune has visual asset showing current direction
- **Direction Options**: Cardinal directions only (N, S, E, W)

#### Advanced Redirect Rune
- **Function**: Like normal redirect rune, but direction can be changed during build phase AND active phase
- **Trigger**: When fireball ignites rune
- **Uses**: Fixed number of uses (0 = infinite uses)
- **Direction Change**:
  - Can change direction multiple times (both phases)
  - **Build Phase**: Same method as regular Redirect Rune
  - **Active Phase**: Click + menu option OR click + drag (reuse UI from placement if possible)
  - Fireball changes direction automatically when it hits the rune
- **Visual**: Rune has visual asset showing current direction
- **Direction Options**: Cardinal directions only (N, S, E, W)
- **Note**: Needs new name (low priority)

---

### Portal Runes

#### Portal Rune
- **Function**: Instantly teleports fireball to the other portal
- **Trigger**: When fireball ignites rune
- **Behavior**:
  - Fireball maintains same direction after teleportation
  - Portals are paired (entry/exit)
  - No player toggle needed - works automatically
- **MVP Pairing**: 
  - Only one portal pair per level
  - First two portals placed become a pair automatically
- **Post-MVP**: 
  - Multiple pairs allowed
  - Matching colors for pairing indication

---

### Explosive Runes

#### Explosive Rune
- **Function**: Explodes when fireball passes over, dealing area damage
- **Trigger**: When fireball passes over tile center
- **Explosion Mechanics**:
  - Deals fixed damage to all enemies within 1 tile radius
  - Explosion radius: 1 tile (affects enemies on adjacent tiles)
  - Fireball continues traveling after explosion (not consumed)
  - Enemies hit by both fireball piercing AND explosion take damage twice
- **Effects**:
  - Plays sound effect (SFX) when exploding
  - Plays visual effect (VFX) when exploding
- **Damage**: Fixed damage value (developer tunable parameter, separate from fireball damage)
- **Note**: Does NOT consume fireball or redirect it

---

### Speed Modification Runes

#### Acceleration Rune
- **Function**: Permanently increases fireball speed by a fixed value
- **Trigger**: When fireball ignites rune
- **Mechanics**:
  - Speed increase stacks (multiple Acceleration Runes add their speed increases)
  - Speed increase stacks up to a maximum speed cap
  - Fixed use (one-time effect per rune)
  - When fireball hits Acceleration Rune, speed increases by fixed amount
  - If fireball hits multiple Acceleration Runes, speed increases stack
  - Speed cannot exceed maximum speed cap
  - If fireball is already at cap, hitting another Acceleration Rune has no effect (but rune is still consumed)
- **Developer Tunable Parameters**:
  - Base fireball speed
  - Acceleration Rune speed increase amount (e.g., +10)
  - Maximum speed cap

---

### Reflect Runes

#### Reflect Rune
- **Function**: Reflects fireball to closest 90-degree angle
- **Trigger**: When fireball ignites rune
- **Mechanics**:
  - Automatically reflects fireball to closest 90-degree angle
  - Snaps to grid (fireball travels along game grid after reflection)
  - Limited uses
  - Debounce/cooldown to prevent fireball getting stuck bouncing
- **Developer Tunable Parameters**:
  - Reflect rune debounce/cooldown duration
  - Number of uses

---

## Post-MVP Rune Types

### Status Runes
- **Status**: Post-MVP (not in MVP scope)
- **Function**: Apply statuses to enemies
- **Effects**:
  - Change enemy properties (e.g., speed)
  - Apply passive effects (on hit, on death)
- **Details**: To be defined post-MVP
  - Which enemies affected?
  - Duration?
  - Complete list of statuses?

### Enemy Affector Runes
- **Status**: Post-MVP (not in MVP scope)
- **Function**: Activate when enemies touch instead of when fireball touches
- **Trigger**: When enemies touch rune
- **Details**: To be defined post-MVP
  - What do these runes do?
  - Examples needed

---

## Rune Upgrades

### MVP Status
- **Upgrades**: No rune upgrades (cut from MVP scope)
- **Reason**: Focus on rune variety over upgrades. Upgrades add complexity and are not essential for core gameplay loop.

### Post-MVP
- **Upgrade System**: May be added post-MVP
- **Redirect Runes**: Can be upgraded for more uses
- **Other Upgrades**: Other upgrade options to be defined

---

## Rune Costs

All rune costs are developer tunable parameters:

- **Redirect Rune Cost**: Resource cost to place one Redirect Rune
- **Advanced Redirect Rune Cost**: Resource cost to place one Advanced Redirect Rune
- **Portal Rune Cost**: Resource cost to place one Portal Rune
- **Reflect Rune Cost**: Resource cost to place one Reflect Rune
- **Explosive Rune Cost**: Resource cost to place one Explosive Rune
- **Acceleration Rune Cost**: Resource cost to place one Acceleration Rune

---

## Rune Availability

### Designer Levers
- **Unlocked By Default**: Runes have `unlocked_by_default` property (designer-configurable)
- **Level-Specific**: Levels can specify `allowed_runes` (which runes are available)
- **Availability Logic**: Rune available if: (unlocked_by_default OR in level's allowed_runes)

### MVP Rune Availability
- **Level 1 (Tutorial)**: Redirect, Reflect, Acceleration (basic runes)
- **Level 2**: Redirect, Reflect, Acceleration, Explosive (adds Explosive)
- **Level 3**: All runes available (adds Advanced Redirect, Portal)

---

## Visual Design

### Visual Elements Needed
- Redirect Rune sprite (with direction indicator)
- Advanced Redirect Rune sprite (with direction indicator)
- Portal Rune sprite (entry/exit variants)
- Reflect Rune sprite
- Explosive Rune sprite
- Acceleration Rune sprite
- Rune activation effects (visual feedback when runes activate)
- Explosion effects (Explosive Rune VFX)

### Visual Feedback
- **Direction Indicators**: Redirect runes show current direction
- **Activation Effects**: Visual feedback when runes activate
- **Explosion Effects**: Explosive Rune VFX
- **Portal Effects**: Visual effect when fireball teleports

---

## Implementation Notes

### Rune Base System
- **Base Class**: All runes should inherit from base rune class
- **Activation Method**: Unified activation system for all rune types
- **Tile Center Collision**: Check tile center collision when fireball enters new tile
- **Polymorphism**: Handle multiple rune types with base class/polymorphism

### Rune-Specific Mechanics
- **Redirect**: Track direction, change fireball direction on activation
- **Portal**: Track pairing, teleport fireball to paired portal
- **Explosive**: Check for enemies in radius, apply area damage
- **Acceleration**: Track fireball speed, increase speed on activation
- **Reflect**: Calculate closest 90-degree angle, apply debounce/cooldown

---

**Status**: Ready for implementation. All MVP rune types defined with complete mechanics.
