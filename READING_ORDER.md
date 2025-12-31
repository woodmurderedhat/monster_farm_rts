# Monster DNA Farm RTS - Reading Order & Architecture Guide

**Purpose:** Learn the codebase systematically  
**Time:** 2-4 hours for full understanding  
**Prerequisites:** Basic Godot knowledge

---

## Start Here: Core Concepts (30 minutes)

### 1. Read These Documentation Files (In Order)

1. **`docs/core-design-document.md`** (20 min)
   - Understand the game vision
   - Learn the 3 pillars (Exploration, DNA Engineering, Farm Defense)
   - Understand player fantasy

2. **`docs/technical-architecture.md`** (20 min)
   - Data-driven first principle
   - Composition over inheritance
   - Signal-based communication
   - Project structure overview

3. **`docs/monster-assembly-pipeline.md`** (10 min)
   - 8-step spawn process
   - Validation→Assembly→Stat Application→Finalization
   - Context-aware spawning

---

## Part 1: DNA System (1-1.5 hours)

### Read Source Code (In Order)

1. **`data/dna/base_dna_resource.gd`** (10 min)
   - Inheritance base for all DNA
   - Shared fields: id, tags, incompatible_tags, modifiers
   - Validate() method

2. **`data/dna/dna_core_resource.gd`** (10 min)
   - Physical foundation DNA
   - Body type, movement type, base stats
   - Slot limits (ability_slots, mutation_capacity)
   - Element allowlist

3. **`data/dna/dna_element_resource.gd`** (8 min)
   - Elemental affinity system
   - Damage bonuses, resistances
   - Environmental interactions
   - Status effects

4. **`data/dna/dna_behavior_resource.gd`** (8 min)
   - Personality traits (aggression, loyalty, curiosity, stress_tolerance)
   - Combat roles (tank, dps, support, scout)
   - Work affinity dictionary

5. **`data/dna/dna_ability_resource.gd`** (8 min)
   - Ability definition (cooldown, cost, range, targeting)
   - Scaling stats for damage calculation
   - Required tags for conditional activation
   - Power calculation

6. **`data/dna/dna_mutation_resource.gd`** (8 min)
   - Instability values
   - Override rules system
   - Forced visual changes
   - Feral state potential

7. **`data/dna/monster_dna_stack.gd`** (15 min)
   - Container combining all DNA parts
   - Stat aggregation methods
   - Tag collection
   - Instability calculation
   - **NEW:** AI configuration method
   - **NEW:** Visual layers method

### Files to Examine

- Look at `data/dna/cores/core_sprigkin.tres` - Example core DNA (Resource file)
- Look at `data/dna/behaviors/behavior_aggressive.tres` - Example behavior
- Look at `data/dna/abilities/ability_bite.tres` - Example ability

---

## Part 2: Validation System (30 minutes)

### Read Source Code

1. **`data/validation/validation_result.gd`** (8 min)
   - Result severity levels (Info, Warning, Error)
   - Factory methods
   - Formatting for display

2. **`data/validation/dna_validator.gd`** (22 min)
   - Entry point: `validate_stack()`
   - 7 validation phases
   - Individual part validation
   - Slot limit checking
   - Tag compatibility checking
   - Blocking error detection

### Understand the Flow

```
MonsterDNAStack
    ↓
DNAValidator.validate_stack()
    ├→ _validate_required_components()
    ├→ _validate_slot_limits()
    ├→ _validate_tag_compatibility()
    ├→ _validate_ability_requirements()
    ├→ _validate_element_compatibility()
    ├→ _validate_individual_parts()
    └→ _validate_mutation_limits()
         ↓
Array[ValidationResult]
```

---

## Part 3: Monster Assembly (1 hour)

### Read Source Code

1. **`systems/monster_assembler.gd`** (Complete file - 40 min)
   - `assemble_monster()` - Main entry point (8-step pipeline)
   - `_load_base_scene()` - Scene instantiation
   - `_initialize_components()` - Component setup
   - `_assemble_stats()` - Stat calculation
   - `_apply_stats()` - Apply to components
   - `_configure_ai()` - AI setup from DNA
   - `_assign_abilities()` - Ability wiring
   - `_apply_visuals()` - Visual modifications
   - `_finalize_monster()` - Final setup

2. **`entities/monster/monster_base.tscn`** (5 min)
   - Scene hierarchy
   - Component children
   - Signals

3. **`entities/monster/monster_base.gd`** (10 min)
   - Monster class
   - Component access
   - Command methods
   - Meta data getters

### Understand the Flow

```
MonsterDNAStack
    ↓
MonsterAssembler.assemble_monster()
    ├→ DNAValidator.validate_stack()
    ├→ Load monster_base.tscn
    ├→ Initialize components
    ├→ Build stat_block Dictionary
    ├→ Configure AI from behavior DNA
    ├→ Assign abilities from DNA
    ├→ Apply visual modifiers
    └→ Finalize and return
         ↓
Fully Functional Monster Node
```

---

## Part 4: Components System (1 hour)

### Read Source Code (In Priority Order)

1. **`entities/monster/components/health_component.gd`** (15 min)
   - Health tracking
   - Damage/heal methods
   - Death signal

2. **`entities/monster/components/stamina_component.gd`** (15 min)
   - Energy pool
   - Consumption and regeneration
   - Component dependency

3. **`entities/monster/components/combat_component.gd`** (20 min)
   - Ability tracking
   - Cooldown management
   - `use_ability()` flow

4. **`entities/monster/components/movement_component.gd`** (10 min)
   - Navigation setup
   - Pathfinding
   - Arrival detection

---

## Part 5: Combat System (1.5 hours)

### Read Source Code (In Order)

1. **`systems/combat/damage_calculator.gd`** (UPDATED TODAY) (20 min)
   - Damage formula: `(BasePower + Attack*0.1 - Defense/2) * CritMult * InstabilityBonus`
   - Hit chance calculation
   - Critical strike system
   - Integration points

2. **`systems/combat/ability_executor.gd`** (UPDATED TODAY) (30 min)
   - Main execute() method
   - Targeting modes (Self, Target, Area, Cone)
   - Ability-specific logic
   - Integration with DamageCalculator

3. **`systems/combat/combat_component.gd`** (20 min)
   - Ability management
   - Cooldown tracking
   - use_ability() implementation

4. **`systems/combat/threat_component.gd`** (15 min)
   - Threat table management
   - Threat generation types
   - Threat decay
   - Highest threat selection

5. **`systems/combat/combat_ai_component.gd`** (15 min)
   - AI state machine
   - Decision making
   - Target scoring

6. **`systems/combat/combat_manager.gd`** (15 min)
   - Combat orchestration
   - Combatant registration
   - Combat loop

### Combat Flow Diagram

```
CombatComponent.use_ability("bite", target)
    ├→ Check enabled?
    ├→ Check cooldown?
    ├→ Check stamina?
    ├→ Consume stamina
    ├→ Start cooldown
    └→ Emit ability_used signal
         ↓
AbilityExecutor.execute(user, ability_data, target)
    ├→ Calculate power with stat scaling
    ├→ Select targeting function based on type
    └→ Execute targeting function
         ↓
_execute_target_ability() [example]
    ├→ DamageCalculator.roll_hit()
    ├→ DamageCalculator.roll_critical()
    ├→ DamageCalculator.calculate_damage()
    └→ DamageCalculator.apply_damage()
         ↓
HealthComponent.take_damage()
    ├→ Reduce current_health
    ├→ Emit health_changed signal
    └→ Check if <= 0 → Emit died signal
```

---

## Part 6: Signals & Communication (30 minutes)

### Read Source Code

1. **`core/globals/event_bus.gd`** (15 min)
   - All signal declarations
   - Event categories (Monster, Combat, Farm, Raid, Player, UI, Game)
   - Signal emission patterns

2. **`core/globals/game_state.gd`** (15 min)
   - Global state management
   - State transitions
   - Pause system
   - Data storage (monsters, DNA collection, farm data)

### Signal Architecture

```
EventBus (Autoload)
├── monster_spawned(monster)
├── monster_died(monster)
├── combat_started
├── combat_ended
├── damage_dealt(attacker, target, amount)
├── ability_used(user, ability_id, target)
├── job_posted(job_data)
├── farm_state_changed
├── raid_started(raid_data)
└── game_state_changed(new_state)
```

---

## Part 7: Data Persistence (20 minutes)

### Read Source Code

1. **`core/save/save_manager.gd`** (20 min)
   - Save/load flow
   - JSON file structure
   - Resource serialization
   - Restoration process

### Save Structure

```
user://save_slot_X/
├── meta.json         (Version, timestamp, playtime)
├── world_state.json  (Regions, events, flags)
├── farm_state.json   (Structures, automation state)
├── player_state.json (Monsters, DNA collection)
└── mod_state.json    (Mod-specific data)
```

---

## Part 8: Game Loop & Integration (30 minutes)

### Read Source Code

1. **`scenes/game_world.gd`** (30 min)
   - `_ready()` - System initialization
   - `_setup_systems()` - Create all managers
   - `_setup_ui()` - UI creation
   - `_connect_signals()` - Event connections
   - `_spawn_test_monsters()` - Development helper
   - `_process()` - Main loop

---

## Part 9: Farm Automation (40 minutes)

### Read Source Code

1. **`systems/farm/farm_manager.gd`** (15 min)
   - Monster registration
   - Zone management
   - Job board integration
   - Statistics

2. **`systems/farm/job_board.gd`** (15 min)
   - Job posting
   - Job claiming
   - Job completion
   - Job filtering

3. **`systems/farm/farm_ai_component.gd`** (10 min)
   - Job evaluation loop
   - Job scoring
   - Lock-in timer

---

## Part 10: Understanding Data Flow

### Monster Creation Flow (Complete)

```
Create DNAStack
    ↓
Load cores/elements/behaviors/abilities/mutations
    ↓
Validate Stack
    ↓
MonsterAssembler.assemble_monster(stack)
    ├→ Load monster_base.tscn
    ├→ Create components
    ├→ Build stat_block from DNA modifiers
    ├→ Create AI config from behavior
    ├→ Create abilities list
    └→ Apply visual modifiers
         ↓
Monster Node (CharacterBody2D)
    ├→ Meta: dna_stack
    ├→ Meta: stat_block
    ├→ Meta: ai_config
    ├→ Meta: abilities
    ├→ Children: Components
    └→ Ready for gameplay
```

### Combat Flow (Complete)

```
Monster A attacks Monster B
    ↓
CombatComponent.use_ability("bite", monster_b)
    ├→ Validate (enabled, cooldown, stamina)
    ├→ Consume stamina
    ├→ Start cooldown
    └→ Emit ability_used
         ↓
AbilityExecutor.execute(attacker, ability_data, target)
    ├→ Roll hit (Accuracy vs Evasion)
    ├→ Roll critical
    └→ Calculate damage
         ↓
DamageCalculator methods
    ├→ calculate_damage(ability + stats)
    └→ apply_damage(result to target)
         ↓
HealthComponent.take_damage()
    ├→ Reduce health
    ├→ Check death
    └→ Emit signals
         ↓
ThreatComponent.add_damage_threat()
    └→ Adjust threat table
```

---

## Recommended Reading Order Summary

### For Understanding Architecture (4-5 hours)

1. Read core design document (20 min)
2. Read technical architecture (20 min)
3. Read monster assembly pipeline (10 min)
4. Study MonsterDNAStack (15 min)
5. Study DNAValidator (15 min)
6. Study MonsterAssembler (40 min)
7. Study Components (60 min)
8. Study Combat System (90 min)
9. Study EventBus & GameState (30 min)
10. Skim SaveManager (15 min)

### For Implementing Features (2-3 hours)

1. Read QUICK_REFERENCE.md (20 min)
2. Read IMPLEMENTATION_GUIDE.md (40 min)
3. Review relevant source files (60-80 min)
4. Check tasklist.md for specific tasks (20 min)

---

## Key Files to Understand First

### Must-Read (In Order)
1. `docs/core-design-document.md`
2. `docs/technical-architecture.md`
3. `data/dna/monster_dna_stack.gd`
4. `data/validation/dna_validator.gd`
5. `systems/monster_assembler.gd`

### Should-Read (When Implementing Combat)
6. `systems/combat/damage_calculator.gd`
7. `systems/combat/ability_executor.gd`
8. `systems/combat/combat_component.gd`

### Should-Read (When Implementing Features)
9. `core/globals/event_bus.gd`
10. `scenes/game_world.gd`

### Can-Read-Later (Lower Priority)
- Save system
- Farm automation
- World events
- Raid system

---

## Quick Navigation Tips

### Find a Specific System
- DNA System: `data/dna/`
- Combat: `systems/combat/`
- Components: `entities/monster/components/`
- Farm: `systems/farm/`
- Save/Load: `core/save/`
- Events: `core/globals/event_bus.gd`

### Find How Something Works
- **Monster creation:** `systems/monster_assembler.gd`
- **Damage calculation:** `systems/combat/damage_calculator.gd`
- **Ability execution:** `systems/combat/ability_executor.gd`
- **Game loop:** `scenes/game_world.gd`
- **Communication:** `core/globals/event_bus.gd`

---

## Testing as You Learn

### After Reading DNA System
```gdscript
var stack = load("res://data/monsters/test_sprigkin.tres")
var results = DNAValidator.validate_stack(stack)
print("Validation passed: %s" % (not DNAValidator.has_blocking_errors(results)))
```

### After Reading MonsterAssembler
```gdscript
var monster = MonsterAssembler.new().assemble_monster(stack)
print("Stats: %s" % monster.get_meta("stat_block"))
```

### After Reading Components
```gdscript
var health = monster.get_node("HealthComponent")
health.take_damage(10)
print("Health: %.0f/%.0f" % [health.current_health, health.max_health])
```

### After Reading Combat System
```gdscript
var damage = DamageCalculator.calculate_damage(attacker, defender, ability_data)
print("Damage: %.1f" % damage)
```

---

**Next:** Start with `docs/core-design-document.md` and follow the order above!
