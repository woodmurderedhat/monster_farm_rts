# Farm Manager - Coordinates farm operations and monster automation
extends Node
class_name FarmManager

## Reference to the job board
var job_board: JobBoard

## All monsters assigned to this farm
var farm_monsters: Array[Node2D] = []

## Farm zones (areas with specific purposes)
var zones: Dictionary = {}  # zone_id -> {type, rect, priority_modifier}

## Farm structures
var structures: Array[Node2D] = []


func _ready() -> void:
	_setup_job_board()
	
	# Connect to events
	EventBus.monster_spawned.connect(_on_monster_spawned)
	EventBus.monster_died.connect(_on_monster_died)


## Setup the job board
func _setup_job_board() -> void:
	job_board = JobBoard.new()
	add_child(job_board)


## Register a monster to the farm
func register_monster(monster: Node2D) -> void:
	if monster in farm_monsters:
		return
	
	farm_monsters.append(monster)
	
	# Setup farm AI component
	var farm_ai := monster.get_node_or_null("FarmAIComponent") as FarmAIComponent
	if farm_ai:
		farm_ai.set_job_board(job_board)


## Unregister a monster from the farm
func unregister_monster(monster: Node2D) -> void:
	farm_monsters.erase(monster)


## Add a zone to the farm
func add_zone(zone_id: String, zone_type: String, rect: Rect2, priority_mod: float = 0.0) -> void:
	zones[zone_id] = {
		"type": zone_type,
		"rect": rect,
		"priority_modifier": priority_mod
	}


## Remove a zone
func remove_zone(zone_id: String) -> void:
	zones.erase(zone_id)


## Post a job at a location
func post_job(job_type_id: String, location: Vector2, data: Dictionary = {}) -> String:
	return job_board.post_job(job_type_id, location, data)


## Post jobs for all structures that need work
func update_structure_jobs() -> void:
	for structure in structures:
		if structure.has_method("get_pending_jobs"):
			var pending_jobs: Array = structure.get_pending_jobs()
			for job_data in pending_jobs:
				post_job(
					job_data.get("type", "general"),
					structure.global_position,
					job_data
				)


## Get monsters in a zone
func get_monsters_in_zone(zone_id: String) -> Array[Node2D]:
	if zone_id not in zones:
		return []
	
	var zone: Dictionary = zones[zone_id]
	var rect: Rect2 = zone.rect
	var result: Array[Node2D] = []
	
	for monster in farm_monsters:
		if rect.has_point(monster.global_position):
			result.append(monster)
	
	return result


## Handle monster spawned
func _on_monster_spawned(monster: Node2D) -> void:
	# Auto-register if in farm context
	if GameState.is_in_farm():
		register_monster(monster)


## Handle monster died
func _on_monster_died(monster: Node2D) -> void:
	unregister_monster(monster)


## Get farm statistics
func get_stats() -> Dictionary:
	var total_stress := 0.0
	var total_happiness := 0.0
	var working_count := 0
	
	for monster in farm_monsters:
		var stress_comp := monster.get_node_or_null("StressComponent") as StressComponent
		if stress_comp:
			total_stress += stress_comp.get_stress_percent()
			if stress_comp.is_happy():
				total_happiness += 1
		
		var job_comp := monster.get_node_or_null("JobComponent") as JobComponent
		if job_comp and job_comp.is_working:
			working_count += 1
	
	var count := farm_monsters.size()
	return {
		"monster_count": count,
		"average_stress": total_stress / maxf(count, 1),
		"happiness_ratio": total_happiness / maxf(count, 1),
		"working_count": working_count,
		"idle_count": count - working_count
	}

