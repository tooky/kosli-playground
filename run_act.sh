#!/usr/bin/env bash
set -Eeu

# brew install act
#   when running act for the first time, select Medium

# gh auth login --scopes=write:packages
#  > GitHub.com
#  > I want to re-authenticate   (y)
#  > HTTPS
#  > Authenticate Git with your GitHub credentials? (Y)
#  > Login with a web browser
#  copy the code into the browser page
#  hit return
#  enter the code in the web-browser
#  click [continue] button
#  click [authorize github] button

./bin/act \
  --secret=GITHUB_TOKEN="$(gh auth token)" \
  --secret-file=.act.secrets


# To uninstall act
# rm -rf "~/Library/Application Support/act"
