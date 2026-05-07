#!/bin/bash

# 项目路径
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$PROJECT_DIR/src"
BUILD_DIR="$PROJECT_DIR/build"
ISO_DIR="$PROJECT_DIR/iso"

# 文件名
KERNEL_ASM="$SRC_DIR/kernel.asm"
LINKER_LD="$SRC_DIR/linker.ld"
KERNEL_BIN="$BUILD_DIR/kernel.bin"
ISO_FILE="$BUILD_DIR/myos.iso"

echo "========================================="
echo "  操作系统构建脚本（GRUB引导）"
echo "========================================="

# 1. 编译内核代码
echo ""
echo "[1/3] 编译 kernel.asm..."
nasm -f elf32 "$KERNEL_ASM" -o "$BUILD_DIR/kernel.o"
ld -m elf_i386 -T "$LINKER_LD" "$BUILD_DIR/kernel.o" -o "$KERNEL_BIN"

if [ $? -ne 0 ]; then
    echo "错误：编译失败！"
    exit 1
fi
echo "✓ 编译成功：$KERNEL_BIN"

# 2. 生成 ISO 镜像
echo ""
echo "[2/3] 生成 ISO 镜像..."
mkdir -p "$ISO_DIR/boot/grub"
mkdir -p "$ISO_DIR/boot"

# 复制内核到 ISO 目录
cp "$KERNEL_BIN" "$ISO_DIR/boot/kernel.bin"

# 使用 grub-mkrescue 创建 GRUB 可启动 ISO
grub-mkrescue -o "$ISO_FILE" "$ISO_DIR"

if [ $? -ne 0 ]; then
    echo "错误：ISO 生成失败！"
    exit 1
fi
echo "✓ ISO 生成成功：$ISO_FILE"

# 3. 启动 QEMU
echo ""
echo "[3/3] 启动 QEMU（GRUB引导）..."
qemu-system-x86_64 \
    -cdrom "$ISO_FILE" \
    -boot d \
    -m 64M \
    -name "MyOS"

echo ""
echo "========================================="
echo "  QEMU 已退出"
echo "========================================="
