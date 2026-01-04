# Gameplay Systems Implementation Plan

Based on resolutions from `docs/iteration-resolutions.md`.

## Overview

This plan implements the core gameplay improvements identified in the iteration review, focusing on systems and content iteration rather than level design.

## Implementation Priority Order

1. **Core rune system changes** (multi-use runes, Power Rune, acceleration cap)
2. **New wall/tile types** (Explosive Wall, Mud Tile)
3. **Sound effects integration** (per existing plan)
4. **Debug mode config** (config file implementation)
5. **Asset integration** (as needed)
6. **Game victory card** (MVP requirement)

---

## Phase 1: Core Rune System Changes

### 1.1: Make All Runes Multi-Use

#### Files to Modify:
- `godot/scripts/entities/runes/explosive_rune.gd`
- `godot/scripts/entities/runes/reflect_rune.gd`
- `godot/scripts/entities/rune_base.gd` (if needed for cleanup)

#### Changes:

**explosive_rune.gd**:
- Remove `uses_remaining = 1` from `_on_rune_ready()`
- Set `uses_remaining = 0` (infinite uses) or remove the assignment entirely
- Remove or modify `_on_depleted()` to not fade out/remove the rune
- Keep explosion effect and damage logic unchanged
- Rune should remain active and reusable

**reflect_rune.gd**:
- Ensure `uses_remaining = 0` (infinite uses) - check if already set
- Remove or modify `_on_depleted()` to not fade out the rune
- Keep cooldown system (cooldown prevents rapid re-activation, not depletion)
- Rune should remain active and reusable

**rune_base.gd**:
- Verify that `uses_remaining = 0` means infinite uses (current behavior)
- Ensure `_on_depleted()` is only called when `uses_remaining` reaches 0
- No changes needed if current logic supports infinite uses correctly

#### Testing:
- Place explosive rune, activate multiple times - should work each time
- Place reflect rune, activate multiple times - should work each time (respecting cooldown)
- Verify runes don't disappear after use

---

### 1.2: Implement Power Rune

#### New Files to Create:
- `godot/scripts/entities/runes/power_rune.gd`
- `godot/scenes/entities/runes/power_rune.tscn`
- `godot/resources/buildable_items/power_rune_definition.tres`

#### Files to Modify:
- `godot/scripts/autoload/game_config.gd` (add power rune parameters)
- `godot/scripts/entities/fireball.gd` (add power stack system)
- `godot/scripts/game/placement_manager.gd` (add power rune to placement logic)
- `godot/scripts/ui/build_menu_item.gd` (add power rune to menu)
- `godot/scripts/ui/details_menu_item.gd` (add power rune to details)
- `godot/scripts/resources/level_data.gd` (add POWER to RuneType enum if needed)

#### Implementation Details:

**power_rune.gd** (NEW):
```gdscript
extends RuneBase
class_name PowerRune
## Grants stacking damage bonus to fireball when activated

func _on_rune_ready() -> void:
	rune_type = "power"
	uses_remaining = 0  # Infinite uses

func _on_activate(fireball: Node2D) -> void:
	# Apply power stack to fireball
	if fireball.has_method("add_power_stack"):
		fireball.add_power_stack(GameConfig.power_rune_damage_increase)
	
	_play_activation_effect()

func _play_activation_effect() -> void:
	# Visual feedback (flash effect)
	var visual := get_node_or_null("RuneVisual") as ColorRect
	if visual:
		var original_color := visual.color
		visual.color = Color.WHITE
		var tween := create_tween()
		tween.tween_property(visual, "color", original_color, 0.2)
```

**power_rune.tscn** (NEW):
- Create scene similar to other rune scenes
- Use explosive tile sprite asset (as specified)
- Include Sprite2D node with explosive sprite
- Include RuneVisual ColorRect (can be hidden if using sprite)

**power_rune_definition.tres** (NEW):
- Create resource file similar to other rune definitions
- Set `item_type = "power"`
- Set `cost` (TBD - balance based on power/utility)
- Set `unlocked_by_default = true` (or false, TBD)
- Set other properties as needed

**game_config.gd**:
- Add `power_rune_damage_increase: int = 5` (or appropriate value, TBD)
- Add power rune definition to `_load_buildable_item_definitions()` array

**fireball.gd**:
- Add `var power_stacks: int = 0` variable
- Add `var power_stack_amount: int = 0` (total power bonus)
- Add `func add_power_stack(amount: int) -> void` method
- Add `func lose_power_stack() -> void` method (loses 1 stack)
- Modify `_hit_enemy()` to apply power bonus to damage
- Modify `_hit_enemy()` to call `lose_power_stack()` after dealing damage
- Update damage calculation: `final_damage = GameConfig.fireball_damage + power_stack_amount`

#### Testing:
- Place power rune, activate fireball over it - power stacks should increase
- Hit enemy - damage should be increased by power stacks
- Hit enemy - power stacks should decrease by 1
- Multiple power runes - stacks should accumulate

---

### 1.3: Update Acceleration Rune to Use Stacking System

#### Files to Modify:
- `godot/scripts/entities/runes/acceleration_rune.gd`
- `godot/scripts/entities/fireball.gd`
- `godot/scripts/autoload/game_config.gd`

#### Changes:

**acceleration_rune.gd**:
- Change from temporary speed boost to permanent stacking system
- Replace `apply_speed_boost()` call with `add_speed_stack()` call
- Remove temporary boost logic (SPEED_BOOST, BOOST_DURATION constants)

**fireball.gd**:
- Add `var speed_stacks: int = 0` variable
- Add `func add_speed_stack(amount: float) -> void` method
- Add `func lose_speed_stack() -> void` method (loses 1 stack)
- Modify `accelerate()` or create new method to handle stacking
- Update speed calculation to use stacks instead of temporary boosts
- Remove `speed_boost`, `boost_timer` variables and related logic
- Modify `_hit_enemy()` to call `lose_speed_stack()` after dealing damage
- Update `_update_current_speed()` to use `base_speed + (speed_stacks * GameConfig.acceleration_speed_increase)`

**game_config.gd**:
- Update `fireball_max_speed: float = 5000.0` (10x increase from 500.0)
- Keep `acceleration_speed_increase: float = 50.0` (or adjust based on playtesting)

#### Testing:
- Place acceleration rune, activate fireball over it - speed stacks should increase
- Place multiple acceleration runes - stacks should accumulate
- Hit enemy - speed stacks should decrease by 1
- Verify speed cap is respected (5000.0)

---

### 1.4: Add Fireball Status Modifiers (Speed/Power Stacks) with SFX/VFX

#### Files to Modify:
- `godot/scripts/entities/fireball.gd`
- `godot/scripts/autoload/floating_number_manager.gd` (or create new system)

#### Changes:

**fireball.gd**:
- Add methods to display status modifier text when stacks change
- Call `FloatingNumberManager.show_number()` or similar when stacks increase/decrease
- Display format: "+Speed x5" or "+Power x3" or similar
- Position: Near fireball position, different from damage numbers

**VFX Implementation (MVP)**:
- Reuse `FloatingNumberManager.show_number()` system
- Create new method: `show_status_modifier(text: String, position: Vector2, color: Color)`
- Or extend existing method to support text labels
- Display stack count when stacks change (increase or decrease)
- Color coding: Speed = blue/cyan, Power = red/orange

**SFX Implementation**:
- Add sound effects when stacks are gained (per existing sound effects plan)
- Power rune activation: Use "rune-generic" or new sound
- Acceleration rune activation: Use "rune-accelerate" sound
- Stack loss: Optional sound effect (TBD)

#### Testing:
- Activate power/acceleration runes - should see stack count text appear
- Hit enemies - should see stack count decrease text
- Verify text doesn't overlap with damage numbers
- Verify colors are distinct and readable

---

## Phase 2: New Wall/Tile Types

### 2.1: Implement Explosive Wall

#### New Files to Create:
- `godot/scripts/entities/walls/explosive_wall.gd`
- `godot/scenes/entities/walls/explosive_wall.tscn`
- `godot/resources/buildable_items/explosive_wall_definition.tres`

#### Files to Modify:
- `godot/scripts/game/placement_manager.gd` (add explosive wall to placement logic)
- `godot/scripts/tiles/tile_manager.gd` (handle explosive wall as wall type)
- `godot/scripts/entities/fireball.gd` (detect adjacent walls for activation)
- `godot/scripts/ui/build_menu_item.gd` (add to build menu)
- `godot/scripts/ui/details_menu_item.gd` (add to details menu)
- `godot/scripts/autoload/game_config.gd` (add explosive wall parameters)

#### Implementation Details:

**explosive_wall.gd** (NEW):
```gdscript
extends Node2D
class_name ExplosiveWall
## Wall that explodes when fireball passes adjacent, dealing damage in 8 surrounding tiles

var grid_position: Vector2i = Vector2i.ZERO
var cooldown_timer: float = 0.0
var is_on_cooldown: bool = false

func _ready() -> void:
	add_to_group("explosive_walls")

func _process(delta: float) -> void:
	if is_on_cooldown:
		cooldown_timer -= delta
		if cooldown_timer <= 0.0:
			is_on_cooldown = false
			cooldown_timer = 0.0

func set_grid_position(pos: Vector2i) -> void:
	grid_position = pos
	position = Vector2(
		pos.x * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2,
		pos.y * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2
	)

func check_fireball_adjacent(fireball_pos: Vector2i) -> bool:
	# Check if fireball is directly adjacent (cardinal directions only)
	var distance := fireball_pos - grid_position
	return abs(distance.x) + abs(distance.y) == 1

func explode() -> void:
	if is_on_cooldown:
		return
	
	# Deal damage to enemies in 8 surrounding tiles (3x3 area)
	var enemies := get_tree().get_nodes_in_group("enemies")
	var enemies_hit: int = 0
	
	for enemy in enemies:
		if enemy.has_method("get_grid_position"):
			var enemy_pos := enemy.get_grid_position()
			var distance := enemy_pos - grid_position
			# Check if enemy is in 3x3 area (including center)
			if abs(distance.x) <= 1 and abs(distance.y) <= 1:
				if enemy.has_method("take_damage"):
					enemy.take_damage(GameConfig.explosive_wall_damage)
					enemies_hit += 1
	
	# Play explosion effect
	_play_explosion_effect()
	
	# Start cooldown (post-MVP: will have cooldown, MVP: no cooldown or very short)
	# is_on_cooldown = true
	# cooldown_timer = GameConfig.explosive_wall_cooldown
	
	if enemies_hit > 0:
		print("ExplosiveWall: Hit %d enemies for %d damage each" % [enemies_hit, GameConfig.explosive_wall_damage])

func _play_explosion_effect() -> void:
	# Visual effect similar to explosive rune
	var explosion := ColorRect.new()
	explosion.size = Vector2(8, 8)
	explosion.position = Vector2(-4, -4)
	explosion.color = Color(1.0, 0.6, 0.2, 0.8)
	add_child(explosion)
	
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(explosion, "size", Vector2(96, 96), 0.3)  # 3x3 tiles
	tween.tween_property(explosion, "position", Vector2(-48, -48), 0.3)
	tween.tween_property(explosion, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(explosion.queue_free)
```

**explosive_wall.tscn** (NEW):
- Create scene with new explosive wall sprite asset
- Include visual representation
- Set up as wall-type structure

**explosive_wall_definition.tres** (NEW):
- Create resource file
- Set `item_type = "explosive_wall"`
- Set `blocks_path = true` (walls block movement)
- Set `cost` (TBD - balance)
- Set other properties

**fireball.gd**:
- Add method to check for adjacent explosive walls
- Call `explode()` on explosive walls when fireball passes adjacent
- Check in `_physics_process()` or `_check_tile_activation()`

**game_config.gd**:
- Add `explosive_wall_damage: int = 15` (or appropriate value)
- Add `explosive_wall_cooldown: float = 0.0` (MVP: no cooldown, post-MVP: add cooldown)
- Add explosive wall definition to `_load_buildable_item_definitions()`

#### Testing:
- Place explosive wall
- Fireball passes adjacent - should explode and damage enemies in 3x3 area
- Verify wall blocks enemy movement
- Verify can't place runes on explosive wall tile

---

### 2.2: Implement Mud Tile

#### New Files to Create:
- `godot/scripts/entities/tiles/mud_tile.gd`
- `godot/scenes/entities/tiles/mud_tile.tscn`
- `godot/resources/buildable_items/mud_tile_definition.tres`

#### Files to Modify:
- `godot/scripts/entities/enemies/enemy_base.gd` (apply slow effect when on mud tile)
- `godot/scripts/game/placement_manager.gd` (add mud tile to placement logic)
- `godot/scripts/tiles/tile_manager.gd` (track mud tile positions)
- `godot/scripts/ui/build_menu_item.gd` (add to build menu)
- `godot/scripts/ui/details_menu_item.gd` (add to details menu)
- `godot/scripts/autoload/game_config.gd` (add mud tile parameters)

#### Implementation Details:

**mud_tile.gd** (NEW):
```gdscript
extends Node2D
class_name MudTile
## Floor tile that slows enemies by 50% when they walk over it

var grid_position: Vector2i = Vector2i.ZERO

func _ready() -> void:
	add_to_group("mud_tiles")

func set_grid_position(pos: Vector2i) -> void:
	grid_position = pos
	position = Vector2(
		pos.x * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2,
		pos.y * GameConfig.TILE_SIZE + GameConfig.TILE_SIZE / 2
	)
```

**mud_tile.tscn** (NEW):
- Create scene with mud tile sprite asset
- Include visual representation
- Set up as floor tile (doesn't block movement)

**mud_tile_definition.tres** (NEW):
- Create resource file
- Set `item_type = "mud_tile"`
- Set `blocks_path = false` (enemies can pass through)
- Set `cost` (TBD - balance)
- Set other properties

**enemy_base.gd**:
- Add method to check if enemy is on mud tile
- Modify speed calculation: `effective_speed = base_speed * (0.5 if on mud tile else 1.0)`
- Check mud tile in `_physics_process()` or movement logic
- Query `TileManager` or `get_tree().get_nodes_in_group("mud_tiles")` to check current position

**tile_manager.gd**:
- Add method to check if position has mud tile
- Or track mud tile positions in a dictionary/set
- Provide `has_mud_tile_at(grid_pos: Vector2i) -> bool` method

**game_config.gd**:
- Add `mud_tile_slow_percentage: float = 0.5` (50% slow)
- Add mud tile definition to `_load_buildable_item_definitions()`

#### Testing:
- Place mud tile
- Enemy walks over mud tile - should move at 50% speed
- Enemy leaves mud tile - should return to normal speed
- Verify mud tile doesn't block enemy movement
- Verify can place runes on mud tile (if desired, or clarify placement rules)

---

## Phase 3: Sound Effects Integration

### 3.1: Extend AudioManager with Sound Effect System

#### Files to Modify:
- `godot/scripts/autoload/audio_manager.gd`

#### Changes:

**audio_manager.gd**:
- Add `var sound_effects: Dictionary` mapping sound names to file paths
- Add `var sound_volumes: Dictionary` for volume multipliers (default 1.0)
- Modify `play_sfx()` to accept optional volume parameter
- Add `play_sound_effect(effect_name: String)` wrapper method
- Add `set_sound_volume(effect_name: String, volume_multiplier: float)` method
- Add `get_sound_volume(effect_name: String) -> float` method
- Initialize sound effects dictionary in `_ready()`
- Apply volume multipliers when playing sounds

**Sound Effect Dictionary**:
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
```

#### Testing:
- Call `AudioManager.play_sound_effect("click")` - should play sound
- Test volume adjustment - should affect sound level
- Verify all sound files exist and load correctly

---

### 3.2: Create Sound Effect Config Resource (Optional but Recommended)

#### New Files to Create:
- `godot/scripts/resources/sound_effect_config.gd`
- `godot/resources/sound_effect_config.tres`

#### Implementation Details:

**sound_effect_config.gd** (NEW):
```gdscript
extends Resource
class_name SoundEffectConfig

@export_range(0.0, 2.0, 0.1) var volume_rune_accelerate: float = 1.0
@export_range(0.0, 2.0, 0.1) var volume_rune_generic: float = 1.0
@export_range(0.0, 2.0, 0.1) var volume_burn: float = 1.0
@export_range(0.0, 2.0, 0.1) var volume_fireball_spawn: float = 1.0
@export_range(0.0, 2.0, 0.1) var volume_enemy_death: float = 1.0
@export_range(0.0, 2.0, 0.1) var volume_furnace_death: float = 1.0
@export_range(0.0, 2.0, 0.1) var volume_level_failed: float = 1.0
@export_range(0.0, 2.0, 0.1) var volume_click: float = 1.0
@export_range(0.0, 2.0, 0.1) var volume_structure_sell: float = 1.0
@export_range(0.0, 2.0, 0.1) var volume_structure_buy: float = 1.0
@export_range(0.0, 2.0, 0.1) var volume_pickup_spark: float = 1.0
@export_range(0.0, 2.0, 0.1) var volume_invalid_action: float = 1.0
@export_range(0.0, 2.0, 0.1) var volume_fireball_travel: float = 1.0
```

**sound_effect_config.tres** (NEW):
- Create resource file in Godot editor
- Set all volume values to 1.0 (default)
- Designers can adjust in inspector

**audio_manager.gd**:
- Add `@export var sound_config: SoundEffectConfig` property
- Load config in `_ready()` or from project settings
- Use config values when playing sounds

#### Testing:
- Load config resource - should have all volume settings
- Adjust volumes in inspector - should affect sound playback
- Verify default values are 1.0

---

### 3.3: Integrate Sound Effects at All Points

#### Integration Points:

**Rune Activation Sounds**:
- `acceleration_rune.gd`: Add `AudioManager.play_sound_effect("rune-accelerate")` in `_on_activate()`
- `power_rune.gd`: Add `AudioManager.play_sound_effect("rune-generic")` in `_on_activate()`
- `redirect_rune.gd`: Add `AudioManager.play_sound_effect("rune-generic")` in `_on_activate()`
- `reflect_rune.gd`: Add `AudioManager.play_sound_effect("rune-generic")` in `_on_activate()`
- `explosive_rune.gd`: Add `AudioManager.play_sound_effect("rune-generic")` in `_on_activate()`
- `portal_rune.gd`: Add `AudioManager.play_sound_effect("rune-generic")` in `_on_activate()`

**Enemy Sounds**:
- `enemy_base.gd` `take_damage()`: Add `AudioManager.play_sound_effect("burn")` after damage applied
- `enemy_base.gd` `_die()`: Add `AudioManager.play_sound_effect("enemy-death")` at start

**Fireball Sounds**:
- `game_scene.gd` `_launch_fireball()`: Add `AudioManager.play_sound_effect("fireball-spawn")` after instantiation
- `fireball.gd` `launch()`: Start looping `AudioManager.play_sound_effect("fireball-travel")` (needs dedicated player)
- `fireball.gd` `_destroy()`: Stop looping fireball-travel sound

**Structure Sounds**:
- `game_scene.gd` `_on_placement_succeeded()`: Add `AudioManager.play_sound_effect("structure-buy")`
- `game_scene.gd` `_on_item_sold()`: Add `AudioManager.play_sound_effect("structure-sell")`
- `game_scene.gd` `_on_placement_failed()`: Add `AudioManager.play_sound_effect("invalid-action")`

**UI Click Sounds**:
- All button `pressed` signal handlers: Add `AudioManager.play_sound_effect("click")` at start
- Files: `build_menu_item.gd`, `main_menu.gd`, `pause_menu.gd`, `game_over.gd`, `game_submenu.gd`, `tile_tooltip.gd`, etc.

**Game State Sounds**:
- `game_scene.gd` `_on_furnace_destroyed()`: Add `AudioManager.play_sound_effect("furnace-death")`
- `game_scene.gd` `lose_level()`: Add `AudioManager.play_sound_effect("level-failed")`
- Find resource collection point: Add `AudioManager.play_sound_effect("pickup-spark")` when resources collected

**Fireball Travel Sound (Looping)**:
- Add dedicated `AudioStreamPlayer` in `AudioManager` for looping sounds
- Add `start_fireball_travel()` and `stop_fireball_travel()` methods
- Fireball calls these in `launch()` and `_destroy()`

#### Testing:
- Test each sound effect plays at correct time
- Test volume adjustments work
- Test fireball travel sound loops correctly and stops when destroyed

---

## Phase 4: Debug Mode Config

### 4.1: Implement Config File System

#### Files to Modify:
- `godot/scripts/autoload/game_config.gd`

#### Changes:

**game_config.gd**:
- Change `debug_mode` from hardcoded `true` to read from config file
- Create `_load_debug_config()` method
- Default to `false` if config file doesn't exist
- Config file can be `.json` or Godot config format
- Consider using Godot's project settings or separate config file

**Implementation Options**:
- Option A: Use Godot project settings (visible in editor)
- Option B: Use separate `config.json` file (can be gitignored)
- Option C: Use environment variable

**Recommendation**: Option B - `config.json` file that can be gitignored for local testing.

#### Testing:
- Create config file with `debug_mode: false` - should disable debug mode
- Remove config file - should default to false
- Verify debug mode works when enabled in config

---

## Phase 5: Game Victory Card

### 5.1: Implement Victory Screen

#### Files to Modify:
- `godot/scripts/ui/game_over.gd`
- `godot/scenes/ui/game_over.tscn` (if needed)

#### Changes:

**game_over.gd**:
- Check if all levels are cleared (need to track level completion)
- Show victory message/card when all levels completed
- Display different content for victory vs defeat
- Add victory-specific UI elements if needed

**Level Completion Tracking**:
- Need to track which levels have been completed
- Store in `GameManager` or save system
- Check on game over screen

#### Testing:
- Complete all levels - should show victory card
- Lose level - should show defeat screen
- Verify victory card displays correctly

---

## Phase 6: Asset Integration (As Needed)

### 6.1: Asset Requirements

#### New Assets Needed:
- Explosive wall sprite (new asset)
- Mud tile sprite (new asset)
- Power rune uses explosive tile sprite (reuse existing)

#### Asset Integration:
- Integrate assets as systems are implemented
- Update sprite references in scene files
- Test visual appearance

---

## Implementation Checklist

### Phase 1: Core Rune System
- [ ] Make explosive rune multi-use
- [ ] Make reflect rune multi-use
- [ ] Create Power Rune script
- [ ] Create Power Rune scene
- [ ] Create Power Rune definition resource
- [ ] Add Power Rune to GameConfig
- [ ] Add Power Rune to placement manager
- [ ] Add Power Rune to UI menus
- [ ] Update fireball with power stack system
- [ ] Update acceleration rune to use stacking
- [ ] Update fireball with speed stack system
- [ ] Implement stack loss on enemy hit (1 per hit)
- [ ] Update acceleration cap (500 → 5000)
- [ ] Add status modifier VFX (text display)
- [ ] Add status modifier SFX

### Phase 2: New Wall/Tile Types
- [ ] Create Explosive Wall script
- [ ] Create Explosive Wall scene
- [ ] Create Explosive Wall definition resource
- [ ] Add Explosive Wall to GameConfig
- [ ] Add Explosive Wall to placement manager
- [ ] Add Explosive Wall to UI menus
- [ ] Implement fireball adjacent detection
- [ ] Implement explosion damage (3x3 area)
- [ ] Create Mud Tile script
- [ ] Create Mud Tile scene
- [ ] Create Mud Tile definition resource
- [ ] Add Mud Tile to GameConfig
- [ ] Add Mud Tile to placement manager
- [ ] Add Mud Tile to UI menus
- [ ] Implement enemy slow effect (50%)
- [ ] Integrate mud tile detection in enemy movement

### Phase 3: Sound Effects
- [ ] Extend AudioManager with sound effect system
- [ ] Create SoundEffectConfig resource (optional)
- [ ] Integrate rune activation sounds
- [ ] Integrate enemy damage/death sounds
- [ ] Integrate fireball spawn sound
- [ ] Integrate fireball travel sound (looping)
- [ ] Integrate structure buy/sell sounds
- [ ] Integrate invalid action sound
- [ ] Integrate UI click sounds
- [ ] Integrate game state sounds
- [ ] Integrate pickup spark sound

### Phase 4: Debug Mode
- [ ] Implement config file system
- [ ] Update GameConfig to read from config
- [ ] Test debug mode enable/disable

### Phase 5: Game Victory Card
- [ ] Implement level completion tracking
- [ ] Update game over screen for victory
- [ ] Test victory card display

### Phase 6: Assets
- [ ] Integrate explosive wall sprite
- [ ] Integrate mud tile sprite
- [ ] Verify all assets load correctly

---

## Testing Strategy

### Unit Testing:
- Test each rune type activates correctly
- Test stack systems (speed and power)
- Test stack loss on enemy hit
- Test new wall/tile types function correctly

### Integration Testing:
- Test rune interactions with fireball
- Test wall/tile interactions with enemies
- Test sound effects play at correct times
- Test status modifier display

### Playtesting:
- Test buff zone strategy with Power Rune
- Test kill zone strategy still works
- Test maze strategy with Explosive Wall and Mud Tile
- Test balance and feel of new systems

---

## Notes

- All runes are now multi-use (major design change)
- Power Rune and Acceleration Rune use stacking systems
- Stacks are lost on enemy hit (1 per hit)
- Acceleration cap increased to 5000.0
- New content: Explosive Wall, Mud Tile
- Sound effects integrated per existing plan
- Debug mode uses config file
- Game victory card included in MVP
