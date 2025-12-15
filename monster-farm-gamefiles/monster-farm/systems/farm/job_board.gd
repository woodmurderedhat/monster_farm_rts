# Job Board - Central registry of available jobs in the farm
# Monsters query the job board to find work
extends Node
class_name JobBoard

## All available job instances
var available_jobs: Array[Dictionary] = []

## Jobs currently being worked on
var claimed_jobs: Dictionary = {}  # job_id -> worker

## Job types registered in the system
var job_types: Dictionary = {}  # job_type_id -> JobResource


func _ready() -> void:
	_load_job_types()


## Load all job type resources
func _load_job_types() -> void:
	var job_dir := "res://data/jobs/"
	var dir := DirAccess.open(job_dir)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var job := load(job_dir + file_name) as JobResource
			if job:
				job_types[job.job_id] = job
		file_name = dir.get_next()


## Post a new job to the board
func post_job(job_type_id: String, location: Vector2, data: Dictionary = {}) -> String:
	var job_type := job_types.get(job_type_id) as JobResource
	if not job_type:
		push_warning("Unknown job type: " + job_type_id)
		return ""
	
	var job_instance := {
		"id": _generate_job_id(),
		"type_id": job_type_id,
		"type": job_type,
		"location": location,
		"data": data,
		"posted_time": Time.get_ticks_msec()
	}
	
	available_jobs.append(job_instance)
	EventBus.job_posted.emit(job_instance)
	
	return job_instance.id


## Claim a job for a worker
func claim_job(job_id: String, worker: Node2D) -> bool:
	for i in range(available_jobs.size()):
		if available_jobs[i].id == job_id:
			var job := available_jobs[i]
			available_jobs.remove_at(i)
			claimed_jobs[job_id] = {"job": job, "worker": worker}
			EventBus.job_claimed.emit(job, worker)
			return true
	return false


## Complete a job
func complete_job(job_id: String) -> void:
	if job_id in claimed_jobs:
		var data: Dictionary = claimed_jobs[job_id]
		var job: Dictionary = data.job
		var worker: Node2D = data.worker
		claimed_jobs.erase(job_id)
		EventBus.job_completed.emit(job, worker)


## Cancel a job (return to board)
func cancel_job(job_id: String) -> void:
	if job_id in claimed_jobs:
		var data: Dictionary = claimed_jobs[job_id]
		var job: Dictionary = data.job
		claimed_jobs.erase(job_id)
		available_jobs.append(job)


## Get all available jobs for a monster
func get_available_jobs_for(monster: Node2D) -> Array[Dictionary]:
	var monster_tags: Array[String] = []
	var dna_stack: Resource = monster.get_meta("dna_stack", null)
	if dna_stack:
		monster_tags = dna_stack.get("tags") if dna_stack.get("tags") else []
	
	var valid_jobs: Array[Dictionary] = []
	for job in available_jobs:
		var job_type: JobResource = job.type
		if job_type.can_perform(monster_tags):
			valid_jobs.append(job)
	
	return valid_jobs


## Generate unique job ID
func _generate_job_id() -> String:
	return "job_%d_%d" % [Time.get_ticks_msec(), randi() % 10000]

