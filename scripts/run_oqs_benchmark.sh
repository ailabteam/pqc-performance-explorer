#!/bin/bash
# Script để chạy benchmark tốc độ VÀ thu thập dữ liệu sử dụng RAM đỉnh.
# Run from the project root directory.

# --- Cấu hình ---
KEM_ALGS_TO_TEST=(
    "Kyber512"
    "Kyber768"
    "Kyber1024"
    "Classic-McEliece-348864"
    "HQC-128"
)

SIG_ALGS_TO_TEST=(
    "Dilithium2"
    "Dilithium3"
    "Dilithium5"
    "Falcon-512"
    "Falcon-1024"
    "SPHINCS+-SHA2-128f-simple"
)
# -----------------

RESULTS_DIR="results/raw_oqs_benchmarks"
BENCHMARK_EXEC_DIR="third_party/liboqs/build/tests"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

if [ ! -f "${BENCHMARK_EXEC_DIR}/speed_kem" ]; then
    echo "Error: Benchmark executables not found."
    exit 1
fi

mkdir -p "${RESULTS_DIR}"

# --- KEM: Tốc độ và RAM ---
echo "--- Running KEM speed & memory test (1s duration each) ---"
KEM_OUT_FILE="${RESULTS_DIR}/kem_benchmark_${TIMESTAMP}.txt"
> "$KEM_OUT_FILE" # Xóa file cũ

for alg in "${KEM_ALGS_TO_TEST[@]}"; do
    echo "Benchmarking KEM: $alg"
    
    # Thêm một dòng đánh dấu đặc biệt để parser dễ dàng xác định
    echo "--- BEGIN ALGORITHM: ${alg} ---" >> "$KEM_OUT_FILE"
    
    # Chạy lệnh benchmark được bọc bởi /usr/bin/time -v
    # Cả stdout và stderr đều được ghi vào file output
    /usr/bin/time -v ${BENCHMARK_EXEC_DIR}/speed_kem --duration 1 "$alg" >> "$KEM_OUT_FILE" 2>&1
    
    # Thêm một dòng kết thúc
    echo "--- END ALGORITHM: ${alg} ---" >> "$KEM_OUT_FILE"
    echo "" >> "$KEM_OUT_FILE" # Thêm dòng trống cho dễ đọc
done
echo "KEM results saved to $KEM_OUT_FILE"


# --- Signature: Tốc độ và RAM ---
echo "--- Running Signature speed & memory test (1s duration each) ---"
SIG_OUT_FILE="${RESULTS_DIR}/sig_benchmark_${TIMESTAMP}.txt"
> "$SIG_OUT_FILE" # Xóa file cũ

for alg in "${SIG_ALGS_TO_TEST[@]}"; do
    echo "Benchmarking Signature: $alg"

    echo "--- BEGIN ALGORITHM: ${alg} ---" >> "$SIG_OUT_FILE"
    /usr/bin/time -v ${BENCHMARK_EXEC_DIR}/speed_sig --duration 1 "$alg" >> "$SIG_OUT_FILE" 2>&1
    echo "--- END ALGORITHM: ${alg} ---" >> "$SIG_OUT_FILE"
    echo "" >> "$SIG_OUT_FILE"
done
echo "Signature results saved to $SIG_OUT_FILE"
