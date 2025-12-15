# Combat AI Component - Autonomous combat decision making
# Scores targets and abilities based on DNA-driven personality
extends Node
class_name CombatAIComponent

## Combat state enum
enum CombatState {
	IDLE,
	ENGAGE,
	HOLD,
	RETREAT,
	BERSERK
}

## Current combat state
var combat_state: CombatState = CombatState.IDLE

## Current target
var current_target: Node2D = null

## Combat role (from DNA)
var combat_role: String = "dps"

## AI parameters (from DNA)
var aggression: float = 0.5
var loyalty: float = 0.5

## Instability level
var instability: float = 0.0

## Reference to parent entity
var entity: Node2D

## Reference to other components
var combat_component: CombatComponent
var health_component: HealthComponent
var movement_component: MovementComponent
var threat_component: ThreatComponent


func _ready() -> void:
	entity = get_parent() as Node2D
	combat_component = entity.get_node_or_null("CombatComponent")
	health_component = entity.get_node_or_null("HealthComponent")
	movement_component = entity.get_node_or_null("MovementComponent")
	threat_component = entity.get_node_or_null("ThreatComponent")
	_initialize_from_meta()


## Initialize AI parameters from entity metadata
func _initialize_from_meta() -> void:
	if entity:
		instability = entity.get_meta("instability", 0.0)
		
		var ai_config: Dictionary = entity.get_meta("ai_config", {})
		aggression = ai_config.get("aggression", 0.5)
		loyalty = ai_config.get("loyalty", 0.5)
		
		var roles: Array = ai_config.get("combat_roles", ["dps"])
		if roles.size() > 0:
			combat_role = roles[0]


## Main combat update called by CombatManager
func update_combat(combat_manager: CombatManager) -> void:
	# Update combat state
	_update_combat_state()
	
	if combat_state == CombatState.IDLE:
		return
	
	if combat_state == CombatState.RETREAT:
		_handle_retreat()
		return
	
	# Get potential targets
	var team: int = entity.get_meta("team", 0)
	var targets := combat_manager.get_targets_for(entity, team)
	
	if targets.is_empty():
		_exit_combat()
		return
	
	# Score and select target
	var best_target := _select_best_target(targets, combat_manager)
	if best_target != current_target:
		current_target = best_target
		if combat_component:
			combat_component.set_target(best_target)
	
	# Score and use ability
	_select_and_use_ability()


## Update combat state based on current situation
func _update_combat_state() -> void:
	# Check for berserk (high instability)
	if instability > 0.8 and randf() < 0.1:
		combat_state = CombatState.BERSERK
		return
	
	# Check for retreat (low health)
	if health_component:
		var health_percent := health_component.get_health_percent()
		var retreat_threshold := 0.2 + (1.0 - aggression) * 0.2
		
		if health_percent < retreat_threshold and combat_state != CombatState.BERSERK:
			combat_state = CombatState.RETREAT
			return
	
	# Default to engage if we have a target or threats
	if current_target or (threat_component and threat_component.get_highest_threat_target()):
		combat_state = CombatState.ENGAGE
	else:
		combat_state = CombatState.IDLE


## Select best target from available targets
func _select_best_target(targets: Array[Node2D], combat_manager: CombatManager) -> Node2D:
	var best_score := -999.0
	var best_target: Node2D = null
	
	# Check for focus target
	if combat_manager.group_focus_target and combat_manager.group_focus_target in targets:
		return combat_manager.group_focus_target
	
	for target in targets:
		var score := _score_target(target)
		if score > best_score:
			best_score = score
			best_target = target
	
	return best_target


## Score a potential target
func _score_target(target: Node2D) -> float:
	var score := 0.0
	
	# Threat value
	if threat_component:
		score += threat_component.get_threat(target) * 0.5
	
	# Distance penalty
	var distance := entity.global_position.distance_to(target.global_position)
	score -= distance * 0.01
	
	# Role preference
	var target_health := target.get_node_or_null("HealthComponent") as HealthComponent
	if target_health:
		var health_percent := target_health.get_health_percent()
		
		match combat_role:
			"dps":
				# Prefer low health targets
				score += (1.0 - health_percent) * 30
			"tank":
				# Prefer high threat targets
				score += 20  # Base score for any target
			"support":
				# Avoid combat, prefer nearby
				score -= 10
	
	# Berserk ignores smart targeting
	if combat_state == CombatState.BERSERK:
		score = randf() * 50

	return score


## Select and use the best ability
func _select_and_use_ability() -> void:
	if not combat_component or not current_target:
		return

	var available := combat_component.get_available_abilities()
	if available.is_empty():
		return

	var best_score := -999.0
	var best_ability: Dictionary = {}

	for ability in available:
		var score := _score_ability(ability)
		if score > best_score:
			best_score = score
			best_ability = ability

	if not best_ability.is_empty() and best_score > 0:
		var ability_id: String = best_ability.get("id", "")
		combat_component.use_ability(ability_id, current_target)


## Score an ability for current situation
func _score_ability(ability: Dictionary) -> float:
	var score := 10.0  # Base score

	# Check range
	var ability_range: float = ability.get("range", 100)
	var distance := entity.global_position.distance_to(current_target.global_position)

	if distance > ability_range:
		return -999.0  # Out of range

	# Energy cost penalty
	var energy_cost: float = ability.get("energy_cost", 0)
	score -= energy_cost * 0.1

	# Role synergy
	var targeting_type: int = ability.get("targeting_type", 1)
	match combat_role:
		"dps":
			score += ability.get("base_power", 0) * 0.2
		"tank":
			if targeting_type == 0:  # Self-targeting
				score += 15  # Prefer self-buffs/shields
		"support":
			if targeting_type == 0:
				score += 20  # Prefer utility

	# Berserk uses abilities randomly
	if combat_state == CombatState.BERSERK:
		score = randf() * 30

	return score


## Handle retreat behavior
func _handle_retreat() -> void:
	if not movement_component:
		return

	# Move away from threats
	var threat_direction := Vector2.ZERO

	if threat_component:
		var threats := threat_component.get_sorted_threats()
		for threat_data in threats:
			var threat_target: Node2D = threat_data.target
			var dir := entity.global_position.direction_to(threat_target.global_position)
			threat_direction -= dir * threat_data.threat

	if threat_direction.length_squared() > 0:
		var retreat_position := entity.global_position + threat_direction.normalized() * 200
		movement_component.move_to(retreat_position)


## Exit combat state
func _exit_combat() -> void:
	combat_state = CombatState.IDLE
	current_target = null
	if combat_component:
		combat_component.leave_combat()


## Handle external combat events
func on_combat_event(event_type: String, data: Dictionary) -> void:
	match event_type:
		"focus_target":
			# Update to focus target if valid
			var target: Node2D = data.get("target")
			if is_instance_valid(target):
				current_target = target
		"retreat":
			combat_state = CombatState.RETREAT
		"hold":
			combat_state = CombatState.HOLD

