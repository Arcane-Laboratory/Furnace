# Pathfinding Visualization

**Version**: 1.0  
**Last Updated**: [Current Date]

---

## Pathfinding Visualization System

### Visual Style
- **Overlay**: Dotted line arrow overlay
- **Display**: Shows enemy route from spawn points to furnace
- **Style**: Dotted line with arrows indicating direction
- **Color**: [To be defined - should be visible but not intrusive]

### Display Timing
- **On Demand**: Path visualization updates on demand (not real-time)
- **Build Phase**: Available during build phase
- **Trigger**: Player requests path preview (button, key, etc.)
- **Active Phase**: Not displayed during active phase

### Multiple Spawn Points
- **All Paths Shown**: Displays paths from all spawn points
- **Visual Distinction**: Different colors/styles for different spawn paths (optional)
- **Clear Indication**: Player can see all enemy routes

### Path Updates
- **On Demand**: Recalculates when player requests
- **Not Real-Time**: Does not update automatically as structures are placed
- **Manual Refresh**: Player must request update to see new path

### No Valid Path Handling
- **Visual Warning**: Shows warning when no valid path exists
- **Start Button**: Disabled when path is invalid
- **Validation**: Prevents starting level if no valid path
- **Feedback**: Clear indication to player why they can't start

### Implementation Notes
- Calculate pathfinding when player requests preview
- Draw dotted line arrow overlay on grid
- Handle multiple spawn points (show all paths)
- Validate path before allowing level start
- Provide clear feedback for invalid paths

---

**Status**: Ready for implementation
