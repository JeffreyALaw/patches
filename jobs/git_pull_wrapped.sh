#!/bin/bash -x

set +e
retval=1
attempt=1

until [[ $retval -eq 0 ]] ; do
  git pull -q
  retval=$?
  attempt=$(( $attempt + 1 ))
  if [[ $retval -ne 0 ]]; then
      # If there was an error wait 10 seconds
      sleep 10
  fi
done
set -e
