#!/bin/sh
# Compatibility entry point; bootstrap owns machine setup.
set -eu
exec bash "$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)/bootstrap.sh" "$@"
