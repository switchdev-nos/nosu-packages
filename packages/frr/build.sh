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


FRR_BUILDDIR="$BUILDDIR"/frr

if [ -n "$PKG_FRR_GIT" ] && [ ! -d "$FRR_BUILDDIR" ]; then
  if [ -n "$PKG_FRR_GIT_BRANCH" ]; then
    CLONE="$PKG_FRR_GIT -b $PKG_FRR_GIT_BRANCH $FRR_BUILDDIR"
  else
    CLONE="$PKG_FRR_GIT $FRR_BUILDDIR"
  fi
  echo "Clone: $CLONE"
  git clone $CLONE
  [[ $? == 0 ]] || fail "frr git cloning failed"
fi

cp -R ./debian "$FRR_BUILDDIR"/

cd "$FRR_BUILDDIR"
./tools/tarsource.sh -V
dpkg-buildpackage -us -uc -Ppkg.frr.nortrlib
[[ $? == 0 ]] ||  fail "frr DEB package build failed"

echo "== NEW frr package was successfully built!"

cd "$ROOTDIR"
mkdir -p "$DEBSDIR"
mv -f "$BUILDDIR"/*.deb "$DEBSDIR"/
echo "== frr DEB packages moved to $DEBSDIR"
