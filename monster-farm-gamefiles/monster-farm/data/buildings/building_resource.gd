extends Resource
class_name BuildingResource

@export var id: String = ""
@export var display_name: String = ""
@export var job_type_id: String = "job_build"
@export var default_position: Vector2 = Vector2.ZERO
@export var placement_type: String = "structure" # structure, wall, gate, trap
@export var snap_step: Vector2 = Vector2(40, 0)
@export var cost: Dictionary = {} # e.g., {"wood": 10, "stone": 5}
