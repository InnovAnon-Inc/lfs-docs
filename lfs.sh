#! /usr/bin/env bash
set -euxo pipefail

# configurable parameters
BASEDIR="${BASEDIR:-/usr/share/doc}"
VERSION="${VERSON:-9.1}"
SCRIPTDIR="$(dirname "$(readlink -f "$0")")"
REPODIR="${REPODIR:-$SCRIPTDIR}"

cd "$REPODIR"

# TODO **EDITME<whatever>EDITME**

script -e -c './read_book'

