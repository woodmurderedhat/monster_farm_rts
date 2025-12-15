# Base DNA Resource - All DNA types inherit from this
# Contains shared fields for identification, rarity, tags, and modifiers
extends Resource
class_name BaseDNAResource

## Unique identifier for this DNA part
@export var id: String

## Display name shown in UI
@export var display_name: String

## Detailed description of this DNA part
@export_multiline var description: String

## Rarity tier affecting drop rates and power budget
@export_enum("Common", "Uncommon", "Rare", "Epic", "Legendary")
var rarity: int = 0

## Tags for categorization and compatibility checks
@export var tags: Array[String] = []

## Tags that cannot coexist with this DNA part
@export var incompatible_tags: Array[String] = []

## Stat modifiers applied when this DNA is active
## Keys are stat names (e.g., "health", "speed"), values are modifier amounts
@export var stat_modifiers: Dictionary = {}

## AI behavior modifiers
## Keys are AI parameter names, values are modifier amounts
@export var ai_modifiers: Dictionary = {}

## Visual modifiers for monster appearance
## Keys are visual property names, values are modification data
@export var visual_modifiers: Dictionary = {}


## Check if this DNA part is compatible with a set of tags
func is_compatible_with_tags(other_tags: Array[String]) -> bool:
	for tag in incompatible_tags:
		if tag in other_tags:
			return false
	return true


## Get all tags including inherited ones
func get_all_tags() -> Array[String]:
	return tags.duplicate()


## Get a stat modifier value, returns 0 if not found
func get_stat_modifier(stat_name: String) -> float:
	return stat_modifiers.get(stat_name, 0.0)


## Get an AI modifier value, returns 0 if not found
func get_ai_modifier(ai_param: String) -> float:
	return ai_modifiers.get(ai_param, 0.0)


## Validate this individual DNA resource
## Override in subclasses for specific validation
func validate() -> Array[Dictionary]:
	var errors: Array[Dictionary] = []
	
	if id.is_empty():
		errors.append({
			"severity": "Error",
			"message": "DNA id cannot be empty",
			"source_id": id
		})
	
	if display_name.is_empty():
		errors.append({
			"severity": "Warning",
			"message": "DNA display_name is empty",
			"source_id": id
		})
	
	return errors

