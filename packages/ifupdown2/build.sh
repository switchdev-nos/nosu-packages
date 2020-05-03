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


IFUPDOWN2_BUILDDIR="$BUILDDIR"/ifupdown2

if [ -n "$PKG_IFUPDOWN2_GIT" ] && [ ! -d "$IFUPDOWN2_BUILDDIR" ]; then
  if [ -n "$PKG_IFUPDOWN2_GIT_BRANCH" ]; then
    CLONE="$PKG_IFUPDOWN2_GIT -b $PKG_IFUPDOWN2_GIT_BRANCH $IFUPDOWN2_BUILDDIR"
  else
    CLONE="$PKG_IFUPDOWN2_GIT $IFUPDOWN2_BUILDDIR"
  fi
  echo "Clone: $CLONE"
  git clone $CLONE
  [[ $? == 0 ]] || fail "ifupdown2 git cloning failed"
fi

cp -R ./debian "$IFUPDOWN2_BUILDDIR"/

cd "$IFUPDOWN2_BUILDDIR"
make deb
[[ $? == 0 ]] ||  fail "ifupdown2 DEB package build failed"

echo "== NEW ifupdown2 package was successfully built!"

cd "$ROOTDIR"
mkdir -p "$DEBSDIR"
mv -f "$BUILDDIR"/*.deb "$DEBSDIR"/
echo "== ifupdown2 DEB packages moved to $DEBSDIR"
