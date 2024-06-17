#!/usr/bin/env bash
set -Eeu

# TODO: ensure this can be run from any directory
docker build . -t playground/alpha
docker run -p4500:4500 playground/alpha
