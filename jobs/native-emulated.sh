#!/bin/bash
NPROC=`nproc --all`
PATH=/bin:$PATH

set -e
set -o pipefail

# The target is mandatory.  The branch is not.  If no branch is
# specified, then use master.
TARGET=$1
shift
BRANCH=$1

if [ "$BRANCH" == "" ]; then
  BRANCH=master
fi

patches/jobs/setupsources.sh $TARGET $BRANCH binutils-gdb gcc glibc linux

rm -rf obj
mkdir -p obj/{binutils-gdb,gcc,glibc,linux}
export PREFIX=`pwd`/installed
PATH=`pwd`/installed/bin:/home/law/bin:$PATH

if [ $TARGET != alpha-linux-gnu ]; then
  pushd obj/binutils-gdb
  ../../binutils-gdb/configure --enable-warn-rwx-segments=no --enable-warn-execstack=no --disable-werror --prefix=$PREFIX ${TARGET}
  make -j $NPROC -l $NPROC all-gas all-binutils all-ld 
  make install-gas install-binutils install-ld
  popd
fi

if [ $TARGET == riscv64-linux-gnu ]; then
  DISABLE_BOOTSTRAP=--disable-bootstrap
fi

pushd obj/gcc
../../gcc/configure --prefix=$PREFIX --disable-analyzer --prefix=$PREFIX --enable-languages=c,c++,fortran,lto --disable-multilib --disable-libsanitizer $DISABLE_BOOTSTRAP ${TARGET}
make -j $NPROC -l $NPROC
make install
popd

case ${TARGET} in
  ppc64le-*-*)
    ;;
  mips64el-*-*)
    ;;
  *)
    export KERNEL_TARGETS="all modules"
    pushd obj/linux
#    make -C ../../linux O=`pwd` mrproper
#    make -C ../../linux O=`pwd` -j $NPROC -l $NPROC defconfig
#    make -C ../../linux O=`pwd` -j $NPROC -l $NPROC $KERNEL_TARGETS
    popd
    ;;
esac

pushd obj/glibc
../../glibc/configure --disable-werror --prefix=$PREFIX --enable-add-ons ${TARGET}
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
