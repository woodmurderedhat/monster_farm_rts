extends Node
## Damage calculation system following combat-and-ability-spec.md

# Final Damage = (BasePower + (Attack * 0.1) - (Defense / 2)) * ElementMultiplier * CritMultiplier * InstabilityBonus

static func calculate_damage(attacker: Node2D, defender: Node2D, ability: Dictionary) -> float:
	var attacker_stats = attacker.get_meta("stat_block", {})
	var defender_stats = defender.get_meta("stat_block", {})
	
	# Get base power from ability
	var base_power = ability.get("base_power", 10.0)
	var attack = attacker_stats.get("attack", 0.0)
	var defense = defender_stats.get("defense", defender_stats.get("armor", 0.0))

	# Additional scaling via power_scalars
	var power_scalars: Dictionary = ability.get("power_scalars", {})
	for stat_name in power_scalars.keys():
		base_power += attacker_stats.get(stat_name, 0.0) * float(power_scalars[stat_name])
	
	# Base calculation
	var damage = base_power + (attack * 0.1) - (defense / 2.0)

	# Elemental effectiveness (simple resist dictionary on defender meta)
	var element_type: String = ability.get("element_type", "")
	if element_type != "":
		var resistances: Dictionary = defender.get_meta("element_resistances", {})
		var resist: float = clampf(resistances.get(element_type, 0.0), -1.0, 1.0)
		damage *= (1.0 - resist)

	# Apply critical hit (1.5x damage)
	if roll_critical(attacker):
		damage *= 1.5

	# Apply instability bonus (chaotic damage from mutations)
	var instability = attacker.get_meta("instability", 0.0)
	if instability > 0:
		damage *= (1.0 + instability * 0.5)  # Up to 50% bonus at 100% instability

	# Ensure minimum damage of 1
	return maxf(1.0, damage)


static func get_hit_chance(attacker: Node2D, defender: Node2D) -> float:
	var attacker_stats = attacker.get_meta("stat_block", {})
	var defender_stats = defender.get_meta("stat_block", {})
	
	var accuracy = attacker_stats.get("accuracy", 0.85)
	var evasion = defender_stats.get("evasion", 0.1)
	
	return clampf(accuracy - evasion, 0.5, 0.95)


static func roll_hit(attacker: Node2D, defender: Node2D) -> bool:
	var hit_chance = get_hit_chance(attacker, defender)
	return randf() <= hit_chance


static func roll_critical(attacker: Node2D) -> bool:
	var attacker_stats = attacker.get_meta("stat_block", {})
	var crit_chance = attacker_stats.get("crit_chance", 0.1)
	return randf() <= crit_chance


static func apply_damage(defender: Node2D, damage: float, attacker: Node2D = null, is_critical: bool = false) -> float:
	var health_component = defender.get_node_or_null("HealthComponent") as HealthComponent
	if health_component:
		var final_damage = damage
		
		if is_critical:
			final_damage = damage * 1.5  # 50% bonus
		
		health_component.take_damage(final_damage, attacker)
		
		# Add threat if target has threat component
		if is_instance_valid(attacker):
			var threat_comp = defender.get_node_or_null("ThreatComponent") as ThreatComponent
			if threat_comp:
				threat_comp.add_damage_threat(attacker, final_damage)
		
		return final_damage
	
	return 0.0
