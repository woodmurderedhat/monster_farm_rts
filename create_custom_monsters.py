"""
Monster Farm RTS - Modder's Art Pack Generator

This script can be used to generate additional artwork variants
following the same conventions as the base placeholder art.

Usage:
    python create_custom_monsters.py --body wolf --elements fire ice --mutations gigantism
    python create_custom_monsters.py --batch batch_config.yaml
"""

import argparse
from pathlib import Path
from PIL import Image, ImageDraw
import sys

# Color definitions - extend these to add more variants
EXTENDED_COLORS = {
    # Existing monsters
    "wolf": {"body": "#8B6F47", "accent": "#D4A574"},
    "golem": {"body": "#6B7280", "accent": "#9CA3AF"},
    "serpent": {"body": "#4F7942", "accent": "#A8D5BA"},
    "swarm": {"body": "#5A4A42", "accent": "#C4A484"},
    
    # New variants
    "phoenix": {"body": "#FF4500", "accent": "#FFD700"},      # Fire bird
    "wraith": {"body": "#4B0082", "accent": "#9370DB"},        # Purple ghost
    "dragon": {"body": "#8B0000", "accent": "#DC143C"},        # Dark red dragon
    "ent": {"body": "#654321", "accent": "#8B4513"},            # Brown tree creature
    "elemental": {"body": "#E0FFFF", "accent": "#00FFFF"},      # Cyan energy form
    "construct": {"body": "#A9A9A9", "accent": "#D3D3D3"},      # Light gray metal
    "beast": {"body": "#8B4513", "accent": "#A0522D"},          # Brown leather
    "insect": {"body": "#3D3D3D", "accent": "#696969"},         # Chitin dark
}

EXTENDED_ELEMENTS = {
    "fire": {"color": "#FF6B35", "symbol": "flame"},
    "ice": {"color": "#4A90E2", "symbol": "snowflake"},
    "electric": {"color": "#FFD60A", "symbol": "lightning"},
    "bio": {"color": "#00A86B", "symbol": "leaf"},
    "shadow": {"color": "#2C2C2C", "symbol": "swirl"},
    "light": {"color": "#FFFF99", "symbol": "star"},           # New element
    "metal": {"color": "#A8A9AD", "symbol": "gear"},           # New element
    "water": {"color": "#1E90FF", "symbol": "wave"},           # New element
    "wind": {"color": "#D0D0FF", "symbol": "spiral"},          # New element
}

EXTENDED_MUTATIONS = [
    "gigantism",
    "unstable",
    "weakness",
    "crystallize",      # New mutation
    "regenerate",       # New mutation
    "toxic",            # New mutation
    "armor",            # New mutation
]

def hex_to_rgb(hex_color):
    """Convert hex color to RGB tuple."""
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def create_custom_body(name, body_color_hex, accent_color_hex, size=64):
    """Create a custom monster body sprite."""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    body_color = hex_to_rgb(body_color_hex)
    accent_color = hex_to_rgb(accent_color_hex)
    
    center_x, center_y = size // 2, size // 2
    radius = size // 4
    
    # Draw body circle
    draw.ellipse(
        [center_x - radius, center_y - radius, center_x + radius, center_y + radius],
        fill=body_color,
        outline=accent_color,
        width=2
    )
    
    # Draw eyes
    eye_y = center_y - radius // 2
    eye_radius = 3
    draw.ellipse([center_x - 8, eye_y - eye_radius, center_x - 2, eye_y + eye_radius], 
                 fill="#000000")
    draw.ellipse([center_x + 2, eye_y - eye_radius, center_x + 8, eye_y + eye_radius], 
                 fill="#000000")
    
    # Draw mouth
    draw.line([center_x - 6, center_y + 4, center_x + 6, center_y + 4], 
              fill="#000000", width=1)
    
    return img

def create_custom_element(name, element_color_hex, size=64):
    """Create a custom element overlay."""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    color = hex_to_rgb(element_color_hex)
    center_x, center_y = size // 2, size // 2
    
    # Draw aura
    aura_radius = size // 3
    alpha_color = (*color, 128)
    draw.ellipse(
        [center_x - aura_radius, center_y - aura_radius, 
         center_x + aura_radius, center_y + aura_radius],
        fill=alpha_color,
        outline=(*color, 200),
        width=1
    )
    
    # Draw element-specific symbol
    if name == "light":
        # Star pattern
        import math
        star_points = []
        for i in range(10):
            angle = i * math.pi / 5 - math.pi / 2
            radius = 12 if i % 2 == 0 else 6
            x = center_x + radius * math.cos(angle)
            y = center_y + radius * math.sin(angle)
            star_points.append((x, y))
        draw.polygon(star_points, fill=color)
    elif name == "metal":
        # Gear shape (simplified)
        draw.ellipse([center_x - 8, center_y - 8, center_x + 8, center_y + 8],
                    fill=None, outline=color, width=2)
        for angle in range(0, 360, 90):
            import math
            rad = math.radians(angle)
            x = center_x + 10 * math.cos(rad)
            y = center_y + 10 * math.sin(rad)
            draw.rectangle([x-2, y-2, x+2, y+2], fill=color)
    elif name == "water":
        # Wave pattern
        draw.line([(center_x - 10, center_y), 
                  (center_x - 5, center_y - 3),
                  (center_x, center_y),
                  (center_x + 5, center_y - 3),
                  (center_x + 10, center_y)],
                fill=color, width=2)
    elif name == "wind":
        # Spiral
        import math
        points = []
        for i in range(20):
            angle = i * math.pi / 10
            radius = i * 0.5
            x = center_x + radius * math.cos(angle)
            y = center_y + radius * math.sin(angle)
            points.append((x, y))
        if len(points) > 1:
            draw.line(points, fill=color, width=1)
    
    return img

def main():
    parser = argparse.ArgumentParser(
        description="Generate custom monster artwork for Monster Farm RTS"
    )
    parser.add_argument("--body", type=str, help="Create custom body sprite")
    parser.add_argument("--color", type=str, help="Body color (hex, e.g. #FF0000)")
    parser.add_argument("--accent", type=str, help="Accent color (hex)")
    parser.add_argument("--element", type=str, help="Create custom element overlay")
    parser.add_argument("--mutation", type=str, help="Create custom mutation sprite")
    parser.add_argument("--list-colors", action="store_true", help="List available colors")
    parser.add_argument("--list-elements", action="store_true", help="List available elements")
    parser.add_argument("--output-dir", type=str, default="monster-farm-gamefiles/monster-farm/art",
                       help="Output directory for sprites")
    
    args = parser.parse_args()
    
    if args.list_colors:
        print("\nAvailable color schemes:")
        for name, colors in EXTENDED_COLORS.items():
            print(f"  {name}: body={colors['body']} accent={colors['accent']}")
        return
    
    if args.list_elements:
        print("\nAvailable elements:")
        for name, config in EXTENDED_ELEMENTS.items():
            print(f"  {name}: {config['color']}")
        return
    
    output_base = Path(args.output_dir)
    
    if args.body and args.color and args.accent:
        bodies_dir = output_base / "monsters" / "bodies"
        bodies_dir.mkdir(parents=True, exist_ok=True)
        
        img = create_custom_body(args.body, args.color, args.accent)
        output_path = bodies_dir / f"{args.body}.png"
        img.save(output_path)
        print(f"✓ Created {args.body} body sprite at {output_path}")
    
    if args.element:
        if args.element not in EXTENDED_ELEMENTS:
            print(f"✗ Unknown element: {args.element}")
            print(f"  Available: {', '.join(EXTENDED_ELEMENTS.keys())}")
            return
        
        overlays_dir = output_base / "monsters" / "overlays"
        overlays_dir.mkdir(parents=True, exist_ok=True)
        
        element_config = EXTENDED_ELEMENTS[args.element]
        img = create_custom_element(args.element, element_config["color"])
        output_path = overlays_dir / f"element_{args.element}.png"
        img.save(output_path)
        print(f"✓ Created {args.element} element overlay at {output_path}")
    
    if args.mutation:
        mutations_dir = output_base / "monsters" / "mutations"
        mutations_dir.mkdir(parents=True, exist_ok=True)
        
        # Simple mutation sprite (placeholder)
        img = Image.new('RGBA', (64, 64), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        
        # Different mutations have different symbols
        if args.mutation == "crystallize":
            draw.polygon([(32, 16), (48, 32), (32, 48), (16, 32)], fill=(100, 150, 255))
        elif args.mutation == "regenerate":
            draw.arc([16, 16, 48, 48], 0, 180, fill=(0, 255, 0), width=2)
            draw.line([(32, 8), (32, 18)], fill=(0, 255, 0), width=2)
        elif args.mutation == "toxic":
            draw.ellipse([16, 16, 48, 48], fill=None, outline=(128, 255, 0), width=2)
            draw.line([(16, 32), (48, 32)], fill=(128, 255, 0), width=1)
            draw.line([(32, 16), (32, 48)], fill=(128, 255, 0), width=1)
        elif args.mutation == "armor":
            draw.rectangle([20, 20, 44, 44], fill=None, outline=(192, 192, 192), width=2)
            draw.rectangle([24, 24, 40, 40], fill=None, outline=(192, 192, 192), width=1)
        else:
            # Generic mutation symbol
            draw.polygon([(32, 10), (50, 30), (40, 50), (24, 50), (14, 30)],
                        fill=(200, 100, 100))
        
        output_path = mutations_dir / f"{args.mutation}.png"
        img.save(output_path)
        print(f"✓ Created {args.mutation} mutation sprite at {output_path}")

if __name__ == "__main__":
    main()
