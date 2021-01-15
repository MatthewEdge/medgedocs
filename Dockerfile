FROM python:3.9-alpine
RUN apk update && apk add build-base && \
  pip install mkdocs

WORKDIR /usr/src/app
COPY mkdocs.yml /usr/src/app/
COPY docs/ /usr/src/app/docs/

EXPOSE 8000
CMD mkdocs serve -a 0.0.0.0:8000
