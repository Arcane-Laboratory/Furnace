# Resolved Questions from iteration.md

This document tracks decisions made on questions from `iteration-unanswered-questions.md`.

## Core Gameplay Questions

### 1. Difficulty & Scaling

**Question 1.1**: Should we implement the proposed auto-scaling mode with heat increases and randomized waves?

**Decision**: **POST-MVP** - Yes, but defer to post-MVP phase.

**Rationale**: 
- Adds significant complexity to the game system
- Should address core balance issues (fireball damage/buff system) first
- Can be designed after core gameplay loop is proven fun
- Provides a good foundation for endless mode feature

**Status**: ✅ Resolved

---

**Question 1.2**: What is the exact implementation of the "heat increases" mechanic?

**Decision**: **DEFERRED** - Will be designed during post-MVP phase when auto-scaling mode is implemented.

**Status**: ⏳ Deferred (depends on Question 1.1)

---

### 2. Fireball Damage & Buff System

**Question 2.1**: Should acceleration runes grant damage bonuses in addition to speed?

**Decision**: **Option B** - Separate rune that grants stacking damage bonus (speed vs power choice).

**Rationale**:
- Provides clearer strategic choice between speed and power
- Better supports the "buff zone" strategy differentiation
- Allows players to optimize for speed vs damage based on situation
- Keeps acceleration rune focused on its core mechanic

**Implementation Notes**:
- Need to design new damage-buffing rune type
- Both runes should lose stacks when fireball hits enemies
- Creates interesting optimization problem: more frequent refreshes vs more stacks

**Status**: ✅ Resolved

---

**Question 2.2**: How many stacks should be lost when fireball hits an enemy?

**Decision**: **Option A** - Fixed amount per hit.

**Rationale**:
- Predictable and easy to understand
- Creates meaningful strategic choices without being too punishing
- Allows players to plan buff zone strategies with known mechanics
- Consistent behavior across all enemy types

**Implementation Notes**:
- **1 stack lost per enemy hit** (both acceleration and damage stacks)
- Should apply to both acceleration stacks and damage stacks
- Creates interesting optimization: more frequent refreshes vs more stacks before unleashing
- If fireball hits multiple enemies in one pass, loses 1 stack per enemy hit

**Status**: ✅ Resolved

---

**Question 2.3**: Should acceleration stacks be uncapped?

**Decision**: **Option B** - Keep a cap, but increase it significantly.

**Rationale**:
- Maintains performance safety (very high speeds could cause issues)
- Prevents potential exploits while allowing more strategic depth
- Supports buff zone strategy better than current low cap
- Can be tuned through playtesting

**Implementation Notes**:
- **Increase acceleration max speed cap by 10x**: Current `fireball_max_speed = 500.0` → New `fireball_max_speed = 5000.0`
- Should be high enough that players can meaningfully stack acceleration
- Consider making cap visible to players (UI indicator?)
- Damage-buffing rune should also have a cap (separate or shared?)
- Update `GameConfig.fireball_max_speed` value

**Status**: ✅ Resolved

---

### 3. Enemy Scrap/Drops System

**Question 3.1**: Should enemies drop scrap/resources during active phase?

**Decision**: **POST-MVP** - Yes, but defer to post-MVP phase.

**Rationale**:
- Adds significant complexity to active phase gameplay
- Requires new UI/UX for mid-wave building
- Changes resource economy and balance
- Should validate core gameplay loop first before adding this layer
- Can address "lack of investment" concern after core loop is proven

**Status**: ✅ Resolved

---

**Question 3.2**: If scrap is implemented, what can players build with it during active phase?

**Decision**: **DEFERRED** - Will be designed during post-MVP phase when scrap system is implemented.

**Status**: ⏳ Deferred (depends on Question 3.1)

---

**Question 3.3**: Should tile upgrades be enabled if scrap system is implemented?

**Decision**: **DEFERRED** - Will be designed during post-MVP phase. Upgrades can reduce/remove cooldowns on runes.

**Status**: ⏳ Deferred (depends on Question 3.1)

---

### 4. Rune Balance & Design

**Question 4.1**: What should the exact cost difference be between one-use and multi-use runes?

**Decision**: **MAJOR DESIGN CHANGE** - Make all runes multi-use. Post-MVP, add cooldowns to some runes that can be reduced/removed via upgrades.

**Rationale**:
- Simplifies rune system and removes one-use vs multi-use pricing complexity
- All runes become reusable, addressing "lack of build diversity" concern
- Cooldowns (post-MVP) provide balance mechanism instead of one-use limitation
- Upgrades (post-MVP) can reduce/remove cooldowns, creating progression

**Implementation Notes**:
- **MVP Changes Required**:
  - Explosive rune: Change from one-use to multi-use (can explode multiple times)
  - Reflect rune: Change from limited uses to infinite uses (or very high use count)
  - All runes should be reusable
- **Post-MVP**: Add cooldown system to some runes (e.g., explosive, reflect)
- **Post-MVP**: Upgrade system can reduce/remove cooldowns
- Rune costs should be balanced based on power/utility, not use count

**Status**: ✅ Resolved

---

**Question 4.2**: Should reflect rune be cheaper, more versatile, or have more uses?

**Decision**: **RESOLVED** - Reflect rune will be multi-use (infinite uses), addressing the "only works once" concern. Cost and versatility can be balanced separately.

**Status**: ✅ Resolved (part of Question 4.1)

---

**Question 4.3**: Should explosive rune be cheaper or more impactful?

**Decision**: **RESOLVED** - Explosive rune will be multi-use, so it can be used multiple times. Cost and impact can be balanced based on power, not use count.

**Status**: ✅ Resolved (part of Question 4.1)

---

**Question 4.4**: What should the acceleration rune speed increase amount be?

**Decision**: **DEFER TO PLAYTESTING** - Keep current value (`acceleration_speed_increase = 50.0`) for now, tune based on playtesting with new cap of 5000.0.

**Rationale**:
- With cap of 5000.0 and increase of 50.0, players need 100 acceleration runes to hit cap
- Need to test if this feels balanced in actual gameplay
- Can adjust based on player feedback and strategy viability

**Status**: ✅ Resolved (deferred to playtesting)

---

**Question 4.5**: Should acceleration rune have a fall-off mechanism?

**Decision**: **Option C** - No additional fall-off mechanism. Enemy-hit-based loss (1 stack per hit) is sufficient.

**Rationale**:
- Already have stack loss on enemy hit (1 stack per enemy hit)
- Additional time-based or distance-based fall-off would be too punishing
- Would complicate buff zone strategy unnecessarily
- Keeps mechanics simple and predictable
- Players can plan strategies knowing stacks only decrease on enemy hits

**Status**: ✅ Resolved

---

## Strategy & Build Diversity Questions

### 6. Maze Strategy Implementation

**Question 6.1**: Should AOE damage tiles be implemented as walls or ground tiles?

**Decision**: **Option A** - AOE tiles act as walls (block enemy movement, can't place runes on them).

**Rationale**:
- More strategic placement options
- Don't conflict with rune placement (walls and runes are separate tile occupancy)
- Supports maze strategy better by creating chokepoints
- Aligns with document recommendation

**Implementation Notes**:
- AOE damage tiles will be wall-type structures
- Block enemy pathfinding (like regular walls)
- Cannot place runes on AOE tile tiles
- Need to differentiate from regular walls visually and functionally

**Status**: ✅ Resolved

---

**Question 6.2**: What should the AOE damage tile be called and how should it work?

**Decision**: **"Explosive Wall"** - New wall-type structure with specific mechanics.

**Rationale**:
- Differentiates from explosive rune (which is a ground tile)
- Clear naming that communicates function
- Supports maze strategy as a wall-type structure

**Implementation Notes**:
- **Asset**: New asset needed for explosive wall (reuse explosive tile asset for damage-buffing rune instead)
- **Trigger**: Activates when fireball passes directly adjacent to it (not on it, since it's a wall)
- **Damage Area**: Deals damage in 8 surrounding squares (3x3 area centered on the wall)
- **Post-MVP**: Will have cooldown when cooldown system is implemented
- **Placement**: Acts as wall (blocks enemy movement, can't place runes on it)
- **Differentiation**: 
  - Explosive Rune: Ground tile, explodes when fireball passes over it, one-time use → now multi-use
  - Explosive Wall: Wall tile, explodes when fireball passes adjacent, affects 8 surrounding tiles

**Status**: ✅ Resolved

---

**Question 6.3**: Should AOE slow tiles be implemented?

**Decision**: **Option A** - Yes, implement slowing runes for MVP.

**Rationale**:
- Complements explosive walls in maze strategy
- Adds strategic depth and build diversity
- Supports the three-strategy approach (kill zone, buff zone, maze)

**Implementation Notes**:
- **Type**: Floor/ground tile (not wall)
- **Name**: "Mud Tile"
- **Mechanics**: Constant effect - slows enemies that are on top of it by 50%
- **Placement**: Can be placed on ground tiles (like runes)
- **Effect**: Enemies walking over mud tiles move at 50% speed while on the tile
- **Strategy**: Works with explosive walls for maze strategy - slow enemies in maze, damage them with explosive walls

**Status**: ✅ Resolved

---

## Level Design Questions

### 7. Level Design Priorities

**Question 7.1**: What are the "1 to 3 basic interactions" that should be identified?

**Decision**: **ALREADY COMPLETED** - Tutorial design is completed and does not need to be part of this work.

**Status**: ✅ Resolved (already handled)

---

**Question 7.2**: What defines a "challenging" level for each interaction?

**Decision**: **DEFERRED** - Ignore level design work for now, stay focused on systems and content iteration/implementation.

**Status**: ⏳ Deferred

---

**Question 7.3**: Should levels have more initial tiles set?

**Decision**: **DEFERRED** - Ignore level design work for now, stay focused on systems and content iteration/implementation.

**Status**: ⏳ Deferred

---

**Question 8.1**: Should there be a level select screen in MVP?

**Decision**: **DEFERRED** - Ignore level design work for now, stay focused on systems and content iteration/implementation.

**Status**: ⏳ Deferred

---

**Question 8.2**: What should the "game victory card" show when all levels are cleared?

**Decision**: **DEFERRED** - Ignore level design work for now, stay focused on systems and content iteration/implementation.

**Status**: ⏳ Deferred

---

## Asset & Polish Questions

### 9. Asset Integration Priorities

**Question 9.1**: Which assets should be integrated first?

**Decision**: **Option C** - Defer to current implementation needs.

**Rationale**:
- Focus on systems and content iteration
- Integrate assets as needed for features being implemented
- Prioritize based on what's needed for current work

**Status**: ✅ Resolved

---

**Question 9.2**: Are all required assets available or do some need to be created?

**Decision**: **DEFERRED** - Will be determined as implementation needs arise.

**Status**: ⏳ Deferred

---

### 10. Effects & Polish Priorities

**Question 10.1**: Which effects should be implemented first?

**Decision**: **Option A** - Follow the sound effects plan (already prioritized in `.cursor/plans/sound-effects-integration.plan.md`).

**Rationale**:
- Sound effects integration plan already exists and is prioritized
- Follow the implementation order defined in the plan
- Visual effects can be added after sound effects are working

**Status**: ✅ Resolved

---

**Question 10.2**: Should visual effects or sound effects be prioritized?

**Decision**: **RESOLVED** - Sound effects first (per Question 10.1), then visual effects.

**Status**: ✅ Resolved

---

## Technical & Implementation Questions

### 11. Debug Mode

**Question 11.1**: How should debug mode be disabled on export?

**Decision**: **Option B** - Config file check (read from config, default to false).

**Rationale**:
- Allows override for testing when needed
- Defaults to false for production builds
- Can be version controlled or excluded from builds
- More flexible than hardcoded values

**Implementation Notes**:
- Change `GameConfig.debug_mode` to read from config file
- Default to `false` if config file doesn't exist or doesn't specify
- Config file can be gitignored for local testing
- Consider using Godot's project settings or a separate config file

**Status**: ✅ Resolved

---

### 12. Tile Upgrade System

**Question 12.1**: When should tile upgrades be re-enabled?

**Decision**: **Option B** - Post-MVP. Keep disabled for MVP.

**Rationale**:
- Major gameplay changes are being made (multi-use runes, damage-buffing rune, etc.)
- Need to finalize core gameplay balance first
- Upgrades add complexity that should come after core loop is proven
- Post-MVP upgrades can reduce/remove cooldowns (as decided in Question 4.1)

**Status**: ✅ Resolved

---

**Question 12.2**: What upgrade options should exist for each rune type?

**Decision**: **POST-MVP** - Will be designed during post-MVP phase when upgrade system is re-enabled.

**Status**: ⏳ Deferred (depends on Question 12.1)

---

## Strategic Direction Questions

### 13. Core Gameplay Loop

**Question 13.1**: Is the current "one level = one wave" structure final, or should it change?

**Decision**: **Option C** - Post-MVP. Keep one level = one wave for MVP, consider multi-wave levels post-MVP.

**Rationale**:
- Focus on systems and content iteration first
- Current structure is acceptable for MVP
- Can address "lack of investment" concern post-MVP if it persists
- Multi-wave levels can be designed after core gameplay is proven

**Status**: ✅ Resolved

---

**Question 13.2**: Should levels have multiple waves?

**Decision**: **POST-MVP** - Will be considered during post-MVP phase if investment concern persists.

**Status**: ⏳ Deferred (depends on Question 13.1)

---

### 14. Player Information & Anticipation

**Question 14.1**: What information should players see about incoming enemies?

**Decision**: **Option D** - Post-MVP. Defer UI improvements.

**Rationale**:
- Focus on systems and content iteration first
- UI improvements can come after core gameplay is proven
- Enemy information display is polish, not core functionality

**Status**: ✅ Resolved

---

**Question 14.2**: When should enemy information be shown? (Build phase? Always visible? On hover?)

**Decision**: **POST-MVP** - Will be designed during post-MVP phase when enemy information UI is implemented.

**Status**: ⏳ Deferred (depends on Question 14.1)

---

## Kevin's Strategy Questions

### 15. Buff Zone Strategy Details

**Question 15.1**: Should there be a separate damage-buffing rune, or should acceleration grant damage?

**Decision**: **ALREADY RESOLVED** - This was resolved in Question 2.1. We chose separate damage-buffing rune.

**Status**: ✅ Resolved (see Question 2.1)

---

**Question 15.2**: If separate damage rune exists, what should it be called and how should it work?

**Decision**: **"Power Rune"** - Grants a stacking damage bonus.

**Rationale**:
- Clear, simple name that communicates function
- Stacking damage bonus mirrors acceleration rune's stacking speed bonus
- Creates parallel mechanics: speed vs power choice

**Implementation Notes**:
- **Name**: "Power Rune"
- **Type**: Ground tile (like other runes)
- **Mechanics**: Grants stacking damage bonus (like acceleration grants stacking speed)
- **Asset**: Reuse explosive tile asset (new asset needed for explosive wall)
- **Stack Loss**: Loses 1 stack per enemy hit (same as acceleration)
- **Cap**: Should have a cap (TBD - similar to acceleration cap increase)
- **Cost**: TBD - balance based on power/utility

**Status**: ✅ Resolved

---

### 16. Kill Zone Strategy

**Question 16.1**: Is the current kill zone strategy sufficient, or does it need changes?

**Decision**: **Option A** - Yes, kill zone strategy is working, no changes needed.

**Rationale**:
- Current kill zone strategy is functional
- Changes to other systems (multi-use runes, power rune) may enhance it naturally
- No specific issues identified that need addressing

**Status**: ✅ Resolved

---

## Priority & Sequencing Questions

### 17. Implementation Order

**Question 17.1**: What is the priority order for the "Key To Dos"?

**Decision**: **CONFIRMED PRIORITY ORDER**:

1. **Core rune system changes** (multi-use runes, Power Rune)
2. **New wall/tile types** (Explosive Wall, Mud Tile)
3. **Sound effects integration** (per existing plan)
4. **Debug mode config** (config file implementation)
5. **Asset integration** (as needed)

**Implementation Notes for Priority 1 (Core Rune System Changes)**:
- Make all runes multi-use (explosive, reflect)
- Implement Power Rune (stacking damage bonus)
- **Add status modifiers to fireball for speed and power stacks**
- **Status modifiers should include SFX and VFX**
- **VFX**: Start with text display reusing damage number system
- **Future**: Add bespoke VFX for status modifiers later
- Update acceleration cap (500 → 5000)
- Implement stack loss on enemy hit (1 stack per hit for both speed and power)

**Status**: ✅ Resolved

---

**Question 17.2**: Should some items be done in parallel or sequentially?

**Decision**: **SEQUENTIAL** - Follow the priority order. Some items can be done in parallel if they don't conflict (e.g., asset integration can happen alongside system implementation).

**Status**: ✅ Resolved

---
