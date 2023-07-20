#!/bin/bash -x

set -e
set -o pipefail

TARGET=$1
shift
GCC_BRANCH=$1
shift

# Shut up git ownership checking
git config --global safe.directory '*'

# This script copies the requested sources from the docker
# volume, updates them from their appropriate upstreams, then
# applies ptaches
#
# The set of repos is passed in as arguments
for repo in $*; do
  case $repo in
    gcc)
      url=git://gcc.gnu.org/git/gcc.git
      ;;
    binutils-gdb)
      url=git://sourceware.org/git/binutils-gdb.git
      ;;
    newlib-cygwin)
      url=https://sourceware.org/git/newlib-cygwin.git
      ;;
    glibc)
      url=https://sourceware.org/git/glibc.git
      ;;
    linux)
      url=https://github.com/torvalds/linux.git
      ;;
    default)
      echo "Unknown repository"
      exit 1
      ;;
  esac
  
  # If we have the docker volume, then use tar to clone into
  # our local copy.  That's going to be much faster than git.
  # Then update the local copy with the latest bits.  Otherwise
  # just clone from upstream.
  if [ -d /home/jlaw/jenkins/docker-volume/$repo ]; then
    pushd /home/jlaw/jenkins/docker-volume
    tar cf - ./$repo | (cd /home/jlaw/jenkins/workspace/${TARGET} ; tar xf - )
    popd
    pushd $repo
    if [ "$repo" == "gcc" ]; then
      if [ "$GCC_BRANCH" == "master" ]; then
        git checkout -q master -- .
      else
        # WTF is going on here
        git checkout -q vendors/$GCC_BRANCH
        git checkout -- .
        git branch $GCC_BRANCH
        git checkout $GCC_BRANCH
        git branch --set-upstream-to=vendors/$GCC_BRANCH $GCC_BRANCH
      fi
    else
      git checkout -q master -- .
    fi
    # We're having a lot of instability with the remote nodes at this step
    # due to network instability.  Given we're just updating a local repo,
    # we can repeat the attempt until it succeeds
    patches/jobs/git_pull_wrapped.sh
    git status .
    popd
  else
    # If the repo already exists, go into it, clean & update
    if [ -d $repo ]; then
      pushd $repo
      git clean -f
      git checkout -- .
      git pull
      popd
    else
      git clone $url $repo
    fi

  fi
  
done
  
for tool in $*; do

  # Don't try to "patch" the chroots
  if [ "$tool" == "chroots" ]; then
    continue
  fi

  cd $tool
  for patch in ../patches/$tool/*.patch; do
    patch -p1 < $patch
  done

  if [ -f ../patches/$tool/TOREMOVE ]; then
    rm -f `cat ../patches/$tool/TOREMOVE | grep -v "^#"`
  fi

  cd ..
done

# Now that we've checked out and patched the tree, also run a script
# that touches various files in the gcc subdir.  This avoids problems
# with timestamps, particularly the Pragma3 test.
pushd gcc
contrib/gcc_update --touch
popd

