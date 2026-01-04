The puprose of this document is to check in with ourselves about our progress and direction.
Is the game fun? Are choices impactful? What about it is fun and how do we double down on it? What is not fun? What is ignored or useless?

## Fun

It is fun to feel the power fantasy of a magical furnace. When your fireball does a good job of killing enemies, it feels good.

### lack of build diversity

- the only valid approach to killing enemies is with the acceleration rune
- the reflect rune is less versitile than the redirect rune, is more expensive, and only works once
- the explosive rune is nice, but it only works one time
- the acceleration rune is very fun and immediately powerful. the cap is hit early

### lack of anticipation

- without knowing more information about incoming enemies, planning is not very fun
    - this can be mitigated via level design, by creating levels which have more initial tiles set
        - for example, a full map and very constrained resources

### lack of difficulty

- in creative mode, such few enemies trivialize gameplay
- central mechanic issue: because the fireball pierces enemies, killing 1 enemy and 100 enemies is equally difficult if they are in the same place
    - one way we could fix this is by having one of the core runes increase the fireball’s damage to the next enemy it hits, this means that the fireball needs to return there to refresh it’s damage, and players can decide if they want more frequent refreshes or more stacks of the buff.
- an auto-scaling mode where heat increases and randomized waves of enemies can be built and act as a guaranteed difficulty ramp for all levels, as well as a potential endless mode

### lack of investment

- because one level is one wave, there is less of a feeling of investing in your build
    - enemies could drop scrap, which could allow you to build and access other parts of the level, but we need to design some levels and get them working first

## Key To Dos

1. Tile Functional and cost Tuning
    
    Tiles should function in an engaging way
    
    - one-use tiles should be cheaper or more impactful
    - repeated-use tiles should be more expensive, weaker, or limited in another way
2. Level design and progression
    - Identify a short list (1 to 3) of basic interactions
    - make a tutorial puzzle level for basic interaction
    - make a ‘challenging’ level for each interaction
    - build on top of these interactions in a final level
    - add a level select screen
    - add a game victory card when all levels are cleared
3. Asset integration
    - get background, tiles, and enemy assets integrated
4. ensure debug mode is disabled on export
5. Effects and polish
    - implement sound or visual effects for key occurrences
        - rune activation
        - damage dealt
        - game over
        - you beat the game
        - fireball shot
        - fireball died
        
6. Tile upgrades
    - disable this system until we have solved core gameplay issues
        - later, maybe enemies drop scrap and tiles can be upgraded during active mode

---

### Kevin’s Thoughts

- Having 3 gameplay “strategies” is a really good number
- The easiest 3 to hit are:
    - Create a “kill zone” (aka a long horizontal area where the fireball bounces back and forth as efficiently as possible)
    - Create a “buff zone” (aka have the fireball gain speed / damage on a track, then use a portal or redirect rune to send that fireball towards the enemies to 1-tap them)
    - Create a “maze” (aka build a maze that makes monsters take a long time to walk through, whilst taking damage from various sources that take advantage of good AOE zones like corners)

**Kill Zone Strategy**

- We already have this, basically — just use any mishmash of runes to do this

**Buff Zone Strategy**

- Currently, this isn’t differentiated enough from Kill Zone strategy because the acceleration gate is capped too low, doesn’t increase damage, and has no fall-off
- The way to make this strategy work is to incentive the player to buff the fireball as much as possible **before** it hits a monster, because the fireball loses some power when it does hit a monster
- My proposed changes:
    - Fireball loses `X` stacks of acceleration upon hitting an enemy
    - Acceleration stacks are uncapped
    - Acceleration stacks also grant a stacking damage bonus
        - Alternative: There’s a different rune that grants a stacking damage bonus, which also loses `X` stacks upon hitting an enemy, and you have to decide whether you want more speed or power (there’s some optimization here for the player)
- This way, players are actually forced to think about how much they want to buff their fireball before unleashing it, rather than just splashing acceleration tiles along their kill zone tracks for passive damage boost

**Maze Strategy**

- Currently, this doesn’t really work because we don’t have anything that has constant AOE effects
- We’d need to add some builds that do — the easiest are:
    - AOE Damage Tile (Explosive?) — Does damage in a 1-3 tile radius (depending on upgrade level) whenever the fireball passes near it
    - AOE Slow Tile (Freezing?) — Slows enemies in a 1-3 tile radius (depending on upgrade level) either on a cooldown or whenever the fireball passes near it
- With just these two, we create an entire line of player thinking for “how do I optimize AOE tiles using my mazing abilities?”
- It’s important to note that, in order to make this strategy work, we probably want to have the AOE tiles act as walls, rather than ground tiles, otherwise the build options are too constrained and they force conflict with ground tiles. Here’s an example (imagine the boom tiles are walls):
