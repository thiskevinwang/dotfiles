#!/usr/bin/env bash

SOURCE="${BASH_SOURCE}"
BASEDIR=$(dirname $0)

while read p; do
  code --install-extension $p >/dev/null 2>/dev/null
  if [[ $? != 0 ]] ; then
    echo "💥 $p"
  else 
    echo "✔ $p"
  fi
  wait
done < $BASEDIR/extensions.txt