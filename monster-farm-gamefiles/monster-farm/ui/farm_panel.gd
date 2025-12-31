extends PanelContainer
## Farm panel displays farm buildings and automation jobs

signal build_requested(building_id: String)

var farm_data: Dictionary = {}
var farm_buildings: Array = []
var active_jobs: Array = []
var monsters: Array = []
var stats: Dictionary = {}
var resources: Dictionary = {}
var build_options: Array = []

func _ready():
	if EventBus:
		EventBus.job_posted.connect(_on_job_posted)
		EventBus.job_completed.connect(_on_job_completed)

	rebuild_farm_display()

func set_farm_data(data: Dictionary) -> void:
	farm_data = data
	resources = data.get("resources", {})
	rebuild_farm_display()

func set_buildings(buildings: Array) -> void:
	farm_buildings = buildings
	rebuild_farm_display()

func set_monsters(monster_list: Array) -> void:
	monsters = monster_list
	rebuild_farm_display()

func set_stats(new_stats: Dictionary) -> void:
	stats = new_stats
	rebuild_farm_display()

func set_resources(new_resources: Dictionary) -> void:
	resources = new_resources
	rebuild_farm_display()

func set_build_options(options: Array) -> void:
	build_options = options
	rebuild_farm_display()

func rebuild_farm_display():
	for child in get_children():
		child.queue_free()

	var vbox = VBoxContainer.new()
	add_child(vbox)

	var title = Label.new()
	title.text = farm_data.get("name", "Farm")
	title.modulate = Color.WHITE
	vbox.add_child(title)

	var resource_label = Label.new()
	resource_label.text = _format_resources(resources)
	resource_label.modulate = Color.GRAY
	vbox.add_child(resource_label)

	var buildings_title = Label.new()
	buildings_title.text = "Buildings"
	buildings_title.modulate = Color.WHITE
	vbox.add_child(buildings_title)

	var buildings_list = VBoxContainer.new()
	vbox.add_child(buildings_list)
	for b in farm_buildings:
		var row = HBoxContainer.new()
		var name_label = Label.new()
		name_label.text = b.get("display_name", b.get("id", "Structure"))
		name_label.modulate = Color.WHITE
		row.add_child(name_label)
		var job_hint = b.get("job_type_id", "")
		if not job_hint.is_empty():
			var job_label = Label.new()
			job_label.text = "Job: %s" % job_hint
			job_label.modulate = Color.SILVER
			row.add_child(job_label)
		buildings_list.add_child(row)

	var stats_label = Label.new()
	stats_label.text = _format_stats(stats)
	stats_label.modulate = Color.SILVER
	vbox.add_child(stats_label)

	var build_btn = Button.new()
	build_btn.text = "Build Structure"
	build_btn.pressed.connect(func(): show_build_menu())
	vbox.add_child(build_btn)

	var build_opts_title = Label.new()
	build_opts_title.text = "Build Options"
	build_opts_title.modulate = Color.WHITE
	vbox.add_child(build_opts_title)

	var build_opts_list = VBoxContainer.new()
	vbox.add_child(build_opts_list)
	for opt in build_options:
		var row = HBoxContainer.new()
		var opt_label = Label.new()
		opt_label.text = opt.get("display_name", opt.get("id", "Option"))
		opt_label.modulate = Color.SILVER
		row.add_child(opt_label)
		var job_hint = opt.get("job_type_id", "")
		if not job_hint.is_empty():
			var job_label = Label.new()
			job_label.text = "Job: %s" % job_hint
			job_label.modulate = Color.GRAY
			row.add_child(job_label)
		var cost_dict: Dictionary = opt.get("cost", {})
		if not cost_dict.is_empty():
			var cost_label = Label.new()
			cost_label.text = _format_cost(cost_dict)
			cost_label.modulate = Color.DARK_GOLDENROD
			row.add_child(cost_label)
		var build_button = Button.new()
		build_button.text = "Place"
		build_button.pressed.connect(func(): _emit_build(opt.get("id", "")))
		row.add_child(build_button)
		build_opts_list.add_child(row)

	var jobs_title = Label.new()
	jobs_title.text = "Active Jobs"
	jobs_title.modulate = Color.WHITE
	vbox.add_child(jobs_title)

	var jobs_scroll = ScrollContainer.new()
	jobs_scroll.custom_minimum_size = Vector2(0, 150)
	var jobs_list = VBoxContainer.new()
	jobs_scroll.add_child(jobs_list)
	vbox.add_child(jobs_scroll)

	for job in active_jobs:
		var job_label = Label.new()
		var display = job.get("type", null)
		if display and display.has_method("get_display_name"):
			display = display.get_display_name()
		job_label.text = job.get("display_name", str(display))
		job_label.modulate = Color.WHITE
		jobs_list.add_child(job_label)

func _on_job_posted(job):
	if job not in active_jobs:
		active_jobs.append(job)
	rebuild_farm_display()

func _on_job_completed(job):
	active_jobs.erase(job)
	rebuild_farm_display()

func show_build_menu():
	print("Build menu stub — options:", build_options)

func _emit_build(building_id: String) -> void:
	if building_id.is_empty():
		return
	emit_signal("build_requested", building_id)

func _format_resources(res: Dictionary) -> String:
	if res.is_empty():
		return "Resources: none"
	var parts: Array[String] = []
	for key in res.keys():
		parts.append("%s: %s" % [key, res[key]])
	return "Resources: " + ", ".join(parts)

func _format_stats(farm_stats: Dictionary) -> String:
	if farm_stats.is_empty():
		return "Monsters: 0"
	return "Monsters: %d | Working: %d | Happy: %.2f" % [
		farm_stats.get("monster_count", 0),
		farm_stats.get("working_count", 0),
		farm_stats.get("happiness_ratio", 0.0)
	]

func _format_cost(cost: Dictionary) -> String:
	var parts: Array[String] = []
	for key in cost.keys():
		parts.append("%s:%s" % [key, cost[key]])
	return "Cost: " + ",".join(parts)
