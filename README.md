## project description

A super light docker web server with Apache and php on top of Alpine Linux for development purposes

- Apache 2.4.52 with SSL
- php 8.0.14
- Xdebug 3.1.2 - debugger and profiler
- composer 2.1.12
- zsh 5.8

The docker image size is 59 MB.

## cool features

- Apache and php configuration files are exposed on the host.
- Just works with any domain name.
- https is configured out of the box.
- All changes to config files are automatically applied (hot reload).
- Xdebug is configured for remote debugging (no headaches).

## start container

Starting the container with `docker-compose` offers all functionalities.

```sh
# start container
docker-compose up

CTRL-Z to detach

# stop container
docker-compose stop
```

Alternatively the container can also be started with `docker run`.

```sh
docker run -p 80:80 --name web 8ct8pus/apache-php-alpine:latest
CTRL-Z to detach

docker stop container
```

## access website

    http://localhost/
    https://localhost/

The source code is located inside the `html` directory.

## set website domain name

To set the domain name to www.test.com, edit the environment variable in the docker-compose file

    environment:
      - DOMAIN=www.test.com

Add this line to the system host file. Editing the file requires administrator privileges.

    C:\Windows\System32\drivers\etc\hosts

    127.0.0.1 test.net www.test.net

## add https

To remove "Your connection is not private" nag screens, import the certificate authority file under ssl/certificate_authority.pem in the browser's certificates under Trusted Root Certification Authorities.

guide: https://support.globalsign.com/digital-certificates/digital-certificate-installation/install-client-digital-certificate-windows-using-chrome

## Xdebug debugger

This repository is configured to debug php code in Visual Studio Code.
To start debugging, open the VSCode workspace then select `Run > Start debugging` then open the site in the browser.

For other IDEs, set the Xdebug debugging port to 9001.

To troubleshoot debugger issues, check the `log\xdebug.log` file.

If `host.docker.internal` does not resolve within the container, update the xdebug client host within `etc\php\conf.d\xdebug.ini` to the docker host ip address.

```
xdebug.client_host          = 192.168.65.2
```

## Xdebug profiler

To start profiling, add the `XDEBUG_PROFILE` variable to the request as a GET, POST or COOKIE.

    http://localhost/?XDEBUG_PROFILE

Profiles are stored in the `log` directory and can be analyzed with tools such as [webgrind](https://github.com/jokkedk/webgrind).

## access container through command line

```sh
docker exec -it web zsh
```

## use development image

- build docker development image

`docker build -t apache-php-alpine:dev .`

- `rm -rf etc log ssl/localhost*`
- in docker-compose.yml

```yaml
services:
  web:
    # development image
    image: apache-php-alpine:dev
```

- `docker-compose up`
- open browser at `localhost`

## extend docker image

In this example, we add the php-curl extension.

```sh
docker-compose up --detach
docker exec -it web zsh
apk add php-curl
exit
docker-compose stop
docker commit web apache-php-alpine-curl:dev
```


## notes

In Windows hot reload doesn't work with WSL 2, you need to use the legacy Hyper-V.
