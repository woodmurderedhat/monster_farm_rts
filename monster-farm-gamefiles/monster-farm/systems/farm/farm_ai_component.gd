# Farm AI Component - Autonomous job selection for farm monsters
# Scores and selects jobs based on DNA, needs, and environment
extends Node
class_name FarmAIComponent

## How often to re-evaluate jobs (seconds)
@export var evaluation_interval: float = 3.0

## Lock-in time after selecting a job (prevents thrashing)
@export var lock_in_time: float = 5.0

## Timer for evaluation
var eval_timer: float = 0.0

## Time remaining in lock-in
var lock_in_remaining: float = 0.0

## Reference to parent entity
var entity: Node2D

## Component references
var job_component: JobComponent
var needs_component: NeedsComponent
var stress_component: StressComponent
var movement_component: MovementComponent

## Reference to job board
var job_board: JobBoard

## DNA-based work affinity
var work_affinity: Dictionary = {}


func _ready() -> void:
	entity = get_parent() as Node2D
	job_component = entity.get_node_or_null("JobComponent")
	needs_component = entity.get_node_or_null("NeedsComponent")
	stress_component = entity.get_node_or_null("StressComponent")
	movement_component = entity.get_node_or_null("MovementComponent")
	_initialize_from_meta()


func _process(delta: float) -> void:
	# Update lock-in timer
	if lock_in_remaining > 0:
		lock_in_remaining -= delta
	
	# Update evaluation timer
	eval_timer += delta
	if eval_timer >= evaluation_interval:
		eval_timer = 0.0
		_evaluate_jobs()


## Initialize from entity metadata
func _initialize_from_meta() -> void:
	if entity:
		var ai_config: Dictionary = entity.get_meta("ai_config", {})
		work_affinity = ai_config.get("work_affinity", {})


## Set the job board reference
func set_job_board(board: JobBoard) -> void:
	job_board = board


## Evaluate and select the best job
func _evaluate_jobs() -> void:
	if not job_board or not job_component:
		return
	
	# Don't re-evaluate if locked in
	if lock_in_remaining > 0 and job_component.has_job():
		return
	
	# Get available jobs
	var jobs := job_board.get_available_jobs_for(entity)
	if jobs.is_empty():
		return
	
	# Score each job
	var best_score := -999.0
	var best_job: Dictionary = {}
	
	for job in jobs:
		var score := _score_job(job)
		if score > best_score:
			best_score = score
			best_job = job
	
	# Select best job if better than current
	if not best_job.is_empty() and best_score > 0:
		_select_job(best_job)


## Score a job for this monster
func _score_job(job: Dictionary) -> float:
	var job_type: JobResource = job.type
	var score := job_type.base_priority * 10.0
	
	# DNA Affinity bonus
	var affinity: float = work_affinity.get(job_type.work_type, 1.0)
	score += (affinity - 1.0) * 20.0
	
	# Need urgency bonus
	if needs_component:
		score += _get_need_bonus(job_type.work_type)
	
	# Stress penalty
	if stress_component:
		var stress_percent := stress_component.get_stress_percent()
		score -= stress_percent * 15.0
	
	# Danger penalty (based on DNA courage)
	var ai_config: Dictionary = entity.get_meta("ai_config", {})
	var aggression: float = ai_config.get("aggression", 0.5)
	var danger_penalty := job_type.danger_level * (1.0 - aggression) * 20.0
	score -= danger_penalty
	
	# Distance penalty
	var location: Vector2 = job.location
	var distance := entity.global_position.distance_to(location)
	score -= distance * 0.01
	
	return score


## Get need-based bonus for a work type
func _get_need_bonus(work_type: String) -> float:
	if not needs_component:
		return 0.0
	
	match work_type:
		"feeding":
			return needs_component.get_urgency("hunger") * 0.3
		"resting":
			return needs_component.get_urgency("rest") * 0.5
		"social":
			return needs_component.get_urgency("social") * 0.2
		"combat", "patrol":
			return needs_component.get_urgency("purpose") * 0.2
		_:
			return 0.0


## Select and start a job
func _select_job(job: Dictionary) -> void:
	# Cancel current job if any
	if job_component.has_job():
		job_component.cancel_job()
	
	# Claim the job
	if job_board.claim_job(job.id, entity):
		# Assign to job component
		var job_data := {
			"id": job.id,
			"type": job.type.work_type,
			"location": job.location,
			"duration": job.type.work_duration,
			"data": job.data
		}
		job_component.assign_job(job_data)
		lock_in_remaining = lock_in_time
		
		# Move to job location
		if movement_component:
			movement_component.move_to(job.location)

