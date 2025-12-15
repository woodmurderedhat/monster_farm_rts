# DNA Ability Resource - Defines a monster ability (data only)
# Logic lives in ability runtime system, not here
extends BaseDNAResource
class_name DNAAbilityResource

## Unique ability identifier used by the ability system
@export var ability_id: String = ""

## Cooldown time in seconds between uses
@export_range(0.0, 60.0) var cooldown: float = 1.0

## Energy/stamina cost per use
@export_range(0.0, 100.0) var energy_cost: float = 10.0

## Maximum range of the ability (0 = melee)
@export_range(0.0, 500.0) var ability_range: float = 100.0

## Targeting type for this ability
@export_enum("Self", "Target", "Area", "Cone")
var targeting_type: int = 1

## Stats that affect this ability's power
## e.g., ["attack", "magic"] - ability scales with these stats
@export var scaling_stats: Array[String] = []

## Tags required in the DNA stack for this ability to work
## If required_tags are not present, ability is disabled
@export var required_tags: Array[String] = []

## Base damage or effect magnitude
@export_range(0.0, 500.0) var base_power: float = 10.0

## Area of effect radius (for Area targeting type)
@export_range(0.0, 200.0) var aoe_radius: float = 0.0


## Get targeting type as string
func get_targeting_type_name() -> String:
	match targeting_type:
		0: return "Self"
		1: return "Target"
		2: return "Area"
		3: return "Cone"
		_: return "Unknown"


## Check if this ability requires a target
func requires_target() -> bool:
	return targeting_type == 1  # Target type


## Check if this ability is an AoE ability
func is_aoe() -> bool:
	return targeting_type == 2 or aoe_radius > 0


## Check if all required tags are present in the given tag list
func has_required_tags(available_tags: Array[String]) -> bool:
	for tag in required_tags:
		if tag not in available_tags:
			return false
	return true


## Calculate scaled power based on stats
func calculate_power(stat_values: Dictionary) -> float:
	var total_power := base_power
	for stat_name in scaling_stats:
		if stat_values.has(stat_name):
			total_power += stat_values[stat_name] * 0.1  # 10% scaling per stat point
	return total_power


## Validate this DNA Ability resource
func validate() -> Array[Dictionary]:
	var errors := super.validate()
	
	if ability_id.is_empty():
		errors.append({
			"severity": "Error",
			"message": "ability_id cannot be empty",
			"source_id": id
		})
	
	if cooldown < 0:
		errors.append({
			"severity": "Error",
			"message": "cooldown cannot be negative",
			"source_id": id
		})
	
	if energy_cost < 0:
		errors.append({
			"severity": "Error",
			"message": "energy_cost cannot be negative",
			"source_id": id
		})
	
	if targeting_type == 2 and aoe_radius <= 0:
		errors.append({
			"severity": "Warning",
			"message": "Area targeting type but aoe_radius is 0",
			"source_id": id
		})
	
	return errors

