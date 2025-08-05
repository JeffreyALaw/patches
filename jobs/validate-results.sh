#!/bin/bash

# Ensure that we fail if any command fails
set -e
set -o pipefail

TARGET=$1

# Step #6, setup for artifact archiving and comparing testresults
rm -rf testresults
mkdir -p testresults
if [ -f ${TARGET}-obj/gcc/gcc/testsuite/gcc/gcc.sum ]; then
  cp `find ${TARGET}-obj -name \*.sum -print` testresults
fi
if [ -f obj/gcc/gcc/testsuite/gcc/gcc.sum ]; then
  cp `find obj -name \*.sum -print` testresults
fi

if [ -f ${TARGET}-obj/binutils/gas/testsuite/gas.sum ]; then
  cp `find ${TARGET}-obj -name \*.sum -print` testresults
fi
if [ -f obj/binutils/gas/testsuite/gas.sum
  cp `find obj -name \*.sum -print` testresults
fi

if [ -f ${TARGET}-obj/binutils/binutils/binutils.sum ]; then
  cp `find ${TARGET}-obj -name \*.sum -print` testresults
fi
if [ -f obj/binutils/binutils/binutils.sum
  cp `find obj -name \*.sum -print` testresults
fi

if [ -f ${TARGET}-obj/binutils/ld/ld.sum ]; then
  cp `find ${TARGET}-obj -name \*.sum -print` testresults
fi
if [ -f obj/binutils/ld/ld.sum
  cp `find obj -name \*.sum -print` testresults
fi

newbase=`grep ${TARGET} patches/gcc/NEWBASELINES || true`
if [ -f old-testresults/gcc.sum.gz ]; then
  rm -f old-testresults/*.sum
  gunzip old-testresults/*.sum.gz
  if [ "x$newbase" == "x" ]; then
    gcc/contrib/compare_tests old-testresults testresults
  else
    gcc/contrib/compare_tests old-testresults testresults || true
  fi
fi

cd testresults
if [ -f gcc.sum ]; then
  gzip --best *.sum
#  gzip --best *.log
fi

