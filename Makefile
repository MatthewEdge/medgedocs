APP=medgedocs

.PHONY: up
up:
	docker build -t ${APP} .
	docker run --rm -d -v ${PWD}:/usr/src/app -p 8000:8000 ${APP}

.PHONY: down
down:
	docker ps | grep ${APP} | awk '{print $$1}' | xargs docker rm -f
