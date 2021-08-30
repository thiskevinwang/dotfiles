#!/usr/bin/env bash

SOURCE="${BASH_SOURCE}"
echo $SOURCE

BASEDIR=$(dirname $0)
echo $BASEDIR

while read p; do
  echo "⏳ Installing: $p ..."
  code --install-extension $p
  wait
  echo "✅ Installed: $p"
  echo ""
done < $BASEDIR/extensions.txt