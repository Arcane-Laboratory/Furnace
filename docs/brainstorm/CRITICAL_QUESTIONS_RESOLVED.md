# Critical Questions - Resolved

## ✅ Question 1: Rune Ignition Mechanics - RESOLVED

### Resolution
- **Fireball Movement**: Travels between tiles in cardinal directions, always moves along tile grids
- **Activation**: Fireball activates/ignites a tile when it goes over the center of that tile
- **Rune Ignition**: When fireball ignites a tile containing a rune, the rune's ability activates
- **Collision Detection**: Grid-aligned collision (fireball position matches tile grid)

### Tile Occupancy Rules
- Each tile can contain: **a rune**, OR **a wall**, OR **an enemy spawn point**
- Never more than one element per tile
- Cannot overlap structures

### Implementation Notes
- Fireball position tracked on grid (tile coordinates)
- Check tile center collision when fireball enters new tile
- If tile contains rune, activate rune's ability
- Simple grid-based check (no complex collision detection needed)

---

**Status**: ✅ RESOLVED - Can now implement rune ignition system

---

## ✅ Question 2: Explosive Rune Mechanics - RESOLVED

### Resolution
- **Trigger**: When fireball passes over tile center containing Explosive Rune
- **Explosion Damage**: Fixed damage value (developer tunable parameter, separate from fireball damage)
- **Explosion Radius**: 1 tile (affects enemies on the rune's tile and all 4 adjacent tiles)
- **Fireball Behavior**: Fireball continues traveling after explosion (not consumed)
- **Double Damage**: Enemies hit by both fireball piercing AND explosion take damage twice
- **Effects**: 
  - Plays sound effect (SFX) when exploding
  - Plays visual effect (VFX) when exploding

### Implementation Notes
- Check for enemies within 1 tile radius when explosion triggers
- Apply explosion damage to all enemies in radius
- Fireball continues on its path (no consumption or redirection)
- Visual/audio effects play at explosion location

**Status**: ✅ RESOLVED - Can now implement Explosive Rune

---

## ✅ Question 3: Acceleration Rune Details - RESOLVED

### Resolution
- **Speed Increase**: Fixed value (e.g., +10) - developer tunable parameter
- **Stacking**: Yes, multiple Acceleration Runes stack their speed increases
- **Speed Cap**: Maximum speed limit - developer tunable parameter
- **Base Speed**: Base fireball speed - developer tunable parameter
- **Behavior**:
  - When fireball hits Acceleration Rune, speed increases by fixed amount
  - If fireball hits multiple Acceleration Runes, speed increases stack
  - Speed cannot exceed maximum speed cap
  - If fireball is already at cap, hitting another Acceleration Rune has no effect (but rune is still consumed)
- **Fixed Use**: Each Acceleration Rune can only be used once per level

### Developer Tunable Parameters
- Base fireball speed
- Acceleration Rune speed increase amount (e.g., +10)
- Maximum speed cap

### Implementation Notes
- Track fireball's current speed
- When Acceleration Rune is hit, add speed increase to current speed
- Check if new speed exceeds cap, if so clamp to cap
- Speed increase is permanent for the rest of the level

**Status**: ✅ RESOLVED - Can now implement Acceleration Rune

---

## ✅ Question 4: Advanced Redirect Rune Direction Change - RESOLVED

### Resolution
- **Regular Redirect Rune**:
  - Direction can be changed during build phase only
  - Can change direction multiple times during build phase
  - Rune has visual asset showing current direction
  
- **Advanced Redirect Rune** (needs new name - low priority):
  - Direction can be changed during build phase AND active phase
  - Can change direction multiple times (both phases)
  - **Build Phase**: Same method as regular Redirect Rune
  - **Active Phase**: Click + menu option OR click + drag (reuse UI from placement if possible)
  - Rune has visual asset showing current direction

### UI Considerations
- Reuse placement UI for direction change if possible
- Visual asset on rune shows current direction
- Direction change method should be intuitive and consistent

### Implementation Notes
- Track direction for each Redirect Rune
- Regular Redirect: Only allow direction change during build phase
- Advanced Redirect: Allow direction change during both phases
- Visual feedback showing current direction
- Consider reusing placement UI patterns for consistency

**Status**: ✅ RESOLVED - Can now implement Redirect Runes (both types)

---

## ✅ Question 5: Portal Rune Pairing - RESOLVED

### Resolution
- **MVP**: Only one portal pair per level
- **Pairing Method**: First two portals placed become a pair automatically
- **Behavior**: 
  - When fireball hits first portal, teleports to second portal
  - When fireball hits second portal, teleports to first portal
  - Works automatically (no player toggle)
  - Fireball maintains same direction after teleportation
- **Post-MVP**: 
  - Multiple portal pairs allowed
  - Matching colors for pairing indication

### Implementation Notes
- Track portal placement order
- First portal placed = Portal A
- Second portal placed = Portal B
- Portal A and Portal B are paired
- If more than 2 portals placed, only first two are active (or prevent placing more than 2)

**Status**: ✅ RESOLVED - Can now implement Portal Rune (MVP version)

---

## ✅ Question 6: Rune Upgrade Options - RESOLVED

### Resolution
- **MVP**: Upgrades are NOT in scope
- **Reason**: Focus on rune variety over upgrades. Upgrades add complexity and are not essential for core gameplay loop.
- **Post-MVP**: Upgrade system may be added
  - Redirect runes can be upgraded for more uses
  - Other upgrade options to be defined

### Implementation Notes
- No upgrade system needed for MVP
- All runes work with their base properties
- Can add upgrade system in post-MVP development

**Status**: ✅ RESOLVED - Upgrades cut from MVP scope

---
