# Monster DNA Farm RTS – Comprehensive Task List

**Project Status:** Early Implementation Phase
**Last Updated:** December 30, 2025
**Priority:** Complete vertical slice to prove all systems work together

---

## Overview

This tasklist tracks all work needed to complete the Monster DNA Farm RTS. Tasks are organized by system and priority. The goal is to implement and fix all aspects of the game following the technical architecture and design documents.

### Current Status Summary
- ✅ Core framework in place (EventBus, GameState, MonsterAssembler)
- ✅ Monster component architecture defined
- ✅ Data structures for DNA system created
- ⚠️ Many systems are scaffolded but incomplete
- ❌ Combat system needs core implementation
- ❌ World/zone system incomplete
- ❌ Raid system incomplete
- ❌ Editor tools not yet started
- ❌ Save/load system partial

---

## Phase 1: DNA & Validation System (CRITICAL)

### 1.1 DNA Validation Framework
- [ ] **Complete DNAValidator class** with:
  - [ ] Structural validation (required fields)
  - [ ] Tag conflict detection (incompatible_tags checking)
  - [ ] Slot limit validation (max 1 core, max 3 elements, etc.)
  - [ ] Instability threshold checking
  - [ ] Blocking error vs. warning classification
  - [ ] Test suite for all validation rules
- [ ] **Create ValidationResult class** with:
  - [ ] Error type enum (BLOCKING, WARNING, INFO)
  - [ ] Message templates for each validation type
  - [ ] Automatic logging integration

### 1.2 DNA Resource Classes
- [ ] Verify all DNA resource types are complete:
  - [x] BaseDNAResource (base class)
  - [x] DNACoreResource
  - [x] DNAElementResource
  - [x] DNABehaviorResource
  - [x] DNAAbilityResource
  - [x] DNAMutationResource
  - [x] MonsterDNAStack (container)
- [ ] Add missing methods to MonsterDNAStack:
  - [ ] `get_combined_stat_modifiers()` - properly aggregate all DNA modifiers
  - [ ] `get_all_tags()` - collect all tags from all parts
  - [ ] `get_total_instability()` - sum instability from mutations
  - [ ] `get_visual_layers()` - collect visual modifications in order
  - [ ] `validate()` - call DNAValidator
  - [ ] `get_ai_configuration()` - aggregate AI parameters

### 1.3 DNA Content (Vertical Slice)
- [ ] **Create 3 Monster Cores:**
  - [ ] Sprigkin (fast, small, high agility)
  - [ ] Barkmaw (tank, large, high health)
  - [ ] Sporespawn (support, medium, healing focus)
- [ ] **Create 5 Elemental DNA:**
  - [ ] Fire (damage + speed)
  - [ ] Water (defense + healing)
  - [ ] Bio (growth + fertility)
  - [ ] Void (instability + special effects)
  - [ ] Lightning (speed + threat)
- [ ] **Create 3 Behavior DNA:**
  - [ ] Aggressive (high aggression, high threat generation)
  - [ ] Defensive (high loyalty, support focus)
  - [ ] Neutral (balanced AI)
- [ ] **Create 9 Ability DNA (3 active, 3 passive per behavior category):**
  - [ ] Active abilities with cooldown, targeting, effects
  - [ ] Passive abilities with stat bonuses
  - [ ] Verify ability IDs are unique
- [ ] **Create 4 Mutation DNA:**
  - [ ] Stable mutations (low instability, good effects)
  - [ ] Unstable mutations (high instability, special effects)

---

## Phase 2: Monster Assembly & Runtime (CRITICAL)

### 2.1 MonsterAssembler Completion
- [ ] Verify assembly pipeline follows spec exactly:
  - [x] Load base scene
  - [x] Initialize components
  - [ ] Validate DNA (**must block invalid builds**)
  - [ ] Assemble stats (verify math matches spec)
  - [ ] Configure AI
  - [ ] Assign abilities
  - [ ] Apply visuals
  - [ ] Finalize
- [ ] **Complete stat assembly:**
  - [ ] Base stat assignment from core DNA
  - [ ] Additive modifier application
  - [ ] Multiplicative modifier application
  - [ ] Derived stat calculation (DPS, threat, etc.)
  - [ ] Sanity bounds (no negative stats, no inf values)
- [ ] **Complete ability assignment:**
  - [ ] Load ability resources by ID
  - [ ] Filter by tag requirements
  - [ ] Create ability runtime instances
  - [ ] Set up cooldown tracking
  - [ ] Verify targeting modes are supported
- [ ] **Visual system integration:**
  - [ ] Load base sprite from core
  - [ ] Layer element visual modifications
  - [ ] Apply color shifts from DNA
  - [ ] Apply scale modifications
  - [ ] Test with test_monsters.tres

### 2.2 Monster Base Scene
- [ ] Verify monster_base.tscn has:
  - [x] Root CharacterBody2D with collision
  - [x] Sprite2D node
  - [x] All required components as children
- [ ] Verify component initialization order:
  - [x] HealthComponent
  - [x] StaminaComponent
  - [x] MovementComponent
  - [x] CombatComponent
  - [x] JobComponent
  - [x] NeedsComponent
  - [x] StressComponent
  - [x] ProgressionComponent
  - [ ] VisualComponent (may need creation)
- [ ] Test spawning 10 monsters without crashes

### 2.3 Component System Completion
- [ ] **HealthComponent:**
  - [ ] Verify heal/damage methods work
  - [ ] Test death signal emission
  - [ ] Verify max_health updates from stats
- [ ] **StaminaComponent:**
  - [ ] Test consumption and regeneration
  - [ ] Verify interaction with ability system
- [ ] **MovementComponent:**
  - [ ] Implement navigation using NavigationAgent2D
  - [ ] Test pathfinding
  - [ ] Test arrival detection
  - [ ] Verify collision avoidance
- [ ] **CombatComponent:**
  - [ ] Track active abilities
  - [ ] Manage ability cooldowns
  - [ ] Calculate damage output
  - [ ] Track threat value
- [ ] **JobComponent:**
  - [ ] Work progress tracking
  - [ ] Job completion logic
  - [ ] Work affinity system
- [ ] **NeedsComponent:**
  - [ ] All 5 needs working (hunger, rest, safety, social, purpose)
  - [ ] Decay mechanics
  - [ ] Critical threshold behavior
- [ ] **StressComponent:**
  - [ ] Stress accumulation
  - [ ] Stress degradation
  - [ ] Mood state determination
  - [ ] Behavioral impacts
- [ ] **ProgressionComponent:**
  - [ ] XP tracking
  - [ ] Level up mechanics
  - [ ] Stat growth application

---

## Phase 3: Combat System (HIGH PRIORITY)

### 3.1 Ability System Runtime
- [ ] **Ability Resource Class:**
  - [ ] Create AbilityResource with:
    - [ ] ability_id
    - [ ] display_name
    - [ ] cooldown duration
    - [ ] cast_time
    - [ ] range
    - [ ] targeting_type (self, unit, area, cone, line)
    - [ ] power_scalars (dict of stat -> multiplier)
    - [ ] energy_cost
    - [ ] vfx reference
    - [ ] description
- [ ] **Ability Executor:**
  - [ ] Implement full ability lifecycle:
    - [ ] Request validation (can cast?)
    - [ ] Target selection (get targets based on targeting_type)
    - [ ] Execution (apply effects)
    - [ ] Cooldown application
    - [ ] Signal emission
  - [ ] Implement targeting modes:
    - [ ] Self (caster only)
    - [ ] Unit (single target)
    - [ ] Area (radius around point)
    - [ ] Cone (directional area)
    - [ ] Line (line between two points)
  - [ ] Test all ability types work

### 3.2 Damage Calculation
- [ ] **DamageCalculator system:**
  - [ ] Base damage from ability power_scalars
  - [ ] Stat scaling (strength, intelligence, etc.)
  - [ ] Type effectiveness (elemental damage type system)
  - [ ] Armor/defense reduction
  - [ ] Critical hit chance/damage
  - [ ] Instability damage modifier
  - [ ] Test suite with known values
- [ ] **StatusEffectComponent:**
  - [ ] Stun, slow, burn, poison effects
  - [ ] Duration tracking
  - [ ] Effect removal
  - [ ] Visual feedback

### 3.3 Combat AI System
- [ ] **CombatAIComponent completion:**
  - [ ] Target scoring (threat, health %, distance)
  - [ ] Ability selection (best ability given current state)
  - [ ] Combat state machine:
    - [ ] IDLE (no enemies)
    - [ ] ENGAGE (attacking targets)
    - [ ] HOLD (defend position)
    - [ ] RETREAT (running away)
    - [ ] BERSERK (instability effects)
  - [ ] Decision loop (score targets every 0.5s)
  - [ ] Test AI vs AI combat
- [ ] **ThreatComponent:**
  - [ ] Threat generation from abilities
  - [ ] Threat decay over time
  - [ ] Tank threat generation
  - [ ] Threat-based target selection

### 3.4 Combat Manager
- [ ] **CombatManager system:**
  - [ ] Register/unregister combatants
  - [ ] Maintain active combat list
  - [ ] Run combat ticks
  - [ ] Calculate danger zones
  - [ ] Broadcast combat events
  - [ ] Manage combat state transitions
- [ ] **Test coverage:**
  - [ ] 2v2 combat scenario
  - [ ] Ability execution during combat
  - [ ] Damage calculation and healing
  - [ ] Death and removal from combat

---

## Phase 4: Player Control & Input (HIGH PRIORITY)

### 4.1 Player Control System
- [ ] **Player entity creation:**
  - [ ] Create player.tscn scene
  - [ ] Player controller script
  - [ ] WASD movement
  - [ ] Dodge/roll mechanic
  - [ ] Combat stats (capped damage)
- [ ] **Summoning system:**
  - [ ] Store active summoned monsters
  - [ ] Summon energy cost
  - [ ] Summon limit enforcement
  - [ ] Unsummon mechanic
- [ ] **Ability casting from player:**
  - [ ] Player has 4-6 active abilities
  - [ ] Ability bar UI binding
  - [ ] Targeting reticule
  - [ ] Cooldown display

### 4.2 Selection & Command System
- [ ] **SelectionManager:**
  - [ ] Single-click monster selection
  - [ ] Multi-click selection (Shift+click)
  - [ ] Box selection (drag)
  - [ ] Selection highlighting
  - [ ] Deselection
- [ ] **CommandManager:**
  - [ ] Move command
  - [ ] Attack command
  - [ ] Ability use command
  - [ ] Formation control (grouped behavior)
  - [ ] Command queue

### 4.3 Input Handling
- [ ] **InputHandler system:**
  - [ ] WASD for player movement
  - [ ] Mouse clicks for world interaction
  - [ ] Right-click context menus
  - [ ] Number keys for ability hotkeys
  - [ ] Space for special actions
- [ ] **Camera system:**
  - [ ] Follow player
  - [ ] Zoom in/out (mouse wheel)
  - [ ] Boundary limits
  - [ ] Smooth movement

---

## Phase 5: Farm Automation System (HIGH PRIORITY)

### 5.1 Farm & Zone System
- [ ] **FarmManager completion:**
  - [ ] Zone registration/management
  - [ ] Monster grouping by zone
  - [ ] Zone-based job generation
  - [ ] Farm statistics tracking
  - [ ] Structure integration
- [ ] **Zone System:**
  - [ ] Define farm zones (feeding area, combat training, rest area, etc.)
  - [ ] Zone priorities
  - [ ] Zone-specific jobs
  - [ ] Environmental effects per zone

### 5.2 Job System
- [ ] **JobResource class:**
  - [ ] job_id
  - [ ] display_name
  - [ ] base_priority
  - [ ] required_tags
  - [ ] forbidden_tags
  - [ ] work_type
  - [ ] danger_level
  - [ ] reward_xp
  - [ ] work_duration estimate
- [ ] **JobBoard system:**
  - [ ] Post jobs to board
  - [ ] Track available jobs
  - [ ] Track claimed jobs
  - [ ] Job completion tracking
  - [ ] Job filtering by monster tags
- [ ] **Sample jobs (Vertical Slice):**
  - [ ] Feed the livestock
  - [ ] Patrol perimeter
  - [ ] Train combat
  - [ ] Rest/Sleep
  - [ ] Repair structures
  - [ ] Guard duty

### 5.3 Farm AI System
- [ ] **FarmAIComponent completion:**
  - [ ] Job evaluation loop
  - [ ] Job scoring formula implementation:
    - [ ] Base priority
    - [ ] Need satisfaction (hunger, rest, etc.)
    - [ ] Danger level modifier
    - [ ] Affinity bonus
    - [ ] Work type preference
  - [ ] Lock-in timer (prevent thrashing)
  - [ ] Job abandonment (if danger increases)
  - [ ] Pathfinding to job location
- [ ] **NeedsComponent dynamics:**
  - [ ] Hunger increases with time/work
  - [ ] Rest decreases when working
  - [ ] Social increases near other monsters
  - [ ] Purpose increases when doing preferred work
  - [ ] Stress impacts all needs
  - [ ] Critical needs force job abandonment

### 5.4 Farm UI
- [ ] **Farm Panel UI:**
  - [ ] Active monsters list
  - [ ] Job board display
  - [ ] Building management
  - [ ] Automation stats
  - [ ] Resource indicators
- [ ] **Monster status panel:**
  - [ ] Health, stamina bars
  - [ ] Current job display
  - [ ] Needs visualization
  - [ ] Stress level
  - [ ] AI decision display (debug)

---

## Phase 6: Raid & Defense System (MEDIUM PRIORITY)

### 6.1 Raid System Core
- [ ] **RaidManager system:**
  - [ ] Raid data structure
  - [ ] Wave management
  - [ ] Enemy spawning
  - [ ] Completion detection
  - [ ] Reward distribution
  - [ ] Failure conditions
- [ ] **RaidScene:**
  - [ ] Dedicated raid map
  - [ ] Defense positions
  - [ ] Wave timer
  - [ ] UI showing wave progress
- [ ] **Enemy spawning:**
  - [ ] Load enemy monsters from DNA
  - [ ] Wave composition
  - [ ] Spawn points and timing
  - [ ] Difficulty scaling

### 6.2 Raid Events
- [ ] **Wave progression:**
  - [ ] Wave 1, 2, 3 with increasing difficulty
  - [ ] Boss wave (optional)
  - [ ] Bonuses for speed/no losses
- [ ] **Raid completion:**
  - [ ] Success condition detection
  - [ ] XP rewards
  - [ ] DNA rewards
  - [ ] Resource rewards
- [ ] **Raid failure:**
  - [ ] Partial rewards
  - [ ] Monster death penalties
  - [ ] Farm damage assessment

### 6.3 Sample Raid (Vertical Slice)
- [ ] Design 3-wave raid scenario
- [ ] Balance monster difficulty
- [ ] Rewards scale appropriately

---

## Phase 7: World & Zone System (MEDIUM PRIORITY)

### 7.1 World Structure
- [ ] **WorldManager:**
  - [ ] Zone data management
  - [ ] Zone unlock system
  - [ ] World event triggering
  - [ ] World state persistence
- [ ] **ZoneManager:**
  - [ ] Zone scenes (terrain, spawns, NPCs)
  - [ ] Monster spawning in zones
  - [ ] Zone transitions
  - [ ] Zone-specific rules (weather, biome, etc.)
- [ ] **Biome system:**
  - [ ] Define biome data (visual theme, monster types)
  - [ ] Biome-specific DNA availability
  - [ ] Environmental effects

### 7.2 Sample World (Vertical Slice)
- [ ] Create 2 zones:
  - [ ] Starting zone (grassland)
  - [ ] Mid-tier zone (forest)
- [ ] Populate with appropriate DNA/monsters
- [ ] Add zone transition points
- [ ] Design quests for each zone

### 7.3 Quest System
- [ ] **Quest types:**
  - [ ] Monster hunts (find and defeat)
  - [ ] DNA collection (gather specific DNA)
  - [ ] Defense quests (protect objective)
  - [ ] Exploration quests
- [ ] **Quest tracking:**
  - [ ] Quest log
  - [ ] Objective progress
  - [ ] Rewards
- [ ] **Sample quests (Vertical Slice):**
  - [ ] Hunt Sprigkin (3 kills)
  - [ ] Collect Fire DNA (10 fragments)
  - [ ] Defend farm from raid

---

## Phase 8: World Events System (MEDIUM PRIORITY)

### 8.1 World Event System
- [ ] **WorldEventResource:**
  - [ ] event_id
  - [ ] trigger_conditions
  - [ ] active_event_data
  - [ ] progression_phases
  - [ ] consequences
  - [ ] cleanup
- [ ] **WorldEventManager:**
  - [ ] Event evaluation
  - [ ] Phase progression
  - [ ] Consequence application
  - [ ] Event cleanup
  - [ ] World state updates
- [ ] **Event types:**
  - [ ] Disaster (increases spawn rates)
  - [ ] Blessing (increases resources)
  - [ ] Migration (monster availability changes)
  - [ ] Epidemic (affects farm monsters)

### 8.2 Narrative Integration
- [ ] **NarrativeEventResource:**
  - [ ] Link to world events
  - [ ] Story context
  - [ ] Delivery methods (popup, log, NPC)
- [ ] **NarrativeEventManager:**
  - [ ] Trigger narrative moments
  - [ ] Story progression
  - [ ] Player impact reflection

### 8.3 Sample World Event (Vertical Slice)
- [ ] Create 1 complete world event
- [ ] Design 3-phase progression
- [ ] Narrative tie-in
- [ ] Consequence testing

---

## Phase 9: Save & Load System (CRITICAL)

### 9.1 SaveManager Completion
- [ ] **Save functionality:**
  - [ ] Save to user://save_slot_X/
  - [ ] Write meta.json (version, timestamp, mods)
  - [ ] Write world_state.json
  - [ ] Write farm_state.json
  - [ ] Write player_state.json (monsters, DNA)
  - [ ] Write mod_state.json (if mod_loader present)
  - [ ] Emit EventBus.game_saved signal
- [ ] **Load functionality:**
  - [ ] Load from save slot
  - [ ] Validate version compatibility
  - [ ] Restore GameState
  - [ ] Rebuild world
  - [ ] Restore farm
  - [ ] Restore monsters (via MonsterAssembler)
  - [ ] Emit EventBus.game_loaded signal
- [ ] **Serialization helpers:**
  - [ ] _serialize_any() for Resources
  - [ ] _try_load_resource() for restoration
  - [ ] Handle missing resources gracefully

### 9.2 Data Persistence
- [ ] **Monster persistence:**
  - [ ] Save DNA stack reference (not node)
  - [ ] Restore via assembler on load
  - [ ] Level/XP preservation
  - [ ] Stat overrides (if any)
- [ ] **Farm state:**
  - [ ] Structure positions
  - [ ] Job board state
  - [ ] Automation settings
- [ ] **Player state:**
  - [ ] Owned monsters list
  - [ ] DNA collection
  - [ ] Research progress
  - [ ] Unlocked features

### 9.3 Migration & Versioning
- [ ] Version tracking in saves
- [ ] Migration scripts for schema changes
- [ ] Backward compatibility testing
- [ ] Clear error messages on incompatibility

### 9.4 Save/Load Testing
- [ ] Test save and load cycle
- [ ] Test with 5 monsters on farm
- [ ] Test farm automation state preservation
- [ ] Test multiple save slots
- [ ] Test overwriting existing saves

---

## Phase 10: Editor Tools (MEDIUM PRIORITY)

### 10.1 DNA Validation Tool
- [ ] **EditorPlugin creation:**
  - [ ] Register custom dock
  - [ ] Add "DNA Tools" menu item
- [ ] **DNA Stack Validator Dock:**
  - [ ] Drag-and-drop zone for DNA Resource
  - [ ] Run validation button
  - [ ] Display validation results:
    - [ ] Errors (red, blocking)
    - [ ] Warnings (yellow, advisory)
    - [ ] Info (blue, notices)
  - [ ] Save button to auto-fix warnings
- [ ] **DNA Resource Inspector:**
  - [ ] Custom inspector for DNA types
  - [ ] Collapsible layer view
  - [ ] Tag visualization
  - [ ] Live stat preview
  - [ ] Validation inline feedback

### 10.2 Monster Preview Generator
- [ ] **Preview dock:**
  - [ ] Load MonsterDNAStack
  - [ ] Assemble in EDITOR_PREVIEW context
  - [ ] Display stats in panel
  - [ ] Show ability list
  - [ ] Show visual layers
  - [ ] Refresh button
- [ ] **Visual representation:**
  - [ ] Show sprite with layered visuals
  - [ ] Animation playback
  - [ ] Size/scale visualization

### 10.3 Debug Tools
- [ ] **Combat debug overlay:**
  - [ ] Threat values
  - [ ] AI decision reasons
  - [ ] Damage numbers
  - [ ] Ability cooldowns
  - [ ] Enable/disable toggle
- [ ] **Farm automation inspector:**
  - [ ] Monster needs display
  - [ ] Job assignment reasons
  - [ ] Stress levels
  - [ ] Work affinity scores
- [ ] **World event inspector:**
  - [ ] Active events list
  - [ ] Phase tracking
  - [ ] Consequence log

### 10.4 Batch Tools
- [ ] **Validate all DNA:**
  - [ ] Scan data/dna directory
  - [ ] Report all errors/warnings
  - [ ] Fix mode (auto-correct where possible)
- [ ] **Regenerate previews:**
  - [ ] Cache preview images
  - [ ] Batch process monsters

---

## Phase 11: UI System (MEDIUM PRIORITY)

### 11.1 Main Menu
- [ ] **Main menu scene:**
  - [ ] New game button
  - [ ] Load game button (slot selection)
  - [ ] Settings button
  - [ ] Quit button
  - [ ] Title/branding

### 11.2 HUD (World/Raid)
- [ ] **Ability bar:**
  - [ ] 4-6 ability buttons
  - [ ] Icon, cooldown, hotkey display
  - [ ] Disabled state (no stamina, on cooldown)
  - [ ] Tooltip on hover
- [ ] **Monster status bars:**
  - [ ] Health/max health
  - [ ] Stamina/max stamina
  - [ ] Selected indicator
- [ ] **Combat log:**
  - [ ] Damage numbers
  - [ ] Ability usage
  - [ ] Critical hits
  - [ ] Scrollable history

### 11.3 Farm UI
- [ ] **Farm panel:**
  - [ ] Active monsters
  - [ ] Job board
  - [ ] Building controls
  - [ ] Farm stats
- [ ] **Monster detail panel:**
  - [ ] Stats display
  - [ ] Needs visualization
  - [ ] Current job
  - [ ] Commands

### 11.4 Inventory/DNA UI
- [ ] **DNA collection display:**
  - [ ] Filter by type
  - [ ] Sort options
  - [ ] Preview selected DNA
- [ ] **Monster collection:**
  - [ ] List owned monsters
  - [ ] Compare monsters
  - [ ] Release/delete

### 11.5 Pause Menu
- [ ] **Pause functionality:**
  - [ ] Pause button
  - [ ] Resume/Settings/Quit options
  - [ ] Game state preservation

---

## Phase 12: Content Creation (VERTICAL SLICE)

### 12.1 DNA Resources (Minimum 20 total)
- [x] 3 Monster Cores
- [x] 5 Elements
- [x] 3 Behaviors
- [x] 9 Abilities (ensure variety)
- [x] 4 Mutations

**Checklist:**
- [ ] All resources saved as .tres files
- [ ] All IDs unique and consistent
- [ ] All resources validate successfully
- [ ] Icons/preview data populated

### 12.2 Monster Designs (Minimum 4)
- [ ] **Sprigkin** (starter fast DPS):
  - [ ] Core + Fire element + Aggressive behavior
  - [ ] 2 active abilities, 1 passive
  - [ ] Speed-focused stats
- [ ] **Barkmaw** (tank):
  - [ ] Core + Bio element + Defensive behavior
  - [ ] Tank abilities (taunt, shield)
  - [ ] High health, armor
- [ ] **Sporespawn** (support):
  - [ ] Core + Water element + Neutral behavior
  - [ ] Healing abilities
  - [ ] Buffer abilities
- [ ] **Custom mutation monster**:
  - [ ] Combine multiple DNA parts
  - [ ] Show instability effects
  - [ ] Prove system works end-to-end

### 12.3 Test Data
- [ ] **test_monsters.tres** with:
  - [ ] All 4 designed monsters
  - [ ] Various combinations
  - [ ] Unstable builds (to test handling)

---

## Phase 13: Integration & Testing

### 13.1 End-to-End Flows
- [ ] **Spawn to battle:**
  - [ ] Create monster from DNA
  - [ ] Spawn in world
  - [ ] Select and command
  - [ ] Engage in combat
  - [ ] Die and respawn
- [ ] **Farm operation:**
  - [ ] Spawn monster to farm
  - [ ] Assign jobs
  - [ ] Jobs complete automatically
  - [ ] Needs decrease
  - [ ] Farm produces resources
- [ ] **Raid sequence:**
  - [ ] Initiate raid
  - [ ] Waves spawn
  - [ ] Combat occurs
  - [ ] Raid completes
  - [ ] Rewards granted
- [ ] **Save/load cycle:**
  - [ ] Make progress
  - [ ] Save game
  - [ ] Close game
  - [ ] Load game
  - [ ] Verify state matches

### 13.2 Bug Fixes
- [ ] **Runtime crashes:**
  - [ ] Test with 10+ monsters
  - [ ] Test all combat abilities
  - [ ] Test rapid assembly/despawn
- [ ] **Logic errors:**
  - [ ] Test damage calculations match spec
  - [ ] Test AI decision making
  - [ ] Test job assignment logic
  - [ ] Test need decay rates
- [ ] **UI issues:**
  - [ ] Test all UI panels
  - [ ] Test input responsiveness
  - [ ] Test resolution scaling

### 13.3 Performance Testing
- [ ] Test with 20 monsters simultaneously
- [ ] Test long farm sessions (30+ min)
- [ ] Profile GDScript execution
- [ ] Optimize hot paths if needed

---

## Phase 14: Polish & Documentation

### 14.1 Code Documentation
- [ ] Docstrings for all public methods
- [ ] Design docs for complex systems
- [ ] Inline comments for non-obvious logic
- [ ] API documentation for mod writers

### 14.2 Player Documentation
- [ ] In-game tooltips
- [ ] Help menu
- [ ] Quick start guide
- [ ] Ability descriptions

### 14.3 Modding Documentation
- [ ] DNA resource schema
- [ ] How to create mods
- [ ] Mod validation tool usage
- [ ] API reference for mod hooks

---

## Critical Path (Recommended Order)

1. **Complete DNA Validation** (1-2 days)
2. **Fix MonsterAssembler** (1 day)
3. **Implement Combat System** (2-3 days)
4. **Complete Player Control** (1-2 days)
5. **Implement Farm AI** (2 days)
6. **Complete Raid System** (1-2 days)
7. **Implement Save/Load** (1-2 days)
8. **Create Vertical Slice Content** (1 day)
9. **Build Editor Tools** (2-3 days)
10. **Integration Testing** (1-2 days)

**Total Estimated Time:** 2-3 weeks for full vertical slice completion

---

## Known Issues & Blockers

### Current Blockers
- [ ] Combat ability execution system needs implementation
- [ ] AI decision loop not fully working
- [ ] Farm zone pathfinding incomplete
- [ ] Raid system scaffolding only
- [ ] Save/load missing load functionality
- [ ] No editor tools yet

### Areas Needing Work
- [ ] Damage calculation formula needs testing
- [ ] Visual component system may need creation
- [ ] World/zone system needs implementation
- [ ] Narrative event integration untested

---

## Success Criteria

The vertical slice is complete when:

1. ✅ Monster can be created from DNA without crashes
2. ✅ Combat system works: player controls monsters, AI fights
3. ✅ Farm automation: monsters work jobs, needs decay
4. ✅ Raid system: 3-wave raid completes successfully
5. ✅ Save/load: full session can be persisted and restored
6. ✅ Editor tools: DNA can be validated and previewed
7. ✅ Content: 4 unique monsters playable
8. ✅ No crashes in 30-minute gameplay session
9. ✅ All systems interact without hard-coded glue code

---

## Progress Tracking

Update this section as work progresses:

| Phase | Status | Start Date | End Date | Notes |
|-------|--------|-----------|----------|-------|
| DNA & Validation | ✅ Complete | - | 12/30 | All DNA classes implemented, validators working, test content created |
| Monster Assembly | 🟡 Partial | - | In Progress | Assembler framework complete, stat application needs testing |
| Combat System | 🟡 Partial | - | - | Ability executor exists, threat system done, integration needed |
| Player Control | 🔴 Not Started | - | - | Input system needs implementation |
| Farm Automation | 🟡 Partial | - | - | Job board exists, AI scoring needs completion |
| Raid System | 🔴 Not Started | - | - | RaidManager scaffolded only |
| World & Zones | 🔴 Not Started | - | - | ZoneManager stubbed |
| World Events | 🔴 Not Started | - | - | EventManager structure in place |
| Save/Load | 🟡 Partial | - | - | Save working, load needs completion |
| Editor Tools | 🔴 Not Started | - | - | No tools implemented yet |
| Content Creation | 🟡 Partial | - | - | DNA templates created, need to populate |
| Integration | 🔴 Not Started | - | - | Systems need connection |
| Polish | 🔴 Not Started | - | - |

---

**Last Updated:** December 30, 2025
**Next Review:** After Phase 1 completion
