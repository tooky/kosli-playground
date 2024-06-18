
image:
	docker build . --tag playground/alpha

test: image
	./sh/run_tests_with_coverage.sh

lint:
	docker run --rm --volume=./app:/app --volume=./config:/config cyberdojo/rubocop --raise-cop-error

run:
	./run.sh
