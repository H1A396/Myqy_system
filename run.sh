#!/bin/bash

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$PROJECT_DIR/src"
BUILD_DIR="$PROJECT_DIR/build"
ISO_DIR="$PROJECT_DIR/iso"

LINKER_LD="$SRC_DIR/linker.ld"
KERNEL_BIN="$BUILD_DIR/kernel.bin"
ISO_FILE="$BUILD_DIR/myos.iso"

echo "========================================="
echo "  操作系统构建脚本（IDT + 异常处理）"
echo "========================================="

mkdir -p "$BUILD_DIR"

FILES=(
    "boot.asm"
    "isr.asm"
    "kernel.c"
    "idt.c"
    "pic.c"
    "vga.c"
)

echo ""
echo "[1/3] 编译源文件..."

for f in "${FILES[@]}"; do
    ext="${f##*.}"
    base="${f%.*}"
    out="$BUILD_DIR/${base}.o"

    if [ "$ext" = "asm" ]; then
        echo "  编译 $f..."
        nasm -f elf32 "$SRC_DIR/$f" -o "$out"
    elif [ "$ext" = "c" ]; then
        echo "  编译 $f..."
        gcc -m32 -ffreestanding -fno-pie -fno-stack-protector -c "$SRC_DIR/$f" -o "$out" -Wall -Wextra
    fi

    if [ $? -ne 0 ]; then
        echo "错误：编译 $f 失败！"
        exit 1
    fi
done

echo "✓ 所有源文件编译成功"

echo ""
echo "[2/3] 链接生成内核..."

OBJS=""
for f in "${FILES[@]}"; do
    base="${f%.*}"
    OBJS="$OBJS $BUILD_DIR/${base}.o"
done

ld -m elf_i386 -T "$LINKER_LD" $OBJS -o "$KERNEL_BIN"

if [ $? -ne 0 ]; then
    echo "错误：链接失败！"
    exit 1
fi
echo "✓ 内核链接成功：$KERNEL_BIN"

echo ""
echo "[3/3] 生成 ISO 镜像..."
mkdir -p "$ISO_DIR/boot/grub"

cp "$KERNEL_BIN" "$ISO_DIR/boot/kernel.bin"

grub-mkrescue -o "$ISO_FILE" "$ISO_DIR"

if [ $? -ne 0 ]; then
    echo "错误：ISO 生成失败！"
    exit 1
fi
echo "✓ ISO 生成成功：$ISO_FILE"

echo ""
echo "启动 QEMU..."
qemu-system-x86_64 \
    -cdrom "$ISO_FILE" \
    -boot d \
    -m 64M \
    -name "MyOS"

echo ""
echo "========================================="
echo "  QEMU 已退出"
echo "========================================="
