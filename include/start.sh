#!/bin/sh

echo ""
echo "Start container web server..."

# set domain variable if not set
if [ $DOMAIN = "" ];
then
    $DOMAIN = "localhost"
fi

echo "domain: $DOMAIN"
echo "document root: $DOCUMENT_ROOT"

# check if we should expose apache2 to host
if [ -d /docker/etc/ ];
then
    echo "Expose apache2 to host..."
    sleep 3

    # check if directory empty
    if [ -z "$(ls -A /docker/etc/apache2 2> /dev/null)" ];
    then
        echo "Expose apache2 - copy files..."
        cp -r /etc/apache2/ /docker/etc/
        rm -rf /etc/apache2/
        ln -s /docker/etc/apache2 /etc/apache2
    else
        echo "Expose apache2 to host - config exists on host"
        rm -rf /etc/apache2/
        ln -s /docker/etc/apache2 /etc/apache2
    fi

    echo "Expose apache2 to host - OK"

    if [ ! -e /etc/ssl/apache2/$DOMAIN.pem ];
    then
        echo "Generate self-signed SSL certificate for $DOMAIN..."

        # generate self-signed SSL certificate
        openssl req -new -x509 -key /etc/ssl/apache2/server.key -out /etc/ssl/apache2/$DOMAIN.pem -days 3650 -subj /CN=$DOMAIN

        # use SSL certificate
        sed -i "s|SSLCertificateFile .*|SSLCertificateFile /etc/ssl/apache2/$DOMAIN.pem|g" /etc/apache2/conf.d/ssl.conf

        echo "Generate self-signed SSL certificate for $DOMAIN - OK"
    fi

    echo "Configure apache2 for domain..."

    # set document root dir
    sed -i "s|/var/www/localhost/htdocs|/var/www/site$DOCUMENT_ROOT|g" /etc/apache2/httpd.conf

    # set SSL document root dir
    sed -i "s|DocumentRoot \".*\"|DocumentRoot \"/var/www/site$DOCUMENT_ROOT\"|g" /etc/apache2/conf.d/ssl.conf

    sed -i "s|#ServerName .*:80|ServerName $DOMAIN:80|g" /etc/apache2/httpd.conf
    sed -i "s|ServerName .*:443|ServerName $DOMAIN:443|g" /etc/apache2/conf.d/ssl.conf

    echo "Configure apache2 for domain - OK"

    echo "Expose php7 to host..."
    sleep 3

    # check if directory empty
    if [ -z "$(ls -A /docker/etc/php7 2> /dev/null)" ];
    then
        echo "Expose php7 to host - copy files..."
        cp -r /etc/php7/ /docker/etc/
        rm -rf /etc/php7/
        ln -s /docker/etc/php7 /etc/php7
    else
        echo "Expose php7 to host - config exists on host"
        rm -rf /etc/php7/
        ln -s /docker/etc/php7 /etc/php7
    fi

    echo "Expose php7 to host - OK"
fi

# create xdebug log file
touch /var/log/apache2/xdebug.log

# allow xdebug to write to it
chmod 666 /var/log/apache2/xdebug.log

echo "-----------------------------------------------"

# start apache2
httpd -k start

# check if apache2 is running
if pgrep -x httpd > /dev/null
then
    echo "Start container web server - OK - ready for connections"
else
    echo "Start container web server - FAILED"
    exit
fi

stop_container()
{
    echo ""
    echo "Stop container web server... - received SIGTERM signal"

    # stop apache2
    echo "Stop apache2..."
    httpd -k stop
    echo "Stop apache2 - OK"

    echo "Stop container web server - OK"
    exit
}

# catch termination signals
# https://unix.stackexchange.com/questions/317492/list-of-kill-signals
trap stop_container SIGTERM

restart_apache2()
{
    sleep 0.5

    # test apache2 config
    if httpd -t
    then
        # restart apache2
        echo "Restart apache2..."
        httpd -k restart

        # check if apache2 is running
        if pgrep -x httpd > /dev/null
        then
            echo "Restart apache2 - OK"
        else
            echo "Restart apache2 - FAILED"
        fi
    else
        echo "Restart apache2 - FAILED - syntax error"
    fi
}

# infinite loop, will only stop on termination signal
while true; do
    # restart apache2 if any file in /etc/apache2 and /etc/php7 changes
    inotifywait --quiet --event modify,create,delete --timeout 3 --recursive /etc/apache2/ /etc/php7/ && restart_apache2
done
