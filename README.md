# Furnace

A tower defense game where you build walls and runes, then watch a single fireball ignite your defenses to defeat waves of enemies before they reach the furnace.

Built for a 3-day game jam with the theme "Support" and prompt "One Shot".

## Project Structure

```
one-shot/
  godot/          # Godot 4.x game project
  web/            # Next.js wrapper for web deployment
  server/         # Express server (placeholder for multiplayer)
  docs/           # Design documents and plans
```

## Quick Start

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

### Godot

1. Open `godot/project.godot` in Godot Editor
2. For web export, export to `web/public/game/`

## Game Overview

- **Build Phase**: Place walls and runes on a 13x8 grid
- **Active Phase**: Watch the fireball automatically launch and interact with your runes
- **Goal**: Defeat all enemies before they reach the furnace (1 HP)

## Tech Stack

- **Game Engine**: Godot 4.x (GDScript)
- **Web Client**: Next.js 14 + Material-UI
- **Server**: Express.js + TypeScript (minimal, for future multiplayer)

## Documentation

See `docs/` for:
- Game Design Document
- Scope and MVP definition
- Technical architecture

## Team

Built by the Arcane Laboratory team.
