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

[ -n "$NOSU_VERSION" ] || fail "NOSU_VERSION is not set"
[ -n "$PKG_MLNX_FIRMWARE_URL" ] || fail "PKG_MLNX_FIRMWARE_URL is not set"

FW_DEB_DIR="$BUILDDIR/mlnx-firmware"
FWDIR="$FW_DEB_DIR/mellanox"


if [ "$CLEAN" = true ] && [ -d "$BUILDDIR" ]; then
  echo "== Cleaning old build"
  rm -fr "$BUILDDIR"
fi

if [ -n "$PKG_MLNX_FIRMWARE_URL" ] && [ ! -d "$FWDIR" ]; then
  # download mellanox firmware
  mkdir -p $FWDIR
  echo "== Loading Mellanox firmware"
  for file in $(curl -s $PKG_MLNX_FIRMWARE_URL |
                 sed -e 's/\(<[^<][^<]*>\)//g' |
                 grep mfa); do
  curl -s -o "$FWDIR/$file" "$PKG_MLNX_FIRMWARE_URL/$file"
done
  [[ $? == 0 ]] || fail "Mellanox firmware downloading failed"
fi

mkdir -p "$FW_DEB_DIR"/debian

echo 10 > "$FW_DEB_DIR"/debian/compat

cat <<EOF > "$FW_DEB_DIR"/debian/control
Source: mlnx-firmware
Section: misc
Priority: optional
Build-Depends: debhelper (>= 8.0.0)
Maintainer: $DEBFULLNAME <$DEBEMAIL>
Homepage: http://www.mellanox.com

Package: mlnx-firmware
Replaces: linux-firmware
Architecture: amd64
Description: Mellanox Firmware binaries
EOF

TAB="$(printf '\t')"
cat <<EOF > "$FW_DEB_DIR"/debian/rules
#!/usr/bin/make -f

%:
${TAB}dh \$@

EOF
chmod +x "$FW_DEB_DIR"/debian/rules

cat <<EOF > "$FW_DEB_DIR"/debian/changelog
mlnx-firmware ($NOSU_VERSION) unstable; urgency=medium

  * debian: update fw package to $NOSU_VERSION

 -- $DEBFULLNAME <$DEBEMAIL>  $(date -R)
EOF


cat <<EOF > "$FW_DEB_DIR"/debian/install
mellanox /lib/firmware/
EOF

cd "$FW_DEB_DIR"
dpkg-buildpackage -us -uc -B
[[ $? == 0 ]] ||  fail "Mellanox Firmware DEB package build failed"

echo "== NEW mlnx-firmware package was successfully built!"

cd "$ROOTDIR"
mkdir -p "$DEBSDIR"
mv "$BUILDDIR"/*.deb "$DEBSDIR"/
echo "== Mellanox Firmware DEB package moved to $DEBSDIR"
