# Slice Plan: World Building via Tilemap Layers (RTS/Farm/TD)

## Objectives (Next 1-2 slices)
- Establish tilemap layer contract for terrain, buildables, navigation, and hazards that works headless and deterministically.
- Prove RTS loop: resource nodes, worker routing, build queues, and obstruction-aware placement.
- Prove farm sim loop: soil states, crop growth ticks, irrigation, and spoilage.
- Prove tower defense loop: lane definition, wave spawns, pathing on layered nav, and tower targeting priorities.

## Tilemap Layering Plan
- Base terrain: height/biome tiles, movement cost, harvestable flags.
- Blocking/buildable: structures, walls, fences; placement validation uses occupancy + clearance mask.
- Navigation: precomputed flow fields per layer (ground/air) with deterministic reseed when tiles change.
- Hazards/effects: traps, slow/poison tiles; duration tracked per cell.
- Farming: soil moisture/fertility per cell; irrigation channels as a separate layer feeding adjacency rules.
- Decoration (non-blocking, optional): cosmetic only, ignored in headless sim.

## RTS Core (proof targets)
- Resource system: mineable nodes with finite yield; drop-off buildings; deterministic gather/return timing.
- Build system: queue + progress ticks; obstruction check uses buildable layer; refunds on cancel.
- Unit control: command buffers; move/stop/harvest/build orders validated against nav layer snapshots.

## Farm Simulation (proof targets)
- Crop lifecycle: seeded -> growing stages -> harvest -> spoil; growth ticked by simulation clock.
- Soil states: moisture and fertility curves; irrigation layer replenishes moisture along channels.
- Field tasks: plow/seed/water/harvest jobs generated from tile states; assignable to workers.

## Tower Defense (proof targets)
- Lane definition: path sets baked from nav layer; supports dynamic re-bake when walls placed.
- Waves: scripted resource defining composition, timing, lanes; reproducible via seed.
- Towers: placement uses buildable layer; targeting priorities (closest-to-exit, highest-HP, fastest).
- Projectiles/auras: deterministic damage ticks; slow/DoT apply to hazard layer when applicable.

## Cross-Cutting Systems
- Deterministic tick scheduler driving RTS/farm/TD subsystems.
- Headless scene entry for tests: minimal scene that loads tilemap layers, seeds resources, runs scripted steps.
- Debuggability: expose layer snapshots (arrays) for assertions instead of relying on prints.

## Immediate Next Actions
1) Define tilemap layer schema (resources) with per-cell data contracts for terrain, buildable, nav, hazard, farming.
2) Create headless test scene that loads layered tilemap, seeds sample map, and runs 500 ticks asserting nav + placement.
3) Implement placement validator service (buildable layer + clearance mask + nav re-bake trigger).
4) Add resource node + worker harvest prototype with deterministic timings and drop-off.
5) Add farming tick: soil moisture/fertility update + crop growth stages; simple irrigation channel fill.
6) Add TD lane + wave prototype: bake lanes from nav layer, spawn wave, tower targeting and damage tick.
7) Wire into integration_test_suite.gd to run above scenarios in CI.

## Notes
- Avoid editor-only dependencies; all scenes/resources must run under godot --headless.
- Keep configs in resources for CI-friendly diffs; prefer text scenes and explicit seeds.
- Expose state for assertions; avoid print-based debugging.
