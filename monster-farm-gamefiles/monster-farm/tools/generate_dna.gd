# Script to generate core DNA resources for vertical slice
# This file can be run in the Godot console or as a tool script
@tool
extends Node

# Run this to generate all vertical slice DNA content
func generate_core_dna():
	# Create Sprigkin Core
	var sprigkin = DNACoreResource.new()
	sprigkin.id = "core_sprigkin"
	sprigkin.display_name = "Sprigkin"
	sprigkin.description = "A small, fast creature with high agility and evasion. Perfect for skirmishing and evasion tactics."
	sprigkin.rarity = 1  # Uncommon
	sprigkin.tags = PackedStringArray(["small", "fast", "evasive", "quadruped", "nimble"])
	sprigkin.incompatible_tags = PackedStringArray(["heavy", "slow", "tank"])
	
	sprigkin.body_type = 0  # Quadruped
	sprigkin.movement_type = 0  # Ground
	sprigkin.base_size = 0.8
	sprigkin.base_mass = 0.6
	sprigkin.base_health = 60
	sprigkin.base_stamina = 120
	sprigkin.base_speed = 150.0
	
	sprigkin.allowed_elements = PackedStringArray(["fire", "lightning"])
	sprigkin.ability_slots = 3
	sprigkin.mutation_capacity = 1
	
	sprigkin.stat_modifiers = {
		"agility": 15,
		"speed": 20,
		"dodge": 10,
		"attack": 5
	}
	
	sprigkin.visual_modifiers = {
		"primary_color": "#90EE90",
		"scale": 0.8,
		"animation_speed": 1.2
	}
	
	ResourceSaver.save(sprigkin, "res://data/dna/cores/core_sprigkin.tres")
	print("✓ Created core_sprigkin")
	
	# Create Barkmaw Core
	var barkmaw = DNACoreResource.new()
	barkmaw.id = "core_barkmaw"
	barkmaw.display_name = "Barkmaw"
	barkmaw.description = "A large, sturdy creature with exceptional durability. Naturally tanky and protective."
	barkmaw.rarity = 1  # Uncommon
	barkmaw.tags = PackedStringArray(["large", "heavy", "durable", "quadruped", "protective"])
	barkmaw.incompatible_tags = PackedStringArray(["small", "fragile", "evasive"])
	
	barkmaw.body_type = 0  # Quadruped
	barkmaw.movement_type = 0  # Ground
	barkmaw.base_size = 1.3
	barkmaw.base_mass = 2.0
	barkmaw.base_health = 200
	barkmaw.base_stamina = 80
	barkmaw.base_speed = 80.0
	
	barkmaw.allowed_elements = ["water", "earth"]
	barkmaw.ability_slots = 2
	barkmaw.mutation_capacity = 2
	
	barkmaw.stat_modifiers = {
		"health": 50,
		"defense": 20,
		"armor": 15,
		"threat": 10
	}
	
	barkmaw.visual_modifiers = {
		"primary_color": "#8B4513",
		"scale": 1.3,
		"skin_texture": "bark"
	}
	
	ResourceSaver.save(barkmaw, "res://data/dna/cores/core_barkmaw.tres")
	print("✓ Created core_barkmaw")
	
	# Create Sporespawn Core
	var sporespawn = DNACoreResource.new()
	sporespawn.id = "core_sporespawn"
	sporespawn.display_name = "Sporespawn"
	sporespawn.description = "A medium-sized creature specialized in support and healing. Focuses on team utility."
	sporespawn.rarity = 1  # Uncommon
	sporespawn.tags = PackedStringArray(["medium", "support", "healer", "biped"])
	sporespawn.incompatible_tags = PackedStringArray(["aggressive", "solo"])
	
	sporespawn.body_type = 1  # Biped
	sporespawn.movement_type = 0  # Ground
	sporespawn.base_size = 1.0
	sporespawn.base_mass = 1.0
	sporespawn.base_health = 100
	sporespawn.base_stamina = 150
	sporespawn.base_speed = 100.0
	
	sporespawn.allowed_elements = ["water", "bio", "void"]
	sporespawn.ability_slots = 4
	sporespawn.mutation_capacity = 1
	
	sporespawn.stat_modifiers = {
		"magic": 15,
		"wisdom": 10,
		"healing_power": 20,
		"speed": 5
	}
	
	sporespawn.visual_modifiers = {
		"primary_color": "#9370DB",
		"scale": 1.0,
		"glow": true
	}
	
	ResourceSaver.save(sporespawn, "res://data/dna/cores/core_sporespawn.tres")
	print("✓ Created core_sporespawn")


func generate_element_dna():
	# Fire Element
	var fire = DNAElementResource.new()
	fire.id = "elem_fire"
	fire.display_name = "Fire Element"
	fire.description = "Infuses the monster with fire energy, increasing damage and speed."
	fire.element_type = "fire"
	fire.damage_bonus = 0.25
	fire.tags = PackedStringArray(["fire", "hot", "aggressive"])
	fire.stat_modifiers = {
		"attack": 10,
		"speed": 5,
		"fire_damage": 20
	}
	fire.visual_modifiers = {
		"effect_particles": "fire",
		"color_tint": "#FF6347"
	}
	ResourceSaver.save(fire, "res://data/dna/elements/elem_fire.tres")
	print("✓ Created elem_fire")
	
	# Water Element
	var water = DNAElementResource.new()
	water.id = "elem_water"
	water.display_name = "Water Element"
	water.description = "Infuses the monster with water energy, enhancing healing and defense."
	water.element_type = "water"
	water.resistance_bonus = 0.2
	water.tags = PackedStringArray(["water", "cool", "healing"])
	water.stat_modifiers = {
		"defense": 10,
		"healing_power": 15,
		"water_resistance": 20
	}
	water.visual_modifiers = {
		"effect_particles": "water",
		"color_tint": "#4169E1"
	}
	ResourceSaver.save(water, "res://data/dna/elements/elem_water.tres")
	print("✓ Created elem_water")
	
	# Bio Element
	var bio = DNAElementResource.new()
	bio.id = "elem_bio"
	bio.display_name = "Bio Element"
	bio.description = "Infuses the monster with organic growth energy, enhancing health and regeneration."
	bio.element_type = "bio"
	bio.tags = PackedStringArray(["bio", "natural", "growth"])
	bio.stat_modifiers = {
		"max_health": 30,
		"health_regen": 5,
		"fertility": 10
	}
	bio.visual_modifiers = {
		"effect_particles": "vines",
		"color_tint": "#228B22"
	}
	ResourceSaver.save(bio, "res://data/dna/elements/elem_bio.tres")
	print("✓ Created elem_bio")
	
	# Lightning Element
	var lightning = DNAElementResource.new()
	lightning.id = "elem_lightning"
	lightning.display_name = "Lightning Element"
	lightning.description = "Infuses the monster with electrical energy, increasing attack speed and damage."
	lightning.element_type = "lightning"
	lightning.damage_bonus = 0.2
	lightning.tags = PackedStringArray(["lightning", "electric", "fast"])
	lightning.stat_modifiers = {
		"attack_speed": 15,
		"lightning_damage": 15,
		"agility": 10
	}
	lightning.visual_modifiers = {
		"effect_particles": "electricity",
		"color_tint": "#FFD700"
	}
	ResourceSaver.save(lightning, "res://data/dna/elements/elem_lightning.tres")
	print("✓ Created elem_lightning")
	
	# Void Element
	var void_elem = DNAElementResource.new()
	void_elem.id = "elem_void"
	void_elem.display_name = "Void Element"
	void_elem.description = "Infuses the monster with void energy, unstable but powerful. High instability."
	void_elem.element_type = "void"
	void_elem.damage_bonus = 0.3
	void_elem.tags = PackedStringArray(["void", "chaotic", "unstable"])
	void_elem.incompatible_tags = PackedStringArray(["bio"])
	void_elem.stat_modifiers = {
		"chaos": 20,
		"void_damage": 30,
		"instability": 0.2
	}
	void_elem.visual_modifiers = {
		"effect_particles": "void",
		"color_tint": "#2F4F4F",
		"opacity": 0.8
	}
	ResourceSaver.save(void_elem, "res://data/dna/elements/elem_void.tres")
	print("✓ Created elem_void")


func _ready():
	print("\n=== Generating Vertical Slice DNA Content ===\n")
	generate_core_dna()
	print()
	generate_element_dna()
	print("\n=== DNA Generation Complete ===\n")
