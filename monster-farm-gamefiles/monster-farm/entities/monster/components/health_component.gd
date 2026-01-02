# Health Component - Manages monster health and damage
extends Node
class_name HealthComponent

## Emitted when health changes
signal health_changed(current: float, maximum: float)

## Emitted when the entity takes damage
signal damage_taken(amount: float, source: Node)

## Emitted when the entity is healed
signal healed(amount: float, source: Node)

## Emitted when health reaches zero
signal died

## Maximum health value
@export var max_health: float = 100.0

## Current health value
var current_health: float = 100.0

## Whether the entity is invulnerable
var is_invulnerable: bool = false

## Reference to parent entity
var entity: Node2D


func _ready() -> void:
	entity = get_parent() as Node2D
	_initialize_from_meta()
	print("[DEBUG] HealthComponent initialized for node: %s" % get_parent().name)
	print("[DEBUG] Parent Node Children:")
	for child in get_parent().get_children():
		print("[DEBUG] Child: %s (Type: %s)" % [child, child.get_class()])


## Initialize health from entity metadata (set by MonsterAssembler)
func _initialize_from_meta() -> void:
	if entity and entity.has_meta("stat_block"):
		var stats: Dictionary = entity.get_meta("stat_block")
		max_health = stats.get("max_health", max_health)
		current_health = max_health


## Take damage from a source
func take_damage(amount: float, source: Node = null) -> void:
	if is_invulnerable or current_health <= 0:
		print("[DEBUG] Damage ignored: Invulnerable or health already 0.")
		return
	
	var actual_damage := maxf(0, amount)
	current_health = maxf(0, current_health - actual_damage)
	print("[DEBUG] Damage taken: %.2f, Current Health: %.2f" % [actual_damage, current_health])
	
	damage_taken.emit(actual_damage, source)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		_on_death()


## Heal the entity
func heal(amount: float, source: Node = null) -> void:
	if current_health <= 0:
		return
	
	var actual_heal := minf(amount, max_health - current_health)
	current_health += actual_heal
	
	healed.emit(actual_heal, source)
	health_changed.emit(current_health, max_health)


## Set health directly (for initialization or special cases)
func set_health(value: float) -> void:
	current_health = clampf(value, 0, max_health)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		_on_death()


## Get health as a percentage (0-1)
func get_health_percent() -> float:
	if max_health <= 0:
		return 0.0
	return current_health / max_health


## Check if alive
func is_alive() -> bool:
	return current_health > 0


## Handle death
func _on_death() -> void:
	died.emit()

