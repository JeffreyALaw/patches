#!/bin/bash

set -e
set -o pipefail

# To facilitate debugging if there is a host side issue
#hostname

TARGET=$1
LOGFILE=`pwd`/log


NPROC=`nproc --all`
PATH=~/bin/:$PATH

PATH=/usr/lib/ccache:$PATH
ccache -M 100G


export GENERATION=2
echo $GENERATION

rm -rf ${TARGET}-obj
mkdir -p ${TARGET}-installed
mkdir -p ${TARGET}-obj/binutils
mkdir -p ${TARGET}-obj/gcc
mkdir -p ${TARGET}-obj/linux
mkdir -p ${TARGET}-obj/glibc

export RUNGCCTESTS=yes

patches/jobs/setupsources.sh ${TARGET} master binutils-gdb gcc glibc linux >& $LOGFILE 2>&1

# Step 1, build binutils
echo Building binutils
cd ${TARGET}-obj/binutils
../../binutils-gdb/configure --enable-warn-rwx-segments=no --enable-warn-execstack=no --prefix=`pwd`/../../${TARGET}-installed --target=${TARGET} >> $LOGFILE 2>&1
make -j $NPROC -l $NPROC all-gas all-binutils all-ld >> $LOGFILE 2>&1
make install-gas install-binutils install-ld >> $LOGFILE 2>&1
cd ../..
cd ${TARGET}-installed/bin
rm -f ar as ld ld.bfd nm objcopy objdump ranlib readelf strip
cd ../..

export SHARED=
if [ \! `find ${TARGET}-installed -name crti.o` ]; then
  SHARED=--disable-shared
fi

# Step 2, build gcc
echo Building GCC
PATH=`pwd`/${TARGET}-installed/bin:$PATH
cd ${TARGET}-obj/gcc
../../gcc/configure $SHARED --disable-analyzer --disable-multilib --without-headers --disable-threads --enable-languages=c,c++,fortran,lto --prefix=`pwd`/../../${TARGET}-installed --target=${TARGET} >> $LOGFILE 2>&1
make -j $NPROC -l $NPROC all-gcc >> $LOGFILE 2>&1
make install-gcc >> $LOGFILE 2>&1

# Step 2.1, build and install libgcc.  This is separate from the other libraries because
# it should always work.  Other libraries may not work the first time we build on a host
# because the target headers, crt files, etc from glibc are not yet available.
echo Building libgcc
make -j $NPROC -l $NPROC all-target-libgcc >> $LOGFILE 2>&1
make install-target-libgcc >> $LOGFILE 2>&1

# Step 2.2.  If it looks like we have crt files, then build libstdc++-v3
if [ -f ../../${TARGET}-installed/${TARGET}/lib/crt1.o ]; then
  echo Building libstdc++
  make -j $NPROC -l $NPROC all-target-libstdc++-v3 >> $LOGFILE 2>&1
  make install-target-libstdc++-v3 >> $LOGFILE 2>&1
fi

cd ../..


# Step 3, build kernel headers, kernel modules and kernel itself
export KERNEL_TARGETS="all modules"
export KERNEL=true
export CONFIG=defconfig
export STRIPKGDBCONFIG=no

case "${TARGET}" in
   
  arm*-* | arm*-*-* | arm*-*-*-*)
    export ARCH=arm
    ;;
    
  csky*-* | csky*-*-* | csky-*-*-*-*)
  	export ARCH=csky
    export KERNEL=false
    ;;

  loongarch*-* | loongarch*-*-* | loongarch*-*-*-*)
    export ARCH=loongarch
    export KERNEL=false
    ;;
   
  microblaze*-* | microblaze*-*-* | microblaze*-*-*-*)
    export ARCH=microblaze
    export STRIPKGDBCONFIG=yes
    ;;
    
  mips64-*-*)
    export ARCH=mips
    export CONFIG=64r1_defconfig
    ;;
    
  mips64el-*-*)
    export ARCH=mips
    export CONFIG=64r1el_defconfig
    ;;
    
  mips*-* | mips*-*-* | mips*-*-*-*)
    export ARCH=mips
    ;;
    
  nios*-* | nios*-*-* | nios*-*-*-*)
    export ARCH=nios2
    ;;

  or1k*-* | or1k*-*-* | or1k*-*-*-*)
    export ARCH=openrisc
    ;;
    
    
  powerpc*-* | powerpc*-*-* | powerpc*-*-*-*)
    export ARCH=powerpc
    CONFIG=pmac32_defconfig
    ;;
    
   
  s390*-* | s390*-*-* | s390*-*-*-*)
    export ARCH=s390
    ;;
    
  sh*-* | sh*-*-* | sh*-*-*-*)
    export ARCH=sh
    export KERNEL=false
    ;;
    
  riscv*-* | riscv*-*-* | riscv*-*-*-*)
    export ARCH=riscv
    ;;

  *)
    /bin/false
    ;;
esac

cd ${TARGET}-obj/linux
echo Building kernel
make -C ../../linux O=${TARGET} ARCH=${ARCH} INSTALL_HDR_PATH=../../${TARGET}-installed/${TARGET} headers_install >> $LOGFILE 2>&1

if [ $KERNEL == "true" ]; then
  make -C ../../linux O=${TARGET} ARCH=${ARCH} mrproper >> $LOGFILE 2>&1
  make -C ../../linux O=${TARGET} ARCH=${ARCH} CROSS_COMPILE=${TARGET}- -j $NPROC -l $NPROC $CONFIG >> $LOGFILE 2>&1
  if [ $STRIPKGDBCONFIG == "yes" ]; then
    sed -i -e s/CONFIG_KGDB=y/CONFIG_KGDB=n/ ../../linux/${TARGET}/.config
  fi
  make -C ../../linux O=${TARGET} ARCH=${ARCH} CROSS_COMPILE=${TARGET}- -j $NPROC -l $NPROC $KERNEL_TARGETS >> $LOGFILE 2>&1
fi

cd ../..



# Step 4, build glibc
echo Building glibc
cd ${TARGET}-obj/glibc
../../glibc/configure --prefix=`pwd`/../../${TARGET}-installed/${TARGET} --build=x86_64-linux-gnu --host=${TARGET} --enable-add-ons --disable-werror >> $LOGFILE 2>&1
make -j $NPROC -l $NPROC  >> $LOGFILE 2>&1
make install >> $LOGFILE 2>&1
cd ../..

# Step 5, run tests
echo Starting Testing
#cd ${TARGET}-obj/binutils
#make -k -j $NPROC -l $NPROC check-gas check-ld check-binutils || true
#cd ../..

# Step 5, conditionally run the GCC testsuite using the simulator
if [ x$DUMMY_SIM = "xyes" ]; then
  rm -f ${TARGET}-installed/bin/${TARGET}-run
  gcc -O2 patches/support/dummy.c -o ${TARGET}-installed/bin/${TARGET}-run
  cd ${TARGET}-obj/gcc/gcc
  make site.exp
  echo lappend boards_dir "`pwd`/../../../patches/support" >> site.exp
  cd ../../../
fi

cd ${TARGET}-obj/gcc/gcc

if [ x"$RUNGCCTESTS" = x"yes" ]; then
  make -k -j $NPROC -l $NPROC check-gcc RUNTESTFLAGS="$TESTARGS" >& check.log
fi

cd ../../..

patches/jobs/validate-results.sh $TARGET


