
export COMMIT_SHORT_SHA = $(shell git rev-parse --short=7 HEAD)

image:
	docker compose build beta

test: image
	./sh/run_tests_with_coverage.sh

lint:
	docker run --rm --volume=./code:/app cyberdojo/rubocop --raise-cop-error

run: image
	docker compose up --detach beta
