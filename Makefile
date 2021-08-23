APP=medgedocs
PORT=8000

.DEFAULT_GOAL := up

.PHONY: dist
dist:
	docker build -t ${APP} .
	docker run --rm -v ${PWD}:/usr/src/app ${APP} mkdocs build

.PHONY: up
up: down
	docker build -t ${APP} .
	docker run --rm -d -v ${PWD}:/usr/src/app -p ${PORT}:8000 ${APP} mkdocs serve -a 0.0.0.0:${PORT}
	@echo "Running at http://localhost:${PORT}"

.PHONY: down
down:
	docker ps | grep ${APP} | awk '{print $$1}' | xargs docker rm -f
