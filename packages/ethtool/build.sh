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

[ -n "$PKG_ETHTOOL_VERSION" ] || fail "PKG_ETHTOOL_VERSION is not set"

if [ "$CLEAN" = true ] && [ -d "$BUILDDIR" ]; then
  echo "== Cleaning old build"
  rm -fr "$BUILDDIR"
fi


if [ -n "$PKG_ETHTOOL_SNAPSHOT" ]; then
  ETHTOOL_BUILDDIR="$BUILDDIR"/ethtool-"$PKG_ETHTOOL_VERSION"
elif [ -n "$PKG_ETHTOOL_GIT" ]; then
  ETHTOOL_BUILDDIR="$BUILDDIR"/ethtool
fi

if [ -n "$PKG_ETHTOOL_SNAPSHOT" ] && [ ! -d "$ETHTOOL_BUILDDIR" ]; then
  mkdir -p "$BUILDDIR"
  echo "== Downloading ethtool snapshot: $PKG_ETHTOOL_SNAPSHOT"
  curl -L "$PKG_ETHTOOL_SNAPSHOT" | tar -xz -C "$BUILDDIR"
  [[ $? == 0 ]] || fail "ethtool snapshot downloading failed"
elif [ -n "$PKG_ETHTOOL_GIT" ] && [ ! -d "$ETHTOOL_BUILDDIR" ]; then
  if [ -n "$PKG_ETHTOOL_GIT_BRANCH" ]; then
    CLONE="$PKG_ETHTOOL_GIT -b $PKG_ETHTOOL_GIT_BRANCH $ETHTOOL_BUILDDIR"
  else
    CLONE="$PKG_ETHTOOL_GIT $ETHTOOL_BUILDDIR"
  fi
  echo "Clone: $CLONE"
  git clone $CLONE
  [[ $? == 0 ]] || fail "ethtool git cloning failed"
fi

cp -R ./debian "$ETHTOOL_BUILDDIR"/

cat <<EOF > "$ETHTOOL_BUILDDIR"/debian/changelog
ethtool ($PKG_ETHTOOL_VERSION-1ubuntu1) unstable; urgency=low

  * new upstream release $PKG_ETHTOOL_VERSION

 -- $DEBFULLNAME <$DEBEMAIL>  $(date -R)
EOF


cd "$ETHTOOL_BUILDDIR"
dpkg-buildpackage -us -uc -B
[[ $? == 0 ]] ||  fail "ethtool DEB package build failed"

echo "== NEW ethtool package was successfully built!"

cd "$ROOTDIR"
mkdir -p "$DEBSDIR"
mv -f "$BUILDDIR"/*.deb "$DEBSDIR"/
echo "== ethtool DEB packages moved to $DEBSDIR"
