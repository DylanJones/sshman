#!/bin/sh
# What to call a release of the commit checked out here, from the version in
# Cargo.toml and the tags the repository already has.
#
#   0.1.1           the first commit of 0.1.1: no v0.1.1 tag yet, so this
#                   commit becomes it
#   0.1.1           a v0.1.1 tag someone pushed by hand, on this commit
#   0.1.1-abc1234   any later commit, while Cargo.toml still says 0.1.1
#
# Prints `name=…` and `prerelease=…` lines, for $GITHUB_OUTPUT. Needs the
# repository's tags, so check out with `fetch-depth: 0`.
set -eu

version=$(sed -n 's/^version = "\(.*\)"$/\1/p' Cargo.toml | head -n 1)
if [ -z "$version" ]; then
    echo "no version in Cargo.toml" >&2
    exit 1
fi

head=$(git rev-parse HEAD)
if tagged=$(git rev-parse -q --verify "refs/tags/v$version^{commit}"); then
    if [ "$tagged" = "$head" ]; then
        name=$version
    else
        name=$version-$(git rev-parse --short=7 HEAD)
    fi
else
    name=$version
fi

case $name in
    *-*) prerelease=true ;;
    *) prerelease=false ;;
esac

echo "name=$name"
echo "prerelease=$prerelease"
