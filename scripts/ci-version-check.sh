#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <target-branch>"
    exit 1
fi

TARGET_BRANCH="$1"
PACKAGE_JSON="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/package.json"
LOCAL_VERSION="$(jq -r '.version' "$PACKAGE_JSON")"

case "$TARGET_BRANCH" in
    main)
        if [[ "$LOCAL_VERSION" == *-beta.* ]]; then
            echo "::error::Beta version $LOCAL_VERSION is not allowed on main"
            exit 1
        fi
        ;;
    dev/*)
        if [[ "$LOCAL_VERSION" != *-beta.* ]]; then
            echo "::error::Version $LOCAL_VERSION must be a beta version on $TARGET_BRANCH"
            exit 1
        fi
        ;;
    *)
        echo "::error::Unsupported target branch: $TARGET_BRANCH"
        exit 1
        ;;
esac

REMOTE_VERSION="$(git ls-remote --tags --refs origin 'v*' \
    | sed 's|.*refs/tags/v||' | sort -V | tail -n1)"

echo "local=$LOCAL_VERSION remote=${REMOTE_VERSION:-none}" >&2

if [[ -n "$REMOTE_VERSION" ]]; then
    if [[ "$LOCAL_VERSION" == "$REMOTE_VERSION" ]]; then
        echo "::error::Version $LOCAL_VERSION is already released"
        exit 1
    fi

    HIGHEST_VERSION="$(printf '%s\n%s\n' "$REMOTE_VERSION" "$LOCAL_VERSION" | sort -V | tail -n1)"
    if [[ "$HIGHEST_VERSION" != "$LOCAL_VERSION" ]]; then
        echo "::error::Local $LOCAL_VERSION is lower than remote $REMOTE_VERSION"
        exit 1
    fi
fi

echo "version=$LOCAL_VERSION"
