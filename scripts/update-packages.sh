#!/bin/sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
DEBS_DIR="$ROOT_DIR/debs"
PACKAGES_FILE="$ROOT_DIR/Packages"
PACKAGES_GZ_FILE="$ROOT_DIR/Packages.gz"
RELEASE_FILE="$ROOT_DIR/Release"
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/saveios6-packages.XXXXXX")
REPO_NAME=${REPO_NAME:-Lonsdaleite}
REPO_DESCRIPTION=${REPO_DESCRIPTION:-Lonsdaleite package repository}
REPO_SUITE=${REPO_SUITE:-stable}
REPO_CODENAME=${REPO_CODENAME:-ios6things}
REPO_VERSION=${REPO_VERSION:-1.0}
REPO_ARCHITECTURES=${REPO_ARCHITECTURES:-iphoneos-arm iphoneos-arm64}
REPO_COMPONENTS=${REPO_COMPONENTS:-main}

cleanup() {
    rm -rf "$TMP_DIR"
}

trap cleanup EXIT INT TERM

if [ ! -d "$DEBS_DIR" ]; then
    echo "Missing debs directory: $DEBS_DIR" >&2
    exit 1
fi

hash_md5() {
    if command -v md5sum >/dev/null 2>&1; then
        md5sum "$1" | awk '{print $1}'
    else
        md5 -q "$1"
    fi
}

hash_sha1() {
    if command -v sha1sum >/dev/null 2>&1; then
        sha1sum "$1" | awk '{print $1}'
    else
        shasum "$1" | awk '{print $1}'
    fi
}

hash_sha256() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    else
        shasum -a 256 "$1" | awk '{print $1}'
    fi
}

file_size() {
    if stat -c %s "$1" >/dev/null 2>&1; then
        stat -c %s "$1"
    else
        stat -f %z "$1"
    fi
}

rfc_2822_date() {
    LC_ALL=C date -u "+%a, %d %b %Y %H:%M:%S UTC"
}

append_release_entry() {
    file_path=$1
    file_name=$2

    printf ' %s %s %s\n' "$(hash_md5 "$file_path")" "$(file_size "$file_path")" "$file_name" >> "$RELEASE_FILE"
}

append_release_sha1_entry() {
    file_path=$1
    file_name=$2

    printf ' %s %s %s\n' "$(hash_sha1 "$file_path")" "$(file_size "$file_path")" "$file_name" >> "$RELEASE_FILE"
}

append_release_sha256_entry() {
    file_path=$1
    file_name=$2

    printf ' %s %s %s\n' "$(hash_sha256 "$file_path")" "$(file_size "$file_path")" "$file_name" >> "$RELEASE_FILE"
}

extract_control() {
    deb_file=$1
    extract_dir=$2

    control_archive=$(
        ar t "$deb_file" | awk '
            $0 ~ /^control\.tar(\.(gz|xz|bz2))?$/ { print; exit }
        '
    )

    if [ -z "$control_archive" ]; then
        echo "Could not find control archive in $deb_file" >&2
        exit 1
    fi

    case "$control_archive" in
        *.gz)
            ar p "$deb_file" "$control_archive" | tar -xzOf - ./control > "$extract_dir/control"
            ;;
        *.xz)
            ar p "$deb_file" "$control_archive" | tar -xJOf - ./control > "$extract_dir/control"
            ;;
        *.bz2)
            ar p "$deb_file" "$control_archive" | tar -xjOf - ./control > "$extract_dir/control"
            ;;
        control.tar)
            ar p "$deb_file" "$control_archive" | tar -xOf - ./control > "$extract_dir/control"
            ;;
        *)
            echo "Unsupported control archive format: $control_archive" >&2
            exit 1
            ;;
    esac
}

find "$DEBS_DIR" -maxdepth 1 -type f -name '*.deb' | sort > "$TMP_DIR/deb-list.txt"

: > "$PACKAGES_FILE"

while IFS= read -r deb_file; do
    [ -n "$deb_file" ] || continue

    pkg_tmp="$TMP_DIR/pkg"
    rm -rf "$pkg_tmp"
    mkdir -p "$pkg_tmp"

    extract_control "$deb_file" "$pkg_tmp"

    rel_path=${deb_file#"$ROOT_DIR"/}

    cat "$pkg_tmp/control" >> "$PACKAGES_FILE"
    printf 'Filename: %s\n' "$rel_path" >> "$PACKAGES_FILE"
    printf 'Size: %s\n' "$(file_size "$deb_file")" >> "$PACKAGES_FILE"
    printf 'MD5sum: %s\n' "$(hash_md5 "$deb_file")" >> "$PACKAGES_FILE"
    printf 'SHA1: %s\n' "$(hash_sha1 "$deb_file")" >> "$PACKAGES_FILE"
    printf 'SHA256: %s\n\n' "$(hash_sha256 "$deb_file")" >> "$PACKAGES_FILE"
done < "$TMP_DIR/deb-list.txt"

gzip -c "$PACKAGES_FILE" > "$PACKAGES_GZ_FILE"

cat > "$RELEASE_FILE" <<EOF
Origin: $REPO_NAME
Label: $REPO_NAME
Suite: $REPO_SUITE
Codename: $REPO_CODENAME
Version: $REPO_VERSION
Architectures: $REPO_ARCHITECTURES
Components: $REPO_COMPONENTS
Description: $REPO_DESCRIPTION
Date: $(rfc_2822_date)
MD5Sum:
EOF

append_release_entry "$PACKAGES_FILE" "Packages"
append_release_entry "$PACKAGES_GZ_FILE" "Packages.gz"

cat >> "$RELEASE_FILE" <<EOF
SHA1:
EOF

append_release_sha1_entry "$PACKAGES_FILE" "Packages"
append_release_sha1_entry "$PACKAGES_GZ_FILE" "Packages.gz"

cat >> "$RELEASE_FILE" <<EOF
SHA256:
EOF

append_release_sha256_entry "$PACKAGES_FILE" "Packages"
append_release_sha256_entry "$PACKAGES_GZ_FILE" "Packages.gz"

echo "Updated:"
echo "  $PACKAGES_FILE"
echo "  $PACKAGES_GZ_FILE"
echo "  $RELEASE_FILE"
