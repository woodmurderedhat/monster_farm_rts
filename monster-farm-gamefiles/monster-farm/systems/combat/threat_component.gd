# Threat Component - Tracks and manages threat/aggro for a monster
extends Node
class_name ThreatComponent

## Threat table: entity -> threat value
var threat_table: Dictionary = {}

## Threat decay per second
@export var threat_decay_rate: float = 5.0

## Base threat from proximity
@export var proximity_threat_base: float = 10.0

## Reference to parent entity
var entity: Node2D


func _ready() -> void:
	entity = get_parent() as Node2D


func _process(delta: float) -> void:
	_decay_threat(delta)


## Add threat from damage
func add_damage_threat(source: Node2D, damage: float) -> void:
	if not is_instance_valid(source):
		return
	
	var current: float = threat_table.get(source, 0.0)
	threat_table[source] = current + damage


## Add threat from taunt
func add_taunt_threat(source: Node2D, amount: float) -> void:
	if not is_instance_valid(source):
		return
	
	var current: float = threat_table.get(source, 0.0)
	threat_table[source] = current + amount


## Add threat from proximity
func add_proximity_threat(source: Node2D, distance: float) -> void:
	if not is_instance_valid(source):
		return
	
	# Closer = more threat
	var threat := proximity_threat_base * (1.0 - clampf(distance / 500.0, 0.0, 1.0))
	var current: float = threat_table.get(source, 0.0)
	threat_table[source] = current + threat


## Get threat value for an entity
func get_threat(target: Node2D) -> float:
	return threat_table.get(target, 0.0)


## Get the highest threat target
func get_highest_threat_target() -> Node2D:
	var highest_threat := 0.0
	var highest_target: Node2D = null
	
	for target in threat_table:
		if not is_instance_valid(target):
			continue
		
		var threat: float = threat_table[target]
		if threat > highest_threat:
			highest_threat = threat
			highest_target = target
	
	return highest_target


## Get all entities with threat, sorted by threat (highest first)
func get_sorted_threats() -> Array:
	var sorted: Array = []
	
	for target in threat_table:
		if is_instance_valid(target) and threat_table[target] > 0:
			sorted.append({"target": target, "threat": threat_table[target]})
	
	sorted.sort_custom(func(a, b): return a.threat > b.threat)
	return sorted


## Clear threat for an entity
func clear_threat(target: Node2D) -> void:
	threat_table.erase(target)


## Clear all threat
func clear_all_threat() -> void:
	threat_table.clear()


## Decay threat over time
func _decay_threat(delta: float) -> void:
	var to_remove: Array = []
	
	for target in threat_table:
		if not is_instance_valid(target):
			to_remove.append(target)
			continue
		
		threat_table[target] -= threat_decay_rate * delta
		if threat_table[target] <= 0:
			to_remove.append(target)
	
	for target in to_remove:
		threat_table.erase(target)

