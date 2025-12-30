# Job Component - Manages monster job assignment and work behavior
extends Node
class_name JobComponent

## Emitted when a job is assigned
signal job_assigned(job_data: Dictionary)

## Emitted when a job is completed
signal job_completed(job_data: Dictionary)

## Emitted when a job is cancelled
signal job_cancelled(job_data: Dictionary)

## Emitted when work progress updates
signal work_progress(progress: float)

## Current job data
var current_job: Dictionary = {}

## Whether monster is currently working
var is_working: bool = false

## Work progress (0-1)
var work_progress_value: float = 0.0

## Work affinity modifiers from DNA
var work_affinity: Dictionary = {}

## Reference to parent entity
var entity: Node2D

## Reference to stress component
var stress_component: StressComponent


func _ready() -> void:
	entity = get_parent() as Node2D
	stress_component = entity.get_node_or_null("StressComponent")
	_initialize_from_meta()


## Initialize from entity metadata
func _initialize_from_meta() -> void:
	if entity and entity.has_meta("ai_config"):
		var config: Dictionary = entity.get_meta("ai_config")
		work_affinity = config.get("work_affinity", {})


## Assign a job to this monster
func assign_job(job_data: Dictionary) -> bool:
	if is_working:
		return false
	
	current_job = job_data.duplicate()
	is_working = true
	work_progress_value = 0.0
	
	job_assigned.emit(current_job)
	return true


## Cancel current job
func cancel_job() -> void:
	if not is_working:
		return
	
	var cancelled_job := current_job.duplicate()
	current_job = {}
	is_working = false
	work_progress_value = 0.0
	
	job_cancelled.emit(cancelled_job)


## Complete current job
func complete_job() -> void:
	if not is_working:
		return
	
	var completed_job := current_job.duplicate()
	current_job = {}
	is_working = false
	work_progress_value = 0.0
	
	job_completed.emit(completed_job)


## Add work progress
func add_work_progress(amount: float) -> void:
	if not is_working:
		return
	
	# Apply work efficiency modifier from stress
	var efficiency := 1.0
	if stress_component:
		efficiency = stress_component.get_work_efficiency()
	
	# Apply job affinity modifier
	var job_type: String = current_job.get("type", "")
	var affinity : float = work_affinity.get(job_type, 1.0)
	
	work_progress_value += amount * efficiency * affinity
	work_progress_value = clampf(work_progress_value, 0.0, 1.0)
	
	work_progress.emit(work_progress_value)
	
	if work_progress_value >= 1.0:
		complete_job()


## Get the affinity for a job type
func get_job_affinity(job_type: String) -> float:
	return work_affinity.get(job_type, 1.0)


## Check if this monster prefers a job type
func prefers_job(job_type: String) -> bool:
	return get_job_affinity(job_type) > 1.0


## Get current job type
func get_current_job_type() -> String:
	return current_job.get("type", "")


## Check if monster has a job
func has_job() -> bool:
	return is_working and not current_job.is_empty()
