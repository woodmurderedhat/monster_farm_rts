extends PanelContainer
## Combat log UI - displays combat events

@onready var log_container = VBoxContainer.new()
var scroll_container: ScrollContainer
var log_entries: Array = []
var max_entries = 20

func _ready():
	modulate = Color.WHITE
	scroll_container = ScrollContainer.new()
	add_child(scroll_container)
	scroll_container.add_child(log_container)
	
	if EventBus:
		EventBus.damage_dealt.connect(_on_damage_dealt)
		EventBus.ability_used.connect(_on_ability_used)
		EventBus.monster_defeated.connect(_on_monster_defeated)

func _on_damage_dealt(attacker, target, damage):
	add_log_entry("%s damaged %s for %d HP" % [attacker.name, target.name, damage])

func _on_ability_used(caster, ability):
	add_log_entry("%s used %s" % [caster.name, ability.get("display_name", "ability")])

func _on_monster_defeated(monster):
	add_log_entry("%s was defeated!" % monster.name)

func add_log_entry(message: String):
	var label = Label.new()
	label.text = message
	label.modulate = Color.WHITE
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	log_container.add_child(label)
	log_entries.append(message)
	
	# Keep only recent entries
	if log_entries.size() > max_entries:
		log_entries.pop_front()
		log_container.get_child(0).queue_free()

func clear_log():
	log_entries.clear()
	for child in log_container.get_children():
		child.queue_free()
