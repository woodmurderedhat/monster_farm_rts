@tool
# Ability Executor - data-driven ability runtime with targeting pipeline
# Handles validation, targeting, execution hooks, and debug fan-out
extends Node
class_name AbilityExecutor

## Import dependencies
var DamageCalculator = preload("res://systems/combat/damage_calculator.gd")

enum TargetingMode {
	SELF,
	TARGET,
	AREA,
	CONE,
	LINE
}


## Public entry point used by AI and player control
func execute_ability(ability_data: Dictionary, target: Node = null) -> bool:
	var user := get_parent() as Node2D
	if user == null:
		return false

	var request := _build_request(user, ability_data, target)
	if not _validate_request(request):
		return false

	var context := _build_target_context(request)
	if not context.get("is_valid", false):
		return false

	_apply_costs(request)
	var ok := _execute_effects(request, context)
	_apply_cooldown(request)

	if ok:
		EventBus.ability_used.emit(user, request.ability_id, context.get("primary_target"))

	return ok


## Calculate power with stat scaling
func _calculate_power(user: Node2D, ability_data: Dictionary) -> float:
	var base_power: float = ability_data.get("base_power", 10.0)
	var stat_block: Dictionary = user.get_meta("stat_block", {})
	var power_scalars: Dictionary = ability_data.get("power_scalars", {})
	if power_scalars.size() > 0:
		for stat_name in power_scalars.keys():
			var mult: float = float(power_scalars[stat_name])
			var stat_value: float = stat_block.get(stat_name, 0.0)
			base_power += stat_value * mult
	else:
		var scaling_stats: Array = ability_data.get("scaling_stats", [])
		for stat_name in scaling_stats:
			var stat_value: float = stat_block.get(stat_name, 0.0)
			base_power += stat_value * 0.1  # fallback scaling

	return base_power


func _build_request(user: Node2D, ability_data: Dictionary, target: Node) -> Dictionary:
	return {
		"user": user,
		"ability_data": ability_data,
		"ability_id": ability_data.get("id", ability_data.get("ability_id", "")),
		"targeting_type": ability_data.get("targeting_type", TargetingMode.TARGET),
		"target": target,
		"range": ability_data.get("ability_range", ability_data.get("range", 0.0)),
		"aoe_radius": ability_data.get("aoe_radius", 0.0)
	}


func _validate_request(request: Dictionary) -> bool:
	if request.ability_id == "":
		return false
	if request.targeting_type == TargetingMode.TARGET and not (request.target is Node2D):
		return false
	return true


func _build_target_context(request: Dictionary) -> Dictionary:
	var user: Node2D = request.user
	var targeting_type: int = request.targeting_type
	var ability_data: Dictionary = request.ability_data

	var ctx: Dictionary = {
		"targets": [],
		"point": user.global_position,
		"is_valid": true,
		"primary_target": null
	}

	match targeting_type:
		TargetingMode.SELF:
			ctx.targets = [user]
			ctx.primary_target = user
			ctx.point = user.global_position
		TargetingMode.TARGET:
			if request.target is Node2D:
				ctx.targets = [request.target]
				ctx.primary_target = request.target
				ctx.point = request.target.global_position
			else:
				ctx.is_valid = false
		TargetingMode.AREA:
			var center: Vector2 = user.global_position
			if request.target is Node2D:
				center = request.target.global_position
			ctx.targets = _get_targets_in_radius(user, center, ability_data.get("aoe_radius", 0.0))
			ctx.point = center
			ctx.primary_target = request.target
		TargetingMode.CONE:
			var dir_target: Node2D = request.target if request.target is Node2D else user
			ctx.targets = _get_targets_in_cone(user, dir_target.global_position, ability_data.get("ability_range", 150.0), PI / 4)
			ctx.point = dir_target.global_position
			ctx.primary_target = dir_target
		TargetingMode.LINE:
			var end_point: Vector2 = request.target.global_position if request.target is Node2D else user.global_position + Vector2.RIGHT * ability_data.get("ability_range", 150.0)
			ctx.targets = _get_targets_in_line(user, end_point, ability_data.get("ability_range", 150.0))
			ctx.point = end_point
			ctx.primary_target = request.target
		_:
			ctx.is_valid = false

	return ctx


func _apply_costs(_request: Dictionary) -> void:
	# Consumption is handled by CombatComponent stamina checks; placeholder for future costs
	pass


func _execute_effects(request: Dictionary, context: Dictionary) -> bool:
	var ability_id: String = request.ability_id
	var ability_data: Dictionary = request.ability_data
	ability_data["base_power"] = _calculate_power(request.user, ability_data)

	match request.targeting_type:
		TargetingMode.SELF:
			return _execute_self_ability(request.user, ability_id, ability_data)
		TargetingMode.TARGET:
			return _execute_target_ability(request.user, context.primary_target, ability_id, ability_data)
		TargetingMode.AREA:
			return _execute_area_ability(request.user, context.point, ability_id, ability_data, request.aoe_radius, context.targets)
		TargetingMode.CONE:
			return _execute_cone_ability(request.user, context.primary_target, ability_id, ability_data, context.targets)
		TargetingMode.LINE:
			return _execute_line_ability(request.user, context.point, ability_id, ability_data, context.targets)
		_:
			return false


func _apply_cooldown(request: Dictionary) -> void:
	if not request.ability_data.has("cooldown"):
		return
	var cooldown: float = request.ability_data.get("cooldown", 0.0)
	var stat_block: Dictionary = request.user.get_meta("stat_block", {})
	var haste: float = stat_block.get("haste", 0.0)
	var final_cd := cooldown * maxf(0.1, 1.0 - haste)
	request.ability_data["cooldown_remaining"] = final_cd


## Execute self-targeting ability
func _execute_self_ability(user: Node2D, ability_id: String, ability_data: Dictionary) -> bool:
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
func _execute_target_ability(
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
func _execute_area_ability(
	user: Node2D,
	_center: Vector2,
	ability_id: String,
	ability_data: Dictionary,
	_radius: float,
	targets: Array[Node2D]
) -> bool:
	for target in targets:
		_deal_damage(user, target, ability_data)

	EventBus.ability_used.emit(user, ability_id, user)
	return targets.size() > 0


## Execute cone ability
func _execute_cone_ability(
	user: Node2D,
	direction_target: Node2D,
	ability_id: String,
	ability_data: Dictionary,
	targets: Array[Node2D]
) -> bool:
	for target in targets:
		_deal_damage(user, target, ability_data)

	EventBus.ability_used.emit(user, ability_id, direction_target)
	return not targets.is_empty()


## Execute line ability (first collider hit)
func _execute_line_ability(
	user: Node2D,
	_end_point: Vector2,
	ability_id: String,
	ability_data: Dictionary,
	targets: Array[Node2D]
) -> bool:
	for target in targets:
		_deal_damage(user, target, ability_data)

	EventBus.ability_used.emit(user, ability_id, user)
	return not targets.is_empty()


## Deal damage to a target using the damage calculator
func _deal_damage(attacker: Node2D, target: Node2D, ability_data: Dictionary) -> bool:
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


## Get valid targets in radius using physics query
func _get_targets_in_radius(user: Node2D, position: Vector2, radius: float) -> Array[Node2D]:
	var targets: Array[Node2D] = []
	if radius <= 0.0:
		return targets

	var shape := CircleShape2D.new()
	shape.radius = radius
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0.0, position)
	params.exclude = [user]
	params.collide_with_bodies = true
	params.collide_with_areas = true

	var state := user.get_world_2d().direct_space_state
	for hit in state.intersect_shape(params, 32):
		var collider = hit.get("collider")
		if collider is Node2D and collider != user:
			targets.append(collider)

	return targets


## Filter targets within a cone (origin = user)
func _get_targets_in_cone(user: Node2D, toward: Vector2, radius: float, half_angle: float) -> Array[Node2D]:
	var base_targets := _get_targets_in_radius(user, user.global_position, radius)
	var dir := user.global_position.direction_to(toward)
	var filtered: Array[Node2D] = []
	for target in base_targets:
		var target_dir := user.global_position.direction_to(target.global_position)
		if abs(dir.angle_to(target_dir)) <= half_angle:
			filtered.append(target)
	return filtered


## Return first collider along a line; can be expanded for piercing later
func _get_targets_in_line(user: Node2D, end_point: Vector2, max_distance: float) -> Array[Node2D]:
	var results: Array[Node2D] = []
	var start := user.global_position
	var dir := (end_point - start).normalized()
	var state := user.get_world_2d().direct_space_state
	var params := PhysicsRayQueryParameters2D.create(start, start + dir * max_distance)
	params.exclude = [user]
	params.collide_with_areas = true
	params.collide_with_bodies = true
	var ray := state.intersect_ray(params)
	if ray.has("collider") and ray.get("collider") is Node2D:
		var hit_collider: Node2D = ray.get("collider")
		results.append(hit_collider)
	return results

