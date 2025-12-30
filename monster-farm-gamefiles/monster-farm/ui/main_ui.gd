extends CanvasLayer
## Main UI controller - manages all HUD elements

@onready var time_label = $Panel/TopBar/HBoxContainer/TimeLabel
@onready var gold_label = $Panel/TopBar/HBoxContainer/GoldLabel
@onready var xp_label = $Panel/TopBar/HBoxContainer/XPLabel
@onready var ability_bar = $Panel/BottomBar/AbilityBar
@onready var monster_info_panel = $Panel/RightPanel/VBoxContainer/MonsterInfoPanel/ScrollContainer/VBoxContainer
@onready var event_log = $Panel/EventLog/VBoxContainer/ScrollContainer/LogList

func _ready():
	# Connect to game state updates
	if EventBus:
		EventBus.game_state_changed.connect(_on_game_state_changed)
		EventBus.monster_spawned.connect(_on_monster_spawned)
		EventBus.damage_dealt.connect(_on_damage_dealt)
		EventBus.ability_used.connect(_on_ability_used)
		EventBus.job_posted.connect(_on_job_posted)
	
	update_ui()

func update_ui():
	if GameState:
		time_label.text = "Day %d - %s" % [GameState.current_day, GameState.current_period]
		gold_label.text = "Gold: %d" % GameState.player_state.get("gold", 0)
		xp_label.text = "XP: %d" % GameState.player_state.get("total_xp", 0)

func _on_game_state_changed(_state):
	update_ui()

func _on_monster_spawned(monster):
	add_log_entry("Monster spawned: %s" % monster.name)

func _on_damage_dealt(attacker, target, damage):
	add_log_entry("%s dealt %d damage to %s" % [attacker.name, damage, target.name])

func _on_ability_used(_caster, ability):
	add_log_entry("Ability used: %s" % ability.display_name)

func _on_job_posted(job):
	add_log_entry("Job posted: %s" % job.display_name)

func add_log_entry(message: String):
	var label = Label.new()
	label.text = message
	label.custom_minimum_size = Vector2(150, 0)
	label.modulate = Color.WHITE
	event_log.add_child(label)
	
	# Keep only last 10 entries
	if event_log.get_child_count() > 10:
		event_log.get_child(0).queue_free()

func update_monster_info(monster):
	var stats = monster.get_meta("stat_block", {})
	monster_info_panel.get_node("MonsterName").text = monster.name
	monster_info_panel.get_node("HealthBar").max_value = stats.get("max_health", 100)
	monster_info_panel.get_node("HealthBar").value = stats.get("current_health", 100)
	monster_info_panel.get_node("EnergyBar").max_value = stats.get("max_energy", 100)
	monster_info_panel.get_node("EnergyBar").value = stats.get("current_energy", 50)

func add_ability_button(ability_id: String, _icon = null):
	var button = Button.new()
	button.text = ability_id
	button.custom_minimum_size = Vector2(50, 40)
	ability_bar.add_child(button)
	button.pressed.connect(func(): EventBus.player_command.emit("use_ability", ability_id))
