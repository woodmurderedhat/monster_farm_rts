# Needs Component - Tracks monster needs that influence behavior
extends Node
class_name NeedsComponent

## Emitted when a need becomes critical
signal need_critical(need_name: String)

## Emitted when a need is satisfied
signal need_satisfied(need_name: String)

## Need values (0-100, higher = more satisfied)
var needs: Dictionary = {
	"hunger": 100.0,
	"rest": 100.0,
	"safety": 100.0,
	"social": 50.0,
	"purpose": 50.0
}

## Decay rates per second
var decay_rates: Dictionary = {
	"hunger": 0.5,
	"rest": 0.3,
	"safety": 0.0,  # Only changes from events
	"social": 0.1,
	"purpose": 0.2
}

## Critical threshold (below this, need is urgent)
var critical_threshold: float = 20.0

## Reference to parent entity
var entity: Node2D


func _ready() -> void:
	entity = get_parent() as Node2D


func _process(delta: float) -> void:
	_decay_needs(delta)


## Get a need value
func get_need(need_name: String) -> float:
	return needs.get(need_name, 50.0)


## Set a need value
func set_need(need_name: String, value: float) -> void:
	var was_critical := is_critical(need_name)
	needs[need_name] = clampf(value, 0.0, 100.0)
	
	if not was_critical and is_critical(need_name):
		need_critical.emit(need_name)
	elif was_critical and not is_critical(need_name):
		need_satisfied.emit(need_name)


## Add to a need value
func add_need(need_name: String, amount: float) -> void:
	set_need(need_name, get_need(need_name) + amount)


## Check if a need is critical
func is_critical(need_name: String) -> bool:
	return get_need(need_name) < critical_threshold


## Get the most urgent need
func get_most_urgent_need() -> String:
	var lowest_value := 100.0
	var most_urgent := ""
	
	for need_name in needs:
		if needs[need_name] < lowest_value:
			lowest_value = needs[need_name]
			most_urgent = need_name
	
	return most_urgent


## Get urgency score for a need (higher = more urgent)
func get_urgency(need_name: String) -> float:
	var value := get_need(need_name)
	# Inverse and scale: 0 need = 100 urgency, 100 need = 0 urgency
	return 100.0 - value


## Decay needs over time
func _decay_needs(delta: float) -> void:
	for need_name in decay_rates:
		var rate: float = decay_rates[need_name]
		if rate > 0:
			add_need(need_name, -rate * delta)


## Satisfy hunger (from eating)
func feed(amount: float) -> void:
	add_need("hunger", amount)


## Satisfy rest (from sleeping/resting)
func rest(amount: float) -> void:
	add_need("rest", amount)


## Satisfy social (from interaction)
func socialize(amount: float) -> void:
	add_need("social", amount)


## Satisfy purpose (from completing preferred work)
func fulfill_purpose(amount: float) -> void:
	add_need("purpose", amount)


## Set safety level (from environment)
func set_safety(value: float) -> void:
	set_need("safety", value)

