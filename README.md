# Kosli Playground

A playground for learning how to implement [Kosli](https://kosli.com)

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
- Switch `Compliance Calculation Require artifacts to have provenance` to `On`
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

## Check the env:DOCKER_ORG_NAME setting

- The `.github/workflows/alpha_main.yml` file has this near the top:
```yml
env:
  DOCKER_ORG_NAME: ${{ github.repository_owner }}
```
Docker Org names cannot contain uppercase characters.
There is currently no built-in Github Action function to convert uppercase to lowercase.
If `repository_owner` (your GitHub username) contains uppercase characters, edit this line to its lowercased value.
For example, if `repository_owner==JohnSmith`, then
```yml
env:
  DOCKER_ORG_NAME: johnsmith  # ${{ github.repository_owner }} converted to lowercase.
```

## Make a change, commit, and push

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
The playground-alpha Artifact is showing as Non-Compliant. 
This is because the Environment was set up to `Require artifacts to have provenance`
and this Artifact currently has no [provenance](https://www.kosli.com/blog/how-to-secure-your-software-supply-chain-with-artifact-binary-provenance/
).

## Make another change, commit, and push

- Re-edit the file `alpha/code/alpha.rb` so the return string from the `'/'` route is something other than `Alpha`
- git add
- git commit
- git push
- The CI pipeline should run successfully
- At https://app.kosli.com, verify your `playground-prod` Environment now has two snapshots


## Create a Kosli Flow and Trail

- Kosli attestations must be made against a Trail, living inside a Flow.
  - A Kosli flow represents a business or software process for which you want to track changes and monitor compliance.
  - A Kosli trail represents a single execution instance of a process represented by a Kosli flow. 
    Each trail must have a unique identifier of your choice, based on your process and domain. 
    Example identifiers include git commits or pull request numbers.
  
- At the top of the `.github/workflows/alpha_main.yml` file add two new `env:` variables for the
Kosli Flow (named after your repo) and Kosli Trail (named after each git-commit), as follows:
```yml
env:
  ...
  KOSLI_FLOW: playground-alpha-ci
  KOSLI_TRAIL: ${{ github.sha }}
```

- Still in `.github/workflows/alpha_main.yml`, add the following entries to the end of the `setup:` job
to install the Kosli CLI and create the Flow and Trail.
```yml
      - uses: actions/checkout@v4.1.1
        with:
          fetch-depth: 10

      - name: Setup the Kosli CLI
        uses: kosli-dev/setup-cli-action@v2
        with:
          version: ${{ vars.KOSLI_CLI_VERSION }}

      - name: Create Kosli Flow
        run:
          kosli create flow "${{ env.KOSLI_FLOW }}"
            --description="Diff files from two traffic-lights"
            --template-file=.kosli.yml

      - name: Begin Kosli Trail
        run:
          kosli begin trail "${{ env.KOSLI_TRAIL }}"
            --description="${{ github.actor }} - $(git log -1 --pretty=%B)"
```

- git add
- git commit
- git push

- Wait for the Github Action to complete
- In https://app.kosli.com, click `Flows` on the left hand side menu
- Click the Flow named `playground-alpha-ci`
- You should see a single Trail whose name is the repo's current HEAD commit
- This Trail will have no attestations
- Is there a new Snapshot in the `playground-prod` Environment?


## Attest the provenance of the Artifact in the CI pipeline

- In `.github/workflows/alpha_main.yml`, add the following entries to the end of the `build:` job
to install the Kosli CLI and attest the Artifact's digest/fingerprint.
```yml
      - name: Setup Kosli CLI
        uses: kosli-dev/setup-cli-action@v2
        with:
          version: ${{ vars.KOSLI_CLI_VERSION }}

      - name: Attest image provenance to Kosli Trail
        run: 
          kosli attest artifact "${needs.setup.outputs.image_name}" 
            --artifact-type=docker
            --name=alpha
```
- Note that the `kosli attest` command does not need to specify the `--org` or `--flow` or `--trail` flags because there are 
environment variables called `KOSLI_ORG`, `KOSLI_FLOW`, and `KOSLI_TRAIL`.
- There are two ways to provide a Docker image's digest/fingerprint to Kosli
  - The command above asks the Kosli CLI to calculate the fingerprint. To do this the CLI needs to be told
     the name of the Docker image (`${needs.setup.outputs.image_name}`), and that this is a Docker image
     (`--artifact-type=docker`). This option requires that the image has previously been pushed to its registry.
  - You can also provide the fingerprint directly using the `--fingerprint` flag or `KOSLI_FINGERPRINT` environment 
    variable. Simply capture it from the GitHub Action `docker/build-push-action@v5` digest output.
    ```yml
      - name: Attest image provenance to Kosli Trail
        run: | 
          DIGEST=$( echo ${{ steps.docker_build.outputs.digest }} | sed 's/.*://')
          kosli attest artifact "${needs.setup.outputs.image_name}" \
            --fingerprint="${DIGEST}" \
            --name=alpha
    ```

- git add
- git commit
- git push

- Open https://app.kosli.com to your `playground-alpha` Environment
- You will see a new Snapshot
- The Artifact will have Provenance


## View a deployment diff

- Re-edit the file `alpha/code/alpha.rb` so the return string from the `'/'` route is yet another new string
- git add
- git commit
- git push
- The CI pipeline should run successfully
- Open https://app.kosli.com to your `playground-alpha` Environment
- You will see a new Snapshot
- The Artifact will have Provenance
- Click the `>` chevron to reveal more information in a drop-down
- Click the link titled `View diff` in the entry called `Previous` to
see the deployment-diff; the commit-level diff between the currently running
alpha Artifact, and the alpha Artifact it replaced.



