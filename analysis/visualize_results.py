# File: analysis/visualize_results.py
# Version: 2.0 (Nâng cấp để vẽ biểu đồ cả về Tốc độ và Kích thước)

import pandas as pd
import matplotlib
matplotlib.use('Agg') # Chế độ không hiển thị GUI, phù hợp cho server
import matplotlib.pyplot as plt
import seaborn as sns
import argparse
import os

def create_bar_chart(df, x_col, y_cols, title, ylabel, output_path, use_log_scale=False, y_unit_suffix=''):
    """
    Hàm chung để tạo và lưu một biểu đồ cột (bar chart).

    Args:
        df (pd.DataFrame): DataFrame chứa dữ liệu.
        x_col (str): Tên cột cho trục X.
        y_cols (list): Danh sách các cột cho trục Y.
        title (str): Tiêu đề của biểu đồ.
        ylabel (str): Nhãn của trục Y.
        output_path (str): Đường dẫn để lưu file ảnh.
        use_log_scale (bool): Có sử dụng thang log cho trục Y hay không.
        y_unit_suffix (str): Hậu tố đơn vị (ví dụ: 'bytes') để hiển thị trên các cột.
    """
    # Sắp xếp dữ liệu để biểu đồ đẹp hơn (dựa trên cột dữ liệu đầu tiên)
    df_sorted = df.sort_values(by=y_cols[0], ascending=True).copy()

    # Tạo biểu đồ
    ax = df_sorted.plot(x=x_col, y=y_cols, kind='bar', figsize=(16, 9), grid=True, zorder=2)

    # --- Tùy chỉnh biểu đồ ---
    plt.title(title, fontsize=22, pad=20)
    plt.xlabel('Algorithm', fontsize=16)
    plt.ylabel(ylabel, fontsize=16)
    plt.xticks(rotation=45, ha='right', fontsize=12)
    plt.yticks(fontsize=12)

    if use_log_scale:
        ax.set_yscale('log')

    # Thêm giá trị trên đỉnh mỗi cột để dễ đọc
    for container in ax.containers:
        ax.bar_label(container, fmt=f'%.0f{y_unit_suffix}', label_type='edge', fontsize=10, rotation=90, padding=5)

    ax.legend(title='Metric', fontsize=12)
    plt.grid(True, which="both", ls="--", zorder=1)
    plt.tight_layout(pad=1.5)

    # --- Lưu biểu đồ ---
    plt.savefig(output_path, dpi=300)
    print(f"Chart saved to {output_path}")
    plt.close() # Đóng plot để giải phóng bộ nhớ

def main():
    parser = argparse.ArgumentParser(description="Visualize PQC performance and size data from a final CSV file.")
    parser.add_argument("input_csv", help="Path to the final merged .csv data file.")
    parser.add_argument("--type", choices=['kem', 'sig'], required=True, help="Type of benchmark: 'kem' or 'sig'.")

    args = parser.parse_args()

    # --- Chuẩn bị ---
    output_dir = "figures"
    os.makedirs(output_dir, exist_ok=True)

    try:
        df = pd.read_csv(args.input_csv)
    except FileNotFoundError:
        print(f"Error: CSV file not found at {args.input_csv}. Please run the merge_data.py script first.")
        return

    if df.empty:
        print(f"Warning: The CSV file {args.input_csv} is empty. No charts will be generated.")
        return

    # --- 1. Vẽ biểu đồ TỐC ĐỘ (như cũ, nhưng cải tiến) ---
    speed_cols_ns = [col for col in df.columns if '_ns' in col]
    if speed_cols_ns:
        df_speed = df[['algorithm'] + speed_cols_ns].copy()
        # Chuyển đổi từ ns sang us cho dễ đọc
        for col in speed_cols_ns:
            df_speed[col.replace('_ns', '_us')] = df_speed[col] / 1000

        speed_cols_us = [col.replace('_ns', '_us') for col in speed_cols_ns]

        speed_title = f'Performance of PQC {args.type.upper()}s'
        speed_ylabel = 'Average Time (microseconds) - Log Scale'
        speed_output_path = os.path.join(output_dir, f'{args.type}_performance_comparison.png')

        create_bar_chart(df_speed, 'algorithm', speed_cols_us, speed_title, speed_ylabel, speed_output_path, use_log_scale=True)

    # --- 2. Vẽ các biểu đồ KÍCH THƯỚC (mới) ---
    size_cols_bytes = [col for col in df.columns if '_bytes' in col]
    if size_cols_bytes:
        df_size = df[['algorithm'] + size_cols_bytes].copy()

        # Vẽ một biểu đồ riêng cho từng loại kích thước
        for size_col in size_cols_bytes:
            # Tạo tên đẹp hơn cho tiêu đề và nhãn
            metric_name = size_col.replace('_bytes', '').replace('_', ' ').title()

            size_title = f'Size of {metric_name} for PQC {args.type.upper()}s'
            size_ylabel = 'Size (bytes) - Log Scale'
            size_output_path = os.path.join(output_dir, f'{args.type}_{size_col}_comparison.png')

            # Chỉ vẽ một cột dữ liệu, sắp xếp theo chính cột đó
            create_bar_chart(df_size, 'algorithm', [size_col], size_title, size_ylabel, size_output_path, use_log_scale=True, y_unit_suffix=' B')

    # --- 3. Vẽ biểu đồ BỘ NHỚ (mới) ---
    if 'peak_ram_kb' in df.columns:
        df_mem = df[['algorithm', 'peak_ram_kb']].copy()
        
        mem_title = f'Peak Memory (RAM) Usage for PQC {args.type.upper()}s'
        mem_ylabel = 'Peak Memory Usage (Kilobytes)'
        mem_output_path = os.path.join(output_dir, f'{args.type}_peak_ram_comparison.png')

        # Sử dụng thang đo tuyến tính (linear) cho RAM vì nó phản ánh đúng hơn mức tiêu thụ tài nguyên tuyệt đối.
        # Log scale có thể che giấu sự khác biệt quan trọng nếu các giá trị tương đối gần nhau.
        create_bar_chart(df_mem, 'algorithm', ['peak_ram_kb'], mem_title, mem_ylabel, mem_output_path, use_log_scale=False, y_unit_suffix=' KB')



if __name__ == "__main__":
    main()
