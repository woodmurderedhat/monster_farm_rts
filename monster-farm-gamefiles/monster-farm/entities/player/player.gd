## Player character entity - controlled directly by the player
## Utility-focused combatant that supports summoned monsters
extends CharacterBody2D
class_name Player

signal player_died()
signal ability_cast(ability_id: String)

@export var move_speed: float = 200.0
@export var dash_speed: float = 400.0
@export var dash_duration: float = 0.3

## Player stats
var max_health: float = 100.0
var current_health: float = 100.0
var max_energy: float = 100.0
var current_energy: float = 100.0
var energy_regen: float = 10.0  # Per second

## Abilities
var abilities: Array[Dictionary] = []
var ability_cooldowns: Dictionary = {}

## State
var is_dashing: bool = false
var dash_time_remaining: float = 0.0
var is_dead: bool = false

## Components (added as children)
@onready var health_component: Node = null
@onready var combat_component: Node = null

func _ready() -> void:
	add_to_group("player")
	_initialize_components()
	_load_player_abilities()

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	_handle_movement(delta)
	_regenerate_energy(delta)
	_update_cooldowns(delta)
	
	move_and_slide()

## Initialize player components
func _initialize_components() -> void:
	# Check for existing components or create them
	health_component = get_node_or_null("HealthComponent")
	combat_component = get_node_or_null("CombatComponent")

## Load player abilities
func _load_player_abilities() -> void:
	# Default player abilities (utility-focused)
	abilities = [
		{
			"ability_id": "player_heal",
			"display_name": "Heal",
			"cooldown": 8.0,
			"energy_cost": 30.0,
			"description": "Heal self or target monster"
		},
		{
			"ability_id": "player_buff",
			"display_name": "Empower",
			"cooldown": 12.0,
			"energy_cost": 25.0,
			"description": "Buff a monster's damage"
		},
		{
			"ability_id": "player_stun",
			"display_name": "Stun Gadget",
			"cooldown": 10.0,
			"energy_cost": 20.0,
			"description": "Stun target enemy"
		},
		{
			"ability_id": "player_dash",
			"display_name": "Dash",
			"cooldown": 5.0,
			"energy_cost": 15.0,
			"description": "Quick dash in movement direction"
		}
	]
	
	# Initialize cooldowns
	for ability in abilities:
		ability_cooldowns[ability.ability_id] = 0.0

## Handle player movement
func _handle_movement(delta: float) -> void:
	var input_vector := Vector2.ZERO
	
	# Get input
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	
	# Apply movement
	if is_dashing:
		dash_time_remaining -= delta
		if dash_time_remaining <= 0:
			is_dashing = false
		# Movement already set during dash
	else:
		velocity = input_vector * move_speed

## Regenerate energy over time
func _regenerate_energy(delta: float) -> void:
	if current_energy < max_energy:
		current_energy = min(max_energy, current_energy + energy_regen * delta)

## Update ability cooldowns
func _update_cooldowns(delta: float) -> void:
	for ability_id in ability_cooldowns:
		if ability_cooldowns[ability_id] > 0:
			ability_cooldowns[ability_id] -= delta

## Cast an ability
func cast_ability(ability_index: int, target: Node = null) -> bool:
	if ability_index < 0 or ability_index >= abilities.size():
		return false
	
	var ability = abilities[ability_index]
	
	# Check cooldown
	if ability_cooldowns[ability.ability_id] > 0:
		return false
	
	# Check energy cost
	if current_energy < ability.energy_cost:
		return false
	
	# Consume energy
	current_energy -= ability.energy_cost
	
	# Set cooldown
	ability_cooldowns[ability.ability_id] = ability.cooldown
	
	# Execute ability
	_execute_ability(ability, target)
	
	ability_cast.emit(ability.ability_id)
	EventBus.player_ability_cast.emit(ability.ability_id, target)
	
	return true

## Execute specific ability logic
func _execute_ability(ability: Dictionary, target: Node) -> void:
	match ability.ability_id:
		"player_dash":
			_perform_dash()
		"player_heal":
			_perform_heal(target)
		"player_buff":
			_perform_buff(target)
		"player_stun":
			_perform_stun(target)

## Perform dash
func _perform_dash() -> void:
	if velocity.length() > 0:
		var dash_direction = velocity.normalized()
		velocity = dash_direction * dash_speed
		is_dashing = true
		dash_time_remaining = dash_duration

## Perform heal ability
func _perform_heal(target: Node) -> void:
	var heal_target = target if target != null else self
	
	if heal_target.has_node("HealthComponent"):
		var health_comp = heal_target.get_node("HealthComponent")
		health_comp.heal(30.0)

## Perform buff ability
func _perform_buff(target: Node) -> void:
	if target == null:
		return
	
	# Apply damage buff to target monster
	EventBus.monster_buffed.emit(target, "damage", 1.5, 10.0)  # 50% damage for 10 seconds

## Perform stun ability
func _perform_stun(target: Node) -> void:
	if target == null:
		return
	
	# Apply stun status
	EventBus.enemy_stunned.emit(target, 2.0)  # 2 second stun

## Take damage
func take_damage(amount: float, source: Node = null) -> void:
	if is_dead:
		return
	
	current_health -= amount
	EventBus.player_damaged.emit(amount, source)
	
	if current_health <= 0:
		_die()

## Heal
func heal(amount: float) -> void:
	current_health = min(max_health, current_health + amount)
	EventBus.player_healed.emit(amount)

## Die
func _die() -> void:
	is_dead = true
	current_health = 0
	player_died.emit()
	EventBus.player_died.emit()

## Respawn
func respawn(spawn_position: Vector2) -> void:
	global_position = spawn_position
	current_health = max_health
	current_energy = max_energy
	is_dead = false
	is_dashing = false
	
	# Reset all cooldowns
	for ability_id in ability_cooldowns:
		ability_cooldowns[ability_id] = 0.0

## Get ability info for UI
func get_ability_info(index: int) -> Dictionary:
	if index >= 0 and index < abilities.size():
		var ability = abilities[index]
		ability["current_cooldown"] = ability_cooldowns.get(ability.ability_id, 0.0)
		return ability
	return {}

## Serialize for save system
func serialize() -> Dictionary:
	return {
		"position": {"x": global_position.x, "y": global_position.y},
		"current_health": current_health,
		"current_energy": current_energy,
		"ability_cooldowns": ability_cooldowns
	}

## Deserialize from save data
func deserialize(data: Dictionary) -> void:
	if data.has("position"):
		var pos = data.position
		global_position = Vector2(pos.x, pos.y)
	
	current_health = data.get("current_health", max_health)
	current_energy = data.get("current_energy", max_energy)
	ability_cooldowns = data.get("ability_cooldowns", {})
