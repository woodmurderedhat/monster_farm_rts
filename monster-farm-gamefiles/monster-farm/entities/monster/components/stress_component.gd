# Stress Component - Manages monster stress and happiness
# High stress affects work efficiency and can cause negative behaviors
extends Node
class_name StressComponent

## Emitted when stress changes
signal stress_changed(current: float, maximum: float)

## Emitted when stress reaches critical level
signal stress_critical

## Emitted when monster becomes happy (low stress)
signal became_happy

## Maximum stress before breakdown
@export var max_stress: float = 100.0

## Stress decay rate per second (when not stressed)
@export var decay_rate: float = 1.0

## Current stress level
var current_stress: float = 0.0

## Stress tolerance from DNA (affects thresholds)
var stress_tolerance: float = 0.5

## Reference to parent entity
var entity: Node2D


func _ready() -> void:
	entity = get_parent() as Node2D
	_initialize_from_meta()


func _process(delta: float) -> void:
	if current_stress > 0:
		_decay_stress(delta)


## Initialize from entity metadata
func _initialize_from_meta() -> void:
	if entity and entity.has_meta("ai_config"):
		var config: Dictionary = entity.get_meta("ai_config")
		stress_tolerance = config.get("stress_tolerance", stress_tolerance)
		# Higher tolerance = more max stress before breakdown
		max_stress = 100.0 * (0.5 + stress_tolerance)


## Add stress from an event
func add_stress(amount: float) -> void:
	var was_happy := is_happy()
	
	# Tolerance reduces stress gain
	var actual_amount := amount * (1.0 - stress_tolerance * 0.5)
	current_stress = minf(current_stress + actual_amount, max_stress)
	
	stress_changed.emit(current_stress, max_stress)
	
	if is_critical() and was_happy:
		stress_critical.emit()


## Reduce stress directly (from rest, food, etc.)
func reduce_stress(amount: float) -> void:
	var was_critical := is_critical()
	current_stress = maxf(0, current_stress - amount)
	stress_changed.emit(current_stress, max_stress)
	
	if was_critical and is_happy():
		became_happy.emit()


## Get stress as percentage (0-1)
func get_stress_percent() -> float:
	if max_stress <= 0:
		return 0.0
	return current_stress / max_stress


## Check if stress is at critical level (>80%)
func is_critical() -> bool:
	return get_stress_percent() > 0.8


## Check if monster is happy (stress <20%)
func is_happy() -> bool:
	return get_stress_percent() < 0.2


## Get work efficiency modifier based on stress
## Returns 0.5-1.0 (50%-100% efficiency)
func get_work_efficiency() -> float:
	var stress_percent := get_stress_percent()
	return 1.0 - (stress_percent * 0.5)


## Decay stress over time
func _decay_stress(delta: float) -> void:
	if current_stress <= 0:
		return
	
	var was_critical := is_critical()
	current_stress = maxf(0, current_stress - decay_rate * delta)
	stress_changed.emit(current_stress, max_stress)
	
	if was_critical and is_happy():
		became_happy.emit()

