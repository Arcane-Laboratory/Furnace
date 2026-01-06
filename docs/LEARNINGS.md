# Game Development Learnings

**Project**: Furnace  
**Session**: Core Rune System & Infrastructure Planning  
**Date**: 2024

---

## Key Takeaways

### 1. Incremental Development with QA Gates

**What Worked**:
- Stopping between phases for QA testing before merging PRs
- Using error checking scripts (`godot-check-errors.sh`) after every change
- Creating PRs with comprehensive test checklists
- Verifying bug-free state before proceeding to next phase

**Takeaway**: Always implement QA/PR gates between major feature phases. This prevents bugs from compounding and ensures stable progress.

**Action**: Document QA process in plan files, create test checklists for each phase.

---

### 2. Resource-Driven Design Over Hardcoding

**What Worked**:
- Using `.tres` resource files for buildable items (runes, walls, tiles)
- Centralized configuration in `game_config.gd` with resource loading
- Easy to add new item types by creating resource files

**What Needs Improvement**:
- Still many hardcoded values in `game_config.gd`
- Some balance values scattered across scripts
- No runtime editing of resources

**Takeaway**: Make everything resource-driven from the start. Use resource libraries for all configurable values. This enables:
- Designer-friendly editing
- Runtime debugging/balancing
- Unit testing
- Version control for balance changes

**Action**: Migrate all hardcoded values to resources. Create resource library framework.

---

### 3. Stacking Systems vs Temporary Effects

**What Worked**:
- Converting Acceleration Rune from temporary boost to permanent stacking
- Power Rune with stacking damage bonus
- Stacks decrease on enemy hit (1 stack per hit)
- Visual feedback for stack changes

**Takeaway**: Stacking systems provide more strategic depth than temporary effects. Players can plan around permanent upgrades. Visual feedback is critical for stack systems.

**Action**: Prefer stacking systems for upgrade mechanics. Always show stack count changes visually.

---

### 4. Multi-Use Runes Improve Gameplay

**What Worked**:
- Converting single-use runes (Explosive, Reflect) to multi-use
- Runes remain active and reusable
- Cooldown systems prevent abuse (e.g., Reflect Rune)

**Takeaway**: Single-use items feel wasteful. Multi-use items encourage experimentation and strategic placement. Use cooldowns for balance, not depletion.

**Action**: Design runes/items as multi-use by default. Use cooldowns or other mechanics for balance.

---

### 5. Visual Feedback is Critical

**What Worked**:
- Floating number system for damage, resources, status modifiers
- Status modifier text ("+Speed x5", "+Power x3")
- Color coding (Speed = cyan, Power = orange)
- Explosion effects for visual clarity

**Takeaway**: Players need immediate visual feedback for all game state changes. Text overlays work well for MVP, can upgrade to particle effects later.

**Action**: Always add visual feedback when implementing new mechanics. Reuse existing systems (FloatingNumberManager) before creating new ones.

---

### 6. Depth Sorting Requires Careful Planning

**What Worked**:
- Using `z_index` based on Y position for depth sorting
- Walls render above enemies at same Y position (`z_index = grid_y * 10 + 5`)
- Floating numbers render above everything (`z_index = 1000`)

**Takeaway**: 2D depth sorting needs clear rules. Document z_index calculation patterns. Test edge cases (enemies at same Y, overlapping sprites).

**Action**: Create z_index guidelines document. Test depth sorting with multiple entities at same position.

---

### 7. Placement Validation Logic Gets Complex

**What Worked**:
- Centralized placement validation in `placement_manager.gd`
- Pathfinding validation to prevent blocking all paths
- Special cases (furnace placement, portal pairing)

**What Was Challenging**:
- Furnace placement rules (can place runes but not walls)
- Portal pairing logic
- Edge cases in validation

**Takeaway**: Placement rules accumulate complexity. Document all special cases. Consider making placement rules data-driven (resource-based rules).

**Action**: Create placement rules documentation. Consider rule-based system for complex validation.

---

### 8. Error Detection and Logging

**What Worked**:
- Godot error watcher scripts (`godot-find-log.sh`, `godot-error-parser.sh`)
- Checking errors after every code change
- Cross-platform log file detection

**Takeaway**: Automated error checking is essential. Don't rely on manual checking. Integrate error checking into development workflow.

**Action**: Create cursor hook to auto-check errors after editing GDScript files. Make error checking part of commit process.

---

### 9. Planning Before Implementation

**What Worked**:
- Creating detailed implementation plans before coding
- Resolving design questions systematically
- Documenting decisions in `iteration-resolutions.md`
- Breaking work into phases with clear deliverables

**Takeaway**: Planning prevents rework. Resolve ambiguities before coding. Document decisions for future reference.

**Action**: Always create implementation plan before starting work. Use plan files to track progress.

---

### 10. Infrastructure Improvements Are High Value

**What Worked**:
- Identifying infrastructure needs early (testing, tooling, CI/CD)
- Creating separate infrastructure plan
- Prioritizing developer experience improvements

**Takeaway**: Infrastructure improvements compound over time. Invest in tooling early. Developer experience directly impacts iteration speed.

**Action**: Allocate time for infrastructure improvements. Don't defer tooling indefinitely.

---

## Technical Patterns That Worked

### Resource Loading Pattern
```gdscript
# Load all resources of a type
func _load_buildable_item_definitions() -> void:
    var definition_paths: Array[String] = [...]
    for path in definition_paths:
        var definition: Resource = load(path)
        buildable_item_definitions[definition.item_type] = definition
```

### Stacking System Pattern
```gdscript
# Add stack
func add_power_stack() -> void:
    power_stacks += 1
    FloatingNumberManager.show_status_modifier("+Power x%d" % power_stacks, position, color)

# Remove stack on hit
func _hit_enemy(enemy: Node2D) -> void:
    deal_damage()
    remove_power_stack()  # Lose 1 stack per hit
```

### Placement Validation Pattern
```gdscript
# Check placement validity
func can_place_at(grid_pos: Vector2i) -> bool:
    # 1. Check bounds
    # 2. Check tile occupancy
    # 3. Check pathfinding (if blocking)
    # 4. Check special rules (furnace, etc.)
    return is_valid
```

---

## Common Pitfalls to Avoid

1. **Hardcoding Values**: Always use resources or config files
2. **Skipping Error Checks**: Check errors after every change
3. **No Visual Feedback**: Always show what's happening to the player
4. **Complex Validation Logic**: Document special cases, consider data-driven rules
5. **Single-Use Items**: Prefer multi-use with cooldowns/limits
6. **Temporary Effects**: Consider stacking systems for upgrades
7. **No Planning**: Always plan before implementing
8. **Deferring Infrastructure**: Tooling improvements compound over time

---

## Process Improvements

### What to Do Next Time

1. **Start with Infrastructure**: Set up error checking, testing, CI/CD early
2. **Resource-First Design**: Make everything resource-driven from the start
3. **Documentation as You Go**: Document patterns and decisions immediately
4. **QA Gates**: Always test between phases, merge PRs before continuing
5. **Visual Feedback First**: Add VFX/text feedback immediately, upgrade later
6. **Plan Before Code**: Resolve design questions before implementation

### What to Avoid

1. **Hardcoding**: Resist the urge to hardcode "just this one value"
2. **Skipping Tests**: Don't skip QA even for "small" changes
3. **Deferring Tooling**: Infrastructure improvements pay off quickly
4. **No Documentation**: Future you will thank present you
5. **Rushing**: Incremental progress with QA gates is faster long-term

---

## Questions to Answer Early

Before starting next game development, answer:

1. **Resource Strategy**: What will be resources vs hardcoded?
2. **Testing Strategy**: How will we test? Unit tests? Integration tests?
3. **Error Detection**: How will we catch errors early?
4. **Visual Feedback**: What feedback systems do we need?
5. **Placement Rules**: What are all the placement edge cases?
6. **Depth Sorting**: What are the z_index rules?
7. **Stacking Systems**: Which mechanics use stacking vs temporary effects?
8. **Infrastructure**: What tooling do we need from day one?

---

## Metrics to Track

- **Error Rate**: How many errors slip through to main?
- **Iteration Speed**: Time from code change to tested in game
- **Rework**: How often do we need to refactor?
- **Documentation**: Is documentation keeping up with code?
- **Test Coverage**: What percentage of systems have tests?

---

## Next Steps

1. Review this document at start of next game project
2. Update with new learnings as development progresses
3. Use as checklist for project setup
4. Share with team for alignment

---

**Remember**: Incremental progress with QA gates beats rushing. Resource-driven design scales better than hardcoding. Visual feedback is non-negotiable. Infrastructure improvements compound over time.
