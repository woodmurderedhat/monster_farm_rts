# DNA Mutation Resource - Defines unstable or rule-breaking modifiers
# Mutations can override normal validation rules and force visual changes
@tool
extends BaseDNAResource
class_name DNAMutationResource

## Type of mutation affecting how it's treated
@export_enum("Positive", "Negative", "Chaotic")
var mutation_type: int = 0

## Instability value contributed by this mutation
## High instability can cause feral events or stat penalties
@export_range(0.0, 1.0) var instability_value: float = 0.1

## Rules this mutation can override
## Keys are rule names, values are override specifications
## e.g., {"max_elements": 4} to allow more elements
@export var override_rules: Dictionary = {}

## Forced visual changes from this mutation
## Keys are visual property names, values are forced values
## e.g., {"color_tint": "#FF0000", "scale_modifier": 1.5}
@export var forced_visuals: Dictionary = {}

## Whether this mutation can trigger feral state
@export var can_cause_feral: bool = false

## Chance of mutation spreading when breeding (0-1)
@export_range(0.0, 1.0) var inheritance_chance: float = 0.5


## Get mutation type as string
func get_mutation_type_name() -> String:
	match mutation_type:
		0: return "Positive"
		1: return "Negative"
		2: return "Chaotic"
		_: return "Unknown"


## Check if this mutation is beneficial
func is_positive() -> bool:
	return mutation_type == 0


## Check if this mutation is harmful
func is_negative() -> bool:
	return mutation_type == 1


## Check if this mutation is unpredictable
func is_chaotic() -> bool:
	return mutation_type == 2


## Check if this mutation overrides a specific rule
func has_rule_override(rule_name: String) -> bool:
	return override_rules.has(rule_name)


## Get the override value for a rule
func get_rule_override(rule_name: String, default_value: Variant = null) -> Variant:
	return override_rules.get(rule_name, default_value)


## Check if this mutation forces a specific visual property
func has_forced_visual(visual_name: String) -> bool:
	return forced_visuals.has(visual_name)


## Get the forced visual value
func get_forced_visual(visual_name: String, default_value: Variant = null) -> Variant:
	return forced_visuals.get(visual_name, default_value)


## Validate this DNA Mutation resource
func validate() -> Array[Dictionary]:
	var errors := super.validate()
	
	if instability_value < 0 or instability_value > 1:
		errors.append({
			"severity": "Error",
			"message": "instability_value must be between 0 and 1",
			"source_id": id
		})
	
	if mutation_type == 2 and instability_value < 0.3:
		errors.append({
			"severity": "Warning",
			"message": "Chaotic mutations usually have higher instability",
			"source_id": id
		})
	
	return errors

