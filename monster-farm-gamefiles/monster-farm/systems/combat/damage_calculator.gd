extends Node
## Damage calculation system

static func calculate_damage(attacker: Node, defender: Node, ability: Dictionary) -> int:
	var attacker_stats = attacker.get_meta("stat_block", {})
	var defender_stats = defender.get_meta("stat_block", {})
	
	var base_damage = ability.get("base_damage", 10)
	var attacker_attack = attacker_stats.get("attack", 5)
	var defender_defense = defender_stats.get("defense", 2)
	
	# Basic formula: base + attacker - defender/2
	var calculated_damage = base_damage + attacker_attack - (defender_defense / 2.0)
	
	# Apply randomness (±20%)
	var randomness = randf_range(0.8, 1.2)
	calculated_damage = int(calculated_damage * randomness)
	
	# Ensure minimum damage
	calculated_damage = max(1, calculated_damage)
	
	return calculated_damage

static func get_hit_chance(attacker: Node, defender: Node) -> float:
	var attacker_stats = attacker.get_meta("stat_block", {})
	var defender_stats = defender.get_meta("stat_block", {})
	
	var accuracy = attacker_stats.get("accuracy", 0.85)
	var evasion = defender_stats.get("evasion", 0.1)
	
	return clamp(accuracy - evasion, 0.5, 0.95)

static func roll_hit(attacker: Node, defender: Node) -> bool:
	var hit_chance = get_hit_chance(attacker, defender)
	return randf() <= hit_chance

static func roll_critical(attacker: Node) -> bool:
	var attacker_stats = attacker.get_meta("stat_block", {})
	var crit_chance = attacker_stats.get("crit_chance", 0.1)
	return randf() <= crit_chance

static func apply_damage(defender: Node, damage: int, is_critical: bool = false) -> int:
	if defender.has_meta("stat_block"):
		var stats = defender.get_meta("stat_block")
		var final_damage = damage
		
		if is_critical:
			final_damage = int(damage * 1.5)  # 50% bonus
		
		stats["current_health"] = max(0, stats.get("current_health", 100) - final_damage)
		defender.set_meta("stat_block", stats)
		
		if stats["current_health"] <= 0:
			EventBus.monster_defeated.emit(defender)
		
		return final_damage
	
	return 0
