#!/usr/bin/env bash
set -Eeu

# Script to run github CI pipelines locally using act
# https://github.com/nektos/act

# INSTALL DOCKER
# --------------
# I'm assuming docker is already installed.

# INSTALL ACT
# -----------
# $ brew install act

# If you install using the bash command provided at https://nektosact.com/installation/index.html#bash-script
# Viz:  curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
# Then to uninstall act on a MacBook I had to do this:
# rm -rf "~/Library/Application Support/act"

# When running act for the first time, you have a choice of "level"
#   - Large: supports a lot of github actions, a massive image
#   - Medium: support the most common github actions, much smaller image
#   - Small: the barest image for bootstrapping
# Small does not work for the actions we have in the CI pipeline (eg docker/build-push-action)
# Medium does work for all the actions we need, so select that to get started faster.

# INSTALL GH
# ----------
# Needed for the $(gh auth token) below
# The token needs permission to push to the ghcr registry.
# This is not in the default set of token scopes.
# So you need to get a token that explicitly requests this scope.

# $ gh auth login --scopes=write:packages
#   > GitHub.com
#   > I want to re-authenticate (y)
#   > HTTPS
#   > Authenticate Git with your GitHub credentials? (Y)
#   > Login with a web browser
#   copy the code into the browser page
#   hit return
#   enter the code in the web-browser
#   click [continue] button
#   click [authorize github] button

exit_non_zero_unless_installed()
{
  local -r dependent="${1}"
  local -r url="${2}"
  if ! installed "${dependent}" ; then
    stderr "${dependent} is not installed!"
    stderr "Installation instructions are here: ${url}"
    exit 42
  fi
}

installed()
{
  local -r dependent="${1}"
  echo -n "Checking: is ${dependent} installed? "
  if hash "${dependent}" 2> /dev/null; then
    echo "yes"
    true
  else
    echo "NO"
    false
  fi
}

stderr()
{
  local -r message="${1}"
  >&2 echo "ERROR: ${message}"
}

exit_non_zero_unless_installed docker https://docs.docker.com/engine/install/
exit_non_zero_unless_installed act    https://nektosact.com/installation/index.html
exit_non_zero_unless_installed gh     https://github.com/cli/cli#installation

# https://stackoverflow.com/questions/68772807/check-scopes-of-github-token
GITHUB_TOKEN=$(gh auth token)
set +e
curl -sS -f -I -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com \
  | grep ^x-oauth-scopes: \
  | cut -d' ' -f2- \
  | tr -d "[:space:]" \
  | tr ',' '\n' \
  | grep -q write:packages
STATUS=$?
set -e

if [ "${STATUS}" != "0" ]; then
  stderr "Your GITHUB_TOKEN does not have 'write:packages' scope."
  stderr "You can reset a token's scopes with the command:"
  stderr "$ gh auth login --scopes=write:packages"
  exit 42
fi

# Recreate .env file with correct image-tag so it matches those used in the CI pipeline's docker/build-push-action
# This is needed to ensure that a local "docker compose up" uses images that have a repo digest.
export ROOT_DIR="$(git rev-parse --show-toplevel)"
# Note: don't put quotes around the $() expressions in these two export as it breaks on bash on a MacBook
export $(cat "${ROOT_DIR}/.env")
export $(cat "${ROOT_DIR}/.act.variables")
IMAGE_TAG="$(git rev-parse --short=7 HEAD)"
{
  echo "# this file was auto-created by the ./run_ci_locally.sh script"
  echo ALPHA_IMAGE="${DOCKER_REGISTRY}/${DOCKER_ORG_NAME}/${REPO_NAME}-alpha:${IMAGE_TAG}"
  echo ALPHA_CONTAINER_NAME=alpha_server
  echo ALPHA_PORT=4500
  echo ALPHA_USER=nobody
  echo BETA_IMAGE="${DOCKER_REGISTRY}/${DOCKER_ORG_NAME}/${REPO_NAME}-beta:${IMAGE_TAG}"
  echo BETA_CONTAINER_NAME=beta_server
  echo BETA_PORT=4501
  echo BETA_USER=nobody
  echo WEBAPP_PORT=4502
} > "${ROOT_DIR}/.env"

act \
  --secret=GITHUB_TOKEN="${GITHUB_TOKEN}" \
  --secret-file=.act.secrets \
  --var-file=.act.variables
