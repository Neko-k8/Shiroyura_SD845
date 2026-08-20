#!/bin/bash

# Set toolchain and build environment directories
export TC_DIR="/home/hakyura/toolchain"
export CROSS_COMPILE="${TC_DIR}/aarch64--glibc--stable-2025.08-1/bin/aarch64-buildroot-linux-gnu-"
export CC="${TC_DIR}/Clang-22/bin/clang"
export CLANG_TRIPLE=aarch64-linux-gnu-
export ARCH=arm64

# LLVM Utilities
export AR="${TC_DIR}/Clang-22/bin/llvm-ar"
export NM="${TC_DIR}/Clang-22/bin/llvm-nm"
export OBJCOPY="${TC_DIR}/Clang-22/bin/llvm-objcopy"
export OBJDUMP="${TC_DIR}/Clang-22/bin/llvm-objdump"
export STRIP="${TC_DIR}/Clang-22/bin/llvm-strip"
export OBJSIZE="${TC_DIR}/Clang-22/bin/llvm-size"
export LD="${TC_DIR}/Clang-22/bin/ld.lld"

export PATH="${TC_DIR}/Clang-22/bin:${TC_DIR}/aarch64--glibc--stable-2025.08-1/bin:${PATH}"

# Optimization flags for Snapdragon 845 (Kryo 385: Cortex-A75 + Cortex-A55 clusters)
export OPT_FLAGS="-O3 -march=armv8.2-a+crypto+dotprod+crc -mcpu=cortex-a75 -ffp-contract=fast -mllvm -enable-epilogue-vectorization -mllvm -polly -mllvm -enable-ml-inliner=release -mllvm -ml-inliner-model-selector=arm64-mixed -mllvm -regalloc-enable-advisor=release"

export KCFLAGS="-w ${OPT_FLAGS}"

JOBS=$(nproc)

echo "=========================================="
echo " Select Build Target Variant for OnePlus 6T"
echo "=========================================="
echo "1) High Performance Build (sdm845-perf_defconfig + enchilada.config)"
echo "2) Menuconfig (Customize configuration before building)"
echo "=========================================="
read -rp "Enter choice [1-2]: " BUILD_CHOICE

mkdir -p "$(pwd)/out"

export MAKE_FLAGS="ARCH=${ARCH} CC=${CC} LD=${LD} AR=${AR} NM=${NM} OBJCOPY=${OBJCOPY} OBJDUMP=${OBJDUMP} STRIP=${STRIP} CLANG_TRIPLE=${CLANG_TRIPLE} CROSS_COMPILE=${CROSS_COMPILE}"

case "${BUILD_CHOICE}" in
    1)
        echo "[+] Applying sdm845-perf_defconfig..."
        make -C "$(pwd)" O="$(pwd)/out" vendor/sdm845-perf_defconfig ${MAKE_FLAGS}
        echo "[+] Merging enchilada.config..."
        make -C "$(pwd)" O="$(pwd)/out" vendor/enchilada.config ${MAKE_FLAGS}
        ;;
    2)
        echo "[+] Applying base configurations..."
        make -C "$(pwd)" O="$(pwd)/out" vendor/sdm845-perf_defconfig ${MAKE_FLAGS}
        make -C "$(pwd)" O="$(pwd)/out" vendor/enchilada.config ${MAKE_FLAGS}
        echo "[+] Launching menuconfig..."
        make -C "$(pwd)" O="$(pwd)/out" menuconfig ${MAKE_FLAGS}
        ;;
    *)
        echo "[-] Invalid option selected. Exiting."
        exit 1
        ;;
esac

echo "[+] Starting kernel compilation using ${JOBS} CPU threads..."
make -C "$(pwd)" O="$(pwd)/out" -j"${JOBS}" ${MAKE_FLAGS}
