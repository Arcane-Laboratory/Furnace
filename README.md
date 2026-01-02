# Furnace

A tower defense game where you build walls and runes, then watch a single fireball ignite your defenses to defeat waves of enemies before they reach the furnace.

Built for a 3-day game jam with the theme "Support" and prompt "One Shot".

## Getting Started (For Developers)

### 1. Install Godot 4.5.1

Download and install Godot 4.5.1 from the official site:

- **Windows**: https://godotengine.org/download/windows/

Extract and run - Godot is self-contained and doesn't require installation.

### 2. Open the Project

1. Launch Godot
2. Click "Import" and navigate to `godot/project.godot`
3. Open the project

### 3. Key Files to Know

| File                               | Purpose                                             |
| ---------------------------------- | --------------------------------------------------- |
| `scripts/autoload/game_config.gd`  | All tunable game parameters (damage, costs, speeds) |
| `scripts/autoload/game_manager.gd` | Game state machine (phases, resources, win/lose)    |
| `scripts/game/game_scene.gd`       | Main game loop and grid interaction                 |
| `scripts/entities/rune_base.gd`    | Base class for creating new rune types              |
| `scripts/entities/fireball.gd`     | Fireball movement and rune activation               |
| `scripts/resources/level_data.gd`  | Custom Resource for defining levels                 |

### 4. Grid Coordinate System

- **Origin**: Grid starts at pixel position (40, 96)
- **Size**: 13 columns x 7 rows
- **Tile Size**: 32x32 pixels
- **Total Grid Area**: 416x224 pixels

### 5. Creating New Runes

Extend `RuneBase` and override `_on_activate()`:

```gdscript
extends RuneBase
class_name MyCustomRune

func _on_rune_ready() -> void:
    rune_type = "my_custom"

func _on_activate(fireball: Node2D) -> void:
    # Your rune effect here
    pass
```

See `scripts/entities/runes/redirect_rune.gd` for a complete example.

### 6. Creating Levels

Create a new `LevelData` resource in the Godot editor:

1. Right-click in FileSystem > New Resource
2. Search for "LevelData"
3. Configure spawn points, preset walls, enemy waves, etc.

---

## Project Structure

```
furnace/
  godot/              # Godot 4.x game project
    assets/           # Sprites, audio, etc.
    scenes/           # Scene files (.tscn)
      ui/             # Menu screens
      game/           # Main game scene
      entities/       # Fireball, runes, enemies
    scripts/          # GDScript files (.gd)
      autoload/       # Singletons (GameManager, GameConfig, SceneManager)
      entities/       # Entity scripts
      resources/      # Custom Resource definitions
  web/                # Next.js wrapper for web deployment
  server/             # Express server (placeholder for multiplayer)
  docs/               # Design documents and brainstorm
```

## Quick Start (Web Development)

### Prerequisites

- Node.js 18+
- Yarn 1.22+
- Godot 4.5+

### Development

```bash
# Install dependencies
yarn install

# Run web client (for hosting Godot export)
yarn dev

# Run server (when needed)
yarn dev:server

# Build all
yarn build
```

### Godot Web Export

1. Open `godot/project.godot` in Godot Editor
2. Project > Export > Web
3. Export to `web/public/game/`

## Game Overview

- **Build Phase**: Place walls and runes on a 13x7 grid
- **Active Phase**: Watch the fireball automatically launch and interact with your runes
- **Goal**: Defeat all enemies before they reach the furnace (1 HP)

## Tech Stack

- **Game Engine**: Godot 4.5 (GDScript)
- **Web Client**: Next.js 14 + Material-UI
- **Server**: Express.js + TypeScript (minimal, for future multiplayer)

## Documentation

See `docs/` for:

- `brainstorm/GAME_DESIGN_DOCUMENT.md` - Full game design
- `brainstorm/CORE_SYSTEMS_RESOLVED.md` - Key design decisions
- `brainstorm/DEVELOPER_TUNABLE_PARAMETERS.md` - Balance parameters
- `scope.md` - MVP vs post-MVP features

## What's Left to Implement

- [ ] Fireball physics/collision with walls
- [ ] Enemy spawning and pathfinding (AStar2D)
- [ ] Build panel click-to-place functionality
- [ ] Individual rune behaviors (Portal, Explosive, Acceleration, etc.)
- [ ] Level content and progression
- [ ] Art assets and sound effects
- [ ] Win/lose conditions triggering

## Team

Built by the Arcane Laboratory team.
