## Resource definition for world events
## World events are systemic happenings that affect zones and gameplay
extends Resource
class_name WorldEventResource

@export var event_id: String = ""
@export var display_name: String = ""
@export var description: String = ""

## Event type: migration, corruption, invasion, discovery, etc.
@export_enum("migration", "corruption", "invasion", "discovery", "ecological", "weather") var event_type: String = "ecological"

## Which zone(s) this event affects
@export var affected_zones: Array[String] = []

## Event lifecycle phases
@export var incubation_duration: float = 300.0  # Seconds before event becomes active
@export var active_duration: float = 600.0  # How long the event lasts
@export var fallout_duration: float = 300.0  # Lingering effects after resolution

## Trigger conditions
@export var trigger_conditions: Dictionary = {}  # e.g., {"player_level": 5, "zone_visited": true}
@export var can_trigger_multiple_times: bool = false

## Event effects
@export var dna_availability_changes: Dictionary = {}  # {"element_fire": 1.5, "mutation_rare": 0.5}
@export var spawn_rate_modifiers: Dictionary = {}  # {"monster_type": multiplier}
@export var zone_danger_modifier: float = 1.0

## Narrative hooks
@export var narrative_events: Array[Resource] = []  # Links to NarrativeEventResource

## Resolution conditions
@export var auto_resolve: bool = true
@export var player_resolution_required: bool = false
@export var resolution_quest: String = ""

func can_trigger(game_state: Dictionary) -> bool:
	for condition_key in trigger_conditions:
		if not game_state.has(condition_key):
			return false
		if game_state[condition_key] != trigger_conditions[condition_key]:
			return false
	return true
