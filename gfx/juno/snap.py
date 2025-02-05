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
    pixels = np.array(image.convert("RGB"))

    # Build a KDTree for fast nearest-neighbor lookup
    color_tree = KDTree(palette)
    
    # Map each pixel to the closest palette color
    reshaped_pixels = pixels.reshape(-1, 3)
    _, nearest_indices = color_tree.query(reshaped_pixels)
    snapped_pixels = np.array([palette[i] for i in nearest_indices], dtype=np.uint8)

    # Reshape back to original image size and convert to indexed mode
    snapped_image = Image.fromarray(snapped_pixels.reshape(pixels.shape), mode="RGB")

    snapped_image = snapped_image.convert("P", palette=Image.Palette.ADAPTIVE)
    pal = snapped_image.getpalette()
    cols = [tuple(pal[i:i+3]) for i in range(0, len(pal), 3)]
    print(f"index: {cols.index((0, 0, 0))}")


    snapped_image.info["transparency"] = cols.index((0, 0, 0))
    return snapped_image

def main():
    if len(sys.argv) < 3:
        print("Usage: python script.py reference.png image1.png image2.png ...")
        sys.exit(1)
    
    reference_image = Image.open(sys.argv[1])
    orig_palette = reference_image.getpalette()
    palette = get_palette(reference_image)
    print(reference_image.info.get("transparency", None))
    
    for image_path in sys.argv[2:]:
        image = Image.open(image_path)
        snapped_image = snap_to_palette(image, palette, orig_palette, reference_image)
        output_path = image_path.rsplit('.', 1)[0] + "_snapped.png"
        snapped_image.save(output_path, format="PNG")
        print(f"Saved: {output_path}")

if __name__ == "__main__":
    main()
