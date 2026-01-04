extends Resource
class_name SoundEffectConfig
## Resource for designer-tunable sound effect volumes
## All volumes are multipliers: 0.0 = silent, 1.0 = normal, 2.0 = double volume


@export_range(0.0, 2.0, 0.1) var rune_accelerate_volume: float = 1.0
@export_range(0.0, 2.0, 0.1) var rune_generic_volume: float = 1.0
@export_range(0.0, 2.0, 0.1) var burn_volume: float = 1.0
@export_range(0.0, 2.0, 0.1) var fireball_spawn_volume: float = 1.0
@export_range(0.0, 2.0, 0.1) var enemy_death_volume: float = 1.0
@export_range(0.0, 2.0, 0.1) var furnace_death_volume: float = 1.0
@export_range(0.0, 2.0, 0.1) var level_failed_volume: float = 1.0
@export_range(0.0, 2.0, 0.1) var click_volume: float = 1.0
@export_range(0.0, 2.0, 0.1) var structure_sell_volume: float = 1.0
@export_range(0.0, 2.0, 0.1) var structure_buy_volume: float = 1.0
@export_range(0.0, 2.0, 0.1) var pickup_spark_volume: float = 1.0
@export_range(0.0, 2.0, 0.1) var invalid_action_volume: float = 1.0
@export_range(0.0, 2.0, 0.1) var fireball_travel_volume: float = 1.0


## Get volume for a sound effect by name
func get_volume(effect_name: String) -> float:
	match effect_name:
		"rune-accelerate":
			return rune_accelerate_volume
		"rune-generic":
			return rune_generic_volume
		"burn":
			return burn_volume
		"fireball-spawn":
			return fireball_spawn_volume
		"enemy-death":
			return enemy_death_volume
		"furnace-death":
			return furnace_death_volume
		"level-failed":
			return level_failed_volume
		"click":
			return click_volume
		"structure-sell":
			return structure_sell_volume
		"structure-buy":
			return structure_buy_volume
		"pickup-spark":
			return pickup_spark_volume
		"invalid-action":
			return invalid_action_volume
		"fireball-travel":
			return fireball_travel_volume
		_:
			return 1.0  # Default volume
