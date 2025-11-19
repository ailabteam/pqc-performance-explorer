#!/bin/bash
# Script to build the liboqs library inside the Conda environment.
# Run from the project root directory.

# =========================================================
# === BƯỚC 1: THÊM DÒNG NÀY VÀO ĐẦU FILE ===
# =========================================================
PROJECT_ROOT=$(pwd)


# --- Build liboqs ---
LIBOQS_DIR="third_party/liboqs"
BUILD_DIR="${LIBOQS_DIR}/build"

# Check if Conda environment is active
if [ -z "$CONDA_PREFIX" ]; then
    echo "Error: Conda environment 'pqc-research' is not activated."
    exit 1
fi

echo "=== Building liboqs v0.10.0 using Conda's self-contained OpenSSL ==="
cd "${LIBOQS_DIR}"

# Clean previous build artifacts
rm -rf build

# Configure the build using CMake
cmake -B build -S . \
    -DOQS_DIST_BUILD=ON \
    -DOQS_OPT_TARGET=generic \
    -DCMAKE_INSTALL_PREFIX="$CONDA_PREFIX" \
    -DOPENSSL_ROOT_DIR="$CONDA_PREFIX"

# Check if configuration was successful
if [ $? -ne 0 ]; then
    echo "Error: CMake configuration failed."
    cd "${PROJECT_ROOT}" # Quay lại thư mục gốc trước khi thoát
    exit 1
fi

# Build the library
echo "--- Compiling ---"
cmake --build build --parallel $(nproc)

if [ $? -ne 0 ]; then
    echo "Error: liboqs compilation failed."
    cd "${PROJECT_ROOT}" # Quay lại thư mục gốc trước khi thoát
    exit 1
fi

echo "--- liboqs build finished in ${BUILD_DIR} ---"


# ================================================================
# === BƯỚC 2: SỬA LẠI HOÀN TOÀN ĐOẠN CODE TÙY CHỈNH Ở CUỐI FILE ===
# ================================================================

# --- Biên dịch các công cụ tiện ích tùy chỉnh ---
# --- Biên dịch các công cụ tiện ích tùy chỉnh ---
echo ""
echo "--- Compiling custom project utilities ---"

# Quay trở lại thư mục gốc của dự án để đảm bảo đường dẫn đúng
cd "${PROJECT_ROOT}"

# Tạo thư mục build ở gốc dự án nếu chưa có
mkdir -p build

# Biên dịch công cụ print_sizes
if [ -f "utils/print_sizes.c" ]; then
    echo "Compiling utils/print_sizes.c..."
    
    # Lệnh biên dịch đã được kiểm chứng
    gcc utils/print_sizes.c \
        -I "${LIBOQS_DIR}/build/include" \
        -L "${LIBOQS_DIR}/build/lib" \
        -L "$CONDA_PREFIX/lib" \
        -o build/print_sizes \
        -loqs -lcrypto
    
    # Kiểm tra xem biên dịch có thành công không
    if [ $? -eq 0 ]; then
        echo "Successfully compiled => build/print_sizes"
    else
        echo "Error: Failed to compile utils/print_sizes.c. Aborting."
        exit 1
    fi
else
    echo "Warning: utils/print_sizes.c not found. Skipping compilation."
fi
