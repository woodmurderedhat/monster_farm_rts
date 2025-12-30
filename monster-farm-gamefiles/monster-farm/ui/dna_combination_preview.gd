extends PanelContainer
## DNA combination preview - shows what monster will result from combo

var parent_dna1: Resource
var parent_dna2: Resource

func _ready():
	modulate = Color.WHITE

func show_combination_preview(dna1: Resource, dna2: Resource):
	parent_dna1 = dna1
	parent_dna2 = dna2
	update_preview()

func update_preview():
	clear_children()
	
	if not parent_dna1 or not parent_dna2:
		return
	
	var container = VBoxContainer.new()
	add_child(container)
	
	# Show parent 1
	var parent1_label = Label.new()
	var parent1_name = parent_dna1.display_name if "display_name" in parent_dna1 else "Unknown"
	parent1_label.text = "Parent 1: %s" % parent1_name
	parent1_label.modulate = Color.WHITE
	container.add_child(parent1_label)
	
	# Show parent 2
	var parent2_label = Label.new()
	var parent2_name = parent_dna2.display_name if "display_name" in parent_dna2 else "Unknown"
	parent2_label.text = "Parent 2: %s" % parent2_name
	parent2_label.modulate = Color.WHITE
	container.add_child(parent2_label)
	
	# Show predicted offspring
	var offspring_label = Label.new()
	offspring_label.text = "Predicted Offspring: ?"
	offspring_label.modulate = Color.YELLOW
	container.add_child(offspring_label)

func clear_children():
	for child in get_children():
		child.queue_free()
