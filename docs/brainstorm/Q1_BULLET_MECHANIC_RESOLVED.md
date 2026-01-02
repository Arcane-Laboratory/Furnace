# Q1: Single Bullet Mechanic - Resolved Details

## ✅ Confirmed Mechanics

### Core Behavior
- **Travel**: Bullet travels through space at a defined speed
- **Piercing**: Bullet pierces through enemies, dealing damage to all enemies in its path
- **Damage Type**: Direct damage to enemies (not area effect)

### Initial Shot
- **Trigger**: Player clicks furnace to fire
- **Time Effect**: Time dramatically slows when aiming
- **Aiming UI**: Player gets aiming interface to set initial trajectory
- **Confirmation**: Player confirms shot direction before bullet fires

### Tower Interactions
- **Passive Triggers**: Bullet triggers passive tower abilities when it hits/passes through towers
- **Redirect Towers**: Some towers can redirect the bullet
  - When bullet hits a redirect-capable tower, time pauses
  - Player gets aiming UI to redirect bullet
  - Player chooses new trajectory

### Visual/Feel
- Bullet is a visible projectile moving through space
- Time manipulation creates strategic decision points
- Player has active control over bullet path through aiming

---

## ✅ Resolved Details

### Bullet Behavior
- **Damage**: Fixed damage per enemy hit
- **Enemy Health**: Varied (different types have different health)
- **Piercing**: Infinite - can hit unlimited enemies
- **Lifetime**: No limits - travels until it leaves screen or hits wall/terrain
- **Boundary**: Despawns when leaving screen or hitting wall/terrain
- **Terrain**: Cannot pass through terrain, despawns on collision

### Redirect Mechanics
- **No Redirect Limit**: Bullet can be redirected unlimited times
- **Reroute Towers**: 
  - Limited use (starts with 1 use, can be upgraded)
  - Pauses time (same slow-mo as initial shot - developer tunable)
  - Player chooses new direction via aiming UI
  - Can be reused if bullet loops back and tower has uses remaining
- **Reflect Towers**: 
  - Limited use (starts with uses, can be upgraded)
  - Automatically reflects bullet to closest 90-degree angle (snaps to grid)
  - Bullet travels along game grid after reflection
  - Has debounce/cooldown period to prevent getting stuck

### Developer Tunable Parameters
- **Bullet Damage**: Fixed damage value (developer tunable)
- **Time Slow-Mo Speed**: Speed of time when aiming (developer tunable)

---

## ❓ Remaining Questions


### Tower Interactions - Details
7. **Multiple Redirects**: ✅ **RESOLVED**
   - Bullet can be redirected **unlimited times**
   - No limit on total number of redirects
   - Two types of redirect towers:
     - **Reroute Towers**: Limited use (player chooses new direction, time pauses for aiming)
     - **Reflect/Bounce Towers**: Reusable (bounces bullet back in direction it came, automatic)

8. **Reroute Tower Details**: ✅ **RESOLVED**
   - Starts with **1 use** per tower
   - Can be upgraded for more uses (if upgrade system is implemented)
   - If bullet loops back and tower has uses remaining, it can be used again
   - When time pauses for aiming: Same slow-mo mechanics as initial shot
   - Time slow-mo speed: **Developer-tunable parameter**

9. **Reflect/Bounce Tower Details**: ✅ **RESOLVED**
   - Reflects bullet to **closest 90-degree angle** (snaps to grid alignment)
   - Bullet travels along game grid after reflection
   - **Limited use** (not reusable) - starts with uses, can be upgraded
   - **Debounce/Cooldown period**: Prevents bullet from getting stuck bouncing repeatedly
   - Works automatically when bullet hits tower

10. **Tower Hit Detection**: 
    - Does bullet need to pass through tower center?
    - Or just pass within tower's range/area?
    - Can bullet hit multiple towers in sequence?

11. **Passive Tower Triggers**: 
    - Which towers trigger on bullet hit vs enemy proximity?
    - Can multiple passive effects trigger simultaneously?
    - What's the order/priority if multiple towers are hit?

12. **Duplicator Tower**: 
    - When bullet hits duplicator, does it:
      - Split into multiple bullets (how many?)?
      - Create copies that travel different paths?
      - All copies can be redirected independently?
    - Do duplicated bullets also have fixed damage?

13. **Portal Tower**: 
    - Does it teleport bullet to another location?
    - Or bounce/reflect bullet?
    - Can portal have two endpoints (entry/exit)?

### Time Manipulation
12. **Slow-Mo Speed**: 
    - How slow is "dramatically slowed" at furnace? (10% speed? 1%?)
    - Can player take unlimited time to aim, or is there a limit?

13. **Pause Duration**: 
    - When bullet hits redirect tower, how long can player take to aim?
    - Unlimited time or limited window?

14. **Enemy Movement During Slow-Mo**: 
    - Do enemies still move during slow-mo (just slower)?
    - Or are they completely frozen?

### Visual & Feedback
15. **Aiming UI**: 
    - What does aiming UI look like?
    - Line preview? Arrow? Trajectory arc?
    - Does it show predicted path through towers?

16. **Bullet Visual**: 
    - What does bullet look like?
    - Does it have trail/particles?
    - Does it change appearance when modified by towers?

---

## 🎯 Priority Questions to Answer Next

**Before implementation, we need:**
1. ~~Damage value and enemy health relationship~~ ✅ **RESOLVED** (fixed damage, varied health, developer tunable)
2. ~~Bullet lifetime/range limits~~ ✅ **RESOLVED** (no limits, despawns on boundary/terrain)
3. ~~Multiple redirect behavior~~ ✅ **RESOLVED** (unlimited redirects, reroute/reflect mechanics defined)
4. ~~Time manipulation specifics~~ ✅ **RESOLVED** (same slow-mo as initial shot, developer tunable)
5. Duplicator and Portal tower exact mechanics
6. Tower hit detection (center vs range)
7. Reflect tower debounce/cooldown duration (developer tunable value)
8. Enemy health ranges (for balance)

**Can be refined during playtesting:**
- Visual details
- Exact aiming UI
- Boundary behaviors

---

## 💡 Design Recommendations

Based on what we know, here are some suggestions to consider:

### Damage Model Options:
- **Option A - One-Shot Basic Enemies**: Bullet kills basic enemies instantly, but stronger enemies take multiple hits
- **Option B - Fixed Damage**: Bullet deals X damage, enemies have varying health (e.g., 50 damage, enemies have 50/100/150 HP)
- **Option C - Percentage**: Bullet deals % of enemy health (e.g., 50% damage per hit)

### Bullet Lifetime Options:
- **Option A - Range Limit**: Bullet travels X tiles then despawns
- **Option B - Enemy Limit**: Bullet can hit max Y enemies then despawns
- **Option C - Infinite**: Bullet travels until it hits boundary or specific condition

### Redirect Limit Options:
- **Option A - Unlimited**: Can redirect as many times as there are redirect towers
- **Option B - Limited**: Max 3-5 redirects per bullet
- **Option C - Per Tower**: Each redirect tower can only redirect once per bullet

---

**Status**: Core mechanic defined ✅ | Details need clarification ❓
