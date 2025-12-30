#!/usr/bin/env python3
"""
Generate placeholder artwork for Monster Farm RTS.
Creates sprite images for monster bodies, elements, and basic effects.
"""

import os
from pathlib import Path
from PIL import Image, ImageDraw

# Color palettes
COLORS = {
    "wolf": {"body": "#8B6F47", "accent": "#D4A574"},
    "golem": {"body": "#6B7280", "accent": "#9CA3AF"},
    "serpent": {"body": "#4F7942", "accent": "#A8D5BA"},
    "swarm": {"body": "#5A4A42", "accent": "#C4A484"},
    "fire": {"body": "#FF6B35", "accent": "#FFD60A"},
    "ice": {"body": "#4A90E2", "accent": "#87CEEB"},
    "electric": {"body": "#FFD60A", "accent": "#FFA500"},
    "bio": {"body": "#00A86B", "accent": "#90EE90"},
    "shadow": {"body": "#2C2C2C", "accent": "#696969"},
}

def create_output_dirs():
    """Create necessary directories for art assets."""
    base = Path("monster-farm-gamefiles/monster-farm/art")
    dirs = [
        base / "monsters" / "bodies",
        base / "monsters" / "overlays",
        base / "monsters" / "mutations",
        base / "ui",
        base / "vfx",
    ]
    for d in dirs:
        d.mkdir(parents=True, exist_ok=True)
    return base

def hex_to_rgb(hex_color):
    """Convert hex color to RGB tuple."""
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def create_monster_body(name, color_key, size=64):
    """Create a simple placeholder monster sprite."""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    body_color = hex_to_rgb(COLORS[color_key]["body"])
    accent_color = hex_to_rgb(COLORS[color_key]["accent"])
    
    center_x, center_y = size // 2, size // 2
    radius = size // 4
    
    # Draw body (circle)
    draw.ellipse(
        [center_x - radius, center_y - radius, center_x + radius, center_y + radius],
        fill=body_color,
        outline=accent_color,
        width=2
    )
    
    # Draw eyes
    eye_y = center_y - radius // 2
    eye_radius = 3
    draw.ellipse([center_x - 8, eye_y - eye_radius, center_x - 2, eye_y + eye_radius], fill="#000000")
    draw.ellipse([center_x + 2, eye_y - eye_radius, center_x + 8, eye_y + eye_radius], fill="#000000")
    
    # Draw mouth
    draw.line([center_x - 6, center_y + 4, center_x + 6, center_y + 4], fill="#000000", width=1)
    
    return img

def create_element_overlay(element_name, color_key, size=64):
    """Create an element overlay sprite with energy effect."""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    accent_color = hex_to_rgb(COLORS[color_key]["accent"])
    
    center_x, center_y = size // 2, size // 2
    
    # Draw element aura (semi-transparent circle)
    aura_radius = size // 3
    alpha_color = (*accent_color, 128)  # 50% transparency
    draw.ellipse(
        [center_x - aura_radius, center_y - aura_radius, center_x + aura_radius, center_y + aura_radius],
        fill=alpha_color,
        outline=(*accent_color, 200),
        width=1
    )
    
    # Draw element symbol (simple shapes)
    if element_name == "fire":
        # Triangle for fire
        draw.polygon([
            (center_x, center_y - 12),
            (center_x - 8, center_y + 8),
            (center_x + 8, center_y + 8)
        ], fill=accent_color)
    elif element_name == "ice":
        # Snowflake pattern
        for angle in range(0, 360, 60):
            import math
            rad = math.radians(angle)
            x2 = center_x + 10 * math.cos(rad)
            y2 = center_y + 10 * math.sin(rad)
            draw.line([(center_x, center_y), (x2, y2)], fill=accent_color, width=1)
    elif element_name == "electric":
        # Lightning bolt
        bolt_points = [
            (center_x, center_y - 10),
            (center_x + 4, center_y - 2),
            (center_x - 2, center_y),
            (center_x + 2, center_y + 8)
        ]
        draw.line(bolt_points, fill=accent_color, width=2)
    elif element_name == "bio":
        # Leaf shape
        draw.ellipse([center_x - 6, center_y - 10, center_x + 6, center_y + 4], fill=accent_color)
    elif element_name == "shadow":
        # Dark swirl
        draw.arc([center_x - 8, center_y - 8, center_x + 8, center_y + 8], 0, 180, fill=accent_color, width=2)
    
    return img

def create_mutation_sprite(mutation_name, size=64):
    """Create mutation visual modifiers."""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    if mutation_name == "gigantism":
        # Draw size indicator (large marker)
        color = (255, 100, 100)
        draw.ellipse([8, 8, size - 8, size - 8], fill=None, outline=color, width=2)
        draw.line([(size // 2, 4), (size // 2, 12)], fill=color, width=2)
        draw.line([(4, size // 2), (12, size // 2)], fill=color, width=2)
    elif mutation_name == "unstable":
        # Draw fracture pattern
        color = (200, 50, 50, 200)
        draw.line([(8, 8), (size - 8, size - 8)], fill=color, width=2)
        draw.line([(size - 8, 8), (8, size - 8)], fill=color, width=2)
        draw.line([(size // 2, 4), (size // 2, size - 4)], fill=color, width=1)
    elif mutation_name == "weakness":
        # Draw down arrow
        color = (100, 100, 255)
        arrow_x, arrow_y = size // 2, size // 2
        draw.polygon([
            (arrow_x, arrow_y - 8),
            (arrow_x - 6, arrow_y),
            (arrow_x - 2, arrow_y),
            (arrow_x - 2, arrow_y + 8),
            (arrow_x + 2, arrow_y + 8),
            (arrow_x + 2, arrow_y),
            (arrow_x + 6, arrow_y)
        ], fill=color)
    
    return img

def main():
    """Generate all placeholder artwork."""
    print("Generating Monster Farm RTS placeholder artwork...")
    
    art_dir = create_output_dirs()
    print(f"✓ Created art directories under {art_dir}")
    
    # Generate monster bodies
    bodies_dir = art_dir / "monsters" / "bodies"
    bodies = [
        ("wolf", "wolf"),         # wolf body uses wolf colors
        ("golem", "golem"),       # golem body uses golem colors
        ("serpent", "serpent"),   # serpent body uses serpent colors
        ("swarm", "swarm"),       # swarm body uses swarm colors
        ("quadruped", "wolf"),    # quadruped type (use wolf colors)
        ("biped", "golem"),       # biped type (use golem colors)
        ("serpentine", "serpent") # serpentine type (use serpent colors)
    ]
    for name, color_key in bodies:
        img = create_monster_body(name, color_key)
        img.save(bodies_dir / f"{name}.png")
        print(f"✓ Generated {name} body sprite")
    
    # Generate element overlays
    overlays_dir = art_dir / "monsters" / "overlays"
    elements = ["fire", "ice", "electric", "bio", "shadow"]
    for element in elements:
        img = create_element_overlay(element, element)
        img.save(overlays_dir / f"element_{element}.png")
        print(f"✓ Generated {element} element overlay")
    
    # Generate mutation sprites
    mutations_dir = art_dir / "monsters" / "mutations"
    mutations = ["gigantism", "unstable", "weakness"]
    for mutation in mutations:
        img = create_mutation_sprite(mutation)
        img.save(mutations_dir / f"{mutation}.png")
        print(f"✓ Generated {mutation} mutation sprite")
    
    # Generate simple UI icons
    ui_dir = art_dir / "ui"
    
    # Health icon (red heart)
    health_img = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(health_img)
    draw.ellipse([4, 6, 12, 14], fill=(255, 0, 0))
    draw.ellipse([12, 6, 20, 14], fill=(255, 0, 0))
    draw.polygon([(4, 14), (12, 20), (20, 14)], fill=(255, 0, 0))
    health_img.save(ui_dir / "health_icon.png")
    print(f"✓ Generated health UI icon")
    
    # Energy icon (yellow star)
    energy_img = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(energy_img)
    star_points = []
    import math
    for i in range(10):
        angle = i * math.pi / 5 - math.pi / 2
        radius = 12 if i % 2 == 0 else 6
        x = 16 + radius * math.cos(angle)
        y = 16 + radius * math.sin(angle)
        star_points.append((x, y))
    draw.polygon(star_points, fill=(255, 255, 0))
    energy_img.save(ui_dir / "energy_icon.png")
    print(f"✓ Generated energy UI icon")
    
    print("\n✨ Artwork generation complete!")
    print(f"Assets saved to: {art_dir}")

if __name__ == "__main__":
    main()
