# Combat Manager - Coordinates combat across all active monsters
# Handles combat ticks, target caching, and group coordination
extends Node
class_name CombatManager

## Combat tick interval in seconds
@export var tick_interval: float = 0.2

## Maximum distance to consider targets
@export var max_target_distance: float = 500.0

## All monsters currently in combat
var combatants: Array[Node2D] = []

## Cached list of valid targets per team
var target_cache: Dictionary = {}

## Current focus target (shared by selected group)
var group_focus_target: Node2D = null

## Timer for combat ticks
var tick_timer: float = 0.0


func _process(delta: float) -> void:
	tick_timer += delta
	if tick_timer >= tick_interval:
		tick_timer = 0.0
		_run_combat_tick()


## Register a monster for combat updates
func register_combatant(monster: Node2D) -> void:
	if monster not in combatants:
		combatants.append(monster)


## Unregister a monster from combat
func unregister_combatant(monster: Node2D) -> void:
	combatants.erase(monster)


## Set group focus target
func set_focus_target(target: Node2D) -> void:
	group_focus_target = target
	EventBus.player_command.emit("focus", {"target": target})


## Clear focus target
func clear_focus_target() -> void:
	group_focus_target = null


## Get all potential targets for a monster
func get_targets_for(monster: Node2D, team: int = 0) -> Array[Node2D]:
	var targets: Array[Node2D] = []
	
	for combatant in combatants:
		if combatant == monster:
			continue
		
		# Check if enemy (different team)
		var combatant_team: int = combatant.get_meta("team", 0)
		if combatant_team == team:
			continue
		
		# Check distance
		var distance := monster.global_position.distance_to(combatant.global_position)
		if distance > max_target_distance:
			continue
		
		# Check if alive
		var health_comp := combatant.get_node_or_null("HealthComponent") as HealthComponent
		if health_comp and not health_comp.is_alive():
			continue
		
		targets.append(combatant)
	
	return targets


## Run a single combat tick
func _run_combat_tick() -> void:
	# Clean up dead/removed combatants
	combatants = combatants.filter(func(c): return is_instance_valid(c))
	
	# Stagger AI updates across multiple frames
	var batch_size := ceili(combatants.size() / 3.0)
	var start_index := (Engine.get_process_frames() % 3) * batch_size
	var end_index := mini(start_index + batch_size, combatants.size())
	
	for i in range(start_index, end_index):
		var monster := combatants[i]
		_update_monster_combat(monster)


## Update combat AI for a single monster
func _update_monster_combat(monster: Node2D) -> void:
	var combat_ai := monster.get_node_or_null("CombatAIComponent") as CombatAIComponent
	if combat_ai:
		combat_ai.update_combat(self)


## Get danger zones (areas with high enemy concentration)
func get_danger_zones() -> Array[Dictionary]:
	# Simple implementation - cluster enemy positions
	var zones: Array[Dictionary] = []
	# Could be expanded with spatial hashing
	return zones


## Notify all combatants of an event
func broadcast_combat_event(event_type: String, data: Dictionary) -> void:
	for combatant in combatants:
		var combat_ai := combatant.get_node_or_null("CombatAIComponent") as CombatAIComponent
		if combat_ai:
			combat_ai.on_combat_event(event_type, data)


## Set deterministic RNG seed for combat rolls
func set_rng_seed(seed: int) -> void:
	var calc = preload("res://systems/combat/damage_calculator.gd")
	calc.set_seed(seed)

