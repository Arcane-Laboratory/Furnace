# Furnace - GDD & Plans Audit & Next Steps

## Executive Summary

After auditing the GDD, scope documents, implementation plans, and current codebase, here's the current state and recommended next steps.

## Current Implementation Status

### ✅ Fully Implemented Systems
1. **Core Infrastructure**
   - Tile system (TileManager, grid, terrain types)
   - Fireball system (movement, activation, collision)
   - All 6 rune types (scripts exist: Redirect, Advanced Redirect, Portal, Explosive, Reflect, Acceleration)
   - Enemy system (EnemyBase, BasicEnemy, EnemyManager, PathfindingManager)
   - Placement manager (drag-and-drop, validation)
   - Build submenu UI
   - Phase management (Build/Active phase switching)
   - Level data structure (LevelData resource)

2. **UI Systems**
   - All menu scenes (Title, Main Menu, Game Over, Pause)
   - Build phase UI panel
   - Active phase UI panel
   - Resource display
   - Path preview system

### ❌ Critical Missing Systems (Blocking Playability)

1. **Furnace System** (CRITICAL)
   - No furnace scene (`scenes/entities/furnace.tscn`)
   - No furnace script (`scripts/entities/furnace.gd`)
   - Impact: Fireball has no launch point, enemies have no target, no win/lose condition
   - Priority: **HIGHEST** - Blocks core gameplay loop

2. **Wall System** (CRITICAL)
   - No wall scene (`scenes/entities/wall.tscn`)
   - No wall script (`scripts/entities/wall.gd`)
   - Impact: Cannot place walls, no strategic path manipulation
   - Priority: **HIGH** - Core gameplay mechanic

3. **Level Loading/Integration** (HIGH)
   - LevelData resource exists but not integrated
   - No level progression system
   - Cannot load actual level configurations
   - Impact: Game cannot progress through levels
   - Priority: **HIGH** - Needed for playable game

### 🟡 Partially Implemented

1. **Selling System**
   - Placement manager has sell signals
   - Tile tooltip exists
   - May need integration testing

2. **Additional Enemy Types**
   - Fast Enemy and Tank Enemy may need implementation
   - Basic Enemy exists

## Recommended Next Steps (Priority Order)

### Phase 1: Critical Gameplay Blockers (Do First)

#### Step 1: Implement Furnace System
**Why**: Without a furnace, the game cannot function. It's the fireball launch point, enemy target, and win/lose condition.

**Tasks**:
1. Create `scenes/entities/furnace.tscn`
   - Area2D node for enemy collision detection
   - Sprite2D for visual representation
   - Marker2D for fireball spawn point
   - CollisionShape2D for enemy detection
2. Create `scripts/entities/furnace.gd`
   - Extends Area2D
   - 1 HP (instant destruction on enemy contact)
   - Signal: `destroyed` (emitted when enemy touches)
   - Function: `_on_enemy_entered()` to trigger game over
   - Fixed position at top center of grid
3. Integrate with game_scene.gd
   - Spawn furnace at level start
   - Connect fireball launch to furnace position
   - Connect enemy collision to furnace
   - Update `_launch_fireball()` to use furnace position

**Estimated Impact**: Unblocks fireball launch, enemy targeting, and win/lose conditions.

#### Step 2: Implement Wall System
**Why**: Walls are a core strategic element. Players need them to manipulate enemy paths.

**Tasks**:
1. Create `scenes/entities/wall.tscn`
   - StaticBody2D node
   - Sprite2D for visual
   - CollisionShape2D (tile-sized, blocks pathfinding)
2. Create `scripts/entities/wall.gd`
   - Extends StaticBody2D
   - Grid position tracking
   - Cost property (from GameConfig)
   - `is_initial_element` flag (non-sellable)
   - Integration with TileManager for occupancy
3. Integrate with placement system
   - Add wall to build submenu
   - Add wall placement validation
   - Register walls in pathfinding as obstacles
   - Add wall to selling system

**Estimated Impact**: Enables strategic path manipulation, core gameplay mechanic.

#### Step 3: Level Loading Integration
**Why**: Need to actually load and play levels. Currently LevelData exists but isn't used.

**Tasks**:
1. Create/update LevelManager autoload
   - Load LevelData resources
   - Initialize level (place initial walls/runes)
   - Set resources from level data
   - Register spawn points
   - Set up enemy wave
2. Integrate with game_scene.gd
   - Load level on scene start
   - Place initial elements (walls/runes from level data)
   - Initialize pathfinding with level data
   - Set up enemy spawning from level data
3. Create level progression
   - Track current level
   - Unlock next level on completion
   - Load next level on victory

**Estimated Impact**: Makes the game actually playable with real levels.

### Phase 2: Gameplay Completion (After Blockers)

#### Step 4: Verify & Complete Selling System
- Test tile tooltip integration
- Verify sell functionality works
- Ensure refunds work correctly
- Test with all item types (walls, runes)

#### Step 5: Additional Enemy Types
- Implement Fast Enemy (if not done)
- Implement Tank Enemy (if not done)
- Test enemy spawning with different types

#### Step 6: Level Design & Testing
- Create Level 1 (Tutorial) resource
- Create Level 2 (Challenge) resource  
- Create Level 3 (Final) resource
- Test level progression
- Balance resources and difficulty

### Phase 3: Polish (After Core Gameplay Works)

#### Step 7: Visual Effects
- Rune activation effects
- Explosion effects (Explosive Rune)
- Fireball trail effects
- Enemy death effects

#### Step 8: Sound Effects
- Rune activation sounds
- Enemy death sounds
- Fireball travel sound
- Structure placement sounds
- Level complete/fail sounds

#### Step 9: Performance & Balance
- Performance optimization pass
- Balance testing
- Difficulty tuning
- Bug fixes

## Implementation Notes

### Architecture Observations
- The codebase has evolved beyond the original plans
- All 6 rune types are implemented (plans said only Redirect existed)
- Enemy system is more complete than plans indicated
- Placement manager exists and is functional
- Some systems are more integrated than planned (acceptable for MVP)

### Key Dependencies
1. Furnace → Fireball launch → Active phase functionality
2. Walls → Path manipulation → Strategic gameplay
3. Level loading → Actual gameplay → Playable game

### Risk Assessment
- **Low Risk**: Rune system, enemy system, placement system (already implemented)
- **Medium Risk**: Level loading integration (needs careful testing)
- **High Risk**: None identified - missing systems are straightforward implementations

## Success Criteria

### Minimum Playable Game
- [ ] Furnace exists and functions (launch point, target, win/lose)
- [ ] Walls can be placed and affect pathfinding
- [ ] At least one level loads and is playable
- [ ] Fireball launches from furnace
- [ ] Enemies spawn and pathfind to furnace
- [ ] Game can be won (all enemies defeated)
- [ ] Game can be lost (enemy reaches furnace)

### Complete MVP
- [ ] All 3 levels load and are playable
- [ ] All rune types functional
- [ ] Wall placement and selling works
- [ ] Level progression works
- [ ] Basic visual feedback exists
- [ ] Basic sound effects exist

## Recommended Action Plan

**Immediate Next Step**: Implement Furnace System
- This is the single biggest blocker
- Relatively straightforward implementation
- Unlocks multiple gameplay systems
- Estimated time: 2-4 hours

**After Furnace**: Implement Wall System
- Core gameplay mechanic
- Well-defined requirements
- Estimated time: 2-3 hours

**After Walls**: Level Loading Integration
- Makes game playable
- Requires careful testing
- Estimated time: 3-5 hours

**Total Estimated Time to Playable**: 7-12 hours of focused development

## Conclusion

The game is surprisingly close to playable. The core systems (runes, enemies, fireball, placement) are implemented. The main blockers are:
1. Furnace (critical - no game without it)
2. Walls (critical - core mechanic)
3. Level loading (high - needed for actual gameplay)

Once these three systems are implemented, the game should be playable end-to-end. Polish can happen after core gameplay is functional.
