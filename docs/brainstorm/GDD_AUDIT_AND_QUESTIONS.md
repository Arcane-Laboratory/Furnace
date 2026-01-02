# Furnace GDD Audit & Critical Questions

## Executive Summary

The brainstorm document provides a solid foundation with a unique core mechanic (single bullet + support towers), but several critical systems need definition before development can proceed effectively. The game concept is innovative but requires clarification on how the core loop actually functions.

---

## High-Level Audit

### ✅ Strengths
1. **Clear Unique Selling Point**: Single bullet mechanic is distinctive
2. **Well-Defined Technical Constraints**: 640x360, pixel perfect, grid system specified
3. **Phase Structure**: Build → Active → Shot loop is clear
4. **Core Systems Identified**: Towers, enemies, furnace, pathfinding

### ⚠️ Areas Needing Definition
1. **Core Mechanic Ambiguity**: The single bullet mechanic is central but undefined
2. **Player Agency**: Unclear what player does beyond building and shooting
3. **Tower Interactions**: How towers modify the bullet needs specification
4. **Resource Economy**: System mentioned but not designed
5. **Balance Framework**: No metrics or targets defined

---

## CRITICAL QUESTIONS - Must Answer Before Development

### 🔴 Priority 1: Core Gameplay Loop

#### Q1: The Single Bullet - What Actually Happens?
**Current State**: "at some point shoot one bullet"

**Questions**:
- Does the bullet travel through space or is it instant?
- What is its damage/effect?
- Can it hit multiple enemies?
- What happens after it hits something?
- Can it be modified by towers before firing, during travel, or after impact?

**Impact**: This defines the entire game. Without clarity, tower design is impossible.

**Recommendation**: Decide on one of these models:
- **Model A - Traveling Bullet**: Bullet travels from furnace, can be modified by towers it passes through
- **Model B - Instant Shot**: Click furnace, bullet instantly affects enemies based on tower modifications
- **Model C - Area Effect**: Bullet creates an effect that towers modify

---

#### Q2: When Can the Player Shoot?
**Current State**: "at some point shoot one bullet"

**Questions**:
- Can player shoot at any time during active phase?
- Only once per wave? Once per level?
- What if player never shoots? Do enemies just reach furnace?
- Is there a time limit or optimal timing window?

**Impact**: Defines player agency and tension in active phase.

**Recommendation**: Consider:
- Shoot once per wave, timing matters
- OR shoot once per level, must choose perfect moment
- OR can shoot anytime but with cooldown/limitation

---

#### Q3: How Do Towers Modify the Bullet?
**Current State**: Towers have "passive abilities" and "active abilities"

**Questions**:
- **Passive towers**: "when enemies are nearby OR when tower is shot"
  - Which is it? Both? How does "when tower is shot" work?
  - Do they modify the bullet before it fires, during travel, or after?
- **Active towers**: Player clicks to activate
  - When can they be activated? During build phase? Active phase?
  - Do they modify the bullet or affect enemies directly?
- **Portal/Duplicator/Reroute**: How do these work mechanically?
  - Portal: Does bullet teleport? Bounce? Create new bullet?
  - Duplicator: Creates how many bullets? Same path or different?
  - Reroute: Changes direction how? Player chooses or automatic?

**Impact**: This is the core strategic depth. Without clarity, level design and balance impossible.

**Recommendation**: Create detailed spec for each tower type with:
- Trigger conditions
- Effect mechanics
- Visual feedback
- Interaction rules

---

### 🔴 Priority 2: Player Character & Agency

#### Q4: What Can the Player Do?
**Current State**: "Movement + abilities" mentioned but undefined

**Questions**:
- Is player a character on screen or just a cursor?
- Can player move during active phase?
- What abilities beyond building/shooting?
- Can player interact with enemies directly?

**Impact**: Defines player role and engagement level.

**Recommendation**: Decide:
- **Option A**: Player is just a builder (cursor only, no character)
- **Option B**: Player has a character with limited movement/abilities
- **Option C**: Player has abilities that affect gameplay (repair towers, slow time, etc.)

---

### 🔴 Priority 3: Resource & Economy System

#### Q5: Resource System Design
**Current State**: "limited resources for special towers", "wall towers are very cheap or free"

**Questions**:
- What is the resource? (Gold? Energy? Materials?)
- How is it earned? (Per wave? Per kill? Fixed per level?)
- How much do special towers cost?
- Can resources be spent during active phase or only build phase?
- Are there multiple resource types?

**Impact**: Defines strategic constraints and difficulty curve.

**Recommendation**: Design simple system:
- One resource type
- Earned per wave completion
- Costs: Walls = free, Basic towers = cheap, Special towers = expensive
- OR: Fixed budget per level (puzzle-style)

---

### 🔴 Priority 4: Enemy & Wave System

#### Q6: Enemy Types & Characteristics
**Current State**: "A few types", "lots of enemies"

**Questions**:
- How many enemy types? (2? 3? 5?)
- What makes each type different?
  - Health?
  - Speed?
  - Special abilities?
  - Visual design?
- How many enemies per wave? Per level?
- How does difficulty scale?

**Impact**: Defines content scope and balance targets.

**Recommendation**: Start simple:
- 2-3 enemy types max for game jam
- Clear differentiation (fast/weak, slow/strong, special ability)
- Define exact counts for first 3 levels as reference

---

#### Q7: Wave System Structure
**Current State**: "Each level has pre-set waves"

**Questions**:
- How many waves per level?
- How many enemies per wave?
- Do waves have breaks between them? (Return to build phase?)
- How does difficulty progress?

**Impact**: Defines level structure and pacing.

**Recommendation**: Define:
- Waves per level (3-5 for game jam?)
- Whether build phase happens between waves or only at start
- Difficulty curve formula

---

### 🟡 Priority 5: Systems & Polish

#### Q8: Tower Upgrades
**Current State**: "? Upgrades" - question mark indicates uncertainty

**Questions**:
- Are upgrades in scope for game jam?
- What can be upgraded? (Damage? Range? Effect strength?)
- When can upgrades happen? (Build phase? Between waves?)
- How are upgrades purchased?

**Impact**: Adds complexity. May be out of scope.

**Recommendation**: **Consider cutting for MVP** - focus on tower variety instead of upgrades.

---

#### Q9: Scoring System
**Current State**: "? Score ?" - question marks indicate uncertainty

**Questions**:
- What is score based on? (Enemies killed? Time? Efficiency?)
- What's the purpose? (Leaderboard? Progression? Feedback?)
- Is this essential for game jam?

**Impact**: Nice to have but not core mechanic.

**Recommendation**: **Consider cutting for MVP** or make very simple (enemies killed = score).

---

#### Q10: Void Holes
**Current State**: "? Void Hole - enemies can cross, you can't build"

**Questions**:
- What is the purpose of void holes?
- How do they differ from regular terrain?
- Are they necessary?

**Impact**: Adds complexity to pathfinding and level design.

**Recommendation**: **Consider cutting for MVP** - focus on core terrain types first.

---

### 🟡 Priority 6: Technical & Scope

#### Q11: Performance Targets
**Current State**: "Performant with lots of enemies/towers/bullets"

**Questions**:
- What is "lots"? (50? 100? 500?)
- Target FPS? (60? 30?)
- What engine/framework?
- Team's experience level?

**Impact**: Defines technical constraints and feasibility.

**Recommendation**: Set specific targets:
- Max enemies on screen: 100?
- Target FPS: 60
- Test early with performance profiling

---

#### Q12: Level Count & Scope
**Current State**: "Levels" mentioned but count undefined

**Questions**:
- How many levels for game jam?
- Tutorial level needed?
- Procedural or hand-crafted?

**Impact**: Defines content scope.

**Recommendation**: Start small:
- 3-5 levels for game jam
- 1 tutorial level
- Hand-crafted (procedural adds complexity)

---

## RISK ASSESSMENT

### 🔴 High Risk

1. **Core Mechanic Ambiguity**
   - **Risk**: Building game around undefined mechanic
   - **Impact**: May need major rework
   - **Mitigation**: Answer Q1-Q3 before any coding

2. **Scope Creep**
   - **Risk**: Many "?" items suggest uncertainty
   - **Impact**: May not finish in time
   - **Mitigation**: Cut features, focus on core loop

3. **Balance Complexity**
   - **Risk**: Single bullet + many towers = complex interactions
   - **Impact**: Game may be too easy/hard, unfun
   - **Mitigation**: Iterative playtesting, start simple

### 🟡 Medium Risk

4. **Performance with Many Enemies**
   - **Risk**: May struggle with target enemy count
   - **Impact**: Need optimization or reduce scope
   - **Mitigation**: Early performance testing, use efficient engine

5. **Pathfinding Validation**
   - **Risk**: Ensuring valid paths exist is complex
   - **Impact**: Players may get stuck, frustration
   - **Mitigation**: Robust pathfinding, clear UI feedback

### 🟢 Low Risk

6. **Art Asset Scope**
   - **Risk**: Many sprites needed
   - **Impact**: May need placeholder art
   - **Mitigation**: Use simple art style, prioritize gameplay

---

## RECOMMENDED RESOLUTION PRIORITY

### Before Any Coding:
1. ✅ Answer Q1: Define the single bullet mechanic
2. ✅ Answer Q2: Define when player can shoot
3. ✅ Answer Q3: Define how towers modify bullet
4. ✅ Answer Q4: Define player character/abilities

### Before Level Design:
5. ✅ Answer Q5: Design resource system
6. ✅ Answer Q6: Define enemy types
7. ✅ Answer Q7: Define wave structure

### Can Define During Development:
8. ⚠️ Answer Q8: Tower upgrades (consider cutting)
9. ⚠️ Answer Q9: Scoring (consider cutting)
10. ⚠️ Answer Q10: Void holes (consider cutting)
11. ✅ Answer Q11: Performance targets
12. ✅ Answer Q12: Level count

---

## NEXT STEPS

1. **Team Discussion**: Review this audit together
2. **Answer Critical Questions**: Start with Priority 1 (Q1-Q4)
3. **Prototype Core Loop**: Build minimal prototype to test bullet mechanic
4. **Fill GDD**: Update GDD with answers
5. **Cut Features**: Remove items marked "consider cutting" if needed
6. **Begin Development**: Start coding once core loop is defined

---

## QUESTIONS FOR YOU

Let's discuss these in order of priority. I recommend we start with:

1. **The Single Bullet**: What's your vision? Does it travel? Is it instant? How should it feel?

2. **Tower Interactions**: When you imagine a "portal tower" or "duplicator tower," what exactly happens? Walk me through a scenario.

3. **Player Agency**: Should the player feel like a builder/strategist, or should they have more active involvement during the active phase?

4. **Scope**: For a game jam, what's realistic? Should we cut upgrades, scoring, void holes to focus on the core loop?

What would you like to tackle first?
