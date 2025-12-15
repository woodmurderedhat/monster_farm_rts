# Monster DNA Stack - Container for all DNA parts that make up a monster
# This is the complete genetic blueprint for monster creation
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


## Get combined stat modifiers from all DNA parts
func get_combined_stat_modifiers() -> Dictionary:
	var combined: Dictionary = {}
	
	# Collect from all DNA parts
	var all_parts: Array = [core, behavior]
	all_parts.append_array(elements)
	all_parts.append_array(abilities)
	all_parts.append_array(mutations)
	
	for part in all_parts:
		if part and part is BaseDNAResource:
			for stat_name in part.stat_modifiers:
				if combined.has(stat_name):
					combined[stat_name] += part.stat_modifiers[stat_name]
				else:
					combined[stat_name] = part.stat_modifiers[stat_name]
	
	return combined


## Check if the stack has a specific element type
func has_element(element_type: String) -> bool:
	for element in elements:
		if element and element.element_type == element_type:
			return true
	return false


## Check if the stack is complete (has required parts)
func is_complete() -> bool:
	return core != null and behavior != null and not abilities.is_empty()


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

