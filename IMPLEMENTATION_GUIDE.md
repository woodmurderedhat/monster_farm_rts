# Monster DNA Farm RTS - Critical Implementation Guide

**Status:** Phase 1 (DNA & Validation) Complete ✅  
**Next Phase:** Phase 2 (Monster Assembly & Runtime)  
**Last Updated:** December 30, 2025

---

## Phase 1 Summary: DNA & Validation ✅

### Completed:
- ✅ DNA Resource classes (Core, Element, Behavior, Ability, Mutation)
- ✅ MonsterDNAStack container with stat/tag aggregation
- ✅ DNAValidator with comprehensive checks
- ✅ ValidationResult logging system
- ✅ Test DNA content (cores, behaviors, abilities, elements)
- ✅ Added `get_ai_configuration()` and `get_visual_layers()` methods to MonsterDNAStack

### What Works:
```gdscript
# Creating and validating monsters:
var dna_stack = MonsterDNAStack.new()
dna_stack.core = load("res://data/dna/cores/core_sprigkin.tres")
dna_stack.behavior = load("res://data/dna/behaviors/behavior_aggressive.tres")
dna_stack.abilities = [load("res://data/dna/abilities/ability_bite.tres")]

var results = DNAValidator.validate_stack(dna_stack)
if not DNAValidator.has_blocking_errors(results):
    # Monster is valid!
```

---

## Phase 2: Monster Assembly & Runtime (IN PROGRESS)

### Current Status:
- ✅ MonsterAssembler pipeline framework exists
- ✅ All 8 assembly steps implemented
- ⚠️ Stat application needs testing and verification
- ⚠️ Visual application framework exists but incomplete
- ⚠️ Test with actual monsters needed

### Critical Tasks:

#### 2.1 Test MonsterAssembler with Real Data
**File:** `scenes/game_world.gd` - `_spawn_test_monsters()` method

**What to do:**
1. Create test monsters manually via GDScript:
   ```gdscript
   var test_stack = load("res://data/monsters/test_sprigkin.tres") as MonsterDNAStack
   var assembled_monster = MonsterAssembler.new().assemble_monster(test_stack)
   if assembled_monster:
       add_child(assembled_monster)
   ```

2. Verify in Play mode:
   - Monster appears without crash
   - Health/stamina are initialized
   - AI configuration loaded
   - Abilities are assigned
   - Visual scale applied

**Success Criteria:**
- Can spawn 5 different monster builds
- No crashes
- Stats match expected values from DNA

#### 2.2 Stat Application Validation
**File:** `systems/monster_assembler.gd` - `_apply_stats()` method

**Currently:**
- Base stats from core applied ✅
- Modifiers aggregated ✅
- Instability penalties applied ✅
- Health component initialized (partially)

**Needs:**
1. Proper HealthComponent initialization:
   ```gdscript
   if health_component:
       health_component.max_health = stat_block.get("max_health", 100)
       health_component.current_health = stat_block.get("max_health", 100)
   ```

2. StaminaComponent initialization:
   ```gdscript
   if stamina_component:
       stamina_component.max_stamina = stat_block.get("max_stamina", 100)
       stamina_component.current_stamina = stat_block.get("max_stamina", 100)
   ```

3. Verify stat formula matches design doc:
   - Base + Additive + Multiplicative + Instability Penalties

**Test with:**
```gdscript
var stats = monster.get_meta("stat_block", {})
print("Health: %d" % stats.get("max_health"))
print("Stamina: %d" % stats.get("max_stamina"))
print("Attack: %d" % stats.get("attack"))
```

#### 2.3 Component Verification
**Critical Components to Verify Work:**

1. **HealthComponent** - Must work
   - [ ] `take_damage()` reduces health
   - [ ] Health can't go below 0
   - [ ] Death signal emitted at 0 HP
   - [ ] `heal()` restores health
   - [ ] Can't exceed max health

2. **StaminaComponent** - Must work
   - [ ] `consume()` reduces stamina
   - [ ] `regen()` restores stamina over time
   - [ ] Can't exceed max stamina
   - [ ] Returns false if not enough stamina

3. **MovementComponent** - Critical
   - [ ] Initializes with velocity
   - [ ] `move_to(target_position)` works
   - [ ] Uses NavigationAgent2D for pathfinding
   - [ ] Emits `destination_reached` signal
   - [ ] **CURRENT ISSUE:** Navigation not working - needs setup

4. **CombatComponent** - Critical
   - [ ] Tracks abilities from DNA
   - [ ] Cooldowns decrement properly
   - [ ] `use_ability()` works
   - [ ] Energy cost checked and consumed

5. **JobComponent** - Farm critical
   - [ ] `assign_job()` works
   - [ ] `work_progress` increments
   - [ ] `complete_job()` works
   - [ ] Emits proper signals

6. **NeedsComponent** - Farm critical
   - [ ] All 5 needs initialized
   - [ ] Needs decay over time
   - [ ] Getter/setter methods work

### Phase 2 Deliverables:

**By end of Phase 2:**
- [ ] Can spawn and test 3 different monsters
- [ ] Stats are correctly applied from DNA
- [ ] All components initialize properly
- [ ] No crashes in 10-minute session with 3 monsters spawned
- [ ] Movement works with navigation
- [ ] Abilities are callable from CombatComponent

---

## Phase 3: Combat System (Next After Phase 2)

### Current Status:
- ✅ Ability Executor framework
- ✅ Threat Component complete
- ⚠️ Damage Calculator basic implementation
- ❌ Combat Manager integration incomplete
- ❌ Combat AI not integrated

### Critical Gaps:

#### 3.1 Damage Calculation Fix
**File:** `systems/combat/damage_calculator.gd`

**Current Issues:**
- Uses "base_damage" but abilities use "base_power"
- References `stat_block` but doesn't get stat properly
- No critical hit system
- No elemental damage system
- No armor/defense reduction

**Needs Implementation:**
```gdscript
# Correct formula from spec:
# Final Damage = (BasePower + (Attack * 0.1) - (Defense / 2)) * CritMultiplier * ElementalBonus

static func calculate_damage(attacker: Node2D, defender: Node2D, ability: Dictionary) -> float:
    var attacker_stats = attacker.get_meta("stat_block", {})
    var defender_stats = defender.get_meta("stat_block", {})
    
    var base_power = ability.get("base_power", 10.0)
    var attack = attacker_stats.get("attack", 0.0)
    var defense = defender_stats.get("defense", 0.0)
    
    # Base calculation
    var damage = base_power + (attack * 0.1) - (defense / 2.0)
    
    # Apply critical hit
    if roll_critical(attacker):
        damage *= 1.5
    
    # Apply instability bonus (chaotic damage)
    var instability = attacker.get_meta("instability", 0.0)
    if instability > 0:
        damage *= (1.0 + instability * 0.5)
    
    return maxf(1.0, damage)  # Minimum 1 damage
```

#### 3.2 Combat Manager Integration
**File:** `systems/combat/combat_manager.gd`

**Needs:**
1. Connect to EventBus signals
2. Register monsters when spawned
3. Unregister when they die
4. Track active combat state
5. Run combat tick for AI decision-making
6. Broadcast combat events

**Implementation:**
```gdscript
func _ready():
    EventBus.monster_spawned.connect(_on_monster_spawned)
    EventBus.monster_died.connect(_on_monster_died)
    set_process(true)

func _on_monster_spawned(monster):
    register_combatant(monster)
```

#### 3.3 Ability Execution Wiring
**File:** `systems/combat/ability_executor.gd`

**Missing Piece:**
- How do abilities get triggered?
- Who calls `AbilityExecutor.execute()`?
- Answer: CombatComponent or AI

**Needs Implementation:**
```gdscript
# In CombatComponent.use_ability():
if AbilityExecutor.execute(self, ability, target):
    # Success
    ability_used.emit(ability_id, target)
else:
    # Failed
    return false
```

---

## Phase 3 After Combat:

### 4. Player Control & Input
- SelectionManager (currently scaffolded)
- CommandManager (currently scaffolded)
- Input handler for WASD + abilities

### 5. Farm Automation
- Complete FarmAIComponent job scoring
- Complete NeedsComponent decay
- Complete StressComponent effects

### 6. Raid System
- Implement RaidManager
- Wave management
- Difficulty scaling
- Reward system

---

## How to Verify Progress

### Test Checklist:

**Phase 2 Completion Test:**
```
☐ Can load test_sprigkin.tres
☐ Can assemble without errors
☐ Monster appears in scene
☐ Health bar shows 60 HP
☐ Can move monster with mouse
☐ Animation plays smoothly
```

**Phase 3 Completion Test:**
```
☐ Two monsters in scene
☐ Select one, click other to attack
☐ Damage numbers appear
☐ Health decreases
☐ Abilities on cooldown
☐ Combat log shows actions
```

---

## Common Issues to Watch For

1. **Navigation not working**: Make sure navigation mesh is set up in scene
2. **Components not initializing**: Check `_ready()` is being called
3. **Stat values zero**: Check `stat_block` is being set properly by assembler
4. **Abilities not triggering**: Check CombatComponent is wired to AbilityExecutor

---

## File Structure Reference

**Critical Assembly Files:**
- `systems/monster_assembler.gd` - Main pipeline
- `data/dna/monster_dna_stack.gd` - Container
- `data/dna/base_dna_resource.gd` - Base class
- `data/validation/dna_validator.gd` - Validator

**Component Files:**
- `entities/monster/components/health_component.gd`
- `entities/monster/components/stamina_component.gd`
- `entities/monster/components/combat_component.gd`
- `entities/monster/components/movement_component.gd`
- `entities/monster/components/job_component.gd`
- `entities/monster/components/needs_component.gd`

**Combat Files:**
- `systems/combat/combat_manager.gd`
- `systems/combat/ability_executor.gd`
- `systems/combat/damage_calculator.gd`
- `systems/combat/threat_component.gd`

---

## Next Steps (Do These in Order)

1. **TODAY:** Verify MonsterAssembler works with test_sprigkin
   - Expected time: 30 minutes
   - Success: Monster spawns, shows correct health

2. **TODAY:** Fix stat application in assembler
   - Expected time: 1 hour
   - Success: Stats match DNA values

3. **TOMORROW:** Implement damage calculation fix
   - Expected time: 1 hour
   - Success: Combat deals correct damage

4. **TOMORROW:** Wire AbilityExecutor to CombatComponent
   - Expected time: 1.5 hours
   - Success: Abilities trigger and deal damage

5. **DAY 3:** Combat Manager integration
   - Expected time: 2 hours
   - Success: 2 monsters can fight autonomously

6. **DAY 3:** Player control & selection
   - Expected time: 2 hours
   - Success: Can select monsters and command them

7. **DAY 4:** Farm automation testing
   - Expected time: 2 hours
   - Success: Monsters work jobs automatically

8. **DAY 5:** Full vertical slice integration test
   - Expected time: Full day
   - Success: Full game loop works

---

## Success Metrics

**Phase 2 Success:**
- 3+ monsters in scene without crash
- Stats correctly initialized
- Components responding to stat values
- Movement and pathfinding working

**Phase 3 Success:**
- Combat executes without crash
- Damage calculated correctly
- Abilities trigger and cooldown
- AI makes decisions

**Full Vertical Slice Success:**
- 30-minute gameplay session
- No crashes
- All systems interact
- Game feels playable

---

**Generated:** December 30, 2025  
**Review:** After Phase 2 completion
