#!/usr/bin/env bash
set -Eeu

# Script to run github CI pipelines locally using act
# https://github.com/nektos/act

# $ brew install act
# When running act for the first time, you have a choice of "level"
#   - Large: supports a lot of github actions, a massive image
#   - Medium: support the most common github actions, much smaller image
#   - Small: the barest image for bootstrapping
# Small does not work for the actions we have in the CI pipeline (eg docker/build-push-action)
# Medium does work for all the actions we need, so select that to get started faster.

# Install gh
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

./bin/act \
  --secret=GITHUB_TOKEN="$(gh auth token)" \
  --secret-file=.act.secrets \
  --var-file=.act.variables


# To uninstall act on MacBook I had to
# rm -rf "~/Library/Application Support/act"
