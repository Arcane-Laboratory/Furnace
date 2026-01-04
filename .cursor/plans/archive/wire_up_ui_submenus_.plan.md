---
name: Wire Up UI Submenus
overview: Wire up the Details Submenu (shown when Details button clicked on build items) and Level In Progress Menu (shown during Active Phase) with live game data and proper navigation.
todos:
  - id: add-description-field
    content: Add description field to BuildableItemDefinition resource
    status: completed
  - id: details-menu-item-script
    content: Create details_menu_item.gd script with configure() method
    status: completed
  - id: details-submenu-script
    content: Create details_submenu.gd script with show_item_details() and close signal
    status: completed
  - id: build-menu-item-signal
    content: Add details_requested signal to build_menu_item.gd
    status: completed
  - id: build-submenu-signal
    content: Add show_details_requested signal to build_submenu.gd
    status: completed
  - id: level-progress-submenu-script
    content: Create level_in_progress_submenu.gd for tracking active phase stats
    status: completed
  - id: level-progress-menu-script
    content: Create level_in_progress_menu.gd to coordinate the menu
    status: completed
  - id: game-scene-details
    content: Update game_scene.gd for details submenu swap
    status: completed
  - id: game-scene-active-phase
    content: Update game_scene.gd for level in progress menu during active phase
    status: completed
  - id: update-tscn-scripts
    content: Add script references to .tscn scene files
    status: completed
---

# Wire Up UI Submenus

## Overview

This plan wires up two new designer-created submenus:

1. **Details Submenu** - Shows item details when "Details" button is clicked in build menu
2. **Level In Progress Menu** - Replaces build menu during Active Phase with live stats

---

## Part 1: Details Submenu

### 1.1 Add Description Field to BuildableItemDefinition

Update [buildable_item_definition.gd](godot/scripts/resources/buildable_item_definition.gd) to add:

```gdscript
@export_multiline var description: String = ""  # Item description for details panel
```

### 1.2 Create Script for details_menu_item.tscn

Create `godot/scripts/ui/details_menu_item.gd`:

- Add `configure(item_type, name, cost, icon_color, description)` method
- Update the Label (item name), MenuRune icon/cost, and Label2 (description)
- Node references: `%MenuLabel` or paths like `CenterContainer/VBoxContainer/Label`, `CenterContainer/VBoxContainer/MenuRune`, `CenterContainer/VBoxContainer/CenterContainer/Panel/MarginContainer/Label2`

### 1.3 Create Script for details_submenu.tscn

Create `godot/scripts/ui/details_submenu.gd`:

- Signal: `close_requested`
- Reference: `DetailsSubmenuItem` and `Close` button
- Method: `show_item_details(definition: BuildableItemDefinition)` - configures the details item
- Connect Close button to emit `close_requested`

### 1.4 Update build_menu_item.gd

Add signal in [build_menu_item.gd](godot/scripts/ui/build_menu_item.gd):

```gdscript
signal details_requested(item_type: String)
```

Update `_on_details_pressed()`:

```gdscript
func _on_details_pressed() -> void:
    details_requested.emit(item_type)
```

### 1.5 Update build_submenu.gd

Add signal and handler in [build_submenu.gd](godot/scripts/ui/build_submenu.gd):

```gdscript
signal show_details_requested(definition: BuildableItemDefinition)
```

In `_connect_menu_item_signals()`, also connect `details_requested` signal to a handler that looks up the item definition and emits `show_details_requested`.

### 1.6 Update game_scene.gd

In [game_scene.gd](godot/scripts/game/game_scene.gd):

- Load and instantiate `details_submenu.tscn` as a sibling to `build_submenu`
- Connect `build_submenu.show_details_requested` to swap visibility
- Connect `details_submenu.close_requested` to swap back
- Track which submenu is active

---

## Part 2: Level In Progress Menu

### 2.1 Create Script for level_in_progress_submenu.tscn

Create `godot/scripts/ui/level_in_progress_submenu.gd`:

- Track three stats: `soot_vanquished`, `sparks_earned`, `damage_dealt`
- Node references using unique names: `%LevelValue`, `%MoneyValue`, `%HeatValue`
- Methods: `reset_stats()`, `add_soot_vanquished(count)`, `add_sparks_earned(amount)`, `add_damage_dealt(amount)`
- Update labels when stats change

### 2.2 Create Script for level_in_progress_menu.tscn

Create `godot/scripts/ui/level_in_progress_menu.gd`:

- Signal: `pause_pressed`, `restart_pressed`
- References: `GameSubmenu` (top section), `InProgressSubmenu` (stats section)
- Connect `GameSubmenu.start_pressed` as pause action
- Connect Restart Level button
- Methods: `set_level(level)`, `reset_stats()`, `get_in_progress_submenu()` for stats access

### 2.3 Update game_scene.gd for Active Phase

Modify [game_scene.gd](godot/scripts/game/game_scene.gd):

- Load and instantiate `level_in_progress_menu.tscn` as sibling to build/details submenus
- On `_start_active_phase()`:
  - Hide `build_submenu` (and `details_submenu` if visible)
  - Show `level_in_progress_menu`
  - Reset stats counters
- Connect `EnemyManager.enemy_died` to increment soot vanquished
- Connect `GameManager.resources_changed` during active phase to track sparks earned (delta)
- Connect fireball `enemy_hit` signal to increment damage dealt
- On `_start_build_phase()`:
  - Hide `level_in_progress_menu`
  - Show `build_submenu`

### 2.4 Wire Up Live Data Connections

In `game_scene.gd`:

```gdscript
# Track sparks at phase start to calculate earned amount
var sparks_at_phase_start: int = 0

func _start_active_phase() -> void:
    sparks_at_phase_start = GameManager.resources
    level_in_progress_menu.reset_stats()
    # ... existing code

func _on_resources_changed(new_amount: int) -> void:
    if GameManager.current_state == GameManager.GameState.ACTIVE_PHASE:
        var delta = new_amount - sparks_at_phase_start
        if delta > 0:
            level_in_progress_menu.get_in_progress_submenu().set_sparks_earned(delta)

func _on_fireball_enemy_hit(enemy: Node2D, damage: int) -> void:
    if level_in_progress_menu:
        level_in_progress_menu.get_in_progress_submenu().add_damage_dealt(damage)
```

Connect `EnemyManager.enemy_died` to increment soot vanquished counter.

---

## File Summary

| File | Action |

| ------------------------------------------------------ | ----------------------------------- |

| `godot/scripts/resources/buildable_item_definition.gd` | Add `description` field |

| `godot/scripts/ui/details_menu_item.gd` | Create new |

| `godot/scripts/ui/details_submenu.gd` | Create new |

| `godot/scripts/ui/build_menu_item.gd` | Add `details_requested` signal |

| `godot/scripts/ui/build_submenu.gd` | Add `show_details_requested` signal |

| `godot/scripts/ui/level_in_progress_submenu.gd` | Create new |

| `godot/scripts/ui/level_in_progress_menu.gd` | Create new |

| `godot/scripts/game/game_scene.gd` | Add submenu management |

| `godot/scenes/ui/details_menu_item.tscn` | Add script reference |

| `godot/scenes/ui/details_submenu.tscn` | Add script reference |

| `godot/scenes/ui/level_in_progress_submenu.tscn` | Add script reference |

| `godot/scenes/ui/level_in_progress_menu.tscn` | Add script reference |
