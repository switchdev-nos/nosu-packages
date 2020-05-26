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

[ -n "$PKG_KEEPALIVED_VERSION" ] || fail "PKG_KEEPALIVED_VERSION is not set"

if [ "$CLEAN" = true ] && [ -d "$BUILDDIR" ]; then
  echo "== Cleaning old build"
  rm -fr "$BUILDDIR"
fi


if [ -n "$PKG_KEEPALIVED_SNAPSHOT" ]; then
  KEEPALIVED_BUILDDIR="$BUILDDIR"/keepalived-"$PKG_KEEPALIVED_VERSION"
elif [ -n "$PKG_KEEPALIVED_GIT" ]; then
  KEEPALIVED_BUILDDIR="$BUILDDIR"/keepalived
fi

if [ -n "$PKG_KEEPALIVED_SNAPSHOT" ] && [ ! -d "$KEEPALIVED_BUILDDIR" ]; then
  mkdir -p "$BUILDDIR"
  echo "== Downloading keepalived snapshot: $PKG_KEEPALIVED_SNAPSHOT"
  curl -L "$PKG_KEEPALIVED_SNAPSHOT" | tar -xz -C "$BUILDDIR"
  [[ $? == 0 ]] || fail "keepalived snapshot downloading failed"
elif [ -n "$PKG_KEEPALIVED_GIT" ] && [ ! -d "$KEEPALIVED_BUILDDIR" ]; then
  if [ -n "$PKG_KEEPALIVED_GIT_BRANCH" ]; then
    CLONE="$PKG_KEEPALIVED_GIT -b $PKG_KEEPALIVED_GIT_BRANCH $KEEPALIVED_BUILDDIR"
  else
    CLONE="$PKG_KEEPALIVED_GIT $KEEPALIVED_BUILDDIR"
  fi
  echo "Clone: $CLONE"
  git clone $CLONE
  [[ $? == 0 ]] || fail "keepalived git cloning failed"
fi

cp -R ./debian "$KEEPALIVED_BUILDDIR"/

cat <<EOF > "$KEEPALIVED_BUILDDIR"/debian/changelog
keepalived ($PKG_KEEPALIVED_VERSION-1ubuntu1) unstable; urgency=low

  * debian: update keepalived to $PKG_KEEPALIVED_VERSION

 -- $DEBFULLNAME <$DEBEMAIL>  $(date -R)
EOF


cd "$KEEPALIVED_BUILDDIR"
dpkg-buildpackage -us -uc -B
[[ $? == 0 ]] ||  fail "keepalived DEB package build failed"

echo "== NEW keepalived package was successfully built!"

cd "$ROOTDIR"
mkdir -p "$DEBSDIR"
mv -f "$BUILDDIR"/*.deb "$DEBSDIR"/
echo "== keepalived DEB packages moved to $DEBSDIR"
