# Contributing Guide

## Getting Started

### Prerequisites

- Node.js 18+
- Yarn 1.22+
- Godot 4.5+

### Setup

```bash
# Clone the repository
git clone https://github.com/Arcane-Laboratory/one-shot.git
cd one-shot

# Install dependencies
yarn install
```

## Development Workflow

### Godot Development

1. Open `godot/project.godot` in Godot Editor
2. Make changes to scenes and scripts
3. Test in editor using F5

### Web Development

```bash
# Start Next.js dev server
yarn dev
```

### Server Development

```bash
# Start Express server with hot reload
yarn dev:server
```

## Code Style

### GDScript

- Use strict typing for all variables and parameters
- Follow snake_case for files, variables, functions
- Follow PascalCase for classes and nodes
- Keep methods under 30 lines
- Use signals for loose coupling

### TypeScript

- Use strict mode
- Prefer explicit types over inference for function signatures
- Use async/await over raw Promises
- Follow ESLint configuration

### General

- No emojis in code, commits, or logs
- Prefer less code over more code
- Reuse existing patterns and abstractions

## Git Workflow

### Branches

- `main` - Production-ready code
- Feature branches: `feature/description`
- Bug fixes: `fix/description`

### Commits

- Write clear, concise commit messages
- Use conventional commit format when appropriate
- No emojis in commit messages

Example:
```
Add redirect rune implementation

- Create redirect_rune.gd with direction logic
- Add redirect rune scene with collision
- Update main scene to include rune placement
```

### Pull Requests

1. Create feature branch from `main`
2. Make changes and test locally
3. Push branch and create PR
4. Request review from team member
5. Merge after approval

## Testing

### Godot

- Test all scenes in editor before committing
- Test web export regularly
- Verify 640x360 resolution looks correct

### Web

```bash
yarn lint
yarn build
```

## File Organization

### Adding New Scenes

1. Create scene file in `godot/scenes/`
2. Create corresponding script in `godot/scripts/`
3. Follow naming conventions (snake_case)

### Adding New Components

1. Create in `web/app/` or `web/lib/`
2. Use TypeScript with explicit types
3. Follow MUI patterns for styling

## Cursor AI Rules

The `.cursor/rules/` folder contains AI assistant guidelines:

- `global.mdc` - Applied to all files
- `godot.mdc` - Applied to `godot/**`
- `web.mdc` - Applied to `web/**`
- `server.mdc` - Applied to `server/**`

These ensure consistent AI-generated code across the team.

## Questions?

Check `docs/` for design documents and game specifications.
