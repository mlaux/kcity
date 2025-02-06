import sys
import numpy as np
from PIL import Image
from scipy.spatial import KDTree

def get_palette(image):
    """Extracts the unique colors from an indexed PNG as an RGB palette."""
    if image.mode != "P":
        raise ValueError("Reference image must be an indexed PNG (mode 'P').")
    
    palette = image.getpalette()[:256*3]  # Get the first 256 colors (RGB triplets)
    unique_colors = list(set(tuple(palette[i:i+3]) for i in range(0, len(palette), 3)))
    return unique_colors

def snap_to_palette(image, palette, orig_palette, reference_image):
    """Converts an image to use the closest colors from the given palette."""
    pixels = np.array(image.convert("RGBA"))
    transparent_mask = pixels[:, :, 3] == 0
    opaque_pixels = pixels[:, :, :3]

    # Build a KDTree for fast nearest-neighbor lookup
    color_tree = KDTree(palette)
    
    # Map each pixel to the closest palette color
    reshaped_pixels = opaque_pixels.reshape(-1, 3)
    _, nearest_indices = color_tree.query(reshaped_pixels)
    snapped_pixels = np.array([palette[i] for i in nearest_indices], dtype=np.uint8)
    snapped_pixels = snapped_pixels.reshape(pixels.shape[:2] + (3,))
    # Reintroduce transparency by setting fully transparent pixels to a placeholder color 255, 0, 255
    snapped_pixels[transparent_mask] = (255, 0, 255)

    # Reshape back to original image size and convert to indexed mode
    snapped_image = Image.fromarray(snapped_pixels, mode="RGB")

    snapped_image = snapped_image.convert("P", palette=Image.Palette.ADAPTIVE)

    # get where it put the magenta to set that as the transparent entry
    # in the png - there is probably an easier way to do this
    pal = snapped_image.getpalette()
    cols = [tuple(pal[i:i+3]) for i in range(0, len(pal), 3)]
    magenta = cols.index((255, 0, 255))
    print(f"index: {magenta}")
    snapped_image.info["transparency"] = magenta
    return snapped_image

def main():
    if len(sys.argv) < 3:
        print("Usage: python script.py reference.png image1.png image2.png ...")
        sys.exit(1)
    
    reference_image = Image.open(sys.argv[1])
    orig_palette = reference_image.getpalette()
    palette = get_palette(reference_image)
    
    for image_path in sys.argv[2:]:
        image = Image.open(image_path)
        snapped_image = snap_to_palette(image, palette, orig_palette, reference_image)
        output_path = image_path#.rsplit('.', 1)[0] + "_snapped.png"
        snapped_image.save(output_path, format="PNG")
        print(f"Saved: {output_path}")

if __name__ == "__main__":
    main()
