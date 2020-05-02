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


HW_MGMT_BUILDDIR="$BUILDDIR"/hw-mgmt

if [ -n "$PKG_MLNX_HW_MGMT_GIT" ] && [ ! -d "$HW_MGMT_BUILDDIR" ]; then
  if [ -n "$PKG_MLNX_HW_MGMT_GIT_BRANCH" ]; then
    CLONE="$PKG_MLNX_HW_MGMT_GIT -b $PKG_MLNX_HW_MGMT_GIT_BRANCH $HW_MGMT_BUILDDIR"
  else
    CLONE="$PKG_MLNX_HW_MGMT_GIT $HW_MGMT_BUILDDIR"
  fi
  echo "Clone: $CLONE"
  git clone $CLONE
  [[ $? == 0 ]] || fail "hw-mgmt git cloning failed"
fi

cp -R ./debian "$HW_MGMT_BUILDDIR"/

cd "$HW_MGMT_BUILDDIR"
dpkg-buildpackage -us -uc -B
[[ $? == 0 ]] ||  fail "hw-mgmt DEB package build failed"

echo "== NEW hw-mgmt package was successfully built!"

cd "$ROOTDIR"
mkdir -p "$DEBSDIR"
mv "$BUILDDIR"/*.deb "$DEBSDIR"/
echo "== hw-mgmt DEB packages moved to $DEBSDIR"
