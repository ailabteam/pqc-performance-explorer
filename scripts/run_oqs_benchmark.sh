#!/bin/bash
# Script to run the built-in benchmarks from liboqs for SPECIFIED algorithms.
# Run from the project root directory.

# --- Cấu hình ---
# Danh sách các thuật toán KEM quan trọng cần benchmark
# Dựa trên tiêu chuẩn NIST và các ứng viên vòng 4
KEM_ALGS_TO_TEST="Kyber-512 Kyber-768 Kyber-1024 Classic-McEliece-348864 HQC-128"

# Danh sách các thuật toán Signature quan trọng cần benchmark
SIG_ALGS_TO_TEST="Dilithium-2 Dilithium-3 Dilithium-5 Falcon-512 Falcon-1024 SPHINCS-SHA2-128f-simple"
# -----------------

RESULTS_DIR="results/raw_oqs_benchmarks"
BENCHMARK_EXEC_DIR="third_party/liboqs/build/tests"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Kiểm tra xem thư mục build có tồn tại không
if [ ! -f "${BENCHMARK_EXEC_DIR}/speed_kem" ]; then
    echo "Error: Benchmark executables not found in ${BENCHMARK_EXEC_DIR}"
    echo "Please run 'bash setup/build_liboqs.sh' first."
    exit 1
fi

mkdir -p "${RESULTS_DIR}"

echo "--- Running KEM speed test for selected algorithms ---"
KEM_OUT_FILE="${RESULTS_DIR}/kem_benchmark_${TIMESTAMP}.txt"
# Chạy từng thuật toán và ghi output vào cùng 1 file
for alg in $KEM_ALGS_TO_TEST; do
    echo "Benchmarking KEM: $alg"
    ${BENCHMARK_EXEC_DIR}/speed_kem "$alg" >> "$KEM_OUT_FILE"
done
echo "KEM results saved to $KEM_OUT_FILE"


echo "--- Running Signature speed test for selected algorithms ---"
SIG_OUT_FILE="${RESULTS_DIR}/sig_benchmark_${TIMESTAMP}.txt"
for alg in $SIG_ALGS_TO_TEST; do
    echo "Benchmarking Signature: $alg"
    ${BENCHMARK_EXEC_DIR}/speed_sig "$alg" >> "$SIG_OUT_FILE"
done
echo "Signature results saved to $SIG_OUT_FILE"
