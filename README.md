# Kosli Playground

A playground for learning how to implement Kosli.

This is a very simple demo application. It is made up of three components:

- WebApp: a single-page javascript web app.
- Alpha: a Ruby based API service
- Beta: a Ruby based API service

This repo is a monorepo with each component in its own directory with its own Makefile.
Each component has an independent GitHub Actions workflow. 
Each workflow will trigger when changes to the relevant component are pushed to the main branch.
Each workflow fakes the deployment step by doing a "docker compose up"


# Setting up

## Fork this repo

## Log into Kosli at https://app.kosli.com using GitHub

This will create a Personal Kosli Organization whose name is your GitHub username.

## At https://app.kosli.com create a Docker Environment

This is the Kosli Environment that will record what is running in the "docker compose up" fake deployment.
- Select `Environments` from left hand side menu
- Click the blue `[Add new environment]` button at the top
- Fill in the Name field as `playground-prod`
- Check the `Docker host` radio button for the Type
- Fill in the `Description` field
- Leave `Exclude scaling events` checked
- Leave `Compliance Calculation Off`
- Click the blue `[Save environment]` button

## Set the variables in the `.env` file at the root of the repo

- DOCKER_ORG_NAME to your GitHub username
- REPO_NAME if you changed from `playground`
- KOSLI_ORG to the name of your Kosli personal Org

## Check you can build an image locally

```bash
cd alpha
make image
```
This should create an image called: `ghcr.io/${DOCKER_ORG_NAME}/playground-alpha:0c74d4c`
where `0c74d4c` will be the short-sha of your current HEAD commit.
```bash
make run
```
This should run the image locally, in a container, on port 4500.
Check you can reach `localhost:4500` in your browser.
It should show the string `Alpha` and nothing else.

## Create a KOSLI_API_TOKEN and save it as a Github Action secret

(Note: In a Shared Organization you would do this under a Service account) 
- At https://app.kosli.com click your github user icon at the top-right
- In the dropdown select `Profile`
- Click the blue `[+ Add API Key]` button
- Choose a value for the `API key expires in` or leave it as Never
- Fill in the `Description` field
- Click the blue `[Add]` button
- You will see the api-key, something like `p1Qv8TggcjOG_UX-WImP3Y6LAf2VXPNN_p9-JtFuHr0`
- Copy this api-key (Kosli stores a hashed version of this, so it will never be available from https://app.kosli.com again)
- Create a Github Action secret, called `KOSLI_API_TOKEN`, set to the copied value


# Make a change, commit, and push

- The repo is set up as a monorepo, with dirs called `alpha`, `beta`, and `webapp`
  for the three services. The `.github/workflows` files have `on: paths:` filters set, so they only run when
  there is a change in their respective directory (or the workflow file itself)

- Edit the file `alpha/code/alpha.rb` so the return string from the `'/'` route is something other than `Alpha`

- git add
- git commit
- git push

- The CI pipeline should run successfully. The fake `deploy:` job runs this command:
  ```yml
  docker compose up ${{ env.SERVICE_NAME }} --wait
  ```
  After this command, the CI pipeline has a step to install the Kosli CLI, and then runs this command:
  ```yml
  kosli snapshot docker "${KOSLI_ENVIRONMENT_NAME}"
  ```
  This takes a snapshot of the docker containers currently running (inside the CI pipeline)
  and sends their image names and digests/fingerprints to the named Environment in Kosli.
  Note that this command does _not_ need to set the `--org`, or `--api-token` flags because
  the `KOSLI_ORG` and `KOSLI_API_TOKEN` environment variables have been set at the top of the workflow yml file.

- At https://app.kosli.com, verify your `playground-prod` Environment now has a single snapshot
(hit refresh in your browser) showing the `playground-alpha` service running.
The image tag should be the short-sha of your new HEAD commit. 



