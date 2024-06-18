
image:
	docker compose build webapp

test: image
	docker compose run webapp coverage

build: image
	docker compose run webapp build

run: image
	docker compose up --detach webapp

stop: image
	docker compose stop webapp
