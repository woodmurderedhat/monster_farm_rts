# Monster Component Contract

This document describes the expected node/component layout and required meta keys for monster base scenes so they are compatible with `MonsterAssembler` and other systems.

Required child nodes (names are case-sensitive):
- `HealthComponent` (Node) — must accept `set_meta("max_health", value)` and `set_meta("current_health", value)` or expose `max_health`/`current_health` properties.
- `CombatComponent` (Node) — must expose methods used by `AbilityButton` and combat manager, e.g., `use_ability(ability_id, target)` and `get_cooldown_remaining(ability_id)`.
- `AIController` (Node, optional) — if present, should implement `configure_ai(ai_config: Dictionary)` to receive assembled AI config.
- `Sprite`/`AnimatedSprite2D` — for visuals; assembler will set `monster.scale` based on DNA visual modifiers.

Required meta keys (set by `MonsterAssembler`):
- `dna_stack`: the `MonsterDNAStack` Resource used to assemble this monster.
- `stat_block`: Dictionary of calculated stats (max_health, max_stamina, speed, size, mass, etc.).
- `ai_config`: Dictionary of AI parameters (aggression, loyalty, work_affinity, etc.).
- `abilities`: Array of ability dictionaries with keys like `id`, `enabled`, `cooldown`, `energy_cost`.
- `visual_data`: Dictionary of visual modifiers applied.
- `instability`: Float between 0.0 and 1.0 representing mutation instability.
- `spawn_context`: Enum value of `SpawnContext` indicating where monster was spawned.

Recommendations for authors creating compatible monster scenes:
- Implement defensive `get_node_or_null("HealthComponent")` usage when reading health meta keys.
- Provide `configure_ai(ai_config)` on an AI node to centralize AI setup.
- Read `abilities` from `get_meta("abilities")` rather than expecting exported ability lists on the scene.
- Avoid hardcoding team or runtime-only values in the base scene; those are set by the world manager at spawn.

If a scene deviates from this contract, `MonsterAssembler` may fail to apply stats/AI/abilities; ensure compatibility by matching node names and providing the methods listed above.
