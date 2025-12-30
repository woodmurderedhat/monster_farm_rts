## Component for managing target selection and tracking
## Used by combat AI to acquire and maintain targets
extends Node
class_name TargetingComponent

const AIScorerScript = preload("res://systems/ai/ai_scorer.gd")

signal target_acquired(target: Node)
signal target_lost()
signal target_died()

@export var targeting_mode: String = "closest"  # closest, weakest, strongest, player_designated
@export var max_target_range: float = 500.0
@export var retarget_interval: float = 2.0  # Seconds between retarget evaluations

var current_target: Node = null
var target_locked: bool = false  # Player-forced target
var time_since_retarget: float = 0.0

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	time_since_retarget += delta
	
	# Validate current target
	if is_instance_valid(current_target):
		if current_target.has_node("HealthComponent"):
			var health = current_target.get_node("HealthComponent")
			if health.current_health <= 0:
				_on_target_died()
				return
		
		# Check range
		var distance = get_parent().global_position.distance_to(current_target.global_position)
		if distance > max_target_range * 1.5:  # Allow some overshoot
			clear_target()
	else:
		if current_target != null:
			clear_target()
	
	# Retarget if needed
	if not target_locked and time_since_retarget >= retarget_interval:
		_evaluate_retarget()
		time_since_retarget = 0.0

## Set a target (can be player-forced or AI-selected)
func set_target(target: Node, locked: bool = false) -> void:
	if current_target == target:
		return
	
	current_target = target
	target_locked = locked
	target_acquired.emit(target)

## Clear current target
func clear_target() -> void:
	current_target = null
	target_locked = false
	target_lost.emit()

## Get all valid targets in range
func get_valid_targets() -> Array[Node]:
	var targets: Array[Node] = []
	var monster = get_parent()
	
	# Get all potential enemies from combat manager
	if EventBus.has_signal("get_combat_targets"):
		var potential_targets = EventBus.call("get_combat_targets", monster)
		for target in potential_targets:
			if is_valid_target(target):
				targets.append(target)
	
	return targets

## Check if a node is a valid target
func is_valid_target(target: Node) -> bool:
	if not is_instance_valid(target):
		return false
	
	if not target.has_node("HealthComponent"):
		return false
	
	var health = target.get_node("HealthComponent")
	if health.current_health <= 0:
		return false
	
	var distance = get_parent().global_position.distance_to(target.global_position)
	if distance > max_target_range:
		return false
	
	# Check if target is on same team
	if target.has_meta("team") and get_parent().has_meta("team"):
		if target.get_meta("team") == get_parent().get_meta("team"):
			return false
	
	return true

## Evaluate whether to switch targets
func _evaluate_retarget() -> void:
	if target_locked:
		return
	
	var valid_targets = get_valid_targets()
	if valid_targets.is_empty():
		if current_target != null:
			clear_target()
		return
	
	var best_target = _select_best_target(valid_targets)
	if best_target != current_target:
		set_target(best_target, false)

## Select best target based on targeting mode and AI scoring
func _select_best_target(targets: Array[Node]) -> Node:
	if targets.is_empty():
		return null
	
	var monster = get_parent()
	var dna_config = monster.get_meta("ai_config") if monster.has_meta("ai_config") else {}
	
	var best_target: Node = null
	var best_score := -INF
	
	for target in targets:
		var score: float = AIScorer.score_combat_target(monster, target, dna_config)
		
		if score > best_score:
			best_score = score
			best_target = target
	
	return best_target

## Handle player command to focus a specific target
func focus_target(target: Node) -> void:
	if is_valid_target(target):
		set_target(target, true)

## Release player lock, allow AI to retarget
func release_focus() -> void:
	target_locked = false

func _on_target_died() -> void:
	target_died.emit()
	clear_target()
