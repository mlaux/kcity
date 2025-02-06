#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void compress_rle(const unsigned char *input, size_t length, FILE *output) {
    size_t i = 0;

    while (i < length) {
        unsigned char byte = input[i];
        size_t count = 1;

        while (i + count < length && input[i + count] == byte && count < 255) {
            count++;
        }

        fputc((unsigned char) count, output);
        fputc(byte, output);
        i += count;
    }
}

int main(int argc, char *argv[]) {
    FILE *input_file;
    long input_size;
    unsigned char *buffer;
    char output_filename[FILENAME_MAX];
    FILE *output_file;
    long output_size;

    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input file>\n", argv[0]);
        return 1;
    }

    input_file = fopen(argv[1], "rb");
    if (!input_file) {
        perror("Error opening input file");
        return 1;
    }

    fseek(input_file, 0, SEEK_END);
    input_size = ftell(input_file);
    rewind(input_file);

    if (input_size < 0) {
        perror("Error determining file size");
        fclose(input_file);
        return 1;
    }

    buffer = (unsigned char *) malloc(input_size);
    if (!buffer) {
        perror("Memory allocation failed");
        fclose(input_file);
        return 1;
    }

    if (fread(buffer, 1, input_size, input_file) != (size_t) input_size) {
        perror("Error reading file");
        free(buffer);
        fclose(input_file);
        return 1;
    }
    fclose(input_file);

    snprintf(output_filename, sizeof(output_filename), "%s.cwm", argv[1]);
    output_file = fopen(output_filename, "wb");
    if (!output_file) {
        perror("Error creating output file");
        free(buffer);
        return 1;
    }

    compress_rle(buffer, input_size, output_file);
    output_size = ftell(output_file);
    fclose(output_file);
    free(buffer);

    printf("%s: %ld -> %ld bytes\n", output_filename, input_size, output_size);
    return 0;
}
