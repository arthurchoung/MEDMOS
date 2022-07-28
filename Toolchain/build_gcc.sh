#!/bin/bash

set -e

VERSION=11.3.0

PREFIX=$( realpath . )

PATH="$PATH:$PREFIX"

if [ -d Build-gcc ]; then
    echo "Directory 'Build-gcc' already exists. Remove if you want to rebuild."
    exit 1
fi

if [ -d "gcc-$VERSION" ]; then
    echo "Directory 'gcc-$VERSION' already exists. Remove if you want to rebuild."
    exit 1
fi

tar xvfJ gcc-$VERSION.tar.xz
mkdir Build-gcc
cd Build-gcc
../gcc-*/configure --target=i586-elf --prefix="$PREFIX" --disable-nls --enable-languages=c,objc --without-headers
make all-gcc
make all-target-libgcc
make install-gcc
make install-target-libgcc

echo "Done"

