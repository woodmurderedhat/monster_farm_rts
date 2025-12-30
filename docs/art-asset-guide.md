
# Godot 4 Monster DNA Farm RTS – Art Design Document

---

## 1. Purpose

This document defines how **artwork is created, structured, implemented, and scaled** for the game.

Goals:

* Support **infinite monster customization** without infinite art costs
* Ensure art is modular, data-driven, and moddable
* Maintain visual clarity in RTS-scale combat
* Integrate tightly with the DNA system and Godot 4 pipeline

Art is treated as a  **system** , not static assets.

---

## 2. Core Art Pillars

### 2.1 Readability First

* Monsters must be readable at a glance
* Silhouettes > detail
* Color communicates role, element, and threat

### 2.2 Modular Construction

* Monsters are  *assembled* , not drawn whole
* Reuse parts across DNA combinations

### 2.3 Stylized, Not Realistic

* Timeless visuals
* Lower asset burden
* Supports exaggeration and mutation

---

## 3. Art Style Overview

### Camera & Perspective

* 2D top-down or 2.5D
* Slight angle for depth

### Line & Shape Language

* Bold outlines
* Clear negative space
* Chunky proportions

### Color Philosophy

* Elements drive color accents
* Neutral bases + vibrant overlays

---

## 4. Monster Visual System (DNA-Driven)

### 4.1 Monster Visual Layers

Monsters are built from stacked layers:

1. **Base Body** (from DNACore)
2. **Elemental Overlays** (DNAElement)
3. **Mutation Parts** (DNAMutation)
4. **Status Effects** (runtime only)

Each layer is independent.

---

### 4.2 Base Body Sets

Each body type includes:

* Idle animation
* Walk/run animation
* Attack pose
* Hit reaction
* Death

Body types:

* Biped
* Quadruped
* Serpentine
* Swarm

---

### 4.3 Elemental Overlays

Element overlays add:

* Color gradients
* Glow effects
* Particles (sparks, flames, frost)

Overlays are:

* Additive
* Tintable
* Stackable

---

### 4.4 Mutations & Extremities

Mutations can:

* Add horns, wings, tails
* Distort proportions
* Override animations

Mutations may intentionally break silhouettes.

---

## 5. Animation Strategy

### 5.1 Modular Animation

* Base animations reused
* Additive animation layers

### 5.2 Frame Budget

* 8–12 frames per animation
* Emphasis on timing, not smoothness

### 5.3 Directional Facing

* 4-direction minimum
* 8-direction optional later

---

## 6. Combat & Ability VFX

### Principles

* Abilities must read faster than animations
* VFX > sprite detail

### VFX Components

* Telegraphs (AoE indicators)
* Impact flashes
* Persistent fields

VFX driven by Ability Resources.

---

## 7. Farm & World Art

### Farm Tiles

* Grid-aligned
* Clear functional zones
* Color-coded utility

### Structures

* Simple silhouettes
* Iconic shapes
* Upgrade visual stages

---

## 8. UI Art Direction

### Style

* Flat, minimal UI
* Strong iconography

### Icons

* DNA icons per type
* Ability icons use shape language
* Status icons consistent color rules

---

## 9. Godot 4 Implementation

### Scene Structure

```
MonsterVisual (Node2D)
 ├─ BodySprite
 ├─ OverlaySprites
 ├─ MutationSprites
 └─ EffectLayer
```

### Shader Use

* Color swap shaders
* Glow outlines
* Damage flashes

No per-monster textures.

---

## 10. Asset Organization

```
res://art/
  monsters/
    bodies/
    overlays/
    mutations/
  vfx/
  ui/
  tiles/
```

Strict naming conventions enforced.

---

## 11. Modding Support

Mods can:

* Add new body parts
* Add overlays
* Add mutation visuals

Mods never replace core assets.

---

## 12. Performance Constraints

* Sprite atlases mandatory
* Texture reuse prioritized
* VFX capped per scene

Supports large battles.

---

## 13. Production Pipeline

### Tools

* Aseprite / Krita (sprites)
* Spine (optional)
* Godot 4 importer

### Automation

* Atlas generation
* Validation of layer alignment

---

## 14. Art Scope for Vertical Slice

### Required Assets

* 2 body types
* 2 elements
* 5 mutations
* Basic VFX set

---

## 15. Common Failure Points (Avoid)

* Unique monsters per DNA combo
* Over-detailed sprites
* Hardcoded visuals

---

## 16. Summary

This art system:

* Scales infinitely with finite assets
* Is tightly integrated with DNA
* Is mod-friendly
* Maintains clarity under RTS pressure

Art becomes a  **procedural system** , not a bottleneck.
