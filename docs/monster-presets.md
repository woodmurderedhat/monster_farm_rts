# Monster Presets - Quick Reference

This document describes the 4 sample monster presets created for the vertical slice.

---

## Preset 1: Sprigkin Fire (Fast DPS)

**File:** `data/monsters/preset_sprigkin_fire.tres`

**Role:** Damage Dealer (DPS)  
**Playstyle:** Fast, aggressive, hit-and-run

**DNA Composition:**
- **Core:** Sprigkin (small, fast, agile)
- **Element:** Fire (damage + speed boost)
- **Behavior:** Aggressive (high aggression, threat generation)
- **Abilities:**
  - Bite (quick melee attack)
  - Fireball (ranged fire damage)

**Stats Focus:**
- High Speed
- Medium-High Damage
- Low Health
- Low Defense

**Strengths:**
- Excellent burst damage
- Fast movement for hit-and-run
- Good at finishing low-health targets

**Weaknesses:**
- Low survivability
- Vulnerable to CC and focus fire
- Needs support to stay alive

---

## Preset 2: Barkmaw Tank (Defensive)

**File:** `data/monsters/preset_barkmaw_tank.tres`

**Role:** Tank  
**Playstyle:** Frontline, high survivability, draws aggro

**DNA Composition:**
- **Core:** Golem (large, slow, high HP)
- **Element:** Nature (defense + healing synergy)
- **Behavior:** Defensive (high loyalty, support focus)
- **Abilities:**
  - Shield (damage reduction buff)
  - Taunt (forces enemies to attack this monster)
  - Charge (gap closer)

**Stats Focus:**
- Very High Health
- High Defense/Armor
- Low Speed
- Medium Damage

**Strengths:**
- Excellent survivability
- Protects allies via taunt
- Can initiate fights with charge

**Weaknesses:**
- Low mobility
- Limited damage output
- Vulnerable to kiting

---

## Preset 3: Sporespawn Support (Healer)

**File:** `data/monsters/preset_sporespawn_support.tres`

**Role:** Support/Healer  
**Playstyle:** Backline, healing allies, utility

**DNA Composition:**
- **Core:** Sprite (medium size, balanced)
- **Elements:** 
  - Water (healing power)
  - Bio (growth + regeneration)
- **Behavior:** Supportive (low aggression, ally focus)
- **Abilities:**
  - Heal (restore ally HP)
  - Vine Whip (ranged control/damage)

**Stats Focus:**
- Medium Health
- Medium Defense
- Medium Speed
- Low Damage, High Healing

**Strengths:**
- Keeps team alive
- Good sustain in long fights
- Dual elements provide versatility

**Weaknesses:**
- Low damage output
- Priority target for enemies
- Needs protection

---

## Preset 4: Serpent Assassin (Custom/Advanced)

**File:** `data/monsters/preset_serpent_assassin.tres`

**Role:** Assassin/Controller  
**Playstyle:** Sneaky, burst damage, crowd control

**DNA Composition:**
- **Core:** Serpent (medium, cunning)
- **Elements:**
  - Shadow (stealth, crit bonuses)
  - Electric (burst damage, stun)
- **Behavior:** Cunning (tactical, opportunistic)
- **Abilities:**
  - Poison Spit (DoT damage)
  - Stun (hard CC)
  - Zap (electric burst damage)

**Stats Focus:**
- High Damage
- Medium-High Speed
- Medium Health
- Low Defense

**Strengths:**
- High burst damage combo (Stun → Zap → Poison)
- Crowd control for focus fire
- Multi-element versatility

**Weaknesses:**
- Requires tactical play
- Squishy if caught
- Relies on ability combos

---

## Team Compositions

### Balanced 2v2 Teams

**Team Alpha (Aggressive):**
- Sprigkin Fire (DPS)
- Barkmaw Tank (Tank)

**Team Beta (Tactical):**
- Serpent Assassin (Assassin)
- Sporespawn Support (Healer)

### Recommended Test Scenarios

1. **Tank + DPS vs Assassin + Support**  
   Tests: Frontline pressure vs backline protection

2. **2x DPS vs Tank + Support**  
   Tests: Burst damage vs sustain

3. **2x Tank vs 2x DPS**  
   Tests: Survivability vs damage output

---

## Usage in Code

```gdscript
# Load presets
const SPRIGKIN := preload("res://data/monsters/preset_sprigkin_fire.tres")
const BARKMAW := preload("res://data/monsters/preset_barkmaw_tank.tres")
const SPORESPAWN := preload("res://data/monsters/preset_sporespawn_support.tres")
const SERPENT := preload("res://data/monsters/preset_serpent_assassin.tres")

# Spawn a monster
var monster := monster_assembler.assemble_monster(SPRIGKIN, MonsterAssembler.SpawnContext.WORLD)
```

---

## Validation Status

All 4 presets have been validated to ensure:
- ✅ No blocking errors in DNA stack
- ✅ All referenced resources exist
- ✅ Stat modifiers are balanced
- ✅ Ability counts within slot limits
- ✅ Element combinations are valid
- ✅ No tag conflicts

Run `tools/integration_test.gd` to verify assembly.

---

## Notes for Designers

- These presets demonstrate the DNA system's flexibility
- Each preset showcases different element combinations
- Abilities are chosen to create distinct playstyles
- Balance is intentionally asymmetric for interesting gameplay
- Serpent preset shows multi-element power (2 elements)

**Next Steps:**
- Create mutation variants of these presets
- Add visual customization data
- Create narrative descriptions for each
