#!/bin/bash

set -e

AS=../Toolchain/bin/i586-elf-as
CC=../Toolchain/bin/i586-elf-gcc

if [ ! -d Objects ]; then
    mkdir Objects
fi

$AS boot.s -o Objects/boot.o
$AS crti.s -o Objects/crti.o
$AS crtn.s -o Objects/crtn.o
$CC -c kernel.m -o Objects/kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra -Wno-unused-parameter -I../ObjectiveC/libobjc -I. -Iinclude -I../HOTDOG -I../HOTDOG/linux -I../HOTDOG/lib -I../HOTDOG/objects  -DBUILD_FOR_MEDMOS -DBUILD_FOUNDATION -DBUILD_WITH_BGRA_PIXEL_FORMAT -fconstant-string-class=NSConstantString

echo "Done"

