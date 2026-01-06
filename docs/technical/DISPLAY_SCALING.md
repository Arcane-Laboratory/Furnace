# Display Scaling & Pixel Perfect Rendering

**Version**: 1.0  
**Last Updated**: [Current Date]  
**Purpose**: Display scaling and pixel perfect rendering specifications for Furnace

---

## Display Specifications

### Base Resolution
- **Resolution**: 640 x 360 pixels
- **Aspect Ratio**: 16:9
- **Pixel Perfect**: Yes - maintain pixel perfect rendering

### Scaling Method
- **Stretch Scaling**: Stretch to fit screen (not integer scaling)
- **Aspect Ratio**: Maintain 16:9 aspect ratio (letterbox/pillarbox if needed)
- **Viewport**: Center the game viewport

---

## Pixel Perfect Rendering

### Requirements
- **Maintain Pixel Perfect**: No sub-pixel rendering
- **Crisp Pixels**: Pixels should remain sharp and clear
- **No Blurring**: Avoid blurry upscaling artifacts

---

## Godot Implementation

### Project Settings

#### Display Settings
1. **Window Settings**:
   - Set base window size to 640x360
   - Enable "Stretch" mode
   - Set stretch mode to "viewport" or "2d"

2. **Stretch Settings**:
   - **Stretch Mode**: `viewport` or `2d`
   - **Stretch Aspect**: `keep` (maintains 16:9 aspect ratio)
   - **Stretch Shrink**: `1` (no shrinking)

#### Pixel Perfect Settings
1. **2D Settings**:
   - Enable "Use Pixel Snap" in Project Settings → Rendering → 2D
   - This ensures sprites snap to pixel boundaries

2. **Viewport Settings**:
   - Set viewport size to 640x360
   - Enable "Snap 2D Transforms to Pixel"
   - Enable "Snap 2D Vertices to Pixel"

3. **Canvas Settings**:
   - Use `CanvasLayer` for UI elements
   - Set proper scaling mode for UI

### Code Implementation

#### Viewport Configuration
```gdscript
# In main scene or game manager
func _ready():
    # Set viewport size
    get_viewport().size = Vector2(640, 360)
    
    # Enable pixel snap
    get_viewport().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
    
    # Or use project settings:
    # Project Settings → Rendering → Textures → Canvas Textures → Default Texture Filter → Nearest
```

#### Sprite Settings
- Use `Texture` import settings:
  - Set Filter to "Nearest" (not "Linear")
  - This prevents blurry upscaling

#### UI Scaling
- Use `Control` nodes with proper anchors
- Consider using `Control` scale or `CanvasLayer` for UI
- Test on different screen sizes

---

## Scaling Behavior

### Different Screen Sizes

#### Large Screens
- Game will stretch to fill screen
- Maintains 16:9 aspect ratio
- Letterbox/pillarbox if screen aspect ratio differs
- Pixels remain crisp (pixel perfect)

#### Small Screens
- Game will scale down if needed
- Maintains aspect ratio
- May be smaller than screen if aspect ratio differs

#### Mobile Considerations
- Test on mobile devices if targeting mobile
- Consider touch controls if needed
- Ensure UI is readable at scaled sizes

---

## Testing

### Test Scenarios
- Different screen resolutions
- Different aspect ratios (16:9, 16:10, 4:3, etc.)
- Window resizing (if supported)
- Fullscreen mode

### Verification
- Pixels remain crisp and sharp
- No blurry upscaling
- Aspect ratio maintained
- Game centered properly

---

## Godot-Specific Notes

### Recommended Settings
1. **Project Settings → Display → Window**:
   - Size: 640x360
   - Stretch Mode: `viewport` or `2d`
   - Stretch Aspect: `keep`

2. **Project Settings → Rendering → 2D**:
   - Use Pixel Snap: Enabled

3. **Project Settings → Rendering → Textures → Canvas Textures**:
   - Default Texture Filter: `Nearest`

4. **Sprite Import Settings**:
   - Filter: `Nearest` (for pixel art)

### Viewport Setup
- Main viewport should be 640x360
- UI can use separate CanvasLayer
- Test scaling in editor and exported builds

---

**Status**: Ready for implementation. Pixel perfect rendering maintained through Godot settings.
