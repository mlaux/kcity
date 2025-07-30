#!/usr/bin/env python3
"""
Enhanced font generator for SNES KCity project.
Supports both 8x8 and 8x16 fonts with automatic character width calculation.
"""

import subprocess
import argparse
import os
import sys
import re

def get_font_metrics(font_family, point_size):
    """Get font metrics including ascent and descent for baseline alignment."""
    try:
        # Use a reference character to get font metrics
        cmd = [
            'magick', '-debug', 'annotate', 'xc:', 
            '-pointsize', str(point_size),
            '-font', font_family,
            '-annotate', '0', 'A', 'null:'
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        output_text = result.stderr + result.stdout
        
        for line in output_text.split('\n'):
            if 'Metrics:' in line:
                # Extract ascent and descent using regex
                ascent_match = re.search(r'ascent:\s*(-?\d+(?:\.\d+)?)', line)
                descent_match = re.search(r'descent:\s*(-?\d+(?:\.\d+)?)', line)
                
                if ascent_match and descent_match:
                    ascent = float(ascent_match.group(1))
                    descent = float(descent_match.group(1))
                    return int(round(ascent)), int(round(descent))
        
        print(f"Warning: Could not determine ascent/descent for font {font_family}, using defaults")
        return 12, -3  # default ascent, descent
        
    except Exception as e:
        print(f"Warning: Could not get font metrics: {e}")
        return 12, -3

def calculate_char_width_metrics(font_family, point_size, char, max_width=8):
    """Calculate character width using ImageMagick's text metrics."""
    try:
        # Handle special characters
        if char == ' ':
            return 3  # Default space width
        elif char == '\\':
            char = '\\\\'
        
        # Run ImageMagick with debug output to get metrics
        cmd = [
            'magick', '-debug', 'annotate', 'xc:', 
            '-pointsize', str(point_size),
            '-font', font_family,
            '-annotate', '0', char, 'null:'
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        # Parse the metrics output (ImageMagick debug output goes to stderr)
        output_text = result.stderr + result.stdout
        for line in output_text.split('\n'):
            if 'Metrics:' in line:
                # Extract width using regex
                width_match = re.search(r'width:\s*(\d+(?:\.\d+)?)', line)
                if width_match:
                    width = float(width_match.group(1))
                    # Round and clamp to max_width
                    return max(1, min(int(round(width)), max_width))
        
        # Fallback if no metrics found
        print(f"Warning: No metrics found for character '{char}', using default width")
        return 4
        
    except Exception as e:
        print(f"Warning: Could not calculate width for '{char}': {e}")
        return 4

def generate_character_images(font_family, point_size, height, output_prefix="ch"):
    """Generate individual character images with proper baseline alignment."""
    print(f"Generating {len(range(32, 128))} character images...")
    
    # Get font metrics for baseline alignment
    ascent, descent = get_font_metrics(font_family, point_size)
    print(f"Font metrics: ascent={ascent}, descent={descent}")
    
    # Calculate vertical position to center the font properly within the target height
    # Total font height = ascent - descent (descent is negative)
    font_height = ascent - descent
    # Position baseline so descenders fit within the target height
    baseline_y = ascent + max(0, (height - font_height) // 2) - 2
    
    for ch in range(32, 128):
        char = chr(ch)
        output_file = f"{output_prefix}{ch:03d}.png"
        
        if ch == ord(' '):
            # Generate white space character
            subprocess.run([
                'magick', '-size', f'8x{height}', 'xc:white', output_file
            ], check=True)
            continue
        elif ch == ord('\\'):
            char = '\\\\'
        
        # Generate character image with proper baseline alignment
        cmd = [
            "magick",
            "-size", f"8x{height}",
            "xc:white",
            "-font", font_family,
            "-pointsize", str(point_size),
            "-fill", "black",
            "-annotate", f"+0+{baseline_y}",
            char,
            # Convert to 4-color indexed PNG (black, white, 2 grays for antialiasing)
            "-colors", "4",
            f"png8:{output_file}",
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
        except subprocess.CalledProcessError as e:
            print(f"Error generating character {ch} ({char}): {e}")
            # Create a fallback blank image
            subprocess.run([
                'magick', '-size', f'8x{height}', 'xc:white', output_file
            ], check=True)

def generate_font_sheet(height, output_name="geneva.png", input_prefix="ch"):
    """Generate the font sheet by montaging individual character images."""
    print(f"Creating font sheet: {output_name}")
    
    import glob
    from PIL import Image
    
    # Get all character files and sort them
    char_files = sorted(glob.glob(f"{input_prefix}*.png"))
    
    if height == 8:
        # Standard 8x8 font - use montage as before
        cmd = [
            "montage"
        ] + char_files + [
            "+set", "label",
            "-tile", "16x", 
            "-geometry", f"8x{height}+0+0", 
            output_name
        ]
        subprocess.run(cmd, check=True)
        
        # Convert final sheet to 4-color indexed
        cmd = [
            "magick", output_name,
            "-colors", "4",
            f"png8:{output_name}",
        ]
        subprocess.run(cmd, check=True)
    else:
        # 8x16 font - need to split each character and arrange as top,bottom,top,bottom...
        print("Arranging 8x16 characters as sequential top/bottom halves...")
        
        # Create list to hold all half-tiles
        half_tiles = []
        
        for char_file in char_files:
            img = Image.open(char_file)
            if img.size != (8, 16):
                print(f"Warning: {char_file} is not 8x16, skipping")
                continue
                
            # Split into top and bottom halves
            top_half = img.crop((0, 0, 8, 8))    # Top 8 pixels
            bottom_half = img.crop((0, 8, 8, 16)) # Bottom 8 pixels
            
            half_tiles.append(top_half)
            half_tiles.append(bottom_half)
        
        # Calculate grid dimensions for the half-tiles
        # We have 96 characters * 2 halves = 192 tiles
        # Arrange as 16 tiles per row
        tiles_per_row = 16
        num_rows = (len(half_tiles) + tiles_per_row - 1) // tiles_per_row
        
        # Create the final image
        final_width = tiles_per_row * 8
        final_height = num_rows * 8
        final_img = Image.new('RGB', (final_width, final_height), 'white')
        
        # Place each half-tile
        for i, tile in enumerate(half_tiles):
            row = i // tiles_per_row
            col = i % tiles_per_row
            x = col * 8
            y = row * 8
            final_img.paste(tile, (x, y))
        
        # Convert final image to 4-color indexed and save
        final_img.save(output_name)
        
        # Use ImageMagick to convert the final sheet to 4-color indexed
        cmd = [
            "magick", output_name,
            "-colors", "4",
            f"png8:{output_name}",
        ]
        subprocess.run(cmd, check=True)
        
        print(f"Created 8x16 font sheet with {len(half_tiles)} half-tiles ({len(char_files)} characters)")

def generate_character_widths(font_family, point_size, output_file="chwidths.bin", max_width=8):
    """Generate character widths binary file using ImageMagick metrics."""
    print(f"Calculating character widths using font metrics...")
    
    widths = []
    for ch in range(32, 128):
        char = chr(ch)
        width = calculate_char_width_metrics(font_family, point_size, char, max_width)
        widths.append(width)
        
        if ch < 40 or ch % 16 == 0:  # Show some progress
            print(f"  Char {ch} ('{char}'): width {width}")
    
    # Write binary file
    with open(output_file, 'wb') as f:
        f.write(bytes(widths))
    
    print(f"Generated {len(widths)} character widths in {output_file}")

def cleanup_temp_files(prefix="ch"):
    """Remove temporary character image files."""
    import glob
    temp_files = glob.glob(f"{prefix}*.png")
    for file in temp_files:
        try:
            os.remove(file)
        except OSError:
            pass

def main():
    parser = argparse.ArgumentParser(description='Generate SNES font data')
    parser.add_argument('--font', '-f', default='FindersKeepers',
                       help='Font family name (default: FindersKeepers)')
    parser.add_argument('--size', '-s', type=int, default=16,
                       help='Font point size (default: 16)')
    parser.add_argument('--height', type=int, choices=[8, 16], default=8,
                       help='Font height in pixels: 8 for 8x8, 16 for 8x16 (default: 8)')
    parser.add_argument('--output', '-o', default='geneva',
                       help='Output filename prefix (default: geneva)')
    parser.add_argument('--keep-temp', action='store_true',
                       help='Keep temporary character image files')
    parser.add_argument('--widths-only', action='store_true',
                       help='Only generate character widths (no images)')
    parser.add_argument('--max-width', type=int, default=8,
                       help='Maximum character width in pixels (default: 8)')
    
    args = parser.parse_args()
    
    output_png = f"{args.output}.png"
    output_widths = "chwidths.bin"
    
    try:
        print(f"Font: {args.font}")
        print(f"Size: {args.size}pt")
        print(f"Dimensions: 8x{args.height} pixels per character")
        print(f"Max width: {args.max_width} pixels")
        print()
        
        if not args.widths_only:
            print(f"Generating {args.height}x8 font images...")
            
            # Generate individual character images
            generate_character_images(args.font, args.size, args.height)
            
            # Create font sheet
            generate_font_sheet(args.height, output_png)
        
        # Generate character widths using metrics
        generate_character_widths(args.font, args.size, output_widths, args.max_width)
        
        if not args.keep_temp and not args.widths_only:
            cleanup_temp_files()
        
        print(f"\nFont generation complete!")
        if not args.widths_only:
            print(f"  Font sheet: {output_png}")
        print(f"  Character widths: {output_widths}")
        print(f"  Font dimensions: 8x{args.height} pixels per character")
        
        if args.height == 16:
            print(f"\nNote: For 8x16 fonts, make sure to use SuperFamiconv to convert")
            print(f"the font sheet with the data organized as sequential top/bottom halves:")
            print(f"  [top A][bottom A][top B][bottom B]...")
        
    except subprocess.CalledProcessError as e:
        print(f"Error during font generation: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()