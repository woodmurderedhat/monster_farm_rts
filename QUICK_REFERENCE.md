# Monster DNA Farm RTS - Quick Reference Guide

**Purpose:** Fast reference for key systems and files  
**Audience:** Developers implementing features  
**Last Updated:** December 30, 2025

---

## Critical File Locations

### DNA System
```
data/dna/
├── base_dna_resource.gd          # Base class for all DNA
├── dna_core_resource.gd          # Core/body DNA
├── dna_element_resource.gd       # Element DNA
├── dna_behavior_resource.gd      # Personality/AI DNA
├── dna_ability_resource.gd       # Ability DNA
├── dna_mutation_resource.gd      # Mutation DNA
├── monster_dna_stack.gd          # Container for all DNA parts
├── cores/*.tres                  # Core resources (8 total)
├── elements/*.tres               # Element resources (7 total)
├── behaviors/*.tres              # Behavior resources (4 total)
└── abilities/*.tres              # Ability resources (10 total)
```

### Assembly & Components
```
systems/
├── monster_assembler.gd          # DNA → Monster conversion
└── combat/
    ├── damage_calculator.gd      # Damage formula
    ├── ability_executor.gd       # Ability execution
    ├── combat_manager.gd         # Combat orchestration
    ├── threat_component.gd       # Threat/aggro tracking
    └── combat_ai_component.gd    # AI decision making

entities/monster/
├── monster_base.tscn            # Base monster scene
├── monster_base.gd              # Monster class
└── components/
    ├── health_component.gd       # Health/death
    ├── stamina_component.gd      # Energy/ability costs
    ├── combat_component.gd       # Ability tracking
    ├── movement_component.gd     # Pathfinding
    ├── job_component.gd          # Farm work
    ├── needs_component.gd        # Monster needs (5)
    ├── stress_component.gd       # Mental state
    └── progression_component.gd  # XP/leveling
```

### Validation & Tools
```
data/validation/
├── dna_validator.gd             # Validation system
└── validation_result.gd         # Result logging

tools/
└── generate_dna.gd              # DNA generation helper
```

### Game Scenes
```
scenes/
├── game_world.tscn              # Main gameplay scene
├── game_world.gd                # Game controller (293 lines)
├── main_menu.tscn               # Menu (not implemented)
└── pause_menu.tscn              # Pause (not implemented)
```

### Save System
```
core/save/
└── save_manager.gd              # Save/load JSON system

core/globals/
├── event_bus.gd                 # Signal hub (autoload)
└── game_state.gd                # Global state (autoload)
```

---

## Key Data Structures

### MonsterDNAStack
```gdscript
var stack = MonsterDNAStack.new()
stack.core = DNACoreResource         # Required
stack.elements = [DNAElementResource, ...]  # 0-N
stack.behavior = DNABehaviorResource # Required
stack.abilities = [DNAAbilityResource, ...]  # 1-N
stack.mutations = [DNAMutationResource, ...]  # 0-N

# Methods:
stack.get_all_tags()              # Array[String]
stack.get_combined_stat_modifiers() # Dictionary
stack.get_total_instability()     # float (0.0-1.0)
stack.get_ai_configuration()      # Dictionary
stack.get_visual_layers()         # Array[Dictionary]
```

### Monster Metadata
```gdscript
monster.set_meta("dna_stack", dna_stack)
monster.set_meta("stat_block", {
    "max_health": 100,
    "max_stamina": 100,
    "attack": 10,
    "defense": 5,
    # ... all stats
})
monster.set_meta("ai_config", {
    "aggression": 0.7,
    "loyalty": 0.5,
    "curiosity": 0.6,
    "combat_roles": ["dps"],
    "work_affinity": {"combat": 1.5}
})
monster.set_meta("abilities", [
    {
        "id": "bite",
        "display_name": "Bite",
        "cooldown": 1.0,
        "energy_cost": 5.0,
        "base_power": 15.0,
        "enabled": true
    }
])
monster.set_meta("instability", 0.2)
```

### Validation Result
```gdscript
var result = ValidationResult.error("message", "source_id")
result.severity    # 0=Info, 1=Warning, 2=Error
result.message     # String
result.source_id   # String (DNA id)
result.is_error()  # bool
result.format()    # Formatted string for logging
```

---

## Common Operations

### Create & Spawn Monster
```gdscript
# Load DNA
var stack = load("res://data/monsters/test_sprigkin.tres")

# Validate (optional, but recommended)
var results = DNAValidator.validate_stack(stack)
if DNAValidator.has_blocking_errors(results):
    push_error("Invalid monster DNA")
    return

# Assemble
var assembler = MonsterAssembler.new()
var monster = assembler.assemble_monster(stack, MonsterAssembler.SpawnContext.WORLD)

# Add to scene
if monster:
    get_tree().current_scene.add_child(monster)
    monster.global_position = Vector2(100, 100)
```

### Deal Damage
```gdscript
var ability = {
    "id": "bite",
    "base_power": 15.0,
    "scaling_stats": ["attack"]
}

var damage = DamageCalculator.calculate_damage(attacker, defender, ability)
DamageCalculator.apply_damage(defender, damage, attacker)
```

### Use Ability
```gdscript
var combat_comp = monster.get_node("CombatComponent") as CombatComponent
if combat_comp.use_ability("bite", target_monster):
    print("Ability used successfully")
else:
    print("Ability failed (cooldown, stamina, etc)")
```

### Check Threat
```gdscript
var threat_comp = monster.get_node("ThreatComponent") as ThreatComponent
var highest_threat_target = threat_comp.get_highest_threat_target()
var threat_value = threat_comp.get_threat(some_target)
```

### Get Monster Stats
```gdscript
var stats = monster.get_meta("stat_block", {})
var health = stats.get("max_health", 100)
var attack = stats.get("attack", 0)
```

---

## Key Formulas

### Damage Calculation
```
Final Damage = (BasePower + Attack*0.1 - Defense/2) * CritMultiplier * InstabilityBonus
- BasePower: From ability DNA (base_power field)
- Attack: From monster stats
- Defense: From target monster stats
- CritMultiplier: 1.5 if critical, 1.0 otherwise
- InstabilityBonus: 1.0 + (instability * 0.5)
- Minimum: 1.0 damage
```

### Hit Chance
```
HitChance = Accuracy - Evasion
- Clamped between 0.5 (50%) and 0.95 (95%)
```

### Stat Assembly
```
FinalStat = BaseStat + AdditiveModifiers + (BaseStat * MultiplicativeModifiers)
- BaseStat: From core DNA
- AdditiveModifiers: Sum from all DNA parts (stat_modifiers dict)
- MultiplicativeModifiers: Applied after additives
- Instability Penalty: If instability > 0.5, reduce stats by up to 10%
```

### Threat Generation
```
ThreatFromDamage = DamageDealt
ThreatFromTaunt = SpecifiedAmount
ThreatFromProximity = BaseAmount * (1 - Distance/500)
```

---

## EventBus Signals

### Monster Events
```gdscript
signal monster_spawned(monster: Node2D)
signal monster_died(monster: Node2D)
signal monster_selected(monster: Node2D)
signal monster_deselected(monster: Node2D)
```

### Combat Events
```gdscript
signal combat_started
signal combat_ended
signal damage_dealt(attacker: Node2D, target: Node2D, amount: float)
signal ability_used(user: Node2D, ability_id: String, target: Node)
```

### Farm Events
```gdscript
signal job_posted(job_data: Dictionary)
signal job_claimed(job_data: Dictionary, worker: Node2D)
signal job_completed(job_data: Dictionary, worker: Node2D)
signal farm_state_changed
```

### Raid Events
```gdscript
signal raid_started(raid_data: Dictionary)
signal raid_wave_spawned(wave_number: int)
signal raid_ended(success: bool)
```

### Game Events
```gdscript
signal game_state_changed(new_state: String)
signal pause_state_changed(is_paused: bool)
```

---

## Component Lifecycle

### HealthComponent
```gdscript
max_health: float              # From stat_block
current_health: float          # Starts at max
health_changed.emit(current, max)  # On change
take_damage(amount, source)    # Reduce health
heal(amount, source)           # Increase health
died.emit()                    # At 0 HP
```

### StaminaComponent
```gdscript
max_stamina: float
current_stamina: float
regen_rate: float              # From stat_block
stamina_changed.emit(current, max)
consume(amount) -> bool        # Returns false if insufficient
add_stamina(amount)
```

### CombatComponent
```gdscript
abilities: Array[Dictionary]   # From dna_stack
in_combat: bool
use_ability(id, target) -> bool
is_on_cooldown(ability_id) -> bool
get_available_abilities() -> Array[Dictionary]
```

### JobComponent
```gdscript
current_job: Dictionary
is_working: bool
assign_job(job_data) -> bool
complete_job()
job_assigned.emit(job)
job_completed.emit(job)
```

### NeedsComponent
```gdscript
get_need(need_name) -> float   # 0.0-1.0
set_need(need_name, value)
add_need(need_name, amount)    # Positive or negative
# Needs: hunger, rest, safety, social, purpose
```

---

## Component Access Pattern

```gdscript
# Get components from monster
var monster = ... # Your monster node
var health = monster.get_node("HealthComponent") as HealthComponent
var stamina = monster.get_node("StaminaComponent") as StaminaComponent
var combat = monster.get_node("CombatComponent") as CombatComponent
var job = monster.get_node("JobComponent") as JobComponent
var needs = monster.get_node("NeedsComponent") as NeedsComponent

# Use components
health.take_damage(10.0)
stamina.consume(5.0)
combat.use_ability("bite", target)
job.assign_job(job_data)
needs.add_need("hunger", -10.0)  # Feed monster
```

---

## Debugging Tips

### Print Monster State
```gdscript
var stats = monster.get_meta("stat_block", {})
var ai_config = monster.get_meta("ai_config", {})
var abilities = monster.get_meta("abilities", [])
var instability = monster.get_meta("instability", 0.0)

print("Monster: %s" % monster.name)
print("Health: %d/%d" % [health.current_health, health.max_health])
print("Stamina: %.1f/%.1f" % [stamina.current_stamina, stamina.max_stamina])
print("Abilities: %d" % abilities.size())
print("Instability: %.0f%%" % (instability * 100))
```

### Validate DNA Before Spawn
```gdscript
var results = DNAValidator.validate_stack(dna_stack)
for result in results:
    print(result.format())
if DNAValidator.has_blocking_errors(results):
    print("ERROR: Cannot spawn this DNA stack")
```

### Test Damage Formula
```gdscript
var attacker_stats = attacker.get_meta("stat_block", {})
var defender_stats = defender.get_meta("stat_block", {})
print("Attack: %d, Defense: %d" % [
    attacker_stats.get("attack", 0),
    defender_stats.get("defense", 0)
])

var ability = {"base_power": 15.0, "scaling_stats": []}
var damage = DamageCalculator.calculate_damage(attacker, defender, ability)
print("Damage calculated: %.1f" % damage)
```

---

## Common Errors & Solutions

### Error: "Could not load DNA resource"
**Cause:** File path incorrect or file doesn't exist  
**Solution:** Check file exists at path, verify file name spelling

### Error: "Monster has no HealthComponent"
**Cause:** Component not a child of monster, or named incorrectly  
**Solution:** Verify monster_base.tscn has HealthComponent as direct child

### Error: "Validation failed with blocking errors"
**Cause:** DNA stack invalid (missing core, duplicate elements, etc)  
**Solution:** Check validation results, see IMPLEMENTATION_GUIDE.md for details

### Monster not moving
**Cause:** NavigationAgent2D not set up, or no navigation mesh  
**Solution:** Create NavigationRegion2D in scene, set navigation mesh

### Abilities not working
**Cause:** CombatComponent not wired to AbilityExecutor  
**Solution:** Check combat_manager is calling ability_executor.execute()

---

## Next Steps

1. **Test Monster Spawn**
   - Enable `spawn_test_monsters = true` in game_world.gd
   - Run game, verify 3 monsters appear

2. **Test Damage**
   - Manually call `damage_calculator.calculate_damage()`
   - Verify formula matches spec

3. **Test Abilities**
   - Call `combat_component.use_ability()`
   - Check ability executes and cooldown works

4. **Test Combat Loop**
   - Wire up CombatManager to run combat ticks
   - Watch monsters fight autonomously

---

**For detailed implementation guidance, see: IMPLEMENTATION_GUIDE.md**  
**For full task list, see: tasklist.md**  
**For current status, see: STATUS_REPORT.md**
