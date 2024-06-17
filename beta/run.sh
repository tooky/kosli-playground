#!/usr/bin/env bash
set -Eeu

# TODO: ensure this can be run from any directory
docker build . -t playground/beta
docker run -p4501:4501 playground/beta
