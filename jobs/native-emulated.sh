#!/bin/bash -x
TARGET=$1
NPROC=`nproc --all`
PATH=/bin:$PATH

set -e
set -o pipefail

# To facilitate debugging if there is a host side issue
#hostname

patches/jobs/setupsources.sh $TARGET master binutils-gdb gcc glibc linux

rm -rf obj
mkdir -p obj/{binutils-gdb,gcc,glibc,linux}
export PREFIX=`pwd`/installed
PATH=`pwd`/installed/bin:/home/law/bin:$PATH

pushd obj/binutils-gdb
../../binutils-gdb/configure --enable-warn-rwx-segments=no --enable-warn-execstack=no --prefix=$PREFIX
make -j $NPROC -l $NPROC all-gas all-binutils all-ld 
make install-gas install-binutils install-ld
popd

pushd obj/gcc
../../gcc/configure --prefix=$PREFIX --disable-analyzer --prefix=$PREFIX --enable-languages=c,c++,fortran,lto --disable-multilib --disable-libsanitizer
make -j $NPROC -l $NPROC
make install
popd

if [ $target != sparc64-linux-gnu ]; then
  export KERNEL_TARGETS="all modules"
  pushd obj/linux
  make -C ../../linux O=`pwd` mrproper
  make -C ../../linux O=`pwd` -j $NPROC -l $NPROC defconfig
  make -C ../../linux O=`pwd` -j $NPROC -l $NPROC $KERNEL_TARGETS
  popd
fi

pushd obj/glibc
../../glibc/configure --disable-werror --prefix=$PREFIX --enable-add-ons
make -j $NPROC -l $NPROC
popd

# The binutils suite is run unconditionally
#pushd obj/binutils-gdb
#make -k -j $NPROC -l $NPROC check-gas check-ld check-binutils || true
#popd

# As is the GCC testsuite on native targets
pushd obj/gcc/gcc
make -k -j $NPROC -l $NPROC check || true
popd

patches/jobs/validate-results.sh $TARGET
