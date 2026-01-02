# Designer Levers

**Version**: 1.0  
**Last Updated**: [Current Date]  
**Purpose**: Configurable properties that level designers can adjust without code changes

---

## Rune Properties

### Unlocked By Default
- **Property**: `unlocked_by_default` (boolean)
- **Purpose**: Determines if rune is available from the start
- **Default**: Can be set per rune type
- **Usage**: 
  - If `true`: Rune is available in all levels (unless level specifically restricts it)
  - If `false`: Rune must be unlocked or allowed by level

### Level-Specific Rune Allowance
- **Property**: `allowed_runes` (array of rune types)
- **Purpose**: Levels can specify which runes are allowed beyond default runes
- **Usage**:
  - Level can allow additional runes beyond default unlocked runes
  - Level can restrict runes (only allow subset of default runes)
  - Empty array = only default unlocked runes available

### Example Configuration

**Rune Defaults:**
```json
{
  "runes": {
    "redirect": {
      "unlocked_by_default": true
    },
    "advancedRedirect": {
      "unlocked_by_default": false
    },
    "portal": {
      "unlocked_by_default": false
    },
    "reflect": {
      "unlocked_by_default": true
    },
    "explosive": {
      "unlocked_by_default": false
    },
    "acceleration": {
      "unlocked_by_default": true
    }
  }
}
```

**Level Configuration:**
```json
{
  "level1": {
    "allowed_runes": ["redirect", "reflect", "acceleration"]
  },
  "level2": {
    "allowed_runes": ["redirect", "reflect", "acceleration", "explosive"]
  },
  "level3": {
    "allowed_runes": ["redirect", "advancedRedirect", "portal", "reflect", "explosive", "acceleration"]
  }
}
```

---

## Level Progression

### MVP: Gated Progression
- **Start**: Player begins at Level 1
- **Progression**: Must clear level to unlock next level
- **Linear**: Levels unlock sequentially (Level 1 → Level 2 → Level 3, etc.)
- **No Level Select**: MVP has no level select menu (post-MVP feature)

### Post-MVP: Level Select Menu
- **Feature**: Level select menu with unlocks
- **Status**: Post-MVP
- **Details**: To be defined post-MVP

---

## Implementation Notes

### Rune Availability Logic
1. Check if rune is `unlocked_by_default`
2. Check if level's `allowed_runes` includes the rune
3. Rune is available if: (unlocked_by_default OR in allowed_runes) AND not restricted by level

### Level Progression Logic
- Track completed levels
- Start at Level 1
- Unlock next level when current level is cleared
- Store progression (save file, local storage, etc.)

---

**Status**: Ready for implementation
