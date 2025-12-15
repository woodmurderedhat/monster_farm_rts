# Combat Component - Manages monster combat state and abilities
extends Node
class_name CombatComponent

## Emitted when entering combat
signal entered_combat

## Emitted when leaving combat
signal left_combat

## Emitted when an ability is used
signal ability_used(ability_id: String, target: Node)

## Emitted when an ability goes on cooldown
signal ability_cooldown_started(ability_id: String, duration: float)

## Whether the monster is in combat
var in_combat: bool = false

## Current target
var current_target: Node2D = null

## Abilities and their cooldowns
var abilities: Array[Dictionary] = []

## Cooldown timers (ability_id -> remaining time)
var cooldowns: Dictionary = {}

## Combat role from DNA
var combat_role: String = "dps"

## Reference to parent entity
var entity: Node2D

## Reference to health component
var health_component: HealthComponent

## Reference to stamina component
var stamina_component: StaminaComponent


func _ready() -> void:
	entity = get_parent() as Node2D
	health_component = entity.get_node_or_null("HealthComponent")
	stamina_component = entity.get_node_or_null("StaminaComponent")
	_initialize_from_meta()


func _process(delta: float) -> void:
	_update_cooldowns(delta)


## Initialize from entity metadata
func _initialize_from_meta() -> void:
	if entity and entity.has_meta("abilities"):
		abilities = entity.get_meta("abilities")
	
	if entity and entity.has_meta("ai_config"):
		var config: Dictionary = entity.get_meta("ai_config")
		var roles: Array = config.get("combat_roles", ["dps"])
		if roles.size() > 0:
			combat_role = roles[0]


## Enter combat state
func enter_combat(target: Node2D = null) -> void:
	if not in_combat:
		in_combat = true
		current_target = target
		entered_combat.emit()


## Leave combat state
func leave_combat() -> void:
	if in_combat:
		in_combat = false
		current_target = null
		left_combat.emit()


## Set the current target
func set_target(target: Node2D) -> void:
	current_target = target


## Try to use an ability by ID
## Returns true if successful
func use_ability(ability_id: String, target: Node = null) -> bool:
	var ability := _get_ability(ability_id)
	if ability.is_empty():
		return false
	
	# Check if enabled
	if not ability.get("enabled", true):
		return false
	
	# Check cooldown
	if is_on_cooldown(ability_id):
		return false
	
	# Check energy cost
	var energy_cost: float = ability.get("energy_cost", 0)
	if stamina_component and not stamina_component.has_stamina(energy_cost):
		return false
	
	# Consume stamina
	if stamina_component:
		stamina_component.consume(energy_cost)
	
	# Start cooldown
	var cooldown: float = ability.get("cooldown", 1.0)
	cooldowns[ability_id] = cooldown
	ability_cooldown_started.emit(ability_id, cooldown)
	
	# Emit ability used
	ability_used.emit(ability_id, target)
	
	return true


## Check if ability is on cooldown
func is_on_cooldown(ability_id: String) -> bool:
	return cooldowns.get(ability_id, 0.0) > 0.0


## Get remaining cooldown for ability
func get_cooldown_remaining(ability_id: String) -> float:
	return cooldowns.get(ability_id, 0.0)


## Get ability data by ID
func _get_ability(ability_id: String) -> Dictionary:
	for ability in abilities:
		if ability.get("id") == ability_id:
			return ability
	return {}


## Update cooldowns
func _update_cooldowns(delta: float) -> void:
	for ability_id in cooldowns.keys():
		cooldowns[ability_id] = maxf(0, cooldowns[ability_id] - delta)


## Get all available (off cooldown) abilities
func get_available_abilities() -> Array[Dictionary]:
	var available: Array[Dictionary] = []
	for ability in abilities:
		var ability_id: String = ability.get("id", "")
		if ability.get("enabled", true) and not is_on_cooldown(ability_id):
			available.append(ability)
	return available

