#!/bin/bash

DEBSDIR="./debs"
ROOTDIR="$PWD"
PKGDIR=$PWD/packages
KERNELDIR=$PWD/kernel

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

[ -n "$NOSU_PACKAGES" ] || fail "NOSU_PACKAGES is not set"

if [ "$CLEAN" = true ]; then
  echo "== Cleaning old debs"
  for pkg in "${NOSU_PACKAGES[@]}"; do
    rm -f $PKGDIR/$pkg/debs/*.deb
    rm -f $DEBSDIR/*.deb
  done
fi

for pkg in "${NOSU_PACKAGES[@]}"; do
  ln -sf $KERNELDIR $PKGDIR/$pkg/kernel
  echo "Building $pkg..."
  cd $PKGDIR/$pkg
  ./docker_build.sh &
  cd $ROOTDIR
done

wait
echo "== all packages were successfully built!"

cd $ROOTDIR
mkdir -p "$DEBSDIR"

for pkg in "${NOSU_PACKAGES[@]}"; do
  mv $PKGDIR/$pkg/debs/*.deb $DEBSDIR/
  rm -fr $PKGDIR/$pkg/kernel
done

echo "== all DEB packages moved to $DEBSDIR"
