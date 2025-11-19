#!/bin/bash
# Script tối giản để test biên dịch một file C với liboqs

# --- Các biến cần thiết ---
# Thư mục gốc của dự án (giả định script được chạy từ gốc)
PROJECT_ROOT=$(pwd)

# Thư mục của liboqs
LIBOQS_DIR="${PROJECT_ROOT}/third_party/liboqs"

# --- Lệnh biên dịch ---
echo "--- Attempting to compile print_sizes.c ---"

# In ra các đường dẫn để gỡ lỗi
echo "Using Include Path (-I): ${LIBOQS_DIR}/build/include"
echo "Using Library Path (-L): ${LIBOQS_DIR}/build/lib"
echo "Source file:           ${PROJECT_ROOT}/utils/print_sizes.c"
echo "Output file:           ${PROJECT_ROOT}/build/print_sizes"
echo ""

# Xóa file thực thi cũ nếu có để đảm bảo build mới
rm -f "${PROJECT_ROOT}/build/print_sizes"

# Lệnh gcc với cờ -v để xem chi tiết các đường dẫn mà nó tìm kiếm
gcc -v \
    -I "${LIBOQS_DIR}/build/include" \
    -L "${LIBOQS_DIR}/build/lib" \
    -L "$CONDA_PREFIX/lib" \
    "${PROJECT_ROOT}/utils/print_sizes.c" \
    -o "${PROJECT_ROOT}/build/print_sizes" \
    -loqs -lcrypto

# --- Kiểm tra kết quả ---
if [ $? -eq 0 ]; then
    echo ""
    echo "--- COMPILE SUCCEEDED ---"
    echo "Running test:"
    "${PROJECT_ROOT}/build/print_sizes" kem Kyber512
else
    echo ""
    echo "--- COMPILE FAILED ---"
fi
