#!/bin/bash
# Script to run the built-in benchmarks from liboqs and save the results.
# Run from the project root directory.

RESULTS_DIR="results/raw_oqs_benchmarks"
BENCHMARK_EXEC_DIR="third_party/liboqs/build/tests"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

mkdir -p "${RESULTS_DIR}"

echo "--- Running KEM speed test ---"
${BENCHMARK_EXEC_DIR}/speed_kem > "${RESULTS_DIR}/kem_benchmark_${TIMESTAMP}.txt"
echo "KEM results saved to ${RESULTS_DIR}/kem_benchmark_${TIMESTAMP}.txt"

echo "--- Running Signature speed test ---"
${BENCHMARK_EXEC_DIR}/speed_sig > "${RESULTS_DIR}/sig_benchmark_${TIMESTAMP}.txt"
echo "Signature results saved to ${RESULTS_DIR}/sig_benchmark_${TIMESTAMP}.txt"
