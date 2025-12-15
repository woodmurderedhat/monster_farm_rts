# Stamina Component - Manages monster stamina/energy for abilities and work
extends Node
class_name StaminaComponent

## Emitted when stamina changes
signal stamina_changed(current: float, maximum: float)

## Emitted when stamina is depleted
signal stamina_depleted

## Emitted when stamina is fully recovered
signal stamina_recovered

## Maximum stamina value
@export var max_stamina: float = 100.0

## Stamina regeneration per second
@export var regen_rate: float = 5.0

## Current stamina value
var current_stamina: float = 100.0

## Whether regeneration is paused
var regen_paused: bool = false

## Reference to parent entity
var entity: Node2D


func _ready() -> void:
	entity = get_parent() as Node2D
	_initialize_from_meta()


func _process(delta: float) -> void:
	if not regen_paused and current_stamina < max_stamina:
		_regenerate(delta)


## Initialize from entity metadata
func _initialize_from_meta() -> void:
	if entity and entity.has_meta("stat_block"):
		var stats: Dictionary = entity.get_meta("stat_block")
		max_stamina = stats.get("max_stamina", max_stamina)
		current_stamina = max_stamina
		regen_rate = stats.get("stamina_regen", regen_rate)


## Consume stamina for an action
## Returns true if successful, false if not enough stamina
func consume(amount: float) -> bool:
	if current_stamina < amount:
		return false
	
	current_stamina -= amount
	stamina_changed.emit(current_stamina, max_stamina)
	
	if current_stamina <= 0:
		stamina_depleted.emit()
	
	return true


## Try to consume stamina, return actual amount consumed
func consume_partial(amount: float) -> float:
	var consumed := minf(amount, current_stamina)
	current_stamina -= consumed
	stamina_changed.emit(current_stamina, max_stamina)
	
	if current_stamina <= 0:
		stamina_depleted.emit()
	
	return consumed


## Add stamina directly
func add_stamina(amount: float) -> void:
	var was_empty := current_stamina <= 0
	current_stamina = minf(current_stamina + amount, max_stamina)
	stamina_changed.emit(current_stamina, max_stamina)
	
	if was_empty and current_stamina > 0:
		stamina_recovered.emit()


## Get stamina as percentage (0-1)
func get_stamina_percent() -> float:
	if max_stamina <= 0:
		return 0.0
	return current_stamina / max_stamina


## Check if entity has enough stamina
func has_stamina(amount: float) -> bool:
	return current_stamina >= amount


## Regenerate stamina over time
func _regenerate(delta: float) -> void:
	var was_below_max := current_stamina < max_stamina
	current_stamina = minf(current_stamina + regen_rate * delta, max_stamina)
	
	if was_below_max:
		stamina_changed.emit(current_stamina, max_stamina)
		
		if current_stamina >= max_stamina:
			stamina_recovered.emit()

