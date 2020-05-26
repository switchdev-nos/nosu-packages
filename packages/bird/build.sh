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

[ -n "$PKG_BIRD_VERSION" ] || fail "PKG_BIRD_VERSION is not set"

if [ "$CLEAN" = true ] && [ -d "$BUILDDIR" ]; then
  echo "== Cleaning old build"
  rm -fr "$BUILDDIR"
fi


if [ -n "$PKG_BIRD_SNAPSHOT" ]; then
  BIRD_BUILDDIR="$BUILDDIR"/bird-"$PKG_BIRD_VERSION"
elif [ -n "$PKG_BIRD_GIT" ]; then
  BIRD_BUILDDIR="$BUILDDIR"/bird
fi

if [ -n "$PKG_BIRD_SNAPSHOT" ] && [ ! -d "$BIRD_BUILDDIR" ]; then
  mkdir -p "$BUILDDIR"
  echo "== Downloading bird snapshot: $PKG_BIRD_SNAPSHOT"
  curl -L "$PKG_BIRD_SNAPSHOT" | tar -xz -C "$BUILDDIR"
  [[ $? == 0 ]] || fail "bird snapshot downloading failed"
elif [ -n "$PKG_BIRD_GIT" ] && [ ! -d "$BIRD_BUILDDIR" ]; then
  if [ -n "$PKG_BIRD_GIT_BRANCH" ]; then
    CLONE="$PKG_BIRD_GIT -b $PKG_BIRD_GIT_BRANCH $BIRD_BUILDDIR"
  else
    CLONE="$PKG_BIRD_GIT $BIRD_BUILDDIR"
  fi
  echo "Clone: $CLONE"
  git clone $CLONE
  [[ $? == 0 ]] || fail "bird git cloning failed"
fi

cp -R ./debian "$BIRD_BUILDDIR"/

cat <<EOF > "$BIRD_BUILDDIR"/debian/changelog
bird ($PKG_BIRD_VERSION-1ubuntu1) unstable; urgency=low

  * debian: update bird to $PKG_BIRD_VERSION

 -- $DEBFULLNAME <$DEBEMAIL>  $(date -R)
EOF


cd "$BIRD_BUILDDIR"
dpkg-buildpackage -us -uc -B
[[ $? == 0 ]] ||  fail "bird DEB package build failed"

echo "== NEW bird package was successfully built!"

cd "$ROOTDIR"
mkdir -p "$DEBSDIR"
mv -f "$BUILDDIR"/*.deb "$DEBSDIR"/
echo "== bird DEB packages moved to $DEBSDIR"
