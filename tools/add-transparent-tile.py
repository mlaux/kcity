import json
import sys

def process_json(input_file, output_file):
    with open(input_file, 'r') as f:
        data = json.load(f)

    # Create the new tile
    new_tile = {
        "palette": 0,
        "data": [0] * 256
    }

    # Append the new tile
    data['tiles'].append(new_tile)

    # The index of the newly added tile
    new_tile_index = len(data['tiles']) - 1

    # Update background
    for y in range(len(data['background'])):
        for x in range(len(data['background'][y])):
            if data['background'][y][x] == -1:
                data['background'][y][x] = new_tile_index

    # Write the result
    with open(output_file, 'w') as f:
        json.dump(data, f, indent=2)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} input.json output.json")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    process_json(input_file, output_file)

