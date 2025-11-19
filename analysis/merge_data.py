# File: analysis/merge_data.py
# Mục đích: Gộp file CSV chứa dữ liệu tốc độ và file CSV chứa dữ liệu kích thước
# thành một file CSV tổng hợp duy nhất.

import pandas as pd
import argparse
import os

def merge_csv_files(speed_file, size_file, output_file):
    """
    Sử dụng pandas để đọc 2 file CSV và gộp chúng lại dựa trên cột 'algorithm'.
    """
    try:
        # Đọc 2 file CSV vào DataFrame của pandas
        df_speed = pd.read_csv(speed_file)
        df_size = pd.read_csv(size_file)

        # Gộp (merge) hai DataFrame lại với nhau
        # 'on="algorithm"': gộp dựa trên cột chung là 'algorithm'
        # 'how="inner"': chỉ giữ lại những thuật toán xuất hiện ở cả 2 file
        df_merged = pd.merge(df_speed, df_size, on="algorithm", how="inner")

        # Lưu DataFrame đã gộp vào file CSV mới
        output_dir = os.path.dirname(output_file)
        if output_dir:
            os.makedirs(output_dir, exist_ok=True)
        
        df_merged.to_csv(output_file, index=False)
        print(f"Successfully merged {speed_file} and {size_file} -> {output_file}")
        print(f"Total records in final file: {len(df_merged)}")

    except FileNotFoundError as e:
        print(f"Error: Could not find a required file. {e}")
        exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        exit(1)

def main():
    parser = argparse.ArgumentParser(description="Merge speed and size benchmark data.")
    parser.add_argument("--type", choices=['kem', 'sig'], required=True, help="Type of benchmark: 'kem' or 'sig'.")
    
    args = parser.parse_args()

    # Định nghĩa tên file dựa trên type
    # Đây là các file CSV được tạo ra bởi các script trước đó
    speed_input = f"results/{args.type}_benchmarks.csv"
    size_input = f"results/{args.type}_sizes.csv"
    
    # File output cuối cùng
    final_output = f"results/{args.type}_final_data.csv"

    merge_csv_files(speed_input, size_input, final_output)


if __name__ == "__main__":
    main()
