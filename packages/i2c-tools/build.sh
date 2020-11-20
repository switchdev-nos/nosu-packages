#!/bin/bash

BUILDDIR="./build"
DEBSDIR="./debs"
ROOTDIR="$PWD"

fail() {
  [ -n "$1" ] && echo $1
  exit 1
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  echo "Usage: $0 [ENV_FILE]"
  exit 0
fi

if [ -n "$1" ]; then
  if [ -r "$1" ]; then
    set -a
    . "$1"
    set +a
  else
    fail "ENV_FILE not readable or missing"
  fi
fi

[ -n "$PKG_I2C_TOOLS_VERSION" ] || fail "PKG_I2C_TOOLS_VERSION is not set"
[ -n "$PKG_I2C_TOOLS_DEBS" ] || fail "PKG_I2C_TOOLS_DEBS is not set"

mkdir -p "$DEBSDIR"
pushd "$DEBSDIR"
echo "== Downloading DEB files for i2c-tools $PKG_I2C_TOOLS_VERSION"
for deb in "${PKG_I2C_TOOLS_DEBS[@]}"; do
  echo "$deb"
  curl -L -O "$deb"
done
popd

echo "== i2c-tools DEB files moved to $DEBSDIR"
