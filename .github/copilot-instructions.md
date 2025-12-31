# Copilot Instructions for Monster DNA Farm RTS (Godot 4)

## Big Picture

- Project: Godot 4, 2D top-down. Data-driven, modular, moddable.
- Entry scene: scenes/game_world.tscn with controller [monster-farm-gamefiles/monster-farm/scenes/game_world.gd](monster-farm-gamefiles/monster-farm/scenes/game_world.gd).
- Autoloads: `EventBus` for signals [core/globals/event_bus.gd](monster-farm-gamefiles/monster-farm/core/globals/event_bus.gd), `GameState` for global state [core/globals/game_state.gd](monster-farm-gamefiles/monster-farm/core/globals/game_state.gd).
- Systems are decoupled via signals; entities are composed from components, not deep inheritance. See docs: [docs/technical-architecture.md](docs/technical-architecture.md), [docs/core-design-document.md](docs/core-design-document.md).

## Domain Model (DNA → Monster)

- DNA lives under [monster-farm-gamefiles/monster-farm/data/dna](monster-farm-gamefiles/monster-farm/data/dna). All DNA types extend `BaseDNAResource` [data/dna/base_dna_resource.gd](monster-farm-gamefiles/monster-farm/data/dna/base_dna_resource.gd) with `id`, `display_name`, `tags`, `stat_modifiers`, `ai_modifiers`, `visual_modifiers`.
- A monster build is a `MonsterDNAStack` [data/dna/monster_dna_stack.gd](monster-farm-gamefiles/monster-farm/data/dna/monster_dna_stack.gd) with `core`, `elements[]`, `behavior`, `abilities[]`, `mutations[]`, and helpers like `get_combined_stat_modifiers()` and `get_total_instability()`.
- Runtime assembly is handled by `MonsterAssembler` [systems/monster_assembler.gd](monster-farm-gamefiles/monster-farm/systems/monster_assembler.gd). Flow mirrors [docs/monster-assembly-pipeline.md](docs/monster-assembly-pipeline.md): validate → load base scene → components → stats → AI → abilities → visuals → finalize.
  - Assembled data is attached via `set_meta` on the monster: `stat_block`, `ai_config`, `abilities`, `visual_data`, `instability`, `spawn_context`.
  - Abilities are added from DNA (fields like `ability_id`, `display_name`, `cooldown`, `energy_cost`, etc.) and filtered by tag requirements.

## Cross-System Communication

- Use `EventBus` signals instead of direct references. Key signals: `monster_spawned`, `damage_dealt`, `job_posted`, `raid_started`, `player_command`, `game_state_changed`, `game_saved`, `game_loaded`.
- `GameState` owns session-level data (`current_farm`, `owned_monsters`, `dna_collection`) and exposes `change_state()`, `set_paused()` helpers.

## Save/Load

- `SaveManager` [core/save/save_manager.gd](monster-farm-gamefiles/monster-farm/core/save/save_manager.gd) writes to `user://save_slot_X/` with: `meta.json`, `world_state.json`, `farm_state.json`, `player_state.json`, `mod_state.json`. Spec in [docs/save-load-spec.md](docs/save-load-spec.md).
- Persist primitives and Resource references, not Nodes. Helper `_serialize_any()` captures resource class + `resource_path`; `_try_load_resource()` resolves them on load. Save emits `EventBus.game_saved`; load emits `EventBus.game_loaded`.
- If you add new persistent data, extend the per-file dictionaries (world/farm/player/mod) and keep schema versioned via `SAVE_VERSION`.

## UI & Input Pattern

- UI reads state and invokes systems; it does not mutate state directly. Example: `AbilityButton` [ui/ability_button.gd](monster-farm-gamefiles/monster-farm/ui/ability_button.gd) pulls cooldowns from a `CombatComponent` and triggers `use_ability()`.
- Selection/commands are mediated by managers in `GameWorld` (selection, command, combat) and may emit/consume `EventBus` signals.

## Editor Tools & Workflows

- **DNA Tools Plugin**: Enable in Editor → Project Settings → Plugins. Adds docks for DNA validation and monster preview: [addons/dna_tools](monster-farm-gamefiles/monster-farm/addons/dna_tools). Check validations before spawning monsters in-game.
- **Quick Dev Loop**: Open [scenes/game_world.tscn](monster-farm-gamefiles/monster-farm/scenes/game_world.tscn), toggle `@export spawn_test_monsters: bool` in Inspector, and play. This demonstrates `MonsterAssembler` with sample DNA resources.
- **Content Authoring**: Create `.tres` Resource files under `data/dna/...` (cores, elements, abilities, behaviors, mutations). Inspector auto-exposes `@export` fields; no code needed.
- **Debug Visualization**: Runtime debug overlays (AI states, threat, damage calc) are available via the Debug Manager (read-only, zero-cost when disabled). Do not branch game logic on debug state.
- **Editor Testing**: Use `_spawn_test_monsters()` in GameWorld to preview assemblies before adding to content pipelines.

## Conventions You Should Follow

- Composition over inheritance: add components as child nodes to entities; don’t bake logic into base scenes.
- Data-driven everything: hard-coded IDs/paths are discouraged; prefer Resource fields and tags for compatibility checks.
- Use signals for cross-module updates; avoid singletons that reach into other systems’ internals.
- Store runtime-calculated values on nodes using `set_meta` when no dedicated component exists yet.
- Respect spawn contexts (`SpawnContext.WORLD/FARM/RAID/EDITOR_PREVIEW`) to adjust validation strictness and defaults.
- Metadata storage: attach processed data to monster nodes via `set_meta("key", value)` for stat_block, ai_config, abilities, visual_data, instability, spawn_context.

## Project Workflows

- **Running the game**: Open [scenes/game_world.tscn](monster-farm-gamefiles/monster-farm/scenes/game_world.tscn) in Godot 4.5+ and press Play. The entry point is [scenes/main_menu.tscn](monster-farm-gamefiles/monster-farm/scenes/main_menu.tscn) in production.
- **Custom monster generation**: Use `create_custom_monsters.py` (in workspace root) to generate sprite variants and DNA stacks in batch. See file for usage examples.
- **Validation before spawn**: Call `DNAValidator.validate_stack(dna_stack)` and check for blocking errors before passing to `MonsterAssembler`.
- **Content iteration**: Modify `.tres` resource files directly in Godot Inspector. No rebuild required; changes take effect on next load/preview.

## Adding Features (Examples)

- New DNA Ability: create a `DNAAbilityResource` in [data/dna/abilities](monster-farm-gamefiles/monster-farm/data/dna/abilities) with `ability_id`, `display_name`, `cooldown`, `energy_cost`, `ability_range`, `targeting_type`, `scaling_stats`, optional `icon`. The assembler will attach it; UI like `AbilityButton` can render and trigger it.
- New Monster Stat: add to `BaseDNAResource.stat_modifiers` and update stat application in `MonsterAssembler._apply_stats()` and any component that consumes it.
- New Save Field: extend the relevant dictionary in `save_manager.gd` and update load mapping back into `GameState` or the appropriate manager.

## Component Patterns (Examples)

- **Monster Components**: Add as child Node in [entities/monster/components](monster-farm-gamefiles/monster-farm/entities/monster/components). Example: `HealthComponent` stores `current_hp` and `max_hp`, exposes `damage()` method, emits `health_changed` signal. The assembler wires components to stat data via `_initialize_components()`.
- **Manager Pattern**: Extend Node, attach to scene tree in `GameWorld._setup_systems()`. Managers own their domain (e.g., `CombatManager` owns combat rules, `FarmManager` owns jobs/automation). Keep managers stateless where possible—read from `GameState` and components.
- **AI Components**: Keep separate from logic—`CombatAIComponent` reads threat, `FarmAIComponent` reads job board. Both emit signals for selection/movement; the command manager executes.

## What Not To Do

- Don't serialize Nodes or tree state. Rebuild from DNA/resources on load.
- Don't create tight coupling between systems; prefer publishing/consuming `EventBus` signals.
- Don't put game logic into UI nodes; call into managers/components.
- Don't create new managers without understanding signal flow in `GameWorld._setup_systems()`.
- Don't mutate `GameState` directly; use managers and let them emit signals.

## Pointers

- Architecture: [docs/technical-architecture.md](docs/technical-architecture.md)
- Core design: [docs/core-design-document.md](docs/core-design-document.md)
- Monster assembly: [docs/monster-assembly-pipeline.md](docs/monster-assembly-pipeline.md)
- Save/load spec: [docs/save-load-spec.md](docs/save-load-spec.md)
- Debug system: [docs/debug-menu-spec.md](docs/debug-menu-spec.md)
- DNA schema: [docs/dna-resource-schema.md](docs/dna-resource-schema.md)
- Combat & abilities: [docs/combat-and-ability-spec.md](docs/combat-and-ability-spec.md)

If any area is unclear (e.g., export presets, mod loader API, component locations, or automation workflows), tell us what you need and I'll expand these rules.
