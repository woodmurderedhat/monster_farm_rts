extends Control
## Creature comparison UI - compares two monsters side by side

var monster1: Node
var monster2: Node

func _ready():
	modulate = Color.WHITE
	create_comparison_layout()

func show_comparison(m1: Node, m2: Node):
	monster1 = m1
	monster2 = m2
	update_comparison()

func create_comparison_layout():
	var container = HBoxContainer.new()
	container.anchor_right = 1.0
	container.anchor_bottom = 1.0
	add_child(container)
	
	# Left side - Monster 1
	var left_panel = PanelContainer.new()
	left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(left_panel)
	
	var left_vbox = VBoxContainer.new()
	left_panel.add_child(left_vbox)
	
	var name1_label = Label.new()
	name1_label.text = "Monster 1"
	name1_label.modulate = Color.WHITE
	left_vbox.add_child(name1_label)
	
	# Right side - Monster 2
	var right_panel = PanelContainer.new()
	right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(right_panel)
	
	var right_vbox = VBoxContainer.new()
	right_panel.add_child(right_vbox)
	
	var name2_label = Label.new()
	name2_label.text = "Monster 2"
	name2_label.modulate = Color.WHITE
	right_vbox.add_child(name2_label)

func update_comparison():
	if not monster1 or not monster2:
		return
	
	var stats1 = monster1.get_meta("stat_block", {})
	var stats2 = monster2.get_meta("stat_block", {})
	
	print("Comparing %s vs %s" % [monster1.name, monster2.name])
	print("Stats 1: %s" % stats1)
	print("Stats 2: %s" % stats2)
