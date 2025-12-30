extends PanelContainer
## Farm panel displays farm buildings and automation jobs

var farm_buildings = {}
var active_jobs = []

func _ready():
	if EventBus:
		EventBus.job_posted.connect(_on_job_posted)
		EventBus.job_completed.connect(_on_job_completed)
	
	rebuild_farm_display()

func rebuild_farm_display():
	# Clear existing
	for child in get_children():
		child.queue_free()
	
	# Create main container
	var vbox = VBoxContainer.new()
	add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "Farm Buildings"
	title.modulate = Color.WHITE
	vbox.add_child(title)
	
	# Buildings
	var buildings_hbox = HBoxContainer.new()
	vbox.add_child(buildings_hbox)
	
	# Build button
	var build_btn = Button.new()
	build_btn.text = "Build Structure"
	build_btn.pressed.connect(func(): show_build_menu())
	vbox.add_child(build_btn)
	
	# Jobs section
	var jobs_title = Label.new()
	jobs_title.text = "Active Jobs"
	jobs_title.modulate = Color.WHITE
	vbox.add_child(jobs_title)
	
	var jobs_scroll = ScrollContainer.new()
	jobs_scroll.custom_minimum_size = Vector2(0, 150)
	var jobs_list = VBoxContainer.new()
	jobs_scroll.add_child(jobs_list)
	vbox.add_child(jobs_scroll)
	
	# Add current jobs
	for job in active_jobs:
		var job_label = Label.new()
		job_label.text = "%s (Workers: 0)" % job.get("display_name", "Unknown")
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
	print("Build menu would show available structures")
	# TODO: Implement structure selection menu
