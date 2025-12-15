# Monster Info Panel - Displays information about selected monster(s)
extends PanelContainer
class_name MonsterInfoPanel

## Reference to name label
@onready var name_label: Label = $VBox/NameLabel

## Reference to health bar
@onready var health_bar: ProgressBar = $VBox/HealthBar

## Reference to stamina bar
@onready var stamina_bar: ProgressBar = $VBox/StaminaBar

## Reference to stress bar
@onready var stress_bar: ProgressBar = $VBox/StressBar

## Reference to abilities container
@onready var abilities_container: HBoxContainer = $VBox/AbilitiesContainer

## Currently displayed monster
var current_monster: Node2D = null


func _ready() -> void:
	EventBus.monster_selected.connect(_on_monster_selected)
	EventBus.monster_deselected.connect(_on_monster_deselected)
	EventBus.selection_cleared.connect(_on_selection_cleared)
	
	visible = false


func _process(_delta: float) -> void:
	if current_monster and is_instance_valid(current_monster):
		_update_display()


## Handle monster selection
func _on_monster_selected(monster: Node2D) -> void:
	current_monster = monster
	visible = true
	_update_display()


## Handle monster deselection
func _on_monster_deselected(_monster: Node2D) -> void:
	# Could show multi-select info here
	pass


## Handle selection cleared
func _on_selection_cleared() -> void:
	current_monster = null
	visible = false


## Update the display with current monster data
func _update_display() -> void:
	if not current_monster:
		return
	
	# Update name
	var dna_stack: Resource = current_monster.get_meta("dna_stack", null)
	if dna_stack and name_label:
		name_label.text = dna_stack.get("display_name") if dna_stack.get("display_name") else "Monster"
	
	# Update health bar
	var health_comp := current_monster.get_node_or_null("HealthComponent") as HealthComponent
	if health_comp and health_bar:
		health_bar.value = health_comp.get_health_percent() * 100
	
	# Update stamina bar
	var stamina_comp := current_monster.get_node_or_null("StaminaComponent") as StaminaComponent
	if stamina_comp and stamina_bar:
		stamina_bar.value = stamina_comp.get_stamina_percent() * 100
	
	# Update stress bar
	var stress_comp := current_monster.get_node_or_null("StressComponent") as StressComponent
	if stress_comp and stress_bar:
		stress_bar.value = stress_comp.get_stress_percent() * 100

