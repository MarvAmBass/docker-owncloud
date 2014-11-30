#/bin/bash

if [ -z ${OWNCLOUD_MYSQL_HOST+x} ]
then
  OWNCLOUD_MYSQL_HOST=mysql
fi

if [ -z ${OWNCLOUD_MYSQL_PORT+x} ]
then
  OWNCLOUD_MYSQL_PORT=3306
fi

if [ -z ${OWNCLOUD_MYSQL_DBNAME+x} ]
then
  OWNCLOUD_MYSQL_DBNAME=owncloud
fi

if [ -z ${OWNCLOUD_MYSQL_PREFIX+x} ]
then
  OWNCLOUD_MYSQL_PREFIX="oc_"
fi

echo ">> set MYSQL Host: $OWNCLOUD_MYSQL_HOST"
#sed -i "s/OWNCLOUD_MYSQL_HOST/$OWNCLOUD_MYSQL_HOST/g" /piwik/config/config.ini.php

echo ">> set MYSQL Port: $OWNCLOUD_MYSQL_PORT"
#sed -i "s/OWNCLOUD_MYSQL_PORT/$OWNCLOUD_MYSQL_PORT/g" /piwik/config/config.ini.php

echo ">> set MYSQL User: <hidden>"
#sed -i "s/OWNCLOUD_MYSQL_USER/$OWNCLOUD_MYSQL_USER/g" /piwik/config/config.ini.php

echo ">> set MYSQL Password: <hidden>"
#sed -i "s/OWNCLOUD_MYSQL_PASSWORD/$OWNCLOUD_MYSQL_PASSWORD/g" /piwik/config/config.ini.php

echo ">> set MYSQL DB Name: $OWNCLOUD_MYSQL_DBNAME"
#sed -i "s/OWNCLOUD_MYSQL_DBNAME/$OWNCLOUD_MYSQL_DBNAME/g" /piwik/config/config.ini.php

echo ">> set MYSQL Prefix: $OWNCLOUD_MYSQL_PREFIX"
#sed -i "s/OWNCLOUD_MYSQL_PREFIX/$OWNCLOUD_MYSQL_PREFIX/g" /piwik/config/config.ini.php


if [ -z ${OWNCLOUD_RELATIVE_URL_ROOT+x} ]
then
  OWNCLOUD_RELATIVE_URL_ROOT="/owncloud/" 
fi

echo ">> making owncloud available beneath: $OWNCLOUD_RELATIVE_URL_ROOT"
mkdir -p "/usr/share/nginx/html$OWNCLOUD_RELATIVE_URL_ROOT"
cp -a /var/www/owncloud/* "/usr/share/nginx/html$OWNCLOUD_RELATIVE_URL_ROOT"
chown -R www-data:www-data "/usr/share/nginx/html$OWNCLOUD_RELATIVE_URL_ROOT"
