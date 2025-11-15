#!/bin/bash
# Prerequisite: conda activate pqc-research

echo "=== Building liboqs v0.10.0 using Conda's self-contained OpenSSL ==="
cd third_party/liboqs

# Clean previous builds to ensure a fresh, correct configuration
rm -rf build
mkdir build && cd build

# Configure CMake to explicitly use Conda's OpenSSL, not the system's.
# The OPENSSL_ROOT_DIR variable forces cmake to look only in our environment.
cmake -GNinja \
      -DOPENSSL_ROOT_DIR=$CONDA_PREFIX \
      -DOQS_USE_OPENSSL=ON \
      -DBUILD_SHARED_LIBS=ON \
      -DOQS_DIST_BUILD=ON \
      ..

echo "--- Compiling ---"
ninja

echo "--- liboqs build finished in third_party/liboqs/build ---"
