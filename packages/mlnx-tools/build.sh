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


if [ "$CLEAN" = true ] && [ -d "$BUILDDIR" ]; then
  echo "== Cleaning old build"
  rm -fr "$BUILDDIR"
fi


MLNX_TOOLS_BUILDDIR="$BUILDDIR"/mlnx-tools

if [ -n "$PKG_MLNX_TOOLS_GIT" ] && [ ! -d "$MLNX_TOOLS_BUILDDIR" ]; then
  if [ -n "$PKG_MLNX_TOOLS_GIT_BRANCH" ]; then
    CLONE="$PKG_MLNX_TOOLS_GIT -b $PKG_MLNX_TOOLS_GIT_BRANCH $MLNX_TOOLS_BUILDDIR"
  else
    CLONE="$PKG_MLNX_TOOLS_GIT $MLNX_TOOLS_BUILDDIR"
  fi
  echo "Clone: $CLONE"
  git clone $CLONE
  [[ $? == 0 ]] || fail "mlnx-tools git cloning failed"
fi

cp -R ./debian "$MLNX_TOOLS_BUILDDIR"/

cd "$MLNX_TOOLS_BUILDDIR"
dpkg-buildpackage -us -uc -B
[[ $? == 0 ]] ||  fail "mlnx-tools DEB package build failed"

echo "== NEW mlnx-tools package was successfully built!"

cd "$ROOTDIR"
mkdir -p "$DEBSDIR"
mv "$BUILDDIR"/*.deb "$DEBSDIR"/
echo "== mlnx-tools DEB packages moved to $DEBSDIR"
