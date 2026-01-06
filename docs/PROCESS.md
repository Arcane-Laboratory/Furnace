# Furnace - Development Process Overview

**Project**: Furnace (Blast Deck)  
**Duration**: ~3 days (January 2-4, 2026)  
**Total Commits**: 339  
**Team**: Arcane Laboratory

---

## Overview

This document provides a detailed breakdown of the development phases, key steps, challenges, and takeaways for each phase of the Furnace project. This serves as a reference for understanding the development timeline and process decisions.

---

## Phase 0: Initial Scaffold

**Timeline**: Day 1 Morning (January 2, 2026)  
**Status**: ✅ **Excellent Execution**  
**Plan Document**: `.cursor/plans/archive/initial_scaffold.plan.md`

### Key Steps

1. **Directory Structure Creation**
   - Created organized folder hierarchy (assets, scenes, scripts)
   - Separated UI scenes, game scenes, entity scenes
   - Set up autoload structure

2. **Autoload Managers**
   - Created `SceneManager` for scene transitions
   - Created `GameManager` for game state management
   - Created `GameConfig` for tunable parameters

3. **UI Scenes**
   - Title screen
   - Main menu
   - Game over screen
   - Pause menu

4. **Core Game Scene**
   - Basic game scene structure
   - Phase management foundation
   - Grid container setup

5. **Project Configuration**
   - Registered autoloads in `project.godot`
   - Set main scene
   - Added input actions

### What Went Well

- ✅ **Followed plan closely** - Initial scaffold plan was excellent and executed precisely
- ✅ **Clean architecture** - Good separation of concerns from the start
- ✅ **Foundation for everything** - All later systems built on this scaffold
- ✅ **Fast execution** - Completed quickly, didn't overthink

### Challenges

- None significant - this phase went smoothly

### Takeaways

- **Good planning pays off** - The scaffold plan was thorough and well-executed
- **Start with structure** - Having the right folder structure and autoloads early made everything easier
- **Don't overthink scaffolding** - Get the basics right, iterate later

### Metrics

- **Time**: ~2-3 hours
- **Files Created**: ~15 files
- **Commits**: ~10-15 commits
- **Success Rate**: 100% (all planned tasks completed)

---

## Phase 1: Tile System Foundation

**Timeline**: Day 1 (January 2, 2026)  
**Status**: ✅ **Solid Foundation**  
**Plan Document**: `.cursor/plans/archive/tile-system-scaffold.plan.md`

### Key Steps

1. **TileBase Class**
   - Created base tile class with terrain types
   - Occupancy tracking system
   - Visual state management

2. **TileManager Autoload**
   - Dictionary-based grid state tracking
   - Fast lookup methods
   - Integration with LevelData

3. **Terrain Types**
   - Open terrain (buildable, crossable)
   - Rock terrain (unbuildable, blocks movement)
   - Spawn point markers

4. **Visual System**
   - ColorRect-based placeholders
   - Highlight system for buildable/invalid tiles
   - Overlay system for state indicators

5. **Integration Points**
   - Prepared for pathfinding integration
   - Prepared for level data loading
   - Prepared for build validation

### What Went Well

- ✅ **Solid foundation** - Tile system became the backbone for everything
- ✅ **Fast queries** - Dictionary-based lookups were performant
- ✅ **Extensible** - Easy to add new terrain types later
- ✅ **Clear separation** - Tile logic separated from game logic

### Challenges

- Minor: Visual placeholders needed replacement later (expected)

### Takeaways

- **Foundation systems matter** - Tile system enabled everything else
- **Dictionary lookups are fast** - Grid state tracking was efficient
- **Placeholders are fine** - Visual polish can come later

### Metrics

- **Time**: ~3-4 hours
- **Files Created**: ~8 files
- **Commits**: ~15-20 commits
- **Success Rate**: 100% (all planned tasks completed)

---

## Phase 2: Core Entities

**Timeline**: Day 1-2 (January 2-3, 2026)  
**Status**: 🟡 **Partial Implementation**  
**Plan Documents**: 
- `.cursor/plans/archive/fireball_system_implementation.plan.md`
- `.cursor/plans/archive/fireball_rune_interactions.plan.md`

### Key Steps

1. **Fireball System** ✅
   - Fireball scene and script
   - Movement system (cardinal directions)
   - Tile activation detection
   - Rune activation logic
   - Enemy hit detection
   - Boundary collision (bouncing)

2. **Rune System** ✅
   - RuneBase class with consistent interface
   - Redirect Rune implementation
   - Activation system
   - Uses tracking

3. **Wall System** ❌
   - Not implemented in this phase
   - Added later as blocker

4. **Furnace System** ❌
   - Not implemented in this phase
   - Added later as blocker

5. **Additional Rune Types** 🟡
   - Only Redirect Rune implemented
   - Other runes added incrementally later

### What Went Well

- ✅ **Fireball system** - Core mechanic worked well
- ✅ **Rune architecture** - Modular design made adding runes easy
- ✅ **Activation system** - Consistent pattern across all runes

### Challenges

- ⚠️ **Missing critical systems** - Wall and Furnace not implemented, became blockers
- ⚠️ **Incomplete rune set** - Only one rune type initially
- ⚠️ **Integration gaps** - Systems built in isolation, not fully integrated

### Takeaways

- **Build critical systems first** - Walls and Furnace should have been priority
- **One rune is enough to start** - But need all types eventually
- **Integration matters** - Systems need to work together, not just individually

### Metrics

- **Time**: ~6-8 hours
- **Files Created**: ~10 files
- **Commits**: ~40-50 commits
- **Success Rate**: ~60% (fireball and rune base worked, but missing critical systems)

---

## Phase 3: Enemy System & Pathfinding

**Timeline**: Day 2 (January 3, 2026)  
**Status**: ✅ **Complete**  
**Plan Documents**: 
- `.cursor/plans/archive/enemy-spawning-system.plan.md`
- `.cursor/plans/archive/pathfinding-implementation.plan.md`

### Key Steps

1. **EnemyBase Class**
   - Base enemy class with health, speed, movement
   - Pathfinding integration
   - Damage and death systems

2. **Enemy Types**
   - Basic Enemy implementation
   - Fast Enemy (added later)
   - Tank Enemy (added later)

3. **EnemyManager Autoload**
   - Spawn point management
   - Staggered spawning system
   - Enemy tracking and cleanup

4. **PathfindingManager Autoload**
   - A* pathfinding algorithm
   - Grid-based path calculation
   - Path validation

5. **Path Visualization**
   - Dotted line overlay
   - Arrow indicators
   - On-demand preview

### What Went Well

- ✅ **Pathfinding worked well** - A* algorithm was efficient
- ✅ **Enemy spawning** - Staggered spawning system was flexible
- ✅ **Modular design** - Easy to add new enemy types
- ✅ **Performance** - Handled 100+ enemies smoothly

### Challenges

- Minor: Path visualization needed polish (expected)

### Takeaways

- **A* pathfinding is reliable** - Grid-based A* worked perfectly
- **Staggered spawning is flexible** - Easy to tune difficulty
- **Performance targets matter** - Setting targets upfront helped

### Metrics

- **Time**: ~4-5 hours
- **Files Created**: ~8 files
- **Commits**: ~30-40 commits
- **Success Rate**: 95% (complete implementation)

---

## Phase 4: Systems Integration

**Timeline**: Day 2 (January 3, 2026)  
**Status**: 🟡 **Partial Integration**  
**Plan Document**: `.cursor/plans/archive/systems-integration.plan.md`

### Key Steps

1. **Placement System** ✅
   - Drag-and-drop placement
   - Build menu integration
   - Validation system

2. **Resource System** ✅
   - Resource tracking in GameManager
   - Cost validation
   - Resource display UI

3. **Level Loading** 🟡
   - LevelData resource structure created
   - Partial level loading
   - Not fully integrated until later

4. **Phase Management** ✅
   - Build phase / Active phase switching
   - UI state management
   - Phase validation

5. **Selling System** 🟡
   - Partial implementation
   - Completed later

### What Went Well

- ✅ **Placement system** - Drag-and-drop worked well
- ✅ **Phase management** - Clean state machine
- ✅ **Resource system** - Simple and effective

### Challenges

- ⚠️ **Level loading incomplete** - LevelData existed but not fully used
- ⚠️ **Integration gaps** - Systems worked individually but not fully together
- ⚠️ **Missing features** - Selling system incomplete

### Takeaways

- **Integration takes time** - Building systems is easier than integrating them
- **Resource system simplicity** - Single currency was sufficient
- **Phase management** - Clear state machine prevented bugs

### Metrics

- **Time**: ~4-5 hours
- **Files Modified**: ~15 files
- **Commits**: ~30-40 commits
- **Success Rate**: ~70% (core systems integrated, but gaps remained)

---

## Phase 5: Gameplay Systems Refactor

**Timeline**: Day 2-3 (January 3-4, 2026)  
**Status**: ⚠️ **Major Refactor, Time-Consuming**  
**Plan Document**: `.cursor/plans/gameplay-systems-implementation.plan.md`  
**Trigger**: Mid-development iteration review (`iteration.md`)

### Key Steps

1. **Iteration Review** ⚠️
   - Identified "lack of build diversity"
   - Identified "lack of difficulty"
   - Identified "lack of investment"

2. **Question Resolution** ⚠️
   - 40+ unanswered questions cataloged
   - 18 major questions resolved
   - Many questions deferred to post-MVP

3. **Rune System Refactor** ⚠️
   - Changed from one-use to multi-use runes
   - Updated all rune types
   - Major code changes

4. **Stacking Systems** ⚠️
   - Implemented speed stacking for Acceleration Rune
   - Implemented power stacking for Power Rune
   - Updated fireball to handle stacks

5. **New Features Added** ⚠️
   - Power Rune (new rune type)
   - Explosive Wall (new wall type)
   - Mud Tile (new tile type)
   - Status modifier VFX

6. **Balance Changes** ⚠️
   - Increased acceleration cap (500 → 5000)
   - Updated costs and damage values
   - Rebalanced all rune types

### What Went Well

- ✅ **Identified real problems** - Iteration review was valuable
- ✅ **Systematic resolution** - Question resolution process was thorough
- ✅ **Improved gameplay** - Changes made game more fun

### Challenges

- ⚠️ **Came too late** - Should have happened after first playable, not mid-development
- ⚠️ **Major refactor** - Required rewriting core systems
- ⚠️ **Time-consuming** - Took ~15-20% of total development time
- ⚠️ **Scope creep** - Added features not in original MVP

### Takeaways

- **Iteration reviews are valuable** - But timing matters (after first playable, not mid-dev)
- **Refactoring is expensive** - Better to validate design before building
- **Question resolution should be early** - Don't defer 40+ questions
- **Scope discipline** - Say "no" to features not in MVP

### Metrics

- **Time**: ~12-15 hours (15-20% of total time)
- **Files Modified**: ~25 files
- **Commits**: ~80-100 commits
- **Success Rate**: 80% (improvements made, but at high cost)

---

## Phase 6: Level Design & Content

**Timeline**: Day 3 (January 4, 2026)  
**Status**: ⚠️ **Happened Too Late**  
**Plan Document**: `docs/LEVELS.md`, `docs/brainstorm/LEVEL_DESIGN.md`

### Key Steps

1. **Level Creation** ⚠️
   - Created 10+ levels (original plan was 3)
   - Level 0 (Free Play) with ramping waves
   - Levels 1-10 with varying difficulty

2. **Level Balancing** ⚠️
   - Resource allocation per level
   - Enemy counts and types
   - Spawn point placement
   - Initial element placement

3. **Difficulty Tuning** ⚠️
   - Final difficulty tuning commits
   - Enemy health adjustments
   - Resource cost adjustments

4. **Level Testing** ⚠️
   - Playtesting levels
   - Fixing level-specific bugs
   - Portal linking fixes
   - Spawn point validation

### What Went Well

- ✅ **Level variety** - Created diverse level designs
- ✅ **Resource system** - Easy to tune per level
- ✅ **Level editor** - Resource-based system made creation fast

### Challenges

- ⚠️ **Happened too late** - Most level work on final day
- ⚠️ **Rushed** - Less time for iteration
- ⚠️ **Balance issues** - Some levels too easy/hard
- ⚠️ **Scope creep** - 10+ levels instead of 3

### Takeaways

- **Level design should be early** - Create placeholder levels as systems are built
- **Test levels continuously** - Don't wait until end
- **Iterate on level design** - Needs multiple passes
- **Stick to scope** - 3 levels was enough for MVP

### Metrics

- **Time**: ~6-8 hours (mostly Day 3)
- **Levels Created**: 10+ (planned: 3)
- **Commits**: ~40-50 commits
- **Success Rate**: 70% (levels created, but rushed)

---

## Phase 7: Polish, Bug Fixes & Export

**Timeline**: Day 3 (January 4, 2026)  
**Status**: 🟡 **Rushed, Incomplete**  
**Plan Documents**: 
- `.cursor/plans/sound-effects-integration.plan.md`
- Various bug fix PRs

### Key Steps

1. **Visual Polish** 🟡
   - Bloom shader effects
   - Screen shake effects
   - White flash on enemy hit
   - Health bar improvements
   - UI spacing fixes

2. **Sound Effects** ❌
   - Sound effects integration plan existed
   - Phase 3 never completed
   - Some sounds added, but incomplete

3. **Bug Fixes** ✅
   - Explosive wall bugs
   - Portal linking issues
   - Enemy removal on level loss
   - Z-index rendering issues
   - Tile stacking bugs

4. **Export & Build** ⚠️
   - Web build fixes
   - Debug mode configuration
   - Level detection fixes
   - UID warning fixes

5. **Mobile Support** 🟡
   - Input debouncing
   - UI adjustments
   - Partial implementation

### What Went Well

- ✅ **Bug fixes** - Many critical bugs fixed
- ✅ **Visual effects** - Some polish added
- ✅ **Export fixes** - Web build worked

### Challenges

- ⚠️ **Rushed** - Everything happened on final day
- ⚠️ **Incomplete** - Sound effects not finished
- ⚠️ **Time pressure** - Less time for thorough testing
- ⚠️ **Debug mode issues** - Multiple commits fixing debug mode in exports

### Takeaways

- **Polish takes time** - Should start earlier
- **Sound effects are important** - Should be integrated earlier
- **Test exports regularly** - Don't wait until end
- **Feature freeze early** - Stop adding features, focus on polish

### Metrics

- **Time**: ~8-10 hours (all Day 3)
- **Files Modified**: ~30 files
- **Commits**: ~60-80 commits
- **Success Rate**: 60% (bugs fixed, but polish incomplete)

---

## Phase Timeline Summary

```
Day 1 (Jan 2):
├── Morning: Phase 0 (Scaffold) ✅
├── Day: Phase 1 (Tile System) ✅
└── Evening: Phase 2 (Core Entities) 🟡

Day 2 (Jan 3):
├── Morning: Phase 3 (Enemy System) ✅
├── Day: Phase 4 (Systems Integration) 🟡
└── Evening: Phase 5 (Gameplay Refactor) ⚠️

Day 3 (Jan 4):
├── Morning: Phase 5 (Continued Refactor) ⚠️
├── Day: Phase 6 (Level Design) ⚠️
└── Evening: Phase 7 (Polish & Bug Fixes) 🟡
```

---

## Key Insights Across All Phases

### What Worked Well Across Phases

1. **Early phases were well-executed** - Phases 0-1 had excellent planning and execution
2. **Modular architecture** - Made refactoring possible in Phase 5
3. **Incremental PRs** - QA checkpoints prevented major issues
4. **Resource-based systems** - Made level design fast in Phase 6

### What Didn't Work Well Across Phases

1. **Phase sequencing** - Phases 5-7 happened simultaneously, causing time pressure
2. **Late iteration** - Phase 5 iteration review came too late
3. **Scope discipline** - Features added in Phases 5-6 not in original MVP
4. **Polish timing** - Phase 7 was rushed because earlier phases took longer

### Critical Path Analysis

**Blockers Identified**:
- Phase 2: Missing Wall and Furnace systems blocked gameplay
- Phase 4: Incomplete level loading blocked playability
- Phase 5: Major refactor consumed significant time
- Phase 6: Level design happened too late
- Phase 7: Polish rushed because of time pressure

**If We Could Reorder**:
1. Phase 0-1: Keep as-is (excellent)
2. Phase 2: Add Wall and Furnace first (critical blockers)
3. Phase 3: Keep as-is (excellent)
4. Phase 4: Complete level loading integration
5. **Iteration Review**: After first playable (not mid-development)
6. Phase 5: Only if iteration review identifies problems
7. Phase 6: Start level design earlier, parallel with systems
8. Phase 7: Start polish earlier, parallel with content

---

## Recommendations for Future Projects

### Phase Sequencing

1. **Foundation First** (Phases 0-1): ✅ Keep this approach
2. **Critical Systems First** (Phase 2): Build blockers first (Walls, Furnace)
3. **Integration Early** (Phase 4): Don't defer integration
4. **Iteration After First Playable**: Not mid-development
5. **Content Parallel** (Phase 6): Start level design as systems are built
6. **Polish Throughout** (Phase 7): Don't save all polish for end

### Phase Management

1. **Regular phase reviews** - Check progress at end of each phase
2. **Scope discipline** - Don't add features mid-phase
3. **Integration testing** - Test systems together as they're built
4. **Parallel work** - Content and polish can happen alongside systems

### Process Improvements

1. **First playable ASAP** - Get something playable in first 4-6 hours
2. **Iteration review early** - After first playable, not mid-development
3. **Question resolution** - Resolve critical questions before building
4. **Level design early** - Create placeholder levels as systems are built
5. **Polish throughout** - Don't save all polish for end

---

**Document Status**: Complete  
**Last Updated**: January 2026  
**Authors**: Arcane Laboratory Team
