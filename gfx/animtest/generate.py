import subprocess

# Captions for each image
captions = ['r' + str(i) for i in range(8)] + \
           ['f' + str(i) for i in range(8)] + \
           ['l' + str(i) for i in range(8)] + \
           ['b' + str(i) for i in range(8)]

# Loop over the captions to generate the images
for caption in captions:
    # Prepare the command
    command = [
        'magick',
        '-background', 'black',
        '-fill', 'white',
        '-size', '16x16',
        f'caption:{caption}t',
        '-monochrome',
        f'{caption}-top.png'
    ]

    subprocess.run(command)

    command = [
        'magick',
        '-background', 'black',
        '-fill', 'white',
        '-size', '16x16',
        f'caption:{caption}b',
        '-monochrome',
        f'{caption}-bottom.png'
    ]

    subprocess.run(command)

print("Images generated successfully.")
