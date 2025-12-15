# Godot 4 Monster DNA Farm RTS – Godot Resource Class Definitions

---

## 1. Purpose

This document defines the **concrete Godot 4 `Resource` classes** used to implement the DNA system and its supporting data.

Goals:

* Copy-paste–ready GDScript skeletons
* Strong typing and editor friendliness
* Safe for mods and long-term expansion
* Zero gameplay logic in Resources

All Resources use `class_name` and are saved as `.tres` or `.res` files.

---

## 2. Base DNA Resource

```gdscript
# res://data/dna/base_dna_resource.gd
extends Resource
class_name BaseDNAResource

@export var id: String
@export var display_name: String
@export_multiline var description: String

@export_enum("Common", "Uncommon", "Rare", "Epic", "Legendary")
var rarity: int = 0

@export var tags: Array[String] = []
@export var incompatible_tags: Array[String] = []

# Generic modifiers interpreted by systems
@export var stat_modifiers: Dictionary = {}
@export var ai_modifiers: Dictionary = {}
@export var visual_modifiers: Dictionary = {}
```

---

## 3. DNACoreResource

Defines the monster’s physical and structural foundation.

```gdscript
# res://data/dna/dna_core_resource.gd
extends BaseDNAResource
class_name DNACoreResource

@export_enum("Quadruped", "Biped", "Serpentine", "Swarm")
var body_type: int

@export_enum("Ground", "Flying", "Burrowing")
var movement_type: int

@export var base_size: float = 1.0
@export var base_mass: float = 1.0

@export var base_health: int = 100
@export var base_stamina: int = 100
@export var base_speed: float = 100.0

@export var allowed_elements: Array[String] = []
@export var ability_slots: int = 2
@export var mutation_capacity: int = 1
```

---

## 4. DNAElementResource

Defines elemental affinities.

```gdscript
# res://data/dna/dna_element_resource.gd
extends BaseDNAResource
class_name DNAElementResource

@export var element_type: String
@export var damage_bonus: float = 0.0
@export var resistance_bonus: float = 0.0

@export var status_effects: Array[Resource] = []
@export var environmental_interactions: Dictionary = {}
```

---

## 5. DNABehaviorResource

Defines personality and AI tendencies.

```gdscript
# res://data/dna/dna_behavior_resource.gd
extends BaseDNAResource
class_name DNABehaviorResource

@export_range(0.0, 1.0) var aggression: float = 0.5
@export_range(0.0, 1.0) var loyalty: float = 0.5
@export_range(0.0, 1.0) var curiosity: float = 0.5

@export var work_affinity: Dictionary = {}
@export var combat_roles: Array[String] = []

@export_range(0.0, 1.0) var stress_tolerance: float = 0.5
```

---

## 6. DNAAbilityResource

Defines a monster ability (data only).

```gdscript
# res://data/dna/dna_ability_resource.gd
extends BaseDNAResource
class_name DNAAbilityResource

@export var ability_id: String
@export var cooldown: float = 1.0
@export var energy_cost: float = 10.0
@export var range: float = 100.0

@export_enum("Self", "Target", "Area", "Cone")
var targeting_type: int

@export var scaling_stats: Array[String] = []
@export var required_tags: Array[String] = []
```

---

## 7. DNAMutationResource

Defines unstable or rule-breaking modifiers.

```gdscript
# res://data/dna/dna_mutation_resource.gd
extends BaseDNAResource
class_name DNAMutationResource

@export_enum("Positive", "Negative", "Chaotic")
var mutation_type: int

@export var instability_value: float = 0.1

# Allows mutation to override validation or stats
@export var override_rules: Dictionary = {}
@export var forced_visuals: Dictionary = {}
```

---

## 8. MonsterDNAStack Resource

A container Resource used during monster creation.

```gdscript
# res://data/dna/monster_dna_stack.gd
extends Resource
class_name MonsterDNAStack

@export var core: DNACoreResource
@export var elements: Array[DNAElementResource] = []
@export var behavior: DNABehaviorResource
@export var abilities: Array[DNAAbilityResource] = []
@export var mutations: Array[DNAMutationResource] = []
```

---

## 9. Validation Result Resource

Used by editor tools and runtime checks.

```gdscript
# res://data/validation/validation_result.gd
extends Resource
class_name ValidationResult

@export_enum("Info", "Warning", "Error")
var severity: int

@export var message: String
@export var source_id: String
```

---

## 10. Validator Interface

All validators implement the same interface.

```gdscript
# res://data/validation/validator.gd
extends Resource
class_name Validator

func validate(dna_stack: MonsterDNAStack) -> Array[ValidationResult]:
	return []
```

---

## 11. Why This Works

* Resources are small, serializable, and mod-safe
* Strong typing improves editor UX
* Validation is reusable everywhere
* Logic lives entirely in systems

This schema is ready to:

* Be extended by mods
* Be validated automatically
* Drive visuals, AI, combat, and automation

---

These Resource definitions are the  **bedrock of the entire project** .
