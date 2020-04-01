## project description

A super light docker web server with Apache and php on top of Alpine Linux for development purposes

- Apache 2.4.41
- php 7.3.16 with Xdebug
- composer
- zsh

The docker image size is 65MB.

## cool features

- Apache and php configuration files are exposed on the host.
- All changes to the config files are automatically applied (hot reload).
- Xdebug is configured for remote debugging (no headaches).

## start container

    docker-compose up

    docker run -it -p 8000:80 8ct8pus/apache-php-alpine

## access website

    http://localhost:8000/

## Xdebug

The docker image is fully configured to debug php code from the PC.
In the Xdebug client on the computer set the variables as follows:

    host: 127.0.0.1
    port: 9000
    path mapping: "/var/www/site/" : "$GIT_ROOT/dev/"

For path mapping, $GIT_ROOT is the absolute path to where you cloned this
repository in.

## build docker image

    docker build -t 8ct8pus/apache-php-alpine:latest .
