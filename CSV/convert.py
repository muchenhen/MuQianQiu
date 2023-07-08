import re
import os

def convert_line(line):
    # Split the line into its comma-separated values
    values = line.strip().split(',')
    
    # Extract the values we want to modify
    id = values[0]
    name = values[1]
    cards_name = values[2]
    cards_id = values[3]
    score = values[4]
    audio_id = values[5]
    
    # Use regular expressions to extract the individual card names and IDs
    card_names = re.findall(r'[^;]+', cards_name)
    card_ids = re.findall(r'\d+', cards_id)
    
    # Combine the card names and IDs into tuples
    card_tuples = [f'""{name}""' for name in card_names]
    card_id_tuples = [f'{id}' for id in card_ids]
    
    # Combine the tuples into strings
    cards_str = ','.join(card_tuples)
    card_ids_str = ','.join(card_id_tuples)
    
    # Construct the modified line
    new_line = f'{id},"{name}","({cards_str})","({card_ids_str})",{score},"{audio_id}"'
    
    return new_line

# 读取同目录下的Story.CSV 对从第二行开始的每一行执行convert_line后保存进原文件

# Open the input file for reading
input_file = 'Story.CSV'
with open(input_file, 'r', encoding='utf-8') as f:
    # Read the first line (header) and discard it
    header = f.readline()
    
    # Read the remaining lines and apply the convert_line function to each of them
    lines = [convert_line(line) for line in f]

# Open the input file for writing
with open(input_file, 'w', encoding='utf-8') as f:
    # Write the header back to the file
    f.write(header)
    
    # Write the modified lines back to the file
    f.write('\n'.join(lines))

print(f"Converted {len(lines)} lines in {os.path.abspath(input_file)}")
 