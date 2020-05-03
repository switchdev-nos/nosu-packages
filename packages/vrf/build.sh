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

VRF_BUILDDIR="$BUILDDIR"/vrf

if [ -n "$PKG_VRF_GIT" ] && [ ! -d "$VRF_BUILDDIR" ]; then
  if [ -n "$PKG_VRF_GIT_BRANCH" ]; then
    CLONE="$PKG_VRF_GIT -b $PKG_VRF_GIT_BRANCH $VRF_BUILDDIR"
  else
    CLONE="$PKG_VRF_GIT $VRF_BUILDDIR"
  fi
  echo "Clone: $CLONE"
  git clone $CLONE
  [[ $? == 0 ]] || fail "vrf git cloning failed"
fi

cp -R ./debian "$VRF_BUILDDIR"/

cd "$VRF_BUILDDIR"
make deb
[[ $? == 0 ]] ||  fail "vrf DEB package build failed"

echo "== NEW vrf package was successfully built!"

cd "$ROOTDIR"
mkdir -p "$DEBSDIR"
mv -f "$BUILDDIR"/*.deb "$DEBSDIR"/
echo "== vrf DEB packages moved to $DEBSDIR"
