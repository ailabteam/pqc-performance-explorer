#!/bin/bash
# Ensure you are in the project root directory before running
# Prerequisite: conda activate pqc-research

echo "=== Building liboqs ==="
cd third_party/liboqs
# Clean previous builds if any
rm -rf build
mkdir build && cd build

cmake -GNinja -DOQS_USE_OPENSL=ON -DBUILD_SHARED_LIBS=ON ..

echo "--- Compiling ---"
ninja

echo "--- liboqs build finished in third_party/liboqs/build ---"
# We don't install it globally to keep the project self-contained
