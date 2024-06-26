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
#   curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
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
  for dependent in "$@"
  do
    if ! installed "${dependent}" ; then
      stderr "${dependent}" is not installed
      exit 42
    fi
  done
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

exit_non_zero_unless_installed docker act gh

act \
  --secret=GITHUB_TOKEN="$(gh auth token)" \
  --secret-file=.act.secrets \
  --var-file=.act.variables
