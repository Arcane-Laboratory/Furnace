# Furnace - Open Questions Summary

This document provides a comprehensive list of all open questions that need to be resolved before development can proceed. Questions are organized by category.

**Last Updated**: [Current Date]  
**Total Questions**: 33

---

## 🔴 Critical Priority (Core Mechanics)

### Rune Mechanics
1. **Portal Rune Pairing** - Can there be multiple portal pairs? How are portals paired? (First two placed? Color coded? UI indication?)
2. **Advanced Redirect Rune Direction Change** - When/how can player change direction? During build phase? During active phase?
3. **Explosive Rune Mechanics** - What does explode do? Area damage? Visual effect? Does fireball continue after explosion?
4. **Acceleration Rune Details** - How much speed increase? Does it stack with multiple acceleration runes?
5. **Status Runes Complete List** - What statuses are available? How are they applied? Duration? Which enemies affected?
6. **Enemy Affector Runes** - What do these runes do? Examples needed. Complete mechanics.
7. **Rune Ignition Mechanics** - How does fireball ignite runes? Does it need to pass through center or within range? Hit detection details.
8. **Rune Upgrade Options** - Redirect runes can be upgraded for more uses. What other upgrade options exist? Are upgrades in scope for game jam?

### Core Systems
9. **Shoot Timing** - Once per wave or once per level? Can shoot anytime or specific window? What if player never shoots?
10. **Player Character** - Is player a character on screen or just cursor? Can player move during active phase? What abilities beyond building/shooting?
11. **Furnace Health** - Confirm 1 HP (one hit = game over). Any exceptions or mechanics around furnace protection?

---

## 🟡 High Priority (Gameplay Systems)

### Resource System
12. **Resource System Details** - Single currency or multiple types? Costs for walls vs runes? How much per level?
13. **Wall Costs** - What is the resource cost for placing a wall?
14. **Rune Costs** - What are the resource costs for each rune type? Do costs vary significantly?
15. **Wall Limits** - Is there a separate wall limit? Or just resource-limited?

### Enemy & Wave Systems
16. **Enemy Types & Characteristics** - How many types (2-3 for jam)? What makes each different (health/speed/abilities)? How many enemies per wave? How does difficulty scale?
17. **Wave System Structure** - How many waves per level? How many enemies per wave? Do waves have breaks between them (return to build phase)? How does difficulty progress?

### Level Design
18. **Initial Elements Design** - How many initial walls/runes per level? Are they tutorial elements or part of challenge?
19. **Terrain Void Hole** - Enemies can cross, player cannot build. What is the purpose? Are they necessary for game jam?
20. **Difficulty Progression** - How does difficulty scale across levels? Enemy count progression, enemy type introduction, resource availability, wave difficulty.
21. **Level Count & Scope** - How many levels for game jam (3-5 recommended)? Tutorial level needed? Procedural or hand-crafted?

---

## 🟢 Medium Priority (UI/UX)

22. **Pathfinding Visualization** - How is enemy path shown to player? Visual style? When is it displayed?
23. **UI Resource Display** - Design exact placement, style, and information shown (current amount, costs, etc.).
24. **Wave Indicator UI** - Design exact placement, style, and information shown (current wave, total waves, next wave timer, etc.).

---

## 🔵 Lower Priority (Polish & Systems)

### Progression & Balance
25. **Score System** - What is score based on (enemies killed/time/efficiency)? What is purpose (leaderboard/progression/feedback)? Is this essential for game jam?
26. **Unlocks & Progression** - Are there unlocks between levels? New runes? New abilities? Or is progression just level difficulty?

### Technical
27. **Performance Targets** - What is target enemy count (50/100/500)? Target FPS (60/30)? What engine/framework? Team experience level?
28. **Display Scaling** - How should 640x360 pixel perfect resolution scale on different screen sizes?

### Content
29. **Tutorial Design** - Design tutorial level to teach core mechanics: build phase, wall/rune placement, pathfinding validation, active phase, shooting fireball, rune interactions.
30. **Sell/Buy Mechanic** - Free sell/buy, not punished for misplacing. Define exact mechanics: full refund? Can sell during active phase? Any limitations?

### Platform & Distribution
31. **Platform Decision** - Target platform (PC/Web/Mobile)? Distribution method (itch.io/Steam/jam submission)? Multiplayer priority?
32. **Engine/Framework Selection** - What engine/framework will be used? Consider team experience, performance requirements, and platform targets.

### Art & Audio
33. **Art Style Definition** - Pixel perfect 640x360 suggests pixel art. Define exact art style, color palette, and visual theme (dark/cold theme from everlasting darkness/cold).
34. **Audio Requirements** - Define needed sound effects and music. Background music style? Sound effects for wall/rune placement, fireball firing, enemy spawn/death, furnace destruction, UI.

---

## ✅ Completed Questions

- ✅ Q1: Single Bullet/Fireball Mechanic - RESOLVED
- ✅ Fireball Cardinal Directions - RESOLVED
- ✅ Fireball Return to Furnace - RESOLVED (does not return)
- ✅ Portal Rune Toggle - RESOLVED (no toggle needed)
- ✅ Redirect Rune "Slow" - CANCELLED (no slow-mo mechanics)

---

## 📋 Recommended Resolution Order

### Phase 1: Core Mechanics (Before Any Coding)
1. Rune Ignition Mechanics (affects all runes)
2. All Rune Mechanics (Explosive, Acceleration, Status, Enemy Affector, Advanced Redirect)
3. Portal Rune Pairing
4. Shoot Timing
5. Player Character

### Phase 2: Systems (Before Level Design)
6. Resource System Details
7. Wall & Rune Costs
8. Wall Limits
9. Enemy Types
10. Wave System Structure

### Phase 3: Level Design
11. Initial Elements Design
12. Level Count & Scope
13. Difficulty Progression
14. Tutorial Design

### Phase 4: Polish
15. UI Design (Resource Display, Wave Indicator, Pathfinding Visualization)
16. Sell/Buy Mechanic
17. Score System (if needed)
18. Art & Audio
19. Platform & Engine Decisions

---

## 📝 Notes

- Questions marked with "game jam" considerations may be cut for MVP scope
- Some questions can be answered during development/playtesting
- Critical Priority questions should be answered before coding begins
- High Priority questions should be answered before level design begins

---

**Status**: All questions captured in TODO list. Ready for systematic resolution.
