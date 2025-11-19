#!/bin/bash
# Script orchestra đầy đủ để chạy toàn bộ pipeline benchmark.
# Chạy từ thư mục gốc của dự án.
set -e # Thoát ngay lập tức nếu có lệnh nào thất bại

# --- Kích hoạt môi trường Conda ---
# Giả sử bạn đang chạy trong một shell đã init conda
source $(conda info --base)/etc/profile.d/conda.sh
conda activate pqc-research

# Kiểm tra xem môi trường đã được kích hoạt chưa
if [ -z "$CONDA_PREFIX" ]; then
    echo "Lỗi: Không thể kích hoạt môi trường Conda 'pqc-research'."
    exit 1
fi
echo "Môi trường Conda 'pqc-research' đã được kích hoạt."
echo ""

# --- Giai đoạn 1: Dọn dẹp kết quả cũ ---
echo "--- [1/7] Cleaning old results ---"
rm -f results/*.csv
rm -f results/raw_oqs_benchmarks/*.txt
rm -f figures/*.png
echo "Done."
echo ""

# --- Giai đoạn 2: Build/Re-build (nếu cần) ---
echo "--- [2/7] Building libraries and custom tools ---"
bash setup/build_liboqs.sh
echo "Done."
echo ""

# --- Giai đoạn 3: Thu thập dữ liệu Tốc độ ---
echo "--- [3/7] Collecting speed benchmark data ---"
bash scripts/run_oqs_benchmark.sh
# Tìm file txt mới nhất để xử lý
RAW_KEM_SPEED_FILE=$(ls -t results/raw_oqs_benchmarks/kem_benchmark_*.txt | head -n 1)
RAW_SIG_SPEED_FILE=$(ls -t results/raw_oqs_benchmarks/sig_benchmark_*.txt | head -n 1)
echo "Done."
echo ""

# --- Giai đoạn 4: Thu thập dữ liệu Kích thước ---
echo "--- [4/7] Collecting size data ---"
bash scripts/collect_sizes.sh
echo "Done."
echo ""

# --- Giai đoạn 5: Xử lý dữ liệu Tốc độ thô -> CSV ---
echo "--- [5/7] Parsing raw speed data to CSV ---"
python analysis/parse_results.py "$RAW_KEM_SPEED_FILE" "results/kem_benchmarks.csv" --type kem
python analysis/parse_results.py "$RAW_SIG_SPEED_FILE" "results/sig_benchmarks.csv" --type sig
echo "Done."
echo ""

# --- Giai đoạn 6: Gộp dữ liệu Tốc độ và Kích thước ---
echo "--- [6/7] Merging speed and size data ---"
python analysis/merge_data.py --type kem
python analysis/merge_data.py --type sig
echo "Done."
echo ""

# --- Giai đoạn 7: Trực quan hóa dữ liệu cuối cùng ---
echo "--- [7/7] Generating final charts ---"
python analysis/visualize_results.py "results/kem_final_data.csv" --type kem
python analysis/visualize_results.py "results/sig_final_data.csv" --type sig
echo "Done."
echo ""

# --- Hoàn tất ---
echo "========================================"
echo "✅ PIPELINE COMPLETED SUCCESSFULLY!"
echo "New charts are available in the 'figures/' directory."
echo "========================================"
