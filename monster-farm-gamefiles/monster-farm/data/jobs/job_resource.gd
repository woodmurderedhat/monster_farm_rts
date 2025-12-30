# Job Resource - Defines a type of work that can be performed
extends Resource
class_name JobResource

## Unique identifier for this job type
@export var job_id: String = ""

## Display name for UI
@export var display_name: String = ""

## Description of the job
@export_multiline var description: String = ""

## Base priority (higher = more important)
@export var base_priority: float = 1.0

## Fulfills a monster's need category (used by AI scoring)
@export var satisfies_need: String = "none"

## Whether this job repeats after completion
@export var is_repeating: bool = true

## Maximum simultaneous workers (-1 for unlimited)
@export var max_workers: int = -1

## Tags required for a monster to perform this job
@export var required_tags: Array[String] = []

## Tags that prevent a monster from performing this job
@export var forbidden_tags: Array[String] = []

## Work type category (farming, combat, maintenance, etc.)
@export var work_type: String = "general"

## Danger level (0-1, affects scoring for cautious monsters)
@export var danger_level: float = 0.0

## Time to complete the job in seconds
@export var work_duration: float = 5.0

## Stamina cost to perform the job
@export var stamina_cost: float = 10.0

## Whether this job can be interrupted
@export var interruptible: bool = true

## Whether this job requires a specific location
@export var requires_location: bool = true


## Check if a monster can perform this job based on tags
func can_perform(monster_tags: Array[String]) -> bool:
	# Check required tags
	for required in required_tags:
		if required not in monster_tags:
			return false
	
	# Check forbidden tags
	for forbidden in forbidden_tags:
		if forbidden in monster_tags:
			return false
	
	return true

