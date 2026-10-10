#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat <<EOF
Usage: $0 {patch|minor|major|pre} [-b]

Bump the version in package.json and package-lock.json.

Commands:
  patch              Increment the patch version
  minor              Increment the minor version
  major              Increment the major version
  pre                Increment the existing beta number

Options:
  -b                 Add beta.1 to a patch, minor, or major bump
  -h, --help         Show this help message

Examples:
  $0 patch
  $0 minor -b
  $0 pre
EOF
}

if [[ $# -eq 1 && ("$1" == "-h" || "$1" == "--help") ]]; then
    usage
    exit 0
fi

if [[ $# -lt 1 || $# -gt 2 ]]; then
    usage
    exit 1
fi

BUMP_TYPE="$1"
shift
BETA=false

if [[ $# -gt 0 ]]; then
    if [[ "$1" != "-b" ]]; then
        usage
        exit 1
    fi

    BETA=true
fi

case "$BUMP_TYPE" in
    patch|minor|major|pre)
        ;;
    *)
        echo "Error: invalid bump type '$BUMP_TYPE'"
        usage
        exit 1
        ;;
esac

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PACKAGE_JSON="$ROOT_DIR/package.json"
PACKAGE_LOCK_JSON="$ROOT_DIR/package-lock.json"

CURRENT_VERSION="$(jq -r '.version' "$PACKAGE_JSON")"

# Validate and extract current version
if [[ "$BUMP_TYPE" == "pre" ]]; then
    if [[ "$CURRENT_VERSION" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)-beta\.([0-9]+)$ ]]; then
        MAJOR="${BASH_REMATCH[1]}"
        MINOR="${BASH_REMATCH[2]}"
        PATCH="${BASH_REMATCH[3]}"
        BETA_VERSION="${BASH_REMATCH[4]}"
    else
        echo "Error: pre bump requires an existing beta version: $CURRENT_VERSION"
        exit 1
    fi
elif [[ "$CURRENT_VERSION" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    MAJOR="${BASH_REMATCH[1]}"
    MINOR="${BASH_REMATCH[2]}"
    PATCH="${BASH_REMATCH[3]}"
else
    echo "Error: invalid existing version: $CURRENT_VERSION"
    exit 1
fi

# Calculate next version
case "$BUMP_TYPE" in
    patch)
        PATCH=$((PATCH + 1))
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    pre)
        BETA_VERSION=$((BETA_VERSION + 1))
        ;;
esac

NEXT_VERSION="$MAJOR.$MINOR.$PATCH"

if [[ "$BETA" == true ]]; then
    if [[ "$BUMP_TYPE" == "pre" ]]; then
        echo "Error: pre bump already targets a beta version; do not use -b"
        exit 1
    fi
    NEXT_VERSION="$NEXT_VERSION-beta.1"
elif [[ "$BUMP_TYPE" == "pre" ]]; then
    NEXT_VERSION="$NEXT_VERSION-beta.$BETA_VERSION"
fi

# Update package.json and package-lock.json
jq --arg version "$NEXT_VERSION" \
    '.version = $version' \
    "$PACKAGE_JSON" > "$PACKAGE_JSON.tmp"

mv "$PACKAGE_JSON.tmp" "$PACKAGE_JSON"

jq --arg version "$NEXT_VERSION" \
    '.version = $version
     | .packages[""].version = $version' \
    "$PACKAGE_LOCK_JSON" > "$PACKAGE_LOCK_JSON.tmp"

mv "$PACKAGE_LOCK_JSON.tmp" "$PACKAGE_LOCK_JSON"

# git tag
git add "$PACKAGE_JSON" "$PACKAGE_LOCK_JSON"
git commit -m "chore(version): $NEXT_VERSION"
# git tag will trigger after build success in github ci

echo
echo "Version bumped successfully:"
echo "  Version:     $CURRENT_VERSION -> $NEXT_VERSION"
