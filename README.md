## project description

A super light docker web server with Apache and php on top of Alpine Linux for development purposes

- Apache 2.4.43 with SSL
- php 7.3.17
- Xdebug debugging from host
- composer
- zsh

The docker image size is 59 MB.

## cool features

- Apache and php configuration files are exposed on the host.
- Just works with any domain name.
- https is configured out of the box.
- All changes to the config files are automatically applied (hot reload).
- Xdebug is configured for remote debugging (no headaches).

## start container

    docker-compose up

## access website

    http://localhost/
    https://localhost/

## set domain name

To set the domain name to www.test.com, edit the environment variable in the docker-compose file

    environment:
      - DOMAIN=www.test.com

Then edit the system host file (C:\Windows\System32\drivers\etc\hosts). Editing the file requires administrator privileges.

    127.0.0.1 test.net
    127.0.0.1 www.test.net

To access the site

    http://www.test.net:8000/
    https://www.test.net:8001/

## https

To remove "Your connection is not private" nag screens, import the certificate authority file ssl/certificate_authority.pem in your browser's certificates under Trusted Root Certification Authorities. (https://support.globalsign.com/digital-certificates/digital-certificate-installation/install-client-digital-certificate-windows-using-chrome)

## Xdebug

The docker image is fully configured to debug php code from the PC.
In the Xdebug client on the computer set the variables as follows:

    host: 127.0.0.1
    port: 9000
    path mapping: "/var/www/site/" : "$GIT_ROOT/dev/"

For path mapping, $GIT_ROOT is the absolute path to where you cloned this
repository in.

## build docker image

    docker build -t apache-php-alpine:dev .

## get console to container

    docker exec -it lamp zsh

## extend the docker image

In this example, we add the php-curl extension.

    docker-compose up --detach
    docker exec -it lamp zsh
    apk add php-curl
    exit
    docker-compose stop
    docker commit lamp apache-php-alpine-curl:dev

To use the new image, run it or update the image link in the docker-compose file.
