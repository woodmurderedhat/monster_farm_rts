extends HBoxContainer
## Ability bar displays and manages 4 active abilities

@export var ability_spacing = 10
var ability_buttons = []

func _ready():
	if GameState:
		GameState.selected_monster_changed.connect(_on_selected_monster_changed)
	
	# Create 4 ability slots
	for i in range(4):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(60, 50)
		btn.modulate = Color.DARK_GRAY
		btn.text = ""
		add_child(btn)
		ability_buttons.append(btn)
		_add_custom_spacer()

func _on_selected_monster_changed(monster):
	if not monster:
		clear_abilities()
		return
	
	var abilities = monster.get_meta("abilities", [])
	clear_abilities()
	
	for i in range(min(abilities.size(), 4)):
		var ability = abilities[i]
		var btn = ability_buttons[i]
		btn.text = ability.get("display_name", "Ability %d" % (i + 1))
		btn.modulate = Color.WHITE
		btn.pressed.connect(func(): use_ability(ability))

func use_ability(ability):
	EventBus.use_ability_command.emit(GameState.selected_monster, ability)

func clear_abilities():
	for btn in ability_buttons:
		btn.text = ""
		btn.modulate = Color.DARK_GRAY
		# Disconnect any previous signals

func _add_custom_spacer():
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(ability_spacing, 0)
	add_child(spacer)
