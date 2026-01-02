# Performance Targets

**Version**: 1.0  
**Last Updated**: [Current Date]  
**Purpose**: Performance specifications and targets for Furnace

---

## Frame Rate Targets

### Target FPS
- **Minimum**: 30 FPS
- **Ideal**: 60 FPS (if achievable)
- **Acceptable**: 30 FPS minimum maintained

---

## Enemy Count Targets

### Maximum Enemies
- **On Screen**: Up to 100 enemies simultaneously
- **Per Level**: Total enemy count per level can exceed 100 (staggered spawning)
- **Performance Consideration**: System should handle 100 enemies on screen at 30 FPS minimum

---

## Engine & Framework

### Godot Engine
- **Engine**: Godot (already in repository)
- **Repository**: https://github.com/Arcane-Laboratory/Furnace/
- **Status**: Base level already started

---

## Performance Optimization Priorities

### Critical Optimizations
1. **Pathfinding**: Efficient pathfinding algorithm (A*, grid-based)
2. **Rendering**: Efficient sprite rendering for enemies
3. **Collision Detection**: Grid-based collision (simple, fast)
4. **Fireball Updates**: Single fireball, simple movement

### Optimization Strategies
- Grid-based systems (pathfinding, collision)
- Object pooling for enemies (if needed)
- Efficient sprite batching
- Limit particle effects
- Optimize rune activation checks

---

## Performance Testing

### Test Scenarios
- 100 enemies on screen simultaneously
- Fireball traveling through multiple runes
- Multiple explosions (if Explosive Runes used)
- Pathfinding with many walls

### Acceptable Degradation
- Frame rate may drop below 60 FPS with 100 enemies
- Must maintain 30 FPS minimum
- Smooth gameplay prioritized over perfect 60 FPS

---

## Technical Considerations

### Godot-Specific
- Use Godot's built-in performance tools
- Optimize node structure
- Efficient scene management
- Consider using Godot's tilemap system for grid

---

**Status**: Performance targets defined. Ready for implementation and testing.
