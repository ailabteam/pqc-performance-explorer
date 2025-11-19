#!/bin/bash
# Script để thu thập dữ liệu kích thước từ công cụ print_sizes
# và lưu chúng vào file CSV.
# Run from the project root directory.

# --- Cấu hình (giống hệt script benchmark) ---
KEM_ALGS_TO_TEST=(
    "Kyber512" "Kyber768" "Kyber1024"
    "Classic-McEliece-348864" "HQC-128"
)

SIG_ALGS_TO_TEST=(
    "Dilithium2" "Dilithium3" "Dilithium5"
    "Falcon-512" "Falcon-1024" "SPHINCS+-SHA2-128f-simple"
)
# -----------------

# Đường dẫn
RESULTS_DIR="results"
PRINT_SIZES_EXEC="build/print_sizes"

# Kiểm tra công cụ
if [ ! -f "${PRINT_SIZES_EXEC}" ]; then
    echo "Error: ${PRINT_SIZES_EXEC} not found. Please run setup/build_liboqs.sh first."
    exit 1
fi

# --- Thu thập kích thước KEM ---
KEM_SIZE_FILE="${RESULTS_DIR}/kem_sizes.csv"
echo "Collecting KEM sizes -> ${KEM_SIZE_FILE}"

# Tạo header cho file CSV
echo "algorithm,public_key_bytes,secret_key_bytes,ciphertext_bytes" > "$KEM_SIZE_FILE"

# Lặp qua các thuật toán và gọi công cụ
for alg in "${KEM_ALGS_TO_TEST[@]}"; do
    "${PRINT_SIZES_EXEC}" kem "$alg" >> "$KEM_SIZE_FILE"
done

# --- Thu thập kích thước Signature ---
SIG_SIZE_FILE="${RESULTS_DIR}/sig_sizes.csv"
echo "Collecting Signature sizes -> ${SIG_SIZE_FILE}"

# Tạo header
echo "algorithm,public_key_bytes,secret_key_bytes,signature_bytes" > "$SIG_SIZE_FILE"

for alg in "${SIG_ALGS_TO_TEST[@]}"; do
    "${PRINT_SIZES_EXEC}" sig "$alg" >> "$SIG_SIZE_FILE"
done

echo "Size collection complete."
