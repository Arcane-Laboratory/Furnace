# Unanswered Questions from iteration.md

This document lists all unanswered questions, decisions needed, and clarifications required before planning implementation work.

## Core Gameplay Questions

### 1. Difficulty & Scaling
- **Question**: Should we implement the proposed auto-scaling mode with heat increases and randomized waves?
  - **Context**: Document mentions this as a potential solution for difficulty issues
  - **Decision Needed**: Yes/No on implementing this feature
  - **Impact**: Affects level design, enemy spawning, and game mode architecture

- **Question**: What is the exact implementation of the "heat increases" mechanic?
  - **Context**: Mentioned but not defined
  - **Decision Needed**: Define what "heat" means, how it increases, and what effects it has
  - **Impact**: New game system that needs design

### 2. Fireball Damage & Buff System
- **Question**: Should acceleration runes grant damage bonuses in addition to speed?
  - **Context**: Document proposes two alternatives:
    1. Acceleration stacks also grant stacking damage bonus
    2. Separate rune that grants stacking damage bonus (speed vs power choice)
  - **Decision Needed**: Choose one approach or reject both
  - **Impact**: Core gameplay balance, rune design, player strategy

- **Question**: How many acceleration stacks should be lost when fireball hits an enemy?
  - **Context**: Document says "Fireball loses `X` stacks of acceleration upon hitting an enemy" but `X` is undefined
  - **Decision Needed**: Define the exact number (fixed amount? percentage? all stacks?)
  - **Impact**: Buff zone strategy viability, game balance

- **Question**: Should acceleration stacks be uncapped?
  - **Context**: Document proposes removing speed cap for acceleration
  - **Decision Needed**: Yes/No, and if yes, what are the performance/balance implications?
  - **Impact**: Game balance, potential exploits, performance

### 3. Enemy Scrap/Drops System
- **Question**: Should enemies drop scrap/resources during active phase?
  - **Context**: Document mentions "enemies could drop scrap, which could allow you to build and access other parts of the level"
  - **Decision Needed**: Yes/No on implementing scrap drops
  - **Impact**: New resource system, active phase building, level design

- **Question**: If scrap is implemented, what can players build with it during active phase?
  - **Context**: Mentioned but not specified
  - **Decision Needed**: Define what structures can be built mid-wave
  - **Impact**: Active phase gameplay, UI changes, placement system

- **Question**: Should tile upgrades be enabled if scrap system is implemented?
  - **Context**: Document says "maybe enemies drop scrap and tiles can be upgraded during active mode"
  - **Decision Needed**: Yes/No, and what upgrade options exist?
  - **Impact**: Upgrade system design, active phase complexity

## Rune Balance & Design Questions

### 4. One-Use vs Multi-Use Runes
- **Question**: What should the exact cost difference be between one-use and multi-use runes?
  - **Context**: Document says "one-use tiles should be cheaper or more impactful" and "repeated-use tiles should be more expensive, weaker, or limited"
  - **Decision Needed**: Define specific cost ratios and impact values
  - **Impact**: Rune pricing, player strategy, game balance

- **Question**: Should reflect rune be cheaper, more versatile, or have more uses?
  - **Context**: Document notes "reflect rune is less versatile than redirect rune, is more expensive, and only works once"
  - **Decision Needed**: Choose which aspect(s) to change
  - **Impact**: Rune viability, build diversity

- **Question**: Should explosive rune be cheaper or more impactful?
  - **Context**: Document notes "explosive rune is nice, but it only works one time"
  - **Decision Needed**: Define cost reduction or damage increase
  - **Impact**: Explosive rune viability, AOE strategy

### 5. Acceleration Rune Cap
- **Question**: What should the acceleration rune speed cap be?
  - **Context**: Document says "the cap is hit early" but doesn't specify what the cap should be
  - **Decision Needed**: Define new cap value (or remove cap entirely if uncapping is chosen)
  - **Impact**: Buff zone strategy viability, game balance

- **Question**: Should acceleration rune have a fall-off mechanism?
  - **Context**: Document mentions "has no fall-off" as a problem
  - **Decision Needed**: Define fall-off mechanics (time-based? distance-based? enemy-hit-based?)
  - **Impact**: Buff zone strategy, game balance

## Strategy & Build Diversity Questions

### 6. Maze Strategy Implementation
- **Question**: Should AOE damage tiles be implemented as walls or ground tiles?
  - **Context**: Document says "we probably want to have the AOE tiles act as walls, rather than ground tiles"
  - **Decision Needed**: Confirm wall vs ground placement
  - **Impact**: Tile system, placement rules, build diversity

- **Question**: What should the AOE damage tile be called and how should it work?
  - **Context**: Document suggests "AOE Damage Tile (Explosive?)" but explosive rune already exists
  - **Decision Needed**: Name, mechanics, and differentiation from explosive rune
  - **Impact**: New rune type, player understanding

- **Question**: Should AOE slow tiles be implemented?
  - **Context**: Document proposes "AOE Slow Tile (Freezing?)" for maze strategy
  - **Decision Needed**: Yes/No, and if yes, define mechanics
  - **Impact**: New rune type, maze strategy viability

- **Question**: What should the AOE radius be for damage/slow tiles?
  - **Context**: Document says "1-3 tile radius (depending on upgrade level)" but upgrades are disabled
  - **Decision Needed**: Define base radius (and whether it's fixed or variable)
  - **Impact**: AOE effectiveness, placement strategy

- **Question**: Should AOE tiles activate on fireball pass or on cooldown?
  - **Context**: Document says "either on a cooldown or whenever the fireball passes near it"
  - **Decision Needed**: Choose activation method
  - **Impact**: AOE tile mechanics, player strategy

## Level Design Questions

### 7. Level Design Priorities
- **Question**: What are the "1 to 3 basic interactions" that should be identified?
  - **Context**: Document says "Identify a short list (1 to 3) of basic interactions"
  - **Decision Needed**: Define which interactions are "basic" and should be tutorialized
  - **Impact**: Tutorial design, level progression

- **Question**: What defines a "challenging" level for each interaction?
  - **Context**: Document says "make a 'challenging' level for each interaction"
  - **Decision Needed**: Define difficulty metrics and success criteria
  - **Impact**: Level design goals, player experience

- **Question**: Should levels have more initial tiles set?
  - **Context**: Document suggests this as mitigation for lack of anticipation
  - **Decision Needed**: Define how many initial tiles and which types
  - **Impact**: Level design, player agency, tutorial effectiveness

### 8. Level Progression & Unlocks
- **Question**: Should there be a level select screen in MVP?
  - **Context**: Document says "add a level select screen" but LEVELS.md says "No Level Select" for MVP
  - **Decision Needed**: Resolve contradiction
  - **Impact**: UI design, progression system

- **Question**: What should the "game victory card" show when all levels are cleared?
  - **Context**: Document mentions adding this but doesn't specify content
  - **Decision Needed**: Define victory screen content and requirements
  - **Impact**: End-game experience, UI design

## Asset & Polish Questions

### 9. Asset Integration Priorities
- **Question**: Which assets should be integrated first?
  - **Context**: Document says "get background, tiles, and enemy assets integrated" but doesn't prioritize
  - **Decision Needed**: Define priority order
  - **Impact**: Development timeline, visual polish

- **Question**: Are all required assets available or do some need to be created?
  - **Context**: Not specified in document
  - **Decision Needed**: Asset audit and creation plan
  - **Impact**: Art pipeline, timeline

### 10. Effects & Polish Priorities
- **Question**: Which effects should be implemented first?
  - **Context**: Document lists: rune activation, damage dealt, game over, victory, fireball shot, fireball died
  - **Decision Needed**: Prioritize which effects are most important
  - **Impact**: Development order, player experience

- **Question**: Should visual effects or sound effects be prioritized?
  - **Context**: Document says "implement sound or visual effects" but doesn't specify which
  - **Decision Needed**: Define priority (or do both simultaneously)
  - **Impact**: Development approach, player experience

## Technical & Implementation Questions

### 11. Debug Mode
- **Question**: How should debug mode be disabled on export?
  - **Context**: Document says "ensure debug mode is disabled on export" but doesn't specify method
  - **Decision Needed**: Define implementation approach (compile flag? config file? build setting?)
  - **Impact**: Build process, security

### 12. Tile Upgrade System
- **Question**: When should tile upgrades be re-enabled?
  - **Context**: Document says "disable this system until we have solved core gameplay issues"
  - **Decision Needed**: Define what "solved core gameplay issues" means as a milestone
  - **Impact**: Feature roadmap, upgrade system design

- **Question**: What upgrade options should exist for each rune type?
  - **Context**: Document mentions upgrades but doesn't specify options
  - **Decision Needed**: Define upgrade tree/options per rune
  - **Impact**: Upgrade system design, player progression

## Strategic Direction Questions

### 13. Core Gameplay Loop
- **Question**: Is the current "one level = one wave" structure final, or should it change?
  - **Context**: Document notes "because one level is one wave, there is less of a feeling of investing in your build"
  - **Decision Needed**: Confirm if this is a problem to solve or acceptable design
  - **Impact**: Core game structure, level design

- **Question**: Should levels have multiple waves?
  - **Context**: Not explicitly proposed but implied by "lack of investment" concern
  - **Decision Needed**: Yes/No on multi-wave levels
  - **Impact**: Level structure, progression, player investment

### 14. Player Information & Anticipation
- **Question**: What information should players see about incoming enemies?
  - **Context**: Document says "without knowing more information about incoming enemies, planning is not very fun"
  - **Decision Needed**: Define what enemy information to show (types? counts? timing? paths?)
  - **Impact**: UI design, player strategy, anticipation

- **Question**: When should enemy information be shown? (Build phase? Always visible? On hover?)
  - **Context**: Not specified
  - **Decision Needed**: Define UI/UX for enemy information display
  - **Impact**: UI design, player experience

## Kevin's Strategy Questions

### 15. Buff Zone Strategy Details
- **Question**: Should there be a separate damage-buffing rune, or should acceleration grant damage?
  - **Context**: Document presents both alternatives without choosing
  - **Decision Needed**: Choose one approach
  - **Impact**: Rune design, player strategy, game balance

- **Question**: If separate damage rune exists, what should it be called and how should it work?
  - **Context**: Not specified
  - **Decision Needed**: Design new rune type
  - **Impact**: New rune implementation, player understanding

### 16. Kill Zone Strategy
- **Question**: Is the current kill zone strategy sufficient, or does it need changes?
  - **Context**: Document says "We already have this, basically" but doesn't confirm if it's good enough
  - **Decision Needed**: Confirm if kill zone is working as intended
  - **Impact**: Strategy viability, balance

## Priority & Sequencing Questions

### 17. Implementation Order
- **Question**: What is the priority order for the "Key To Dos"?
  - **Context**: Document lists 6 items but doesn't prioritize them
  - **Decision Needed**: Define implementation sequence
  - **Impact**: Development roadmap, resource allocation

- **Question**: Should some items be done in parallel or sequentially?
  - **Context**: Not specified
  - **Decision Needed**: Define dependencies and parallelization opportunities
  - **Impact**: Development timeline, team coordination

### 18. MVP Scope
- **Question**: Which of these improvements are MVP vs post-MVP?
  - **Context**: Document mixes MVP fixes with post-MVP features
  - **Decision Needed**: Categorize each item as MVP or post-MVP
  - **Impact**: Scope definition, release planning

## Summary

**Total Questions Identified**: 40+ unanswered questions across 18 categories

**Critical Decisions Needed**:
1. Fireball damage/buff system (affects core gameplay)
2. Rune balance changes (affects build diversity)
3. Maze strategy implementation (affects strategy viability)
4. Level design priorities (affects tutorial and progression)
5. Implementation order (affects development timeline)

**Recommendation**: Address questions in priority order, starting with core gameplay mechanics before moving to polish and features.
