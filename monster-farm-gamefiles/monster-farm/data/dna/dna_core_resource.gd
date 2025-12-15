# DNA Core Resource - Defines the monster's physical foundation
# Required for every monster - only one allowed per DNA stack
extends BaseDNAResource
class_name DNACoreResource

## Body type determines base sprite and animation set
@export_enum("Quadruped", "Biped", "Serpentine", "Swarm")
var body_type: int = 0

## Movement type affects pathfinding and terrain interaction
@export_enum("Ground", "Flying", "Burrowing")
var movement_type: int = 0

## Base size multiplier for the monster
@export_range(0.5, 3.0) var base_size: float = 1.0

## Base mass affects knockback and physics
@export_range(0.5, 5.0) var base_mass: float = 1.0

## Base health points
@export_range(50, 500) var base_health: int = 100

## Base stamina for abilities and work
@export_range(50, 300) var base_stamina: int = 100

## Base movement speed
@export_range(50.0, 200.0) var base_speed: float = 100.0

## Element types this core allows (empty = all allowed)
@export var allowed_elements: Array[String] = []

## Maximum number of abilities this monster can have
@export_range(1, 6) var ability_slots: int = 2

## Maximum number of mutations this monster can carry
@export_range(0, 5) var mutation_capacity: int = 1


## Get body type as string
func get_body_type_name() -> String:
	match body_type:
		0: return "Quadruped"
		1: return "Biped"
		2: return "Serpentine"
		3: return "Swarm"
		_: return "Unknown"


## Get movement type as string
func get_movement_type_name() -> String:
	match movement_type:
		0: return "Ground"
		1: return "Flying"
		2: return "Burrowing"
		_: return "Unknown"


## Check if an element type is allowed by this core
func is_element_allowed(element_type: String) -> bool:
	if allowed_elements.is_empty():
		return true
	return element_type in allowed_elements


## Validate this DNA Core resource
func validate() -> Array[Dictionary]:
	var errors := super.validate()
	
	if base_health < 1:
		errors.append({
			"severity": "Error",
			"message": "base_health must be positive",
			"source_id": id
		})
	
	if base_stamina < 1:
		errors.append({
			"severity": "Error",
			"message": "base_stamina must be positive",
			"source_id": id
		})
	
	if base_speed <= 0:
		errors.append({
			"severity": "Error",
			"message": "base_speed must be positive",
			"source_id": id
		})
	
	if ability_slots < 1:
		errors.append({
			"severity": "Error",
			"message": "ability_slots must be at least 1",
			"source_id": id
		})
	
	return errors

