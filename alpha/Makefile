
image:
	docker compose build alpha

test:
	./sh/run_tests_with_coverage.sh

lint:
	docker run --rm --volume=./code:/app cyberdojo/rubocop --raise-cop-error

run: image
	docker compose up --detach alpha
