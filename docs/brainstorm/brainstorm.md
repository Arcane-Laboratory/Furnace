Elevator Pitch
You are a mechanic / support that builds towers
all you can do is build support towers and at some point shoot one bullet
hordes of enemies come to destroy the last furnace and bring about everlasting darkness/cold
# High Level

- Single player first, multiplayer optional
- Performant with lots of enemies/towers/bullets
- Core Game
    - Build Phase
    - Active / Shot phase
- Player
    - Movement + abilities
- Furnace
    - 1 Health?
    - Is this the shot?
- Towers
    - Types
    - ? Upgrades
- Enemies
    - A few types
    - lots of enemies
- Levels
    - Map layouts

# Core

Technical

640 x 360 Pixel Perfect

Scenes

- Title Screen
- Start Menu
- Game Over
    - ? Score ?
- Pause
- Core Game
    - Build UI
        - Tower placement + types
        - build grid
        - valid path detection
        - available resources
    - Active UI
        - Wave indicator
    - enemy path-finding
        - UI that shows enemy path before the level starts
        - If there’s no path then it won’t let you start the level
    - Controls
        - mouse - build in build phase, activate towers in active phase
            - clicking your furnace shoots the shot
        - button to pause/slow game to determine shot timing
    - Levels
        - Each level has pre-set waves, maybe existing terrain?
        - Layout
            - Grid
                - 13 by 8 grid
                - 32x32 tiles
                - early levels have a bunch of terrain that makes the level grid artificially smaller
            - Fixed-End point for enemies to march toward (the furnace)
            - Grid Slots
                - Rock/Mountain Terrain - un-build-able and uncrossable
                - Open terrain - build-able and crossable
                - Spawn Point - enemies start here
                - ? Void Hole - enemies can cross, you can’t build
    - Building
        - limited resources for special towers
        - wall towers are very cheap or free
        - free sell/buy not punished for misplacing a wall
            - **UI - Resource**
    - Towers
        - Passive Abilities or Active abilities (Players use the towers)
        - Passive (when enemies are nearby or when tower is shot)
            - bounce or repeat bullet with portals
            - duplicate bullet
            - re-route
        - Active (click tower with mouse)
            - freeze
            - re-route
    - Furnace
        - Fixed-point
        - one end point on grid
    - Entry point

Bullet - Fireball

- fireball ignites towers to activate them
- ? if fireball goes back to furnace, it can be reused

Wall & Runes

- Wall - Prevent enemy movement
- Redirect Rune - changes fireball to a specific direction (can be used as a bounce), fixed number of uses (0 = infinite), redirecting is slow
- Advanced Redirect Rune - like the normal redirect rune, but you can change the direction
- Portal Rune - instantly teleports fireball to the other portal (player toggle?)
- Explosive rune - explodes fireball when passed over (does not consume bullet or redirect it)
- Acceleration rune - permanently increases speed (fixed use)
- Status runes
    - apply statuses to enemies
        - change enemy properties like speed
        - apply passive effects such as on hit or on death
- enemy affector runes
    - activate when enemies touch instead of when bullet touches

Levels

- Each level is a blank grid with some initial walls and runes which can not be edited by the player
- Each player has fixed resources which they can use to construct additional walls or place additional runes
- level difficulty is from
    - mob timings
    - mobs that come from different places
    - limited resources
    - limited walls
