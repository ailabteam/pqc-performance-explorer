import re
import pandas as pd
import argparse
import os

KEM_PATTERN = re.compile(r"(\S+)\s+@\s+\d+\s+reps:\s+keypair\s+avg:\s+(\d+)\s+ns;\s+encaps\s+avg:\s+(\d+)\s+ns;\s+decaps\s+avg:\s+(\d+)\s+ns")
SIG_PATTERN = re.compile(r"(\S+)\s+@\s+\d+\s+reps:\s+keypair\s+avg:\s+(\d+)\s+ns;\s+sign\s+avg:\s+(\d+)\s+ns;\s+verify\s+avg:\s+(\d+)\s+ns")

def parse_file(input_file, pattern):
    data = []
    try:
        with open(input_file, 'r') as f:
            for line in f:
                match = pattern.search(line)
                if match:
                    values = [int(v) for v in match.groups()[1:]]
                    data.append([match.group(1)] + values)
    except FileNotFoundError:
        print(f"Error: Input file not found at {input_file}")
        exit(1)
    return data

def main():
    parser = argparse.ArgumentParser(description="Parse OQS benchmark results into a CSV file.")
    parser.add_argument("input_file", help="Path to the raw benchmark .txt file.")
    parser.add-argument("output_file", help="Path to save the output .csv file.")
    parser.add_argument("--type", choices=['kem', 'sig'], required=True, help="Type of benchmark: 'kem' or 'sig'.")
    
    args = parser.parse_args()

    if args.type == 'kem':
        pattern = KEM_PATTERN
        columns = ['algorithm', 'keypair_ns', 'encaps_ns', 'decaps_ns']
    else: # sig
        pattern = SIG_PATTERN
        columns = ['algorithm', 'keypair_ns', 'sign_ns', 'verify_ns']
        
    os.makedirs(os.path.dirname(args.output_file), exist_ok=True)
    
    parsed_data = parse_file(args.input_file, pattern)
    
    if not parsed_data:
        print(f"Warning: No matching lines found in {args.input_file} for type '{args.type}'. Check the file content.")
        return

    df = pd.DataFrame(parsed_data, columns=columns)
    df.to_csv(args.output_file, index=False)
    print(f"Successfully parsed data and saved to {args.output_file}")

if __name__ == "__main__":
    main()
