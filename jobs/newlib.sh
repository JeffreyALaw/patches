#!/bin/bash

# Ensure that we fail if any command fails
set -e
set -o pipefail

TARGET=$1
LOGFILE=`pwd`/log

NPROC=`nproc --all`

export GENERATION=2
echo $GENERATION

SRCDIR=../../

rm -rf ${TARGET}-obj
rm -rf ${TARGET}-installed
mkdir -p ${TARGET}-installed
mkdir -p ${TARGET}-obj/binutils
mkdir -p ${TARGET}-obj/gcc
mkdir -p ${TARGET}-obj/newlib

# Some targets have a simulator we can use for testing GCC.
export TESTARGS=none
export RUNGCCTESTS=no
export SIMTARG=
export SIMINSTALLTARG=
export DUMMY_SIM=no
export BUILDLIBSTDCXX=yes
export TESTCXX=check-g++

case "${TARGET}" in
  arc*-*)
    RUNGCCTESTS=yes
    DUMMY_SIM=yes
    SIMTARG=
    SIMINSTALLTARG=
    TESTARGS="--target_board=arc-sim"
    ;;
  avr*-*)
    RUNGCCTESTS=yes
    DUMMY_SIM=yes
    SIMTARG=
    SIMINSTALLTARG=
    TESTARGS="--target_board=arc-sim"
    ;;
  bfin*-*)
    RUNGCCTESTS=yes
    SIMTARG=all-sim
    SIMINSTALLTARG=install-sim
    TESTARGS="--target_board=bfin-sim"
    ;;
  c6x*-*)
    RUNGCCTESTS=yes
    DUMMY_SIM=yes
    SIMTARG=
    SIMINSTALLTARG=
    TESTARGS="--target_board=c6x-sim"
    ;;
  cr16*-*)
    RUNGCCTESTS=yes
    DUMMY_SIM=yes
    SIMTARG=
    SIMINSTALLTARG=
    TESTARGS="--target_board=cr16-sim"
    ;;
  cris*-*)
    RUNGCCTESTS=yes
    SIMTARG=all-sim
    SIMINSTALLTARG=install-sim
    TESTARGS="--target_board=cris-sim"
    ;;
  epiphany*-*)
    # The epiphany port is terribly broken with reload failures depending on
    # register assignments.  This causes tests to oscillate between PASS/FAIL
    # status fairly randomly which causes spurious regression failures
    # Until the port is fixed, just avoid the GCC tests to avoid the silly amount
    # of noise here.
    RUNGCCTESTS=no
    DUMMY_SIM=yes
    SIMTARG=
    SIMINSTALLTARG=
    TESTARGS="--target_board=epiphany-sim"
    ;;
  fr30*-*)
    RUNGCCTESTS=yes
    DUMMY_SIM=yes
    SIMTARG=
    SIMINSTALLTARG=
    TESTARGS="--target_board=fr30-sim"
    ;;
  frv*-*)
    RUNGCCTESTS=yes
    SIMTARG=all-sim
    SIMINSTALLTARG=install-sim
    TESTARGS="--target_board=frv-sim"
    ;;
  ft32*-*)
    RUNGCCTESTS=yes
    DUMMY_SIM=yes
    SIMTARG=
    SIMINSTALLTARG=
    BUILDLIBSTDCXX=no
    TESTCXX=
    TESTARGS="--target_board=ft32-sim"
    ;;
  h8300*-*)
    RUNGCCTESTS=yes
    SIMTARG=all-sim
    SIMINSTALLTARG=install-sim
    BUILDLIBSTDCXX=no
    TESTCXX=
    TESTARGS="--target_board=h8300-sim\{-mh/-mint32,-ms/-mint32,-msx/-mint32\}"
	;;
  iq2000*-*)
    RUNGCCTESTS=yes
    SIMTARG=all-sim
    SIMINSTALLTARG=install-sim
    TESTARGS="--target_board=iq2000-sim"
    ;;
  lm32*-*)
    RUNGCCTESTS=yes
    DUMMY_SIM=yes
    SIMTARG=
    SIMINSTALLTARG=
    TESTARGS="--target_board=lm32-sim"
    ;;
  m32r*-*)
    RUNGCCTESTS=yes
    SIMTARG=all-sim
    SIMINSTALLTARG=install-sim
    TESTARGS="--target_board=m32r-sim"
    ;;
  mcore*-*)
    RUNGCCTESTS=yes
    SIMTARG=all-sim
    SIMINSTALLTARG=install-sim
    TESTARGS="--target_board=mcore-sim"
    ;;
  mn10300*-*)
    RUNGCCTESTS=yes
    SIMTARG=all-sim
    SIMINSTALLTARG=install-sim
    TESTARGS="--target_board=mn10300-sim"
    ;;
  moxie*-*)
    RUNGCCTESTS=yes
    SIMTARG=all-sim
    SIMINSTALLTARG=install-sim
    TESTARGS="--target_board=moxie-sim"
    ;;
  msp430*-*)
    RUNGCCTESTS=yes
    SIMTARG=all-sim
    SIMINSTALLTARG=install-sim
    # Turn off multilib testing for now
    TESTARGS="--target_board=msp430-sim\{,-mcpu=msp430,-mlarge/-mcode-region=either,-mlarge/-mdata-region=either/-mcode-region=either}"
    TESTARGS="--target_board=msp430-sim"
    ;;
  nds32*-*)
    RUNGCCTESTS=yes
    DUMMY_SIM=yes
    SIMTARG=
    SIMINSTALLTARG=
    TESTARGS="--target_board=nds32-sim"
    ;;
  or1k*-*)
    RUNGCCTESTS=yes
    SIMTARG=all-sim
    SIMINSTALLTARG=install-sim
    TESTARGS="--target_board=or1k-sim"
    ;;
  rl78*-*)
    RUNGCCTESTS=yes
    SIMTARG=all-sim
    SIMINSTALLTARG=install-sim
    TESTARGS="--target_board=rl78-sim"
    ;;
  rx*-*)
    RUNGCCTESTS=yes
    SIMTARG=all-sim
    SIMINSTALLTARG=install-sim
    TESTARGS="--target_board=rx-sim"
    ;;
  v850*-*)
    RUNGCCTESTS=yes
    SIMTARG=all-sim
    SIMINSTALLTARG=install-sim
    TESTARGS="--target_board=v850-sim\{,-mgcc-abi,-msoft-float,-mv850e3v5,-msoft-float/-mv850e3v5,-mgcc-abi/-msoft-float/-mv850e3v5,-mgcc-abi/-msoft-float/-mv850e3v5\}"
    ;;
  visium*-*)
    RUNGCCTESTS=yes
    DUMMY_SIM=yes
    SIMTARG=
    SIMINSTALLTARG=
    TESTARGS="--target_board=visium-sim"
    ;;
  xstormy16*-*)
    RUNGCCTESTS=yes
    DUMMY_SIM=yes
    SIMTARG=
    SIMINSTALLTARG=
    TESTARGS="--target_board=xstormy16-sim"
    ;;
esac

patches/jobs/setupsources.sh $TARGET master binutils-gdb gcc newlib-cygwin > LOGFILE 2>&1


# Step 1, build binutils
echo Building binutils
cd ${TARGET}-obj/binutils
${SRCDIR}/binutils-gdb/configure --enable-warn-rwx-segments=no --enable-warn-execstack=no --enable-lto --prefix=`pwd`/../../${TARGET}-installed --target=${TARGET} >> LOGFILE 2>&1
make -j $NPROC -l $NPROC all-gas all-binutils all-ld $SIMTARG >> LOGFILE 2>&1
make install-gas install-binutils install-ld $SIMINSTALLTARG >> LOGFILE 2>&1
cd ../..
cd ${TARGET}-installed/bin
rm -f ar as ld ld.bfd nm objcopy objdump ranlib readelf strip run
cd ../..

# Step 2, build gcc
echo Building GCC
PATH=`pwd`/${TARGET}-installed/bin:$PATH
cd ${TARGET}-obj/gcc
${SRCDIR}/gcc/configure --disable-analyzer --with-system-libunwind --with-newlib --without-headers --disable-threads --disable-shared --enable-languages=c,c++,lto,fortran --prefix=`pwd`/../../${TARGET}-installed --target=${TARGET} >> LOGFILE 2>&1
make -j $NPROC -l $NPROC all-gcc >> LOGFILE 2>&1
make install-gcc >> LOGFILE 2>&1

# We try to build and install libgcc, but don't consider a failure fatal
(make -j $NPROC -l $NPROC all-target-libgcc && make install-target-libgcc) >> LOGFILE 2>&1 || /bin/true

# Conditionally build libstdc++.  Also set up to conditionally run its testsuite
if [ x$BUILDLIBSTDCXX == "xyes" ]; then
  (make -j $NPROC -l $NPROC all-target-libstdc++-v3 && make install-target-libstdc++-v3) >> LOGFILE 2>&1 || /bin/true
fi

cd ../../

# Step 3, build newlib
if [ ${TARGET} != avr-elf ]; then
  cd ${TARGET}-obj/newlib
  pushd ${SRCDIR}/newlib-cygwin >& /dev/null
  find . -name aclocal.m4 | xargs touch
  find . -name aclocal.m4 | xargs touch
  find . -name configure | xargs touch
  find . -name Makefile.am | xargs touch
  find . -name Makefile.in | xargs touch
  find . -name config.h.in | xargs touch
  popd >& /dev/null
  ${SRCDIR}/newlib-cygwin/configure --prefix=`pwd`/../../${TARGET}-installed --target=${TARGET} >> LOGFILE 2>&1
  make -j $NPROC -l $NPROC >> LOGFILE 2>&1
  make install >> LOGFILE 2>&1
  cd ../..
else
  # We don't have bzip2 in the docker image.  My bad
  wget "https://sourceforge.net/projects/bzip2/files/bzip2-1.0.6.tar.gz/download" -O bzip2-1.0.6.tar.gz
  tar xf bzip2-1.0.6.tar.gz
  pushd bzip2-1.0.6 >& /dev/null
  make -j 40 >> LOGFILE 2>&1
  make install PREFIX=/usr >> LOGFILE 2>&1
  popd >& /dev/null

  # avr needs a different newlib than everyone else.  boo
  wget http://download.savannah.gnu.org/releases/avr-libc/avr-libc-2.1.0.tar.bz2
  bunzip2 avr-libc-2.1.0.tar.bz2
  tar xf avr-libc-2.1.0.tar
  pushd avr-libc-2.1.0 >& /dev/null
  # The AVR team mucked up 30+ years of standard ways to configure cross toolchains,
  # remove that crap
  patch < ../patches/newlib-cygwin/avr-libc-hack
  popd >& /dev/null
  pushd ${TARGET}-obj/newlib >& /dev/null
  # Now that the sources are all fixed up, build them in a fairly standard way
  ${SRCDIR}/avr-libc-2.1.0/configure --prefix=`pwd`/../../${TARGET}-installed --target=${TARGET} --host=avr-elf >> LOGFILE 2>&1
  make -j $NPROC -l $NPROC >> LOGFILE 2>&1
  make install >> LOGFILE 2>&1
  popd >& /dev/null

#  # We also need to build the AVR simulator, which (of course) needs
#  # cmake which we don't have in our newlib build docker container :(
#  wget https://github.com/Kitware/CMake/releases/download/v3.26.4/cmake-3.26.4-linux-x86_64.sh
#  sh ./cmake-3.26.4-linux-x86_64.sh --skip-license || true
#  echo DONE extracting
#  PATH=/home/jlaw/jenkins/workspace/avr-elf/cmake-3.26.4-linux-x86_64/bin:$PATH
#  git clone https://git.savannah.nongnu.org/git/simulavr.git
#  pushd simulavr
#  make build -j 80
#  cp build/app/simulavr /home/jlaw/jenkins/workspace/avr-elf/avr-elf-installed/bin/avr-elf-run
#  popd >& /dev/null
fi

# Step 5, run tests
if [ $DUMMY_SIM = "yes" ]; then
  rm -f ${TARGET}-installed/bin/${TARGET}-run
  gcc -O2 patches/support/dummy.c -o ${TARGET}-installed/bin/${TARGET}-run
fi
cd ${TARGET}-obj/gcc/gcc
make site.exp
echo lappend boards_dir "`pwd`/../../../patches/support" >> site.exp
cd ../../../

# If a second argument is provided, it is a flag that we want to stop
# before running the testsuite
if [ "x$2" != "x" ]; then
  exit 0
fi


# The binutils suite is run unconditionally
#cd ${TARGET}-obj/binutils
#make -k -j $NPROC -l $NPROC check-gas check-ld check-binutils || true
#cd ../..

# Step 5, conditionally run the GCC testsuite using the simulator
cd ${TARGET}-obj/gcc/gcc

if [ $RUNGCCTESTS = "yes" ]; then
  echo Testing GCC
  make -k -j $NPROC -l $NPROC check-gcc $CHECK_CXX RUNTESTFLAGS="$TESTARGS"
fi

cd ../../..

patches/jobs/validate-results.sh $TARGET
