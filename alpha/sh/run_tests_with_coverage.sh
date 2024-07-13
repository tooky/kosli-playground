#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(git rev-parse --show-toplevel)/alpha"
export SH_DIR="${ROOT_DIR}/sh"

source "${SH_DIR}/containers_up_healthy_and_clean.sh"
source "${SH_DIR}/test_in_containers.sh"
source "${SH_DIR}/echo_env_vars.sh"
# shellcheck disable=SC2046
export $(echo_env_vars)

run_tests_with_coverage()
{
  mkdir "${ROOT_DIR}/test/reports" || true
  server_up_healthy_and_clean
  test_in_containers "$@"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  run_tests_with_coverage "$@"
fi
