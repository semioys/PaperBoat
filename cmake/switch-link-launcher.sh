#!/usr/bin/env bash
# Linker launcher for Switch builds on a Windows (MSYS2) host.
#
# Paperboat links thousands of objects, which overflows the 32K command line
# limit of a native Windows process. MSYS2 programs (this script) have no such
# limit, so CMake hands us the full link command; we move the arguments into a
# response file and call the native devkitA64 driver with @file.
#
# The driver cannot resolve MSYS paths (/d/..., /opt/devkitpro/...) inside a
# response file, so they are rewritten to Windows form (D:/..., C:/devkitPro/...).
set -euo pipefail

compiler="$1"
shift

rsp="$(mktemp --suffix=.rsp)"
trap 'rm -f "$rsp" "$rsp.raw"' EXIT

dkp_root="$(cygpath -m /opt/devkitpro)"
msys_root="$(cygpath -m /)"
msys_root="${msys_root%/}"

# One argument per line, then a single rewrite pass. A path may start the
# argument or follow '=', ',' or a -L/-I prefix (-specs=..., -Wl,..., -L...).
printf '%s\n' "$@" >"$rsp.raw"
sed -E \
    -e "s#(^|[=,]|^-[LI])/opt/devkitpro#\\1${dkp_root}#g" \
    -e 's#(^|[=,]|^-[LI])/([a-zA-Z])/#\1\2:/#g' \
    -e "s#(^|[=,]|^-[LI])/(usr|tmp|etc)/#\\1${msys_root}/\\2/#g" \
    -e 's#\\#\\\\#g' \
    -e 's#"#\\"#g' \
    -e 's#^.*$#"&"#' \
    "$rsp.raw" >"$rsp"

"$compiler" "@$rsp"
