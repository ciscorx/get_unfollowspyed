#!/bin/python3

#####################
#   This script replaces all korean words in a file with their
#   equivalent respective english translations using a bash script
#   called translate_phrase.sh to do the translating.
#####################

import subprocess
import re
import sys

def translate_line(line):
    """Calls the translate_phrase.sh script to get the translation"""
    result = subprocess.run(['./translate_phrase.sh', line], stdout=subprocess.PIPE)
    return result.stdout.decode('utf-8').strip()

def main(input_file, output_file):
    with open(input_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    translated_lines = []
    korean_pattern = re.compile("[\uac00-\ud7a3]")  # Unicode range for Hangul characters

    for line in lines:
        # Check if the line contains any Korean character
        if korean_pattern.search(line):
            translation = translate_line(line)
            translated_lines.append(translation)
        else:
            translated_lines.append(line)

    with open(output_file, 'w', encoding='utf-8') as f:
        for line in translated_lines:
            f.write(line + "\n")

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: python script_name.py input_file.txt output_file.txt")
        sys.exit(1)
    
    input_file_path = sys.argv[1]
    output_file_path = sys.argv[2]
    
    main(input_file_path, output_file_path)
