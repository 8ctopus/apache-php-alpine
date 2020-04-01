## project description

A docker super light web server with Apache and php on top of Alpine Linux for development purposes

- apache 2.4.41
- php 7.3.16 with xdebug
- composer
- zsh

The docker image size is 65MB.

## cool features

- Apache and php configuration files are exposed on the host.
- All changes to the config files are automatically applied (hot reload).

## start container

    docker-compose up

    docker run -it -p 8000:80 8ct8pus/apache-php-alpine

## connect to web server

    http://localhost:8000/

## build docker image

    docker build -t 8ct8pus/apache-php-alpine:latest .

