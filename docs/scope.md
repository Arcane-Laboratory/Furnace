# Furnace - Development Scope

**Version**: 1.0  
**Last Updated**: [Current Date]  
**Purpose**: Define MVP (Minimum Viable Product) scope for game jam and post-MVP features for future development

---

## 🎯 MVP Scope (Must Have)

### Core Gameplay Loop
- ✅ **Build Phase**
  - Player places walls and runes on grid
  - Grid-based placement (13x8 grid, 32x32 tiles)
  - View enemy path preview
  - Validate enemy path exists
  - Free sell/buy (full refund, can modify before starting level)
  
- ✅ **Active Phase**
  - Fireball automatically launches when level starts
  - Fireball travels in cardinal directions only
  - Fireball pierces enemies, deals fixed damage
  - Player observes only (no interaction during active phase)
  - Level ends when all enemies defeated OR furnace destroyed

- ✅ **Level Structure**
  - One level = one wave
  - 3-5 levels total for game jam
  - Some initial walls/runes pre-placed (non-editable)
  - Fixed resources per level

### Fireball System
- ✅ **Core Mechanics**
  - Automatic launch from furnace (top of screen, downward)
  - Cardinal direction movement only (N/S/E/W)
  - Fixed damage per enemy hit
  - Infinite piercing (no hit limit)
  - No lifetime limit (travels until screen boundary or wall/terrain)
  - Despawns on boundary or terrain collision

- ✅ **Developer Tunable Parameters**
  - Fireball damage value
  - Fireball speed
  - Reflect rune debounce/cooldown duration

### Rune System (MVP Runes Only)

#### ✅ Redirect Rune
- Changes fireball to fixed direction
- Fixed number of uses (0 = infinite)
- Automatic direction change when fireball hits
- **Status**: IN MVP

#### ✅ Advanced Redirect Rune
- Like Redirect Rune, but direction can be changed
- Player sets direction during build phase
- Fixed number of uses
- **Status**: IN MVP (if direction change is simple)

#### ✅ Portal Rune
- Teleports fireball to paired portal
- Maintains direction after teleport
- **MVP**: One portal pair per level (simplified)
- **MVP Pairing**: Automatic pairing (first two placed = pair)
- **Post-MVP**: Multiple portal pairs allowed, matching colors for pairing indication
- **Status**: IN MVP (one pair only)

#### ✅ Reflect Rune
- Reflects fireball to closest 90-degree angle
- Limited uses
- Debounce/cooldown to prevent stuck loops
- **Status**: IN MVP

#### ✅ Explosive Rune
- Explodes fireball when passed over
- Does NOT consume or redirect fireball
- **Status**: IN MVP (if mechanics are simple - needs definition)

#### ✅ Acceleration Rune
- Permanently increases fireball speed
- Fixed use (one-time effect)
- **Status**: IN MVP (if mechanics are simple - needs definition)

### Defensive Structures

#### ✅ Wall
- Prevents enemy movement
- Blocks pathfinding
- Resource cost to place
- **Status**: IN MVP

### Enemy System

#### ✅ Enemy Types (2-3 types for MVP)
- **Basic Enemy**: Standard health, standard speed
- **Fast Enemy**: Lower health, higher speed
- **Tank Enemy**: Higher health, lower speed (optional third type)
- Varied health values
- Fixed damage from fireball
- Destroy furnace on contact (one touch = game over)
- **No Special Abilities**: Enemies have no power ups or special abilities in MVP

#### ✅ Enemy Behavior
- Follow pathfinding route to furnace
- Spawn from designated spawn points (spawning tiles)
- Staggered spawning from flexible number of spawn points
- Multiple spawn points possible
- No special abilities or power ups in MVP

### Resource System

#### ✅ Basic Resource System
- Single currency type
- Fixed resources per level (cannot be edited)
- Costs vary by structure/rune type
- Resource display in UI
- **Status**: IN MVP (needs cost values defined)

### Level Design

#### ✅ Level Components
- Blank grid with initial walls/runes (non-editable)
- Pre-set enemy wave
- Spawn points
- Furnace location (top of screen)
- Terrain types: Rock/Mountain (unbuildable), Open Terrain (buildable)

#### ✅ Level Count
- **MVP**: 3 levels total
  - Level 1: Tutorial level (teaches core mechanics)
  - Level 2: Challenge level
  - Level 3: Challenge level
- Hand-crafted levels (not procedural)

### UI/UX (MVP Minimum)

#### ✅ Essential UI
- Build phase UI:
  - Wall/rune placement interface
  - Resource display
  - Enemy path preview
  - End build phase button
- Active phase UI:
  - Basic wave indicator (if needed)
  - Furnace health indicator (1 HP)
- Game Over screen
- Pause screen
- Title/Start Menu

#### ✅ Controls
- Mouse: Click to place walls/runes, click to sell
- Keyboard: Pause button

### Technical (MVP Minimum)

#### ✅ Display
- 640x360 pixel perfect resolution
- 16:9 aspect ratio
- Basic scaling (can refine later)

#### ✅ Performance
- Target: 60 FPS
- Handle "lots of enemies" (specific target TBD)
- Basic optimization

---

## 🟡 Post-MVP Features (Consider for Later)

### Rune System Expansions

#### Status Runes
- Apply statuses to enemies
- Change enemy properties (speed, etc.)
- Apply passive effects (on hit, on death)
- **Status**: POST-MVP
- **Reason**: Complex mechanics, adds significant complexity

#### Enemy Affector Runes
- Activate when enemies touch (not fireball)
- Various effects on enemies
- **Status**: POST-MVP
- **Reason**: Different activation mechanism, adds complexity

#### Multiple Portal Pairs
- More than one portal pair per level
- Portal pairing system (matching colors for pairing indication)
- **Status**: POST-MVP
- **Reason**: MVP limited to one portal pair per level, expand to multiple pairs post-MVP

### Rune Upgrades
- Upgrade redirect runes for more uses
- Other upgrade options
- Upgrade UI/system
- **Status**: POST-MVP (CONFIRMED - Not in MVP scope)
- **Reason**: Focus on rune variety over upgrades for MVP. Upgrades add complexity and are not essential for core gameplay loop.

### Advanced Resource System
- Multiple resource types
- Resource generation during waves
- More complex economy
- **Status**: POST-MVP
- **Reason**: Simple single currency sufficient for MVP

### Enemy System Expansions

#### More Enemy Types
- 4+ enemy types
- Special abilities
- Boss enemies
- **Status**: POST-MVP
- **Reason**: 2-3 types sufficient for game jam

#### Enemy Special Abilities
- Flying enemies
- Armored enemies
- Swarm enemies
- **Status**: POST-MVP
- **Reason**: Keep MVP simple

#### Enemy Power Ups
- Enemies with power ups or special modifiers
- Enhanced enemy abilities
- **Status**: POST-MVP (CONFIRMED)
- **Reason**: Difficulty progression in MVP is handled through level design (more spawn points, more enemies, more enemy types). Enemy power ups add complexity and are not essential for MVP.

### Level Design Expansions

#### More Levels
- 10+ levels
- Level progression system
- **Status**: POST-MVP
- **Reason**: 3-5 levels sufficient for game jam

#### Procedural Generation
- Procedurally generated levels
- Random enemy spawns
- **Status**: POST-MVP
- **Reason**: Hand-crafted better for game jam

#### Terrain Types
- **Void Holes**: Uneditable terrain tiles that enemies can pass through but players cannot build on
- Special terrain effects
- **Status**: POST-MVP
- **Reason**: Basic terrain (Rock/Mountain, Open Terrain, Spawn Point) sufficient for MVP

### Progression Systems

#### Score System
- Score based on enemies killed
- Leaderboards
- High score tracking
- **Status**: POST-MVP (CONFIRMED - Cut from MVP)
- **Reason**: Not essential for core gameplay

#### Level Select Menu with Unlocks
- Level select menu interface
- Unlock system for levels
- **Status**: POST-MVP
- **Reason**: MVP uses gated linear progression (Level 1 → Level 2 → Level 3)

#### MVP Progression System
- **Gated Progression**: Start at Level 1, must clear to unlock next
- **Rune Unlocks**: Runes have `unlocked_by_default` property (designer-configurable)
- **Level-Specific Runes**: Levels can specify `allowed_runes` (which runes available)
- **Status**: IN MVP

### UI/UX Enhancements

#### Advanced UI Features
- Detailed pathfinding visualization
- Advanced wave indicator (timers, etc.)
- Tower range indicators
- Enemy health bars
- Bullet trail/effects visualization
- **Status**: POST-MVP
- **Reason**: Basic UI sufficient for MVP

### Polish Features

#### Art Style Refinement
- Detailed art style definition
- Advanced particle effects
- Animations
- **Status**: POST-MVP
- **Reason**: Placeholder art sufficient for MVP

#### Audio Enhancements
- Background music
- Advanced sound effects
- Audio mixing
- **Status**: POST-MVP
- **Reason**: Basic sound effects sufficient for MVP

### Technical Enhancements

#### Advanced Performance
- Specific performance targets
- Advanced optimization
- Performance profiling tools
- **Status**: POST-MVP
- **Reason**: Basic performance sufficient for MVP

#### Display Scaling
- Advanced scaling options
- Multiple resolution support
- **Status**: POST-MVP
- **Reason**: Basic scaling sufficient for MVP

### Platform & Distribution

#### Multiplatform
- Web version
- Mobile version
- Console version
- **Status**: POST-MVP
- **Reason**: Focus on one platform for MVP

#### Distribution
- Steam release
- Itch.io release
- Marketing materials
- **Status**: POST-MVP
- **Reason**: Game jam submission first

---

## ❌ Explicitly Out of Scope (Cut Features)

### Multiplayer
- **Status**: CUT
- **Reason**: Single player only for MVP and game jam

### Rune Upgrades (in MVP)
- **Status**: CUT FROM MVP (CONFIRMED)
- **Reason**: Focus on rune variety instead. Upgrades add complexity and are not essential for core gameplay loop.
- **Note**: Post-MVP feature

### Score System (in MVP)
- **Status**: CUT FROM MVP (CONFIRMED)
- **Reason**: Not essential for core gameplay. Focus on core mechanics first.
- **Note**: Post-MVP feature - can add if needed

### Status Runes (in MVP)
- **Status**: CUT FROM MVP
- **Reason**: Too complex for game jam timeline
- **Note**: High priority for post-MVP

### Enemy Affector Runes (in MVP)
- **Status**: CUT FROM MVP
- **Reason**: Different activation mechanism adds complexity
- **Note**: Consider for post-MVP

### Void Holes Terrain
- **Status**: CUT FROM MVP (CONFIRMED)
- **Purpose**: Uneditable terrain tiles that:
  - Players cannot place/build walls or runes on
  - Enemies can pass through
  - Prevent player construction
- **Reason**: Not essential for MVP, adds complexity to pathfinding and level design
- **Note**: Post-MVP feature - can add if needed for level design variety

### Enemy Power Ups
- **Status**: CUT FROM MVP (CONFIRMED)
- **Reason**: Difficulty progression handled through level design (more spawn points, enemies, enemy types). Enemy power ups add complexity and are not essential for MVP.
- **Note**: Post-MVP feature

### Slow-Mo/Aiming Mechanics
- **Status**: CUT (already resolved)
- **Reason**: Fireball launches automatically, no aiming needed

### Player Character Movement
- **Status**: CUT (already resolved)
- **Reason**: Player is cursor only, no character sprite

### Fireball Return to Furnace
- **Status**: CUT (already resolved)
- **Reason**: Fireball does not return automatically
- **Note**: Could add rune for this post-MVP

---

## 📊 Scope Summary

### MVP Features Count
- **Core Systems**: 3 (Fireball, Player, Furnace) ✅
- **Rune Types**: 6 (Redirect, Advanced Redirect, Portal, Reflect, Explosive, Acceleration)
- **Defensive Structures**: 1 (Wall)
- **Enemy Types**: 2-3
- **Levels**: 3-5
- **UI Screens**: 5 (Title, Menu, Game, Pause, Game Over)

### Post-MVP Features Count
- **Rune Types**: 2 (Status, Enemy Affector)
- **Systems**: Multiple (Upgrades, Score, Unlocks, etc.)
- **Content**: More levels, enemies, terrain types

### Cut Features Count
- **Major Systems**: 6 (Multiplayer, Upgrades in MVP, Score in MVP, Status Runes in MVP, Enemy Affector in MVP, Void Holes)

---

## 🎯 MVP Success Criteria

### Must Have for Game Jam Submission:
1. ✅ Playable build with 3-5 levels
2. ✅ Core gameplay loop functional (build → active → resolution)
3. ✅ At least 4-5 rune types working
4. ✅ 2-3 enemy types
5. ✅ Basic UI functional
6. ✅ No critical bugs
7. ✅ Runs at playable framerate

### Nice to Have (but not required):
- Polished art
- Background music
- Score system
- More than 3 levels
- All rune types

---

## 🔄 Scope Review Process

### When to Review:
- After resolving critical questions (Tier 1)
- After first playable prototype
- Before final polish phase
- If running behind schedule

### How to Adjust:
1. If behind schedule: Cut lowest priority MVP features
2. If ahead of schedule: Add highest priority post-MVP features
3. If feature too complex: Move to post-MVP
4. If feature essential: Move to MVP

### Priority Order for Cuts (if needed):
1. Acceleration Rune (if complex)
2. Explosive Rune (if complex)
3. Advanced Redirect Rune (if complex)
4. Reduce to 3 levels instead of 5
5. Reduce to 2 enemy types instead of 3

---

## 📝 Notes

### MVP Philosophy
- **Focus**: Core gameplay loop and fun factor
- **Quality over Quantity**: Fewer, well-polished features over many incomplete features
- **Playable First**: Get something playable quickly, then iterate
- **Cut Early**: Better to cut features early than struggle with scope creep

### Post-MVP Philosophy
- **Expand Gradually**: Add features one at a time
- **Player Feedback**: Use feedback to prioritize post-MVP features
- **Balance**: Maintain game balance as features are added

### Risk Mitigation
- **Complex Runes**: If Explosive/Acceleration runes prove too complex, cut them
- **Resource System**: Start with simple costs, refine during playtesting
- **Enemy Types**: Can start with 2 types, add third if time permits
- **Level Count**: Can reduce to 3 levels if needed

---

## ✅ Approval & Sign-off

**MVP Scope Approved**: [ ] Yes [ ] No  
**Post-MVP Scope Approved**: [ ] Yes [ ] No  
**Cut Features Approved**: [ ] Yes [ ] No

**Team Notes**:
- [Add team feedback here]

---

**Status**: Ready for team review and approval. Scope can be adjusted based on team discussion and game jam timeline.
