## Farm Zone - defines workable areas, restricted zones, and job locations
## Used by automation to determine where monsters can work and patrol
extends Node2D
class_name FarmZone

signal zone_modified()

@export_enum("work", "rest", "patrol", "restricted", "storage") var zone_type: String = "work"
@export var zone_name: String = "Farm Zone"
@export var zone_priority: int = 1

## Spatial bounds (could be replaced with Area2D/Polygon2D in actual implementation)
@export var zone_bounds: Rect2 = Rect2(0, 0, 200, 200)

## Job constraints
@export var allowed_job_types: Array[String] = []  # Empty = all allowed
@export var max_workers: int = -1  # -1 = unlimited

var current_workers: Array[Node] = []

func _ready() -> void:
	add_to_group("farm_zones")

## Check if a position is within this zone
func contains_point(point: Vector2) -> bool:
	var local_point = to_local(point)
	return zone_bounds.has_point(local_point)

## Check if a monster can work in this zone
func can_monster_work_here(monster: Node, job_type: String) -> bool:
	# Check max workers
	if max_workers >= 0 and current_workers.size() >= max_workers:
		if monster not in current_workers:
			return false
	
	# Check allowed job types
	if not allowed_job_types.is_empty():
		if job_type not in allowed_job_types:
			return false
	
	# Check zone type restrictions
	if zone_type == "restricted":
		return false
	
	return true

## Assign a monster to work in this zone
func assign_worker(monster: Node) -> void:
	if monster not in current_workers:
		current_workers.append(monster)
		zone_modified.emit()

## Remove a worker from this zone
func remove_worker(monster: Node) -> void:
	current_workers.erase(monster)
	zone_modified.emit()

## Get a random work position within this zone
func get_random_work_position() -> Vector2:
	var local_pos = Vector2(
		zone_bounds.position.x + randf() * zone_bounds.size.x,
		zone_bounds.position.y + randf() * zone_bounds.size.y
	)
	return to_global(local_pos)

## Get available worker slots
func get_available_slots() -> int:
	if max_workers < 0:
		return 999  # Unlimited
	return max(0, max_workers - current_workers.size())

## Debug draw
func _draw() -> void:
	if Engine.is_editor_hint():
		# Draw zone bounds
		draw_rect(zone_bounds, Color.YELLOW if zone_type == "work" else Color.RED, false, 2.0)
		
		# Draw label
		draw_string(ThemeDB.fallback_font, zone_bounds.position, zone_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
