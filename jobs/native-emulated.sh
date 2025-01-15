#!/bin/bash
NPROC=`nproc --all`
PATH=/bin:$PATH

set -e
set -o pipefail

# The target is mandatory.  The branch is not.  If no branch is
# specified, then use master.
TARGET=$1
LOGFILE=`pwd`/log
shift
BRANCH=$1

if [ "$BRANCH" == "" ]; then
  BRANCH=master
fi

patches/jobs/setupsources.sh $TARGET $BRANCH binutils-gdb gcc glibc linux > $LOGFILE 2>&1

rm -rf obj
mkdir -p obj/{binutils-gdb,gcc,glibc,linux}
export PREFIX=`pwd`/installed
PATH=`pwd`/installed/bin:/home/law/bin:$PATH

echo Building binutils
date
pushd obj/binutils-gdb
../../binutils-gdb/configure --enable-warn-rwx-segments=no --enable-warn-execstack=no --disable-werror --prefix=$PREFIX ${TARGET} >> $LOGFILE 2>&1
make -j $NPROC -l $NPROC all-gas all-binutils all-ld  >> $LOGFILE 2>&1
make install-gas install-binutils install-ld >> $LOGFILE 2>&1
popd

# MIPS is always multiarch
if [ $TARGET == mips64el-linux-gnuabi64 ]; then
  ENABLE_MULTIARCH=--enable-multiarch
fi

if [ $TARGET == mipsel-linux-gnu ]; then
  ENABLE_MULTIARCH=--enable-multiarch
fi

# Abusing ENABLE_MULTIARCH...
#if [ $TARGET == riscv64-linux-gnu ]; then
#  ENABLE_MULTIARCH=--with-arch=rv64gcv_zba_zbb_zbs_zicond
#fi

echo Building GCC
date
pushd obj/gcc
../../gcc/configure --prefix=$PREFIX --disable-analyzer --prefix=$PREFIX --enable-languages=c,c++,fortran,lto $ENABLE_MULTIARCH --disable-multilib --disable-libsanitizer $DISABLE_BOOTSTRAP ${TARGET} >> $LOGFILE 2>&1
#make -j $NPROC -l $NPROC >> $LOGFILE 2>&1
#make install >> $LOGFILE 2>&1
make -j $NPROC -l $NPROC >> $LOGFILE
make install >> $LOGFILE
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

echo Building glibc
date
pushd obj/glibc
../../glibc/configure --disable-werror --prefix=$PREFIX --enable-add-ons ${TARGET} >> $LOGFILE 2>&1
make -j $NPROC -l $NPROC >> $LOGFILE 2>&1
popd

# The binutils suite is run unconditionally
#pushd obj/binutils-gdb
#make -k -j $NPROC -l $NPROC check-gas check-ld check-binutils || true
#popd

# As is the GCC testsuite on native targets
echo Testing GCC
date
pushd obj/gcc/gcc
make -k -j $NPROC -l $NPROC check >& check.log || true 
popd

echo DONE
date
patches/jobs/validate-results.sh $TARGET
