import subprocess

# Captions for each image
captions = ['R' + str(i) for i in range(8)] + \
           ['F' + str(i) for i in range(8)] + \
           ['L' + str(i) for i in range(8)] + \
           ['B' + str(i) for i in range(8)]

# Loop over the captions to generate the images
for caption in captions:
    # Prepare the command
    command = [
        'magick',
        '-background', 'none',
        '-fill', 'white',
        '-size', '16x32',
        f'caption:{caption}',
        '-monochrome',
        f'{caption}.png'
    ]
    
    # Execute the command
    subprocess.run(command)

print("Images generated successfully.")
