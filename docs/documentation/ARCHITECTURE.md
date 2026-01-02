# Technical Architecture

## Overview

Furnace is a monorepo containing three main components:

1. **godot/** - The game itself, built with Godot 4.x
2. **web/** - Next.js wrapper for web deployment
3. **server/** - Express server (placeholder for future multiplayer)

## Project Structure

```
one-shot/
  .cursor/rules/        # Cursor AI rules for consistent development
  docs/                 # Design documents and plans
  godot/                # Godot game project
    scenes/             # Godot scene files (.tscn)
    scripts/            # GDScript files (.gd)
    resources/          # Game resources and configs
  web/                  # Next.js web client
    app/                # Next.js App Router pages
    lib/                # Shared utilities and hooks
    public/game/        # Godot web export destination
  server/               # Express server
    src/                # TypeScript source
```

## Technology Stack

### Game (Godot)

- **Engine**: Godot 4.5
- **Language**: GDScript
- **Renderer**: GL Compatibility (required for web export)
- **Resolution**: 640x360 pixel perfect

### Web Client

- **Framework**: Next.js 14 (App Router)
- **UI Library**: Material-UI (MUI)
- **Language**: TypeScript

### Server

- **Runtime**: Node.js
- **Framework**: Express.js
- **Language**: TypeScript

## Data Flow

### Single Player (MVP)

```
Godot Game <-> Local Game State
     |
     v
Web Wrapper (iframe embed)
```

### Future Multiplayer

```
Godot Game <-> WebSocket <-> Server <-> Game State
                              |
                              v
                         Other Players
```

## Build and Deploy

### Web Export

1. Export Godot project to `web/public/game/`
2. Build Next.js: `yarn build`
3. Deploy to Vercel or similar

### Development

```bash
# Terminal 1: Next.js dev server
yarn dev

# Terminal 2: Server (if needed)
yarn dev:server

# Godot: Open project in Godot Editor
```

## Key Design Decisions

1. **Yarn Workspaces**: Shared dependencies, unified scripts
2. **Material-UI**: Consistent UI components with dark theme
3. **GL Compatibility**: Required for Godot web export
4. **Pixel Perfect**: 640x360 base resolution with viewport scaling
