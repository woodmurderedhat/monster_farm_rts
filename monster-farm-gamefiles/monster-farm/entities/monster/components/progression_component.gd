## Progression Component - tracks XP, levels, and stat growth for monsters
## Attached to monsters to handle leveling and stat scaling
extends Node
class_name ProgressionComponent

signal level_up(new_level: int)
signal xp_gained(amount: int)
signal stat_increased(stat_name: String, new_value: float)

@export var current_level: int = 1
@export var current_xp: int = 0
@export var max_level: int = 100

## XP curve configuration
@export var base_xp_requirement: int = 100
@export var xp_curve_exponent: float = 1.5

## Stat growth rates (from DNA)
var stat_growth_rates: Dictionary = {}

func _ready() -> void:
	_load_stat_growth_rates()

## Load stat growth rates from monster's DNA
func _load_stat_growth_rates() -> void:
	var monster = get_parent()
	
	if monster.has_meta("dna_stack"):
		var stack = monster.get_meta("dna_stack")
		if stack.has_method("get_stat_growth_rates"):
			stat_growth_rates = stack.get_stat_growth_rates()
	
	# Fallback default rates
	if stat_growth_rates.is_empty():
		stat_growth_rates = {
			"max_health": 10.0,
			"attack": 2.0,
			"defense": 1.5,
			"speed": 0.5
		}

## Award XP to this monster
func award_xp(amount: int) -> void:
	current_xp += amount
	xp_gained.emit(amount)
	
	_check_level_up()

## Check if monster should level up
func _check_level_up() -> void:
	while current_xp >= get_xp_for_next_level() and current_level < max_level:
		_level_up()

## Perform level up
func _level_up() -> void:
	current_level += 1
	current_xp -= get_xp_for_next_level()
	
	_apply_stat_growth()
	
	level_up.emit(current_level)
	EventBus.monster_leveled_up.emit(get_parent(), current_level)

## Apply stat increases on level up
func _apply_stat_growth() -> void:
	var monster = get_parent()
	
	# Apply to stat block meta if it exists
	if monster.has_meta("stat_block"):
		var stats = monster.get_meta("stat_block")
		
		for stat_name in stat_growth_rates:
			if stats.has(stat_name):
				var growth = stat_growth_rates[stat_name]
				stats[stat_name] += growth
				stat_increased.emit(stat_name, stats[stat_name])
		
		monster.set_meta("stat_block", stats)
	
	# Update health component max health
	if monster.has_node("HealthComponent") and stat_growth_rates.has("max_health"):
		var health_comp = monster.get_node("HealthComponent")
		health_comp.max_health += stat_growth_rates["max_health"]
		# Heal a portion on level up
		health_comp.heal(stat_growth_rates["max_health"] * 0.5)

## Get XP required for next level
func get_xp_for_next_level() -> int:
	return int(base_xp_requirement * pow(current_level, xp_curve_exponent))

## Get total XP required to reach a specific level
func get_total_xp_for_level(level: int) -> int:
	var total := 0
	for i in range(1, level):
		total += int(base_xp_requirement * pow(i, xp_curve_exponent))
	return total

## Get progress to next level as percentage
func get_level_progress() -> float:
	var required = get_xp_for_next_level()
	return float(current_xp) / float(required) if required > 0 else 1.0

## Set level directly (for spawning monsters at specific levels)
func set_level(level: int, apply_stats: bool = true) -> void:
	current_level = clamp(level, 1, max_level)
	current_xp = 0
	
	if apply_stats:
		# Apply all stat growth from level 1 to target level
		var monster = get_parent()
		if monster.has_meta("stat_block"):
			var stats = monster.get_meta("stat_block")
			
			for stat_name in stat_growth_rates:
				if stats.has(stat_name):
					var total_growth = stat_growth_rates[stat_name] * (current_level - 1)
					stats[stat_name] += total_growth
			
			monster.set_meta("stat_block", stats)

## Serialize for save system
func serialize() -> Dictionary:
	return {
		"current_level": current_level,
		"current_xp": current_xp,
		"stat_growth_rates": stat_growth_rates
	}

## Deserialize from save data
func deserialize(data: Dictionary) -> void:
	current_level = data.get("current_level", 1)
	current_xp = data.get("current_xp", 0)
	stat_growth_rates = data.get("stat_growth_rates", {})
