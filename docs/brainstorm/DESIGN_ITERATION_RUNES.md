# Design Iteration: Towers → Runes & Fireball System

## Major Changes Summary

### Terminology Shift
- **Bullet** → **Fireball**
- **Towers** → **Runes** (and **Walls**)
- Fireball **ignites** runes to activate them

### Core Mechanic Evolution
- Fireball ignites runes to activate them (instead of just triggering effects)
- Fireball can potentially return to furnace and be reused (needs confirmation)

---

## New Rune System

### Defensive Structures

#### Wall
- **Function**: Prevents enemy movement
- **Placement**: Player can place with resources
- **Interaction**: Blocks enemy pathfinding

### Redirect Runes

#### Redirect Rune
- **Function**: Changes fireball to a specific direction (can be used as bounce)
- **Uses**: Fixed number of uses (0 = infinite uses)
- **Mechanics**: Fireball changes direction automatically when it hits the rune (cardinal directions only)
- **Direction**: Fixed direction (cannot be changed)
- **Movement**: Fireball only travels in cardinal directions (N, S, E, W)

#### Advanced Redirect Rune
- **Function**: Like normal redirect rune, but direction can be changed
- **Uses**: Fixed number of uses (0 = infinite uses)
- **Mechanics**: Fireball changes direction automatically when it hits the rune
- **Direction**: [To be defined: When/how can player change direction?]

### Portal Runes

#### Portal Rune
- **Function**: Instantly teleports fireball to the other portal
- **Mechanics**: ✅ **RESOLVED**
  - Works automatically (no player toggle)
  - Teleports fireball to the other portal
  - Fireball maintains same direction after teleportation
  - Portals are paired (entry/exit)
- **Questions**:
  - [To be defined: Can there be multiple portal pairs?]
  - [To be defined: How are portals paired? (First two placed? Color coded? UI indication?)]

### Explosive Runes

#### Explosive Rune
- **Function**: Explodes fireball when passed over
- **Important**: Does NOT consume bullet or redirect it
- **Mechanics**: [To be defined]
  - What does "explode" mean? Area damage? Visual effect?
  - Does fireball continue after explosion?

### Speed Modification Runes

#### Acceleration Rune
- **Function**: Permanently increases fireball speed
- **Uses**: Fixed use (one-time effect?)
- **Mechanics**: [To be defined]
  - How much speed increase?
  - Does it stack with multiple acceleration runes?

### Status Runes

#### Status Runes (General Category)
- **Function**: Apply statuses to enemies
- **Effects**:
  - Change enemy properties (e.g., speed)
  - Apply passive effects (on hit, on death)
- **Mechanics**: [To be defined]
  - Which enemies are affected? (all enemies? enemies that pass through?)
  - Duration of status effects?
  - What statuses are available?

### Enemy Affector Runes

#### Enemy Affector Runes
- **Function**: Activate when enemies touch instead of when fireball touches
- **Mechanics**: [To be defined]
  - What do these runes do?
  - Examples needed

---

## Level Design Changes

### Level Structure
- **Grid**: Each level is a blank grid
- **Initial Elements**: Some initial walls and runes placed (cannot be edited by player)
- **Player Construction**: Player has fixed resources to construct additional walls or place additional runes

### Difficulty Factors
1. **Mob Timings**: When enemies spawn, wave timing
2. **Mobs from Different Places**: Multiple spawn points, varied entry points
3. **Limited Resources**: Fixed resource budget per level
4. **Limited Walls**: [To be defined - is there a wall limit separate from resources?]

---

## Open Questions

### Fireball Mechanics
1. **Fireball Movement**: ✅ **RESOLVED**
   - Fireball only travels in **cardinal directions** (N, S, E, W - no diagonals)
   - Always starts from furnace at **top of screen**, traveling **downwards** (South)
   - No slow-mo or aiming mechanics needed

2. **Fireball Return to Furnace**: ✅ **RESOLVED**
   - Fireball does NOT automatically return to furnace
   - Fireball travels until it leaves screen or hits wall/terrain
   - [Future consideration: Could add a rune that returns fireball to furnace for reuse]

3. **Fireball Ignition**: 
   - When fireball "ignites" a rune, what exactly happens?
   - Does fireball need to pass through rune center?
   - Or just within range?

### Rune Mechanics
3. ~~**Redirect Rune "Slow"**:~~ ✅ **RESOLVED**
   - ~~What does "redirecting is slow" mean?~~
   - No slow-mo mechanics - fireball redirects automatically
   - Redirect runes change fireball direction instantly when hit

4. **Advanced Redirect Rune Direction Change**: 
   - When/how can player change direction?
   - During build phase? (set direction before wave starts)
   - Or during active phase? (some interaction method)

5. **Portal Rune Mechanics**: ✅ **RESOLVED**
   - No player toggle needed - works automatically
   - Teleports fireball to the other portal
   - Fireball maintains same direction after teleportation
   - Portals are paired (entry/exit)
   - [To be defined: Can there be multiple portal pairs? How are portals paired?]

5. **Explosive Rune**: 
   - What does "explode" do?
   - Area damage? Visual effect?
   - Does fireball continue?

6. **Status Runes**: 
   - Complete list of status effects?
   - How are they applied?
   - Duration?

7. **Enemy Affector Runes**: 
   - What do these do?
   - Examples needed

### Level Design
8. **Resource System**: 
   - What are resources? (single currency? multiple types?)
   - How much per level?
   - Costs for walls vs runes?

9. **Wall Limits**: 
   - Is there a separate wall limit?
   - Or just resource-limited?

10. **Initial Elements**: 
    - How many initial walls/runes per level?
    - Are they tutorial elements or part of challenge?

---

## Migration from Old Design

### What Changed
- ✅ Bullet → Fireball (terminology)
- ✅ Towers → Runes (terminology and concept)
- ✅ Fireball ignites runes (new activation method)
- ✅ Wall as separate structure (not a tower type)
- ✅ More specific rune types defined
- ✅ Level design structure clarified

### What Stays the Same
- ✅ Fixed damage, varied enemy health
- ✅ Infinite piercing
- ✅ No lifetime limits (despawns on boundary/terrain)
- ✅ Time manipulation for aiming
- ✅ Grid-based placement
- ✅ Pathfinding validation

### What Needs Clarification
- ❓ Fireball return to furnace mechanic
- ❓ Complete rune mechanics (explosive, status, enemy affector)
- ❓ Resource system details
- ❓ Level difficulty scaling

---

## Next Steps

1. Clarify fireball return to furnace mechanic
2. Define all rune types completely
3. Design resource system
4. Update GDD with new terminology and mechanics
5. Create rune reference document
