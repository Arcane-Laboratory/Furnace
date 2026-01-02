# Furnace - Game Design Document

**Version:** 1.0  
**Last Updated:** [Date]  
**Status:** [Draft/In Progress/Final]  
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
[To be determined - PC/Web/Mobile]

### 1.5 Unique Selling Points
- Single fireball mechanic - player shoots one fireball that ignites runes
- Build phase strategy combined with active phase execution
- Rune abilities enhance/modify the fireball rather than auto-attacking
- Focus on strategic wall and rune placement over resource management
- Fireball can potentially return to furnace for reuse

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
- **Duration**: Until player manually ends phase or timer expires
- **Player Actions**:
  - Place walls and runes on valid grid spaces
  - Change direction of Redirect Runes (all types)
  - Sell/remove walls and runes (free or low cost)
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
  - Cannot place or remove structures during active phase
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
  - Player clicks furnace to fire the fireball
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

**Redirect Runes** (Trigger: When fireball ignites rune)
- **Redirect Rune**: 
  - Changes fireball to a specific direction (can be used as bounce)
  - Fixed number of uses (0 = infinite uses)
  - Direction can be changed during build phase only
  - Can change direction multiple times during build phase
  - Fireball changes direction automatically when it hits the rune
  - Rune has visual asset showing current direction
- **Advanced Redirect Rune** (needs new name - low priority): 
  - Like normal redirect rune, but direction can be changed during build phase AND active phase
  - Fixed number of uses (0 = infinite uses)
  - **Direction Change**:
    - Can change direction multiple times (both phases)
    - During build phase: Same method as regular Redirect Rune
    - During active phase: Click + menu option OR click + drag (reuse UI from placement if possible)
  - Fireball changes direction automatically when it hits the rune
  - Rune has visual asset showing current direction

**Portal Runes** (Trigger: When fireball ignites rune)
- **Portal Rune**: 
  - Instantly teleports fireball to the other portal
  - Fireball maintains same direction after teleportation
  - Portals are paired (entry/exit)
  - No player toggle needed - works automatically
  - **MVP**: Only one portal pair per level
  - **Pairing**: First two portals placed become a pair automatically
  - **Post-MVP**: Multiple pairs allowed, matching colors for pairing indication

**Explosive Runes** (Trigger: When fireball passes over tile center)
- **Explosive Rune**: 
  - Explodes fireball when passed over (triggers at tile center)
  - Does NOT consume fireball or redirect it
  - **Explosion Mechanics**:
    - Deals fixed damage to all enemies within 1 tile radius
    - Explosion radius: 1 tile (affects enemies on adjacent tiles)
    - Fireball continues traveling after explosion
    - Enemies hit by both fireball piercing AND explosion take damage twice
  - **Effects**:
    - Plays sound effect (SFX) when exploding
    - Plays visual effect (VFX) when exploding
  - **Damage**: Fixed damage value (developer tunable parameter, separate from fireball damage)

**Speed Modification Runes** (Trigger: When fireball ignites rune)
- **Acceleration Rune**: 
  - Permanently increases fireball speed by a fixed value
  - Speed increase stacks (multiple Acceleration Runes add their speed increases)
  - Speed increase stacks up to a maximum speed cap
  - Fixed use (one-time effect per rune)
  - **Mechanics**:
    - When fireball hits Acceleration Rune, speed increases by fixed amount
    - If fireball hits multiple Acceleration Runes, speed increases stack
    - Speed cannot exceed maximum speed cap
    - If fireball is already at cap, hitting another Acceleration Rune has no effect (but rune is still consumed)
  - **Developer Tunable Parameters**:
    - Base fireball speed
    - Acceleration Rune speed increase amount (e.g., +10)
    - Maximum speed cap

**Status Runes** (Trigger: When fireball ignites rune)
- **Status Runes**: 
  - Apply statuses to enemies
  - Effects:
    - Change enemy properties (e.g., speed)
    - Apply passive effects (on hit, on death)
  - [To be defined: Which enemies affected? Duration? Complete list of statuses?]

**Enemy Affector Runes** (Trigger: When enemies touch rune)
- **Enemy Affector Runes**: 
  - Activate when enemies touch instead of when fireball touches
  - [To be defined: What do these runes do? Examples needed]

#### 4.1.3 Rune Placement
- Grid-based placement (13x8 grid, 32x32 tiles)
- **Tile Occupancy Rules**:
  - Each tile can contain: a rune, OR a wall, OR an enemy spawn point
  - Never more than one element per tile
  - Cannot overlap structures
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

#### 4.2.1 Enemy Types
- [To be defined - "A few types" mentioned]
- Considerations:
  - Health values
  - Movement speed
  - Special abilities
  - Visual distinction

#### 4.2.2 Enemy Behavior
- Pathfinding: Follow predetermined route to furnace
- Spawning: From designated spawn points
- Quantity: "Lots of enemies" - performance consideration
- Attack: Destroy furnace on contact

#### 4.2.3 Wave System
- **Level Structure**: One level = one wave
- **Wave Progression**: [To be defined]
  - Enemy count scaling across levels?
  - Enemy type progression across levels?
  - Difficulty curve across levels?

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
  - Calculated before build phase ends
  - Visual preview shown to player
  - Must validate path exists before starting active phase
- **Path Visualization**: UI shows enemy route
- **Path Validation**: Prevents starting level if no valid path

---

## 5. Content

### 5.1 Levels
- **Structure**: 
  - Each level is a blank grid
  - Some initial walls and runes pre-placed (cannot be edited by player)
  - Player has fixed resources to construct additional walls or place additional runes
  - **One level = one wave** (level ends when wave completes or furnace destroyed)
- **Level Start**: 
  - Fireball automatically shoots when level begins (no player input needed)
- **Level Components**:
  - Pre-set enemy wave (one wave per level)
  - Initial walls (non-editable)
  - Initial runes (non-editable)
  - Spawn points
  - Furnace location
- **Difficulty Factors**:
  - Mob timings (when enemies spawn during the wave)
  - Mobs from different places (multiple spawn points, varied entry points)
  - Limited resources (fixed resource budget per level)
  - Limited walls (constraint on wall placement)

### 5.2 Terrain Types
- **Rock/Mountain**: Unbuildable and uncrossable
- **Open Terrain**: Buildable and crossable
- **Spawn Point**: Enemy starting location
- **Void Hole**: [To be defined - enemies can cross, player can't build]

### 5.3 Progression Elements
- **Score System**: [Mentioned but undefined]
- **Unlocks**: [To be defined]
- **Difficulty**: [To be defined]

---

## 6. Technical Specifications

### 6.1 Display
- **Resolution**: 640 x 360 pixels
- **Pixel Perfect**: Yes
- **Aspect Ratio**: 16:9
- **Scaling**: [To be defined]

### 6.2 Performance Targets
- **Enemy Count**: "Lots of enemies" - need specific target
- **Tower Count**: [To be defined]
- **Bullet Count**: 1 primary, but may duplicate/modify
- **Frame Rate**: [To be defined - 60 FPS target?]

### 6.3 Grid System
- **Grid Size**: 13 columns x 8 rows
- **Tile Size**: 32x32 pixels
- **Total Playable Area**: 416 x 256 pixels (within 640x360 window)

### 6.4 Engine/Technology
- [To be defined]

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
- [To be defined]

#### 7.1.2 Start Menu
- [To be defined]

#### 7.1.3 Game Over Screen
- Score display: [To be defined]
- Retry option
- Return to menu

#### 7.1.4 Pause Screen
- Resume
- Settings
- Return to menu

#### 7.1.5 Core Game UI

**Build Phase UI**
- Tower placement interface
- Tower type selection
- Build grid overlay
- Valid path detection indicator
- Available resources display
- End build phase button

**Active Phase UI**
- Wave indicator
- Enemy path visualization
- Furnace health indicator
- Shot button/indicator
- Pause/slow time button

### 7.2 Controls

#### 7.2.1 Mouse Controls
- **Build Phase**: Click to place towers, click to sell
- **Active Phase**: Click furnace to shoot, click towers to activate abilities

#### 7.2.2 Keyboard Controls
- Pause/slow game button
- [Additional controls to be defined]

### 7.3 Visual Feedback
- Path preview visualization
- Resource indicators
- Tower range indicators: [To be defined]
- Enemy health bars: [To be defined]
- Bullet trail/effects: [To be defined]

---

## 8. Art & Audio

### 8.1 Art Style
- [To be defined]
- Pixel art suggested by resolution

### 8.2 Visual Elements Needed
- Tower sprites (multiple types)
- Enemy sprites (multiple types)
- Terrain tiles
- Furnace sprite
- Bullet/projectile effects
- UI elements
- Particle effects

### 8.3 Audio
- Background music: [To be defined]
- Sound effects:
  - Tower placement
  - Bullet firing
  - Enemy spawn/death
  - Furnace destruction
  - UI interactions

---

## 9. Level Design

### 9.1 Level Structure
- **Early Levels**: More terrain, artificially smaller grid
- **Progression**: [To be defined]
- **Variety**: Different layouts, enemy compositions

### 9.2 Design Principles
- Ensure valid paths exist
- Provide strategic choices
- Balance difficulty curve
- Teach mechanics progressively

### 9.3 Level Progression
- [To be defined]
  - Tutorial levels?
  - Difficulty scaling?
  - New mechanics introduced?

---

## 10. Progression & Balance

### 10.1 Difficulty Curve
- [To be defined]
- Early levels: Tutorial/learning
- Mid levels: Challenge increases
- Late levels: Mastery required

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
- [To be defined]
- PC (Windows/Mac/Linux)?
- Web browser?
- Mobile?

### 11.2 Distribution
- [To be defined]
- Game jam submission?
- Itch.io?
- Steam?

### 11.3 Multiplayer
- **Status**: Optional, future consideration
- **Type**: [To be defined]
- **Priority**: Low (single player first)

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

**Document Status**: This is a template. All sections marked "[To be defined]" require team discussion and decision-making.
