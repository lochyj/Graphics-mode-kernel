clear

echo "---- Removing old files ----"

rm -rf ./out/*
rm -rf ./out/image/*

mkdir ./out/image

echo "---- Building ASM ----"

# Compiling the asm code

nasm ./src/bootloader.asm -f bin -o ./out/bootloader.bin

echo "---- Compiling C ----"

# Compiling the C code

gcc -m32 -g -fno-pie -ffreestanding -fno-stack-protector -I . -c ./src/kernel.c -o ./out/kernel.out

echo "---- Linking output files ----"

ld -m elf_i386 -shared -fstack-protector -o ./out/kernel.bin -Ttext 0x9000 ./out/kernel.out --oformat binary 
# -e main -nostdlib

echo "---- Adding MBR bin to kernel bin ----" 

cat ./out/bootloader.bin ./out/kernel.bin > ./out/image/image.img

echo "---- Running in QEMU ----"

qemu-system-i386 -fda ./out/image/image.img
