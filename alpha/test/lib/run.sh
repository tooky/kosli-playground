#!/usr/bin/env bash
set -Eeu

readonly MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export COVERAGE_ROOT="${1}" # /tmp/coverage
readonly TEST_LOG="${2}"    # test.log
shift; shift

readonly TEST_FILES=(${MY_DIR}/../*_test.rb)
readonly TEST_ARGS=(${@})

readonly SCRIPT="
require '${MY_DIR}/coverage.rb'
%w(${TEST_FILES[*]}).shuffle.each{ |file|
  require file
}"

export RUBYOPT='-W2'
mkdir -p ${COVERAGE_ROOT}

ruby -e "${SCRIPT}" -- ${TEST_ARGS[@]} 2>&1 | tee ${COVERAGE_ROOT}/${TEST_LOG}
grep -q "0 failures, 0 errors" ${COVERAGE_ROOT}/${TEST_LOG}
