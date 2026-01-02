# Furnace - Asset Tracking & Project Management

**Version**: 1.0  
**Last Updated**: [Current Date]  
**Purpose**: Track all assets needed for game development including VFX, SFX, music, 2D assets, levels, and enemy designs

---

## VFX (Visual Effects)

### Fireball Effects
- [ ] **Fireball Trail** - Particle effect following fireball
  - **Type**: Particle System
  - **Duration**: Continuous while fireball active
  - **Style**: Fire/spark trail
  - **Priority**: Medium

- [ ] **Fireball Despawn** - Effect when fireball hits wall/despawns
  - **Type**: Particle System / Animation
  - **Duration**: ~0.3s
  - **Style**: Explosion/spark burst
  - **Priority**: Medium

### Rune Activation Effects
- [ ] **Redirect Rune Activation** - Visual feedback when redirect rune activates
  - **Type**: Animation / Particle burst
  - **Duration**: ~0.2s
  - **Style**: Directional flash/arrow indicator
  - **Priority**: High

- [ ] **Advanced Redirect Rune Activation** - Visual feedback when advanced redirect activates
  - **Type**: Animation / Particle burst
  - **Duration**: ~0.2s
  - **Style**: Enhanced directional flash (distinct from regular redirect)
  - **Priority**: High

- [ ] **Portal Rune Activation** - Teleportation effect
  - **Type**: Animation / Particle system
  - **Duration**: ~0.4s
  - **Style**: Portal swirl/energy effect
  - **Priority**: High

- [ ] **Portal Rune Exit** - Fireball exit effect at destination portal
  - **Type**: Animation / Particle system
  - **Duration**: ~0.4s
  - **Style**: Portal emergence effect
  - **Priority**: High

- [ ] **Explosive Rune Explosion** - Area damage explosion effect
  - **Type**: Particle System / Animation
  - **Duration**: ~0.5s
  - **Style**: Fire/explosion burst with radius indicator
  - **Radius**: 1 tile (32px)
  - **Priority**: High

- [ ] **Reflect Rune Activation** - Reflection visual feedback
  - **Type**: Animation / Flash
  - **Duration**: ~0.2s
  - **Style**: Mirror/reflection flash
  - **Priority**: High

- [ ] **Acceleration Rune Activation** - Speed boost visual feedback
  - **Type**: Animation / Particle trail
  - **Duration**: ~0.3s
  - **Style**: Speed lines/energy burst
  - **Priority**: Medium

### Enemy Effects
- [ ] **Enemy Death** - Death animation/effect
  - **Type**: Animation / Particle system
  - **Duration**: ~0.4s
  - **Style**: Disintegration/explosion
  - **Priority**: High

- [ ] **Enemy Spawn** - Spawn animation
  - **Type**: Animation
  - **Duration**: ~0.3s
  - **Style**: Materialization/appearance effect
  - **Priority**: Medium

- [ ] **Enemy Hit** - Damage feedback flash
  - **Type**: Animation / Color flash
  - **Duration**: ~0.1s
  - **Style**: Red flash/damage indicator
  - **Priority**: Medium

### UI Effects
- [ ] **Button Hover** - UI button hover effect
  - **Type**: Animation
  - **Duration**: Instant
  - **Style**: Highlight/glow
  - **Priority**: Low

- [ ] **Button Click** - UI button click feedback
  - **Type**: Animation
  - **Duration**: ~0.1s
  - **Style**: Press animation
  - **Priority**: Low

- [ ] **Path Preview** - Visual path overlay
  - **Type**: Line/Arrow overlay
  - **Duration**: Continuous while preview active
  - **Style**: Dotted line with arrows showing enemy path
  - **Priority**: High

- [ ] **Invalid Placement Indicator** - Visual feedback for invalid placement
  - **Type**: Animation / Color overlay
  - **Duration**: Continuous while hovering invalid tile
  - **Style**: Red overlay/X mark
  - **Priority**: Medium

- [ ] **Valid Placement Indicator** - Visual feedback for valid placement
  - **Type**: Animation / Color overlay
  - **Duration**: Continuous while hovering valid tile
  - **Style**: Green overlay/highlight
  - **Priority**: Medium

### Furnace Effects
- [ ] **Furnace Destruction** - Game over effect
  - **Type**: Animation / Particle system
  - **Duration**: ~1.0s
  - **Style**: Explosion/destruction
  - **Priority**: High

- [ ] **Fireball Launch** - Initial fireball spawn effect
  - **Type**: Animation / Particle burst
  - **Duration**: ~0.2s
  - **Style**: Launch burst from furnace
  - **Priority**: Medium

---

## SFX (Sound Effects)

### Fireball Sounds
- [ ] **Fireball Travel** - Continuous sound while fireball moves
  - **Type**: Looping SFX
  - **Duration**: Continuous
  - **Style**: Whoosh/fire sound
  - **Priority**: Medium

- [ ] **Fireball Despawn** - Sound when fireball hits wall/despawns
  - **Type**: One-shot SFX
  - **Duration**: ~0.3s
  - **Style**: Impact/thud
  - **Priority**: Low

### Rune Activation Sounds
- [ ] **Redirect Rune Activation** - Sound when redirect rune activates
  - **Type**: One-shot SFX
  - **Duration**: ~0.2s
  - **Style**: Click/mechanical sound
  - **Priority**: Medium

- [ ] **Portal Rune Activation** - Teleportation sound
  - **Type**: One-shot SFX
  - **Duration**: ~0.4s
  - **Style**: Magical/energy whoosh
  - **Priority**: High

- [ ] **Explosive Rune Explosion** - Explosion sound effect
  - **Type**: One-shot SFX
  - **Duration**: ~0.5s
  - **Style**: Explosion/blast
  - **Priority**: High

- [ ] **Reflect Rune Activation** - Reflection sound
  - **Type**: One-shot SFX
  - **Duration**: ~0.2s
  - **Style**: Ping/deflect sound
  - **Priority**: Medium

- [ ] **Acceleration Rune Activation** - Speed boost sound
  - **Type**: One-shot SFX
  - **Duration**: ~0.3s
  - **Style**: Whoosh/acceleration
  - **Priority**: Low

### Enemy Sounds
- [ ] **Enemy Death** - Death sound effect
  - **Type**: One-shot SFX
  - **Duration**: ~0.4s
  - **Style**: Defeat/disintegration sound
  - **Priority**: High

- [ ] **Enemy Spawn** - Spawn sound
  - **Type**: One-shot SFX
  - **Duration**: ~0.3s
  - **Style**: Materialization/appearance sound
  - **Priority**: Low

- [ ] **Enemy Hit** - Damage sound
  - **Type**: One-shot SFX
  - **Duration**: ~0.1s
  - **Style**: Impact/hit sound
  - **Priority**: Medium

- [ ] **Enemy Reaches Furnace** - Game over sound
  - **Type**: One-shot SFX
  - **Duration**: ~0.5s
  - **Style**: Alarm/failure sound
  - **Priority**: High

### UI Sounds
- [ ] **Button Hover** - UI hover sound
  - **Type**: One-shot SFX
  - **Duration**: ~0.1s
  - **Style**: Subtle click/hover
  - **Priority**: Low

- [ ] **Button Click** - UI click sound
  - **Type**: One-shot SFX
  - **Duration**: ~0.1s
  - **Style**: Click/confirm sound
  - **Priority**: Low

- [ ] **Structure Placement** - Sound when placing structure
  - **Type**: One-shot SFX
  - **Duration**: ~0.2s
  - **Style**: Place/drop sound
  - **Priority**: Medium

- [ ] **Structure Sell** - Sound when selling structure
  - **Type**: One-shot SFX
  - **Duration**: ~0.2s
  - **Style**: Coin/refund sound
  - **Priority**: Medium

- [ ] **Invalid Action** - Error sound for invalid actions
  - **Type**: One-shot SFX
  - **Duration**: ~0.2s
  - **Style**: Error/buzz sound
  - **Priority**: Low

### Level Sounds
- [ ] **Level Start** - Sound when level begins
  - **Type**: One-shot SFX
  - **Duration**: ~0.5s
  - **Style**: Start/fanfare
  - **Priority**: Medium

- [ ] **Level Complete** - Victory sound
  - **Type**: One-shot SFX
  - **Duration**: ~1.0s
  - **Style**: Victory/fanfare
  - **Priority**: High

- [ ] **Level Failed** - Defeat sound
  - **Type**: One-shot SFX
  - **Duration**: ~1.0s
  - **Style**: Failure/sad sound
  - **Priority**: High

---

## Songs (Background Music)

### Main Menu Music
- [ ] **Title Screen Theme** - Main menu background music
  - **Type**: Looping music track
  - **Duration**: 2-3 minutes (loops)
  - **Style**: Atmospheric/ambient, matches game theme
  - **Priority**: Medium

### Gameplay Music
- [ ] **Build Phase Theme** - Music during build phase
  - **Type**: Looping music track
  - **Duration**: 2-3 minutes (loops)
  - **Style**: Calm/strategic, allows focus
  - **Priority**: Medium

- [ ] **Active Phase Theme** - Music during active phase
  - **Type**: Looping music track
  - **Duration**: 2-3 minutes (loops)
  - **Style**: Tense/action-oriented, builds excitement
  - **Priority**: High

### Level-Specific Music
- [ ] **Tutorial Level Music** - Music for Level 1
  - **Type**: Looping music track
  - **Duration**: 2-3 minutes (loops)
  - **Style**: Gentle/learning-friendly
  - **Priority**: Low (can reuse build phase theme)

- [ ] **Challenge Level Music** - Music for Levels 2-3
  - **Type**: Looping music track
  - **Duration**: 2-3 minutes (loops)
  - **Style**: More intense than tutorial
  - **Priority**: Low (can reuse active phase theme)

---

## 2D Assets

### Game Entities

#### Fireball
- [ ] **Fireball Sprite** - Main fireball sprite
  - **Size**: 32x32px (1:1 aspect ratio)
  - **Type**: Sprite
  - **Animated**: Yes (rotation or frame animation)
  - **Frames**: 4-8 frames for rotation animation
  - **Priority**: High

#### Furnace
- [ ] **Furnace Sprite** - Main furnace sprite
  - **Size**: 32x32px (1:1 aspect ratio)
  - **Type**: Sprite
  - **Animated**: Yes (idle animation - flames)
  - **Frames**: 4-6 frames for flame animation
  - **Priority**: High

#### Walls
- [ ] **Wall Sprite** - Standard wall sprite
  - **Size**: 32x32px (1:1 aspect ratio)
  - **Type**: Sprite
  - **Animated**: No
  - **Priority**: High

### Runes

#### Base Rune
- [ ] **Rune Base Sprite** - Base rune appearance (if needed)
  - **Size**: 32x32px (1:1 aspect ratio)
  - **Type**: Sprite
  - **Animated**: No
  - **Priority**: Low

#### Redirect Rune
- [ ] **Redirect Rune Sprite** - Base redirect rune sprite
  - **Size**: 32x32px (1:1 aspect ratio)
  - **Type**: Sprite
  - **Animated**: No
  - **Priority**: High

- [ ] **Redirect Rune Direction Indicators** - Arrow indicators for 4 directions
  - **Size**: 32x32px each (1:1 aspect ratio)
  - **Type**: Sprite (4 variants: N, S, E, W)
  - **Animated**: No
  - **Priority**: High

#### Advanced Redirect Rune
- [ ] **Advanced Redirect Rune Sprite** - Advanced redirect rune sprite
  - **Size**: 32x32px (1:1 aspect ratio)
  - **Type**: Sprite
  - **Animated**: No (distinct visual from regular redirect)
  - **Priority**: High

- [ ] **Advanced Redirect Direction Indicators** - Arrow indicators for 4 directions
  - **Size**: 32x32px each (1:1 aspect ratio)
  - **Type**: Sprite (4 variants: N, S, E, W)
  - **Animated**: No
  - **Priority**: High

#### Portal Rune
- [ ] **Portal Rune Entry Sprite** - Entry portal sprite
  - **Size**: 32x32px (1:1 aspect ratio)
  - **Type**: Sprite
  - **Animated**: Yes (portal swirl animation)
  - **Frames**: 6-8 frames for swirl
  - **Priority**: High

- [ ] **Portal Rune Exit Sprite** - Exit portal sprite
  - **Size**: 32x32px (1:1 aspect ratio)
  - **Type**: Sprite
  - **Animated**: Yes (portal swirl animation)
  - **Frames**: 6-8 frames for swirl
  - **Priority**: High

#### Explosive Rune
- [ ] **Explosive Rune Sprite** - Explosive rune sprite
  - **Size**: 32x32px (1:1 aspect ratio)
  - **Type**: Sprite
  - **Animated**: No (or subtle pulse animation)
  - **Priority**: High

#### Reflect Rune
- [ ] **Reflect Rune Sprite** - Reflect rune sprite
  - **Size**: 32x32px (1:1 aspect ratio)
  - **Type**: Sprite
  - **Animated**: No (mirror-like appearance)
  - **Priority**: High

#### Acceleration Rune
- [ ] **Acceleration Rune Sprite** - Acceleration rune sprite
  - **Size**: 32x32px (1:1 aspect ratio)
  - **Type**: Sprite
  - **Animated**: No (or subtle speed lines)
  - **Priority**: High

### Enemies

#### Basic Enemy
- [ ] **Basic Enemy Sprite** - Standard enemy sprite
  - **Size**: 32x32px (1:1 aspect ratio)
  - **Type**: Sprite
  - **Animated**: Yes (walking animation)
  - **Frames**: 4-6 frames for walk cycle
  - **Priority**: High

#### Fast Enemy
- [ ] **Fast Enemy Sprite** - Fast enemy sprite
  - **Size**: 32x32px (1:1 aspect ratio)
  - **Type**: Sprite
  - **Animated**: Yes (walking animation, faster)
  - **Frames**: 4-6 frames for walk cycle
  - **Priority**: High

#### Tank Enemy
- [ ] **Tank Enemy Sprite** - Tank enemy sprite
  - **Size**: 32x32px (1:1 aspect ratio)
  - **Type**: Sprite
  - **Animated**: Yes (walking animation, slower)
  - **Frames**: 4-6 frames for walk cycle
  - **Priority**: Medium (optional for MVP)

### Terrain/Tiles

#### Base Terrain
- [ ] **Open Terrain Tile** - Standard buildable terrain
  - **Size**: 32x32px (1:1 aspect ratio)
  - **Type**: Tile sprite
  - **Animated**: No
  - **Priority**: High

- [ ] **Rock/Mountain Tile** - Unbuildable terrain
  - **Size**: 32x32px (1:1 aspect ratio)
  - **Type**: Tile sprite
  - **Animated**: No
  - **Priority**: High

- [ ] **Spawn Point Indicator** - Visual marker for spawn points
  - **Size**: 32x32px (1:1 aspect ratio)
  - **Type**: Sprite overlay
  - **Animated**: Yes (subtle pulse/glow)
  - **Frames**: 4 frames for pulse
  - **Priority**: Medium

- [ ] **Grid Overlay** - Grid lines for placement visualization
  - **Size**: N/A (overlay)
  - **Type**: UI overlay
  - **Animated**: No
  - **Priority**: Medium

### UI Elements

#### Main Menu UI
- [ ] **Title Logo** - Game title/logo
  - **Size**: 320x80px (4:1 aspect ratio)
  - **Type**: UI sprite
  - **Animated**: No (or subtle glow)
  - **Priority**: High

- [ ] **Menu Background** - Main menu background
  - **Size**: 640x360px (16:9 aspect ratio)
  - **Type**: Background sprite
  - **Animated**: No
  - **Priority**: Medium

- [ ] **Menu Button** - Standard menu button
  - **Size**: 200x40px (5:1 aspect ratio)
  - **Type**: UI sprite
  - **Animated**: No
  - **Priority**: High

- [ ] **Menu Button Hover** - Button hover state
  - **Size**: 200x40px (5:1 aspect ratio)
  - **Type**: UI sprite
  - **Animated**: No
  - **Priority**: Medium

- [ ] **Menu Button Pressed** - Button pressed state
  - **Size**: 200x40px (5:1 aspect ratio)
  - **Type**: UI sprite
  - **Animated**: No
  - **Priority**: Medium

#### Build Phase UI
- [ ] **Resource Display Background** - Resource counter background
  - **Size**: 150x40px (3.75:1 aspect ratio)
  - **Type**: UI sprite
  - **Animated**: No
  - **Priority**: High

- [ ] **Resource Icon** - Resource currency icon
  - **Size**: 24x24px (1:1 aspect ratio)
  - **Type**: UI sprite
  - **Animated**: No
  - **Priority**: High

- [ ] **Build Panel Background** - Build panel container
  - **Size**: 200x400px (1:2 aspect ratio)
  - **Type**: UI sprite
  - **Animated**: No
  - **Priority**: High

- [ ] **Rune Button** - Button for placing runes
  - **Size**: 64x64px (1:1 aspect ratio)
  - **Type**: UI sprite
  - **Animated**: No
  - **Priority**: High

- [ ] **Wall Button** - Button for placing walls
  - **Size**: 64x64px (1:1 aspect ratio)
  - **Type**: UI sprite
  - **Animated**: No
  - **Priority**: High

- [ ] **Start Button** - Start level button
  - **Size**: 150x50px (3:1 aspect ratio)
  - **Type**: UI sprite
  - **Animated**: No
  - **Priority**: High

- [ ] **Path Preview Button** - Toggle path preview button
  - **Size**: 150x40px (3.75:1 aspect ratio)
  - **Type**: UI sprite
  - **Animated**: No
  - **Priority**: Medium

#### Active Phase UI
- [ ] **Minimal UI Background** - Minimal UI container
  - **Size**: 300x60px (5:1 aspect ratio)
  - **Type**: UI sprite
  - **Animated**: No
  - **Priority**: Medium

- [ ] **Level Name Display** - Level name text background
  - **Size**: 200x30px (6.67:1 aspect ratio)
  - **Type**: UI sprite
  - **Animated**: No
  - **Priority**: Low

#### Selling UI
- [ ] **Sell Menu Background** - Sell menu popup
  - **Size**: 120x80px (1.5:1 aspect ratio)
  - **Type**: UI sprite
  - **Animated**: No
  - **Priority**: Medium

- [ ] **Sell Button** - Sell structure button
  - **Size**: 100x30px (3.33:1 aspect ratio)
  - **Type**: UI sprite
  - **Animated**: No
  - **Priority**: Medium

- [ ] **Cancel Button** - Cancel sell button
  - **Size**: 100x30px (3.33:1 aspect ratio)
  - **Type**: UI sprite
  - **Animated**: No
  - **Priority**: Medium

#### Game Over UI
- [ ] **Game Over Background** - Game over screen background
  - **Size**: 400x200px (2:1 aspect ratio)
  - **Type**: UI sprite
  - **Animated**: No
  - **Priority**: Medium

- [ ] **Victory Text** - Victory message
  - **Size**: 300x60px (5:1 aspect ratio)
  - **Type**: UI sprite/text
  - **Animated**: No
  - **Priority**: Medium

- [ ] **Defeat Text** - Defeat message
  - **Size**: 300x60px (5:1 aspect ratio)
  - **Type**: UI sprite/text
  - **Animated**: No
  - **Priority**: Medium

- [ ] **Retry Button** - Retry level button
  - **Size**: 150x40px (3.75:1 aspect ratio)
  - **Type**: UI sprite
  - **Animated**: No
  - **Priority**: Medium

- [ ] **Next Level Button** - Next level button (victory only)
  - **Size**: 150x40px (3.75:1 aspect ratio)
  - **Type**: UI sprite
  - **Animated**: No
  - **Priority**: Medium

- [ ] **Main Menu Button** - Return to menu button
  - **Size**: 150x40px (3.75:1 aspect ratio)
  - **Type**: UI sprite
  - **Animated**: No
  - **Priority**: Medium

#### Pause Menu UI
- [ ] **Pause Menu Background** - Pause menu overlay
  - **Size**: 400x300px (4:3 aspect ratio)
  - **Type**: UI sprite
  - **Animated**: No
  - **Priority**: Low

- [ ] **Resume Button** - Resume game button
  - **Size**: 150x40px (3.75:1 aspect ratio)
  - **Type**: UI sprite
  - **Animated**: No
  - **Priority**: Low

- [ ] **Quit to Menu Button** - Quit button
  - **Size**: 150x40px (3.75:1 aspect ratio)
  - **Type**: UI sprite
  - **Animated**: No
  - **Priority**: Low

### Itch.io Page Assets

#### Promotional Images
- [ ] **Game Logo** - Main game logo for page header
  - **Size**: 800x200px (4:1 aspect ratio)
  - **Type**: Logo/Graphic
  - **Animated**: No
  - **Priority**: High

- [ ] **Hero Image** - Main promotional image
  - **Size**: 1920x1080px (16:9 aspect ratio)
  - **Type**: Screenshot/Promo art
  - **Animated**: No (or animated GIF)
  - **Priority**: High

- [ ] **Screenshot 1** - Gameplay screenshot
  - **Size**: 1280x720px (16:9 aspect ratio)
  - **Type**: Screenshot
  - **Animated**: No
  - **Priority**: High

- [ ] **Screenshot 2** - Build phase screenshot
  - **Size**: 1280x720px (16:9 aspect ratio)
  - **Type**: Screenshot
  - **Animated**: No
  - **Priority**: High

- [ ] **Screenshot 3** - Active phase screenshot
  - **Size**: 1280x720px (16:9 aspect ratio)
  - **Type**: Screenshot
  - **Animated**: No
  - **Priority**: High

- [ ] **Screenshot 4** - Rune close-up screenshot
  - **Size**: 1280x720px (16:9 aspect ratio)
  - **Type**: Screenshot
  - **Animated**: No
  - **Priority**: Medium

#### Thumbnails
- [ ] **Page Thumbnail** - Itch.io page thumbnail
  - **Size**: 630x500px (1.26:1 aspect ratio)
  - **Type**: Thumbnail
  - **Animated**: No
  - **Priority**: High

- [ ] **Download Thumbnail** - Download button thumbnail
  - **Size**: 630x500px (1.26:1 aspect ratio)
  - **Type**: Thumbnail
  - **Animated**: No
  - **Priority**: High

#### Icons
- [ ] **Game Icon** - Game icon for downloads
  - **Size**: 512x512px (1:1 aspect ratio)
  - **Type**: Icon
  - **Animated**: No
  - **Priority**: High

- [ ] **Favicon** - Browser favicon
  - **Size**: 32x32px (1:1 aspect ratio)
  - **Type**: Icon
  - **Animated**: No
  - **Priority**: Medium

#### Social Media Assets
- [ ] **Twitter Card Image** - Twitter preview image
  - **Size**: 1200x630px (1.9:1 aspect ratio)
  - **Type**: Social media asset
  - **Animated**: No
  - **Priority**: Low

- [ ] **Discord Embed Image** - Discord embed preview
  - **Size**: 1200x630px (1.9:1 aspect ratio)
  - **Type**: Social media asset
  - **Animated**: No
  - **Priority**: Low

---

## Level Designs

### Level 1: Tutorial Level
- [ ] **Level Design Document** - Complete level specification
  - **Metadata**:
    - **Level ID**: 1
    - **Level Name**: "First Steps"
    - **Difficulty**: Very Easy (nearly guaranteed win)
    - **Enemy Types**: Basic Enemy only
    - **Enemy Count**: Minimal (3-5 enemies)
    - **Initial Resources**: 50 (generous)
    - **Runes Available**: Redirect, Reflect, Acceleration
    - **Initial Runes**: 2-3 Redirect Runes (pre-placed)
    - **Initial Walls**: 0-2 walls (if needed for teaching)
    - **Spawn Points**: 1 spawn point
    - **Teaching Focus**: Fireball kills enemies, redirect runes, rune editing
  - **Status**: Not Started
  - **Priority**: High

### Level 2: Challenge Level
- [ ] **Level Design Document** - Complete level specification
  - **Metadata**:
    - **Level ID**: 2
    - **Level Name**: "Speed Challenge"
    - **Difficulty**: Moderate
    - **Enemy Types**: Basic Enemy, Fast Enemy
    - **Enemy Count**: Moderate (8-12 enemies)
    - **Initial Resources**: 40
    - **Runes Available**: Redirect, Reflect, Acceleration, Explosive
    - **Initial Runes**: 1-2 runes (strategic placement)
    - **Initial Walls**: 2-4 walls
    - **Spawn Points**: 1-2 spawn points
    - **Teaching Focus**: Fast enemies, explosive runes
  - **Status**: Not Started
  - **Priority**: High

### Level 3: Challenge Level
- [ ] **Level Design Document** - Complete level specification
  - **Metadata**:
    - **Level ID**: 3
    - **Level Name**: "Final Test"
    - **Difficulty**: High
    - **Enemy Types**: Basic Enemy, Fast Enemy, Tank Enemy (if implemented)
    - **Enemy Count**: High (15-20 enemies)
    - **Initial Resources**: 35
    - **Runes Available**: All runes
    - **Initial Runes**: 2-3 runes (complex setup)
    - **Initial Walls**: 3-5 walls
    - **Spawn Points**: 2-3 spawn points
    - **Teaching Focus**: All mechanics, strategic planning
  - **Status**: Not Started
  - **Priority**: High

---

## Enemy Designs

### Basic Enemy
- [ ] **Enemy Design Document** - Complete enemy specification
  - **Metadata**:
    - **Enemy Type**: Basic Enemy
    - **Health**: 50 HP
    - **Speed**: 50 pixels/second
    - **Visual Style**: Standard enemy appearance
    - **Color Scheme**: Primary color (distinct from other types)
    - **Size**: 32x32px
    - **Animation**: 4-6 frame walk cycle
    - **Introduction Level**: Level 1
    - **Role**: Baseline enemy, standard threat
  - **Status**: Not Started
  - **Priority**: High

### Fast Enemy
- [ ] **Enemy Design Document** - Complete enemy specification
  - **Metadata**:
    - **Enemy Type**: Fast Enemy
    - **Health**: 30 HP
    - **Speed**: 80 pixels/second
    - **Visual Style**: Sleek/fast appearance
    - **Color Scheme**: Distinct color (e.g., blue/yellow)
    - **Size**: 32x32px
    - **Animation**: 4-6 frame walk cycle (faster animation)
    - **Introduction Level**: Level 2
    - **Role**: Speed challenge, lower health
  - **Status**: Not Started
  - **Priority**: High

### Tank Enemy
- [ ] **Enemy Design Document** - Complete enemy specification
  - **Metadata**:
    - **Enemy Type**: Tank Enemy
    - **Health**: 150 HP
    - **Speed**: 30 pixels/second
    - **Visual Style**: Heavy/armored appearance
    - **Color Scheme**: Distinct color (e.g., red/dark)
    - **Size**: 32x32px
    - **Animation**: 4-6 frame walk cycle (slower animation)
    - **Introduction Level**: Level 3 (optional for MVP)
    - **Role**: Durability challenge, slow but tough
  - **Status**: Not Started
  - **Priority**: Medium (optional for MVP)

---

## Asset Status Summary

### By Category
- **VFX**: 0/20 complete (0%)
- **SFX**: 0/20 complete (0%)
- **Songs**: 0/4 complete (0%)
- **2D Assets (Game)**: 0/60+ complete (0%)
- **2D Assets (Itch.io)**: 0/10 complete (0%)
- **Level Designs**: 0/3 complete (0%)
- **Enemy Designs**: 0/3 complete (0%)

### By Priority
- **High Priority**: ~45 items
- **Medium Priority**: ~25 items
- **Low Priority**: ~15 items

---

## Notes

### Asset Creation Guidelines
- **Art Style**: Pixel art, matches 640x360 resolution
- **Color Palette**: Consistent color scheme across all assets
- **Animation**: Use sprite sheets for animations (4-8 frames typical)
- **File Format**: PNG for sprites, OGG for audio (or WAV for SFX)

### Asset Organization
- **Game Assets**: `godot/assets/sprites/` and `godot/assets/audio/`
- **Itch.io Assets**: Separate folder for promotional materials
- **Naming Convention**: `[type]_[name]_[variant].png` (e.g., `rune_redirect_north.png`)

### Dependencies
- Some assets depend on others (e.g., UI buttons need hover/pressed states)
- VFX may reference sprite assets for particles
- Level designs depend on enemy designs being finalized

---

**Last Updated**: [Current Date]  
**Next Review**: [Update as needed]
