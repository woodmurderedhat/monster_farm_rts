# Monster DNA Farm RTS – Art Asset Guide

---

## 1. Overview

This document defines the **art requirements, specifications, and integration guidelines** for the Monster DNA Farm RTS game.

**Art Style:** 32×32 pixel art with a vibrant, readable aesthetic suitable for RTS gameplay.

**Core Principle:** Art must support the DNA system. Monster visuals are assembled from modular parts, not pre-drawn complete sprites.

---

## 2. Technical Specifications

### Base Grid
- **Tile Size:** 32×32 pixels
- **Monster Size:** 32×32 base (can extend to 64×64 for large monsters)
- **UI Elements:** Multiples of 8px (8, 16, 32, 64)
- **Color Depth:** 32-bit RGBA (PNG format)

### Palette Guidelines
- **Max colors per sprite:** 16 (excluding transparency)
- **Consistent lighting:** Top-left light source
- **Outline:** 1px dark outline (not pure black, use darkened base color)
- **Anti-aliasing:** Manual pixel AA only, no blur

### File Format
- **Sprites:** PNG with transparency
- **Spritesheets:** Horizontal strips, uniform frame size
- **Naming:** `category_name_variant.png` (e.g., `monster_wolf_fire.png`)

---

## 3. Monster Art System

### 3.1 Modular Monster Assembly

Monsters are NOT drawn as complete sprites. They are assembled from **DNA-driven layers**:

```
Layer Order (bottom to top):
1. Shadow (optional)
2. Body Base (from Core DNA)
3. Body Details/Patterns (from Element DNA)
4. Eyes/Face (from Behavior DNA)
5. Accessories/Mutations (from Mutation DNA)
6. Effects/Auras (from Element DNA)
```

### 3.2 Body Base Sprites (Core DNA)

Each `DNACoreResource` needs a corresponding body sprite set.

| Core Type | Description | Sprite Requirements |
|-----------|-------------|---------------------|
| Wolf | Quadruped, agile | 4-dir walk, idle, attack |
| Golem | Bipedal, heavy | 4-dir walk, idle, attack |
| Serpent | Slither movement | 4-dir slither, idle, strike |
| Swarm | Cluster of small units | Idle, swarm animation |

**File Structure:**
```
assets/sprites/monsters/cores/
  core_wolf/
    idle_down.png
    idle_up.png
    idle_left.png
    idle_right.png
    walk_down.png (4 frames)
    walk_up.png (4 frames)
    ...
```

### 3.3 Element Overlays (Element DNA)

Element overlays add visual flair without replacing the base body.

| Element | Visual Treatment |
|---------|-----------------|
| Fire | Orange/red glow, ember particles |
| Ice | Blue tint, frost crystals on edges |
| Bio | Green veins, organic patterns |
| Electric | Yellow crackling, static particles |
| Shadow | Dark wisps, purple undertones |

**Implementation:** Shader-based tinting + overlay sprites for patterns.

### 3.4 Expression/Face Variants (Behavior DNA)

Behavior affects the monster's "expression" or demeanor.

| Behavior | Visual Cues |
|----------|-------------|
| Aggressive | Angry eyes, bared teeth |
| Defensive | Wary eyes, closed posture |
| Cunning | Sly eyes, alert ears |
| Supportive | Soft eyes, open posture |

### 3.5 Mutation Effects (Mutation DNA)

Mutations add dramatic visual changes.

| Mutation | Visual Effect |
|----------|--------------|
| Gigantism | 1.5x scale, thicker outline |
| Unstable Energy | Glowing cracks, particle leak |
| Weakness | Desaturated colors, smaller |

---

## 4. Animation Requirements

### 4.1 Monster Animations

| Animation | Frames | Loop | Notes |
|-----------|--------|------|-------|
| Idle | 2-4 | Yes | Subtle breathing/movement |
| Walk | 4-6 | Yes | Per direction (4 dirs) |
| Attack | 3-5 | No | Quick, impactful |
| Hurt | 2 | No | Flash or recoil |
| Death | 4-6 | No | Collapse or fade |
| Special | Varies | No | Per ability |

### 4.2 Frame Rate
- **Standard animations:** 8 FPS (0.125s per frame)
- **Fast actions (attack):** 12 FPS (0.083s per frame)
- **Idle:** 4 FPS (0.25s per frame)

---

## 5. UI Art Requirements

### 5.1 HUD Elements
- Health bar frame: 64×8
- Stamina bar frame: 64×8
- Stress indicator: 16×16 icons
- Ability buttons: 32×32
- Selection indicator: 40×40 (ring around monster)

### 5.2 Icons
- DNA part icons: 32×32 (for inventory/UI)
- Job icons: 24×24
- Status effect icons: 16×16
- Resource icons: 16×16

### 5.3 Panels and Frames
- Window frames: 9-slice compatible
- Button states: Normal, Hover, Pressed, Disabled
- Tooltip background: 9-slice

---

## 6. Environment Art

### 6.1 Farm Tileset
- Ground tiles: Grass, dirt, stone, water (32×32 each)
- Autotile support: 47-tile blob format recommended
- Decorations: Flowers, rocks, fences (various sizes)

### 6.2 Structures
- Buildings: 64×64 or 96×96 depending on size
- Construction stages: Foundation, 50%, Complete
- Damage states: Normal, Damaged, Destroyed

### 6.3 World Map Tiles
- Biome tiles: Forest, desert, swamp, mountain
- POI markers: Dungeon entrance, town, resource node

---

## 7. VFX and Particles

### 7.1 Combat Effects
- Hit spark: 16×16, 4 frames
- Elemental impacts: Fire burst, ice shatter, etc.
- Damage numbers: Font or pre-rendered sprites

### 7.2 Ability Effects
- Projectiles: 16×16 or 32×32
- Area effects: Scalable circles/cones
- Buff/debuff auras: Looping animated overlays

---

## 8. Integration with Game Systems

### 8.1 DNA Resource → Sprite Binding

Each DNA resource specifies its visual components via the `visual_modifiers` dictionary:

```gdscript
# In DNACoreResource
visual_modifiers = {
    "sprite_path": "res://assets/sprites/monsters/cores/core_wolf/",
    "base_scale": 1.0,
    "shadow_offset": Vector2(0, 4)
}

# In DNAElementResource
visual_modifiers = {
    "tint_color": Color(1.0, 0.6, 0.2),  # Fire tint
    "overlay_sprite": "res://assets/sprites/overlays/fire_pattern.png",
    "particle_effect": "res://assets/vfx/ember_particles.tscn"
}
```

### 8.2 MonsterAssembler Sprite Loading

The `MonsterAssembler` reads visual modifiers and constructs the sprite stack:

```gdscript
# In monster_assembler.gd
func _apply_visuals(monster: Node2D, dna_stack: MonsterDNAStack) -> void:
    var sprite := monster.get_node("Sprite2D") as Sprite2D

    # Load base body from Core DNA
    var core_path: String = dna_stack.core.visual_modifiers.get("sprite_path", "")
    sprite.texture = load(core_path + "idle_down.png")

    # Apply element tint
    var tint: Color = dna_stack.element.visual_modifiers.get("tint_color", Color.WHITE)
    sprite.modulate = tint

    # Add overlay if specified
    var overlay_path: String = dna_stack.element.visual_modifiers.get("overlay_sprite", "")
    if overlay_path:
        var overlay := Sprite2D.new()
        overlay.texture = load(overlay_path)
        monster.add_child(overlay)
```

### 8.3 Animation Integration

Animations are handled via `AnimatedSprite2D` with SpriteFrames resources:

```
assets/sprites/monsters/cores/core_wolf/
  core_wolf.tres          <- SpriteFrames resource
  idle_down.png
  walk_down.png
  attack_down.png
  ...
```

The `MovementComponent` triggers animation changes:

```gdscript
func _update_animation() -> void:
    var anim_sprite := owner.get_node("AnimatedSprite2D") as AnimatedSprite2D

    if velocity.length() > 0.1:
        anim_sprite.play("walk_" + _get_direction_name())
    else:
        anim_sprite.play("idle_" + _get_direction_name())
```

### 8.4 Selection and Status Indicators

The `SelectionIndicator` child node displays selection state:

```gdscript
# Selection ring appears when monster is selected
selection_indicator.visible = is_selected
selection_indicator.modulate = Color.GREEN  # Or Color.RED for enemies
```

Health/stamina bars are drawn as `TextureProgressBar` nodes above the monster:

```
Monster
├── Sprite2D (or AnimatedSprite2D)
├── SelectionIndicator
└── OverheadUI
    ├── HealthBar (TextureProgressBar)
    └── StaminaBar (TextureProgressBar)
```

---

## 9. Asset File Structure

```
assets/
├── sprites/
│   ├── monsters/
│   │   ├── cores/
│   │   │   ├── core_wolf/
│   │   │   ├── core_golem/
│   │   │   └── core_serpent/
│   │   ├── overlays/
│   │   │   ├── fire_pattern.png
│   │   │   ├── ice_crystals.png
│   │   │   └── bio_veins.png
│   │   └── faces/
│   │       ├── face_aggressive.png
│   │       ├── face_defensive.png
│   │       └── face_cunning.png
│   ├── ui/
│   │   ├── hud/
│   │   ├── icons/
│   │   ├── panels/
│   │   └── buttons/
│   ├── environment/
│   │   ├── farm_tileset.png
│   │   ├── structures/
│   │   └── decorations/
│   └── vfx/
│       ├── combat/
│       ├── abilities/
│       └── particles/
├── fonts/
│   └── pixel_font.tres
└── audio/
    ├── sfx/
    └── music/
```

---

## 10. Art Production Checklist

### Minimum Viable Art (Vertical Slice)

**Monsters (Priority 1):**
- [ ] 1 Core body set (Wolf) - all animations, 4 directions
- [ ] 3 Element overlays (Fire, Ice, Bio)
- [ ] 2 Face variants (Aggressive, Supportive)
- [ ] Selection ring indicator

**UI (Priority 1):**
- [ ] Health bar (frame + fill)
- [ ] Stamina bar (frame + fill)
- [ ] 5 Ability icons (Bite, Fireball, Heal, Shield, Poison)
- [ ] Selection box texture

**Environment (Priority 2):**
- [ ] Basic grass tileset (9 tiles minimum)
- [ ] 1 Structure (Monster Den)
- [ ] Farm zone indicator

**VFX (Priority 2):**
- [ ] Hit spark effect
- [ ] Ability cast flash
- [ ] Death fade effect

### Full Production

**Monsters:**
- [ ] 4 Core body sets (Wolf, Golem, Serpent, Swarm)
- [ ] 5 Element overlays
- [ ] 4 Face variants
- [ ] 3 Mutation effects (Gigantism, Unstable, Weakness)

**UI:**
- [ ] Complete HUD set
- [ ] All ability icons
- [ ] DNA part icons (15+)
- [ ] Job icons (10+)
- [ ] Status effect icons (10+)
- [ ] Window/panel frames

**Environment:**
- [ ] Farm tileset (47-tile autotile)
- [ ] 5 Structure types
- [ ] Decoration set
- [ ] World map tiles

---

## 11. Art Style Reference

### Color Palette Recommendations

| Category | Primary | Secondary | Accent |
|----------|---------|-----------|--------|
| Fire | #FF6B35 | #FFB347 | #FFE066 |
| Ice | #4FC3F7 | #81D4FA | #E1F5FE |
| Bio | #66BB6A | #A5D6A7 | #C8E6C9 |
| Electric | #FFEE58 | #FFF59D | #FFFDE7 |
| Shadow | #7E57C2 | #B39DDB | #1A1A2E |

### Do's and Don'ts

**Do:**
- Use strong silhouettes (readable at small size)
- Keep consistent lighting direction
- Use limited, cohesive palettes
- Add sub-pixel animation for smooth movement

**Don't:**
- Use too many colors (causes visual noise)
- Mix pixel sizes (keep 1:1 pixel ratio)
- Over-detail small sprites
- Use gradients or soft shadows

---

## 12. Exporting from Art Tools

### Aseprite Settings
- Export as PNG
- Trim: Off (maintain consistent frame sizes)
- Split layers: Off (composite final image)
- Scale: 1x (no upscaling)

### Photoshop/GIMP Settings
- Color Mode: RGB, 8-bit
- Export: PNG-24 with transparency
- No interpolation on resize

---

## 13. Summary

The art pipeline is **modular by design** to support the DNA system:

1. **Create base parts** (Core bodies, Element overlays, Face variants)
2. **Define visual_modifiers** in DNA resources pointing to assets
3. **MonsterAssembler** composites sprites at runtime
4. **Animations** are driven by component state changes

This approach allows **exponential content creation** - 4 cores × 5 elements × 4 behaviors = 80 unique monster looks from ~13 art sets.

Start with the minimum viable checklist, then expand as production scales.

