## World Event Manager - handles dynamic world events
## Events affect zones, DNA availability, and create emergent narratives
extends Node
class_name WorldEventManager

const WorldEventResourceScript = preload("res://data/world_event_resource.gd")

signal event_triggered(event: WorldEventResource)
signal event_phase_changed(event: WorldEventResource, new_phase: String)
signal event_resolved(event: WorldEventResource)

@export var event_check_interval: float = 60.0  # Check for new events every minute
@export var max_concurrent_events: int = 3

## Active events and their states
var active_events: Array[Dictionary] = []  # {event: Resource, phase: String, time_in_phase: float}
var resolved_events: Array[String] = []  # IDs of events that have already happened
var available_events: Array[WorldEventResource] = []

var time_since_check: float = 0.0

func _ready() -> void:
	_load_event_catalog()
	set_process(true)

func _process(delta: float) -> void:
	_update_active_events(delta)
	
	time_since_check += delta
	if time_since_check >= event_check_interval:
		_check_for_new_events()
		time_since_check = 0.0

## Load all world event resources from data directory
func _load_event_catalog() -> void:
	var events_path = "res://data/world_events/"
	if not DirAccess.dir_exists_absolute(events_path):
		push_warning("World events directory not found: " + events_path)
		return

	var dir := DirAccess.open(events_path)
	if dir == null:
		push_warning("Failed to open world events dir: " + events_path)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var res := load(events_path + file_name) as WorldEventResource
			if res and res not in available_events:
				available_events.append(res)
		file_name = dir.get_next()

## Register an event resource
func register_event(event: WorldEventResource) -> void:
	if event not in available_events:
		available_events.append(event)

## Update all active events
func _update_active_events(delta: float) -> void:
	var events_to_remove = []
	
	for event_data in active_events:
		event_data.time_in_phase += delta
		var event: WorldEventResource = event_data.event
		var phase: String = event_data.phase
		
		# Check for phase transition
		match phase:
			"incubation":
				if event_data.time_in_phase >= event.incubation_duration:
					_transition_event_phase(event_data, "active")
			
			"active":
				if event_data.time_in_phase >= event.active_duration:
					if event.auto_resolve:
						_transition_event_phase(event_data, "fallout")
					else:
						# Requires player action to resolve
						pass
			
			"fallout":
				if event_data.time_in_phase >= event.fallout_duration:
					events_to_remove.append(event_data)
	
	# Remove completed events
	for event_data in events_to_remove:
		_resolve_event(event_data)

## Transition an event to a new phase
func _transition_event_phase(event_data: Dictionary, new_phase: String) -> void:
	event_data.phase = new_phase
	event_data.time_in_phase = 0.0
	
	var event: WorldEventResource = event_data.event
	event_phase_changed.emit(event, new_phase)
	
	# Apply phase-specific effects
	match new_phase:
		"active":
			_apply_event_effects(event)
		"fallout":
			_remove_event_effects(event)

## Check if new events should trigger
func _check_for_new_events() -> void:
	if active_events.size() >= max_concurrent_events:
		return
	
	var game_state = _get_game_state()
	
	for event in available_events:
		# Skip if already active
		if _is_event_active(event):
			continue
		
		# Skip if already resolved and can't repeat
		if event.event_id in resolved_events and not event.can_trigger_multiple_times:
			continue
		
		# Check trigger conditions
		if event.can_trigger(game_state):
			_trigger_event(event)
			break  # Only trigger one event per check

## Trigger a new event
func _trigger_event(event: WorldEventResource) -> void:
	var event_data = {
		"event": event,
		"phase": "incubation",
		"time_in_phase": 0.0
	}
	
	active_events.append(event_data)
	event_triggered.emit(event)
	
	# Notify EventBus
	EventBus.world_event_triggered.emit(event)

## Apply event effects to world state
func _apply_event_effects(event: WorldEventResource) -> void:
	# Modify DNA availability in affected zones
	for zone_id in event.affected_zones:
		EventBus.zone_dna_availability_changed.emit(zone_id, event.dna_availability_changes)
	
	# Modify spawn rates
	if not event.spawn_rate_modifiers.is_empty():
		EventBus.spawn_rates_modified.emit(event.spawn_rate_modifiers)

## Remove event effects when event ends
func _remove_event_effects(event: WorldEventResource) -> void:
	# Revert DNA availability changes
	var inverse_changes = {}
	for key in event.dna_availability_changes:
		inverse_changes[key] = 1.0 / event.dna_availability_changes[key]
	
	for zone_id in event.affected_zones:
		EventBus.zone_dna_availability_changed.emit(zone_id, inverse_changes)

## Resolve an event
func _resolve_event(event_data: Dictionary) -> void:
	var event: WorldEventResource = event_data.event
	active_events.erase(event_data)
	
	if event.event_id not in resolved_events:
		resolved_events.append(event.event_id)
	
	event_resolved.emit(event)
	EventBus.world_event_resolved.emit(event)

## Check if event is currently active
func _is_event_active(event: WorldEventResource) -> bool:
	for event_data in active_events:
		if event_data.event == event:
			return true
	return false

## Get current game state for event evaluation
func _get_game_state() -> Dictionary:
	if not GameState:
		return {}

	# GameState exposes player progression in `player_state` dict (level under "level").
	var player_level := 1
	if GameState.has_method("get"):
		# safe get: attempt to read property; if missing, fall back to defaults
		var maybe_level = null
		# Try direct property first (for backwards compatibility)
		if GameState.has_meta("player_level"):
			maybe_level = GameState.get_meta("player_level")
		else:
			# Check player_state dictionary
			if GameState.has("player_state"):
				var ps = GameState.get("player_state")
				if ps and typeof(ps) == TYPE_DICTIONARY and ps.has("level"):
					maybe_level = ps["level"]
		if maybe_level != null:
			player_level = maybe_level

	return {
		"player_level": player_level,
		"zones_visited": (GameState.zones_visited if GameState.has("zones_visited") else []),
		"monsters_owned": ((GameState.owned_monsters.size() if GameState.has("owned_monsters") else 0)),
		"current_zone": (GameState.current_zone if GameState.has("current_zone") else "")
	}

## Player resolves an event manually
func resolve_event_by_player(event: WorldEventResource) -> bool:
	for event_data in active_events:
		if event_data.event == event:
			_transition_event_phase(event_data, "fallout")
			return true
	return false

## Get all active events
func get_active_events() -> Array[WorldEventResource]:
	var events: Array[WorldEventResource] = []
	for event_data in active_events:
		events.append(event_data.event)
	return events

## Get events in specific phase
func get_events_in_phase(phase: String) -> Array[WorldEventResource]:
	var events: Array[WorldEventResource] = []
	for event_data in active_events:
		if event_data.phase == phase:
			events.append(event_data.event)
	return events
