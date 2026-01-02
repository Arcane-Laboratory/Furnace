# GDD Audit - Conflicts and Inconsistencies

**Date**: [Current Date]  
**Purpose**: Identify conflicts between `.cursor/plans` and the GDD, and internal GDD inconsistencies

---

## Critical Conflicts Found

### 1. Fireball Launch Mechanism - ✅ RESOLVED

**GDD Section 3.1.2 (Active Phase)**:
- "Fireball automatically shoots when level starts (no player input needed)"

**GDD Section 3.4 (The Fireball)**:
- ~~"**Firing**: Player clicks furnace to fire the fireball"~~ (REMOVED)
- ✅ **Fixed**: "Fireball automatically launches when level starts (no player input needed)"

**Status**: ✅ **RESOLVED** - Conflict fixed in GDD section 3.4

---

## GDD Internal Inconsistencies

### 2. Fireball Return to Furnace - ✅ RESOLVED

**GDD Section 1.5 (Unique Selling Points)**:
- ~~"Fireball can potentially return to furnace for reuse"~~ (REMOVED)
- ✅ **Fixed**: "Post-MVP: Fireball return to furnace for reuse (via rune)"

**GDD Section 3.4 (The Fireball)**:
- "Fireball does NOT automatically return to furnace"
- "[Future consideration: Could add a rune that returns fireball to furnace for reuse]"

**Status**: ✅ **RESOLVED** - Section 1.5 updated to clarify this is post-MVP

---

### 3. Platform Information - ✅ RESOLVED

**GDD Section 1.4**:
- ~~"[To be determined - PC/Web/Mobile]"~~ (REMOVED)
- ✅ **Fixed**: "MVP: Web (HTML5 export via Godot), distributed via Itch.io" + "Post-MVP: Mobile (iOS/Android), Discord Activity"

**GDD Section 11.1**:
- "MVP: Web browser (HTML5 export via Godot)"
- "Distribution: Itch.io (game jam submission)"

**Status**: ✅ **RESOLVED** - Section 1.4 updated with platform information

---

### 4. Build Phase Duration - ✅ RESOLVED

**GDD Section 3.1.1 (Build Phase)**:
- ~~"**Duration**: Until player manually ends phase or timer expires"~~ (REMOVED)
- ✅ **Fixed**: "**Duration**: Until player manually ends phase (no timer - unlimited build time)"

**GDD Section 3.1.2 (Active Phase)**:
- No mention of timer in build phase

**Status**: ✅ **RESOLVED** - Clarified that build phase has no timer, unlimited until player clicks Start

---

## Plan vs GDD Conflicts

### 5. Initial Scaffold Plan - No Conflicts Found

**Plan File**: `.cursor/plans/initial_scaffold.md`

**Review**: The initial scaffold plan is consistent with the GDD:
- ✅ Grid size (13x8, 32x32 tiles) matches
- ✅ Autoload structure (SceneManager, GameManager, GameConfig) is appropriate
- ✅ Phase management (BUILD_PHASE, ACTIVE_PHASE) matches GDD
- ✅ UI scenes match GDD requirements

**No conflicts identified** - plan aligns with GDD specifications

---

## Recommendations

### ✅ All Fixes Applied

1. **✅ Fix Fireball Launch Conflict** (Critical) - **RESOLVED**
   - Removed "Player clicks furnace to fire the fireball" from section 3.4
   - Updated to: "Fireball automatically launches when level starts (no player input needed)"
   - Now matches section 3.1.2 and all resolved design decisions

2. **✅ Update Platform Section** (High Priority) - **RESOLVED**
   - Changed section 1.4 from "[To be determined]" to "Web (HTML5) for MVP, Mobile/Discord post-MVP"

3. **✅ Clarify Build Phase Duration** (Medium Priority) - **RESOLVED**
   - Removed "or timer expires" from section 3.1.1
   - Clarified: "Until player manually ends phase (no timer - unlimited build time)"

4. **✅ Update Unique Selling Points** (Low Priority) - **RESOLVED**
   - Updated "Fireball can potentially return to furnace for reuse" to clarify it's post-MVP
   - Changed to: "Post-MVP: Fireball return to furnace for reuse (via rune)"

---

## Verification Checklist

### Core Mechanics
- [x] Fireball launch: Automatic (needs fix in section 3.4)
- [x] Fireball movement: Cardinal directions only
- [x] Fireball damage: Fixed damage, infinite piercing
- [x] Rune activation: Tile center collision
- [x] Player character: Cursor only

### Systems
- [x] Build phase: Place walls/runes, sell for refund
- [x] Active phase: Fireball launches automatically, player observes
- [x] Level structure: One level = one wave
- [x] Level count: 3 levels (1 tutorial + 2 challenge)

### Technical
- [x] Grid: 13x8, 32x32 tiles
- [x] Platform: Web/Itch.io (needs update in section 1.4)
- [x] Performance: 30 FPS min, 100 enemies max

---

## Summary

**Total Conflicts Found**: 1 critical, 3 minor inconsistencies

**Critical Issue**: ✅ **RESOLVED** - Fireball launch mechanism contradiction fixed

**Plan Status**: ✅ No conflicts between `.cursor/plans/initial_scaffold.md` and GDD

**All Issues Resolved**:
1. ✅ Fixed fireball launch description in section 3.4
2. ✅ Updated platform information in section 1.4
3. ✅ Clarified build phase duration
4. ✅ Updated unique selling points to clarify post-MVP features

---

**Status**: ✅ Audit complete. All conflicts identified and resolved. GDD is now consistent.
