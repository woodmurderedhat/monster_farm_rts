# Integration Test Suite - headless-friendly runner
extends RefCounted
class_name IntegrationTestSuite

# Test results tracking
var tests_passed := 0
var tests_failed := 0
var test_log: Array[String] = []


func run_all() -> Dictionary:
	tests_passed = 0
	tests_failed = 0
	test_log.clear()

	_print_header()

	test_dna_validation()
	test_monster_assembly()
	test_component_initialization()
	test_stat_calculation()
	test_ability_assignment()
	test_ai_configuration()
	test_scene_smoke_loads()

	_print_summary()

	return {
		"passed": tests_passed,
		"failed": tests_failed,
		"total": tests_passed + tests_failed,
		"log": test_log.duplicate(true)
	}


func _print_header() -> void:
	print("\n========================================")
	print("MONSTER FARM RTS - INTEGRATION TEST")
	print("========================================\n")


func _print_summary() -> void:
	print("\n========================================")
	print("TEST SUMMARY")
	print("========================================")
	print("Passed: %d" % tests_passed)
	print("Failed: %d" % tests_failed)
	print("Total: %d" % (tests_passed + tests_failed))

	if tests_failed > 0:
		print("\nFAILED TESTS:")
		for entry in test_log:
			if "FAIL" in entry:
				print("  - " + entry)

	print("\n========================================\n")


## Test DNA validation system
func test_dna_validation() -> void:
	print("TEST 1: DNA Validation System")
	print("------------------------------")
	
	# Create valid DNA stack
	var core := load("res://data/dna/cores/core_sprigkin.tres") as DNACoreResource
	var element := load("res://data/dna/elements/element_fire.tres") as DNAElementResource
	var behavior := load("res://data/dna/behaviors/behavior_aggressive.tres") as DNABehaviorResource
	var ability := load("res://data/dna/abilities/ability_bite.tres") as DNAAbilityResource
	
	if not core or not element or not behavior or not ability:
		_test_fail("Failed to load DNA resources")
		return
	
	var stack := MonsterDNAStack.new()
	stack.core = core
	stack.elements = [element]
	stack.behavior = behavior
	stack.abilities = [ability]
	
	# Validate
	var results := DNAValidator.validate_stack(stack)
	
	# Should have no blocking errors
	var has_errors := DNAValidator.has_blocking_errors(results)
	if not has_errors:
		_test_pass("DNA Validation: No blocking errors on valid stack")
	else:
		_test_fail("DNA Validation: Found blocking errors on valid stack")
		for result in results:
			if result.is_error():
				print("  ERROR: " + result.message)
	
	# Test missing core
	var invalid_stack := MonsterDNAStack.new()
	invalid_stack.behavior = behavior
	invalid_stack.abilities = [ability]
	
	var invalid_results := DNAValidator.validate_stack(invalid_stack)
	if DNAValidator.has_blocking_errors(invalid_results):
		_test_pass("DNA Validation: Detected missing core")
	else:
		_test_fail("DNA Validation: Did not detect missing core")
	
	print()


## Test monster assembly
func test_monster_assembly() -> void:
	print("TEST 2: Monster Assembly")
	print("------------------------")
	
	# Create assembler
	var assembler := MonsterAssembler.new()
	
	# Create DNA stack
	var core := load("res://data/dna/cores/core_wolf.tres") as DNACoreResource
	var element := load("res://data/dna/elements/element_fire.tres") as DNAElementResource
	var behavior := load("res://data/dna/behaviors/behavior_aggressive.tres") as DNABehaviorResource
	var ability1 := load("res://data/dna/abilities/ability_bite.tres") as DNAAbilityResource
	var ability2 := load("res://data/dna/abilities/ability_fireball.tres") as DNAAbilityResource
	
	var stack := MonsterDNAStack.new()
	stack.core = core
	stack.elements = [element]
	stack.behavior = behavior
	stack.abilities = [ability1, ability2]
	
	# Assemble monster
	var monster := assembler.assemble_monster(stack, MonsterAssembler.SpawnContext.EDITOR_PREVIEW)
	
	if monster:
		_test_pass("Monster Assembly: Successfully created monster")
		
		# Verify metadata
		if monster.has_meta("stat_block"):
			_test_pass("Monster Assembly: Stat block attached")
		else:
			_test_fail("Monster Assembly: Missing stat block")
		
		if monster.has_meta("ai_config"):
			_test_pass("Monster Assembly: AI config attached")
		else:
			_test_fail("Monster Assembly: Missing AI config")
		
		if monster.has_meta("abilities"):
			_test_pass("Monster Assembly: Abilities attached")
		else:
			_test_fail("Monster Assembly: Missing abilities")
		
		# Clean up
		monster.queue_free()
	else:
		_test_fail("Monster Assembly: Failed to create monster")
	
	assembler.queue_free()
	print()


## Test component initialization
func test_component_initialization() -> void:
	print("TEST 3: Component Initialization")
	print("---------------------------------")
	
	var assembler := MonsterAssembler.new()
	
	# Create simple DNA stack
	var core := load("res://data/dna/cores/core_sprigkin.tres") as DNACoreResource
	var behavior := load("res://data/dna/behaviors/behavior_defensive.tres") as DNABehaviorResource
	var ability := load("res://data/dna/abilities/ability_bite.tres") as DNAAbilityResource
	
	var stack := MonsterDNAStack.new()
	stack.core = core
	stack.behavior = behavior
	stack.abilities = [ability]
	
	var monster := assembler.assemble_monster(stack, MonsterAssembler.SpawnContext.EDITOR_PREVIEW)
	
	if monster:
		# Check for components
		var health_comp := monster.get_node_or_null("HealthComponent")
		if health_comp:
			_test_pass("Components: HealthComponent exists")
		else:
			_test_fail("Components: HealthComponent missing")
		
		var combat_comp := monster.get_node_or_null("CombatComponent")
		if combat_comp:
			_test_pass("Components: CombatComponent exists")
		else:
			_test_fail("Components: CombatComponent missing")
		
		var movement_comp := monster.get_node_or_null("MovementComponent")
		if movement_comp:
			_test_pass("Components: MovementComponent exists")
		else:
			_test_fail("Components: MovementComponent missing")
		
		monster.queue_free()
	else:
		_test_fail("Components: Could not create monster for testing")
	
	assembler.queue_free()
	print()


## Test stat calculation
func test_stat_calculation() -> void:
	print("TEST 4: Stat Calculation")
	print("------------------------")
	
	var assembler := MonsterAssembler.new()
	
	var core := load("res://data/dna/cores/core_golem.tres") as DNACoreResource
	var behavior := load("res://data/dna/behaviors/behavior_defensive.tres") as DNABehaviorResource
	var ability := load("res://data/dna/abilities/ability_shield.tres") as DNAAbilityResource
	
	var stack := MonsterDNAStack.new()
	stack.core = core
	stack.behavior = behavior
	stack.abilities = [ability]
	
	var monster := assembler.assemble_monster(stack, MonsterAssembler.SpawnContext.EDITOR_PREVIEW)
	
	if monster and monster.has_meta("stat_block"):
		var stats: Dictionary = monster.get_meta("stat_block")
		
		# Verify stats exist and are valid
		if stats.has("max_health") and stats["max_health"] > 0:
			_test_pass("Stats: max_health calculated (%d)" % stats["max_health"])
		else:
			_test_fail("Stats: max_health invalid or missing")
		
		if stats.has("speed") and stats["speed"] >= 0:
			_test_pass("Stats: speed calculated (%d)" % stats["speed"])
		else:
			_test_fail("Stats: speed invalid or missing")
		
		if stats.has("size") and stats["size"] > 0:
			_test_pass("Stats: size calculated (%.2f)" % stats["size"])
		else:
			_test_fail("Stats: size invalid or missing")
		
		# Check no NaN or Inf values
		var has_invalid := false
		for key in stats.keys():
			var value = stats[key]
			if typeof(value) in [TYPE_INT, TYPE_FLOAT]:
				if is_nan(value) or is_inf(value):
					has_invalid = true
					_test_fail("Stats: %s has invalid value (NaN/Inf)" % key)
		
		if not has_invalid:
			_test_pass("Stats: No NaN or Inf values detected")
		
		monster.queue_free()
	else:
		_test_fail("Stats: Could not create monster or stat block missing")
	
	assembler.queue_free()
	print()


## Test ability assignment
func test_ability_assignment() -> void:
	print("TEST 5: Ability Assignment")
	print("--------------------------")
	
	var assembler := MonsterAssembler.new()
	
	var core := load("res://data/dna/cores/core_drake.tres") as DNACoreResource
	var element := load("res://data/dna/elements/element_fire.tres") as DNAElementResource
	var behavior := load("res://data/dna/behaviors/behavior_aggressive.tres") as DNABehaviorResource
	var ability1 := load("res://data/dna/abilities/ability_fireball.tres") as DNAAbilityResource
	var ability2 := load("res://data/dna/abilities/ability_bite.tres") as DNAAbilityResource
	
	var stack := MonsterDNAStack.new()
	stack.core = core
	stack.elements = [element]
	stack.behavior = behavior
	stack.abilities = [ability1, ability2]
	
	var monster := assembler.assemble_monster(stack, MonsterAssembler.SpawnContext.EDITOR_PREVIEW)
	
	if monster and monster.has_meta("abilities"):
		var abilities: Array = monster.get_meta("abilities")
		
		if abilities.size() == 2:
			_test_pass("Abilities: Correct count assigned (2)")
		else:
			_test_fail("Abilities: Wrong count (expected 2, got %d)" % abilities.size())
		
		# Verify ability structure
		var has_valid_structure := true
		for ability_data in abilities:
			if not ability_data is Dictionary:
				has_valid_structure = false
				break
			if not ability_data.has("id") or not ability_data.has("cooldown"):
				has_valid_structure = false
				break
		
		if has_valid_structure:
			_test_pass("Abilities: Valid ability structure")
		else:
			_test_fail("Abilities: Invalid ability structure")
		
		monster.queue_free()
	else:
		_test_fail("Abilities: Could not create monster or abilities missing")
	
	assembler.queue_free()
	print()


## Test AI configuration
func test_ai_configuration() -> void:
	print("TEST 6: AI Configuration")
	print("------------------------")
	
	var assembler := MonsterAssembler.new()
	
	var core := load("res://data/dna/cores/core_serpent.tres") as DNACoreResource
	var behavior := load("res://data/dna/behaviors/behavior_cunning.tres") as DNABehaviorResource
	var ability := load("res://data/dna/abilities/ability_poison_spit.tres") as DNAAbilityResource
	
	var stack := MonsterDNAStack.new()
	stack.core = core
	stack.behavior = behavior
	stack.abilities = [ability]
	
	var monster := assembler.assemble_monster(stack, MonsterAssembler.SpawnContext.EDITOR_PREVIEW)
	
	if monster and monster.has_meta("ai_config"):
		var ai_config: Dictionary = monster.get_meta("ai_config")
		
		# Verify AI parameters exist and are in valid range
		if ai_config.has("aggression"):
			var aggro: float = ai_config["aggression"]
			if aggro >= 0.0 and aggro <= 1.0:
				_test_pass("AI Config: aggression in valid range (%.2f)" % aggro)
			else:
				_test_fail("AI Config: aggression out of range (%.2f)" % aggro)
		else:
			_test_fail("AI Config: aggression missing")
		
		if ai_config.has("loyalty"):
			var loyalty: float = ai_config["loyalty"]
			if loyalty >= 0.0 and loyalty <= 1.0:
				_test_pass("AI Config: loyalty in valid range (%.2f)" % loyalty)
			else:
				_test_fail("AI Config: loyalty out of range (%.2f)" % loyalty)
		else:
			_test_fail("AI Config: loyalty missing")
		
		if ai_config.has("combat_roles"):
			_test_pass("AI Config: combat_roles assigned")
		else:
			_test_fail("AI Config: combat_roles missing")
		
		monster.queue_free()
	else:
		_test_fail("AI Config: Could not create monster or AI config missing")
	
	assembler.queue_free()
	print()


const SCENE_SMOKE_PATHS := [
	"res://scenes/main_menu.tscn",
	"res://scenes/main_ui.tscn",
	"res://scenes/game_world.tscn",
	"res://scenes/farm_scene.tscn",
	"res://scenes/raid_scene.tscn",
	"res://scenes/zone_scene.tscn"
]


## Test key scenes can load and instantiate headlessly
func test_scene_smoke_loads() -> void:
	print("TEST 7: Scene Smoke Loads")
	print("-------------------------")

	for scene_path in SCENE_SMOKE_PATHS:
		var scene: PackedScene = load(scene_path)
		if scene == null:
			_test_fail("Scene missing: %s" % scene_path)
			continue

		var instance: Node = scene.instantiate()
		if instance:
			_test_pass("Scene loads and instantiates: %s" % scene_path)
			instance.free()
		else:
			_test_fail("Scene failed to instantiate: %s" % scene_path)

	print()


## Helper: mark test as passed
func _test_pass(message: String) -> void:
	tests_passed += 1
	print("  \u2713 " + message)
	test_log.append("PASS: " + message)


## Helper: mark test as failed
func _test_fail(message: String) -> void:
	tests_failed += 1
	print("  \u2717 " + message)
	test_log.append("FAIL: " + message)
