## Narrative Event Resource - storytelling layer over systemic events
## Provides narrative context to gameplay systems without changing mechanics
extends Resource
class_name NarrativeEventResource

@export var narrative_id: String = ""
@export var title: String = ""
@export_multiline var text: String = ""

## Link to systemic world event
@export var linked_world_event: WorldEventResource = null
@export_enum("incubation", "active", "resolution", "fallout") var trigger_phase: String = "incubation"

## Delivery method
@export_enum("popup", "log", "npc_message", "environment") var delivery_method: String = "log"
@export var priority: int = 1  # Higher priority shown first

## Trigger conditions beyond linked event
@export var additional_conditions: Dictionary = {}
@export var one_time: bool = true

## NPC context
@export var speaker_npc: String = ""  # NPC ID if delivered as message
@export var speaker_portrait: Texture2D = null

## Audio/visual
@export var sound_effect: AudioStream = null
@export var icon: Texture2D = null

## Choices (optional)
@export var presents_choices: bool = false
@export var choices: Array[Dictionary] = []  # {text: String, outcome: String}

func can_trigger(game_state: Dictionary) -> bool:
	for condition_key in additional_conditions:
		if not game_state.has(condition_key):
			return false
		if game_state[condition_key] != additional_conditions[condition_key]:
			return false
	return true
