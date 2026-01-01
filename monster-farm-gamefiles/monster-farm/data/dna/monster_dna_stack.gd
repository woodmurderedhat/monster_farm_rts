# Monster DNA Stack - Container for all DNA parts that make up a monster
# This is the complete genetic blueprint for monster creation
@tool
extends Resource
class_name MonsterDNAStack

## Core DNA - Required, defines physical foundation
@export var core: DNACoreResource

## Element DNAs - 0 to N elements (limited by core.allowed_elements)
@export var elements: Array[DNAElementResource] = []

## Behavior DNA - Required, defines personality
@export var behavior: DNABehaviorResource

## Ability DNAs - 1 to N abilities (limited by core.ability_slots)
@export var abilities: Array[DNAAbilityResource] = []

## Mutation DNAs - 0 to N mutations (limited by core.mutation_capacity)
@export var mutations: Array[DNAMutationResource] = []


## Get all tags from all DNA parts combined
func get_all_tags() -> Array[String]:
	var all_tags: Array[String] = []
	
	if core:
		all_tags.append_array(core.get_all_tags())
	
	for element in elements:
		if element:
			all_tags.append_array(element.get_all_tags())
	
	if behavior:
		all_tags.append_array(behavior.get_all_tags())
	
	for ability in abilities:
		if ability:
			all_tags.append_array(ability.get_all_tags())
	
	for mutation in mutations:
		if mutation:
			all_tags.append_array(mutation.get_all_tags())
	
	return all_tags


## Get all incompatible tags from all DNA parts
func get_all_incompatible_tags() -> Array[String]:
	var all_incompatible: Array[String] = []
	
	if core:
		all_incompatible.append_array(core.incompatible_tags)
	
	for element in elements:
		if element:
			all_incompatible.append_array(element.incompatible_tags)
	
	if behavior:
		all_incompatible.append_array(behavior.incompatible_tags)
	
	for ability in abilities:
		if ability:
			all_incompatible.append_array(ability.incompatible_tags)
	
	for mutation in mutations:
		if mutation:
			all_incompatible.append_array(mutation.incompatible_tags)
	
	return all_incompatible


## Calculate total instability from all mutations
func get_total_instability() -> float:
	var total := 0.0
	for mutation in mutations:
		if mutation:
			total += mutation.instability_value
	return clampf(total, 0.0, 1.0)


## Get combined stat modifiers from all DNA parts, split into additive and multiplicative layers
func get_combined_stat_modifiers() -> Dictionary:
	var add_mods: Dictionary = {}
	var mult_mods: Dictionary = {}

	# Collect from all DNA parts
	var all_parts: Array = [core, behavior]
	all_parts.append_array(elements)
	all_parts.append_array(abilities)
	all_parts.append_array(mutations)

	for part in all_parts:
		if part and part is BaseDNAResource:
			for stat_name in part.stat_modifiers:
				var value = part.stat_modifiers[stat_name]
				if typeof(value) == TYPE_DICTIONARY:
					if value.has("add"):
						add_mods[stat_name] = add_mods.get(stat_name, 0.0) + float(value.get("add", 0.0))
					if value.has("mult"):
						mult_mods[stat_name] = mult_mods.get(stat_name, 1.0) * float(value.get("mult", 1.0))
				else:
					add_mods[stat_name] = add_mods.get(stat_name, 0.0) + float(value)

	return {
		"add": add_mods,
		"mult": mult_mods
	}


## Check if the stack has a specific element type
func has_element(element_type: String) -> bool:
	for element in elements:
		if element and element.element_type == element_type:
			return true
	return false


## Check if the stack is complete (has required parts)
func is_complete() -> bool:
	return core != null and behavior != null and not abilities.is_empty()


## Get AI configuration aggregated from all DNA parts
func get_ai_configuration() -> Dictionary:
	var ai_config: Dictionary = {}
	
	# Base config from behavior DNA
	if behavior:
		ai_config = {
			"aggression": behavior.aggression,
			"loyalty": behavior.loyalty,
			"curiosity": behavior.curiosity,
			"stress_tolerance": behavior.stress_tolerance,
			"combat_roles": behavior.combat_roles.duplicate(),
			"work_affinity": behavior.work_affinity.duplicate()
		}
	else:
		ai_config = {
			"aggression": 0.5,
			"loyalty": 0.5,
			"curiosity": 0.5,
			"stress_tolerance": 0.5,
			"combat_roles": ["dps"],
			"work_affinity": {}
		}
	
	# Apply modifiers from all DNA parts
	var all_parts: Array = [core]
	all_parts.append_array(elements)
	all_parts.append_array(abilities)
	all_parts.append_array(mutations)
	
	for part in all_parts:
		if part and part is BaseDNAResource and part.ai_modifiers:
			for ai_param in part.ai_modifiers:
				if ai_config.has(ai_param):
					var current = ai_config[ai_param]
					if typeof(current) in [TYPE_INT, TYPE_FLOAT]:
						ai_config[ai_param] += part.ai_modifiers[ai_param]
				else:
					ai_config[ai_param] = part.ai_modifiers[ai_param]
	
	# Clamp behavioral stats to 0.0-1.0
	ai_config["aggression"] = clampf(ai_config.get("aggression", 0.5), 0.0, 1.0)
	ai_config["loyalty"] = clampf(ai_config.get("loyalty", 0.5), 0.0, 1.0)
	ai_config["curiosity"] = clampf(ai_config.get("curiosity", 0.5), 0.0, 1.0)
	ai_config["stress_tolerance"] = clampf(ai_config.get("stress_tolerance", 0.5), 0.0, 1.0)
	
	return ai_config


## Get visual layer modifiers in application order
func get_visual_layers() -> Array[Dictionary]:
	var layers: Array[Dictionary] = []
	
	# Base layer from core
	if core:
		layers.append({
			"source": core.id,
			"type": "core",
			"body_type": core.get_body_type_name(),
			"size_multiplier": core.base_size,
			"modifiers": core.visual_modifiers.duplicate()
		})
	
	# Element layers
	for element in elements:
		if element:
			layers.append({
				"source": element.id,
				"type": "element",
				"element_type": element.element_type,
				"modifiers": element.visual_modifiers.duplicate()
			})
	
	# Mutation layers (applied last, can override)
	for mutation in mutations:
		if mutation:
			layers.append({
				"source": mutation.id,
				"type": "mutation",
				"instability": mutation.instability_value,
				"modifiers": mutation.visual_modifiers.duplicate()
			})
	
	return layers


## Get a summary string for debugging
func get_summary() -> String:
	var summary := "DNA Stack: "
	if core:
		summary += core.display_name + " "
	if behavior:
		summary += "[" + behavior.display_name + "] "
	summary += "Elements: %d, Abilities: %d, Mutations: %d" % [
		elements.size(),
		abilities.size(),
		mutations.size()
	]
	return summary


## Run validation using the shared validator
func validate() -> Array[ValidationResult]:
	return DNAValidator.validate_stack(self)
