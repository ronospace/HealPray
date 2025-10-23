#!/usr/bin/env python3
"""
Generate HealPray app icon with transitional gradient design
A beautiful icon featuring a heart symbol with healing hands on a gradient background
"""

from PIL import Image, ImageDraw, ImageFont
import math

def create_app_icon(size=1024):
    """Create the app icon with the specified size"""
    # Create a new image with RGBA mode (supports transparency)
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Define theme colors (from app_theme.dart)
    healing_teal = (0, 150, 136)  # #009688
    peaceful_blue = (66, 165, 245)  # #42A5F5
    sunrise_gold = (255, 179, 0)  # #FFB300
    
    # Create gradient background (teal to blue transitional)
    for y in range(size):
        # Calculate gradient ratio
        ratio = y / size
        
        # Interpolate between teal and peaceful blue
        r = int(healing_teal[0] * (1 - ratio) + peaceful_blue[0] * ratio)
        g = int(healing_teal[1] * (1 - ratio) + peaceful_blue[1] * ratio)
        b = int(healing_teal[2] * (1 - ratio) + peaceful_blue[2] * ratio)
        
        draw.line([(0, y), (size, y)], fill=(r, g, b, 255))
    
    # Add subtle radial overlay for depth
    center_x, center_y = size // 2, size // 2
    max_radius = size * 0.7
    
    for x in range(size):
        for y in range(size):
            # Calculate distance from center
            dx = x - center_x
            dy = y - center_y
            distance = math.sqrt(dx * dx + dy * dy)
            
            if distance < max_radius:
                # Create subtle radial gradient overlay
                overlay_alpha = int(30 * (1 - distance / max_radius))
                pixel = img.getpixel((x, y))
                # Brighten center
                new_r = min(255, pixel[0] + overlay_alpha)
                new_g = min(255, pixel[1] + overlay_alpha)
                new_b = min(255, pixel[2] + overlay_alpha)
                img.putpixel((x, y), (new_r, new_g, new_b, 255))
    
    # Draw healing hands symbol (two hands forming a heart/cup shape)
    draw = ImageDraw.Draw(img)
    
    # Scale factor for elements
    scale = size / 1024
    
    # Draw a stylized heart with praying hands silhouette
    # Heart center
    heart_center_x = size // 2
    heart_center_y = int(size * 0.48)
    heart_size = int(size * 0.35)
    
    # Draw white heart with golden glow
    # First draw glow
    glow_color = (*sunrise_gold, 100)
    for i in range(8, 0, -1):
        glow_size = heart_size + (i * 8)
        draw_heart(draw, heart_center_x, heart_center_y, glow_size, glow_color)
    
    # Main heart
    draw_heart(draw, heart_center_x, heart_center_y, heart_size, (255, 255, 255, 255))
    
    # Draw praying hands silhouette in the center
    hands_color = healing_teal
    draw_praying_hands(draw, heart_center_x, heart_center_y, int(heart_size * 0.5), hands_color)
    
    # Add subtle sparkles/stars for spiritual feel
    sparkle_positions = [
        (int(size * 0.25), int(size * 0.25)),
        (int(size * 0.75), int(size * 0.25)),
        (int(size * 0.25), int(size * 0.75)),
        (int(size * 0.75), int(size * 0.75)),
    ]
    
    for x, y in sparkle_positions:
        draw_sparkle(draw, x, y, int(size * 0.04), (255, 255, 255, 200))
    
    return img

def draw_heart(draw, cx, cy, size, color):
    """Draw a heart shape"""
    # Heart using curves - simplified version
    points = []
    
    for angle in range(0, 360, 5):
        rad = math.radians(angle)
        # Parametric heart equation
        x = 16 * math.sin(rad) ** 3
        y = -(13 * math.cos(rad) - 5 * math.cos(2 * rad) - 2 * math.cos(3 * rad) - math.cos(4 * rad))
        
        # Scale and translate
        px = cx + int(x * size / 20)
        py = cy + int(y * size / 20)
        points.append((px, py))
    
    if len(points) > 2:
        draw.polygon(points, fill=color)

def draw_praying_hands(draw, cx, cy, size, color):
    """Draw simplified praying hands silhouette"""
    # Left hand
    left_hand = [
        (cx - int(size * 0.4), cy + int(size * 0.8)),
        (cx - int(size * 0.3), cy - int(size * 0.2)),
        (cx - int(size * 0.1), cy - int(size * 0.5)),
        (cx, cy - int(size * 0.6)),
        (cx - int(size * 0.15), cy + int(size * 0.1)),
    ]
    
    # Right hand
    right_hand = [
        (cx + int(size * 0.4), cy + int(size * 0.8)),
        (cx + int(size * 0.3), cy - int(size * 0.2)),
        (cx + int(size * 0.1), cy - int(size * 0.5)),
        (cx, cy - int(size * 0.6)),
        (cx + int(size * 0.15), cy + int(size * 0.1)),
    ]
    
    # Draw hands
    draw.polygon(left_hand, fill=color)
    draw.polygon(right_hand, fill=color)

def draw_sparkle(draw, cx, cy, size, color):
    """Draw a simple sparkle/star"""
    # Draw a 4-point star
    points = []
    for i in range(8):
        angle = math.radians(i * 45)
        radius = size if i % 2 == 0 else size * 0.4
        x = cx + int(math.cos(angle) * radius)
        y = cy + int(math.sin(angle) * radius)
        points.append((x, y))
    
    if len(points) > 2:
        draw.polygon(points, fill=color)

def generate_icon_sizes(base_icon):
    """Generate all required icon sizes for iOS and Android"""
    # iOS sizes
    ios_sizes = {
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png': 20,
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png': 40,
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png': 60,
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png': 29,
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png': 58,
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png': 87,
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png': 40,
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png': 80,
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png': 120,
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png': 120,
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png': 180,
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png': 76,
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png': 152,
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png': 167,
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png': 1024,
    }
    
    # Android sizes
    android_sizes = {
        'android/app/src/main/res/mipmap-mdpi/ic_launcher.png': 48,
        'android/app/src/main/res/mipmap-hdpi/ic_launcher.png': 72,
        'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png': 96,
        'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png': 144,
        'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png': 192,
    }
    
    all_sizes = {**ios_sizes, **android_sizes}
    
    return all_sizes

def main():
    print("🎨 Generating HealPray app icon...")
    
    # Create base 1024x1024 icon
    print("Creating 1024x1024 base icon...")
    base_icon = create_app_icon(1024)
    
    # Save base icon
    base_icon.save('app_icon_1024.png')
    print("✅ Base icon saved: app_icon_1024.png")
    
    # Generate all required sizes
    print("\n📱 Generating icon sizes for iOS and Android...")
    sizes = generate_icon_sizes(base_icon)
    
    import os
    generated_count = 0
    for filepath, size in sizes.items():
        # Create directory if it doesn't exist
        directory = os.path.dirname(filepath)
        if directory and not os.path.exists(directory):
            os.makedirs(directory, exist_ok=True)
        
        # Resize and save
        resized = base_icon.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(filepath)
        generated_count += 1
        print(f"  ✓ Generated {size}x{size} → {filepath}")
    
    print(f"\n🎉 Successfully generated {generated_count} icon files!")
    print("✨ App icon generation complete!")

if __name__ == '__main__':
    main()
