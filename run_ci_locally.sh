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

repo_root()
{
  git rev-parse --show-toplevel
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

#if [ "${STATUS}" != "0" ]; then
#  stderr "Your GITHUB_TOKEN does not have 'write:packages' scope."
#  stderr "You can reset a token's scopes with the command:"
#  stderr "$ gh auth login --scopes=write:packages"
#  exit 42
#fi

SECRETS_FILENAME="$(repo_root)/.act.secrets"

if [ ! -f "${SECRETS_FILENAME}" ]; then
  # act does not check the existence of the file named in the --secret-file flag
  stderr "You need a file called .act.secrets at the root of your git repo"
  stderr "It needs to contain the KOSLI_API_TOKEN, in .env format"
  stderr "For example:"
  stderr "KOSLI_API_TOKEN=zGMiwXC28AHll6bqcv4VrCRwINQFl54IJKPQv5Vekqg"
  stderr ""
  stderr "Create your api-token in your Kosli profile page"
  stderr "Select 'Profile' from the drop-down menu under your user-icon at the top-right"
  stderr "Note: The .act.secrets file is .gitignore'd"
  exit 42
fi

if [ -n "$(git status -s)" ]; then
  stderr "You have uncommitted local changes"
  stderr "Commit the changes and then run ./run_ci_locally.sh"
  exit 42
fi

act \
  --secret=GITHUB_TOKEN="${GITHUB_TOKEN}" \
  --secret-file="${SECRETS_FILENAME}" \
  --var-file=.env
