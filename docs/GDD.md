# Furnace - Game Design Document

**Version:** 1.0  
**Last Updated:** [Current Date]  
**Status:** In Progress - Core systems defined, ready for implementation  
**Team:** [Team Members]

---

## Table of Contents

1. [Overview](#overview)
2. [Game Concept](#game-concept)
3. [Core Mechanics](#core-mechanics)
4. [Gameplay Systems](#gameplay-systems)
5. [Content](#content)
6. [Technical Specifications](#technical-specifications)
7. [User Interface](#user-interface)
8. [Art & Audio](#art--audio)
9. [Level Design](#level-design)
10. [Progression & Balance](#progression--balance)
11. [Platform & Distribution](#platform--distribution)
12. [Development Timeline](#development-timeline)
13. [Risks & Open Questions](#risks--open-questions)

---

## 1. Overview

### 1.1 Elevator Pitch
You are a mechanic/support that builds walls and runes. All you can do is construct defensive structures and place runes, then shoot one fireball. The fireball ignites runes to activate them. Hordes of enemies come to destroy the last furnace and bring about everlasting darkness/cold.

### 1.2 Genre
Tower Defense / Strategy / Puzzle

### 1.3 Target Audience
- Primary: Strategy game enthusiasts, tower defense fans
- Secondary: Puzzle game players, indie game players

### 1.4 Platform
- **MVP**: Web (HTML5 export via Godot), distributed via Itch.io
- **Post-MVP**: Mobile (iOS/Android), Discord Activity

### 1.5 Unique Selling Points
- Single fireball mechanic - one fireball automatically launches and ignites runes
- Build phase strategy combined with active phase execution
- Rune abilities enhance/modify the fireball rather than auto-attacking
- Focus on strategic wall and rune placement over resource management
- Post-MVP: Fireball return to furnace for reuse (via rune)

---

## 2. Game Concept

### 2.1 Core Vision
A tower defense game where the player's agency comes from strategic wall and rune placement and precise timing of a single fireball that ignites runes to activate their abilities, modifying and enhancing the fireball's path and effects.

### 2.2 Gameplay Loop
1. **Build Phase**: Player places walls and runes on a grid to create a defensive layout
2. **Level Start**: Fireball automatically shoots when level begins (no player input)
3. **Active Phase**: Enemies spawn and march toward the furnace while fireball travels
4. **Resolution**: Fireball effects resolve, enemies are damaged/eliminated
5. **Level End**: Level completes when all enemies are defeated or furnace is destroyed (one level = one wave)

### 2.3 Player Experience Goals
- Strategic planning during build phase
- Tension and anticipation during active phase
- Satisfaction from well-placed towers enhancing the shot
- Challenge from limited resources and single-shot constraint

---

## 3. Core Mechanics

### 3.1 Phases

#### 3.1.1 Build Phase
- **Duration**: Until player manually ends phase (no timer - unlimited build time)
- **Player Actions**:
  - Place walls and runes on valid grid spaces
  - Change direction of Redirect Runes (all types)
  - Sell/remove walls and runes through UI menu (full refund)
  - View enemy path preview
  - Validate that enemy path exists
- **Constraints**:
  - Fixed resources per level (cannot be edited)
  - Limited resources for walls and runes
  - Must maintain valid enemy path to furnace
  - Grid placement rules (terrain restrictions)
  - Some initial walls and runes are pre-placed and cannot be edited

#### 3.1.2 Active/Shot Phase
- **Duration**: Until wave completes or furnace is destroyed
- **Fireball Launch**: 
  - Fireball automatically shoots when level starts (no player input needed)
  - Always starts downward from furnace at top of screen
  - Travels in cardinal directions only
- **Player Actions**:
  - Can change direction of Advanced Redirect Runes (click + menu OR click + drag)
  - Cannot interact with regular Redirect Runes during active phase
  - Cannot place or remove structures during active phase (selling disabled)
  - Otherwise observes fireball and enemy behavior
- **Fireball Behavior**:
  - Fireball ignites runes to activate them as it travels
  - Redirect runes change fireball direction (no player input needed during travel)
  - Fireball does not return to furnace (travels until it leaves screen or hits wall/terrain)
- **Enemy Behavior**:
  - Follow pathfinding route to furnace
  - Destroy furnace on contact (one touch = game over)
  - Interact with enemy affector runes when touching them

### 3.2 Player Character
- **Role**: Mechanic/Support (represented as cursor only)
- **Representation**: Player is just a cursor - no character sprite on screen
- **Movement**: Cursor movement only (for UI interaction)
- **Abilities**: 
  - Build phase: Place walls and runes
  - Active phase: No interaction (player observes only)
  - No abilities beyond building and observing

### 3.3 Furnace
- **Health**: 1 HP (one hit = game over)
- **Location**: Fixed endpoint at top of screen
- **Function**: 
  - Target for enemies
  - Source of the fireball (always fires downward automatically when level starts)
  - Victory condition (survive the wave)
- **Destruction**: 
  - Furnace dies instantly when an enemy touches it
  - One touch = game over
  - No damage over time or multiple hits needed

### 3.4 The Fireball
- **Travel**: Fireball travels through space at a defined speed
- **Direction**: Fireball only travels in cardinal directions (North, South, East, West - no diagonals)
- **Initial Direction**: Always starts from furnace (located at top of screen) traveling downwards (South)
- **Piercing**: Fireball pierces through enemies, dealing damage to all enemies in its path
- **Damage**: Fixed damage per enemy hit (damage value: Developer tunable parameter)
- **Enemy Health**: Varied - different enemy types have different health values
- **Firing**: 
  - Fireball automatically launches when level starts (no player input needed)
  - No aiming needed - fireball always starts downward from furnace
  - No slow-mo or time manipulation mechanics
- **Rune Ignition**: 
  - Fireball travels between tiles in cardinal directions, always moving along tile grids
  - Fireball activates/ignites a tile when it goes over the center of that tile
  - When fireball ignites a tile containing a rune, the rune's ability activates
  - Grid-aligned collision detection (fireball position matches tile grid)
- **Return to Furnace**: 
  - Fireball does NOT automatically return to furnace
  - [Future consideration: Could add a rune that returns fireball to furnace for reuse]
- **Developer Tunable Parameters**:
  - Fireball damage value
  - Base fireball speed
  - Reflect rune debounce/cooldown duration
  - Explosive Rune damage value
  - Acceleration Rune speed increase amount
  - Maximum speed cap
- **Lifetime**: 
  - No range limit, no hit limit, no time limit
  - Fireball travels until it leaves the screen or hits a wall/terrain
  - Despawns on boundary collision or terrain collision

---

## 4. Gameplay Systems

### 4.1 Wall & Rune System

#### 4.1.1 Wall
- **Function**: Prevents enemy movement (blocks pathfinding)
- **Placement**: Player can place with resources
- **Cost**: [To be defined - resource cost]
- **Limitations**: [To be defined - is there a separate wall limit?]

#### 4.1.2 Rune Types

**See**: [RUNES.md](RUNES.md) for complete rune specifications.

**MVP Rune Types** (6 total):
- Redirect Rune
- Advanced Redirect Rune
- Portal Rune
- Reflect Rune
- Explosive Rune
- Acceleration Rune

**Post-MVP Rune Types**:
- Status Runes
- Enemy Affector Runes

#### 4.1.3 Rune Placement
- Grid-based placement (13x8 grid, 32x32 tiles)
- **Tile Occupancy Rules**: See [TILES.md](TILES.md) for tile system specifications
- Valid placement rules:
  - Cannot block enemy path completely (walls can, runes cannot)
  - Cannot place on unbuildable terrain
  - Must have valid path from spawn to furnace
- Resource costs:
  - Walls: Developer tunable parameter
  - Runes: Developer tunable parameters (varies by rune type)
- Initial elements: Some walls and runes are pre-placed and cannot be edited

#### 4.1.4 Rune Upgrades
- **MVP**: No rune upgrades (cut from MVP scope)
- **Post-MVP**: Upgrade system may be added
  - Redirect runes can be upgraded for more uses
  - Other upgrade options to be defined

### 4.2 Enemy System

**See**: [ENEMIES.md](ENEMIES.md) for complete enemy specifications.

**MVP Enemy Types**: 2-3 types (Basic, Fast, Tank optional)  
**Enemy Behavior**: Pathfinding, staggered spawning, destroy furnace on contact  
**Wave System**: One level = one wave, designer-controlled enemy waves

### 4.3 Resource System
- **Resource Type**: Single currency (MVP)
- **Resource Allocation**: Fixed resources per level (cannot be edited, varies by level difficulty)
- **Resource Usage**: 
  - Used to construct additional walls
  - Used to place additional runes
  - Costs vary by structure/rune type
- **Resource Display**: UI indicator showing available resources
- **Difficulty Factor**: Limited resources contribute to level difficulty
- **Developer Tunable Parameters**:
  - Wall cost (per wall)
  - Rune costs (per rune type):
    - Redirect Rune cost
    - Advanced Redirect Rune cost
    - Portal Rune cost
    - Reflect Rune cost
    - Explosive Rune cost
    - Acceleration Rune cost
  - Resource amounts per level (varies by difficulty)

### 4.4 Pathfinding System
- **Enemy Pathfinding**:
  - Calculated on demand (when player requests)
  - Visual preview shown to player
  - Must validate path exists before starting active phase
- **Path Visualization**: 
  - Dotted line arrow overlay showing enemy route
  - Shows paths from all spawn points
  - Multiple paths can use different colors/styles
  - Updates on demand (not real-time)
- **Path Validation**: 
  - Prevents starting level if no valid path
  - Visual warning when no valid path exists
  - Start button disabled when path invalid

---

## 5. Content

**See dedicated content design documents**:
- [LEVELS.md](LEVELS.md) - Level structure, progression, and design specifications
- [ENEMIES.md](ENEMIES.md) - Enemy types, behavior, and wave system
- [RUNES.md](RUNES.md) - Complete rune system specifications
- [TILES.md](TILES.md) - Tile system, terrain types, and placement rules

### 5.1 Content Overview

**Levels**: 3 levels total (1 tutorial + 2 challenge), gated progression, one level = one wave  
**Enemies**: 2-3 enemy types (Basic, Fast, Tank optional), staggered spawning, pathfinding  
**Runes**: 6 rune types in MVP (Redirect, Advanced Redirect, Portal, Reflect, Explosive, Acceleration)  
**Tiles**: Grid-based system (13x8, 32x32 tiles), terrain types (Open, Rock/Mountain), spawn points

### 5.2 Progression Elements
- **Level Progression (MVP)**:
  - Start at Level 1
  - Must clear level to unlock next level
  - Linear progression (Level 1 → Level 2 → Level 3, etc.)
  - No level select menu in MVP
- **Rune Unlocks**:
  - Runes have `unlocked_by_default` property (designer-configurable)
  - Levels can specify `allowed_runes` (which runes are available)
  - Rune available if: (unlocked_by_default OR in level's allowed_runes)
- **Post-MVP**: Level select menu with unlocks system

---

## 6. Technical Specifications

### 6.1 Display
- **Resolution**: 640 x 360 pixels
- **Pixel Perfect**: Yes - maintain pixel perfect rendering
- **Aspect Ratio**: 16:9
- **Scaling**: 
  - Stretch scaling (stretch to fit screen)
  - Maintain 16:9 aspect ratio (letterbox/pillarbox if needed)
  - Center game viewport
  - See DISPLAY_SCALING.md for Godot implementation details

### 6.2 Performance Targets
- **Enemy Count**: 
  - Maximum on screen: 100 enemies simultaneously
  - Per level: Can exceed 100 (staggered spawning)
- **Frame Rate**: 
  - Minimum: 30 FPS
  - Ideal: 60 FPS (if achievable)
- **Engine**: Godot (already in repository)

### 6.3 Grid System
- **Grid Size**: 13 columns x 8 rows
- **Tile Size**: 32x32 pixels
- **Total Playable Area**: 416 x 256 pixels (within 640x360 window)

### 6.4 Engine/Technology
- **Engine**: Godot (already in repository)
- **Repository**: https://github.com/Arcane-Laboratory/Furnace/
- **Export Target**: Web (HTML5) for MVP, Mobile/Discord post-MVP

### 6.5 Developer Tunable Parameters

**Fireball Parameters:**
- Fireball damage value per enemy hit
- Base fireball speed
- Reflect rune debounce/cooldown duration

**Rune Parameters:**
- Explosive Rune damage value (separate from fireball damage)
- Acceleration Rune speed increase amount (e.g., +10)
- Maximum speed cap (caps Acceleration Rune stacking)

**Resource System Parameters:**
- Wall cost (per wall)
- Redirect Rune cost
- Advanced Redirect Rune cost
- Portal Rune cost
- Reflect Rune cost
- Explosive Rune cost
- Acceleration Rune cost
- Resource amounts per level (varies by difficulty)

---

## 7. User Interface

### 7.1 Scenes

#### 7.1.1 Title Screen
- Game title display
- Start game button
- [Visual design to match art style - defined by art lead]

#### 7.1.2 Start Menu
- Start game button (begins Level 1)
- [Additional menu options TBD - settings, etc.]
- [Visual design to match art style - defined by art lead]

#### 7.1.3 Game Over Screen
- Retry option
- Return to menu
- [No score display - score system cut from MVP]

#### 7.1.4 Pause Screen
- Resume
- Settings
- Return to menu

#### 7.1.5 Core Game UI

**Build Phase UI**
- **UI Toggle**: Switches to build phase mode
- **Money Resource Indicator**: Always visible, shows current resource amount
- **Build UI Panel**: 
  - Shows all rune types and wall type
  - Displays cost for each item
  - Click item for more information
  - Drag item to map to build (if enough money)
- **Start Button**: 
  - Available during build phase
  - Only enabled if valid path exists
  - Disabled with visual indication if no valid path
- **Pathfinding Visualization**: On-demand (dotted line arrow overlay)
- **Sell Interaction**: 
  - Click tile with player-placed wall/rune
  - Sell button appears above clicked tile
  - Full refund on sell

**Active Phase UI**
- **UI Toggle**: Switches to active phase mode
- **Money Resource Indicator**: Always visible
- **Level Display**: Level name/number (no wave indicator - one level = one wave)
- **Minimal UI**: Player observes only (no interaction)
- **Advanced Redirect Rune**: Can change direction during active phase (if applicable)

### 7.2 Controls

#### 7.2.1 Mouse Controls
- **Build Phase**: 
  - Click rune/wall in build UI panel for information
  - Drag rune/wall from build UI panel to map to place (if enough money)
  - Click tile with player-placed structure to sell (sell button appears above tile)
  - Click Start button to begin level (if valid path exists)
- **Active Phase**: 
  - Click Advanced Redirect Runes to change direction (click + menu OR click + drag)
  - No other interaction during active phase

#### 7.2.2 Keyboard Controls
- Pause button (pause/unpause game)
- [Additional controls TBD - pathfinding preview toggle, etc.]

### 7.3 Visual Feedback
- Path preview visualization (dotted line arrow overlay, on-demand)
- Resource indicators (money resource always visible)
- Fireball visual effects (trail, glow, etc. - to match art style)
- Rune activation effects (visual feedback when runes activate)
- Explosion effects (Explosive Rune VFX)
- Enemy health bars: Optional (not essential for MVP, can add post-MVP)

---

## 8. Art & Audio

### 8.1 Art Style
- **Style**: Pixel art (matches 640x360 pixel perfect resolution)
- **Art Direction**: Exact style and palette defined by art lead
- **Theme**: Dark/cold theme (everlasting darkness/cold)
- **Visual Elements**: 
  - Furnace (light/warmth source)
  - Fireball (warm accent)
  - Enemies (dark/shadowy)
  - Walls and runes (to match art style)

### 8.2 Visual Elements Needed
- Rune sprites (all rune types: Redirect, Advanced Redirect, Portal, Reflect, Explosive, Acceleration)
- Wall sprites
- Enemy sprites (2-3 enemy types: Basic, Fast, Tank)
- Terrain tiles (Rock/Mountain, Open Terrain)
- Furnace sprite
- Fireball sprite/effects
- UI elements
- Particle effects (explosions, rune activations, etc.)
- [Asset requirements to be planned after GDD completion]

### 8.3 Audio
- **Status**: Audio requirements deferred - will plan asset requirements after GDD completion
- **Sound Effects Needed** (to be defined):
  - Wall/rune placement
  - Fireball firing/launching
  - Enemy spawn/death
  - Furnace destruction
  - Rune activation sounds
  - UI interactions
- **Background Music**: To be defined (deferred to asset planning)

---

## 9. Level Design

**See**: [LEVELS.md](LEVELS.md) for complete level design specifications.

**Summary**:
- 3 levels total (1 tutorial + 2 challenge)
- Gated progression (must clear level to unlock next)
- Designer-controlled difficulty scaling
- Hands-off tutorial approach

---

## 10. Progression & Balance

### 10.1 Difficulty Curve
- **Designer-Controlled**: All difficulty factors are set by level designers per level
- **No Fixed Formulas**: Designers configure enemy counts, resources, spawn points individually
- **General Guidance**: Difficulty increases through:
  - More spawn points
  - More enemies
  - More enemy types
  - Fewer resources
  - Strategic initial elements
- **Progression**:
  - Level 1 (Tutorial): Basic Enemy only, more resources, fewer enemies
  - Level 2: Introduce Fast Enemy, moderate difficulty
  - Level 3: Introduce Tank Enemy (if implemented), highest difficulty

### 10.2 Balance Considerations
- Tower costs vs effectiveness
- Enemy health vs bullet damage
- Resource availability
- Wave difficulty scaling

### 10.3 Scoring System
- [Mentioned but undefined]
- Purpose: Leaderboard? Progression? Feedback?

---

## 11. Platform & Distribution

### 11.1 Target Platforms
- **MVP**: Web browser (HTML5 export via Godot)
- **Distribution**: Itch.io (game jam submission)
- **Post-MVP**: 
  - Mobile (iOS/Android via Godot)
  - Discord Activity (Discord platform integration)

### 11.2 Distribution
- **MVP**: Itch.io (game jam submission)
- **Post-MVP**: 
  - Itch.io (continued)
  - Mobile app stores (if mobile version developed)
  - Discord Activity platform

### 11.3 Multiplayer
- **Status**: Not in scope for MVP
- **Priority**: Low (single player only)
- **Post-MVP**: May consider multiplayer features

---

## 12. Development Timeline

### 12.1 Milestones
- [To be defined based on game jam timeline]

### 12.2 Priority Features
1. Core build phase
2. Core active/shot phase
3. Basic tower types
4. Basic enemy types
5. Pathfinding system
6. UI implementation
7. Level system
8. Polish

---

## 13. Risks & Open Questions

### 13.1 Critical Questions

#### Gameplay Mechanics
1. **The Single Bullet**: 
   - What exactly happens when you shoot? Does it travel? Instant hit? Area effect?
   - Can it be modified by towers? How?
   - What happens after it hits? Does it disappear? Can it bounce/chain?

2. **Player Movement**:
   - Is the player stationary or can they move?
   - What abilities does the player have beyond building and shooting?

3. **Tower Interactions**:
   - How do passive towers trigger? Range? Timing?
   - Can multiple towers affect the same bullet?
   - What's the priority/order of tower effects?

4. **Active Phase Duration**:
   - How long does the active phase last?
   - Can player shoot at any time or only once?
   - What happens if player doesn't shoot?

5. **Enemy-Furnace Interaction**:
   - Do enemies attack the furnace or just touch it?
   - Can enemies be blocked by towers?
   - Can enemies destroy towers?

#### Systems & Balance
6. **Resource System**:
   - What are the resources?
   - How are they earned?
   - How many resources per level/wave?

7. **Tower Upgrades**:
   - What can be upgraded?
   - How are upgrades purchased?
   - When can upgrades happen?

8. **Wave System**:
   - How many waves per level?
   - How many enemies per wave?
   - How does difficulty scale?

9. **Scoring**:
   - What is the score based on?
   - What's the purpose of scoring?
   - Leaderboards?

#### Technical
10. **Performance**:
    - Target enemy count?
    - Target FPS?
    - Optimization strategies?

11. **Engine**:
    - What engine/framework?
    - Team experience level?

#### Content
12. **Level Count**:
    - How many levels?
    - Procedural or hand-crafted?

13. **Enemy Types**:
    - How many types?
    - What are their characteristics?

14. **Tower Types**:
    - Complete list of towers?
    - All towers available from start or unlocked?

### 13.2 Risks

1. **Single Bullet Mechanic Clarity**: Risk that players won't understand the core mechanic
   - *Mitigation*: Clear tutorial, visual feedback

2. **Performance with Many Enemies**: May struggle with "lots of enemies"
   - *Mitigation*: Early performance testing, optimization

3. **Balance Complexity**: Single bullet + many towers = complex interactions
   - *Mitigation*: Iterative playtesting, clear documentation

4. **Pathfinding Validation**: Ensuring valid paths exist
   - *Mitigation*: Robust pathfinding system, clear UI feedback

5. **Scope Creep**: Many undefined systems could expand scope
   - *Mitigation*: Prioritize core loop, cut features if needed

---

## 14. Appendices

### 14.1 Glossary
- **Furnace**: The player's base/target that enemies attack
- **Build Phase**: Phase where player places towers
- **Active Phase**: Phase where enemies spawn and player can shoot
- **Shot Phase**: Moment when player fires the single bullet

### 14.2 References
- [Game design references]
- [Technical references]

---

**Document Status**: Core systems and mechanics defined. Ready for implementation. Audio requirements deferred to asset planning phase.
