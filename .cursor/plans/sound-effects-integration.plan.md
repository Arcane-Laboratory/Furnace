# Sound Effects Integration Plan

## Overview
Integrate 14 sound effects into the Furnace game with designer-tunable volume controls. All sound files already exist in `godot/assets/audio/`.

## Architecture

### 1. Extend AudioManager with Sound Effect System
**File**: `godot/scripts/autoload/audio_manager.gd`

**Changes**:
- Add a dictionary to map sound effect names to file paths
- Add a dictionary to store volume multipliers for each sound effect (designer-tunable)
- Create a `SoundEffectConfig` resource class or use a simple dictionary for volume settings
- Extend `play_sfx()` to accept volume parameter and apply sound-specific volume multiplier
- Add methods: `play_sound_effect(effect_name: String)`, `set_sound_volume(effect_name: String, volume_multiplier: float)`, `get_sound_volume(effect_name: String) -> float`

**Sound Effect Mapping**:
```gdscript
var sound_effects: Dictionary = {
    "rune-accelerate": "res://assets/audio/rune-accelerate.wav",
    "rune-generic": "res://assets/audio/rune-generic.wav",
    "burn": "res://assets/audio/burn.wav",
    "fireball-spawn": "res://assets/audio/fireball-spawn.wav",
    "enemy-death": "res://assets/audio/enemy-death.wav",
    "furnace-death": "res://assets/audio/furnace-death.wav",
    "level-failed": "res://assets/audio/level-failed.wav",
    "click": "res://assets/audio/click.wav",
    "structure-sell": "res://assets/audio/structure-sell.wav",
    "structure-buy": "res://assets/audio/structure-buy.wav",
    "pickup-spark": "res://assets/audio/pickup-spark.wav",
    "invalid-action": "res://assets/audio/invalid-action.wav",
    "fireball-travel": "res://assets/audio/fireball-travel.wav"
}

var sound_volumes: Dictionary = {}  # Will be initialized with default 1.0 for each
```

**Volume Control System**:
- Default volume multiplier: 1.0 for all sounds
- Volume range: 0.0 (silent) to 2.0 (double volume)
- Store volumes in a config file or as exported variables for designer access
- Apply volume: `final_volume_db = base_volume_db + linear_to_db(volume_multiplier)`

### 2. Create Sound Effect Configuration Resource (Optional but Recommended)
**File**: `godot/scripts/resources/sound_effect_config.gd` (NEW)

**Purpose**: Allow designers to tune volumes in the Godot editor without code changes

**Structure**:
```gdscript
extends Resource
class_name SoundEffectConfig

@export var rune_accelerate_volume: float = 1.0
@export var rune_generic_volume: float = 1.0
@export var burn_volume: float = 1.0
# ... etc for all 14 sounds
```

**Usage**: Create a `.tres` resource file that designers can edit in the inspector.

### 3. Integration Points

#### A. Rune Activation Sounds
**Files**: 
- `godot/scripts/entities/runes/acceleration_rune.gd`
- `godot/scripts/entities/runes/redirect_rune.gd`
- `godot/scripts/entities/runes/reflect_rune.gd`
- `godot/scripts/entities/runes/explosive_rune.gd`
- `godot/scripts/entities/runes/portal_rune.gd`

**Changes**:
- In `acceleration_rune.gd` `_on_activate()`: Add `AudioManager.play_sound_effect("rune-accelerate")`
- In other rune `_on_activate()` methods: Add `AudioManager.play_sound_effect("rune-generic")` (or specific sounds if different runes need different sounds)

**Location**: After rune activation logic, before visual feedback

#### B. Enemy Damage Sound
**File**: `godot/scripts/entities/enemies/enemy_base.gd`

**Changes**:
- In `take_damage()` function: Add `AudioManager.play_sound_effect("burn")` when damage is applied
- Play sound before health check to ensure it plays even on killing blow

**Location**: Line ~83, after `health -= amount` and before health bar update

#### C. Enemy Death Sound
**File**: `godot/scripts/entities/enemies/enemy_base.gd`

**Changes**:
- In `_die()` function: Add `AudioManager.play_sound_effect("enemy-death")`
- Play sound at the start of death sequence

**Location**: Line ~106, at the beginning of `_die()` function

#### D. Fireball Spawn Sound
**File**: `godot/scripts/game/game_scene.gd`

**Changes**:
- In `_launch_fireball()` function: Add `AudioManager.play_sound_effect("fireball-spawn")`
- Play sound when fireball is launched from furnace

**Location**: Line ~852, after fireball is instantiated and before `fireball.launch()`

#### E. Fireball Travel Sound (Looping)
**File**: `godot/scripts/entities/fireball.gd`

**Changes**:
- Add an `AudioStreamPlayer2D` node to the fireball scene (for positional audio)
- Or use a global looping sound effect in AudioManager
- Start playing in `launch()` function
- Stop playing in `_destroy()` function
- Use `AudioStreamPlayer` with looping enabled, or manage looping manually

**Location**: 
- Start: Line ~114 in `launch()` function
- Stop: Line ~303 in `_destroy()` function

**Note**: This is a looping sound, so it needs special handling. Consider using a dedicated `AudioStreamPlayer` that loops while fireball is active.

#### F. Structure Purchase Sound
**File**: `godot/scripts/game/game_scene.gd`

**Changes**:
- In `_on_placement_succeeded()` function: Add `AudioManager.play_sound_effect("structure-buy")`

**Location**: Line ~1311, replace the comment with actual sound call

#### G. Structure Sell Sound
**File**: `godot/scripts/game/game_scene.gd`

**Changes**:
- In `_on_item_sold()` function: Add `AudioManager.play_sound_effect("structure-sell")`

**Location**: Line ~1317, replace the comment with actual sound call

#### H. Invalid Action Sound
**File**: `godot/scripts/game/game_scene.gd`

**Changes**:
- In `_on_placement_failed()` function: Add `AudioManager.play_sound_effect("invalid-action")`

**Location**: Line ~1306, after showing error snackbar

#### I. Click Sound
**Files**: Multiple UI files with button presses

**Changes**:
- Create a helper function in AudioManager: `play_ui_click()` that plays the click sound
- Add click sound to all button `pressed` signal handlers:
  - `godot/scripts/ui/build_menu_item.gd`: `_on_details_pressed()`
  - `godot/scripts/ui/main_menu.gd`: All button handlers
  - `godot/scripts/ui/pause_menu.gd`: All button handlers
  - `godot/scripts/ui/game_over.gd`: Button handlers
  - `godot/scripts/ui/game_submenu.gd`: `_on_start_button_pressed()`
  - `godot/scripts/ui/tile_tooltip.gd`: Button handlers
  - Other UI files with buttons

**Approach**: Add `AudioManager.play_sound_effect("click")` at the start of each button handler function

#### J. Pickup Spark Sound
**File**: `godot/scripts/game/game_scene.gd` or wherever sparks/resources are collected

**Changes**:
- Find where sparks/resources are collected (likely in `FloatingNumberManager` or resource collection logic)
- Add `AudioManager.play_sound_effect("pickup-spark")` when resources are collected

**Note**: May need to search for where resources are added to determine exact location

#### K. Furnace Death Sound
**File**: `godot/scripts/game/game_scene.gd`

**Changes**:
- In `_on_furnace_destroyed()` function: Add `AudioManager.play_sound_effect("furnace-death")`
- Play sound before calling `lose_level()`

**Location**: Line ~699, at the start of `_on_furnace_destroyed()`

#### L. Level Failed Sound
**File**: `godot/scripts/game/game_scene.gd`

**Changes**:
- In `lose_level()` function: Add `AudioManager.play_sound_effect("level-failed")`
- Play sound when level is lost (may be redundant with furnace-death, but include both per requirements)

**Location**: Find `lose_level()` function and add sound call

### 4. Volume Tuning System for Designers

#### Option A: Export Variables in AudioManager (Simplest)
**File**: `godot/scripts/autoload/audio_manager.gd`

**Changes**:
- Add `@export` variables for each sound volume:
```gdscript
@export_range(0.0, 2.0, 0.1) var volume_rune_accelerate: float = 1.0
@export_range(0.0, 2.0, 0.1) var volume_rune_generic: float = 1.0
# ... etc
```
- In `play_sound_effect()`, look up the volume multiplier and apply it

**Pros**: Simple, visible in inspector
**Cons**: Many exported variables, harder to organize

#### Option B: Sound Effect Config Resource (Recommended)
**File**: `godot/scripts/resources/sound_effect_config.gd` (NEW)
**File**: `godot/resources/sound_effect_config.tres` (NEW)

**Changes**:
- Create a Resource class with all volume settings as exported variables
- Create a `.tres` resource file that designers can edit
- AudioManager loads this resource and uses it for volume lookups

**Pros**: Clean separation, easy for designers to edit, can be version controlled
**Cons**: Requires creating resource file

#### Option C: Dictionary with Editor Plugin (Advanced)
- Create a custom editor plugin that provides a UI for editing sound volumes
- Store volumes in a JSON or resource file

**Pros**: Best UX for designers
**Cons**: Most complex, requires editor plugin development

**Recommendation**: Use Option B (Resource file) as it balances simplicity with designer usability.

### 5. Implementation Steps

1. **Extend AudioManager**:
   - Add sound effect dictionary
   - Add volume dictionary or config resource loading
   - Modify `play_sfx()` to accept volume parameter
   - Add `play_sound_effect()` wrapper method
   - Initialize default volumes (all 1.0)

2. **Create Sound Effect Config Resource** (if using Option B):
   - Create `sound_effect_config.gd` resource class
   - Create `sound_effect_config.tres` resource file
   - Load resource in AudioManager `_ready()`

3. **Integrate Rune Sounds**:
   - Add sound calls to all rune `_on_activate()` methods
   - Test each rune type

4. **Integrate Enemy Sounds**:
   - Add burn sound to `take_damage()`
   - Add death sound to `_die()`
   - Test damage and death scenarios

5. **Integrate Fireball Sounds**:
   - Add spawn sound to `_launch_fireball()`
   - Add travel sound (looping) to fireball `launch()` and `_destroy()`
   - Test fireball spawning and movement

6. **Integrate Structure Sounds**:
   - Add buy sound to placement success
   - Add sell sound to item sold
   - Add invalid sound to placement failed
   - Test placement scenarios

7. **Integrate UI Click Sounds**:
   - Add click sound to all button handlers
   - Test UI interactions

8. **Integrate Game State Sounds**:
   - Add furnace-death sound
   - Add level-failed sound
   - Add pickup-spark sound (find collection point)
   - Test game over scenarios

9. **Testing**:
   - Test all sound effects play at correct times
   - Test volume adjustments work correctly
   - Test that sounds don't overlap incorrectly
   - Test fireball travel sound loops correctly and stops when fireball is destroyed

10. **Documentation**:
   - Document how designers can adjust volumes
   - Document which sounds play in which scenarios
   - Add comments in code explaining sound integration points

### 6. Special Considerations

#### Fireball Travel Sound (Looping)
- This sound needs to loop while the fireball is active
- Options:
  - Use `AudioStreamPlayer` with `stream.loop = true` and manage start/stop
  - Use `AudioStreamPlayer2D` attached to fireball for positional audio
  - Use a dedicated looping player in AudioManager that's controlled by fireball state

**Recommendation**: Use a dedicated `AudioStreamPlayer` in AudioManager for fireball travel, with methods `start_fireball_travel()` and `stop_fireball_travel()` that the fireball calls.

#### Volume Application
- Apply volume multiplier: `volume_db = linear_to_db(base_volume * multiplier)`
- Base volume should be 0.0 dB (full volume) for most sounds
- Volume multiplier range: 0.0 (silent) to 2.0 (double volume, +6dB)

#### Sound Effect Pooling (Future Optimization)
- If many sounds play simultaneously, consider using `AudioStreamPlayer` pooling
- Current single `sfx_player` may cut off sounds if multiple play quickly
- For now, single player is acceptable, but note this limitation

### 7. File Changes Summary

**Modified Files**:
- `godot/scripts/autoload/audio_manager.gd` - Core sound system
- `godot/scripts/entities/enemies/enemy_base.gd` - Damage and death sounds
- `godot/scripts/entities/fireball.gd` - Travel sound (looping)
- `godot/scripts/entities/runes/*.gd` - Rune activation sounds (5 files)
- `godot/scripts/game/game_scene.gd` - Fireball spawn, structure sounds, game state sounds
- `godot/scripts/ui/*.gd` - Click sounds (multiple UI files)

**New Files**:
- `godot/scripts/resources/sound_effect_config.gd` - Volume configuration resource (if using Option B)
- `godot/resources/sound_effect_config.tres` - Volume settings file (if using Option B)

**Total**: ~15 files modified, 0-2 files created (depending on volume system choice)
