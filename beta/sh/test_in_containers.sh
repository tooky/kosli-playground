
# - - - - - - - - - - - - - - - - - - - - - - - - - -
test_in_containers()
{
  local exit_code=0
  run_server_tests "${@:-}" || exit_code=$?
  return ${exit_code}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_server_tests()
{
  run_tests \
    "${ALPHA_USER}" \
    "${ALPHA_CONTAINER_NAME}" \
    server "${@:-}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_tests()
{
  local -r USER="${1}"           # eg nobody
  local -r CONTAINER_NAME="${2}" # eg beta_server
  local -r TYPE="${3}"           # eg server

  echo '=================================='
  echo "Running ${TYPE} tests"
  echo '=================================='

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Run tests (with branch coverage) inside the container.

  local -r COVERAGE_CODE_TAB_NAME=code
  local -r COVERAGE_TEST_TAB_NAME=test
  local -r CONTAINER_TMP_DIR=/tmp # fs is read-only with tmpfs at /tmp
  local -r CONTAINER_COVERAGE_DIR="${CONTAINER_TMP_DIR}/reports"
  local -r TEST_LOG=test.log

  set +e
  docker exec \
    --env COVERAGE_CODE_TAB_NAME=${COVERAGE_CODE_TAB_NAME} \
    --env COVERAGE_TEST_TAB_NAME=${COVERAGE_TEST_TAB_NAME} \
    --user "${USER}" \
    "${CONTAINER_NAME}" \
      sh -c "/app/test/lib/run.sh ${CONTAINER_COVERAGE_DIR} ${TEST_LOG} ${*:4}"

  local -r STATUS=$?
  set -e

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Extract test-run results and coverage data from the container.
  # You can't [docker cp] from a tmpfs, so tar-piping coverage out

  if [ "${TYPE}" = server ]; then
    local -r HOST_TEST_DIR="${ROOT_DIR}/test"
  else
    local -r HOST_TEST_DIR="${ROOT_DIR}/client/test"
  fi

  docker exec \
    "${CONTAINER_NAME}" \
    tar Ccf \
      "$(dirname "${CONTAINER_COVERAGE_DIR}")" \
      - "$(basename "${CONTAINER_COVERAGE_DIR}")" \
        | tar Cxf "${HOST_TEST_DIR}/" -

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Tell caller where the results are...
  local -r HOST_REPORTS_DIR="${HOST_TEST_DIR}/reports"
  mkdir -p "${HOST_REPORTS_DIR}"

  echo "${TYPE} test branch-coverage report is at"
  echo "${HOST_REPORTS_DIR}/index.html"
  echo "${TYPE} test status == ${STATUS}"
  echo
  if [ "${STATUS}" != 0 ]; then
    echo Docker logs "${CONTAINER_NAME}"
    echo
    docker logs "${CONTAINER_NAME}" 2>&1
  fi
  return ${STATUS}
}
