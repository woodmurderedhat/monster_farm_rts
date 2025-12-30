## Automation Scheduler - manages farm automation cycles and job assignment
## Coordinates when monsters evaluate and switch jobs
extends Node
class_name AutomationScheduler

const AIScorerScript = preload("res://systems/ai/ai_scorer.gd")

signal job_cycle_started()
signal job_cycle_completed()
signal monster_assigned_job(monster: Node, job: Resource)

@export var job_evaluation_interval: float = 10.0  # Seconds between job re-evaluation
@export var stagger_evaluations: bool = true  # Prevent all monsters from evaluating at once

var time_since_cycle: float = 0.0
var registered_monsters: Array[Node] = []
var evaluation_offsets: Dictionary = {}  # monster -> offset_time

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	time_since_cycle += delta
	
	if time_since_cycle >= job_evaluation_interval:
		_run_job_cycle()
		time_since_cycle = 0.0
	
	# Handle staggered evaluations
	if stagger_evaluations:
		_process_staggered_evaluations(delta)

## Run a full job evaluation cycle
func _run_job_cycle() -> void:
	job_cycle_started.emit()
	
	if not stagger_evaluations:
		# Evaluate all monsters at once
		for monster in registered_monsters:
			if is_instance_valid(monster):
				_evaluate_monster_job(monster)
	
	job_cycle_completed.emit()

## Process staggered evaluations (spread over time)
func _process_staggered_evaluations(delta: float) -> void:
	for monster in evaluation_offsets:
		if not is_instance_valid(monster):
			continue
		
		evaluation_offsets[monster] -= delta
		
		if evaluation_offsets[monster] <= 0.0:
			_evaluate_monster_job(monster)
			# Reset offset for next cycle
			evaluation_offsets[monster] = job_evaluation_interval

## Evaluate and potentially assign new job to a monster
func _evaluate_monster_job(monster: Node) -> void:
	if not monster.has_node("JobComponent"):
		return
	
	var job_comp = monster.get_node("JobComponent")
	
	# Check if locked (player forced this job)
	if job_comp.job_locked:
		return
	
	# Check if current job is high priority and should continue
	if job_comp.current_job != null:
		if job_comp.time_in_job < job_comp.min_job_duration:
			return  # Don't thrash between jobs
	
	# Get all available jobs from JobBoard
	var job_board = _get_job_board()
	if job_board == null:
		return
	
	var available_jobs = job_board.get_available_jobs()
	if available_jobs.is_empty():
		return
	
	# Score all jobs for this monster
	var best_job = _select_best_job(monster, available_jobs)
	
	if best_job != null and best_job != job_comp.current_job:
		_assign_job(monster, best_job)

## Select best job for a monster using AI scoring
func _select_best_job(monster: Node, jobs: Array) -> Resource:
	var needs = _get_monster_needs(monster)
	var dna_config = monster.get_meta("ai_config") if monster.has_meta("ai_config") else {}
	
	var best_job: Resource = null
	var best_score := -INF
	
	for job in jobs:
		var score = AIScorer.score_job(monster, job, needs, dna_config)
		
		if score > best_score:
			best_score = score
			best_job = job
	
	return best_job

## Assign a job to a monster
func _assign_job(monster: Node, job: Resource) -> void:
	if not monster.has_node("JobComponent"):
		return
	
	var job_comp = monster.get_node("JobComponent")
	job_comp.assign_job(job)
	
	monster_assigned_job.emit(monster, job)
	EventBus.monster_job_assigned.emit(monster, job)

## Register a monster for automation
func register_monster(monster: Node) -> void:
	if monster not in registered_monsters:
		registered_monsters.append(monster)
		
		# Assign staggered evaluation offset
		if stagger_evaluations:
			var offset = randf() * job_evaluation_interval
			evaluation_offsets[monster] = offset

## Unregister a monster (when it leaves farm or is destroyed)
func unregister_monster(monster: Node) -> void:
	registered_monsters.erase(monster)
	evaluation_offsets.erase(monster)

## Get monster needs for job scoring
func _get_monster_needs(monster: Node) -> Dictionary:
	if monster.has_node("NeedsComponent"):
		var needs_comp = monster.get_node("NeedsComponent")
		return needs_comp.get_needs_state()
	
	return {}

## Get reference to JobBoard
func _get_job_board() -> Node:
	# Look for JobBoard in parent or scene tree
	var farm_manager = get_node_or_null("/root/GameWorld/FarmManager")
	if farm_manager and farm_manager.has_node("JobBoard"):
		return farm_manager.get_node("JobBoard")
	
	return null

## Force immediate evaluation for a specific monster
func force_evaluate_monster(monster: Node) -> void:
	_evaluate_monster_job(monster)

## Get all registered monsters
func get_registered_monsters() -> Array[Node]:
	return registered_monsters.duplicate()
