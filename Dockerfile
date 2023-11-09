FROM alpine:latest

RUN apk update && apk upgrade
RUN apk add netcat-openbsd

WORKDIR /home

CMD sh

