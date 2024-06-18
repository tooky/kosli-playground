
image:
	docker build . --tag playground/alpha

lint:
	docker run --rm --volume=./app:/app --volume=./config:/config cyberdojo/rubocop --raise-cop-error

run:
	./run.sh

