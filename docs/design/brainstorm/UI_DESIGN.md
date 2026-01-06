# UI Design Specification

**Version**: 1.0  
**Last Updated**: [Current Date]  
**Purpose**: Detailed UI/UX specifications for Furnace

---

## UI Phase System

### Build Phase UI
- **Toggle**: UI switches to build phase mode
- **Components**:
  - Money resource indicator (always visible)
  - Build UI panel (shows all rune/wall types)
  - Start button
  - Pathfinding visualization (on-demand)

### Active Phase UI
- **Toggle**: UI switches to active phase mode
- **Components**:
  - Money resource indicator (always visible)
  - Minimal UI (player observes only)
  - [Other active phase UI elements TBD]

---

## Resource Display

### Money Resource Indicator
- **Visibility**: Always shown (both build and active phases)
- **Information**: Current resource amount
- **Placement**: [To be defined - top corner, etc.]
- **Style**: [To be defined - text, icon, etc.]

---

## Build Phase UI

### Build UI Panel
- **Purpose**: Shows all available rune and wall types
- **Display**: 
  - All rune types (Redirect, Advanced Redirect, Portal, Reflect, Explosive, Acceleration)
  - Wall type
  - Cost for each item displayed
- **Interaction**:
  - **Click**: Show more information about item
  - **Drag**: Drag item to map to build it (if enough money)
  - **Validation**: Can only build if player has enough resources

### Start Button
- **Location**: [To be defined - likely bottom or side of build UI]
- **Functionality**: 
  - Starts the level (begins active phase)
  - Only enabled/clickable if valid path exists
  - Disabled if no valid path (with visual indication)

### Pathfinding Visualization
- **Trigger**: On-demand (player requests)
- **Display**: Dotted line arrow overlay
- **See**: PATHFINDING_VISUALIZATION.md for details

---

## Selling System

### Sell Interaction
- **Method**: Click on tile containing player-placed wall or rune
- **Sell Button**: Appears above the clicked tile
- **Refund**: Full refund (100% of cost)
- **Limitations**: 
  - Cannot sell initial elements (non-editable)
  - Only during build phase

---

## Active Phase UI

### Minimal UI
- **Purpose**: Player observes only (no interaction)
- **Components**:
  - Money resource indicator (always visible)
  - Level name/number display (no wave indicator - one level = one wave)
  - [Other elements TBD - furnace health, etc.]

---

## UI Flow

### Build Phase Flow
1. Player sees build UI panel with all rune/wall types and costs
2. Player clicks item for info OR drags to map to build
3. If building: Check if enough money, place if valid
4. Player can click placed structures to sell (sell button appears above)
5. Player can request pathfinding visualization
6. Player clicks Start button when ready (if valid path exists)

### Active Phase Flow
1. UI switches to active phase mode
2. Minimal UI shown
3. Player observes fireball and enemies
4. Player can change Advanced Redirect Rune directions (if applicable)
5. Level ends when all enemies defeated OR furnace destroyed

---

## Visual Design Notes

### Placement Considerations
- Build UI panel: [To be defined - side, bottom, etc.]
- Resource indicator: [To be defined - top corner]
- Start button: [To be defined - prominent placement]
- Sell button: Appears above clicked tile

### Style Guidelines
- Clear, readable text
- Cost clearly displayed for each item
- Visual feedback for interactions
- Disabled state for Start button when invalid

---

## Implementation Notes

### Phase Switching
- Smooth transition between build and active phase UI
- Hide/show appropriate UI elements
- Maintain resource indicator visibility

### Drag and Drop
- Drag item from build UI panel
- Visual feedback during drag
- Highlight valid placement tiles
- Show cost validation

### Sell Button
- Position above clicked tile
- Clear visual indication
- Easy to click
- Dismiss on click elsewhere or after selling

---

**Status**: Ready for UI implementation. Some placement details to be finalized during development.
