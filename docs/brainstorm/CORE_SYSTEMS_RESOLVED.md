# Core Systems - Resolved

## ✅ Shoot Timing - RESOLVED

### Fireball Launch
- **Automatic Launch**: Fireball automatically shoots when level starts
- **No Player Input**: Player does not need to click or interact to fire
- **Timing**: Launches immediately when active phase begins
- **Direction**: Always starts downward from furnace at top of screen

### Level Structure
- **One Level = One Wave**: Each level contains exactly one wave
- **Level End**: Level completes when:
  - All enemies are defeated (victory)
  - Furnace is destroyed (defeat)

### Implications
- Player strategy is entirely in build phase
- No timing decisions during active phase
- Fireball path is predetermined by rune placement
- Player observes and cannot interact during active phase

---

## ✅ Player Character - RESOLVED

### Player Representation
- **Cursor Only**: Player is represented as a cursor - no character sprite
- **No Character Model**: No visible character on screen
- **UI Interaction**: Cursor used for UI interaction only

### Player Capabilities
- **Build Phase**: 
  - Place walls and runes
  - Interact with UI
  - Move cursor to select/place items
- **Active Phase**: 
  - No interaction possible
  - Player observes only
  - Cannot move character (no character exists)
  - Cannot interact with fireball or enemies

### Abilities
- **No Special Abilities**: Player has no abilities beyond building walls/runes
- **No Movement**: No character movement (cursor movement only for UI)
- **No Active Phase Actions**: Cannot repair, activate, or interact during active phase

---

## ✅ Furnace Health - RESOLVED

### Furnace Mechanics
- **Health**: 1 HP (one hit = game over)
- **Destruction**: Furnace dies instantly when an enemy touches it
- **No Damage Over Time**: Single touch = instant destruction
- **No Protection**: No shields, barriers, or protection mechanics
- **Game Over Condition**: Enemy contact = immediate level failure

### Enemy Interaction
- **Touch = Death**: Any enemy reaching furnace destroys it
- **No Multiple Hits**: Does not require multiple hits or damage over time
- **Instant**: No delay or animation - immediate game over

---

## Summary

All three core system questions have been resolved. The game mechanics are now clear:

1. **Fireball**: Automatically launches at level start, no player input needed
2. **Player**: Cursor only, no character, no active phase interaction
3. **Furnace**: 1 HP, instant destruction on enemy contact
4. **Level Structure**: One level = one wave

These decisions significantly simplify the game design and make the core loop clear: build strategically, then watch the fireball and enemies interact.
