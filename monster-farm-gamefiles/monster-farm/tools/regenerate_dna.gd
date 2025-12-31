# Regenerate all corrupted DNA .tres files
@tool
extends Node

func _ready():
	regenerate_dna()

func regenerate_dna():
	print("Regenerating DNA resources...")
	
	# Generate Cores
	var core_sprigkin = DNACoreResource.new()
	core_sprigkin.id = "core_sprigkin"
	core_sprigkin.display_name = "Sprigkin"
	core_sprigkin.description = "A small, fast creature with high agility"
	core_sprigkin.rarity = 1
	core_sprigkin.tags = PackedStringArray(["small", "fast", "evasive", "quadruped"])
	core_sprigkin.body_type = 0
	core_sprigkin.movement_type = 0
	core_sprigkin.base_size = 0.8
	core_sprigkin.base_mass = 0.6
	core_sprigkin.base_health = 60
	core_sprigkin.base_stamina = 120
	core_sprigkin.base_speed = 150.0
	core_sprigkin.allowed_elements = PackedStringArray(["fire", "lightning"])
	core_sprigkin.ability_slots = 3
	core_sprigkin.mutation_capacity = 1
	core_sprigkin.stat_modifiers = {
		"agility": 15,
		"speed": 20,
		"dodge": 10,
		"attack": 5
	}
	ResourceSaver.save(core_sprigkin, "res://data/dna/cores/core_sprigkin.tres")
	print("✓ Regenerated core_sprigkin")
	
	# Generate Elements
	var elem_fire = DNAElementResource.new()
	elem_fire.id = "elem_fire"
	elem_fire.display_name = "Fire"
	elem_fire.description = "Fire element"
	elem_fire.element_type = "fire"
	elem_fire.damage_bonus = 0.25
	elem_fire.tags = PackedStringArray(["fire", "aggressive"])
	elem_fire.stat_modifiers = {"attack": 10, "fire_damage": 20}
	ResourceSaver.save(elem_fire, "res://data/dna/elements/elem_fire.tres")
	print("✓ Regenerated elem_fire")
	
	var elem_water = DNAElementResource.new()
	elem_water.id = "elem_water"
	elem_water.display_name = "Water"
	elem_water.description = "Water element"
	elem_water.element_type = "water"
	elem_water.resistance_bonus = 0.2
	elem_water.tags = PackedStringArray(["water", "healing"])
	elem_water.stat_modifiers = {"defense": 10, "healing_power": 15}
	ResourceSaver.save(elem_water, "res://data/dna/elements/elem_water.tres")
	print("✓ Regenerated elem_water")
	
	var elem_nature = DNAElementResource.new()
	elem_nature.id = "elem_nature"
	elem_nature.display_name = "Nature"
	elem_nature.description = "Nature element"
	elem_nature.element_type = "bio"
	elem_nature.tags = PackedStringArray(["nature", "growth"])
	elem_nature.stat_modifiers = {"max_health": 30, "health_regen": 5}
	ResourceSaver.save(elem_nature, "res://data/dna/elements/elem_nature.tres")
	print("✓ Regenerated elem_nature")
	
	# Generate Abilities
	var ability_bite = DNAAbilityResource.new()
	ability_bite.ability_id = "bite"
	ability_bite.id = "ability_bite"
	ability_bite.display_name = "Bite"
	ability_bite.description = "Bite attack"
	ability_bite.cooldown = 1.0
	ability_bite.energy_cost = 10
	ability_bite.ability_range = 1.5
	ability_bite.targeting_type = 1
	ability_bite.base_power = 20
	ability_bite.tags = PackedStringArray(["attack", "melee"])
	ResourceSaver.save(ability_bite, "res://data/dna/abilities/ability_bite.tres")
	print("✓ Regenerated ability_bite")
	
	# Create placeholders for other abilities
	var ability_charge = DNAAbilityResource.new()
	ability_charge.ability_id = "charge"
	ability_charge.id = "ability_charge"
	ability_charge.display_name = "Charge"
	ability_charge.cooldown = 3.0
	ability_charge.energy_cost = 30
	ability_charge.base_power = 25
	ResourceSaver.save(ability_charge, "res://data/dna/abilities/ability_charge.tres")
	print("✓ Regenerated ability_charge")
	
	var ability_stun = DNAAbilityResource.new()
	ability_stun.ability_id = "stun"
	ability_stun.id = "ability_stun"
	ability_stun.display_name = "Stun"
	ability_stun.cooldown = 4.0
	ability_stun.energy_cost = 25
	ResourceSaver.save(ability_stun, "res://data/dna/abilities/ability_stun.tres")
	print("✓ Regenerated ability_stun")
	
	var ability_taunt = DNAAbilityResource.new()
	ability_taunt.ability_id = "taunt"
	ability_taunt.id = "ability_taunt"
	ability_taunt.display_name = "Taunt"
	ability_taunt.cooldown = 2.0
	ability_taunt.energy_cost = 15
	ResourceSaver.save(ability_taunt, "res://data/dna/abilities/ability_taunt.tres")
	print("✓ Regenerated ability_taunt")
	
	var ability_vine_whip = DNAAbilityResource.new()
	ability_vine_whip.ability_id = "vine_whip"
	ability_vine_whip.id = "ability_vine_whip"
	ability_vine_whip.display_name = "Vine Whip"
	ability_vine_whip.cooldown = 2.5
	ability_vine_whip.energy_cost = 20
	ability_vine_whip.base_power = 18
	ResourceSaver.save(ability_vine_whip, "res://data/dna/abilities/ability_vine_whip.tres")
	print("✓ Regenerated ability_vine_whip")
	
	var ability_zap = DNAAbilityResource.new()
	ability_zap.ability_id = "zap"
	ability_zap.id = "ability_zap"
	ability_zap.display_name = "Zap"
	ability_zap.cooldown = 1.5
	ability_zap.energy_cost = 12
	ability_zap.base_power = 15
	ResourceSaver.save(ability_zap, "res://data/dna/abilities/ability_zap.tres")
	print("✓ Regenerated ability_zap")
	
	# Generate Mutations
	var mut_intellect = DNAMutationResource.new()
	mut_intellect.id = "mutation_intellect"
	mut_intellect.display_name = "Intellect"
	mut_intellect.mutation_type = 0  # Positive
	mut_intellect.instability_value = 0.05
	mut_intellect.stat_modifiers = {"magic": 10, "wisdom": 10}
	ResourceSaver.save(mut_intellect, "res://data/dna/mutations/mutation_intellect.tres")
	print("✓ Regenerated mutation_intellect")
	
	var mut_resilient = DNAMutationResource.new()
	mut_resilient.id = "mutation_resilient"
	mut_resilient.display_name = "Resilient"
	mut_resilient.mutation_type = 0  # Positive
	mut_resilient.instability_value = 0.05
	mut_resilient.stat_modifiers = {"defense": 15, "health": 20}
	ResourceSaver.save(mut_resilient, "res://data/dna/mutations/mutation_resilient.tres")
	print("✓ Regenerated mutation_resilient")
	
	var mut_swift = DNAMutationResource.new()
	mut_swift.id = "mutation_swift"
	mut_swift.display_name = "Swift"
	mut_swift.mutation_type = 0  # Positive
	mut_swift.instability_value = 0.05
	mut_swift.stat_modifiers = {"speed": 25, "agility": 10}
	ResourceSaver.save(mut_swift, "res://data/dna/mutations/mutation_swift.tres")
	print("✓ Regenerated mutation_swift")
	
	var mut_volatile = DNAMutationResource.new()
	mut_volatile.id = "mutation_volatile"
	mut_volatile.display_name = "Volatile"
	mut_volatile.mutation_type = 2  # Chaotic
	mut_volatile.instability_value = 0.3
	mut_volatile.stat_modifiers = {"attack": 20, "instability": 0.3}
	ResourceSaver.save(mut_volatile, "res://data/dna/mutations/mutation_volatile.tres")
	print("✓ Regenerated mutation_volatile")
	
	# Generate missing cores
	var core_beetle = DNACoreResource.new()
	core_beetle.id = "core_beetle"
	core_beetle.display_name = "Beetle"
	core_beetle.body_type = 0
	core_beetle.base_health = 100
	core_beetle.base_speed = 70
	core_beetle.allowed_elements = PackedStringArray(["bio", "earth"])
	ResourceSaver.save(core_beetle, "res://data/dna/cores/core_beetle.tres")
	print("✓ Regenerated core_beetle")
	
	var core_drake = DNACoreResource.new()
	core_drake.id = "core_drake"
	core_drake.display_name = "Drake"
	core_drake.body_type = 0
	core_drake.base_health = 150
	core_drake.base_speed = 100
	core_drake.allowed_elements = PackedStringArray(["fire", "void"])
	ResourceSaver.save(core_drake, "res://data/dna/cores/core_drake.tres")
	print("✓ Regenerated core_drake")
	
	var core_sprite = DNACoreResource.new()
	core_sprite.id = "core_sprite"
	core_sprite.display_name = "Sprite"
	core_sprite.body_type = 0
	core_sprite.base_health = 50
	core_sprite.base_speed = 120
	core_sprite.allowed_elements = PackedStringArray(["water", "lightning"])
	ResourceSaver.save(core_sprite, "res://data/dna/cores/core_sprite.tres")
	print("✓ Regenerated core_sprite")
	
	print("\n=== DNA Regeneration Complete ===\n")
