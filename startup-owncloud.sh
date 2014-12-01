#/bin/bash

if [ -z ${OWNCLOUD_IMAP_HOST+x} ]
then
  OWNCLOUD_IMAP_HOST=mail
fi

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

if [ -z ${OWNCLOUD_ADMIN+x} ]
then
  OWNCLOUD_ADMIN="admin"
  echo ">> owncloud admin user: $OWNCLOUD_ADMIN"
fi

if [ -z ${OWNCLOUD_ADMIN_PASSWORD+x} ]
then
  OWNCLOUD_ADMIN_PASSWORD=`perl -e 'my @chars = ("A".."Z", "a".."z"); my $string; $string .= $chars[rand @chars] for 1..10; print $string;'`
  echo ">> generated owncloud admin password: $OWNCLOUD_ADMIN_PASSWORD"
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

if [ -z ${OWNCLOUD_RELATIVE_URL_ROOT+x} ]
then
  OWNCLOUD_RELATIVE_URL_ROOT="/" 
fi

echo ">> making owncloud available beneath: $OWNCLOUD_RELATIVE_URL_ROOT"
mkdir -p "/usr/share/nginx/html$OWNCLOUD_RELATIVE_URL_ROOT"
cp -a /var/www/owncloud/* "/usr/share/nginx/html$OWNCLOUD_RELATIVE_URL_ROOT"
chown -R www-data:www-data "/usr/share/nginx/html$OWNCLOUD_RELATIVE_URL_ROOT"

# headless installation
if [ $(mysql -h $OWNCLOUD_MYSQL_HOST -P $OWNCLOUD_MYSQL_PORT -u $OWNCLOUD_MYSQL_USER -p$OWNCLOUD_MYSQL_PASSWORD $OWNCLOUD_MYSQL_DBNAME -e "show tables;" 2> /dev/null | wc -l) -lt 10 ]
then
  sleep 1
  nginx > /dev/null 2> /dev/null &
  sleep 1
	## Create OwnCloud Installation
	echo ">> init owncloud installation"
	DATA_DIR=/usr/share/nginx/html$OWNCLOUD_RELATIVE_URL_ROOT\data

  if [ -z ${OWNCLOUD_MYSQL_USER+x} ] || [ -z ${OWNCLOUD_MYSQL_PASSWORD+x} ]
  then
    echo ">> using sqlite DB"
  	DB_TYPE="sqlite"
  	POST=`echo "install=true&adminlogin=$OWNCLOUD_ADMIN&adminpass=$OWNCLOUD_ADMIN_PASSWORD&adminpass-clone=$OWNCLOUD_ADMIN_PASSWORD&directory=$DATA_DIR&dbtype=$DB_TYPE&dbuser=&dbpass=&dbpass-clone=&dbname=&dbhost=localhost"`
  else
    echo ">> using mysql DB"
  	DB_TYPE="mysql"
  	POST=`echo "install=true&adminlogin=$OWNCLOUD_ADMIN&adminpass=$OWNCLOUD_ADMIN_PASSWORD&adminpass-clone=$OWNCLOUD_ADMIN_PASSWORD&directory=$DATA_DIR&dbtype=$DB_TYPE&dbuser=$OWNCLOUD_MYSQL_USER&dbpass=$OWNCLOUD_MYSQL_PASSWORD&dbpass-clone=$OWNCLOUD_MYSQL_PASSWORD&dbname=$OWNCLOUD_MYSQL_DBNAME&dbhost=$OWNCLOUD_MYSQL_HOST:$OWNCLOUD_MYSQL_PORT"`
  fi
  
	echo "# wget -O - --no-check-certificate --no-proxy --post-data \"$POST\" "https://localhost$OWNCLOUD_RELATIVE_URL_ROOT\index.php
  wget -O - --no-check-certificate --no-proxy --post-data "$POST" https://localhost$OWNCLOUD_RELATIVE_URL_ROOT\index.php > /dev/null 2> /dev/null
  
	sleep 1
	killall nginx
else
	echo ">> owncloud db already installed"
	# update db server
	sed -i "s/.*'dbhost' \=>.*/  'dbhost' => '$OWNCLOUD_MYSQL_HOST:$OWNCLOUD_MYSQL_PORT',/g" /var/www/owncloud/config/config.php
	# update mail server
	sed -i "s/{.*:993/{$OWNCLOUD_IMAP_HOST:993/g" /var/www/owncloud/config/config.php
fi
