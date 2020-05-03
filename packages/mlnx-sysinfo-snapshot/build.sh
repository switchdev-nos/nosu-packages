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


SYSINFO_SNAPSHOT_BUILDDIR="$BUILDDIR"/sysinfo-snapshot

if [ -n "$PKG_MLNX_SYSINFO_SNAPSHOT_GIT" ] && [ ! -d "$SYSINFO_SNAPSHOT_BUILDDIR" ]; then
  if [ -n "$PKG_MLNX_SYSINFO_SNAPSHOT_GIT_BRANCH" ]; then
    CLONE="$PKG_MLNX_SYSINFO_SNAPSHOT_GIT -b $PKG_MLNX_SYSINFO_SNAPSHOT_GIT_BRANCH $SYSINFO_SNAPSHOT_BUILDDIR"
  else
    CLONE="$PKG_MLNX_SYSINFO_SNAPSHOT_GIT $SYSINFO_SNAPSHOT_BUILDDIR"
  fi
  echo "Clone: $CLONE"
  git clone $CLONE
  [[ $? == 0 ]] || fail "sysinfo-snapshot git cloning failed"
fi

cp -R ./debian "$SYSINFO_SNAPSHOT_BUILDDIR"/

cd "$SYSINFO_SNAPSHOT_BUILDDIR"
dpkg-buildpackage -us -uc
[[ $? == 0 ]] ||  fail "sysinfo-snapshot DEB package build failed"

echo "== NEW sysinfo-snapshot package was successfully built!"

cd "$ROOTDIR"
mkdir -p "$DEBSDIR"
mv -f "$BUILDDIR"/*.deb "$DEBSDIR"/
echo "== sysinfo-snapshot DEB packages moved to $DEBSDIR"
