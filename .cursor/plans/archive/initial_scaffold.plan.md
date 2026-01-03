---
name: Godot Game Scaffold
overview: Scaffold the core Godot project structure with UI scenes, autoload managers, and organized folder hierarchy. Uses minimal placeholder UI with a centralized SceneManager autoload and a combined GameScene for build/active phases.
todos:
  - id: create-folders
    content: Create directory structure (assets, scenes/ui, scenes/game, scripts/autoload, scripts/ui, scripts/game)
    status: completed
  - id: place-asset
    content: Place background asset at assets/sprites/board_background.png
    status: completed
  - id: create-autoloads
    content: Create SceneManager, GameManager, and GameConfig autoload scripts
    status: completed
    dependencies:
      - create-folders
  - id: create-ui-scenes
    content: "Create UI scenes: title_screen, main_menu, game_over, pause_menu with scripts"
    status: completed
    dependencies:
      - create-autoloads
  - id: create-game-scene
    content: Create game_scene.tscn with background, grid area, UI layers, and phase management
    status: completed
    dependencies:
      - create-autoloads
      - place-asset
  - id: update-project
    content: "Update project.godot: register autoloads, set main scene, add input actions"
    status: completed
    dependencies:
      - create-autoloads
---

# Furnace - Godot Game Scaffold

Create the foundational scene structure, autoload managers, and organized file hierarchy for the Furnace tower defense game.

## Directory Structure

```
godot/
  assets/
    sprites/
      board_background.png      # The provided background asset
    audio/
  scenes/
    ui/
      title_screen.tscn         # Title with game logo
      main_menu.tscn            # Start Game, Settings, Quit buttons
      game_over.tscn            # Win/Lose state, Retry, Menu buttons
      pause_menu.tscn           # Resume, Settings, Quit buttons
    game/
      game_scene.tscn           # Combined build + active phase scene
  scripts/
    autoload/
      scene_manager.gd          # Centralized scene transitions
      game_manager.gd           # Game state, level data, resources
      game_config.gd            # Tunable parameters from scope doc
    ui/
      title_screen.gd
      main_menu.gd
      game_over.gd
      pause_menu.gd
    game/
      game_scene.gd             # Phase management, core game loop
```

## Autoload Managers

### SceneManager (`scripts/autoload/scene_manager.gd`)

- Scene transition functions: `goto_title()`, `goto_menu()`, `goto_game()`, `goto_game_over()`
- Optional fade transitions (can add later)
- Registered as autoload in project.godot

### GameManager (`scripts/autoload/game_manager.gd`)

- Game state enum: `TITLE`, `MENU`, `BUILD_PHASE`, `ACTIVE_PHASE`, `PAUSED`, `GAME_OVER`
- Current level tracking
- Resource count (single currency per scope)
- Win/lose state

### GameConfig (`scripts/autoload/game_config.gd`)

- Developer tunable parameters from [scope.md](docs/scope.md):
  - Fireball damage, speed, cooldowns
  - Rune costs (redirect, portal, explosive, acceleration)
  - Wall cost
  - Grid size (13x8), tile size (32x32)

## UI Scenes (Minimal Placeholder Style)

### Title Screen

- Game title "Furnace" centered
- "Press any key" or auto-transition to menu
- Dark background

### Main Menu

- VBoxContainer with buttons: Start Game, Settings (placeholder), Quit
- Simple centered layout

### Game Over

- Shows win/lose state
- Buttons: Retry, Main Menu

### Pause Menu

- CanvasLayer overlay
- Buttons: Resume, Main Menu

## Core Game Scene

### Structure

- Background (using provided asset, centered in playable area)
- Grid container (13x8, 32x32 tiles = 416x256 pixels)
- UI layer for build phase (rune selection, resources, end phase button)
- UI layer for active phase (wave indicator)
- Furnace placeholder position (top center)

### Phase State Machine

- `BUILD_PHASE`: Player can place walls/runes, preview path
- `ACTIVE_PHASE`: Fireball launches, enemies spawn, observe only

## Project Configuration

Update [project.godot](godot/project.godot):

- Register 3 autoloads: SceneManager, GameManager, GameConfig
- Set main scene to `title_screen.tscn`
- Add input actions: `ui_pause` (Escape key)

## Asset Placement

Move the provided background image to `godot/assets/sprites/board_background.png`
