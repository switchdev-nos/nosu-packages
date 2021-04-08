#!/bin/bash

ROOTDIR="$PWD"
BUILDDIR="$ROOTDIR/build"
DEBSDIR="$ROOTDIR/debs"

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


DROPWATCH_BUILDDIR="$BUILDDIR"/dropwatch

if [ -n "$PKG_DROPWATCH_GIT" ] && [ ! -d "$DROPWATCH_BUILDDIR" ]; then
  if [ -n "$PKG_DROPWATCH_GIT_BRANCH" ]; then
    CLONE="$PKG_DROPWATCH_GIT -b $PKG_DROPWATCH_GIT_BRANCH $DROPWATCH_BUILDDIR"
  else
    CLONE="$PKG_DROPWATCH_GIT $DROPWATCH_BUILDDIR"
  fi
  echo "Clone: $CLONE"
  git clone $CLONE
  [[ $? == 0 ]] || fail "dropwatch git cloning failed"
fi


cd "$DROPWATCH_BUILDDIR"
[[ -n $PKG_DROPWATCH_GIT_HASH ]] && git checkout $PKG_DROPWATCH_GIT_HASH
cp -R "$ROOTDIR"/debian "$DROPWATCH_BUILDDIR"/
dpkg-buildpackage -us -uc -B
[[ $? == 0 ]] ||  fail "dropwatch DEB package build failed"

echo "== NEW dropwatch package was successfully built!"

cd "$ROOTDIR"
mkdir -p "$DEBSDIR"
mv -f "$BUILDDIR"/*.deb "$DEBSDIR"/
echo "== dropwatch DEB packages moved to $DEBSDIR"
