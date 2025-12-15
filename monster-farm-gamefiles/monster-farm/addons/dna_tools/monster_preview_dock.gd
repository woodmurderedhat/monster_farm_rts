# Monster Preview Dock - Editor dock for previewing assembled monsters
@tool
extends VBoxContainer

var dna_stack_path: LineEdit
var load_button: Button
var preview_viewport: SubViewportContainer
var sub_viewport: SubViewport
var stats_label: RichTextLabel
var abilities_label: RichTextLabel
var ai_label: RichTextLabel

var current_preview: Node2D = null


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	# Title
	var title := Label.new()
	title.text = "Monster Preview"
	title.add_theme_font_size_override("font_size", 16)
	add_child(title)
	
	# DNA Stack path input
	var path_container := HBoxContainer.new()
	add_child(path_container)
	
	dna_stack_path = LineEdit.new()
	dna_stack_path.placeholder_text = "Path to MonsterDNAStack resource..."
	dna_stack_path.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	path_container.add_child(dna_stack_path)
	
	load_button = Button.new()
	load_button.text = "Load"
	load_button.pressed.connect(_on_load_pressed)
	path_container.add_child(load_button)
	
	# Preview viewport
	preview_viewport = SubViewportContainer.new()
	preview_viewport.custom_minimum_size = Vector2(200, 150)
	preview_viewport.stretch = true
	add_child(preview_viewport)
	
	sub_viewport = SubViewport.new()
	sub_viewport.size = Vector2(200, 150)
	sub_viewport.transparent_bg = true
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	preview_viewport.add_child(sub_viewport)
	
	# Stats display
	add_child(_create_label("Stats:"))
	stats_label = RichTextLabel.new()
	stats_label.custom_minimum_size.y = 80
	stats_label.bbcode_enabled = true
	stats_label.fit_content = true
	add_child(stats_label)
	
	# Abilities display
	add_child(_create_label("Abilities:"))
	abilities_label = RichTextLabel.new()
	abilities_label.custom_minimum_size.y = 60
	abilities_label.bbcode_enabled = true
	abilities_label.fit_content = true
	add_child(abilities_label)
	
	# AI Role display
	add_child(_create_label("AI Configuration:"))
	ai_label = RichTextLabel.new()
	ai_label.custom_minimum_size.y = 60
	ai_label.bbcode_enabled = true
	ai_label.fit_content = true
	add_child(ai_label)


func _create_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	return label


func _on_load_pressed() -> void:
	var path := dna_stack_path.text.strip_edges()
	if path.is_empty():
		return
	
	if not ResourceLoader.exists(path):
		_show_error("Resource not found: " + path)
		return
	
	var stack := load(path) as MonsterDNAStack
	if not stack:
		_show_error("Invalid MonsterDNAStack resource")
		return
	
	_preview_stack(stack)


func _preview_stack(stack: MonsterDNAStack) -> void:
	# Clear previous preview
	if current_preview:
		current_preview.queue_free()
		current_preview = null
	
	# Validate first
	var results := DNAValidator.validate_stack(stack)
	var has_errors := false
	for result in results:
		if result.severity == 0:  # Error
			has_errors = true
			break
	
	if has_errors:
		_show_error("Stack has validation errors")
		return
	
	# Assemble monster for preview
	var assembler := MonsterAssembler.new()
	var monster := assembler.assemble_monster(stack, MonsterAssembler.SpawnContext.EDITOR_PREVIEW)
	
	if not monster:
		_show_error("Failed to assemble monster")
		assembler.queue_free()
		return
	
	# Add to viewport
	monster.position = Vector2(100, 75)
	sub_viewport.add_child(monster)
	current_preview = monster
	
	# Display stats
	_display_stats(monster)
	_display_abilities(monster)
	_display_ai_config(monster)
	
	assembler.queue_free()


func _display_stats(monster: Node2D) -> void:
	var stats: Dictionary = monster.get_meta("stat_block", {})
	var text := "[b]Final Stats:[/b]\n"
	
	for stat_name in stats:
		text += "%s: %.1f\n" % [stat_name, stats[stat_name]]
	
	stats_label.text = text


func _display_abilities(monster: Node2D) -> void:
	var abilities: Array = monster.get_meta("abilities", [])
	var text := "[b]Abilities:[/b]\n"
	
	for ability in abilities:
		var name: String = ability.get("display_name", ability.get("id", "???"))
		var enabled: bool = ability.get("enabled", true)
		var status := "[color=green]✓[/color]" if enabled else "[color=red]✗[/color]"
		text += "%s %s\n" % [status, name]
	
	abilities_label.text = text


func _display_ai_config(monster: Node2D) -> void:
	var config: Dictionary = monster.get_meta("ai_config", {})
	var text := "[b]AI Config:[/b]\n"
	
	text += "Aggression: %.2f\n" % config.get("aggression", 0.5)
	text += "Loyalty: %.2f\n" % config.get("loyalty", 0.5)
	text += "Roles: %s\n" % str(config.get("combat_roles", []))
	
	ai_label.text = text


func _show_error(message: String) -> void:
	stats_label.text = "[color=red]Error: %s[/color]" % message
	abilities_label.text = ""
	ai_label.text = ""

