# DNA Validator Dock - Editor dock for validating DNA stacks
@tool
extends VBoxContainer

var core_slot: OptionButton
var element_slot: OptionButton
var behavior_slot: OptionButton
var ability_list: ItemList
var mutation_list: ItemList
var validate_button: Button
var results_tree: Tree

var available_cores: Array[Resource] = []
var available_elements: Array[Resource] = []
var available_behaviors: Array[Resource] = []
var available_abilities: Array[Resource] = []
var available_mutations: Array[Resource] = []


func _ready() -> void:
	_build_ui()
	_load_available_resources()


func _build_ui() -> void:
	# Title
	var title := Label.new()
	title.text = "DNA Stack Validator"
	title.add_theme_font_size_override("font_size", 16)
	add_child(title)
	
	# Core selection
	add_child(_create_label("Core:"))
	core_slot = OptionButton.new()
	add_child(core_slot)
	
	# Element selection
	add_child(_create_label("Element:"))
	element_slot = OptionButton.new()
	add_child(element_slot)
	
	# Behavior selection
	add_child(_create_label("Behavior:"))
	behavior_slot = OptionButton.new()
	add_child(behavior_slot)
	
	# Abilities
	add_child(_create_label("Abilities:"))
	ability_list = ItemList.new()
	ability_list.custom_minimum_size.y = 80
	ability_list.select_mode = ItemList.SELECT_MULTI
	add_child(ability_list)
	
	# Mutations
	add_child(_create_label("Mutations:"))
	mutation_list = ItemList.new()
	mutation_list.custom_minimum_size.y = 60
	mutation_list.select_mode = ItemList.SELECT_MULTI
	add_child(mutation_list)
	
	# Validate button
	validate_button = Button.new()
	validate_button.text = "Validate Stack"
	validate_button.pressed.connect(_on_validate_pressed)
	add_child(validate_button)
	
	# Results tree
	add_child(_create_label("Results:"))
	results_tree = Tree.new()
	results_tree.custom_minimum_size.y = 150
	results_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(results_tree)


func _create_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	return label


func _load_available_resources() -> void:
	available_cores = _load_resources_from_dir("res://data/dna/cores/")
	available_elements = _load_resources_from_dir("res://data/dna/elements/")
	available_behaviors = _load_resources_from_dir("res://data/dna/behaviors/")
	available_abilities = _load_resources_from_dir("res://data/dna/abilities/")
	available_mutations = _load_resources_from_dir("res://data/dna/mutations/")
	
	_populate_option_button(core_slot, available_cores)
	_populate_option_button(element_slot, available_elements)
	_populate_option_button(behavior_slot, available_behaviors)
	_populate_item_list(ability_list, available_abilities)
	_populate_item_list(mutation_list, available_mutations)


func _load_resources_from_dir(path: String) -> Array[Resource]:
	var resources: Array[Resource] = []
	var dir := DirAccess.open(path)
	if not dir:
		return resources
	
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var res := load(path + file_name)
			if res:
				resources.append(res)
		file_name = dir.get_next()
	
	return resources


func _populate_option_button(button: OptionButton, resources: Array[Resource]) -> void:
	button.clear()
	button.add_item("(None)", 0)
	for i in range(resources.size()):
		var res := resources[i]
		var name: String = res.get("display_name") if res.get("display_name") else res.get("id")
		button.add_item(name, i + 1)


func _populate_item_list(list: ItemList, resources: Array[Resource]) -> void:
	list.clear()
	for res in resources:
		var name: String = res.get("display_name") if res.get("display_name") else res.get("id")
		list.add_item(name)


func _on_validate_pressed() -> void:
	var stack := _build_stack()
	if not stack:
		_show_error("Could not build DNA stack")
		return
	
	var results := DNAValidator.validate_stack(stack)
	_display_results(results)


func _build_stack() -> MonsterDNAStack:
	var stack := MonsterDNAStack.new()
	
	var core_idx := core_slot.selected - 1
	if core_idx >= 0 and core_idx < available_cores.size():
		stack.core = available_cores[core_idx]
	
	var element_idx := element_slot.selected - 1
	if element_idx >= 0 and element_idx < available_elements.size():
		stack.element = available_elements[element_idx]
	
	var behavior_idx := behavior_slot.selected - 1
	if behavior_idx >= 0 and behavior_idx < available_behaviors.size():
		stack.behavior = available_behaviors[behavior_idx]
	
	# Get selected abilities
	var selected_abilities := ability_list.get_selected_items()
	for idx in selected_abilities:
		if idx < available_abilities.size():
			stack.abilities.append(available_abilities[idx])
	
	# Get selected mutations
	var selected_mutations := mutation_list.get_selected_items()
	for idx in selected_mutations:
		if idx < available_mutations.size():
			stack.mutations.append(available_mutations[idx])
	
	return stack


func _display_results(results: Array) -> void:
	results_tree.clear()
	var root := results_tree.create_item()
	root.set_text(0, "Validation Results")

	var error_count := 0
	var warning_count := 0

	for result in results:
		var item := results_tree.create_item(root)
		var severity: int = result.severity
		var message: String = result.message

		match severity:
			0:  # Error
				item.set_text(0, "❌ " + message)
				item.set_custom_color(0, Color.RED)
				error_count += 1
			1:  # Warning
				item.set_text(0, "⚠️ " + message)
				item.set_custom_color(0, Color.YELLOW)
				warning_count += 1
			2:  # Info
				item.set_text(0, "ℹ️ " + message)
				item.set_custom_color(0, Color.CYAN)

	if results.is_empty():
		var item := results_tree.create_item(root)
		item.set_text(0, "✅ Stack is valid!")
		item.set_custom_color(0, Color.GREEN)

	root.set_text(0, "Results: %d errors, %d warnings" % [error_count, warning_count])


func _show_error(message: String) -> void:
	results_tree.clear()
	var root := results_tree.create_item()
	root.set_text(0, "❌ " + message)
	root.set_custom_color(0, Color.RED)

