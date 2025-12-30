extends Node
## Monster info panel - displays detailed stats of selected monster

@onready var title = get_node("../Title") if has_node("../Title") else null

func _ready():
	if GameState:
		GameState.selected_monster_changed.connect(_on_monster_selected)

func _on_monster_selected(monster):
	clear_panel()
	
	if not monster:
		return
	
	var stats = monster.get_meta("stat_block", {})
	var abilities = monster.get_meta("abilities", [])
	var _visual_data = monster.get_meta("visual_data", {})
	
	# Display basic info
	if title:
		title.text = monster.name
	
	# Create stat display
	var stat_display = VBoxContainer.new()
	add_child(stat_display)
	
	var health = Label.new()
	health.text = "HP: %d / %d" % [stats.get("current_health", 0), stats.get("max_health", 100)]
	stat_display.add_child(health)
	
	var attack = Label.new()
	attack.text = "Attack: %d" % stats.get("attack", 5)
	stat_display.add_child(attack)
	
	var defense = Label.new()
	defense.text = "Defense: %d" % stats.get("defense", 2)
	stat_display.add_child(defense)
	
	var speed = Label.new()
	speed.text = "Speed: %d" % stats.get("speed", 3)
	stat_display.add_child(speed)
	
	# Display abilities
	if abilities.size() > 0:
		var ability_label = Label.new()
		ability_label.text = "Abilities:"
		stat_display.add_child(ability_label)
		
		for ability in abilities:
			var ability_text = Label.new()
			ability_text.text = "  - %s" % ability.get("display_name", "Unknown")
			stat_display.add_child(ability_text)

func clear_panel():
	for child in get_children():
		if child.name != "Title":
			child.queue_free()
