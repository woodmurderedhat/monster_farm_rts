# Movement Component - Handles monster movement and navigation
extends Node
class_name MovementComponent

## Emitted when movement starts
signal movement_started

## Emitted when destination is reached
signal destination_reached

## Emitted when movement is blocked
signal movement_blocked

## Movement speed in pixels per second
@export var move_speed: float = 100.0

## Acceleration rate
@export var acceleration: float = 500.0

## Reference to parent entity (CharacterBody2D)
var entity: CharacterBody2D

## Current velocity
var velocity: Vector2 = Vector2.ZERO

## Target position for navigation
var target_position: Vector2 = Vector2.ZERO

## Whether we're currently moving to a target
var is_moving: bool = false

## Minimum distance to consider "arrived"
var arrival_threshold: float = 10.0

## Navigation agent reference
var nav_agent: NavigationAgent2D


func _ready() -> void:
	entity = get_parent() as CharacterBody2D
	nav_agent = entity.get_node_or_null("NavigationAgent2D")
	_initialize_from_meta()


func _physics_process(delta: float) -> void:
	if is_moving:
		_process_movement(delta)


## Initialize from entity metadata
func _initialize_from_meta() -> void:
	if entity and entity.has_meta("stat_block"):
		var stats: Dictionary = entity.get_meta("stat_block")
		move_speed = stats.get("speed", move_speed)


## Move to a target position
func move_to(position: Vector2) -> void:
	target_position = position
	is_moving = true
	
	if nav_agent:
		nav_agent.target_position = position
	
	movement_started.emit()


## Stop movement immediately
func stop() -> void:
	is_moving = false
	velocity = Vector2.ZERO
	if entity:
		entity.velocity = Vector2.ZERO


## Get direction to current target
func get_direction_to_target() -> Vector2:
	if not entity:
		return Vector2.ZERO
	
	if nav_agent and nav_agent.is_navigation_finished() == false:
		return entity.global_position.direction_to(nav_agent.get_next_path_position())
	
	return entity.global_position.direction_to(target_position)


## Check if at target
func is_at_target() -> bool:
	if not entity:
		return true
	return entity.global_position.distance_to(target_position) < arrival_threshold


## Process movement each frame
func _process_movement(delta: float) -> void:
	if not entity:
		return
	
	# Check if arrived
	if is_at_target():
		stop()
		destination_reached.emit()
		return
	
	# Get movement direction
	var direction := get_direction_to_target()
	
	# Calculate desired velocity
	var desired_velocity := direction * move_speed
	
	# Smoothly accelerate to desired velocity
	velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	
	# Apply to entity
	entity.velocity = velocity
	entity.move_and_slide()
	
	# Check if blocked
	if entity.get_slide_collision_count() > 0:
		var collision := entity.get_slide_collision(0)
		if collision:
			movement_blocked.emit()


## Get current movement speed
func get_current_speed() -> float:
	return velocity.length()


## Check if currently moving
func get_is_moving() -> bool:
	return is_moving and velocity.length_squared() > 1.0

