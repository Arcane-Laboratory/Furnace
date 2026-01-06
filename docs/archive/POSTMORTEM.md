# Furnace - Development Postmortem

**Project**: Furnace (Blast Deck)  
**Duration**: ~3 days (January 2-4, 2026)  
**Total Commits**: 339  
**Team**: Arcane Laboratory  
**Context**: 3-day game jam with theme "Support" and prompt "One Shot"

---

## Executive Summary

Furnace was developed as a tower defense game where players build walls and runes, then watch a single fireball automatically launch and interact with those defenses to defeat waves of enemies. The project achieved a playable MVP with 10+ levels, all core rune types, and a complete gameplay loop. However, the development process revealed several areas where process improvements could have saved significant time and reduced friction.

**Key Achievement**: Delivered a complete, playable game in 3 days with complex systems (pathfinding, rune interactions, fireball physics, level progression).

**Key Challenge**: Iterative design decisions and scope changes consumed significant development cycles that could have been avoided with better upfront planning.

---

## Project Phases Overview

The development process can be divided into distinct phases, each with its own challenges, successes, and learnings. See `PROCESS_OVERVIEW.md` for detailed phase-by-phase breakdown.

### Quick Phase Summary

1. **Phase 0: Initial Scaffold** (Day 1 Morning) - ✅ Excellent execution
2. **Phase 1: Tile System Foundation** (Day 1) - ✅ Solid foundation
3. **Phase 2: Core Entities** (Day 1-2) - 🟡 Partial, some systems missing
4. **Phase 3: Enemy System & Pathfinding** (Day 2) - ✅ Complete
5. **Phase 4: Systems Integration** (Day 2) - 🟡 Partial integration
6. **Phase 5: Gameplay Systems Refactor** (Day 2-3) - ⚠️ Major refactor, time-consuming
7. **Phase 6: Level Design & Content** (Day 3) - ⚠️ Happened too late
8. **Phase 7: Polish & Bug Fixes** (Day 3) - 🟡 Rushed, incomplete

**Key Insight**: Phases 5-7 happened simultaneously and late, causing time pressure. Better sequencing would have helped.

---

## What Worked Well

### 1. **Comprehensive Documentation Upfront**
- **GDD (Game Design Document)** was thorough and well-structured
- **Scope document** clearly defined MVP vs post-MVP features
- **Architecture documentation** helped maintain consistency
- **Result**: Team had clear shared understanding of goals and constraints

### 2. **Centralized Configuration System**
- **GameConfig autoload** with all tunable parameters in one place
- **Developer Tunable Parameters document** made balancing straightforward
- **Result**: Easy to iterate on balance without hunting through code

### 3. **Modular Rune System Architecture**
- **RuneBase class** with clear inheritance pattern
- **Consistent activation pattern** (`_on_activate(fireball)`)
- **Result**: Adding new rune types was straightforward (6 rune types implemented)

### 4. **Resource-Based Level System**
- **LevelData resource** allowed designers to create levels without code
- **Scene-based entities** (runes, walls, enemies) made level composition easy
- **Result**: Level creation was fast and non-programmer-friendly

### 5. **Incremental PR Process**
- **Phased implementation** with QA checkpoints between phases
- **PR-based workflow** ensured stable main branch
- **Result**: Could roll back problematic changes easily, maintained code quality

### 6. **Clear Separation of Concerns**
- **Autoload singletons** (GameManager, GameConfig, TileManager, etc.)
- **Entity scripts** separated from game logic
- **UI scripts** isolated from gameplay
- **Result**: Code was maintainable and debuggable

### 7. **Early Performance Considerations**
- **Performance targets** defined upfront (100 enemies, 60 FPS)
- **Grid-based system** optimized for pathfinding
- **Result**: Game ran smoothly even with many enemies

---

## What Didn't Work Well

### 1. **Iterative Design Changes Mid-Development**

**Problem**: Major design decisions were made and changed during development:
- Rune use limits (one-use → multi-use) - **Major refactor**
- Acceleration rune mechanics (temporary boost → stacking system) - **System redesign**
- Power rune addition (new rune type mid-development) - **New feature scope**
- Explosive wall addition (new wall type) - **New feature scope**

**Impact**: 
- Multiple refactors of core systems
- Time spent on systems that were later changed
- ~20-30% of development time spent on redesigns

**Evidence**: 
- `iteration-resolutions.md` shows 18 major questions resolved mid-development
- `mid-development-check-in.md` (iteration.md) identified "lack of build diversity" requiring system changes
- `iteration-unanswered-questions.md` shows 40+ questions that needed resolution mid-development
- Multiple commits show refactoring work (stacking systems, multi-use runes)

**Root Cause**: 
- Core gameplay loop wasn't playtested early enough
- Design decisions were made in isolation without validating fun factor
- The mid-development iteration (`iteration.md`) correctly identified problems, but it came too late

**What We'd Do Differently**: 
- More thorough playtesting of core mechanics before full implementation
- Design review sessions earlier in development
- Prototype core loop faster to validate design before building full systems
- Run iteration review after first playable, not mid-development

### 2. **Scope Creep Despite Clear Scope Document**

**Problem**: Despite having a clear scope document, features were added mid-development:
- Power Rune (not in original MVP)
- Explosive Wall (not in original MVP)
- Mud Tile (not in original MVP)
- Status modifier VFX system
- Upgrade system (partially implemented, then disabled)

**Impact**: 
- Original MVP scope was ~3 levels, ended with 10+ levels
- Features added that weren't essential for MVP
- Time pressure increased near deadline

**Evidence**:
- `scope.md` clearly defines MVP as 3 levels, 6 rune types
- `IMPLEMENTATION_STATUS.md` shows Power Rune, Explosive Wall, Mud Tile as "Phase 1 & 2" additions
- Git history shows these features added mid-development

**What We'd Do Differently**: 
- Stricter adherence to MVP scope
- "Nice to have" backlog separate from MVP work
- Regular scope reviews to catch creep early

### 3. **Incomplete Planning Before Implementation**

**Problem**: Some systems were implemented before all edge cases were considered:
- Portal rune pairing (automatic vs manual) - **Changed mid-development**
- Rune use limits (one-use vs multi-use) - **Changed mid-development**
- Fireball stacking mechanics - **Redesigned mid-development**
- **40+ unanswered questions** identified mid-development (`iteration-unanswered-questions.md`)

**Impact**: 
- Refactoring work required
- Bugs introduced by incomplete implementations
- Time spent fixing edge cases that should have been planned
- Major design questions deferred until they became blockers

**Evidence**:
- `iteration-resolutions.md` shows many "DEFERRED" decisions that should have been made upfront
- `iteration-unanswered-questions.md` catalogs 40+ questions across 18 categories
- Multiple "fix" commits related to systems that weren't fully planned
- Questions about core mechanics (fireball damage/buff system, rune balance) were critical but deferred

**What We'd Do Differently**: 
- Design review sessions for each major system before implementation
- Edge case analysis upfront
- Prototype complex interactions before full implementation
- Resolve all critical design questions before coding (use "Three Amigos" or design review sessions)
- Create decision log to track resolved vs deferred questions

### 4. **Sound Effects Integration Delayed**

**Problem**: Sound effects were planned but not implemented until late (or not at all):
- `sound-effects-integration.plan.md` exists but was Phase 3
- Many sound effects still missing (per `IMPLEMENTATION_STATUS.md`)
- Audio system incomplete

**Impact**: 
- Game feels less polished
- Missing audio feedback reduces game feel
- Last-minute audio integration was rushed

**Evidence**:
- `IMPLEMENTATION_STATUS.md` shows Phase 3 (Sound Effects) as "NOT IMPLEMENTED"
- Git history shows audio-related commits near the end

**What We'd Do Differently**: 
- Integrate audio earlier (even placeholder sounds)
- Audio should be part of core loop, not polish phase
- Test game feel with audio from the start

### 5. **Level Design Happened Late**

**Problem**: Level design and balancing happened very late in development:
- Most level commits are in final day
- Difficulty tuning happened at the end
- Level testing was rushed

**Impact**: 
- Balance issues discovered late
- Less time for iteration on level design
- Some levels may be too easy/hard

**Evidence**:
- Git history shows many "Update level_X.tres" commits on final day
- "Final Difficulty Tuning" commit near deadline
- `to-do.md` mentions level design as deferred work

**What We'd Do Differently**: 
- Create placeholder levels earlier
- Test levels as systems are implemented
- Iterate on level design throughout development

### 6. **Debug Mode Configuration Issues**

**Problem**: Debug mode was hardcoded and caused issues:
- Debug mode accidentally enabled in builds
- Multiple commits fixing debug mode in exports
- Config system planned but not implemented

**Impact**: 
- Debug features visible in production builds
- Time spent fixing export issues
- Unprofessional appearance

**Evidence**:
- Multiple commits: "enable debug mode and prevent debug mode from going into the web build"
- "debug true" commits show manual toggling
- `gameplay-systems-implementation.plan.md` shows debug config as Phase 4 (late)

**What We'd Do Differently**: 
- Implement config system earlier
- Use feature flags from the start
- Test exports regularly, not just at the end

### 7. **Gap Between Planning and Execution**

**Problem**: Comprehensive planning documents existed but weren't fully followed:
- Initial scaffold plan was excellent and followed
- Later plans (systems integration, gameplay systems) were partially followed
- Some planned systems were never implemented (sound effects, some polish)
- Implementation deviated from plans in some areas

**Impact**: 
- Some good planning work wasn't utilized
- Inconsistency between planned architecture and actual implementation
- Some features planned but never built

**Evidence**:
- `initial_scaffold.plan.md` was followed closely and worked well
- `implementation.plan.md` shows many systems as "PARTIAL" or "NOT STARTED"
- `sound-effects-integration.plan.md` exists but Phase 3 was never completed
- `critical-systems-implementation.plan.md` identified blockers that were eventually solved

**What We'd Do Differently**: 
- Regular plan reviews to ensure execution matches planning
- Update plans as implementation evolves
- Don't create plans for features that won't be built (or mark them clearly as post-MVP)
- Use plans as living documents, not static requirements

---

## What Took a Lot of Cycles

### 1. **Rune System Refactoring** (~15-20% of time)
- Changing from one-use to multi-use runes
- Implementing stacking systems (speed/power)
- Updating all rune types to new patterns
- **Why**: Design decision changed mid-development after iteration review identified "lack of build diversity"
- **Could Have Been Avoided**: Better upfront design validation, earlier playtesting
- **Note**: The iteration review (`iteration.md`) was valuable but came too late - should have happened after first playable

### 2. **Fireball System Iterations** (~10-15% of time)
- Stacking system implementation
- Status modifier VFX
- Speed cap adjustments
- **Why**: Mechanics weren't fully designed before implementation
- **Could Have Been Avoided**: Prototype core mechanics earlier

### 3. **Level Integration and Fixes** (~10% of time)
- Portal linking issues
- Preset item placement bugs
- Spawn point validation
- Level export/import issues
- **Why**: Level system complexity wasn't fully anticipated
- **Could Have Been Avoided**: More thorough testing of level system earlier

### 4. **UI Polish and Mobile Support** (~8-10% of time)
- Input debouncing for mobile
- Cost display fixes
- Menu button spacing
- Info snackbar implementation
- **Why**: Mobile support added late, UI polish needed
- **Could Have Been Avoided**: Test on target platforms earlier

### 5. **Bug Fixes and Edge Cases** (~15-20% of time)
- Explosive wall not working after restart
- Enemy removal on level loss
- Z-index rendering issues
- Tile stacking bugs
- Portal linking issues
- Preset item placement bugs
- **Why**: Incomplete testing, edge cases not considered, systems integrated without full testing
- **Could Have Been Avoided**: More thorough testing, edge case analysis, integration testing as systems are built

### 6. **Export and Build Issues** (~5-8% of time)
- Web build level detection
- Debug mode in exports
- UID warnings
- **Why**: Exports not tested regularly
- **Could Have Been Avoided**: Test exports throughout development

---

## What Saved Us a Lot of Grief

### 1. **Godot's Resource System**
- **What**: Using `.tres` resource files for levels, rune definitions, etc.
- **Why It Helped**: Non-programmers could create content, easy to iterate
- **Impact**: Level creation was fast, balancing was easy

### 2. **Autoload Singletons**
- **What**: GameManager, GameConfig, TileManager as autoloads
- **Why It Helped**: Centralized state, easy access from anywhere
- **Impact**: Reduced coupling, easier debugging

### 3. **Clear Architecture from the Start**
- **What**: Separation of concerns (entities, game logic, UI)
- **Why It Helped**: Changes in one area didn't break others
- **Impact**: Could refactor systems without breaking everything

### 4. **PR-Based Workflow**
- **What**: Incremental PRs with QA checkpoints
- **Why It Helped**: Caught bugs early, maintained stable main branch
- **Impact**: Could roll back problematic changes, clean git history

### 5. **Comprehensive Documentation**
- **What**: GDD, scope docs, architecture docs, implementation plans
- **Why It Helped**: Shared understanding, reference for decisions
- **Impact**: Less confusion, faster onboarding

### 6. **Grid-Based System**
- **What**: 13x7 grid with 32x32 tiles
- **Why It Helped**: Simplified pathfinding, collision, placement
- **Impact**: Pathfinding was straightforward, no complex collision math

### 7. **Modular Rune Architecture**
- **What**: RuneBase class with consistent interface
- **Why It Helped**: Adding new runes was just extending a class
- **Impact**: 6 rune types implemented without major refactoring

### 8. **Mid-Development Iteration Process**
- **What**: `iteration.md` review that identified core problems ("lack of build diversity", "lack of anticipation")
- **Why It Helped**: Correctly identified real problems that needed fixing
- **Impact**: Led to important improvements (multi-use runes, Power Rune, stacking systems)
- **Note**: This was valuable but came too late - should have happened after first playable, not mid-development

### 9. **Comprehensive Question Resolution Process**
- **What**: `iteration-unanswered-questions.md` and `iteration-resolutions.md` systematically addressed 40+ questions
- **Why It Helped**: Forced team to make decisions rather than deferring indefinitely
- **Impact**: Clear decisions made, even if some were deferred to post-MVP
- **Note**: Should have been done earlier, but the process itself was valuable

---

## What We'd Do Differently Next Time

### Process Improvements

1. **Prototype Core Loop First**
   - Build minimal playable prototype in first 4-6 hours
   - Validate core mechanics before building full systems
   - Test with real players early

2. **Design Review Sessions**
   - Review each major system design before implementation
   - Identify edge cases upfront
   - Get team buy-in on design decisions

3. **Stricter Scope Management**
   - Weekly scope reviews
   - "Nice to have" backlog separate from MVP
   - Say "no" to scope creep more aggressively

4. **Earlier Integration Testing**
   - Test systems together as they're built
   - Don't wait until end to test full game
   - Regular playtesting sessions

5. **Regular Export Testing**
   - Test exports weekly, not just at the end
   - Catch platform-specific issues early
   - Verify debug mode disabled in exports

6. **Audio Integration Earlier**
   - Add placeholder sounds from the start
   - Audio is part of game feel, not polish
   - Test with audio throughout development

7. **Level Design Throughout**
   - Create placeholder levels early
   - Test levels as systems are implemented
   - Iterate on level design continuously

### Technical Improvements

1. **Feature Flags from the Start**
   - Debug mode as feature flag
   - Easy to enable/disable features
   - Test different configurations

2. **More Thorough Testing**
   - Unit tests for core systems (rune activation, damage calculation)
   - Integration tests for complex interactions
   - Edge case testing earlier

3. **Better Error Handling**
   - More validation of level data
   - Better error messages
   - Graceful degradation

4. **Performance Profiling Earlier**
   - Profile with target enemy counts early
   - Identify bottlenecks before they're problems
   - Optimize as we go, not at the end

### Design Improvements

1. **Validate Mechanics Before Building**
   - Paper prototype or simple digital prototype
   - Test core loop with players
   - Iterate on design before full implementation

2. **Plan Edge Cases Upfront**
   - What happens when fireball hits multiple runes?
   - What if no valid path exists?
   - What if player places runes in invalid locations?

3. **Balance Testing Throughout**
   - Test balance as systems are added
   - Don't wait until end for balance pass
   - Use analytics/data to inform balance

---

## If We Could Go Back in Time: Advice to Past Selves

### Week Before Jam Starts

1. **"Prototype the core loop in 4 hours. If it's not fun, pivot."**
   - Don't build full systems until core loop is validated
   - Test with real players early
   - Be willing to change direction if core loop isn't working

2. **"Make a paper prototype of rune interactions. Draw out all edge cases."**
   - Visualize complex interactions before coding
   - Identify edge cases on paper
   - Get team alignment on mechanics

3. **"Create a 'Nice to Have' backlog. Everything not in MVP goes there."**
   - Strict MVP scope
   - Defer nice-to-haves
   - Focus on core loop first

### Day 1 of Jam

1. **"Build the simplest playable version first. One level, one rune type, basic enemies."**
   - Get something playable ASAP
   - Add complexity incrementally
   - Test as you go

2. **"Test exports on Day 1. Don't wait until Day 3."**
   - Catch platform issues early
   - Verify build process works
   - Test on target devices/platforms

3. **"Add placeholder audio from the start. Game feel matters."**
   - Even simple sounds improve feel
   - Audio is not polish, it's core
   - Test with audio throughout

### Day 2 of Jam

1. **"Run the iteration review NOW. Don't wait until you're deep in implementation."**
   - The `iteration.md` review was valuable but came too late
   - Run it after first playable, not mid-development
   - Use it to validate core loop before building more systems

2. **"Resolve the 40+ unanswered questions BEFORE building more features."**
   - `iteration-unanswered-questions.md` shows questions that should have been answered earlier
   - Critical questions (fireball damage/buff system) blocked progress
   - Answer questions systematically, don't defer indefinitely

3. **"Before refactoring runes to multi-use, playtest with current system. Is the problem real?"**
   - Validate problems before solving them
   - Test with players
   - Don't refactor based on assumptions

4. **"Create at least one complete level today. Test the full loop."**
   - Don't wait until end for levels
   - Test full gameplay loop early
   - Iterate on level design

5. **"If you're adding a new feature, ask: 'Is this in MVP scope?' If no, backlog it."**
   - Stricter scope management
   - Defer nice-to-haves
   - Focus on MVP completion

### Day 3 of Jam

1. **"Stop adding features. Polish what exists."**
   - Feature freeze early
   - Focus on polish and bug fixes
   - Test, don't build

2. **"Test exports every 2 hours. Don't wait until the end."**
   - Catch issues early
   - Verify builds work
   - Don't scramble at deadline

3. **"Playtest with someone who hasn't seen the game. Their confusion is your bug list."**
   - Fresh eyes catch issues
   - Test onboarding experience
   - Fix critical UX issues

---

## Key Metrics & Statistics

### Development Timeline
- **Start**: January 2, 2026, 11:43 AM
- **End**: January 4, 2026, 8:47 PM
- **Duration**: ~3 days (77 hours)
- **Total Commits**: 339
- **Average Commits/Day**: ~113

### Planning vs Execution
- **Plans Created**: 14 plan documents (11 archived, 3 active)
- **Questions Identified**: 40+ unanswered questions mid-development
- **Questions Resolved**: 18 major questions resolved in `iteration-resolutions.md`
- **Plans Fully Followed**: Initial scaffold (excellent execution)
- **Plans Partially Followed**: Systems integration, gameplay systems
- **Plans Not Followed**: Sound effects integration (Phase 3 incomplete)

### Codebase Statistics
- **Rune Types Implemented**: 6 (Redirect, Advanced Redirect, Portal, Reflect, Explosive, Acceleration)
- **Wall Types**: 2 (Regular Wall, Explosive Wall)
- **Tile Types**: 2 (Open Terrain, Mud Tile)
- **Enemy Types**: 3 (Basic, Fast, Tank)
- **Levels Created**: 10+ (original plan was 3)
- **UI Screens**: 5+ (Title, Main Menu, Game, Pause, Game Over, Victory)

### Scope Changes
- **Original MVP Scope**: 3 levels, 6 rune types, 2-3 enemy types
- **Final Scope**: 10+ levels, 6 rune types, 3 enemy types, additional features (Power Rune, Explosive Wall, Mud Tile)

### Time Allocation (Estimated)
- **Core Systems**: ~30% (fireball, runes, enemies, pathfinding)
- **Refactoring**: ~20% (rune system changes, stacking systems)
- **New Features**: ~15% (Power Rune, Explosive Wall, Mud Tile)
- **Level Design**: ~10% (level creation, balancing)
- **Bug Fixes**: ~15% (edge cases, integration issues)
- **UI/Polish**: ~10% (mobile support, visual polish)

---

## The Iteration Process: What Worked and What Didn't

### The Mid-Development Iteration Review (`iteration.md`)

**What Happened**: Mid-development, the team conducted an iteration review asking: "Is the game fun? Are choices impactful? What is not fun?"

**What It Identified**:
- ✅ "Lack of build diversity" - Only acceleration rune was viable
- ✅ "Lack of anticipation" - No enemy information
- ✅ "Lack of difficulty" - Piercing mechanic made 1 enemy = 100 enemies equally easy
- ✅ "Lack of investment" - One wave per level felt shallow

**What It Led To**:
- Multi-use runes (addressing build diversity)
- Power Rune addition (addressing build diversity)
- Stacking systems (addressing difficulty)
- Explosive Wall and Mud Tile (addressing build diversity)

**Why It Was Valuable**:
- Correctly identified real problems
- Led to important improvements
- Process itself was good (asking the right questions)

**Why It Was Problematic**:
- Came too late (mid-development instead of after first playable)
- Required major refactors instead of design changes
- 40+ questions needed resolution (`iteration-unanswered-questions.md`)

**Key Insight**: The iteration process was valuable, but its timing was wrong. It should have happened:
1. After first playable prototype (Day 1)
2. Before building full systems (not mid-development)
3. With systematic question resolution upfront

### The Question Resolution Process

**What Happened**: `iteration-unanswered-questions.md` cataloged 40+ questions across 18 categories that needed answers.

**Categories**:
- Core gameplay (difficulty, fireball damage/buff system)
- Rune balance & design
- Strategy & build diversity
- Level design priorities
- Asset & polish priorities
- Technical & implementation
- Strategic direction

**Resolution Process**: `iteration-resolutions.md` systematically resolved 18 major questions, deferred others to post-MVP.

**What Worked**:
- Forced team to make decisions
- Clear categorization of MVP vs post-MVP
- Systematic approach prevented indefinite deferral

**What Didn't Work**:
- Questions should have been answered before implementation
- Critical questions (fireball damage/buff system) blocked progress
- Too many questions deferred ("DEFERRED" appears frequently)

**Key Insight**: Having a systematic question resolution process is valuable, but it should happen during planning, not mid-development. Use it to:
1. Identify questions during design phase
2. Resolve critical questions before coding
3. Defer only non-critical questions to post-MVP

---

## Lessons Learned

### Design Process
1. **Validate before building**: Prototype core mechanics before full implementation
2. **Test early and often**: Don't wait until the end to test
3. **Scope discipline**: Say "no" to scope creep, even when features seem small
4. **Edge cases matter**: Plan for edge cases upfront, not as afterthoughts
5. **Iteration reviews**: Run iteration reviews after first playable, not mid-development
6. **Question resolution**: Resolve critical design questions early (don't defer 40+ questions)
7. **Design decisions**: Make design decisions before implementation, not during refactoring

### Development Process
1. **Incremental is better**: Small, tested changes beat large refactors
2. **Test exports regularly**: Don't wait until deadline to test builds
3. **Audio is core**: Integrate audio early, not as polish
4. **Level design is iterative**: Create levels early, iterate throughout

### Technical Process
1. **Architecture matters**: Good architecture saves time later
2. **Modularity helps**: Modular systems are easier to change
3. **Documentation is valuable**: Good docs prevent confusion and save time
4. **Feature flags are useful**: Use flags for debug mode, experimental features

### Team Process
1. **Shared understanding**: Good documentation creates shared understanding
2. **PR workflow helps**: Incremental PRs catch issues early
3. **QA checkpoints**: Regular QA prevents bugs from compounding
4. **Communication**: Regular check-ins prevent misalignment

---

## Conclusion

Furnace was a successful game jam project that delivered a complete, playable game in 3 days. The team achieved impressive results: 10+ levels, 6 rune types, complex systems, and a polished gameplay loop.

However, the development process revealed several areas for improvement:
- **Design validation**: More upfront validation could have prevented major refactors
- **Scope management**: Stricter adherence to MVP scope would have reduced time pressure
- **Testing**: Earlier and more thorough testing would have caught issues sooner
- **Integration**: Earlier integration of systems (audio, levels, exports) would have reduced last-minute scrambling

The project's success was largely due to:
- **Good architecture**: Modular, maintainable code structure
- **Clear documentation**: Shared understanding of goals and systems
- **Incremental process**: PR-based workflow with QA checkpoints
- **Team collaboration**: Effective use of PRs, documentation, and communication

**Key Takeaway**: The biggest time sinks were avoidable: design changes mid-development, scope creep, and delayed integration testing. With better upfront planning and stricter scope discipline, the same quality could have been achieved with less stress and more time for polish.

**Important Note**: The mid-development iteration process (`iteration.md`) was actually valuable and correctly identified real problems. The issue wasn't the process itself, but its timing - it should have happened after the first playable prototype, not mid-development. The systematic question resolution process (`iteration-unanswered-questions.md` → `iteration-resolutions.md`) was also valuable but should have been done earlier.

---

## Recommendations for Future Projects

### Before Starting
1. **Prototype core loop**: Validate mechanics before building full systems
2. **Design review**: Review major systems before implementation
3. **Scope definition**: Define MVP clearly, create "nice to have" backlog
4. **Architecture planning**: Plan system architecture upfront

### During Development
1. **Regular testing**: Test systems as they're built, not just at the end
2. **Scope discipline**: Weekly scope reviews, say "no" to creep
3. **Early integration**: Integrate systems early (audio, levels, exports)
4. **Incremental PRs**: Small, tested changes with QA checkpoints
5. **Iteration reviews**: Run iteration reviews after first playable, not mid-development
6. **Question resolution**: Resolve critical design questions early, don't defer indefinitely
7. **Plan updates**: Update plans as implementation evolves, don't let them become stale

### At the End
1. **Feature freeze**: Stop adding features early, focus on polish
2. **Export testing**: Test exports regularly, not just at deadline
3. **Playtesting**: Test with fresh players, fix critical UX issues
4. **Documentation**: Update docs with final decisions and learnings

---

**Document Status**: Complete  
**Last Updated**: January 2026  
**Authors**: Arcane Laboratory Team
