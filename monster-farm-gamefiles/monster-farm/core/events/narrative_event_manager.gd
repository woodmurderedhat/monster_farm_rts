## Narrative Event Manager - delivers story moments without breaking flow
## Reacts to world events and provides context through various channels
extends Node
class_name NarrativeEventManager

signal narrative_event_triggered(event: NarrativeEventResource)
signal narrative_choice_made(event: NarrativeEventResource, choice_index: int)

var triggered_events: Array[String] = []  # IDs of one-time events already shown
var event_queue: Array[NarrativeEventResource] = []
var available_narratives: Array[NarrativeEventResource] = []

func _ready() -> void:
	_connect_to_event_bus()
	_load_narrative_catalog()

## Connect to EventBus signals to react to world changes
func _connect_to_event_bus() -> void:
	if EventBus.has_signal("world_event_triggered"):
		EventBus.world_event_triggered.connect(_on_world_event_triggered)
	
	if EventBus.has_signal("zone_discovered"):
		EventBus.zone_discovered.connect(_on_zone_discovered)
	
	if EventBus.has_signal("monster_spawned"):
		EventBus.monster_spawned.connect(_on_monster_spawned)

## Load narrative event catalog
func _load_narrative_catalog() -> void:
	var narrative_path = "res://data/narratives/"
	if not DirAccess.dir_exists_absolute(narrative_path):
		push_warning("Narrative events directory not found: " + narrative_path)
		return
	
	# TODO: Load .tres files from narratives directory

## Register a narrative event
func register_narrative(event: NarrativeEventResource) -> void:
	if event not in available_narratives:
		available_narratives.append(event)

## React to world events triggering
func _on_world_event_triggered(world_event: WorldEventResource) -> void:
	_check_linked_narratives(world_event, "incubation")

## Check for narratives linked to a world event in a specific phase
func _check_linked_narratives(world_event: WorldEventResource, phase: String) -> void:
	for narrative in available_narratives:
		# Skip if already triggered and is one-time
		if narrative.one_time and narrative.narrative_id in triggered_events:
			continue
		
		# Check if linked to this world event
		if narrative.linked_world_event == world_event:
			if narrative.trigger_phase == phase:
				_trigger_narrative(narrative)

## React to zone discovery
func _on_zone_discovered(zone_id: String) -> void:
	var game_state = _get_game_state()
	game_state["discovered_zone"] = zone_id
	
	for narrative in available_narratives:
		if narrative.one_time and narrative.narrative_id in triggered_events:
			continue
		
		if narrative.can_trigger(game_state):
			_trigger_narrative(narrative)

## React to monster spawning (for discovery events)
func _on_monster_spawned(monster: Node) -> void:
	var _game_state = _get_game_state()
	
	# Check for unique DNA combinations
	if monster.has_meta("dna_stack"):
		var _stack = monster.get_meta("dna_stack")
		# TODO: Check for rare/unique combinations
		pass

## Trigger a narrative event
func _trigger_narrative(event: NarrativeEventResource) -> void:
	# Add to queue if not already queued
	if event not in event_queue:
		event_queue.append(event)
	
	# Sort queue by priority
	event_queue.sort_custom(func(a, b): return a.priority > b.priority)
	
	# Deliver highest priority event
	if not event_queue.is_empty():
		_deliver_narrative(event_queue[0])
		event_queue.remove_at(0)
	
	# Mark as triggered if one-time
	if event.one_time and event.narrative_id not in triggered_events:
		triggered_events.append(event.narrative_id)

## Deliver a narrative event via specified method
func _deliver_narrative(event: NarrativeEventResource) -> void:
	narrative_event_triggered.emit(event)
	
	match event.delivery_method:
		"popup":
			_show_popup(event)
		"log":
			_add_to_event_log(event)
		"npc_message":
			_show_npc_message(event)
		"environment":
			_trigger_environmental_effect(event)

## Show popup notification
func _show_popup(event: NarrativeEventResource) -> void:
	# Emit signal for UI to handle
	EventBus.narrative_popup_requested.emit({
		"title": event.title,
		"text": event.text,
		"icon": event.icon,
		"choices": event.choices if event.presents_choices else []
	})

## Add to event log (non-intrusive)
func _add_to_event_log(event: NarrativeEventResource) -> void:
	EventBus.log_message_added.emit({
		"timestamp": Time.get_ticks_msec(),
		"title": event.title,
		"text": event.text,
		"category": "narrative"
	})

## Show NPC message
func _show_npc_message(event: NarrativeEventResource) -> void:
	EventBus.npc_message_received.emit({
		"npc_id": event.speaker_npc,
		"portrait": event.speaker_portrait,
		"message": event.text,
		"title": event.title
	})

## Trigger environmental narrative effect
func _trigger_environmental_effect(_event: NarrativeEventResource) -> void:
	# Could spawn visual effects, change ambiance, etc.
	pass

## Player makes a choice from a narrative event
func make_choice(event: NarrativeEventResource, choice_index: int) -> void:
	if choice_index < 0 or choice_index >= event.choices.size():
		return
	
	var choice = event.choices[choice_index]
	narrative_choice_made.emit(event, choice_index)
	
	# Handle choice outcome
	if choice.has("outcome"):
		_apply_choice_outcome(choice.outcome)

## Apply the outcome of a narrative choice
func _apply_choice_outcome(_outcome: String) -> void:
	# Parse and apply outcome effects
	# This could modify game state, trigger events, etc.
	pass

## Get game state for condition checking
func _get_game_state() -> Dictionary:
	if not GameState:
		return {}

	var level: int = 1
	if GameState.player_state.has("level"):
		level = int(GameState.player_state["level"])

	return {
		"player_level": level,
		"zones_visited": GameState.zones_visited,
		"monsters_owned": GameState.owned_monsters.size(),
		"current_zone": GameState.current_zone
	}

## Serialize for save system
func serialize() -> Dictionary:
	return {
		"triggered_events": triggered_events
	}

## Deserialize from save data
func deserialize(data: Dictionary) -> void:
	triggered_events = data.get("triggered_events", [])
