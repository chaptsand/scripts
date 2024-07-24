import sys

def remove_duplicates(file_path, output_path=None):
    lines_seen = set()
    unique_lines = []

    with open(file_path, 'r') as file:
        for line in file:
            line = line.strip()
            if line not in lines_seen:
                unique_lines.append(line)
                lines_seen.add(line)

    if output_path is None:
        output_path = file_path

    with open(output_path, 'w') as file:
        for line in unique_lines:
            file.write(line + '\n')

if __name__ == "__main__":
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print(f"Usage: {sys.argv[0]} <input_file> [output_file]")
        sys.exit(1)

    input_file_path = sys.argv[1]
    output_file_path = sys.argv[2] if len(sys.argv) == 3 else None

    remove_duplicates(input_file_path, output_file_path)
