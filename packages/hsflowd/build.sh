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

HSFLOWD_BUILDDIR="$BUILDDIR"/hsflowd

if [ -n "$PKG_HSFLOWD_GIT" ] && [ ! -d "$HSFLOWD_BUILDDIR" ]; then
  if [ -n "$PKG_HSFLOWD_GIT_BRANCH" ]; then
    CLONE="$PKG_HSFLOWD_GIT -b $PKG_HSFLOWD_GIT_BRANCH $HSFLOWD_BUILDDIR"
  else
    CLONE="$PKG_HSFLOWD_GIT $HSFLOWD_BUILDDIR"
  fi
  echo "Clone: $CLONE"
  git clone $CLONE
  [[ $? == 0 ]] || fail "hsflowd git cloning failed"
fi

cp -R ./debian "$HSFLOWD_BUILDDIR"/

cd "$HSFLOWD_BUILDDIR"
make deb FEATURES="DENT PSAMPLE SYSTEMD DROPMON PCAP NFLOG TCP"
[[ $? == 0 ]] ||  fail "hsflowd DEB package build failed"

echo "== NEW hsflowd package was successfully built!"

cd "$ROOTDIR"
mkdir -p "$DEBSDIR"
mv -f "$HSFLOWD_BUILDDIR"/*.deb "$DEBSDIR"/
echo "== hsflowd DEB packages moved to $DEBSDIR"
