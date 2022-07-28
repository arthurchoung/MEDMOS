#!/bin/bash

CC=../Toolchain/bin/i586-elf-gcc

if [ ! -d Objects ]; then
    mkdir Objects
fi

$CC -c libobjc/NXConstStr.m -o Objects/NXConstStr.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
$CC -c libobjc/Object.m -o Objects/Object.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
$CC -c libobjc/Protocol.m -o Objects/Protocol.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
$CC -c libobjc/accessors.m -o Objects/accessors.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
$CC -c libobjc/class.c -o Objects/class.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra -Iinclude
$CC -c libobjc/encoding.c -o Objects/encoding.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra -Iinclude
$CC -c libobjc/error.c -o Objects/error.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra -Iinclude
$CC -c libobjc/hash.c -o Objects/hash.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra -Iinclude
$CC -c libobjc/init.c -o Objects/init.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra -Iinclude
$CC -c libobjc/ivars.c -o Objects/ivars.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra -Iinclude
$CC -c libobjc/memory.c -o Objects/memory.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra -Iinclude
$CC -c libobjc/methods.c -o Objects/methods.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra -Iinclude
$CC -c libobjc/nil_method.c -o Objects/nil_method.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra -Iinclude
$CC -c libobjc/objc-foreach.c -o Objects/objc-foreach.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra -Iinclude
$CC -c libobjc/objects.c -o Objects/objects.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra -Iinclude
$CC -c libobjc/protocols.c -o Objects/protocols.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra -Iinclude
$CC -c libobjc/sarray.c -o Objects/sarray.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra -Iinclude
$CC -c libobjc/selector.c -o Objects/selector.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra -Iinclude
$CC -c libobjc/sendmsg.c -o Objects/sendmsg.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra -Iinclude
$CC -c libobjc/linking.m -o Objects/linking.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra -Iinclude -Ilibobjc
$CC -c libobjc/gc.c -o Objects/gc.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra -Iinclude -Ilibobjc

