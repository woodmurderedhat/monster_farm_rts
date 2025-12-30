## AI component for intelligent ability usage
## Decides when and which abilities to use based on tactical situation
extends Node
class_name AbilityAIComponent

const AIScorerScript = preload("res://systems/ai/ai_scorer.gd")

@export var decision_interval: float = 0.5  # How often to reevaluate abilities
@export var auto_use_passives: bool = true
@export var auto_use_defensives: bool = true
@export var player_control_active: bool = false  # Player manual override

var time_since_decision: float = 0.0
var ability_queue: Array = []

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	if player_control_active:
		return
	
	time_since_decision += delta
	
	if time_since_decision >= decision_interval:
		_evaluate_and_use_abilities()
		time_since_decision = 0.0

## Main ability evaluation logic
func _evaluate_and_use_abilities() -> void:
	var monster = get_parent()
	
	if not monster.has_meta("abilities"):
		return
	
	var abilities = monster.get_meta("abilities")
	if abilities.is_empty():
		return
	
	var tactical_context = _build_tactical_context()
	var target = _get_current_target()
	
	# Score all available abilities
	var scored_abilities = []
	for ability in abilities:
		var score = AIScorer.score_ability(monster, ability, target, tactical_context)
		if score > 0:
			scored_abilities.append({"ability": ability, "score": score})
	
	# Sort by score (highest first)
	scored_abilities.sort_custom(func(a, b): return a.score > b.score)
	
	# Use highest scoring ability
	if not scored_abilities.is_empty():
		var best = scored_abilities[0]
		_use_ability(best.ability, target)

## Build tactical context for ability scoring
func _build_tactical_context() -> Dictionary:
	var monster = get_parent()
	var context = {}
	
	# Self health
	if monster.has_node("HealthComponent"):
		var health = monster.get_node("HealthComponent")
		context["self_health_pct"] = health.current_health / health.max_health
	
	# Enemy/ally counts in range
	var enemies_nearby = 0
	var allies_nearby = 0
	
	# This would ideally query the combat manager for nearby units
	# For now, we'll use a simplified approach
	context["enemy_count"] = enemies_nearby
	context["ally_count"] = allies_nearby
	context["enemy_density"] = 0.0
	
	# Combat state
	if monster.has_node("CombatComponent"):
		var combat = monster.get_node("CombatComponent")
		context["in_combat"] = combat.in_combat
	
	return context

## Get current combat target
func _get_current_target() -> Node:
	var monster = get_parent()
	
	if monster.has_node("TargetingComponent"):
		return monster.get_node("TargetingComponent").current_target
	
	if monster.has_node("CombatAIComponent"):
		var combat_ai = monster.get_node("CombatAIComponent")
		if combat_ai.has("current_target"):
			return combat_ai.current_target
	
	return null

## Execute an ability
func _use_ability(ability: Dictionary, target: Node) -> void:
	var monster = get_parent()
	
	# Check if we have an ability executor
	var executor = null
	if monster.has_node("CombatComponent"):
		var combat = monster.get_node("CombatComponent")
		if combat.has_node("AbilityExecutor"):
			executor = combat.get_node("AbilityExecutor")
	
	if executor == null:
		# Fallback: emit signal
		EventBus.ability_used.emit(monster, ability, target)
		return
	
	# Execute via executor
	executor.execute_ability(ability, target)
	
	# Set cooldown
	if ability.has("cooldown"):
		ability["cooldown_remaining"] = ability.cooldown

## Player manually triggers an ability
func manual_cast_ability(ability_index: int, target: Node = null) -> bool:
	var monster = get_parent()
	
	if not monster.has_meta("abilities"):
		return false
	
	var abilities = monster.get_meta("abilities")
	if ability_index < 0 or ability_index >= abilities.size():
		return false
	
	var ability = abilities[ability_index]
	
	# Check if can cast
	if ability.get("cooldown_remaining", 0.0) > 0.0:
		return false
	
	# Use target from targeting component if not provided
	if target == null:
		target = _get_current_target()
	
	_use_ability(ability, target)
	return true

## Enable/disable player manual control
func set_player_control(enabled: bool) -> void:
	player_control_active = enabled
