# Level Design Guide

**Version**: 1.0  
**Last Updated**: [Current Date]  
**Purpose**: Guide for level designers creating levels for Furnace

---

## Overview

Levels in Furnace are hand-crafted puzzle/strategy challenges where players place walls and runes to guide a fireball through enemies. Each level is a single wave that begins when the fireball automatically launches.

---

## Level Structure

### Core Components
- **Grid**: 13x8 grid, 32x32 pixel tiles
- **Furnace**: Fixed at top of screen, fires fireball downward automatically
- **Spawn Points**: Flexible number of spawning tiles where enemies spawn
- **Initial Elements**: Pre-placed walls and runes (non-editable by player)
- **Player Resources**: Fixed amount per level (varies by difficulty)

### Level Flow
1. **Build Phase**: Player places walls/runes with fixed resources
2. **Level Start**: Fireball automatically launches downward from furnace
3. **Active Phase**: Enemies spawn staggered from spawn points, fireball travels
4. **Resolution**: Level ends when all enemies defeated OR furnace destroyed

---

## Initial Elements

### Purpose
Initial elements serve **both tutorial and challenge purposes**:
- **Tutorial**: Demonstrate mechanics, show examples, guide learning
- **Challenge**: Create puzzle constraints, strategic obstacles, difficulty

### Design Guidelines

#### Tutorial Levels
- **More initial elements** to demonstrate mechanics
- **Strategic placement** to guide player learning
- **Show examples** of each rune type in action
- **Guide player** toward understanding core concepts

#### Challenge Levels
- **Fewer initial elements** to give player more freedom
- **Used as constraints** for puzzle-solving
- **Create strategic challenges** through placement
- **Vary by level** based on design needs

### Placement Strategy
- Initial elements are **non-editable** by player
- Can be used to:
  - Guide fireball path
  - Create obstacles
  - Demonstrate rune interactions
  - Set up puzzle constraints
  - Teach mechanics progressively

### Quantity
- **Varies by level** based on purpose
- Tutorial levels: More elements (teaching)
- Challenge levels: Fewer elements (puzzle constraints)
- No fixed number - use what serves the level's purpose

---

## Difficulty Progression

### Level Design Constraints
Difficulty increases through:
1. **More spawn points** - Enemies come from multiple locations
2. **More enemies** - Higher enemy counts per level
3. **More enemy types** - Introduce new enemy types in later levels
4. **Fewer resources** - Less resources available for player
5. **Strategic initial elements** - Initial elements create harder puzzles

### Designer Control
- **All difficulty factors are designer-controlled per level**
- No fixed formulas - designers set enemy counts, resources, spawn points per level
- Level interface/editor allows designers to configure all difficulty parameters
- General guidance: Increase difficulty through the factors listed above

### Enemy Introduction
- **Level 1 (Tutorial)**: Basic Enemy only
- **Level 2+**: Introduce Fast Enemy
- **Level 3+**: Introduce Tank Enemy (if implemented)

### Resource Scaling
- Early levels: More resources (easier)
- Later levels: Fewer resources (harder)
- Should allow placement of several runes + walls

---

## Level Editor Interface

### Required Features
- **Grid Editor**: Place walls, runes, spawn points, initial elements
- **Enemy Wave Designer**: Define enemy types, counts, spawn timing
- **Pathfinding Preview**: Show enemy path before level starts
- **Resource Allocation**: Set fixed resources per level
- **Validation**: Ensure valid path exists from spawn to furnace

### Designer Tools Needed
- Place spawning tiles (enemy spawn points)
- Place initial walls/runes (non-editable)
- Define enemy wave (types, counts, timing)
- Set resource amount
- Test pathfinding

---

## Design Principles

### Core Principles
1. **Valid Path Required**: Must always have valid path from spawn to furnace
2. **Strategic Choices**: Give player meaningful decisions
3. **Progressive Teaching**: Introduce mechanics gradually
4. **Balanced Challenge**: Difficulty should scale appropriately
5. **Clear Goals**: Player should understand what to do

### Best Practices
- Start simple, increase complexity
- Use initial elements to guide or challenge
- Test pathfinding before finalizing level
- Balance resources vs challenge
- Ensure fireball can reach all enemies (or make it a puzzle)

---

## Level Count (MVP)

- **3 levels total** for MVP
  - **Level 1**: Tutorial level (teaches core mechanics)
    - Hands-off teaching approach (guided by level design)
    - First mechanic: Fireball kills enemies, enemies kill furnace
    - Main runes: Redirect runes and editing them to point at each other
    - Nearly guaranteed win (players just need to rotate runes properly)
  - **Level 2**: Challenge level (increasing difficulty)
  - **Level 3**: Challenge level (increasing difficulty)
- **Hand-crafted** (not procedural)

---

## Summary

**Initial Elements**: Serve both tutorial and challenge purposes. Use more in tutorial levels to teach, fewer in challenge levels for puzzle constraints. Quantity varies by level based on design needs.

**Difficulty**: Progresses through more spawn points, more enemies, more enemy types, fewer resources, and strategic initial element placement.

**Design**: Hand-crafted levels with clear progression, valid paths, and meaningful strategic choices.

---

**Status**: Ready for level designers to begin creating levels.
