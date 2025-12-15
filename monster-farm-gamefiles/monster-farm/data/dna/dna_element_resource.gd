# DNA Element Resource - Defines elemental affinities and resistances
# Monsters can have 1-3 elements depending on DNACore settings
extends BaseDNAResource
class_name DNAElementResource

## The element type identifier
@export var element_type: String = ""

## Bonus damage dealt with this element (percentage)
@export_range(0.0, 1.0) var damage_bonus: float = 0.0

## Resistance to this element (percentage)
@export_range(0.0, 1.0) var resistance_bonus: float = 0.0

## Status effects this element can apply
## Each resource should be a StatusEffectResource
@export var status_effects: Array[Resource] = []

## Environmental interactions (e.g., "water" -> "extinguish_fire")
## Keys are environment types, values are interaction effects
@export var environmental_interactions: Dictionary = {}


## Get the primary status effect if any
func get_primary_status_effect() -> Resource:
	if status_effects.is_empty():
		return null
	return status_effects[0]


## Check if this element has a specific environmental interaction
func has_environment_interaction(environment: String) -> bool:
	return environmental_interactions.has(environment)


## Get the effect for a specific environment
func get_environment_effect(environment: String) -> String:
	return environmental_interactions.get(environment, "")


## Validate this DNA Element resource
func validate() -> Array[Dictionary]:
	var errors := super.validate()
	
	if element_type.is_empty():
		errors.append({
			"severity": "Error",
			"message": "element_type cannot be empty",
			"source_id": id
		})
	
	if damage_bonus < 0.0 or damage_bonus > 1.0:
		errors.append({
			"severity": "Warning",
			"message": "damage_bonus should be between 0.0 and 1.0",
			"source_id": id
		})
	
	if resistance_bonus < 0.0 or resistance_bonus > 1.0:
		errors.append({
			"severity": "Warning",
			"message": "resistance_bonus should be between 0.0 and 1.0",
			"source_id": id
		})
	
	return errors

