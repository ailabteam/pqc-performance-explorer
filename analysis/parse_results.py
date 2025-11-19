# File: analysis/parse_results.py
# Version: 2.0 (Nâng cấp để xử lý output hỗn hợp từ speed_kem và /usr/bin/time)

import pandas as pd
import argparse
import os
import re # Thư viện biểu thức chính quy

def parse_combined_output(file_content, operations):
    results = []
    algorithm_blocks = re.findall(r'--- BEGIN ALGORITHM: (.*?) ---\n(.*?)\n--- END ALGORITHM: \1 ---', file_content, re.DOTALL)

    for alg_name, block_content in algorithm_blocks:
        record = {'algorithm': alg_name}
        
        # --- 1. Trích xuất dữ liệu Tốc độ từ bảng ---
        speed_lines = block_content.split('\n')
        for line in speed_lines:
            columns = [col.strip() for col in line.split('|')]
            if len(columns) < 4:
                continue
            op_name = columns[0]
            if op_name in operations:
                try:
                    time_us = float(columns[3])
                    record[f'{op_name}_ns'] = int(time_us * 1000)
                except (ValueError, IndexError):
                    continue
        
        # --- 2. Trích xuất dữ liệu RAM từ output của /usr/bin/time ---
        ram_match = re.search(r'Maximum resident set size \(kbytes\): (\d+)', block_content)
        if ram_match:
            record['peak_ram_kb'] = int(ram_match.group(1))
        else:
            record['peak_ram_kb'] = None 

        op_keys_found = all(f'{op}_ns' in record for op in operations)
        if op_keys_found:
            results.append(record)

    return results

def main():
    parser = argparse.ArgumentParser(description="Parse OQS benchmark results (speed and memory) into a CSV file.")
    parser.add_argument("input_file", help="Path to the raw benchmark .txt file.")
    parser.add_argument("output_file", help="Path to save the output .csv file.")
    parser.add_argument("--type", choices=['kem', 'sig'], required=True, help="Type of benchmark: 'kem' or 'sig'.")

    args = parser.parse_args()

    if args.type == 'kem':
        operations = ['keygen', 'encaps', 'decaps']
        csv_columns = ['algorithm', 'keygen_ns', 'encaps_ns', 'decaps_ns', 'peak_ram_kb']
    else: # sig
        operations = ['keypair', 'sign', 'verify']
        csv_columns = ['algorithm', 'keypair_ns', 'sign_ns', 'verify_ns', 'peak_ram_kb']

    try:
        with open(args.input_file, 'r') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"Error: Input file not found at {args.input_file}")
        exit(1)

    parsed_data = parse_combined_output(content, operations)

    if not parsed_data:
        print(f"Warning: No valid data parsed from {args.input_file}.")
        return

    df = pd.DataFrame(parsed_data)
    df = df[csv_columns]
    
    output_dir = os.path.dirname(args.output_file)
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)

    df.to_csv(args.output_file, index=False)
    print(f"Successfully parsed {len(df)} records (speed+memory) and saved to {args.output_file}")


if __name__ == "__main__":
    main()
