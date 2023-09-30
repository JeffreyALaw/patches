#!/bin/bash

# If any command fails, exit immediately
set -e
set -o pipefail

TARGET=$1
LOGFILE=`pwd`/log

NPROC=`nproc --all`

rm -rf ${TARGET}-obj
rm -rf ${TARGET}-installed
mkdir -p ${TARGET}-installed
mkdir -p ${TARGET}-obj/binutils
mkdir -p ${TARGET}-obj/gcc

# We only need the binutils-gdb and gcc trees
patches/jobs/setupsources.sh $TARGET master binutils-gdb gcc

# Step 1, build binutils
cd ${TARGET}-obj/binutils
../../binutils-gdb/configure --prefix=`pwd`/../../${TARGET}-installed --target=${TARGET} >& $LOGFILE
make -j $NPROC -l $NPROC all-gas all-binutils all-ld >& $LOGFILE
make install-gas install-binutils install-ld >& $LOGFILE
cd ../..
cd ${TARGET}-installed/bin
rm -f ar as ld ld.bfd nm objcopy objdump ranlib readelf strip
cd ../..

# Step 2, build gcc
PATH=`pwd`/${TARGET}-installed/bin:$PATH
cd ${TARGET}-obj/gcc
../../gcc/configure --disable-analyzer --with-system-libunwind --with-newlib --without-headers --disable-threads --disable-shared --enable-languages=c,c++,lto --prefix=`pwd`/../../${TARGET}-installed --target=${TARGET} >& $LOGFILE
make -j $NPROC -l $NPROC all-gcc >& $LOGFILE
make install-gcc >& $LOGFILE

# We try to build and install libgcc, but don't consider a failure fatal
(make -j $NPROC -l $NPROC all-target-libgcc && make install-target-libgcc) || /bin/true
cd ../..

# The binutils suite is run unconditionally
cd ${TARGET}-obj/binutils
make -k -j $NPROC -l $NPROC check-gas check-ld check-binutils || true
cd ../..

gzip --best $LOGFILE

#patches/jobs/validate-results.sh $TARGET
