#!/bin/bash

set -e

VERSION=2.38

PREFIX=$( realpath . )

if [ -d Build-binutils ]; then
    echo "Directory 'Build-binutils' already exists. Remove if you want to rebuild."
    exit 1
fi

if [ -d "binutils-$VERSION" ]; then
    echo "Directory 'binutils-$VERSION' already exists. Remove if you want to rebuild."
    exit 1
fi

tar xvfJ binutils-$VERSION.tar.xz
mkdir Build-binutils
cd Build-binutils
../binutils-$VERSION/configure --target=i586-elf --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
make
make install

echo "Done"

