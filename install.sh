#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$ROOT/config.env"

for cmd in git podman patch; do
    command -v "$cmd" >/dev/null 2>&1 || {
        echo "Comando mancante: $cmd" >&2
        exit 1
    }
done

WORKDIR="$ROOT/.local-build"
SOURCE="$WORKDIR/source"
BUILD="$WORKDIR/build"
INSTALL="$WORKDIR/install"

mkdir -p "$WORKDIR"

echo "=== DOWNLOAD GNU BINUTILS/GDB ==="

if [ ! -d "$SOURCE/.git" ]; then
    git clone "$UPSTREAM_URL" "$SOURCE"
fi

git -C "$SOURCE" fetch origin "$UPSTREAM_COMMIT"
git -C "$SOURCE" checkout --detach "$UPSTREAM_COMMIT"

echo "=== APPLICAZIONE PATCH ==="

if patch -d "$SOURCE" -p1 --dry-run < "$ROOT/patches/compat.patch" >/dev/null; then
    patch -d "$SOURCE" -p1 < "$ROOT/patches/compat.patch"
elif patch -d "$SOURCE" -p1 -R --dry-run < "$ROOT/patches/compat.patch" >/dev/null; then
    echo "Patch già applicata."
else
    echo "ERRORE: patch incompatibile con i sorgenti." >&2
    exit 1
fi

echo "=== COMPONENTI CGEN ==="

for name in arc-asm.c arc-desc.c arc-desc.h arc-ibld.c arc-opc.h arc-opinst.c; do
    if [ ! -s "$SOURCE/opcodes/$name" ]; then
        cp "$ROOT/generated-opcodes/$name" "$SOURCE/opcodes/$name"
    fi
done

echo "=== CONTAINER DEBIAN 11 ==="

podman build -t "$IMAGE" -f "$ROOT/Containerfile" "$ROOT"

echo "=== COMPILAZIONE GNU ARC700 ==="

mkdir -p "$BUILD" "$INSTALL"

podman run --rm     --network none     --volume "$SOURCE:/work/source:Z"     --volume "$BUILD:/work/build:Z"     --volume "$INSTALL:/work/install:Z"     -e TARGET="$TARGET"     -e JOBS="$JOBS"     -e BUILD_CFLAGS="$CFLAGS"     -e BUILD_CXXFLAGS="$CXXFLAGS"     "$IMAGE" sh -ec "
        cd /work/build

        /work/source/configure             --target=\$TARGET             --prefix=/work/install             --disable-werror             --disable-gdb             --disable-binutils             --disable-ld             --disable-gas             --disable-gprof             --disable-nls             --enable-sim             CFLAGS=\"\$BUILD_CFLAGS\"             CXXFLAGS=\"\$BUILD_CXXFLAGS\"

        make -j\$JOBS MAKEINFO=true all-sim
        make -j1 MAKEINFO=true install-sim
        test -x /work/install/bin/arc-elf32-run
    "

echo "=== INSTALLAZIONE COMPLETATA ==="
echo "$INSTALL/bin/arc-elf32-run"
sha256sum "$INSTALL/bin/arc-elf32-run"
