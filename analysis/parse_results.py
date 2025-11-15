import pandas as pd
import argparse
import os

def parse_oqs_table_output_final(input_file, operations):
    """
    Parses the multi-block, table-based output from OQS speed tests.
    This version correctly identifies algorithm and operation rows.
    """
    results = []
    current_algorithm = None
    current_timings = {}

    try:
        with open(input_file, 'r') as f:
            for line in f:
                # Tách dòng thành các cột dựa trên dấu '|'
                columns = [col.strip() for col in line.split('|')]
                
                # Bỏ qua các dòng không phải là dữ liệu bảng
                if len(columns) < 2 or not columns[0]:
                    continue
                
                first_col_content = columns[0]

                # Kiểm tra xem dòng này là dòng operation hay dòng tên thuật toán
                if first_col_content in operations:
                    # Đây là một dòng operation (keygen, encaps, etc.)
                    if current_algorithm and len(columns) >= 4:
                        try:
                            # Lấy giá trị mean time (us) và chuyển sang ns
                            time_us = float(columns[3])
                            current_timings[first_col_content] = int(time_us * 1000)
                        except ValueError:
                            continue # Bỏ qua nếu cột không phải là số
                elif first_col_content not in ["Operation", "------------------------------------"]:
                    # Đây là một dòng tên thuật toán mới
                    # Lưu kết quả của thuật toán cũ lại (nếu có đủ dữ liệu)
                    if current_algorithm and len(current_timings) == len(operations):
                        ordered_times = [current_timings.get(op) for op in operations]
                        results.append([current_algorithm] + ordered_times)

                    # Bắt đầu xử lý thuật toán mới
                    current_algorithm = first_col_content
                    current_timings = {}

            # Lưu lại thuật toán cuối cùng trong file
            if current_algorithm and len(current_timings) == len(operations):
                ordered_times = [current_timings.get(op) for op in operations]
                results.append([current_algorithm] + ordered_times)

    except FileNotFoundError:
        print(f"Error: Input file not found at {input_file}")
        exit(1)
        
    return results

def main():
    parser = argparse.ArgumentParser(description="Parse OQS benchmark results into a CSV file.")
    parser.add_argument("input_file", help="Path to the raw benchmark .txt file.")
    parser.add_argument("output_file", help="Path to save the output .csv file.")
    parser.add_argument("--type", choices=['kem', 'sig'], required=True, help="Type of benchmark: 'kem' or 'sig'.")
    
    args = parser.parse_args()

    if args.type == 'kem':
        operations = ['keygen', 'encaps', 'decaps']
        columns = ['algorithm', 'keypair_ns', 'encaps_ns', 'decaps_ns']
    else: # sig
        operations = ['keypair', 'sign', 'verify']
        columns = ['algorithm', 'keypair_ns', 'sign_ns', 'verify_ns']
    
    output_dir = os.path.dirname(args.output_file)
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)
    
    parsed_data = parse_oqs_table_output_final(args.input_file, operations)
    
    if not parsed_data:
        print(f"Warning: No valid data parsed from {args.input_file}.")
        pd.DataFrame(columns=columns).to_csv(args.output_file, index=False)
        return

    df = pd.DataFrame(parsed_data, columns=columns)
    df.dropna(inplace=True)
    df.to_csv(args.output_file, index=False)
    print(f"Successfully parsed {len(df)} records and saved to {args.output_file}")

if __name__ == "__main__":
    main()
