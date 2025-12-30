extends ProgressBar
## Health bar display above monsters

var monster_ref: Node

func _ready():
	custom_minimum_size = Vector2(80, 8)
	max_value = 100
	modulate = Color.RED
	add_theme_color_override("font_color", Color.WHITE)

func setup(monster: Node):
	monster_ref = monster
	update_health()
	if monster.has_meta("stat_block"):
		set_process(true)

func _process(_delta):
	if monster_ref and not is_node_gone(monster_ref):
		update_health()

func update_health():
	if monster_ref and monster_ref.has_meta("stat_block"):
		var stats = monster_ref.get_meta("stat_block")
		max_value = stats.get("max_health", 100)
		value = stats.get("current_health", max_value)

func is_node_gone(node: Node) -> bool:
	return not is_instance_valid(node) or node.is_queued_for_deletion()
