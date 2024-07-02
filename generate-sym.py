import re
import sys

# chatgpt did a pretty good job on this
def generate_sym(vice_file):
    with open(vice_file, 'r') as infile, open('out.sym', 'w') as outfile:
        outfile.write('[labels]\n')
        for line in infile:
            # Match the pattern <symbol name> = <address>
            match = re.match(r'(\S+)\s*=\s*\$(\w+)', line)
            if match:
                symbol_name, address = match.groups()
                # Convert address to integer
                address_int = int(address, 16)
                # Extract upper byte and lower two bytes
                upper_byte = (address_int >> 16) & 0xFF
                lower_two_bytes = address_int & 0xFFFF
                # Format and write the result
                outfile.write(f'{upper_byte:02X}:{lower_two_bytes:04X} {symbol_name}\n')

if __name__ == '__main__':
    if len(sys.argv) > 1:
        generate_sym(sys.argv[1])