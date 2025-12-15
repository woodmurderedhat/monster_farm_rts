# DNA Validator - Validates a MonsterDNAStack for errors and warnings
# Used by both editor tools and runtime spawn system
extends Resource
class_name DNAValidator


## Validate a complete DNA stack
## Returns array of ValidationResult
static func validate_stack(dna_stack: MonsterDNAStack) -> Array[ValidationResult]:
	var results: Array[ValidationResult] = []
	
	if dna_stack == null:
		results.append(ValidationResult.error("DNA stack is null"))
		return results
	
	# Phase 1: Check required components
	results.append_array(_validate_required_components(dna_stack))
	
	# Phase 2: Check slot limits
	results.append_array(_validate_slot_limits(dna_stack))
	
	# Phase 3: Check tag compatibility
	results.append_array(_validate_tag_compatibility(dna_stack))
	
	# Phase 4: Check ability requirements
	results.append_array(_validate_ability_requirements(dna_stack))
	
	# Phase 5: Check element compatibility
	results.append_array(_validate_element_compatibility(dna_stack))
	
	# Phase 6: Validate individual parts
	results.append_array(_validate_individual_parts(dna_stack))
	
	# Phase 7: Check mutation limits
	results.append_array(_validate_mutation_limits(dna_stack))
	
	return results


## Check for required DNA components
static func _validate_required_components(stack: MonsterDNAStack) -> Array[ValidationResult]:
	var results: Array[ValidationResult] = []
	
	if stack.core == null:
		results.append(ValidationResult.error("DNACore is required"))
	
	if stack.behavior == null:
		results.append(ValidationResult.error("DNABehavior is required"))
	
	if stack.abilities.is_empty():
		results.append(ValidationResult.warning("No abilities defined - monster will have no attacks"))
	
	return results


## Check that slot limits are respected
static func _validate_slot_limits(stack: MonsterDNAStack) -> Array[ValidationResult]:
	var results: Array[ValidationResult] = []
	
	if stack.core == null:
		return results
	
	# Check ability slots
	if stack.abilities.size() > stack.core.ability_slots:
		results.append(ValidationResult.error(
			"Too many abilities: %d (max: %d)" % [stack.abilities.size(), stack.core.ability_slots],
			stack.core.id
		))
	
	# Check mutation capacity
	if stack.mutations.size() > stack.core.mutation_capacity:
		results.append(ValidationResult.error(
			"Too many mutations: %d (max: %d)" % [stack.mutations.size(), stack.core.mutation_capacity],
			stack.core.id
		))
	
	return results


## Check tag compatibility across all DNA parts
static func _validate_tag_compatibility(stack: MonsterDNAStack) -> Array[ValidationResult]:
	var results: Array[ValidationResult] = []
	
	var all_tags := stack.get_all_tags()
	var all_incompatible := stack.get_all_incompatible_tags()
	
	for tag in all_tags:
		if tag in all_incompatible:
			results.append(ValidationResult.error(
				"Tag conflict: '%s' is present but marked as incompatible" % tag
			))
	
	return results


## Check that abilities have their required tags
static func _validate_ability_requirements(stack: MonsterDNAStack) -> Array[ValidationResult]:
	var results: Array[ValidationResult] = []
	
	var all_tags := stack.get_all_tags()
	
	for ability in stack.abilities:
		if ability == null:
			continue
		if not ability.has_required_tags(all_tags):
			results.append(ValidationResult.warning(
				"Ability '%s' missing required tags - will be disabled" % ability.display_name,
				ability.id
			))
	
	return results


## Check element compatibility with core
static func _validate_element_compatibility(stack: MonsterDNAStack) -> Array[ValidationResult]:
	var results: Array[ValidationResult] = []
	
	if stack.core == null:
		return results
	
	for element in stack.elements:
		if element == null:
			continue
		if not stack.core.is_element_allowed(element.element_type):
			results.append(ValidationResult.error(
				"Element '%s' not allowed by this core" % element.element_type,
				element.id
			))
	
	return results


## Validate each individual DNA part
static func _validate_individual_parts(stack: MonsterDNAStack) -> Array[ValidationResult]:
	var results: Array[ValidationResult] = []
	
	var all_parts: Array = []
	if stack.core:
		all_parts.append(stack.core)
	if stack.behavior:
		all_parts.append(stack.behavior)
	all_parts.append_array(stack.elements)
	all_parts.append_array(stack.abilities)
	all_parts.append_array(stack.mutations)
	
	for part in all_parts:
		if part == null:
			continue
		var part_errors: Array[Dictionary] = part.validate()
		for err in part_errors:
			var result := ValidationResult.new()
			result.message = err.get("message", "Unknown error")
			result.source_id = err.get("source_id", "")
			match err.get("severity", "Error"):
				"Info": result.severity = 0
				"Warning": result.severity = 1
				_: result.severity = 2
			results.append(result)
	
	return results


## Validate mutation limits and instability
static func _validate_mutation_limits(stack: MonsterDNAStack) -> Array[ValidationResult]:
	var results: Array[ValidationResult] = []
	
	var total_instability := stack.get_total_instability()
	
	if total_instability > 0.8:
		results.append(ValidationResult.warning(
			"High instability (%.0f%%) - monster may become feral" % (total_instability * 100)
		))
	
	return results


## Check if a validation result array has any blocking errors
static func has_blocking_errors(results: Array[ValidationResult]) -> bool:
	for result in results:
		if result.is_error():
			return true
	return false


## Filter results by severity
static func filter_by_severity(results: Array[ValidationResult], severity: int) -> Array[ValidationResult]:
	var filtered: Array[ValidationResult] = []
	for result in results:
		if result.severity == severity:
			filtered.append(result)
	return filtered

