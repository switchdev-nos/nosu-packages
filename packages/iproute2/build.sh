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

[ -n "$PKG_IPROUTE2_VERSION" ] || fail "PKG_IPROUTE2_VERSION is not set"

if [ "$CLEAN" = true ] && [ -d "$BUILDDIR" ]; then
  echo "== Cleaning old build"
  rm -fr "$BUILDDIR"
fi


if [ -n "$PKG_IPROUTE2_SNAPSHOT" ]; then
  IPROUTE2_BUILDDIR="$BUILDDIR"/iproute2-"$PKG_IPROUTE2_VERSION"
elif [ -n "$PKG_IPROUTE2_GIT" ]; then
  IPROUTE2_BUILDDIR="$BUILDDIR"/iproute2
fi

if [ -n "$PKG_IPROUTE2_SNAPSHOT" ] && [ ! -d "$IPROUTE2_BUILDDIR" ]; then
  mkdir -p "$BUILDDIR"
  echo "== Downloading iproute2 snapshot: $PKG_IPROUTE2_SNAPSHOT"
  curl -L "$PKG_IPROUTE2_SNAPSHOT" | tar -xz -C "$BUILDDIR"
  [[ $? == 0 ]] || fail "iproute2 snapshot downloading failed"
elif [ -n "$PKG_IPROUTE2_GIT" ] && [ ! -d "$IPROUTE2_BUILDDIR" ]; then
  if [ -n "$PKG_IPROUTE2_GIT_BRANCH" ]; then
    CLONE="$PKG_IPROUTE2_GIT -b $PKG_IPROUTE2_GIT_BRANCH $IPROUTE2_BUILDDIR"
  else
    CLONE="$PKG_IPROUTE2_GIT $IPROUTE2_BUILDDIR"
  fi
  echo "Clone: $CLONE"
  git clone $CLONE
  [[ $? == 0 ]] || fail "iproute2 git cloning failed"
fi

cp -R ./debian "$IPROUTE2_BUILDDIR"/

cat <<EOF > "$IPROUTE2_BUILDDIR"/debian/changelog
iproute2 ($PKG_IPROUTE2_VERSION-1ubuntu1) unstable; urgency=low

  * debian: update iproute2 to $PKG_IPROUTE2_VERSION

 -- $DEBFULLNAME <$DEBEMAIL>  $(date -R)
EOF


cd "$IPROUTE2_BUILDDIR"
dpkg-buildpackage -us -uc -B
[[ $? == 0 ]] ||  fail "iproute2 DEB package build failed"

echo "== NEW iproute2 package was successfully built!"

cd "$ROOTDIR"
mkdir -p "$DEBSDIR"
mv -f "$BUILDDIR"/*.deb "$DEBSDIR"/
echo "== iproute2 DEB packages moved to $DEBSDIR"
