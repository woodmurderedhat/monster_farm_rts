# Monster Assembler - Converts DNA Stack into a functional monster entity
# This is the main entry point for spawning monsters from DNA
extends Node
class_name MonsterAssembler

## Spawn context affects validation strictness and AI defaults
enum SpawnContext {
	WORLD,
	FARM,
	RAID,
	EDITOR_PREVIEW
}

## Signal emitted when a monster is successfully spawned
signal monster_spawned(monster: Node2D, dna_stack: MonsterDNAStack)

## Signal emitted when monster spawn fails
signal monster_spawn_failed(dna_stack: MonsterDNAStack, errors: Array[ValidationResult])

## Path to the base monster scene
const MONSTER_BASE_SCENE := "res://entities/monster/monster_base.tscn"


## Main entry point - assemble a monster from DNA
## Returns the monster node or null if assembly fails
func assemble_monster(dna_stack: MonsterDNAStack, context: SpawnContext = SpawnContext.WORLD) -> Node2D:
	# Phase 1: Validate DNA
	var validation_results := DNAValidator.validate_stack(dna_stack)
	
	# Check for blocking errors (except in preview mode)
	if context != SpawnContext.EDITOR_PREVIEW:
		if DNAValidator.has_blocking_errors(validation_results):
			_log_validation_errors(validation_results)
			monster_spawn_failed.emit(dna_stack, validation_results)
			return null
	
	# Phase 2: Load base scene
	var monster := _load_base_scene()
	if monster == null:
		push_error("MonsterAssembler: Failed to load base monster scene")
		return null
	
	# Phase 3: Initialize components
	_initialize_components(monster, dna_stack)
	
	# Phase 4: Assemble stats
	var stat_block := _assemble_stats(dna_stack, context)
	_apply_stats(monster, stat_block)
	
	# Phase 5: Configure AI
	_configure_ai(monster, dna_stack, context)
	
	# Phase 6: Assign abilities
	_assign_abilities(monster, dna_stack)
	
	# Phase 7: Apply visuals
	_apply_visuals(monster, dna_stack)
	
	# Phase 8: Finalize
	_finalize_monster(monster, dna_stack, context)
	
	monster_spawned.emit(monster, dna_stack)
	return monster


## Load the base monster scene
func _load_base_scene() -> Node2D:
	if not ResourceLoader.exists(MONSTER_BASE_SCENE):
		push_warning("MonsterAssembler: Base scene not found at " + MONSTER_BASE_SCENE)
		# Create a placeholder for development
		var placeholder := CharacterBody2D.new()
		placeholder.name = "Monster"
		return placeholder
	
	var scene := load(MONSTER_BASE_SCENE) as PackedScene
	return scene.instantiate() as Node2D


## Initialize monster components with DNA data
func _initialize_components(monster: Node2D, dna_stack: MonsterDNAStack) -> void:
	# Store DNA reference on monster
	monster.set_meta("dna_stack", dna_stack)
	
	# Components will be initialized by the monster scene itself
	# This method is for any additional setup needed


## Build the stat block from DNA layers
func _assemble_stats(dna_stack: MonsterDNAStack, context: SpawnContext) -> Dictionary:
	var stats: Dictionary = {}
	
	# Base stats from core
	if dna_stack.core:
		stats["max_health"] = dna_stack.core.base_health
		stats["max_stamina"] = dna_stack.core.base_stamina
		stats["speed"] = dna_stack.core.base_speed
		stats["size"] = dna_stack.core.base_size
		stats["mass"] = dna_stack.core.base_mass
	
	# Apply modifiers from all DNA parts
	var modifiers := dna_stack.get_combined_stat_modifiers()
	for stat_name in modifiers:
		if stats.has(stat_name):
			stats[stat_name] += modifiers[stat_name]
		else:
			stats[stat_name] = modifiers[stat_name]
	
	# Apply instability penalties
	var instability := dna_stack.get_total_instability()
	if instability > 0.5:
		var penalty := (instability - 0.5) * 0.2  # Up to 10% penalty
		for stat_name in stats:
			if typeof(stats[stat_name]) in [TYPE_INT, TYPE_FLOAT]:
				stats[stat_name] *= (1.0 - penalty)
	
	# Apply context modifiers
	match context:
		SpawnContext.RAID:
			stats["max_health"] = stats.get("max_health", 100) * 1.2
		SpawnContext.FARM:
			stats["stress_rate"] = stats.get("stress_rate", 1.0) * 0.8
	
	return stats


## Apply assembled stats to the monster
func _apply_stats(monster: Node2D, stat_block: Dictionary) -> void:
	monster.set_meta("stat_block", stat_block)
	
	# Apply to health component if exists
	var health_component := monster.get_node_or_null("HealthComponent")
	if health_component:
		health_component.set_meta("max_health", stat_block.get("max_health", 100))
		health_component.set_meta("current_health", stat_block.get("max_health", 100))


## Configure AI based on DNA behavior
func _configure_ai(monster: Node2D, dna_stack: MonsterDNAStack, context: SpawnContext) -> void:
	if dna_stack.behavior == null:
		return
	
	var ai_config: Dictionary = {
		"aggression": dna_stack.behavior.aggression,
		"loyalty": dna_stack.behavior.loyalty,
		"curiosity": dna_stack.behavior.curiosity,
		"stress_tolerance": dna_stack.behavior.stress_tolerance,
		"combat_roles": dna_stack.behavior.combat_roles.duplicate(),
		"work_affinity": dna_stack.behavior.work_affinity.duplicate()
	}
	
	# Apply AI modifiers from DNA
	for mutation in dna_stack.mutations:
		if mutation:
			for key in mutation.ai_modifiers:
				ai_config[key] = mutation.ai_modifiers[key]
	
	monster.set_meta("ai_config", ai_config)


## Assign abilities from DNA to the monster
func _assign_abilities(monster: Node2D, dna_stack: MonsterDNAStack) -> void:
	var available_tags := dna_stack.get_all_tags()
	var abilities_data: Array[Dictionary] = []

	for ability in dna_stack.abilities:
		if ability == null:
			continue

		var ability_data: Dictionary = {
			"id": ability.ability_id,
			"display_name": ability.display_name,
			"cooldown": ability.cooldown,
			"energy_cost": ability.energy_cost,
			"range": ability.ability_range,
			"targeting_type": ability.targeting_type,
			"base_power": ability.base_power,
			"aoe_radius": ability.aoe_radius,
			"scaling_stats": ability.scaling_stats.duplicate(),
			"enabled": ability.has_required_tags(available_tags)
		}
		abilities_data.append(ability_data)

	monster.set_meta("abilities", abilities_data)


## Apply visual modifiers from DNA
func _apply_visuals(monster: Node2D, dna_stack: MonsterDNAStack) -> void:
	var visual_data: Dictionary = {}

	# Collect visual modifiers from all DNA parts
	if dna_stack.core:
		visual_data["body_type"] = dna_stack.core.get_body_type_name()
		visual_data["base_size"] = dna_stack.core.base_size
		visual_data.merge(dna_stack.core.visual_modifiers, true)

	for element in dna_stack.elements:
		if element:
			visual_data.merge(element.visual_modifiers, true)

	# Mutations can force visual changes
	for mutation in dna_stack.mutations:
		if mutation:
			visual_data.merge(mutation.forced_visuals, true)

	monster.set_meta("visual_data", visual_data)

	# Apply scale if specified
	var scale_mod: float = visual_data.get("scale_modifier", 1.0)
	var base_size: float = visual_data.get("base_size", 1.0)
	monster.scale = Vector2(base_size * scale_mod, base_size * scale_mod)


## Finalize monster setup and make it active
func _finalize_monster(monster: Node2D, dna_stack: MonsterDNAStack, context: SpawnContext) -> void:
	# Set current health/stamina to max
	var stat_block: Dictionary = monster.get_meta("stat_block", {})
	monster.set_meta("current_health", stat_block.get("max_health", 100))
	monster.set_meta("current_stamina", stat_block.get("max_stamina", 100))

	# Set spawn context
	monster.set_meta("spawn_context", context)

	# Calculate and store instability
	monster.set_meta("instability", dna_stack.get_total_instability())

	# Set monster name based on DNA
	if dna_stack.core:
		monster.name = dna_stack.core.display_name


## Log validation errors for debugging
func _log_validation_errors(results: Array[ValidationResult]) -> void:
	for result in results:
		if result.is_error():
			push_error("DNA Validation Error: " + result.format())
		elif result.is_warning():
			push_warning("DNA Validation Warning: " + result.format())

