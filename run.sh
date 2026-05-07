#!/bin/bash

# 项目路径
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$PROJECT_DIR/src"
BUILD_DIR="$PROJECT_DIR/build"
ISO_DIR="$PROJECT_DIR/iso"

# 文件名
BOOT_ASM="$SRC_DIR/boot.asm"
KERNEL_C="$SRC_DIR/kernel.c"
LINKER_LD="$SRC_DIR/linker.ld"
KERNEL_BIN="$BUILD_DIR/kernel.bin"
ISO_FILE="$BUILD_DIR/myos.iso"

echo "========================================="
echo "  操作系统构建脚本（GRUB + C语言）"
echo "========================================="

mkdir -p "$BUILD_DIR"

# 1. 编译汇编代码
echo ""
echo "[1/4] 编译 boot.asm..."
nasm -f elf32 "$BOOT_ASM" -o "$BUILD_DIR/boot.o"

if [ $? -ne 0 ]; then
    echo "错误：汇编编译失败！"
    exit 1
fi
echo "✓ boot.asm 编译成功"

# 2. 编译C代码
echo ""
echo "[2/4] 编译 kernel.c..."
gcc -m32 -ffreestanding -fno-pie -fno-stack-protector -c "$KERNEL_C" -o "$BUILD_DIR/kernel.o" -Wall -Wextra

if [ $? -ne 0 ]; then
    echo "错误：C编译失败！"
    exit 1
fi
echo "✓ kernel.c 编译成功"

# 3. 链接生成内核
echo ""
echo "[3/4] 链接生成内核..."
ld -m elf_i386 -T "$LINKER_LD" "$BUILD_DIR/boot.o" "$BUILD_DIR/kernel.o" -o "$KERNEL_BIN"

if [ $? -ne 0 ]; then
    echo "错误：链接失败！"
    exit 1
fi
echo "✓ 内核链接成功：$KERNEL_BIN"

# 4. 生成 ISO 镜像并启动
echo ""
echo "[4/4] 生成 ISO 镜像..."
mkdir -p "$ISO_DIR/boot/grub"
mkdir -p "$ISO_DIR/boot"

cp "$KERNEL_BIN" "$ISO_DIR/boot/kernel.bin"

grub-mkrescue -o "$ISO_FILE" "$ISO_DIR"

if [ $? -ne 0 ]; then
    echo "错误：ISO 生成失败！"
    exit 1
fi
echo "✓ ISO 生成成功：$ISO_FILE"

# 启动 QEMU
echo ""
echo "启动 QEMU（GRUB引导）..."
qemu-system-x86_64 \
    -cdrom "$ISO_FILE" \
    -boot d \
    -m 64M \
    -name "MyOS"

echo ""
echo "========================================="
echo "  QEMU 已退出"
echo "========================================="