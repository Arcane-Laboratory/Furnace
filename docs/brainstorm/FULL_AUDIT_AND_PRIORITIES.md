# Furnace - Full Audit & Critical Priorities

**Audit Date**: [Current Date]  
**Status**: Pre-Development Planning Phase  
**Total Open Questions**: 30 (3 core systems resolved)

---

## Executive Summary

### ✅ Resolved (Critical Foundation)
- **Fireball Core Mechanics**: Travel, damage, piercing, cardinal directions, automatic launch
- **Core Systems**: Shoot timing, player character, furnace health
- **Basic Rune Types**: Portal (mechanics), Redirect (basic), Reflect

### 🔴 Blocking Development (Must Solve Before Coding)
**8 Questions** - These prevent implementation of core gameplay systems

### 🟡 Blocking Level Design (Must Solve Before Content Creation)
**6 Questions** - These prevent creating playable levels

### 🟢 Can Defer (Polish & Refinement)
**16 Questions** - Can be answered during development or cut for MVP

---

## 🔴 TIER 1: BLOCKING DEVELOPMENT (Solve Immediately)

These questions **MUST** be answered before any coding can begin. They define the core gameplay loop.

### 1. Rune Ignition Mechanics ⚠️ **CRITICAL BLOCKER**
**Question**: How does fireball ignite runes? Hit detection details.

**Why Critical**: 
- Affects ALL rune implementations
- Determines collision detection system
- Impacts fireball movement code
- Needed for every rune type

**Dependencies**: Blocks all rune development

**Options to Consider**:
- A) Fireball must pass through rune center (exact tile)
- B) Fireball triggers if within 1 tile radius
- C) Fireball triggers if passes through any part of rune tile
- D) Fireball triggers if within rune's "activation range"

**Recommendation**: Decide immediately - this is the foundation for all runes.

---

### 2. Advanced Redirect Rune Direction Change ⚠️ **HIGH PRIORITY**
**Question**: When/how can player change direction?

**Why Critical**:
- Determines UI/UX design
- Affects build phase vs active phase mechanics
- Impacts player agency

**Dependencies**: Blocks Advanced Redirect Rune implementation

**Options**:
- A) Set direction during build phase (before level starts)
- B) Change direction during build phase (can modify before starting)
- C) Some other interaction method

**Recommendation**: Answer after Rune Ignition, but before implementing Advanced Redirect.

---

### 3-6. Core Rune Mechanics ⚠️ **HIGH PRIORITY**
**Questions**:
- Explosive Rune: What does explode do? Area damage? Visual? Does fireball continue?
- Acceleration Rune: Speed increase amount? Stacking?
- Status Runes: Complete list? How applied? Duration? Which enemies?
- Enemy Affector Runes: What do they do? Examples?

**Why Critical**:
- Define what each rune type does
- Needed for implementation
- Affects game balance

**Dependencies**: Blocks rune system implementation

**Recommendation**: Can answer in parallel, but all needed before rune coding.

---

### 7. Portal Rune Pairing ⚠️ **MEDIUM-HIGH PRIORITY**
**Question**: Can there be multiple portal pairs? How are portals paired?

**Why Critical**:
- Affects portal rune implementation
- Determines pairing logic
- Impacts level design possibilities

**Dependencies**: Blocks Portal Rune implementation

**Options**:
- A) First two portals placed = pair, next two = pair, etc.
- B) Color-coded pairs
- C) UI selection/assignment
- D) Only one pair per level

**Recommendation**: Answer before implementing Portal Rune.

---

### 8. Rune Upgrade Options ⚠️ **SCOPE DECISION**
**Question**: Are upgrades in scope? What upgrade options exist?

**Why Critical**:
- Determines feature scope
- Affects resource system design
- May be cut for MVP

**Dependencies**: Affects resource system and rune implementation

**Recommendation**: **DECIDE TO CUT FOR MVP** - Focus on rune variety over upgrades.

---

## 🟡 TIER 2: BLOCKING LEVEL DESIGN (Solve Before Content Creation)

These questions **MUST** be answered before creating playable levels.

### 9-12. Resource System ⚠️ **HIGH PRIORITY**
**Questions**:
- Resource System Details: Single currency? Costs? Amount per level?
- Wall Costs: Resource cost for walls?
- Rune Costs: Resource costs for each rune type?
- Wall Limits: Separate limit or just resource-limited?

**Why Critical**:
- Needed to design levels
- Determines player constraints
- Affects difficulty balance
- Required for level editor/designer

**Dependencies**: Blocks level creation

**Recommendation**: Answer together as a system. Can use placeholder values initially.

---

### 13-14. Enemy & Wave Systems ⚠️ **HIGH PRIORITY**
**Questions**:
- Enemy Types: How many? Health/speed/abilities? Count per wave?
- Wave Structure: Already resolved (one level = one wave), but need enemy count/details

**Why Critical**:
- Needed to create enemies
- Determines level difficulty
- Required for content creation

**Dependencies**: Blocks enemy implementation and level design

**Recommendation**: Define at least 2-3 enemy types with basic stats for MVP.

---

### 15. Initial Elements Design ⚠️ **MEDIUM PRIORITY**
**Question**: How many initial walls/runes per level? Tutorial vs challenge?

**Why Critical**:
- Needed for level design
- Affects tutorial design
- Determines level structure

**Dependencies**: Blocks level creation

**Recommendation**: Can start with simple answer, refine during level design.

---

## 🟢 TIER 3: CAN DEFER (Polish & Refinement)

These questions can be answered during development or cut for MVP.

### UI/UX (3 questions)
- Pathfinding Visualization
- UI Resource Display  
- Wave Indicator UI

**Status**: Can use placeholder UI, refine later

### Progression & Balance (2 questions)
- Score System (likely cut for MVP)
- Unlocks & Progression (likely just difficulty scaling)

**Status**: Nice to have, not essential

### Technical (2 questions)
- Performance Targets (can test during development)
- Display Scaling (can handle during implementation)

**Status**: Can be determined during development

### Content (2 questions)
- Tutorial Design (can design after core mechanics)
- Sell/Buy Mechanic (can use simple implementation)

**Status**: Can refine during playtesting

### Platform & Distribution (2 questions)
- Platform Decision
- Engine/Framework Selection

**Status**: Should decide early, but doesn't block core development

### Art & Audio (2 questions)
- Art Style Definition
- Audio Requirements

**Status**: Can use placeholder art, define style during development

### Level Design Details (3 questions)
- Terrain Void Hole (can cut for MVP)
- Difficulty Progression (can refine during playtesting)
- Level Count & Scope (can decide based on time)

**Status**: Can refine during development

---

## 📊 Dependency Analysis

### Critical Path (Must Solve in Order)

```
1. Rune Ignition Mechanics
   ↓
2. Core Rune Mechanics (Explosive, Acceleration, Status, Enemy Affector)
   ↓
3. Advanced Redirect Direction Change
   ↓
4. Portal Rune Pairing
   ↓
5. Resource System (all 4 questions together)
   ↓
6. Enemy Types & Wave Details
   ↓
7. Initial Elements Design
   ↓
8. [Can start coding core systems]
```

### Parallel Work Streams

**Can solve simultaneously:**
- Explosive, Acceleration, Status, Enemy Affector runes (after ignition mechanics)
- Resource system questions (all together)
- UI questions (can defer)

---

## 🎯 Recommended Resolution Plan

### Week 1: Core Mechanics (BLOCKING)
**Days 1-2:**
1. ✅ Rune Ignition Mechanics (CRITICAL - do first)
2. ✅ Explosive Rune Mechanics
3. ✅ Acceleration Rune Details
4. ✅ Status Runes Complete List
5. ✅ Enemy Affector Runes

**Days 3-4:**
6. ✅ Advanced Redirect Direction Change
7. ✅ Portal Rune Pairing
8. ✅ Rune Upgrade Options (DECIDE: Cut for MVP?)

**Result**: Can start coding rune system

---

### Week 2: Systems (BLOCKING LEVEL DESIGN)
**Days 1-2:**
9. ✅ Resource System Details (all 4 questions)
   - Single currency or multiple?
   - Wall costs
   - Rune costs (per type)
   - Wall limits

**Days 3-4:**
10. ✅ Enemy Types & Characteristics
11. ✅ Wave Details (enemy counts, timing)
12. ✅ Initial Elements Design

**Result**: Can start creating levels

---

### Week 3+: Polish (CAN DEFER)
- UI/UX design
- Tutorial design
- Art style definition
- Platform/engine decision
- Score system (if needed)
- Difficulty progression refinement

---

## ⚠️ Critical Gaps & Risks

### 1. Inconsistency Found
**Issue**: GDD says "Player clicks furnace to fire" but we resolved it as "automatic launch"

**Status**: ✅ Already fixed in latest GDD update

### 2. Missing Information
**Issue**: No clear definition of what "ignites" means for runes

**Impact**: Blocks all rune implementation

**Action**: **SOLVE IMMEDIATELY** (Tier 1, Question 1)

### 3. Scope Creep Risk
**Issue**: Many rune types defined, but mechanics unclear

**Risk**: May be too complex for game jam timeline

**Action**: Consider cutting some rune types for MVP (Status Runes? Enemy Affector?)

### 4. Balance Unknown
**Issue**: No damage values, health values, or resource costs defined

**Impact**: Cannot balance game

**Action**: Define placeholder values, refine during playtesting

---

## 📋 Immediate Action Items

### Must Do This Week (Before Coding):
1. **Rune Ignition Mechanics** - Define hit detection
2. **Explosive Rune** - Define what "explode" does
3. **Acceleration Rune** - Define speed increase
4. **Status Runes** - Define list or cut for MVP
5. **Enemy Affector Runes** - Define or cut for MVP
6. **Advanced Redirect** - Define direction change method
7. **Portal Pairing** - Define pairing method
8. **Upgrade Scope** - DECIDE: Cut for MVP?

### Should Do This Week (Before Level Design):
9. **Resource System** - Define costs and amounts
10. **Enemy Types** - Define at least 2-3 types
11. **Initial Elements** - Define basic structure

### Can Defer:
- Everything else (UI, Art, Audio, Platform, etc.)

---

## 🎮 MVP Scope Recommendation

### Include in MVP:
- ✅ Fireball (automatic launch, cardinal directions)
- ✅ Walls (block enemies)
- ✅ Redirect Rune (fixed direction)
- ✅ Advanced Redirect Rune (if direction change is simple)
- ✅ Portal Rune (one pair)
- ✅ Explosive Rune (if mechanics are simple)
- ✅ Acceleration Rune (if mechanics are simple)
- ✅ Basic Resource System
- ✅ 2-3 Enemy Types
- ✅ 3-5 Levels

### Cut for MVP:
- ❌ Status Runes (complex, can add later)
- ❌ Enemy Affector Runes (complex, can add later)
- ❌ Rune Upgrades (focus on variety over upgrades)
- ❌ Score System (not essential)
- ❌ Void Holes (can add later)
- ❌ Multiple Portal Pairs (start with one pair)

---

## 📈 Progress Tracking

### Resolved: 3/33 (9%)
- ✅ Shoot Timing
- ✅ Player Character  
- ✅ Furnace Health

### Critical Blockers: 8/33 (24%)
- 🔴 Rune Ignition Mechanics
- 🔴 Advanced Redirect Direction
- 🔴 Explosive Rune
- 🔴 Acceleration Rune
- 🔴 Status Runes
- 🔴 Enemy Affector Runes
- 🔴 Portal Pairing
- 🔴 Upgrade Scope

### Level Design Blockers: 6/33 (18%)
- 🟡 Resource System (4 questions)
- 🟡 Enemy Types
- 🟡 Initial Elements

### Can Defer: 16/33 (48%)
- 🟢 UI, Art, Audio, Platform, etc.

---

## 🚀 Next Steps

1. **IMMEDIATELY**: Solve Rune Ignition Mechanics (Tier 1, #1)
2. **This Week**: Solve all Tier 1 questions (8 total)
3. **Next Week**: Solve Tier 2 questions (6 total)
4. **Then**: Start coding core systems
5. **Parallel**: Answer Tier 3 questions during development

---

**Status**: Ready to systematically resolve Tier 1 questions. Recommend starting with Rune Ignition Mechanics as it blocks everything else.
