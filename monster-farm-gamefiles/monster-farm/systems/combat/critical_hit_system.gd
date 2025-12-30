extends Node
## Critical hit system

@export var base_crit_chance = 0.1
@export var crit_damage_multiplier = 1.5

func check_critical_hit(attacker: Node) -> bool:
	if not attacker.has_meta("stat_block"):
		return false
	
	var stats = attacker.get_meta("stat_block")
	var crit_chance = stats.get("crit_chance", base_crit_chance)
	
	return randf() < crit_chance

func apply_critical_damage(base_damage: int) -> int:
	return int(base_damage * crit_damage_multiplier)

func get_crit_chance(attacker: Node) -> float:
	if not attacker.has_meta("stat_block"):
		return base_crit_chance
	
	var stats = attacker.get_meta("stat_block")
	return stats.get("crit_chance", base_crit_chance)

func increase_crit_chance(attacker: Node, amount: float):
	if attacker.has_meta("stat_block"):
		var stats = attacker.get_meta("stat_block")
		stats["crit_chance"] = min(1.0, stats.get("crit_chance", base_crit_chance) + amount)
		attacker.set_meta("stat_block", stats)
