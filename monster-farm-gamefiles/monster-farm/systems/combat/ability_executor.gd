# Ability Executor - Executes ability effects when abilities are used
# Handles damage, healing, buffs, and status effects
extends Node
class_name AbilityExecutor

## Import dependencies
var DamageCalculator = preload("res://systems/combat/damage_calculator.gd")


## Execute an ability
## Returns true if ability was successfully executed
static func execute(
	user: Node2D,
	ability_data: Dictionary,
	target: Node = null
) -> bool:
	var ability_id: String = ability_data.get("id", "")
	var targeting_type: int = ability_data.get("targeting_type", 1)
	var aoe_radius: float = ability_data.get("aoe_radius", 0)
	
	# Update base power with stat scaling
	ability_data["base_power"] = _calculate_power(user, ability_data)
	
	# Execute based on targeting type
	match targeting_type:
		0:  # Self
			return _execute_self_ability(user, ability_id, ability_data)
		1:  # Target
			if target is Node2D:
				return _execute_target_ability(user, target as Node2D, ability_id, ability_data)
		2:  # Area
			if target is Node2D:
				return _execute_area_ability(user, target as Node2D, ability_id, ability_data, aoe_radius)
		3:  # Cone
			if target is Node2D:
				return _execute_cone_ability(user, target as Node2D, ability_id, ability_data)
	
	return false


## Calculate power with stat scaling
static func _calculate_power(user: Node2D, ability_data: Dictionary) -> float:
	var base_power: float = ability_data.get("base_power", 10)
	var scaling_stats: Array = ability_data.get("scaling_stats", [])
	
	var stat_block: Dictionary = user.get_meta("stat_block", {})
	
	for stat_name in scaling_stats:
		var stat_value: float = stat_block.get(stat_name, 0)
		base_power += stat_value * 0.1  # 10% scaling per stat point
	
	return base_power


## Execute self-targeting ability
static func _execute_self_ability(user: Node2D, ability_id: String, ability_data: Dictionary) -> bool:
	var power: float = ability_data.get("base_power", 10.0)
	
	match ability_id:
		"shield":
			# Apply shield buff
			user.set_meta("shield_amount", power)
			EventBus.ability_used.emit(user, ability_id, user)
			return true
		"heal":
			# Heal self
			var health_comp := user.get_node_or_null("HealthComponent") as HealthComponent
			if health_comp:
				health_comp.heal(power)
				EventBus.ability_used.emit(user, ability_id, user)
				return true
	
	return false


## Execute single-target ability
static func _execute_target_ability(
	user: Node2D,
	target: Node2D,
	ability_id: String,
	ability_data: Dictionary
) -> bool:
	match ability_id:
		"bite", "attack", "fireball", "charge":
			return _deal_damage(user, target, ability_data)
		"heal":
			var health_comp := target.get_node_or_null("HealthComponent") as HealthComponent
			if health_comp:
				var power: float = ability_data.get("base_power", 10.0)
				health_comp.heal(power, user)
				EventBus.ability_used.emit(user, ability_id, target)
				return true
		"poison_spit":
			# Deal damage and apply poison (TODO: status effects)
			_deal_damage(user, target, ability_data)
			EventBus.ability_used.emit(user, ability_id, target)
			return true
		_:
			# Default: deal damage
			return _deal_damage(user, target, ability_data)
	
	return false


## Execute area ability
static func _execute_area_ability(
	user: Node2D,
	center: Node2D,
	ability_id: String,
	ability_data: Dictionary,
	radius: float
) -> bool:
	# Get all targets in radius
	var targets := _get_targets_in_radius(center.global_position, radius, user)
	
	for target in targets:
		_deal_damage(user, target, ability_data)
	
	EventBus.ability_used.emit(user, ability_id, center)
	return targets.size() > 0


## Execute cone ability
static func _execute_cone_ability(
	user: Node2D,
	direction_target: Node2D,
	ability_id: String,
	ability_data: Dictionary
) -> bool:
	# Cone abilities hit targets in a cone shape
	# Simplified implementation
	var targets := _get_targets_in_radius(user.global_position, 150.0, user)
	var direction := user.global_position.direction_to(direction_target.global_position)
	
	for target in targets:
		var target_dir := user.global_position.direction_to(target.global_position)
		var angle := direction.angle_to(target_dir)
		if abs(angle) < PI / 4:  # 45 degree cone
			_deal_damage(user, target, ability_data)
	
	EventBus.ability_used.emit(user, ability_id, direction_target)
	return true


## Deal damage to a target using the damage calculator
static func _deal_damage(attacker: Node2D, target: Node2D, ability_data: Dictionary) -> bool:
	var damage_calc = preload("res://systems/combat/damage_calculator.gd")
	
	# Check if hit lands
	if not damage_calc.roll_hit(attacker, target):
		EventBus.ability_used.emit(attacker, ability_data.get("id", ""), target)
		return false  # Miss!
	
	# Roll for critical
	var is_critical: bool = damage_calc.roll_critical(attacker)
	
	# Calculate damage
	var damage: float = damage_calc.calculate_damage(attacker, target, ability_data)
	
	# Apply damage
	var final_damage: float = damage_calc.apply_damage(target, damage, attacker, is_critical)
	
	# Broadcast event
	EventBus.damage_dealt.emit(attacker, target, final_damage)
	EventBus.ability_used.emit(attacker, ability_data.get("id", ""), target)
	return true


## Get all valid targets in a radius
static func _get_targets_in_radius(_position: Vector2, _radius: float, _exclude: Node2D) -> Array[Node2D]:
	var targets: Array[Node2D] = []
	# This would use physics queries in a real implementation
	# For now, return empty - needs scene tree access
	return targets

