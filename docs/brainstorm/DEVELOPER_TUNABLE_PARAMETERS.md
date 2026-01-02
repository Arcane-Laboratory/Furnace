# Developer Tunable Parameters

**Version**: 1.0  
**Last Updated**: [Current Date]  
**Purpose**: Comprehensive list of all developer-tunable parameters for balancing and configuration

---

## Overview

All parameters listed below should be easily configurable (e.g., in a config file, constants file, or editor) to allow for rapid iteration and balancing during development and playtesting.

---

## Fireball Parameters

### Core Fireball Stats
- **Fireball Damage**: Fixed damage value per enemy hit
  - **Type**: Integer
  - **Default**: [TBD]
  - **Notes**: Applied to each enemy the fireball pierces through

- **Base Fireball Speed**: Initial travel speed of fireball
  - **Type**: Float/Integer (units per frame or units per second)
  - **Default**: [TBD]
  - **Notes**: Speed before any Acceleration Rune modifications

---

## Rune Parameters

### Reflect Rune
- **Reflect Rune Debounce/Cooldown**: Duration to prevent fireball getting stuck bouncing
  - **Type**: Float (seconds) or Integer (frames)
  - **Default**: [TBD]
  - **Notes**: Time period after reflection during which same rune cannot reflect again

### Explosive Rune
- **Explosive Rune Damage**: Fixed damage value for explosion
  - **Type**: Integer
  - **Default**: [TBD]
  - **Notes**: Separate from fireball damage. Applied to all enemies within 1 tile radius

### Acceleration Rune
- **Acceleration Rune Speed Increase**: Fixed speed increase amount
  - **Type**: Float/Integer (same units as Base Fireball Speed)
  - **Default**: [TBD] (e.g., +10)
  - **Notes**: Amount added to fireball speed when Acceleration Rune is hit. Stacks with multiple runes.

- **Maximum Speed Cap**: Maximum speed fireball can reach
  - **Type**: Float/Integer (same units as Base Fireball Speed)
  - **Default**: [TBD]
  - **Notes**: Caps Acceleration Rune stacking. Fireball speed cannot exceed this value.

---

## Resource System Parameters

### Wall Costs
- **Wall Cost**: Resource cost to place one wall
  - **Type**: Integer
  - **Default**: [TBD]
  - **Notes**: Cost per wall placement

### Rune Costs
All rune costs are per rune placement:

- **Redirect Rune Cost**: Resource cost to place one Redirect Rune
  - **Type**: Integer
  - **Default**: [TBD]

- **Advanced Redirect Rune Cost**: Resource cost to place one Advanced Redirect Rune
  - **Type**: Integer
  - **Default**: [TBD]
  - **Notes**: Advanced Redirect Rune (needs new name - low priority)

- **Portal Rune Cost**: Resource cost to place one Portal Rune
  - **Type**: Integer
  - **Default**: [TBD]
  - **Notes**: MVP limited to one pair per level

- **Reflect Rune Cost**: Resource cost to place one Reflect Rune
  - **Type**: Integer
  - **Default**: [TBD]

- **Explosive Rune Cost**: Resource cost to place one Explosive Rune
  - **Type**: Integer
  - **Default**: [TBD]

- **Acceleration Rune Cost**: Resource cost to place one Acceleration Rune
  - **Type**: Integer
  - **Default**: [TBD]

### Resource Allocation
- **Resource Amount Per Level**: Fixed resources available per level
  - **Type**: Integer (array/list per level)
  - **Default**: [TBD per level]
  - **Notes**: Varies by level difficulty. Should be defined per level (e.g., Level 1: 50, Level 2: 75, Level 3: 100)

---

## Parameter Organization Recommendations

### Suggested File Structure
```
config/
  ├── fireball_params.json (or .yaml, .lua, etc.)
  ├── rune_params.json
  ├── resource_params.json
  └── level_resources.json (resource amounts per level)
```

### Or Single Config File
```
config/
  └── game_balance.json
```

### Example Structure (JSON)
```json
{
  "fireball": {
    "damage": 50,
    "baseSpeed": 100
  },
  "runes": {
    "reflect": {
      "debounceCooldown": 0.5
    },
    "explosive": {
      "damage": 75
    },
    "acceleration": {
      "speedIncrease": 10,
      "maxSpeedCap": 200
    }
  },
  "costs": {
    "wall": 1,
    "redirectRune": 5,
    "advancedRedirectRune": 8,
    "portalRune": 10,
    "reflectRune": 6,
    "explosiveRune": 7,
    "accelerationRune": 5
  },
  "levelResources": {
    "level1": 50,
    "level2": 75,
    "level3": 100,
    "level4": 125,
    "level5": 150
  }
}
```

---

## Balancing Guidelines

### Fireball Balance
- **Damage vs Enemy Health**: Fireball damage should be balanced against enemy health values
  - Basic enemies: Should take 1-2 hits to kill
  - Tank enemies: Should take 3-5 hits to kill
  - Fast enemies: Should take 1 hit to kill (if low health)

- **Speed**: Base speed should allow fireball to travel across level in reasonable time
  - Too fast: Hard to see, feels rushed
  - Too slow: Boring, enemies reach furnace before fireball

### Rune Balance
- **Explosive Rune**: Damage should be balanced against fireball damage
  - Can be same, higher, or lower depending on desired effect
  - Consider that enemies can be hit by both fireball and explosion

- **Acceleration Rune**: Speed increase and cap should allow meaningful stacking
  - Too low: Stacking feels weak
  - Too high: Fireball becomes uncontrollable

### Resource Balance
- **Wall Cost**: Should be cheap enough that players can place many walls
  - Consider: Very cheap (1-2) or free (0)

- **Rune Costs**: Should vary based on rune power/complexity
  - Basic runes (Redirect, Acceleration): Lower cost
  - Advanced runes (Portal, Explosive): Higher cost
  - Advanced Redirect: Higher than basic Redirect

- **Resource Amounts**: Should scale with level difficulty
  - Early levels: More resources (easier)
  - Later levels: Fewer resources (harder)
  - Should allow placement of several runes + walls

---

## Testing & Iteration

### Recommended Testing Process
1. Set initial placeholder values
2. Playtest with these values
3. Adjust based on feedback
4. Document what works
5. Iterate

### Key Balance Points to Test
- Can player afford reasonable number of walls + runes?
- Is fireball damage appropriate for enemy health?
- Does Acceleration Rune stacking feel meaningful?
- Are expensive runes worth their cost?
- Does resource scarcity create interesting choices?

---

## Notes

- All values marked [TBD] need to be set during initial implementation
- Values should be easily changeable without code recompilation (if possible)
- Consider using a visual editor or config file for non-programmers
- Document any dependencies between parameters (e.g., speed cap should be > base speed)

---

## Enemy Parameters

### Enemy Stats (Per Type)
- **Basic Enemy Health**: Health value for Basic Enemy
  - **Type**: Integer
  - **Default**: [TBD]
  
- **Basic Enemy Speed**: Movement speed for Basic Enemy
  - **Type**: Float/Integer (units per frame or units per second)
  - **Default**: [TBD]

- **Fast Enemy Health**: Health value for Fast Enemy
  - **Type**: Integer
  - **Default**: [TBD]
  - **Notes**: Should be lower than Basic Enemy

- **Fast Enemy Speed**: Movement speed for Fast Enemy
  - **Type**: Float/Integer (same units as Basic Enemy Speed)
  - **Default**: [TBD]
  - **Notes**: Should be higher than Basic Enemy

- **Tank Enemy Health**: Health value for Tank Enemy (if implemented)
  - **Type**: Integer
  - **Default**: [TBD]
  - **Notes**: Should be higher than Basic Enemy

- **Tank Enemy Speed**: Movement speed for Tank Enemy (if implemented)
  - **Type**: Float/Integer (same units as Basic Enemy Speed)
  - **Default**: [TBD]
  - **Notes**: Should be lower than Basic Enemy

### Enemy Wave Parameters (Per Level)
- **Enemy Count**: Total number of enemies per level
  - **Type**: Integer (per level)
  - **Default**: [TBD per level]
  - **Notes**: Varies by level difficulty

- **Enemy Spawn Timing**: Timing/delays for staggered spawning
  - **Type**: Float (seconds) or Integer (frames)
  - **Default**: [TBD]
  - **Notes**: Delay between enemy spawns, can vary per spawn point

- **Spawn Point Locations**: Grid coordinates of spawn points
  - **Type**: Array of tile coordinates (per level)
  - **Default**: [TBD per level]
  - **Notes**: Defined by level designers in level editor

---

## Future Parameters (Post-MVP)

These parameters may be added post-MVP:
- Enemy power ups
- Status Rune effects (if added)
- Enemy Affector Rune effects (if added)
- Upgrade costs (if upgrade system added)

---

**Status**: Ready for implementation. All parameters should be defined before final balancing phase.
