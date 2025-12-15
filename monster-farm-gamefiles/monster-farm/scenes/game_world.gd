# Game World - Main game scene controller
# Manages the world, monsters, and player interaction
extends Node2D
class_name GameWorld

## Reference to the monster assembler
var monster_assembler: MonsterAssembler

## Reference to the combat manager
var combat_manager: CombatManager

## Reference to the selection manager
var selection_manager: SelectionManager

## Reference to the command manager
var command_manager: CommandManager

## Container for spawned monsters
@onready var monsters_container: Node2D = $Monsters

## Reference to the camera
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	_setup_systems()
	_spawn_test_monsters()


## Setup game systems
func _setup_systems() -> void:
	# Create monster assembler
	monster_assembler = MonsterAssembler.new()
	add_child(monster_assembler)
	
	# Create combat manager
	combat_manager = CombatManager.new()
	add_child(combat_manager)
	
	# Create selection manager
	selection_manager = SelectionManager.new()
	add_child(selection_manager)
	
	# Create command manager
	command_manager = CommandManager.new()
	command_manager.selection_manager = selection_manager
	command_manager.combat_manager = combat_manager
	add_child(command_manager)


## Spawn test monsters for development
func _spawn_test_monsters() -> void:
	# Load sample DNA resources
	var core_wolf := load("res://data/dna/cores/core_wolf.tres")
	var element_fire := load("res://data/dna/elements/element_fire.tres")
	var behavior_aggressive := load("res://data/dna/behaviors/behavior_aggressive.tres")
	var ability_bite := load("res://data/dna/abilities/ability_bite.tres")
	var ability_fireball := load("res://data/dna/abilities/ability_fireball.tres")
	
	if not core_wolf:
		push_warning("Could not load test DNA resources")
		return
	
	# Create a DNA stack
	var dna_stack := MonsterDNAStack.new()
	dna_stack.core = core_wolf
	dna_stack.element = element_fire
	dna_stack.behavior = behavior_aggressive
	dna_stack.abilities = [ability_bite, ability_fireball]
	
	# Spawn a few test monsters
	for i in range(3):
		var monster := monster_assembler.assemble_monster(dna_stack, MonsterAssembler.SpawnContext.WORLD)
		if monster:
			monster.global_position = Vector2(100 + i * 100, 200)
			monster.set_meta("team", 0)  # Player team
			monsters_container.add_child(monster)
			combat_manager.register_combatant(monster)
			EventBus.monster_spawned.emit(monster)
	
	# Spawn enemy monsters
	var core_golem := load("res://data/dna/cores/core_golem.tres")
	var behavior_defensive := load("res://data/dna/behaviors/behavior_defensive.tres")
	
	if core_golem:
		var enemy_stack := MonsterDNAStack.new()
		enemy_stack.core = core_golem
		enemy_stack.element = element_fire
		enemy_stack.behavior = behavior_defensive
		enemy_stack.abilities = [ability_bite]
		
		for i in range(2):
			var enemy := monster_assembler.assemble_monster(enemy_stack, MonsterAssembler.SpawnContext.WORLD)
			if enemy:
				enemy.global_position = Vector2(400 + i * 80, 200)
				enemy.set_meta("team", 1)  # Enemy team
				monsters_container.add_child(enemy)
				combat_manager.register_combatant(enemy)
				EventBus.monster_spawned.emit(enemy)


## Spawn a monster from a DNA stack
func spawn_monster(dna_stack: MonsterDNAStack, position: Vector2, team: int = 0) -> Node2D:
	var monster := monster_assembler.assemble_monster(dna_stack, MonsterAssembler.SpawnContext.WORLD)
	if monster:
		monster.global_position = position
		monster.set_meta("team", team)
		monsters_container.add_child(monster)
		combat_manager.register_combatant(monster)
		EventBus.monster_spawned.emit(monster)
	return monster

