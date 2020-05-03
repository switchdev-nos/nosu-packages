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


SOSREPORT_BUILDDIR="$BUILDDIR"/sos

if [ -n "$PKG_SOSREPORT_GIT" ] && [ ! -d "$SOSREPORT_BUILDDIR" ]; then
  if [ -n "$PKG_SOSREPORT_GIT_BRANCH" ]; then
    CLONE="$PKG_SOSREPORT_GIT -b $PKG_SOSREPORT_GIT_BRANCH $SOSREPORT_BUILDDIR"
  else
    CLONE="$PKG_SOSREPORT_GIT $SOSREPORT_BUILDDIR"
  fi
  echo "Clone: $CLONE"
  git clone $CLONE
  [[ $? == 0 ]] || fail "sosreport git cloning failed"
fi

cp -R ./debian "$SOSREPORT_BUILDDIR"/

cd "$SOSREPORT_BUILDDIR"
dpkg-buildpackage -us -uc -B
[[ $? == 0 ]] ||  fail "sosreport DEB package build failed"

echo "== NEW sosreport package was successfully built!"

cd "$ROOTDIR"
mkdir -p "$DEBSDIR"
mv -f "$BUILDDIR"/*.deb "$DEBSDIR"/
echo "== sosreport DEB packages moved to $DEBSDIR"
