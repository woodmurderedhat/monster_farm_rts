# Quick Test Guide - Monster Farm RTS

**Last Updated:** January 1, 2026

This guide provides quick instructions for testing the implemented systems.

---

## 🧪 1. Integration Tests

**What:** Validates DNA, Assembly, Components, Stats, Abilities, and AI  
**Location:** `tools/integration_test.gd`

**How to Run:**
1. Open Godot Editor
2. Open `tools/integration_test.gd`
3. Click **File → Run** (or press Ctrl+Shift+X)
4. Check Output panel for test results

**Expected Output:**
```
========================================
MONSTER FARM RTS - INTEGRATION TEST
========================================

TEST 1: DNA Validation System
------------------------------
  ✓ DNA Validation: No blocking errors on valid stack
  ✓ DNA Validation: Detected missing core

TEST 2: Monster Assembly
------------------------
  ✓ Monster Assembly: Successfully created monster
  ✓ Monster Assembly: Stat block attached
  ✓ Monster Assembly: AI config attached
  ✓ Monster Assembly: Abilities attached
  
... (more tests)

========================================
TEST SUMMARY
========================================
Passed: 15
Failed: 0
Total: 15
```

### Headless / CI Run

- Use the shared runner: `godot4.exe --headless --path "monster-farm-gamefiles/monster-farm" --script res://tools/headless_test_runner.gd`
- Exit code `0` on success, `1` when any test fails (failures are echoed after the summary)
- Works without the editor; usable in CI and local PowerShell

---

## 🎮 2. Game World Test (2v2 Combat)

**What:** Tests monster spawning and combat with presets  
**Location:** `scenes/game_world.tscn`

**How to Run:**
1. Open `scenes/game_world.tscn`
2. In Inspector, enable `spawn_test_monsters` checkbox on GameWorld node
3. Press **F5** (Play Scene)
4. Watch monsters spawn and engage in combat

**Expected Behavior:**
- 4 monsters spawn (2 per team)
- Team 0: Sprigkin (DPS) + Barkmaw (Tank)
- Team 1: Serpent (Assassin) + Sporespawn (Support)
- Combat AI should engage automatically
- Damage numbers should appear
- Monsters should use abilities

**What to Check:**
- [ ] All 4 monsters spawn without errors
- [ ] Monsters have correct team assignments
- [ ] Combat AI activates
- [ ] Abilities trigger (watch console)
- [ ] Health decreases when hit
- [ ] No crashes or errors

---

## ⚔️ 3. Dedicated Combat Test Scene

**What:** Isolated 2v2 combat test with detailed logging  
**Location:** `scenes/combat_test.gd`

**How to Run:**
1. Create new scene in Godot
2. Add Node2D as root
3. Attach `scenes/combat_test.gd` script
4. Press **F6** (Play Current Scene)

**Expected Console Output:**
```
=== COMBAT TEST 2v2 ===
Spawning teams...
  Spawned: Sprigkin_Team0 at (200, 300)
  Spawned: Barkmaw_Team0 at (200, 400)
  Spawned: Serpent_Team1 at (600, 300)
  Spawned: Sporespawn_Team1 at (600, 400)
Teams spawned. Combat will begin automatically.

=== COMBAT STARTED ===
Targets assigned. Combat AI engaged.

=== COMBAT ENDED: Team X Victory ===
```

---

## 🧬 4. Monster Preset Validation

**What:** Verify all presets load and validate correctly  
**How:** Use integration test or manual validation

**Manual Validation:**
```gdscript
# In Godot Script panel
var preset := load("res://data/monsters/preset_sprigkin_fire.tres") as MonsterDNAStack
var results := DNAValidator.validate_stack(preset)
for r in results:
    print(r.format())
# Should show no blocking errors
```

**Presets to Test:**
- [ ] `preset_sprigkin_fire.tres` (DPS)
- [ ] `preset_barkmaw_tank.tres` (Tank)
- [ ] `preset_sporespawn_support.tres` (Support)
- [ ] `preset_serpent_assassin.tres` (Assassin)

---

## 💾 5. Save/Load Test

**What:** Test save and load functionality  
**Status:** ⚠️ Needs comprehensive testing

**Manual Test Steps:**
1. Play game_world.tscn
2. Spawn some monsters
3. Call `SaveManager.save_slot(0)` via debugger
4. Check `user://save_slot_0/` folder created
5. Close and reopen
6. Call `SaveManager.load_slot(0)` via debugger
7. Verify monsters restored

**Expected Files:**
- `user://save_slot_0/meta.json`
- `user://save_slot_0/world_state.json`
- `user://save_slot_0/farm_state.json`
- `user://save_slot_0/player_state.json`
- `user://save_slot_0/mod_state.json`

---

## 🏭 6. Farm Automation Test

**What:** Test job system and farm AI  
**Status:** ⚠️ Needs scene setup

**Setup Required:**
1. Create farm scene with zones
2. Spawn monsters with farm context
3. Post jobs to job board
4. Observe monsters claiming jobs

**What to Verify:**
- [ ] Monsters evaluate jobs
- [ ] Job scoring works (needs influence)
- [ ] Monsters path to job location
- [ ] Jobs complete
- [ ] Needs decay over time

---

## 🛡️ 7. Raid System Test

**What:** Test wave-based raid  
**Status:** ❌ Not yet implemented (wave system pending)

**Blocked By:**
- Wave progression logic
- Enemy spawning from raid data
- Reward distribution

---

## 🐛 Common Issues & Fixes

### Issue: "Monster spawns but components missing"
**Fix:** Check monster_base.tscn has all component nodes

### Issue: "Abilities don't trigger"
**Fix:** Verify CombatComponent has abilities metadata

### Issue: "Combat AI not engaging"
**Fix:** Check combat_state is set to ENGAGE and target assigned

### Issue: "Validation errors on preset"
**Fix:** Check all DNA resources paths are correct

### Issue: "Integration test fails"
**Fix:** Check console for specific error, verify DNA resources exist

---

## 📊 Performance Profiling

**When:** After basic functionality confirmed  
**How:** 
1. Enable profiler in Godot (Debug → Start Profiling)
2. Spawn 20 monsters
3. Let combat run for 60 seconds
4. Check CPU/memory usage

**Targets:**
- Combat tick should be < 1ms per monster
- Total frame time < 16ms (60 FPS)
- Memory should stay stable

---

## ✅ Test Checklist (Vertical Slice)

### Critical Path
- [ ] Integration tests pass
- [ ] Game world spawns 2v2 without crashes
- [ ] Combat occurs and monsters die
- [ ] Abilities trigger and have visual feedback
- [ ] 30-minute session without crash

### Secondary
- [ ] Save/load cycle works
- [ ] Farm automation assigns jobs
- [ ] Selection/commands work with mouse
- [ ] UI displays monster stats

### Nice to Have
- [ ] Raid waves work
- [ ] Multiple zones load
- [ ] Editor tools validate DNA

---

## 🎯 Next Testing Priorities

1. **Run integration test** - 5 minutes
2. **Test game_world.tscn** - 10 minutes
3. **Verify combat logic** - 15 minutes
4. **Test save/load** - 10 minutes
5. **Farm automation** - 20 minutes

**Total Testing Time:** ~1 hour for core validation

---

## 📝 Reporting Issues

When you find a bug:

1. **Check console** for errors/warnings
2. **Note the context** (what were you doing?)
3. **Record steps** to reproduce
4. **Check if it blocks** vertical slice

**Log Issues In:**
- Create GitHub issue, OR
- Add to `tasklist.md` Known Issues section

---

**Happy Testing! 🚀**

Report issues or questions in the project Discord/GitHub.
