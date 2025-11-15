#!/bin/bash
# Script to run benchmarks with all algorithm names corrected for liboqs v0.10.0.
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

echo "--- Running KEM speed test (1s duration each) ---"
KEM_OUT_FILE="${RESULTS_DIR}/kem_benchmark_${TIMESTAMP}.txt"
> "$KEM_OUT_FILE"
for alg in "${KEM_ALGS_TO_TEST[@]}"; do
    echo "Benchmarking KEM: $alg"
    ${BENCHMARK_EXEC_DIR}/speed_kem --duration 1 "$alg" >> "$KEM_OUT_FILE" 2>&1
done
echo "KEM results saved to $KEM_OUT_FILE"


echo "--- Running Signature speed test (1s duration each) ---"
SIG_OUT_FILE="${RESULTS_DIR}/sig_benchmark_${TIMESTAMP}.txt"
> "$SIG_OUT_FILE"
for alg in "${SIG_ALGS_TO_TEST[@]}"; do
    echo "Benchmarking Signature: $alg"
    ${BENCHMARK_EXEC_DIR}/speed_sig --duration 1 "$alg" >> "$SIG_OUT_FILE" 2>&1
done
echo "Signature results saved to $SIG_OUT_FILE"
