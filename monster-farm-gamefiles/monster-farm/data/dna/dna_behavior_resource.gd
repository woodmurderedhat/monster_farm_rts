# DNA Behavior Resource - Defines personality and AI tendencies
# Exactly one behavior profile required per monster
extends BaseDNAResource
class_name DNABehaviorResource

## Aggression level - affects combat initiation and target priority
@export_range(0.0, 1.0) var aggression: float = 0.5

## Loyalty level - affects following commands and staying near owner
@export_range(0.0, 1.0) var loyalty: float = 0.5

## Curiosity level - affects exploration and interaction with objects
@export_range(0.0, 1.0) var curiosity: float = 0.5

## Stress tolerance - how well the monster handles negative events
@export_range(0.0, 1.0) var stress_tolerance: float = 0.5

## Work affinity - preference multipliers for different job types
## Keys are job type names (e.g., "farming", "mining"), values are preference weights
@export var work_affinity: Dictionary = {}

## Combat roles this behavior supports
## Valid roles: "tank", "dps", "support", "scout"
@export var combat_roles: Array[String] = []


## Get the primary combat role (first in list)
func get_primary_combat_role() -> String:
	if combat_roles.is_empty():
		return "dps"  # Default role
	return combat_roles[0]


## Check if this behavior supports a specific combat role
func has_combat_role(role: String) -> bool:
	return role in combat_roles


## Get work affinity for a specific job type (1.0 = neutral)
func get_work_affinity(job_type: String) -> float:
	return work_affinity.get(job_type, 1.0)


## Calculate overall temperament score (for AI decisions)
func get_temperament_score() -> float:
	# Higher = more aggressive/active, lower = more passive/defensive
	return (aggression + curiosity - (1.0 - loyalty)) / 2.0


## Validate this DNA Behavior resource
func validate() -> Array[Dictionary]:
	var errors := super.validate()
	
	if combat_roles.is_empty():
		errors.append({
			"severity": "Error",
			"message": "At least one combat_role must be defined",
			"source_id": id
		})
	
	var valid_roles := ["tank", "dps", "support", "scout"]
	for role in combat_roles:
		if role not in valid_roles:
			errors.append({
				"severity": "Warning",
				"message": "Unknown combat role: " + role,
				"source_id": id
			})
	
	return errors

