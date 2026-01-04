extends Control
## Reusable stats display component - shows soot vanquished, sparks used, damage dealt


## Reference to UI elements (using unique names from scene)
@onready var soot_value: Label = %LevelValue
@onready var sparks_value: Label = %MoneyValue
@onready var damage_value: Label = %HeatValue


func _ready() -> void:
	_ensure_labels_ready()


## Ensure label references are initialized (handles timing issues)
func _ensure_labels_ready() -> void:
	if not soot_value:
		soot_value = get_node_or_null("%LevelValue") as Label
	if not sparks_value:
		sparks_value = get_node_or_null("%MoneyValue") as Label
	if not damage_value:
		damage_value = get_node_or_null("%HeatValue") as Label


## Set all stats at once
func set_stats(soot: int, sparks: int, damage: int) -> void:
	_ensure_labels_ready()
	set_soot_vanquished(soot)
	set_sparks_used(sparks)
	set_damage_dealt(damage)


## Set soot vanquished value
func set_soot_vanquished(value: int) -> void:
	_ensure_labels_ready()
	if soot_value:
		soot_value.text = str(value)


## Set sparks used value
func set_sparks_used(value: int) -> void:
	_ensure_labels_ready()
	if sparks_value:
		sparks_value.text = str(value)


## Set damage dealt value
func set_damage_dealt(value: int) -> void:
	_ensure_labels_ready()
	if damage_value:
		damage_value.text = str(value)
