# Furnace Productionization Plan

**Purpose**: Transform Furnace from a game jam game into a publishable Steam game  
**Target Release**: Steam (Full release, no early access)  
**Pricing**: Low price ($5-10)

---

## Executive Summary

This plan outlines the productionization of Furnace, focusing on content expansion, new systems, polish, and Steam integration. The game will maintain its puzzle-first approach with 3 chapters, introducing new mechanics gradually while supporting multiple viable build paths through an upgrade system.

**Key Goals**:
- Expand content to 20-30 levels (MVP) across 3 chapters
- Implement new rune systems (Burn, Damage/Speed split) and cooldowns
- Add progression through upgrade system and scoring/leaderboards
- Polish tutorial, UI, audio, and visual effects
- Integrate Steam features (achievements, leaderboards, cloud saves)

---

## 1. Immediately Impactful Polish Changes

**Priority**: Implement these first for quick wins and improved player experience

### Critical Fixes
1. **Fix Portal Cost Bug**
   - Issue: Portal cost counting per tile on restart
   - Fix: Correct cost calculation logic
   - Impact: Prevents player frustration and negative reviews

2. **Remove Screen Shake from Explosive Rune**
   - Issue: Screen shake annoying in late-game
   - Fix: Remove screen shake from explosive rune activation
   - Impact: Improves late-game experience, reduces visual fatigue

3. **Add Pause Menu Button**
   - Issue: No on-screen pause button
   - Fix: Add pause button in top-left corner
   - Impact: Essential for player control, especially on mobile

4. **Add Clear Board Button**
   - Issue: No way to reset level during build phase
   - Fix: Add clear board button (always visible during build phase, resets level)
   - Impact: Improves UX, allows experimentation without restarting

### Quick Wins
5. **Add Fireball Die Animation**
   - Current: Fireball disappears instantly
   - Fix: Simple fade out animation
   - Impact: Better visual feedback, more polished feel

6. **Implement Audio Mixing/Ducking**
   - Issue: Too many sounds overwhelming players
   - Fix: Add audio mixing/ducking (reduce SFX when many sounds play)
   - Impact: Significantly improves audio experience

7. **Add More Tutorial Levels**
   - Current: Players struggle to understand mechanics initially
   - Fix: Add a few more levels at the very beginning for easier on-ramp
   - Impact: Reduces player confusion, improves retention

8. **Create Tutorial Level 0**
   - Current: No dedicated tutorial
   - Fix: Create Level 0 before Level 1 (increment all existing levels by 1)
   - Content: Fireball + basic placement (place a rune, see it activate)
   - Impact: Essential for onboarding, addresses playtester feedback

---

## 2. Design Meeting Agenda

### Meeting Purpose
Resolve open design questions that block implementation of new systems (upgrade system, Burn Rune, UI redesign, alternative damage sources).

### Agenda Items

#### 2.1: Upgrade System Design (60-90 minutes)

**Goal**: Design complete upgrade system supporting multiple viable build paths with synergies

**Questions to Resolve**:
1. **Build Paths**: What build paths should be supported?
   - Damage-focused (power stacking, explosive builds)
   - Speed-focused (acceleration stacking, fast fireball)
   - Control-focused (reflect, redirect, path manipulation)
   - DOT-focused (burn stacking, early application)
   - Hybrid/combination paths
   - What synergies exist between paths?

2. **Upgrade Progression**: How do players earn/progress upgrades?
   - Currency system (earn X per level, spend on upgrades)
   - Star/performance system (earn stars, unlock upgrades)
   - Automatic unlocks (complete level X = unlock upgrade Y)
   - Combination system
   - When can players upgrade? (between levels, at chapter completion, anytime)

3. **Upgrade Depth**: How deep should upgrade trees be?
   - How many upgrade levels per rune/tile? (2-3? 4-6? 7+?)
   - Should depth vary by rune type?
   - Linear or branching upgrade trees?

4. **Upgrade Scope**: Which specific tiles should have individual upgrades?
   - All damage-dealing tiles?
   - All tiles with cooldowns?
   - Specific high-value tiles (Power Rune, Explosive Walls)?
   - Should some upgrades be global (affect all runes of a type)?

5. **Synergy Design**: How complex should synergies be?
   - Simple 2-rune combos
   - Moderate 3-4 rune combos
   - Deep 5+ rune combos
   - Emergent (discoverable, not explicitly designed)
   - Examples of specific synergies to design?

6. **Difficulty Impact**: How do upgrades affect difficulty?
   - Make game easier (power fantasy)
   - Enable harder content (unlock new challenges)
   - Maintain difficulty (upgrades = more options, not easier)
   - Combination approach

**Deliverables**:
- Upgrade tree diagrams for each rune type
- Progression flow chart
- Synergy matrix
- Balance guidelines

---

#### 2.2: Burn Rune Design (30 minutes)

**Goal**: Finalize Burn Rune mechanics and balance

**Questions to Resolve**:
1. **Duration/Applications**: How long does burn effect last?
   - Time-based (X seconds after activation)
   - Application-based (X fireball hits/applications)
   - Until fireball destroyed
   - Combination (time limit OR application limit)

2. **Stacking**: Should burn stack?
   - No stacking (single burn effect)
   - Yes, stacking (multiple applications increase damage)
   - Capped stacking (stacks up to X times)
   - How does stacking work? (additive damage? multiplicative?)

3. **Balance**: Damage per tick, tick frequency, total duration
   - How much damage per tick?
   - How often does it tick? (every 0.5s? 1s? 2s?)
   - Total damage compared to direct fireball damage?

**Deliverables**:
- Burn Rune specification document
- Balance numbers (damage, duration, cost)

---

#### 2.3: UI Redesign (45 minutes)

**Goal**: Design UI system to handle 10+ rune types

**Questions to Resolve**:
1. **Menu Layout**: How to display more than 6 runes?
   - Fit more on page (grid layout, smaller tiles, multiple rows)
   - Pagination (scrollable menu, tabs, page navigation)
   - Categorized tabs (Basic/Advanced runes, or by function)
   - Expandable submenus
   - Combination approach

2. **Rune Count**: How many runes should UI support?
   - Current: 7 runes (Redirect, Advanced Redirect, Portal, Reflect, Explosive, Acceleration, Power)
   - After split: 9 runes (+Damage, +Speed)
   - After Burn: 10 runes
   - Future: Plan for 12-15 runes?

3. **Mobile UI**: How should mobile/touch be handled?
   - Same UI as desktop
   - Optimized layout (larger buttons, different arrangement)
   - Swipe gestures for navigation
   - Touch-specific interactions

4. **Visual Design**: How should the UI look?
   - Maintain current clean aesthetic?
   - New visual style for expanded menu?
   - Icons vs. text labels?

**Deliverables**:
- UI mockups/wireframes
- Interaction flow diagrams
- Mobile UI specifications

---

#### 2.4: Alternative Damage Sources (30 minutes)

**Goal**: Determine if additional damage sources beyond Burn Rune are needed

**Questions to Resolve**:
1. **Need Assessment**: Is Burn Rune sufficient, or are more damage sources needed?
   - Current: Fireball-based damage + Burn Rune (DOT)
   - Team feedback: "More ways of doing damage without the bullet being there"
   - Does Burn Rune satisfy this, or need more?

2. **If More Needed**: What additional sources?
   - Trap tiles (damage when enemies step on them)
   - Environmental hazards (damage zones, etc.)
   - Passive damage auras (damage over time in an area)
   - Other creative options

3. **Priority**: If adding more, which is highest priority?
   - What fits the puzzle-focused gameplay?
   - What adds most strategic depth?
   - What's easiest to implement?

**Deliverables**:
- List of approved damage sources (if any)
- Priority order
- Basic specifications

---

#### 2.5: Content Planning (30 minutes)

**Goal**: Plan level content and chapter structure

**Questions to Resolve**:
1. **Chapter Breakdown**: How many levels per chapter?
   - Total: 30-50 levels across 3 chapters
   - MVP: 20-30 levels
   - Distribution: Equal (10 per chapter)? Or varied?

2. **Rune Introduction**: When are new runes introduced?
   - Chapter 1: Which runes?
   - Chapter 2: Which new runes?
   - Chapter 3: Which new runes?
   - How are new runes introduced? (tutorial level? gradual introduction?)

3. **Unique Mechanics**: What unique mechanics per chapter?
   - Chapter 1: [TBD]
   - Chapter 2: [TBD]
   - Chapter 3: [TBD]

4. **Level Themes**: Should chapters have themes?
   - Visual themes?
   - Mechanical themes?
   - Narrative themes (if any)?

**Deliverables**:
- Chapter breakdown document
- Rune introduction schedule
- Level content outline

---

### Design Meeting Output

**Required Deliverables**:
1. Upgrade System Design Document (complete specification)
2. Burn Rune Specification (mechanics and balance)
3. UI Redesign Mockups (desktop and mobile)
4. Damage Sources List (if any beyond Burn)
5. Content Plan (chapter structure, rune introduction schedule)

**Next Steps After Meeting**:
- Review and approve all designs
- Create implementation tickets/tasks
- Begin implementation of designed systems

---

## 3. High-Level Scope of Work

### 3.1: Content Expansion

**Scope**: Expand from current 10+ levels to 20-30 levels (MVP) across 3 chapters

**Work Items**:
- Create tutorial Level 0 (fireball + basic placement)
- Increment all existing levels by 1
- Add 2-3 more levels at beginning for easier on-ramp
- Design and create additional levels to reach 20-30 total
- Organize levels into 3 chapters with different rune types and mechanics
- Design unique mechanics for each chapter
- Plan rune introduction schedule per chapter

**Dependencies**: Content planning session (design meeting)

**Success Criteria**:
- 20-30 levels complete and playtested
- Clear chapter structure with unique mechanics
- Gradual introduction of all mechanics
- Smooth difficulty curve

---

### 3.2: New Rune Systems

**Scope**: Implement Burn Rune and split Power Rune into Damage/Speed runes

**Work Items**:
- **Burn Rune**:
  - Create burn_rune.gd script
  - Create burn_rune.tscn scene
  - Create burn_rune_definition.tres resource
  - Implement burn DOT system on enemies
  - Add visual feedback (burning enemies effect)
  - Integrate with fireball system
  - Add to build menu and details menu
  - Balance testing

- **Split Power Rune**:
  - Create damage_rune.gd script (from Power Rune)
  - Create speed_rune.gd script (from Power Rune)
  - Create damage_rune.tscn and speed_rune.tscn scenes
  - Create damage_rune_definition.tres and speed_rune_definition.tres resources
  - Update fireball to handle separate damage and speed stacks
  - Remove or deprecate Power Rune
  - Update UI to accommodate new runes
  - Balance testing

**Dependencies**: Burn Rune design session, UI redesign

**Success Criteria**:
- Burn Rune fully functional with DOT system
- Damage and Speed runes working independently
- All runes integrated into UI
- Balanced gameplay

---

### 3.3: Cooldown System

**Scope**: Implement cooldown system for runes and tiles

**Work Items**:
- Design cooldown system architecture
- Implement cooldown tracking on runes
- Implement cooldown tracking on tiles (Mud Tile, etc.)
- Add visual feedback (grayed out, pulsing effect)
- Integrate with upgrade system (cooldowns as upgradeable stat)
- Add cooldown UI indicators
- Balance cooldown durations
- Testing and iteration

**Dependencies**: Upgrade system design (to understand upgradeable cooldowns)

**Success Criteria**:
- Cooldowns working on all applicable runes/tiles
- Clear visual feedback for cooldown state
- Balanced cooldown durations
- Upgrade system can modify cooldowns

---

### 3.4: Upgrade System

**Scope**: Implement complete upgrade system supporting multiple build paths

**Work Items**:
- Design upgrade system architecture (after design meeting)
- Create upgrade resource classes
- Implement upgrade progression system (currency/star/unlock system)
- Create upgrade UI (upgrade menu, upgrade trees)
- Implement per-rune upgrades
- Implement global upgrades
- Implement meta-progression upgrades
- Design and implement synergies
- Balance upgrade costs and effects
- Testing and iteration

**Dependencies**: Upgrade system design meeting (must happen first)

**Success Criteria**:
- Multiple viable build paths supported
- Clear upgrade progression
- Synergies working as designed
- Balanced upgrade costs and effects
- Upgrade system enhances replayability

---

### 3.5: Scoring & Leaderboards

**Scope**: Implement resource-based scoring and Steam leaderboards

**Work Items**:
- **Scoring System**:
  - Implement resource-based scoring formula (fewer resources used = higher score)
  - Calculate score at level completion
  - Display score with resources remaining (e.g., "Score: 1,250 (50 resources left)")
  - Store local high scores per level

- **Leaderboards**:
  - Implement local leaderboard system
  - Integrate Steam leaderboard API
  - Create leaderboard UI (per-level leaderboards)
  - Add leaderboard viewing in level select/complete screens
  - Test leaderboard functionality

**Dependencies**: Steam account setup, Steam SDK integration

**Success Criteria**:
- Scoring system working correctly
- Local leaderboards functional
- Steam leaderboards integrated and working
- Leaderboard UI polished and accessible

---

### 3.6: Steam Integration

**Scope**: Integrate Steam features (achievements, leaderboards, cloud saves)

**Work Items**:
- **Steam Setup**:
  - Set up Steam account/workspace
  - Configure Steam SDK
  - Set up Steam app page
  - Configure Steam build pipeline

- **Achievements**:
  - Design achievement list
  - Implement achievement system
  - Create achievement UI
  - Test achievement unlocking

- **Leaderboards**:
  - Already covered in 3.5 (Scoring & Leaderboards)

- **Cloud Saves**:
  - Implement Steam cloud save system
  - Save game state (unlocked levels, upgrades, progress)
  - Load game state from cloud
  - Handle cloud save conflicts
  - Test cloud save functionality

- **Steam Workshop** (Nice-to-have):
  - Research Steam Workshop integration
  - Design level sharing system
  - Implement level export/import
  - Create level sharing UI
  - Test Workshop functionality

**Dependencies**: Steam account setup (must happen early)

**Success Criteria**:
- Steam achievements working
- Steam leaderboards working
- Cloud saves working reliably
- Steam Workshop functional (if implemented)

---

### 3.7: Tutorial & Onboarding

**Scope**: Create comprehensive tutorial system

**Work Items**:
- Create tutorial Level 0 (before Level 1)
- Design tutorial content (fireball + basic placement)
- Implement show-don't-tell tutorial approach
- Increment all existing levels by 1
- Add 2-3 more levels at beginning for easier on-ramp
- Test tutorial flow with new players
- Iterate based on feedback

**Dependencies**: None (can start immediately)

**Success Criteria**:
- Tutorial level teaches fireball and basic placement
- Players understand core mechanics after tutorial
- Smooth transition from tutorial to Level 1
- Reduced player confusion (addresses playtester feedback)

---

### 3.8: UI/UX Improvements

**Scope**: Improve in-game UI and mobile support

**Work Items**:
- **Pause Menu**:
  - Add pause button (top-left corner)
  - Implement pause menu functionality
  - Add resume/restart/quit options

- **Clear Board Button**:
  - Add clear board button (always visible during build phase)
  - Implement level reset functionality
  - Add confirmation dialog (optional)

- **Menu Redesign**:
  - Redesign build menu to handle 10+ runes (after UI design meeting)
  - Implement chosen UI solution (pagination/tabs/grid)
  - Update details menu
  - Test menu usability

- **Mobile UI**:
  - Increase touch target sizes
  - Implement button debouncing
  - Optimize layout for mobile screens
  - Test on mobile devices

**Dependencies**: UI redesign meeting

**Success Criteria**:
- Pause menu accessible and functional
- Clear board button working
- Build menu handles all runes elegantly
- Mobile UI functional and polished

---

### 3.9: Audio & Visual Polish

**Scope**: Improve audio mixing and visual effects

**Work Items**:
- **Audio**:
  - Implement audio mixing/ducking system (reduce SFX when many sounds play)
  - Create loss song v1
  - Create win song v1
  - Integrate win/loss songs
  - Test audio balance

- **Visual Effects**:
  - Implement fireball die animation (simple fade out)
  - Verify furnace idle animation (already done)
  - Remove screen shake from explosive rune
  - Polish existing visual effects
  - Test visual feedback clarity

**Dependencies**: None (can start immediately)

**Success Criteria**:
- Audio not overwhelming during active mode
- Win/loss songs implemented
- Fireball die animation polished
- Screen shake issues resolved
- Visual effects clear and impactful

---

### 3.10: Bug Fixes & Performance

**Scope**: Fix known bugs and optimize performance

**Work Items**:
- **Bug Fixes**:
  - Fix portal cost bug (cost calculation logic)
  - Conduct bug audit (find additional bugs)
  - Fix critical bugs
  - Fix balance bugs
  - Fix polish bugs

- **Performance**:
  - Conduct performance audit (identify bottlenecks)
  - Optimize enemy rendering (many enemies on screen)
  - Optimize particle effects (fireball trail, explosions)
  - Optimize screen shake (already removing from explosive)
  - Optimize mobile performance
  - Test performance targets met

**Dependencies**: Performance audit (must happen early)

**Success Criteria**:
- All critical bugs fixed
- Performance targets met (30 FPS minimum, 60 FPS ideal)
- Game runs smoothly with 100+ enemies
- Mobile performance acceptable

---

### 3.11: Content Creation

**Scope**: Create additional levels to reach 20-30 level MVP

**Work Items**:
- Design level layouts
- Create level resources (.tres files)
- Place initial walls and runes
- Configure enemy waves
- Set resource amounts
- Test level difficulty and balance
- Iterate based on playtesting
- Organize levels into chapters

**Dependencies**: Content planning session, rune introduction schedule

**Success Criteria**:
- 20-30 levels complete
- Levels organized into 3 chapters
- Gradual difficulty increase
- All mechanics introduced properly
- Levels are fun and challenging

---

### 3.12: QA & Testing

**Scope**: Comprehensive testing and quality assurance

**Work Items**:
- Create test plans for each system
- Conduct functional testing
- Conduct balance testing
- Conduct performance testing
- Conduct mobile testing
- Conduct Steam integration testing
- Bug tracking and fixing
- Playtesting with external testers
- Iterate based on feedback

**Dependencies**: All features implemented

**Success Criteria**:
- All systems tested and working
- No critical bugs
- Balanced gameplay
- Performance targets met
- Positive playtester feedback

---

### 3.13: Steam Release Preparation

**Scope**: Prepare for Steam release

**Work Items**:
- Create Steam store page
  - Write store description
  - Create screenshots
  - Create trailer video
  - Set up store assets
- Configure Steam build settings
- Set up Steam build pipeline
- Create release build
- Submit to Steam
- Marketing preparation
  - Social media posts
  - Press kit
  - Influencer outreach
- Launch preparation

**Dependencies**: All features complete, QA passed

**Success Criteria**:
- Steam store page complete and approved
- Build submitted to Steam
- Marketing materials ready
- Launch successful

---

## 4. Dependencies & Prerequisites

### Critical Dependencies (Must Happen First)
1. **Upgrade System Design Session** - Blocks upgrade system implementation
2. **Performance Audit** - Identifies optimization targets
3. **Steam Account Setup** - Required for Steam integration work
4. **UI Redesign Meeting** - Blocks menu system redesign
5. **Burn Rune Design Session** - Blocks Burn Rune implementation
6. **Content Planning Session** - Guides level creation

### Implementation Dependencies
- Burn Rune → After Burn Rune design session
- Damage/Speed Rune Split → After UI redesign (to accommodate more runes)
- Cooldown System → After upgrade system design (cooldowns are upgradeable)
- Upgrade System → After upgrade system design session
- Scoring/Leaderboards → After Steam account setup
- Steam Integration → After Steam account setup
- Content Creation → After content planning session

---

## 5. Risk Assessment

### High Risk Items
- **Upgrade System Complexity**: Design session must happen early, implementation may take longer than expected
- **Steam Integration**: First-time Steam integration may have learning curve
- **Content Creation**: 20-30 levels may take significant time
- **Balance**: New runes and upgrades need extensive playtesting

### Medium Risk Items
- **UI Redesign**: Handling 10+ runes elegantly may require iteration
- **Performance**: Late-game performance issues may require optimization
- **Mobile Support**: Mobile optimizations may reveal additional issues

### Low Risk Items
- **Tutorial**: Well-defined scope, straightforward implementation
- **Bug Fixes**: Known bugs are specific and fixable
- **Audio/Visual Polish**: Clear requirements, manageable scope

---

## 6. Success Metrics

### Pre-Release Metrics
- [ ] 20-30 levels complete and playtested
- [ ] All critical features implemented and tested
- [ ] Steam integration complete
- [ ] Performance targets met (30 FPS minimum)
- [ ] No critical bugs
- [ ] Tutorial addresses playtester confusion
- [ ] Audio not overwhelming

### Post-Release Metrics
- [ ] Positive Steam reviews (>80% positive)
- [ ] Player retention (players completing multiple levels)
- [ ] Leaderboard engagement (players competing for scores)
- [ ] Achievement completion rates
- [ ] Level completion rates

---

## 7. Open Design Questions

These questions require dedicated design sessions before implementation:

### Upgrade System Design Session
- Which specific tiles should have individual upgrades?
- What build paths should be supported? (damage-focused, speed-focused, control-focused, hybrid)
- How do players earn/progress upgrades? (currency system, star system, automatic unlocks, etc.)
- How deep should upgrade trees be? (2-3 levels? 4-6? 7+? Varies by rune?)
- How do upgrades affect difficulty? (make easier vs enable harder content vs maintain difficulty)
- What synergy depth? (simple 2-rune combos vs moderate 3-4 vs deep 5+ vs emergent)

### Burn Rune Design Session
- Duration/applications: How long does burn effect last? (time vs applications vs until fireball destroyed)
- Stacking: Should burn stack? (multiple applications increase damage)

### UI Design Session
- Menu system: How to handle more than 6 rune types? (fit more on page vs pagination vs tabs vs categorized)
- Total rune count: How many runes should UI support? (planning for 10+?)
- Mobile UI: How should mobile/touch be handled? (same as desktop vs optimized layout)

### Alternative Damage Sources Design Session
- What additional damage sources beyond Burn Rune? (trap tiles, environmental hazards, passive auras, etc.)
- Priority: Which is highest priority if adding more?

### Content Planning Session
- Chapter breakdown: How many levels per chapter?
- Rune introduction: When are new runes introduced per chapter?
- Unique mechanics: What unique mechanics per chapter?
- Level themes: Should chapters have themes?

---

## 8. Implementation Phases

### Phase 1: Foundation & Quick Wins
**Focus**: Immediately impactful polish changes and critical fixes

**Work Items**:
- Fix portal cost bug
- Remove screen shake from explosive rune
- Add pause menu button (top-left)
- Add clear board button
- Create tutorial Level 0
- Increment all existing levels by 1
- Add more levels at beginning for easier on-ramp
- Implement fireball die animation
- Implement audio mixing/ducking

**Dependencies**: None (can start immediately)

**Success Criteria**: Game feels more polished, critical issues resolved

---

### Phase 2: Design & Planning
**Focus**: Resolve all open design questions

**Work Items**:
- Conduct upgrade system design session
- Conduct Burn Rune design session
- Conduct UI redesign meeting
- Conduct alternative damage sources session
- Conduct content planning session
- Create design documents and specifications
- Review and approve designs

**Dependencies**: None (can start immediately)

**Success Criteria**: All design questions resolved, implementation can begin

---

### Phase 3: New Systems Implementation
**Focus**: Implement new rune systems and cooldowns

**Work Items**:
- Implement Burn Rune (after design session)
- Split Power Rune into Damage/Speed runes
- Implement cooldown system (runes and tiles)
- Redesign UI to handle more runes (after UI design meeting)
- Integrate all new systems
- Balance testing

**Dependencies**: Design sessions complete, UI redesign complete

**Success Criteria**: All new runes functional, cooldowns working, UI handles all runes

---

### Phase 4: Progression & Scoring
**Focus**: Implement upgrade system and scoring/leaderboards

**Work Items**:
- Implement upgrade system (after design session)
- Implement resource-based scoring
- Implement local leaderboards
- Implement Steam leaderboards (after Steam setup)
- Create upgrade UI
- Balance upgrade system

**Dependencies**: Upgrade system design complete, Steam account setup

**Success Criteria**: Upgrade system functional, scoring working, leaderboards integrated

---

### Phase 5: Steam Integration
**Focus**: Integrate Steam features

**Work Items**:
- Set up Steam account/workspace
- Configure Steam SDK
- Implement Steam achievements
- Implement Steam cloud saves
- Set up Steam store page
- Steam Workshop (nice-to-have, if time permits)

**Dependencies**: Steam account setup (must happen early)

**Success Criteria**: Steam features working, store page ready

---

### Phase 6: Content Creation
**Focus**: Create additional levels to reach MVP

**Work Items**:
- Design level layouts (after content planning)
- Create level resources
- Configure enemy waves and resources
- Test and balance levels
- Organize into chapters
- Iterate based on playtesting

**Dependencies**: Content planning session, rune introduction schedule

**Success Criteria**: 20-30 levels complete, organized into 3 chapters

---

### Phase 7: Polish & Optimization
**Focus**: Final polish and performance optimization

**Work Items**:
- Conduct performance audit
- Optimize based on audit results
- Implement win/loss songs
- Final visual polish pass
- Mobile optimizations
- Final bug fixes
- Final balance tuning

**Dependencies**: Performance audit (must happen early)

**Success Criteria**: Performance targets met, game polished, bugs fixed

---

### Phase 8: QA & Release
**Focus**: Testing and Steam release

**Work Items**:
- Comprehensive QA testing
- External playtesting
- Bug fixes
- Steam submission
- Marketing preparation
- Launch

**Dependencies**: All features complete

**Success Criteria**: Game ready for release, Steam submission successful

---

## 9. Next Steps

### Immediate Actions
1. **Schedule Design Meetings**:
   - Upgrade System Design Session (60-90 min)
   - Burn Rune Design Session (30 min)
   - UI Redesign Meeting (45 min)
   - Alternative Damage Sources Session (30 min)
   - Content Planning Session (30 min)

2. **Start Quick Wins**:
   - Fix portal cost bug
   - Remove screen shake from explosive rune
   - Add pause menu button
   - Add clear board button
   - Create tutorial Level 0

3. **Set Up Prerequisites**:
   - Set up Steam account/workspace
   - Schedule performance audit
   - Prepare design meeting materials

### After Design Meetings
1. Review and approve all designs
2. Create implementation tickets/tasks
3. Begin Phase 3 implementation (new systems)
4. Begin Phase 4 implementation (progression/scoring)
5. Begin Phase 6 implementation (content creation)

---

*This plan should be updated as development progresses and new information becomes available.*
