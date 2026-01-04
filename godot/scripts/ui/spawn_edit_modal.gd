extends Control
class_name SpawnEditModal
## Modal dialog for editing enemy spawn rules for a specific spawn point


signal rules_changed(spawn_index: int, rules: Array[SpawnEnemyRule])
signal spawn_deleted(spawn_index: int)
signal closed


@onready var background: ColorRect = $Background
@onready var panel: PanelContainer = $Panel
@onready var title_label: Label = $Panel/MarginContainer/VBoxContainer/TitleLabel
@onready var enemy_row_list: VBoxContainer = $Panel/MarginContainer/VBoxContainer/ScrollContainer/EnemyRowList
@onready var add_enemy_button: Button = $Panel/MarginContainer/VBoxContainer/ButtonRow/AddEnemyButton
@onready var close_button: Button = $Panel/MarginContainer/VBoxContainer/ButtonRow/CloseButton
@onready var delete_spawn_button: Button = $Panel/MarginContainer/VBoxContainer/DeleteSpawnButton


## Current spawn point index being edited
var current_spawn_index: int = -1

## Current spawn point position
var current_spawn_pos: Vector2i = Vector2i.ZERO

## Current rules being edited (local copy)
var current_rules: Array[SpawnEnemyRule] = []


func _ready() -> void:
	hide()
	
	# Connect button signals
	add_enemy_button.pressed.connect(_on_add_enemy_pressed)
	close_button.pressed.connect(_on_close_pressed)
	delete_spawn_button.pressed.connect(_on_delete_spawn_pressed)
	
	# Connect background click to close modal
	background.gui_input.connect(_on_background_input)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event.is_action_pressed("ui_cancel"):
		_on_close_pressed()
		get_viewport().set_input_as_handled()


func _on_background_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_close_pressed()


## Show the modal for a specific spawn point
func show_for_spawn_point(spawn_index: int, spawn_pos: Vector2i, rules: Array[SpawnEnemyRule]) -> void:
	current_spawn_index = spawn_index
	current_spawn_pos = spawn_pos
	
	# Deep copy rules to avoid modifying originals
	current_rules.clear()
	for rule in rules:
		var new_rule := SpawnEnemyRule.new()
		new_rule.spawn_point_index = rule.spawn_point_index
		new_rule.enemy_type = rule.enemy_type
		new_rule.spawn_delay = rule.spawn_delay
		new_rule.spawn_count = rule.spawn_count
		new_rule.spawn_time = rule.spawn_time
		current_rules.append(new_rule)
	
	# Update title
	title_label.text = "Edit Spawn (%d, %d)" % [spawn_pos.x, spawn_pos.y]
	
	# Rebuild UI
	_rebuild_enemy_rows()
	
	show()
	add_enemy_button.grab_focus()


## Hide the modal
func hide_modal() -> void:
	hide()
	closed.emit()


## Rebuild the enemy row list UI from current rules
func _rebuild_enemy_rows() -> void:
	# Clear existing rows
	for child in enemy_row_list.get_children():
		child.queue_free()
	
	# Create a row for each rule
	for i in range(current_rules.size()):
		var rule := current_rules[i]
		var row := _create_enemy_row(i, rule)
		enemy_row_list.add_child(row)


## Create a single enemy row UI
func _create_enemy_row(index: int, rule: SpawnEnemyRule) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "EnemyRow_%d" % index
	row.add_theme_constant_override("separation", 4)
	
	# Enemy type dropdown
	var type_option := OptionButton.new()
	type_option.name = "TypeOption"
	type_option.custom_minimum_size = Vector2(60, 24)
	type_option.add_item("Basic", SpawnEnemyRule.EnemyType.BASIC)
	type_option.add_item("Fast", SpawnEnemyRule.EnemyType.FAST)
	type_option.add_item("Tank", SpawnEnemyRule.EnemyType.TANK)
	type_option.select(rule.enemy_type)
	type_option.item_selected.connect(func(id): _on_type_changed(index, id))
	row.add_child(type_option)
	
	# Delay input
	var delay_spin := SpinBox.new()
	delay_spin.name = "DelaySpin"
	delay_spin.custom_minimum_size = Vector2(50, 24)
	delay_spin.min_value = 0.0
	delay_spin.max_value = 999.0
	delay_spin.step = 0.5
	delay_spin.value = rule.spawn_delay
	delay_spin.suffix = "s"
	delay_spin.value_changed.connect(func(val): _on_delay_changed(index, val))
	row.add_child(delay_spin)
	
	# Count input
	var count_spin := SpinBox.new()
	count_spin.name = "CountSpin"
	count_spin.custom_minimum_size = Vector2(50, 24)
	count_spin.min_value = 1
	count_spin.max_value = 100
	count_spin.step = 1
	count_spin.value = rule.spawn_count
	count_spin.value_changed.connect(func(val): _on_count_changed(index, int(val)))
	row.add_child(count_spin)
	
	# Time input
	var time_spin := SpinBox.new()
	time_spin.name = "TimeSpin"
	time_spin.custom_minimum_size = Vector2(50, 24)
	time_spin.min_value = 1.0
	time_spin.max_value = 999.0
	time_spin.step = 1.0
	time_spin.value = rule.spawn_time
	time_spin.suffix = "s"
	time_spin.value_changed.connect(func(val): _on_time_changed(index, val))
	row.add_child(time_spin)
	
	# Delete button
	var delete_btn := Button.new()
	delete_btn.name = "DeleteBtn"
	delete_btn.custom_minimum_size = Vector2(24, 24)
	delete_btn.text = "X"
	delete_btn.pressed.connect(func(): _on_delete_row(index))
	row.add_child(delete_btn)
	
	return row


## Handle enemy type change
func _on_type_changed(index: int, type_id: int) -> void:
	if index >= 0 and index < current_rules.size():
		current_rules[index].enemy_type = type_id as SpawnEnemyRule.EnemyType
		_emit_rules_changed()


## Handle spawn delay change
func _on_delay_changed(index: int, value: float) -> void:
	if index >= 0 and index < current_rules.size():
		current_rules[index].spawn_delay = value
		_emit_rules_changed()


## Handle spawn count change
func _on_count_changed(index: int, value: int) -> void:
	if index >= 0 and index < current_rules.size():
		current_rules[index].spawn_count = value
		_emit_rules_changed()


## Handle spawn time change
func _on_time_changed(index: int, value: float) -> void:
	if index >= 0 and index < current_rules.size():
		current_rules[index].spawn_time = value
		_emit_rules_changed()


## Handle delete row button
func _on_delete_row(index: int) -> void:
	if index >= 0 and index < current_rules.size():
		current_rules.remove_at(index)
		_rebuild_enemy_rows()
		_emit_rules_changed()


## Handle add enemy button
func _on_add_enemy_pressed() -> void:
	AudioManager.play_ui_click()
	
	var new_rule := SpawnEnemyRule.new()
	new_rule.spawn_point_index = current_spawn_index
	new_rule.enemy_type = SpawnEnemyRule.EnemyType.BASIC
	new_rule.spawn_delay = 0.0
	new_rule.spawn_count = 6
	new_rule.spawn_time = 60.0
	
	current_rules.append(new_rule)
	_rebuild_enemy_rows()
	_emit_rules_changed()


## Handle close button
func _on_close_pressed() -> void:
	AudioManager.play_ui_click()
	hide_modal()


## Handle delete spawn button
func _on_delete_spawn_pressed() -> void:
	AudioManager.play_ui_click()
	spawn_deleted.emit(current_spawn_index)
	hide_modal()


## Emit the rules_changed signal with current rules
func _emit_rules_changed() -> void:
	rules_changed.emit(current_spawn_index, current_rules.duplicate())
