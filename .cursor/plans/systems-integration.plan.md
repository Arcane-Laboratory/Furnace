# Furnace - Systems Integration Plan

**Version**: 1.1  
**Last Updated**: January 2, 2025  
**Purpose**: Detailed plan for integrating all game systems into Godot following best practices

**Builds On**: `initial_scaffold.md`  
**References**: GDD, content design docs (RUNES.md, ENEMIES.md, LEVELS.md, TILES.md)  
**Status**: See `implementation-status.md` for current implementation status

---

## Implementation Status

**Last Review**: January 2, 2025

### ✅ Completed Systems
- **Scaffold**: All Phase 0 tasks complete
- **Fireball System**: Fully implemented with movement, activation, collision
- **Rune Base**: Base class implemented and extensible
- **Redirect Rune**: One working rune type
- **Level Data Resource**: Structure defined and ready
- **Basic Grid**: Grid visualization and state tracking in game_scene
- **Phase Management**: Build/Active phase switching functional
- **UI Scenes**: All menu screens exist

### 🟡 Partially Implemented
- **Grid System**: Logic embedded in game_scene (not separate GridManager)
- **Resource System**: In GameManager (not separate ResourceManager)
- **Build UI**: Basic panel exists, missing rune/wall selection
- **Active UI**: Basic UI exists, minimal features

### ❌ Not Started
- **GridManager autoload** (grid logic currently in game_scene)
- **Pathfinding Manager**
- **Enemy System** (base, types, manager)
- **Wall System**
- **Furnace Scene**
- **Most Rune Types** (Portal, Explosive, Reflect, Acceleration)
- **Level Manager**
- **Selling System**
- **Path Preview**

**Note**: Some systems deviate from the planned architecture (e.g., GridManager embedded in game_scene). These work but are less modular. See `implementation-status.md` for details.

---

## Architecture Overview

### Core Principles
- **Scene-based architecture**: Each game entity is a scene
- **Autoloads for global state**: GameManager, GameConfig, SceneManager
- **Signals for communication**: Decouple systems using signals
- **Resource types for data**: Level data, enemy stats, rune configs as resources
- **Groups for organization**: Use Godot groups for entity management
- **TileMap for grid**: Use TileMap for terrain and grid visualization
- **Node composition**: Build complex entities from simple nodes

---

## System 1: Grid & Tile System

### Implementation Strategy

#### GridManager (Autoload Extension)
**File**: `scripts/autoload/grid_manager.gd`

**Responsibilities**:
- Grid coordinate conversion (world ↔ grid)
- Tile occupancy tracking
- Terrain type queries
- Placement validation

**Data Structure**:
```gdscript
# GridManager.gd
extends Node

const GRID_WIDTH = 13
const GRID_HEIGHT = 8
const TILE_SIZE = 32

var tile_occupancy = {}  # Dictionary: Vector2i -> TileContent enum
var terrain_map = {}     # Dictionary: Vector2i -> TerrainType enum

enum TileContent {
    EMPTY,
    WALL,
    RUNE,
    SPAWN_POINT
}

enum TerrainType {
    OPEN,
    ROCK_MOUNTAIN
}
```

**Key Functions**:
- `world_to_grid(world_pos: Vector2) -> Vector2i`
- `grid_to_world(grid_pos: Vector2i) -> Vector2`
- `is_tile_occupied(grid_pos: Vector2i) -> bool`
- `can_place_structure(grid_pos: Vector2i, structure_type: TileContent) -> bool`
- `get_terrain_type(grid_pos: Vector2i) -> TerrainType`

#### TileMap Setup
**Scene**: `scenes/game/grid_tilemap.tscn`

**Structure**:
- `TileMap` node for terrain visualization
- Separate TileSet layers:
  - Layer 0: Open Terrain
  - Layer 1: Rock/Mountain
  - Layer 2: Spawn Points (visual indicator)

**Integration**:
- GridManager reads TileMap for terrain data on level load
- TileMap updated when terrain changes (post-MVP)

---

## System 2: Fireball System

### Implementation Strategy

#### Fireball Scene
**File**: `scenes/game/entities/fireball.tscn`

**Node Structure**:
```
Fireball (CharacterBody2D)
├── Sprite2D (fireball sprite)
├── CollisionShape2D (small circle for collision)
├── Area2D (for rune detection)
│   └── CollisionShape2D (tile-sized for rune activation)
└── AnimationPlayer (optional: trail effects)
```

**Script**: `scripts/game/entities/fireball.gd`

**Properties**:
```gdscript
extends CharacterBody2D

@export var damage: int = GameConfig.fireball_damage
@export var base_speed: float = GameConfig.fireball_base_speed
var current_speed: float
var direction: Vector2i = Vector2i.DOWN  # Cardinal direction
var grid_position: Vector2i
var last_tile_center: Vector2i
```

**Key Functions**:
- `launch(start_pos: Vector2, start_dir: Vector2i)`
- `_physics_process(delta)` - Grid-aligned movement
- `_on_tile_center_reached(grid_pos: Vector2i)` - Rune activation check
- `change_direction(new_dir: Vector2i)`
- `increase_speed(amount: float)`
- `despawn()`

**Movement Logic**:
- Move in cardinal directions only (N/S/E/W)
- Track grid position, check tile center collision
- When tile center reached, check for rune activation
- Use `move_and_slide()` or manual movement with grid snapping

**Rune Activation**:
- Area2D detects when fireball enters tile center
- Signal emitted: `tile_center_reached(grid_pos: Vector2i)`
- GridManager checks if tile contains rune
- If rune exists, activate rune via signal

**Signals**:
- `tile_center_reached(grid_pos: Vector2i)`
- `rune_activated(rune: RuneBase)`
- `enemy_hit(enemy: Enemy)`
- `despawned()`

---

## System 3: Rune System

### Base Rune Architecture

#### Base Rune Scene
**File**: `scenes/game/entities/runes/base_rune.tscn`

**Node Structure**:
```
BaseRune (StaticBody2D)
├── Sprite2D (rune sprite)
├── CollisionShape2D (tile-sized)
└── AnimationPlayer (activation effects)
```

**Script**: `scripts/game/entities/runes/base_rune.gd`

**Base Class**:
```gdscript
extends StaticBody2D
class_name RuneBase

signal activated(fireball: Fireball)

@export var cost: int
@export var is_initial_element: bool = false  # Cannot be sold if true
var grid_position: Vector2i
var uses_remaining: int = 0  # 0 = infinite

func activate(fireball: Fireball) -> void:
    if uses_remaining > 0:
        uses_remaining -= 1
    activated.emit(fireball)
    _on_activated(fireball)

func _on_activated(fireball: Fireball) -> void:
    # Override in derived classes
    pass
```

### Individual Rune Types

#### Redirect Rune
**File**: `scenes/game/entities/runes/redirect_rune.tscn`  
**Script**: `scripts/game/entities/runes/redirect_rune.gd`

**Properties**:
```gdscript
extends RuneBase
class_name RedirectRune

@export var direction: Vector2i = Vector2i.DOWN
var can_edit_in_active_phase: bool = false  # false for regular, true for advanced
```

**Behavior**:
- On activation, change fireball direction
- Visual indicator shows current direction (sprite rotation or arrow)
- Direction editable in build phase (always)
- Advanced version: also editable in active phase

**Implementation**:
- Override `_on_activated()` to call `fireball.change_direction(direction)`
- Handle direction editing via UI interaction

#### Portal Rune
**File**: `scenes/game/entities/runes/portal_rune.tscn`  
**Script**: `scripts/game/entities/runes/portal_rune.gd`

**Properties**:
```gdscript
extends RuneBase
class_name PortalRune

var paired_portal: PortalRune = null
var portal_id: int = -1  # For MVP: first two placed = pair
```

**Behavior**:
- On activation, teleport fireball to paired portal
- Maintain fireball direction after teleport
- MVP: Track placement order, first two = pair

**Implementation**:
- PortalManager (autoload extension) tracks portal pairs
- On activation, get paired portal position
- Teleport fireball: `fireball.global_position = paired_portal.global_position`

#### Explosive Rune
**File**: `scenes/game/entities/runes/explosive_rune.tscn`  
**Script**: `scripts/game/entities/runes/explosive_rune.gd`

**Properties**:
```gdscript
extends RuneBase
class_name ExplosiveRune

@export var explosion_damage: int = GameConfig.explosive_rune_damage
@export var explosion_radius: int = 1  # 1 tile radius
```

**Behavior**:
- On activation, deal area damage to enemies
- Fireball continues (not consumed)
- Play SFX/VFX

**Implementation**:
- Override `_on_activated()` to:
  - Get all enemies in radius (use Area2D or spatial query)
  - Apply damage to each enemy
  - Play explosion effect (Particles2D or AnimationPlayer)
  - Play sound effect

#### Reflect Rune
**File**: `scenes/game/entities/runes/reflect_rune.tscn`  
**Script**: `scripts/game/entities/runes/reflect_rune.gd`

**Properties**:
```gdscript
extends RuneBase
class_name ReflectRune

@export var debounce_time: float = GameConfig.reflect_rune_debounce
var last_reflection_time: float = 0.0
```

**Behavior**:
- Reflect fireball to closest 90-degree angle
- Limited uses
- Debounce to prevent stuck loops

**Implementation**:
- Calculate closest 90-degree angle from fireball direction
- Check debounce timer before reflecting
- Update last_reflection_time

#### Acceleration Rune
**File**: `scenes/game/entities/runes/acceleration_rune.tscn`  
**Script**: `scripts/game/entities/runes/acceleration_rune.gd`

**Properties**:
```gdscript
extends RuneBase
class_name AccelerationRune

@export var speed_increase: float = GameConfig.acceleration_rune_speed_increase
```

**Behavior**:
- Permanently increase fireball speed
- Stack with multiple runes
- Cap at maximum speed

**Implementation**:
- Override `_on_activated()` to call `fireball.increase_speed(speed_increase)`
- Fireball handles speed cap internally

### Rune Manager
**File**: `scripts/autoload/rune_manager.gd` (extension of GameManager)

**Responsibilities**:
- Track all runes in level
- Handle rune placement/removal
- Manage rune availability (designer levers)
- Portal pairing logic (MVP)

---

## System 4: Wall System

### Wall Scene
**File**: `scenes/game/entities/wall.tscn`

**Node Structure**:
```
Wall (StaticBody2D)
├── Sprite2D (wall sprite)
└── CollisionShape2D (tile-sized, blocks pathfinding)
```

**Script**: `scripts/game/entities/wall.gd`

**Properties**:
```gdscript
extends StaticBody2D
class_name Wall

@export var cost: int = GameConfig.wall_cost
var grid_position: Vector2i
var is_initial_element: bool = false
```

**Behavior**:
- Blocks enemy pathfinding
- Blocks fireball (fireball despawns on collision)
- Can be sold (if not initial element)

**Pathfinding Integration**:
- Walls registered in GridManager as obstacles
- Pathfinding system queries GridManager for obstacles

---

## System 5: Enemy System

### Base Enemy Scene
**File**: `scenes/game/entities/enemy.tscn`

**Node Structure**:
```
Enemy (CharacterBody2D)
├── Sprite2D (enemy sprite)
├── CollisionShape2D (enemy collision)
├── Area2D (for fireball detection)
│   └── CollisionShape2D
└── HealthBar (optional: ProgressBar)
```

**Script**: `scripts/game/entities/enemy.gd`

**Base Class**:
```gdscript
extends CharacterBody2D
class_name EnemyBase

signal died
signal reached_furnace

@export var health: int
@export var max_health: int
@export var speed: float
var current_path: Array[Vector2i] = []
var current_path_index: int = 0
var grid_position: Vector2i
```

**Key Functions**:
- `take_damage(amount: int)`
- `set_path(path: Array[Vector2i])`
- `_physics_process(delta)` - Follow path
- `_on_furnace_reached()` - Game over

**Movement**:
- Follow pathfinding path (array of grid positions)
- Move toward next path node
- When node reached, advance to next
- Use `move_and_slide()` or manual movement

### Enemy Types

#### Basic Enemy
**File**: `scenes/game/entities/enemies/basic_enemy.tscn`  
**Script**: `scripts/game/entities/enemies/basic_enemy.gd`

```gdscript
extends EnemyBase
class_name BasicEnemy

func _ready():
    health = GameConfig.basic_enemy_health
    max_health = health
    speed = GameConfig.basic_enemy_speed
```

#### Fast Enemy
**File**: `scenes/game/entities/enemies/fast_enemy.tscn`  
**Script**: `scripts/game/entities/enemies/fast_enemy.gd`

```gdscript
extends EnemyBase
class_name FastEnemy

func _ready():
    health = GameConfig.fast_enemy_health
    max_health = health
    speed = GameConfig.fast_enemy_speed
```

#### Tank Enemy (Optional)
**File**: `scenes/game/entities/enemies/tank_enemy.tscn`  
**Script**: `scripts/game/entities/enemies/tank_enemy.gd`

```gdscript
extends EnemyBase
class_name TankEnemy

func _ready():
    health = GameConfig.tank_enemy_health
    max_health = health
    speed = GameConfig.tank_enemy_speed
```

### Enemy Manager
**File**: `scripts/autoload/enemy_manager.gd` (extension of GameManager)

**Responsibilities**:
- Spawn enemies (staggered timing)
- Track all active enemies
- Handle enemy death
- Check furnace collision

**Spawning Logic**:
- Timer-based spawning from spawn points
- Spawn enemy at spawn point position
- Set enemy path via pathfinding

---

## System 6: Pathfinding System

### Pathfinding Manager
**File**: `scripts/autoload/pathfinding_manager.gd`

**Responsibilities**:
- Calculate paths from spawn points to furnace
- Validate paths exist
- Provide path visualization data

**Algorithm**: A* pathfinding on grid

**Data Structure**:
```gdscript
extends Node
class_name PathfindingManager

var grid_width = GridManager.GRID_WIDTH
var grid_height = GridManager.GRID_HEIGHT

func calculate_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
    # A* implementation
    # Use GridManager to check obstacles
    pass

func validate_path_exists(start: Vector2i, end: Vector2i) -> bool:
    var path = calculate_path(start, end)
    return path.size() > 0

func get_all_paths(spawn_points: Array[Vector2i], furnace_pos: Vector2i) -> Dictionary:
    # Returns Dictionary: spawn_point -> path
    var paths = {}
    for spawn in spawn_points:
        paths[spawn] = calculate_path(spawn, furnace_pos)
    return paths
```

**Integration**:
- Called when player requests path preview
- Called when validating level start
- Called when enemy spawns (to set enemy path)

---

## System 7: Resource System

### Resource Manager
**File**: `scripts/autoload/resource_manager.gd` (extension of GameManager)

**Responsibilities**:
- Track current resources
- Handle resource spending
- Handle resource refunds (selling)

**Implementation**:
```gdscript
extends Node
class_name ResourceManager

signal resources_changed(new_amount: int)

var current_resources: int = 0

func set_resources(amount: int) -> void:
    current_resources = amount
    resources_changed.emit(current_resources)

func spend(amount: int) -> bool:
    if current_resources >= amount:
        current_resources -= amount
        resources_changed.emit(current_resources)
        return true
    return false

func refund(amount: int) -> void:
    current_resources += amount
    resources_changed.emit(current_resources)
```

**Integration**:
- Called when placing structures (walls/runes)
- Called when selling structures
- UI listens to `resources_changed` signal

---

## System 8: Level System

### Level Data Resource
**File**: `resources/level_data.gd`

**Resource Type**:
```gdscript
extends Resource
class_name LevelData

@export var level_id: int
@export var level_name: String
@export var initial_resources: int
@export var allowed_runes: Array[String] = []  # Empty = all default runes
@export var spawn_points: Array[Vector2i] = []
@export var initial_walls: Array[Vector2i] = []
@export var initial_runes: Dictionary = {}  # grid_pos -> rune_type
@export var enemy_wave: Dictionary = {}  # enemy_type -> count
@export var spawn_timing: Array[float] = []  # Delays between spawns
```

### Level Manager
**File**: `scripts/autoload/level_manager.gd` (extension of GameManager)

**Responsibilities**:
- Load level data
- Initialize level (place initial elements)
- Track level progression
- Handle level completion

**Functions**:
- `load_level(level_id: int)`
- `initialize_level(level_data: LevelData)`
- `complete_level()`
- `unlock_next_level()`

**Level Loading Flow**:
1. Load LevelData resource
2. Set resources via ResourceManager
3. Place initial walls/runes
4. Register spawn points
5. Set up enemy wave
6. Initialize pathfinding

---

## System 9: Furnace System

### Furnace Scene
**File**: `scenes/game/entities/furnace.tscn`

**Node Structure**:
```
Furnace (Area2D)
├── Sprite2D (furnace sprite)
├── CollisionShape2D (for enemy detection)
└── FireballSpawnPoint (Marker2D for fireball launch position)
```

**Script**: `scripts/game/entities/furnace.gd`

**Properties**:
```gdscript
extends Area2D
class_name Furnace

signal destroyed

const HEALTH = 1

func _on_enemy_entered(enemy: EnemyBase) -> void:
    destroyed.emit()
    GameManager.game_over(false)  # false = defeat
```

**Behavior**:
- Fixed position at top center
- 1 HP (instant destruction on enemy contact)
- Spawns fireball when level starts

**Fireball Launch**:
- On level start, spawn fireball at furnace position
- Fireball launches downward automatically

---

## System 10: UI System

### Build Phase UI
**File**: `scenes/ui/build_phase_ui.tscn`

**Node Structure**:
```
BuildPhaseUI (Control)
├── ResourceDisplay (Label)
├── BuildPanel (VBoxContainer)
│   ├── WallButton (Button)
│   ├── RedirectRuneButton (Button)
│   ├── AdvancedRedirectRuneButton (Button)
│   ├── PortalRuneButton (Button)
│   ├── ReflectRuneButton (Button)
│   ├── ExplosiveRuneButton (Button)
│   └── AccelerationRuneButton (Button)
├── StartButton (Button)
└── PathPreviewButton (Button)
```

**Script**: `scripts/ui/build_phase_ui.gd`

**Functionality**:
- Display current resources
- Show costs for each structure
- Handle drag-to-place (or click-to-place)
- Enable/disable Start button based on path validation
- Show path preview on demand

**Integration**:
- Listens to `resources_changed` signal
- Emits signals for structure placement
- Calls PathfindingManager for validation

### Active Phase UI
**File**: `scenes/ui/active_phase_ui.tscn`

**Node Structure**:
```
ActivePhaseUI (Control)
├── ResourceDisplay (Label)
└── LevelDisplay (Label)
```

**Script**: `scripts/ui/active_phase_ui.gd`

**Functionality**:
- Minimal UI (resource display, level name)
- Player observes only
- Advanced Redirect Rune editing (if applicable)

### Selling UI
**File**: `scenes/ui/sell_menu.tscn`

**Node Structure**:
```
SellMenu (Control)
├── SellButton (Button)
└── CancelButton (Button)
```

**Script**: `scripts/ui/sell_menu.gd`

**Functionality**:
- Appears above clicked structure
- Full refund on sell
- Only in build phase
- Cannot sell initial elements

---

## System 11: Phase Management

### Phase Manager
**File**: `scripts/game/phase_manager.gd` (part of GameScene)

**Responsibilities**:
- Manage BUILD_PHASE ↔ ACTIVE_PHASE transitions
- Enable/disable appropriate systems
- Handle phase-specific UI

**State Machine**:
```gdscript
extends Node
class_name PhaseManager

enum Phase {
    BUILD,
    ACTIVE
}

signal phase_changed(new_phase: Phase)

var current_phase: Phase = Phase.BUILD

func start_active_phase() -> void:
    # Validate path exists
    if not PathfindingManager.validate_path_exists(...):
        return
    
    current_phase = Phase.ACTIVE
    phase_changed.emit(current_phase)
    
    # Spawn fireball
    # Start enemy spawning
    # Disable build UI
    # Enable active UI

func return_to_build_phase() -> void:
    # Only if level not started yet (MVP: not applicable)
    pass
```

---

## System 12: Signal Architecture

### Global Signals
**File**: `scripts/autoload/signals.gd` (autoload)

**Purpose**: Centralized signal definitions for decoupling

```gdscript
extends Node

# Fireball signals
signal fireball_tile_center_reached(grid_pos: Vector2i)
signal fireball_rune_activated(rune: RuneBase)
signal fireball_enemy_hit(enemy: EnemyBase)
signal fireball_despawned

# Enemy signals
signal enemy_spawned(enemy: EnemyBase)
signal enemy_died(enemy: EnemyBase)
signal enemy_reached_furnace

# Structure signals
signal structure_placed(structure: Node, grid_pos: Vector2i)
signal structure_sold(structure: Node, grid_pos: Vector2i)

# Level signals
signal level_started
signal level_completed(victory: bool)
```

---

## File Structure

### Complete Directory Layout
```
godot/
├── assets/
│   ├── sprites/
│   │   ├── board_background.png
│   │   ├── fireball.png
│   │   ├── enemies/
│   │   ├── runes/
│   │   └── walls/
│   └── audio/
├── scenes/
│   ├── ui/
│   │   ├── title_screen.tscn
│   │   ├── main_menu.tscn
│   │   ├── game_over.tscn
│   │   ├── pause_menu.tscn
│   │   ├── build_phase_ui.tscn
│   │   ├── active_phase_ui.tscn
│   │   └── sell_menu.tscn
│   └── game/
│       ├── game_scene.tscn
│       ├── grid_tilemap.tscn
│       └── entities/
│           ├── fireball.tscn
│           ├── furnace.tscn
│           ├── wall.tscn
│           ├── enemies/
│           │   ├── basic_enemy.tscn
│           │   ├── fast_enemy.tscn
│           │   └── tank_enemy.tscn
│           └── runes/
│               ├── base_rune.tscn
│               ├── redirect_rune.tscn
│               ├── advanced_redirect_rune.tscn
│               ├── portal_rune.tscn
│               ├── reflect_rune.tscn
│               ├── explosive_rune.tscn
│               └── acceleration_rune.tscn
├── scripts/
│   ├── autoload/
│   │   ├── scene_manager.gd
│   │   ├── game_manager.gd
│   │   ├── game_config.gd
│   │   ├── grid_manager.gd
│   │   ├── pathfinding_manager.gd
│   │   ├── resource_manager.gd
│   │   ├── level_manager.gd
│   │   ├── enemy_manager.gd
│   │   ├── rune_manager.gd
│   │   └── signals.gd
│   ├── ui/
│   │   ├── title_screen.gd
│   │   ├── main_menu.gd
│   │   ├── game_over.gd
│   │   ├── pause_menu.gd
│   │   ├── build_phase_ui.gd
│   │   ├── active_phase_ui.gd
│   │   └── sell_menu.gd
│   └── game/
│       ├── game_scene.gd
│       ├── phase_manager.gd
│       └── entities/
│           ├── fireball.gd
│           ├── furnace.gd
│           ├── wall.gd
│           ├── enemies/
│           │   ├── enemy_base.gd
│           │   ├── basic_enemy.gd
│           │   ├── fast_enemy.gd
│           │   └── tank_enemy.gd
│           └── runes/
│               ├── base_rune.gd
│               ├── redirect_rune.gd
│               ├── advanced_redirect_rune.gd
│               ├── portal_rune.gd
│               ├── reflect_rune.gd
│               ├── explosive_rune.gd
│               └── acceleration_rune.gd
└── resources/
    ├── level_data.gd
    └── levels/
        ├── level_1.tres
        ├── level_2.tres
        └── level_3.tres
```

---

## Implementation Order

### Phase 1: Foundation (After Scaffold)
1. GridManager autoload
2. Grid TileMap setup
3. Basic tile occupancy tracking

### Phase 2: Core Entities
1. Fireball scene and script
2. Wall scene and script
3. Base Rune scene and script
4. Furnace scene and script

### Phase 3: Rune Types
1. Redirect Rune
2. Advanced Redirect Rune
3. Explosive Rune
4. Acceleration Rune
5. Reflect Rune
6. Portal Rune (with pairing logic)

### Phase 4: Enemy System
1. Base Enemy scene and script
2. Enemy types (Basic, Fast, Tank)
3. Enemy Manager
4. Pathfinding Manager

### Phase 5: Systems Integration
1. Resource Manager
2. Level Manager
3. Phase Manager
4. Signal architecture

### Phase 6: UI Integration
1. Build Phase UI
2. Active Phase UI
3. Selling system
4. Path preview visualization

### Phase 7: Polish
1. Visual effects
2. Sound effects
3. Performance optimization
4. Testing and balancing

---

## Godot Best Practices Applied

### 1. Scene Composition
- Each entity is a reusable scene
- Base classes for shared functionality
- Node composition over inheritance where appropriate

### 2. Autoloads
- Global state in autoloads (GameManager, GameConfig)
- System managers as autoloads (GridManager, PathfindingManager)
- Signals autoload for decoupling

### 3. Signals
- Use signals for communication between systems
- Avoid direct node references where possible
- Centralized signal definitions

### 4. Resources
- Level data as resources (LevelData)
- Config data in GameConfig autoload
- Easy to edit in Godot editor

### 5. Groups
- Use groups for entity management (e.g., "enemies", "runes")
- Easy to query all entities of a type

### 6. Performance
- Object pooling for enemies (if needed)
- Efficient pathfinding algorithm
- Limit particle effects
- Optimize sprite rendering

### 7. Code Organization
- Clear separation of concerns
- Single responsibility principle
- Consistent naming conventions
- Documentation in code

---

## Testing Strategy

### Unit Testing
- Test individual systems in isolation
- Test pathfinding algorithm
- Test resource calculations
- Test rune activation logic

### Integration Testing
- Test system interactions
- Test phase transitions
- Test level loading
- Test signal connections

### Playtesting
- Test gameplay flow
- Test difficulty progression
- Test UI interactions
- Test edge cases

---

**Status**: Ready for implementation. All systems defined with Godot best practices.
