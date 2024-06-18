
image:
	docker compose build alpha

test: image
	./sh/run_tests_with_coverage.sh

lint:
	docker run --rm --volume=./app:/app --volume=./config:/config cyberdojo/rubocop --raise-cop-error

run: image
	docker compose up --detach alpha
