#!/bin/bash
# Script to run the built-in benchmarks from liboqs for SPECIFIED algorithms.
# Uses bash array for robust algorithm name handling.
# Run from the project root directory.

# --- Cấu hình ---
# Danh sách các thuật toán KEM quan trọng cần benchmark (sử dụng cú pháp array)
KEM_ALGS_TO_TEST=(
    "Kyber-512"
    "Kyber-768"
    "Kyber-1024"
    "Classic-McEliece-348864"
    "HQC-128"
)

# Danh sách các thuật toán Signature quan trọng cần benchmark
SIG_ALGS_TO_TEST=(
    "Dilithium-2"
    "Dilithium-3"
    "Dilithium-5"
    "Falcon-512"
    "Falcon-1024"
    "SPHINCS-SHA2-128f-simple"
)
# -----------------

RESULTS_DIR="results/raw_oqs_benchmarks"
BENCHMARK_EXEC_DIR="third_party/liboqs/build/tests"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

if [ ! -f "${BENCHMARK_EXEC_DIR}/speed_kem" ]; then
    echo "Error: Benchmark executables not found. Please run 'bash setup/build_liboqs.sh' first."
    exit 1
fi

mkdir -p "${RESULTS_DIR}"

echo "--- Running KEM speed test for selected algorithms ---"
KEM_OUT_FILE="${RESULTS_DIR}/kem_benchmark_${TIMESTAMP}.txt"
# Dùng cú pháp for loop chuẩn cho array: "${ARRAY[@]}"
for alg in "${KEM_ALGS_TO_TEST[@]}"; do
    echo "Benchmarking KEM: $alg"
    # Chạy lệnh và ghi output vào file, bao gồm cả lỗi nếu có
    ${BENCHMARK_EXEC_DIR}/speed_kem "$alg" >> "$KEM_OUT_FILE" 2>&1
done
echo "KEM results saved to $KEM_OUT_FILE"


echo "--- Running Signature speed test for selected algorithms ---"
SIG_OUT_FILE="${RESULTS_DIR}/sig_benchmark_${TIMESTAMP}.txt"
for alg in "${SIG_ALGS_TO_TEST[@]}"; do
    echo "Benchmarking Signature: $alg"
    ${BENCHMARK_EXEC_DIR}/speed_sig "$alg" >> "$SIG_OUT_FILE" 2>&1
done
echo "Signature results saved to $SIG_OUT_FILE"
