# Ability Button - UI button for manually casting abilities
extends Button
class_name AbilityButton

## The ability data this button represents
var ability_data: Dictionary = {}

## Reference to the monster that owns this ability
var owner_monster: Node2D = null

## Cooldown overlay
@onready var cooldown_overlay: ColorRect = $CooldownOverlay

## Cooldown label
@onready var cooldown_label: Label = $CooldownLabel


func _ready() -> void:
	pressed.connect(_on_pressed)


func _process(_delta: float) -> void:
	_update_cooldown_display()


## Setup the button with ability data
func setup(ability: Dictionary, monster: Node2D) -> void:
	ability_data = ability
	owner_monster = monster
	
	text = ability.get("display_name", ability.get("id", "???"))
	tooltip_text = ability.get("description", "")
	
	# Set icon if available
	var icon_path: String = ability.get("icon", "")
	if icon_path and ResourceLoader.exists(icon_path):
		icon = load(icon_path)


## Handle button press
func _on_pressed() -> void:
	if not owner_monster or ability_data.is_empty():
		return
	
	var combat_comp := owner_monster.get_node_or_null("CombatComponent") as CombatComponent
	if combat_comp:
		var ability_id: String = ability_data.get("id", "")
		var target := combat_comp.current_target
		combat_comp.use_ability(ability_id, target)


## Update cooldown display
func _update_cooldown_display() -> void:
	if not owner_monster:
		return
	
	var combat_comp := owner_monster.get_node_or_null("CombatComponent") as CombatComponent
	if not combat_comp:
		return
	
	var ability_id: String = ability_data.get("id", "")
	var remaining := combat_comp.get_cooldown_remaining(ability_id)
	
	if remaining > 0:
		disabled = true
		if cooldown_overlay:
			cooldown_overlay.visible = true
		if cooldown_label:
			cooldown_label.visible = true
			cooldown_label.text = "%.1f" % remaining
	else:
		disabled = false
		if cooldown_overlay:
			cooldown_overlay.visible = false
		if cooldown_label:
			cooldown_label.visible = false

