# Monster Base - Main script for monster entities
# All monster logic is delegated to components
extends CharacterBody2D
class_name Monster

## Emitted when monster is selected
signal selected

## Emitted when monster is deselected
signal deselected

## Emitted when monster dies
signal died

## Whether this monster is selected by the player
var is_selected: bool = false

## Components (cached for quick access)
@onready var health_component: HealthComponent = $HealthComponent
@onready var stamina_component: StaminaComponent = $StaminaComponent
@onready var stress_component: StressComponent = $StressComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var combat_component: CombatComponent = $CombatComponent
@onready var job_component: JobComponent = $JobComponent


func _ready() -> void:
	_connect_component_signals()


## Connect to component signals
func _connect_component_signals() -> void:
	if health_component:
		health_component.died.connect(_on_died)


## Select this monster
func select() -> void:
	is_selected = true
	selected.emit()
	# Visual feedback handled by selection system


## Deselect this monster
func deselect() -> void:
	is_selected = false
	deselected.emit()


## Get the DNA stack that created this monster
func get_dna_stack() -> Resource:
	return get_meta("dna_stack", null)


## Get the stat block
func get_stat_block() -> Dictionary:
	return get_meta("stat_block", {})


## Get a specific stat value
func get_stat(stat_name: String, default: float = 0.0) -> float:
	var stats: Dictionary = get_stat_block()
	return stats.get(stat_name, default)


## Get AI configuration
func get_ai_config() -> Dictionary:
	return get_meta("ai_config", {})


## Get instability level
func get_instability() -> float:
	return get_meta("instability", 0.0)


## Command: Move to position
func command_move(target_position: Vector2) -> void:
	if movement_component:
		movement_component.move_to(target_position)
	
	# Moving cancels current job
	if job_component and job_component.is_working:
		job_component.cancel_job()


## Command: Attack target
func command_attack(target: Node2D) -> void:
	if combat_component:
		combat_component.enter_combat(target)
		combat_component.set_target(target)


## Command: Stop current action
func command_stop() -> void:
	if movement_component:
		movement_component.stop()
	if combat_component:
		combat_component.leave_combat()
	if job_component:
		job_component.cancel_job()


## Handle death
func _on_died() -> void:
	died.emit()
	# Disable processing
	set_physics_process(false)
	set_process(false)
	# Could play death animation here

