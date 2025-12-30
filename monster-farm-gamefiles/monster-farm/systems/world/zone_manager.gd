## Zone Manager - handles world zones, biomes, and exploration
## Manages zone state, DNA spawning, and player progression through the world
extends Node
class_name ZoneManager

signal zone_entered(zone_id: String)
signal zone_unlocked(zone_id: String)
signal zone_state_changed(zone_id: String, state: Dictionary)

## Zone state tracking
var zone_states: Dictionary = {}  # zone_id -> {unlocked, visited, corruption, DNA_availability, etc}
var current_zone: String = ""
var unlocked_zones: Array[String] = []

func _ready() -> void:
	_initialize_zones()

## Initialize default zone states
func _initialize_zones() -> void:
	# Starting zone is always unlocked
	unlock_zone("starter_plains")

## Create default state for a zone
func _create_default_zone_state(_zone_id: String) -> Dictionary:
	return {
		"unlocked": false,
		"visited": false,
		"corruption_level": 0.0,
		"danger_level": 1.0,
		"dna_availability": {},  # Populated by biome data
		"active_modifiers": [],
		"discovered_locations": [],
		"monsters_encountered": []
	}

## Unlock a new zone
func unlock_zone(zone_id: String) -> void:
	if zone_id not in unlocked_zones:
		unlocked_zones.append(zone_id)
	
	if not zone_states.has(zone_id):
		zone_states[zone_id] = _create_default_zone_state(zone_id)
	
	zone_states[zone_id].unlocked = true
	zone_unlocked.emit(zone_id)
	EventBus.zone_unlocked.emit(zone_id)

## Enter a zone (player travels to it)
func enter_zone(zone_id: String) -> bool:
	if zone_id not in unlocked_zones:
		push_warning("Attempted to enter locked zone: " + zone_id)
		return false
	
	current_zone = zone_id
	
	if not zone_states[zone_id].visited:
		zone_states[zone_id].visited = true
		_on_first_visit(zone_id)
	
	zone_entered.emit(zone_id)
	EventBus.zone_entered.emit(zone_id)
	
	# Update GameState
	if GameState:
		GameState.current_zone = zone_id
	
	return true

## Handle first visit to a zone
func _on_first_visit(zone_id: String) -> void:
	# Trigger discovery events, unlock adjacent zones, etc.
	EventBus.zone_discovered.emit(zone_id)

## Get zone state
func get_zone_state(zone_id: String) -> Dictionary:
	if zone_states.has(zone_id):
		return zone_states[zone_id]
	return _create_default_zone_state(zone_id)

## Modify zone corruption
func modify_corruption(zone_id: String, amount: float) -> void:
	if not zone_states.has(zone_id):
		return
	
	zone_states[zone_id].corruption_level = clamp(
		zone_states[zone_id].corruption_level + amount,
		0.0,
		1.0
	)
	
	zone_state_changed.emit(zone_id, zone_states[zone_id])
	EventBus.zone_corruption_changed.emit(zone_id, zone_states[zone_id].corruption_level)

## Modify DNA availability in a zone (from world events)
func modify_dna_availability(zone_id: String, modifiers: Dictionary) -> void:
	if not zone_states.has(zone_id):
		return
	
	for dna_type in modifiers:
		if not zone_states[zone_id].dna_availability.has(dna_type):
			zone_states[zone_id].dna_availability[dna_type] = 1.0
		
		zone_states[zone_id].dna_availability[dna_type] *= modifiers[dna_type]
	
	zone_state_changed.emit(zone_id, zone_states[zone_id])

## Get DNA drop rate multiplier for a specific DNA type in current zone
func get_dna_drop_multiplier(dna_id: String) -> float:
	if current_zone.is_empty() or not zone_states.has(current_zone):
		return 1.0
	
	var availability = zone_states[current_zone].dna_availability
	return availability.get(dna_id, 1.0)

## Check if zone is unlocked
func is_zone_unlocked(zone_id: String) -> bool:
	return zone_id in unlocked_zones

## Get all unlocked zones
func get_unlocked_zones() -> Array[String]:
	return unlocked_zones.duplicate()

## Get current zone
func get_current_zone() -> String:
	return current_zone

## Record monster encounter in zone
func record_monster_encounter(zone_id: String, monster_id: String) -> void:
	if not zone_states.has(zone_id):
		return
	
	if monster_id not in zone_states[zone_id].monsters_encountered:
		zone_states[zone_id].monsters_encountered.append(monster_id)

## Serialize zone states for saving
func serialize() -> Dictionary:
	return {
		"zone_states": zone_states,
		"current_zone": current_zone,
		"unlocked_zones": unlocked_zones
	}

## Deserialize zone states from save data
func deserialize(data: Dictionary) -> void:
	zone_states = data.get("zone_states", {})
	current_zone = data.get("current_zone", "")
	unlocked_zones = data.get("unlocked_zones", [])
