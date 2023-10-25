#!/bin/python3

#####################
#   This script appends the English translations and pronunciations of Chinese words
#   from an input file using a bash script called translate_phrase_print_pronunciation.sh for translation.
#####################

import subprocess
import re
import sys

def translate_line(line):
    """Calls the translate_phrase_print_pronunciation.sh script to get the translation"""
    result = subprocess.run(['./translate_phrase_print_pronunciation.sh', line], stdout=subprocess.PIPE)
    return result.stdout.decode('utf-8').strip()

def main(input_file, output_file):
    with open(input_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    processed_lines = []
    chinese_pattern = re.compile(r"[\u4E00-\u9FFF]")  # Unicode range for Han characters (Chinese)

    for line in lines:
        processed_lines.append(line.strip())  # Append the original line
        # Check if the line contains any Chinese character
        if chinese_pattern.search(line):
            translation = translate_line(line)
            # Append the English translation and pronunciation
            processed_lines.append(translation)
    
    with open(output_file, 'w', encoding='utf-8') as f:
        for line in processed_lines:
            f.write(line + "\n")

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: python script_name.py input_file.txt output_file.txt")
        sys.exit(1)
    
    input_file_path = sys.argv[1]
    output_file_path = sys.argv[2]
    
    main(input_file_path, output_file_path)
