#!/usr/bin/env bash
set -euo pipefail

COE_DIR="RTL"
ASS_DIR="assembling"

# Args (can be overridden on CLI)
LD=${1:-linker.ld}
I_COE=${2:-instructions.coe}
D_COE=${3:-data_init.coe}

# Output ELF
ELF="program.elf"

# Toolchain settings
ARCH=rv32imf
ABI=ilp32
CC=riscv32-unknown-elf-gcc
OBJCOPY=riscv32-unknown-elf-objcopy

echo "→ Collecting sources in ${ASS_DIR}"
mapfile -t SRC_LIST < <(find -maxdepth 1 \( -name '*.c' -o -name '*.s' \) | sort)
if [ ${#SRC_LIST[@]} -eq 0 ]; then
  echo -e "\033[31mNo sources (.c/.s) found in ${ASS_DIR}\033[0m" >&2
  exit 1
fi

# Common flags
CFLAGS="-O2 -ffreestanding -fno-pic -fno-builtin -march=${ARCH} -mabi=${ABI} -Wall -Wextra -ffunction-sections -fdata-sections"
LDFLAGS="-nostdlib -Wl,--no-relax -T ${LD} -march=${ARCH} -mabi=${ABI}"

OBJ_LIST=()
for src in "${SRC_LIST[@]}"; do
  obj="${src%.*}.o"
  echo "   CC ${src} -> ${obj}"
  ${CC} ${CFLAGS} -c "${src}" -o "${obj}"
  OBJ_LIST+=("${obj}")
done

echo "→ Linking -> ${ASS_DIR}/${ELF}"
${CC} ${LDFLAGS} "${OBJ_LIST[@]}" -o "${ELF}" -lc -lm -lnosys

echo "→ Extracting sections into raw binaries"
# Instruction memory: include .init, .text, .rodata (if you keep consts in ROM)
${OBJCOPY} -O binary \
  --only-section .init \
  --only-section .text* \
  "${ELF}" "text.bin"

# Data memory: include .data, .sdata
${OBJCOPY} -O binary \
  --only-section .data* \
  --only-section .sdata* \
  --only-section .bss* \
  --only-section .rodata* \
  --only-section .srodata* \
  --only-section .stack* \
  "${ELF}" "data.bin"
  
cd ..

echo "→ Converting binaries to COE format"
# Instructions COE
{
  echo "memory_initialization_radix=16;"
  echo "memory_initialization_vector="
  xxd -p -c4 "${ASS_DIR}/text.bin" \
    | sed -E 's/^([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})$/\4\3\2\1/' \
    | sed 's/$/,/' \
    | sed '$ s/,$/;/'
} > "${I_COE}"

# Data COE
{
  echo "memory_initialization_radix=16;"
  echo "memory_initialization_vector="
  xxd -p -c4 "${ASS_DIR}/data.bin" \
    | sed -E 's/^([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})$/\4\3\2\1/' \
    | sed 's/$/,/' \
    | sed '$ s/,$/;/' 
} > "${D_COE}"

echo -e "→ \033[1;32m Successfully modified COE files.\033[0m"
echo "   - ${COE_DIR}/${I_COE} (instructions)"
echo "   - ${COE_DIR}/${D_COE} (initialized data)"
echo -e "\033[33mWARNING: Remember to regenerate the BRAM IP in Vivado with the new COEs.\033[0m" >&2
