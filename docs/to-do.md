# Furnace - Asset Tracking & Project Management

**Version**: 1.2  
**Last Updated**: [Current Date]  
**Purpose**: Track all assets needed for game development including VFX, SFX, music, 2D assets, levels, and enemy designs

**Notes**:
- Buttons and text will be generated in-engine using a single nine-slice texture
- Enemies have walk and death animations that can be flipped left/right in-engine
- Fireball uses a single sprite rotated NSEW (not animated rotation)
- Runes use a single animation rotated NSEW (not separate animations per direction)

---

## VFX (Visual Effects)

| Status | Name | Category | Type | Duration | Style | Priority | Notes |
|--------|------|----------|------|----------|-------|----------|-------|
| ☐ | Rune Activation | Rune Activation Effects | Generic in-engine effect | ~0.2s | Visual feedback for rune activation | High | Generic effect for all rune types |
| ☐ | Path Preview | UI Effects | Line/Arrow overlay | Continuous while preview active | Dotted line with arrows showing enemy path | High | |
| ☐ | Furnace Destruction | Furnace Effects | Animation / Particle system | ~1.0s | Explosion/destruction | High | |
| ☐ | Fireball Trail | Fireball Effects | Particle System | Continuous while fireball active | Fire/spark trail | Medium | |
| ☐ | Enemy Hit | Enemy Effects | Animation / Color flash | ~0.1s | Red flash/damage indicator | Medium | Generic in-engine effect |
| ☐ | Invalid Placement Indicator | UI Effects | Animation / Color overlay | Continuous while hovering invalid tile | Red overlay/X mark | Medium | |
| ☐ | Valid Placement Indicator | UI Effects | Animation / Color overlay | Continuous while hovering valid tile | Green overlay/highlight | Medium | |
| ☐ | Fireball Launch | Furnace Effects | Animation / Particle burst | ~0.2s | Launch burst from furnace | Medium | |
| ☐ | Enemy Spawn | Enemy Effects | Animation | ~0.3s | Materialization/appearance effect | Low | Generic in-engine effect |
| ☐ | Button Hover | UI Effects | Animation (color/shader effect) | Instant | Highlight/glow | Low | Generated in-engine |
| ☐ | Button Click | UI Effects | Animation (scale/shader effect) | ~0.1s | Press animation | Low | Generated in-engine |

**Note**: Each enemy type has its own death and walk animations (see 2D Assets section).

---

## SFX (Sound Effects)

| Status | Name | Category | Type | Duration | Style | Priority | Notes |
|--------|------|----------|------|----------|-------|----------|-------|
| ☐ | Rune Activation | Rune Activation Sounds | One-shot SFX | ~0.2s | Generic activation sound | High | Generic sound for all rune types |
| ☐ | Enemy Death | Enemy Sounds | One-shot SFX | ~0.4s | Defeat/disintegration sound | High | Generic sound for all enemy types |
| ☐ | Enemy Reaches Furnace | Enemy Sounds | One-shot SFX | ~0.5s | Alarm/failure sound | High | |
| ☐ | Level Complete | Level Sounds | One-shot SFX | ~1.0s | Victory/fanfare | High | |
| ☐ | Level Failed | Level Sounds | One-shot SFX | ~1.0s | Failure/sad sound | High | |
| ☐ | Fireball Travel | Fireball Sounds | Looping SFX | Continuous | Whoosh/fire sound | Medium | |
| ☐ | Enemy Hit | Enemy Sounds | One-shot SFX | ~0.1s | Impact/hit sound | Medium | |
| ☐ | Structure Placement | UI Sounds | One-shot SFX | ~0.2s | Place/drop sound | Medium | |
| ☐ | Structure Sell | UI Sounds | One-shot SFX | ~0.2s | Coin/refund sound | Medium | |
| ☐ | Level Start | Level Sounds | One-shot SFX | ~0.5s | Start/fanfare | Medium | |
| ☐ | Enemy Spawn | Enemy Sounds | One-shot SFX | ~0.3s | Materialization/appearance sound | Low | |
| ☐ | Button Hover | UI Sounds | One-shot SFX | ~0.1s | Subtle click/hover | Low | |
| ☐ | Button Click | UI Sounds | One-shot SFX | ~0.1s | Click/confirm sound | Low | |
| ☐ | Invalid Action | UI Sounds | One-shot SFX | ~0.2s | Error/buzz sound | Low | |

---

## Songs (Background Music)

| Status | Name | Category | Type | Duration | Style | Priority | Notes |
|--------|------|----------|------|----------|-------|----------|-------|
| ☐ | Active Phase Theme | Gameplay Music | Looping music track | 2-3 minutes (loops) | Tense/action-oriented, builds excitement | High | |
| ☐ | Title Screen Theme | Main Menu Music | Looping music track | 2-3 minutes (loops) | Atmospheric/ambient, matches game theme | Medium | |
| ☐ | Build Phase Theme | Gameplay Music | Looping music track | 2-3 minutes (loops) | Calm/strategic, allows focus | Medium | |
| ☐ | Tutorial Level Music | Level-Specific Music | Looping music track | 2-3 minutes (loops) | Gentle/learning-friendly | Low | Can reuse build phase theme |
| ☐ | Challenge Level Music | Level-Specific Music | Looping music track | 2-3 minutes (loops) | More intense than tutorial | Low | Can reuse active phase theme |

---

## 2D Assets

| Status | Name | Category | Size | Type | Animated | Frames | Priority | Notes |
|--------|------|----------|------|------|----------|--------|----------|-------|
| ☐ | Fireball Sprite | Game Entities | 32x32px (1:1) | Sprite | No | N/A | High | Single sprite, rotated NSEW in-engine. Particle effects added separately |
| ☐ | Furnace Sprite | Game Entities | 32x32px (1:1) | Sprite | Yes | 4-6 frames | High | Idle animation - flames |
| ☐ | Wall Sprite | Game Entities | 32x32px (1:1) | Sprite | No | N/A | High | |
| ☐ | Redirect Rune Sprite | Runes | 32x32px (1:1) | Sprite | Yes | 4-6 frames | High | Single animation, rotated NSEW in-engine. Direction indicators shown via rotation |
| ☐ | Advanced Redirect Rune Sprite | Runes | 32x32px (1:1) | Sprite | Yes | 4-6 frames | High | Single animation, rotated NSEW in-engine, distinct from regular redirect |
| ☐ | Portal Rune Sprite | Runes | 32x32px (1:1) | Sprite | Yes | 6-8 frames | High | Single portal swirl animation, rotated NSEW in-engine. Entry/exit variants use same sprite |
| ☐ | Explosive Rune Sprite | Runes | 32x32px (1:1) | Sprite | Yes | 4-6 frames | High | Single animation, rotated NSEW in-engine. Subtle pulse animation |
| ☐ | Reflect Rune Sprite | Runes | 32x32px (1:1) | Sprite | Yes | 4-6 frames | High | Single animation, rotated NSEW in-engine. Mirror-like animation |
| ☐ | Acceleration Rune Sprite | Runes | 32x32px (1:1) | Sprite | Yes | 4-6 frames | High | Single animation, rotated NSEW in-engine. Subtle speed lines animation |
| ☐ | Basic Enemy Walk Animation | Enemies | 32x32px per frame (1:1) | Sprite sheet | Yes | 4-6 frames | High | Walk cycle. Flipped left/right in-engine |
| ☐ | Basic Enemy Death Animation | Enemies | 32x32px per frame (1:1) | Sprite sheet | Yes | 4-6 frames | High | Death animation. Flipped left/right in-engine if needed |
| ☐ | Fast Enemy Walk Animation | Enemies | 32x32px per frame (1:1) | Sprite sheet | Yes | 4-6 frames | High | Walk cycle, faster animation. Flipped left/right in-engine |
| ☐ | Fast Enemy Death Animation | Enemies | 32x32px per frame (1:1) | Sprite sheet | Yes | 4-6 frames | High | Death animation. Flipped left/right in-engine if needed |
| ☐ | Open Terrain Tile | Terrain/Tiles | 32x32px (1:1) | Tile sprite | No | N/A | High | Standard buildable terrain |
| ☐ | Rock/Mountain Tile | Terrain/Tiles | 32x32px (1:1) | Tile sprite | No | N/A | High | Unbuildable terrain |
| ☐ | UI Nine-Slice Texture | UI Elements | Variable | Nine-slice texture | No | N/A | High | Single texture for all buttons, panels, backgrounds, text backgrounds |
| ☐ | Title Logo | UI Elements | 320x80px (4:1) | UI sprite | No | N/A | High | Game title/logo (or subtle glow) |
| ☐ | Resource Icon | UI Elements | 24x24px (1:1) | UI sprite | No | N/A | High | Resource currency icon |
| ☐ | Rune Icon (Build Panel) | UI Elements | 48x48px (1:1) | UI sprite | No | N/A | High | One icon per rune type (6 total) |
| ☐ | Wall Icon (Build Panel) | UI Elements | 48x48px (1:1) | UI sprite | No | N/A | High | Icon for placing walls |
| ☐ | Game Logo | Itch.io Page Assets | 800x200px (4:1) | Logo/Graphic | No | N/A | High | Main game logo for page header |
| ☐ | Hero Image | Itch.io Page Assets | 1920x1080px (16:9) | Screenshot/Promo art | No | N/A | High | Main promotional image (or animated GIF) |
| ☐ | Screenshot 1 | Itch.io Page Assets | 1280x720px (16:9) | Screenshot | No | N/A | High | Gameplay screenshot |
| ☐ | Screenshot 2 | Itch.io Page Assets | 1280x720px (16:9) | Screenshot | No | N/A | High | Build phase screenshot |
| ☐ | Screenshot 3 | Itch.io Page Assets | 1280x720px (16:9) | Screenshot | No | N/A | High | Active phase screenshot |
| ☐ | Page Thumbnail | Itch.io Page Assets | 630x500px (1.26:1) | Thumbnail | No | N/A | High | Itch.io page thumbnail |
| ☐ | Download Thumbnail | Itch.io Page Assets | 630x500px (1.26:1) | Thumbnail | No | N/A | High | Download button thumbnail |
| ☐ | Game Icon | Itch.io Page Assets | 512x512px (1:1) | Icon | No | N/A | High | Game icon for downloads |
| ☐ | Spawn Point Indicator | Terrain/Tiles | 32x32px (1:1) | Sprite overlay | Yes | 4 frames | Medium | Visual marker for spawn points. Subtle pulse/glow |
| ☐ | Grid Overlay | Terrain/Tiles | N/A (overlay) | UI overlay | No | N/A | Medium | Grid lines for placement visualization |
| ☐ | Menu Background | UI Elements | 640x360px (16:9) | Background sprite | No | N/A | Medium | Main menu background |
| ☐ | Sell Icon | UI Elements | 24x24px (1:1) | UI sprite | No | N/A | Medium | Icon for sell button |
| ☐ | Cancel Icon | UI Elements | 24x24px (1:1) | UI sprite | No | N/A | Medium | Icon for cancel button |
| ☐ | Victory Icon | UI Elements | 64x64px (1:1) | UI sprite | No | N/A | Medium | Victory indicator icon |
| ☐ | Defeat Icon | UI Elements | 64x64px (1:1) | UI sprite | No | N/A | Medium | Defeat indicator icon |
| ☐ | Screenshot 4 | Itch.io Page Assets | 1280x720px (16:9) | Screenshot | No | N/A | Medium | Rune close-up screenshot |
| ☐ | Favicon | Itch.io Page Assets | 32x32px (1:1) | Icon | No | N/A | Medium | Browser favicon |
| ☐ | Tank Enemy Walk Animation | Enemies | 32x32px per frame (1:1) | Sprite sheet | Yes | 4-6 frames | Medium | Walk cycle, slower animation. Optional for MVP. Flipped left/right in-engine |
| ☐ | Tank Enemy Death Animation | Enemies | 32x32px per frame (1:1) | Sprite sheet | Yes | 4-6 frames | Medium | Death animation. Optional for MVP. Flipped left/right in-engine if needed |
| ☐ | Rune Base Sprite | Runes | 32x32px (1:1) | Sprite | No | N/A | Low | Base rune appearance (if needed) |
| ☐ | Minimal UI Elements | UI Elements | Variable | UI sprite | No | N/A | Low | Any decorative elements (if needed). Most UI generated via nine-slice |
| ☐ | Game Over Background | UI Elements | 400x200px (2:1) | Background sprite | No | N/A | Low | Game over screen background (if decorative). Can use nine-slice if simple panel |
| ☐ | Pause Icon | UI Elements | 32x32px (1:1) | UI sprite | No | N/A | Low | Pause indicator icon |
| ☐ | Twitter Card Image | Itch.io Page Assets | 1200x630px (1.9:1) | Social media asset | No | N/A | Low | Twitter preview image |
| ☐ | Discord Embed Image | Itch.io Page Assets | 1200x630px (1.9:1) | Social media asset | No | N/A | Low | Discord embed preview |

---

## Level Designs

| Status | Level ID | Level Name | Difficulty | Enemy Types | Enemy Count | Initial Resources | Runes Available | Initial Runes | Initial Walls | Spawn Points | Teaching Focus | Priority |
|--------|----------|------------|------------|-------------|-------------|------------------|----------------|---------------|---------------|--------------|----------------|----------|
| ☐ | 1 | First Steps | Very Easy (nearly guaranteed win) | Basic Enemy only | Minimal (3-5 enemies) | 50 (generous) | Redirect, Reflect, Acceleration | 2-3 Redirect Runes (pre-placed) | 0-2 walls | 1 spawn point | Fireball kills enemies, redirect runes, rune editing | High |
| ☐ | 2 | Speed Challenge | Moderate | Basic Enemy, Fast Enemy | Moderate (8-12 enemies) | 40 | Redirect, Reflect, Acceleration, Explosive | 1-2 runes (strategic placement) | 2-4 walls | 1-2 spawn points | Fast enemies, explosive runes | High |
| ☐ | 3 | Final Test | High | Basic Enemy, Fast Enemy, Tank Enemy (if implemented) | High (15-20 enemies) | 35 | All runes | 2-3 runes (complex setup) | 3-5 walls | 2-3 spawn points | All mechanics, strategic planning | High |

---

## Enemy Designs

| Status | Enemy Type | Health | Speed | Visual Style | Color Scheme | Size | Animation | Introduction Level | Role | Priority |
|--------|------------|--------|-------|--------------|--------------|------|-----------|-------------------|------|----------|
| ☐ | Basic Enemy | 50 HP | 50 pixels/second | Standard enemy appearance | Primary color (distinct from other types) | 32x32px | 4-6 frame walk cycle, 4-6 frame death animation. Flipped left/right in-engine | Level 1 | Baseline enemy, standard threat | High |
| ☐ | Fast Enemy | 30 HP | 80 pixels/second | Sleek/fast appearance | Distinct color (e.g., blue/yellow) | 32x32px | 4-6 frame walk cycle (faster animation), 4-6 frame death animation. Flipped left/right in-engine | Level 2 | Speed challenge, lower health | High |
| ☐ | Tank Enemy | 150 HP | 30 pixels/second | Heavy/armored appearance | Distinct color (e.g., red/dark) | 32x32px | 4-6 frame walk cycle (slower animation), 4-6 frame death animation. Flipped left/right in-engine | Level 3 (optional for MVP) | Durability challenge, slow but tough | Medium |

---

## Asset Status Summary

### By Category
- **VFX**: 0/20 complete (0%)
- **SFX**: 0/20 complete (0%)
- **Songs**: 0/4 complete (0%)
- **2D Assets (Game)**: 0/40+ complete (0%)
- **2D Assets (Itch.io)**: 0/10 complete (0%)
- **Level Designs**: 0/3 complete (0%)
- **Enemy Designs**: 0/3 complete (0%)

### By Priority
- **High Priority**: ~40 items
- **Medium Priority**: ~20 items
- **Low Priority**: ~15 items

---

## Notes

### Asset Creation Guidelines
- **Art Style**: Pixel art, matches 640x360 resolution
- **Color Palette**: Consistent color scheme across all assets
- **Animation**: Use sprite sheets for animations (4-8 frames typical)
- **File Format**: PNG for sprites, OGG for audio (or WAV for SFX)

### Animation & Rotation Notes
- **Fireball**: Single sprite rotated NSEW in-engine (not animated rotation)
- **Runes**: Single animation per rune type, rotated NSEW in-engine (not separate animations per direction)
- **Enemies**: Walk and death animations flipped left/right in-engine (no separate left/right sprites needed)
- **Direction Indicators**: Shown via sprite rotation, not separate directional sprites

### UI Generation
- **Nine-Slice Texture**: Single texture used for all buttons, panels, and text backgrounds
- **In-Engine Text**: Text rendered using engine's text rendering system
- **Button States**: Hover/pressed states generated via shaders/color modulation
- **No Individual Button Assets**: All buttons use the same nine-slice texture

### Asset Organization
- **Game Assets**: `godot/assets/sprites/` and `godot/assets/audio/`
- **Itch.io Assets**: Separate folder for promotional materials
- **Naming Convention**: `[type]_[name]_[variant].png` (e.g., `rune_redirect.png`, `enemy_basic_walk.png`)

### Dependencies
- Some assets depend on others (e.g., VFX may reference sprite assets for particles)
- Level designs depend on enemy designs being finalized
- UI elements depend on nine-slice texture being created first

---

**Last Updated**: [Current Date]  
**Next Review**: [Update as needed]
