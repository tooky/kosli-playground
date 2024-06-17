#!/usr/bin/env bash
set -Eeu

readonly MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pushd "${MY_DIR}" &> /dev/null
trap "popd &> /dev/null" INT EXIT

docker build . -t playground/beta
docker run -p4501:4501 playground/beta
