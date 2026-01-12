# Quick Wins Implementation Plan

**Phase**: Phase 1 - Foundation & Quick Wins  
**Source**: `docs/productionization-plan.md` Section 1 & Phase 1  
**Status**: Ready to Begin  
**Dependencies**: None (can start immediately)

---

## Overview

These are immediately impactful polish changes and critical fixes that can be implemented quickly to improve player experience. All items have no dependencies and can be started immediately.

---

## Quick Wins Checklist

### Critical Fixes (High Priority)

- [ ] **1. Fix Portal Cost Bug**
  - **Issue**: Portal cost counting per tile on restart
  - **Fix**: Correct cost calculation logic
  - **Impact**: Prevents player frustration and negative reviews
  - **Files to Check**: 
    - `godot/scripts/game/game_scene.gd` (placement/resource logic)
    - `godot/scripts/game/placement_manager.gd` (cost calculation)
    - Portal rune placement logic

- [ ] **2. Remove Screen Shake from Explosive Rune**
  - **Issue**: Screen shake annoying in late-game
  - **Fix**: Remove screen shake from explosive rune activation
  - **Impact**: Improves late-game experience, reduces visual fatigue
  - **Files to Check**:
    - `godot/scripts/entities/runes/explosive_rune.gd`
    - `godot/scripts/game/visual_effects_manager.gd` (if screen shake is centralized)
    - Search for "screen shake" or "shake" in explosive rune code

- [ ] **3. Add Pause Menu Button**
  - **Issue**: No on-screen pause button
  - **Fix**: Add pause button in top-left corner
  - **Impact**: Essential for player control, especially on mobile
  - **Files to Modify**:
    - `godot/scenes/game/game_scene.tscn` (add button to UI)
    - `godot/scripts/game/game_scene.gd` (wire up button)
    - `godot/scripts/ui/pause_menu.gd` (ensure pause menu exists)

- [ ] **4. Add Clear Board Button**
  - **Issue**: No way to reset level during build phase
  - **Fix**: Add clear board button (always visible during build phase, resets level)
  - **Impact**: Improves UX, allows experimentation without restarting
  - **Files to Modify**:
    - `godot/scenes/game/game_scene.tscn` (add button to build phase UI)
    - `godot/scripts/game/game_scene.gd` (implement reset logic)
    - May need to reset: player-placed items, resources, level state

### Quick Wins (Medium Priority)

- [ ] **5. Add Fireball Die Animation**
  - **Current**: Fireball disappears instantly
  - **Fix**: Simple fade out animation
  - **Impact**: Better visual feedback, more polished feel
  - **Files to Modify**:
    - `godot/scripts/entities/fireball.gd` (add fade animation in `_destroy()`)
    - May need to delay actual destruction until animation completes

- [ ] **6. Implement Audio Mixing/Ducking**
  - **Issue**: Too many sounds overwhelming players
  - **Fix**: Add audio mixing/ducking (reduce SFX when many sounds play)
  - **Impact**: Significantly improves audio experience
  - **Files to Modify**:
    - `godot/scripts/autoload/audio_manager.gd` (add mixing/ducking logic)
    - May need to track concurrent sound count and reduce volume

- [ ] **7. Create Tutorial Level 0**
  - **Current**: No dedicated tutorial
  - **Fix**: Create Level 0 before Level 1 (increment all existing levels by 1)
  - **Content**: Fireball + basic placement (place a rune, see it activate)
  - **Impact**: Essential for onboarding, addresses playtester feedback
  - **Files to Create/Modify**:
    - `godot/resources/levels/level_0.tres` (new tutorial level)
    - Update level progression logic to start at level 0
    - Increment all existing level numbers by 1

- [ ] **8. Increment All Existing Levels by 1**
  - **Reason**: Make room for tutorial Level 0
  - **Files to Modify**:
    - All `level_X.tres` files need level number incremented
    - Level progression logic updated
    - Any hardcoded level references updated

- [ ] **9. Add More Tutorial Levels**
  - **Current**: Players struggle to understand mechanics initially
  - **Fix**: Add a few more levels at the very beginning for easier on-ramp
  - **Impact**: Reduces player confusion, improves retention
  - **Files to Create**:
    - Additional tutorial levels (level_1, level_2, etc. after level_0)
    - Focus on gradual mechanic introduction

---

## Implementation Order

### Recommended Sequence

1. **Critical Fixes First** (Items 1-4)
   - These fix real bugs/UX issues
   - High impact, relatively quick
   - Prevents player frustration

2. **Visual Polish** (Item 5)
   - Fireball die animation
   - Quick visual improvement

3. **Audio Improvement** (Item 6)
   - Audio mixing/ducking
   - Improves overall experience

4. **Tutorial Content** (Items 7-9)
   - Level 0 creation
   - Level renumbering
   - Additional tutorial levels
   - More time-consuming but important

---

## Testing Checklist

After implementing each item:

- [ ] Test the fix/feature works as expected
- [ ] Verify no regressions introduced
- [ ] Test on target platforms (web, mobile if applicable)
- [ ] Verify UI elements are accessible and functional
- [ ] Check that level progression still works (for level renumbering)

---

## Notes

- All items can be worked on in parallel if multiple developers
- Items 1-4 are highest priority (critical fixes)
- Items 7-9 are more time-consuming (content creation)
- Level renumbering (item 8) should be done carefully to avoid breaking references

---

## Next Steps

1. Review current codebase to understand implementation details
2. Start with Critical Fix #1 (Portal Cost Bug)
3. Work through checklist systematically
4. Test each item before moving to next
5. Update this document with progress

---

**Status**: Ready to begin implementation  
**Last Updated**: [Current Date]
