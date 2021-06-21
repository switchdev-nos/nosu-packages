#!/bin/bash

DEBSDIR="./debs"
ROOTDIR="$PWD"
PKGDIR=$PWD/packages
KERNELDIR=$PWD/kernel
ENVFILE=$1

fail() {
  [ -n "$1" ] && echo $1
  exit 1
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  echo "Usage: $0 [ENVFILE]"
  exit 0
fi

if [ -n "$ENVFILE" ]; then
  if [ -r "$ENVFILE" ]; then
    set -a
    . "$ENVFILE"
    set +a
  else
    fail "ENVFILE not readable or missing"
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
  rm -fr $PKGDIR/$pkg/kernel
  ln -sf $KERNELDIR $PKGDIR/$pkg/kernel
  echo "Building $pkg..."
  cat $PKGDIR/$pkg/env/default $ENVFILE > $PKGDIR/$pkg/env/build
  pushd $PKGDIR/$pkg
  ./docker_build.sh ./env/build 
  popd
done

wait
echo "== all packages were successfully built!"

cd $ROOTDIR
mkdir -p "$DEBSDIR"

for pkg in "${NOSU_PACKAGES[@]}"; do
  mv -f $PKGDIR/$pkg/debs/*.deb $DEBSDIR/
  rm -fr $PKGDIR/$pkg/kernel
  rm -f $PKGDIR/$pkg/env/build
done

echo "== all DEB packages moved to $DEBSDIR"
