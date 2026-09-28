#!/bin/bash

export TC_DIR="/home/shiroyura/toolchain"
export CC="${TC_DIR}/neutron-clang-06092026/bin/clang"
export CLANG_TRIPLE=aarch64-linux-gnu-
export ARCH=arm64

export CROSS_COMPILE=aarch64-linux-gnu-

export AR="${TC_DIR}/neutron-clang-06092026/bin/llvm-ar"
export NM="${TC_DIR}/neutron-clang-06092026/bin/llvm-nm"
export OBJCOPY="${TC_DIR}/neutron-clang-06092026/bin/llvm-objcopy"
export OBJDUMP="${TC_DIR}/neutron-clang-06092026/bin/llvm-objdump"
export STRIP="${TC_DIR}/neutron-clang-06092026/bin/llvm-strip"
export OBJSIZE="${TC_DIR}/neutron-clang-06092026/bin/llvm-size"
export LD="${TC_DIR}/neutron-clang-06092026/bin/ld.lld"

export PATH="${TC_DIR}/neutron-clang-06092026/bin:${PATH}"

export LLVM=1
export LLVM_IAS=1

export OPT_FLAGS="-O3 -mcpu=cortex-a75+crypto+crc -ffp-contract=fast -mllvm -enable-epilogue-vectorization -mllvm -polly"

export KCFLAGS="-w ${OPT_FLAGS}"

JOBS=$(nproc)

mkdir -p "$(pwd)/out"

export MAKE_FLAGS="ARCH=${ARCH} LLVM=1 LLVM_IAS=1 CC=${CC} LD=${LD} AR=${AR} NM=${NM} OBJCOPY=${OBJCOPY} OBJDUMP=${OBJDUMP} STRIP=${STRIP} CLANG_TRIPLE=${CLANG_TRIPLE} CROSS_COMPILE=${CROSS_COMPILE}"

VENDOR_CFG_DIR="$(pwd)/arch/arm64/configs/vendor"

echo "[+] Initializing base config: vendor/sdm845-perf_defconfig..."
make -C "$(pwd)" O="$(pwd)/out" vendor/sdm845-perf_defconfig ${MAKE_FLAGS}

echo "[+] Merging vendor/enchilada.config..."
ARCH=${ARCH} LLVM=1 LLVM_IAS=1 CC=${CC} LD=${LD} "$(pwd)/scripts/kconfig/merge_config.sh" -O "$(pwd)/out" "$(pwd)/out/.config" "${VENDOR_CFG_DIR}/enchilada.config"

echo "[+] Validating and generating final .config..."
make -C "$(pwd)" O="$(pwd)/out" olddefconfig ${MAKE_FLAGS}

echo "[+] Starting build process with ${JOBS} CPU threads..."
make -C "$(pwd)" O="$(pwd)/out" -j"${JOBS}" ${MAKE_FLAGS}

