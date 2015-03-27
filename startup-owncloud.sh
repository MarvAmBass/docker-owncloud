#/bin/bash

###
# Variables
###

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

if [ -z ${OWNCLOUD_MYSQL_USER+x} ] || [ -z ${OWNCLOUD_MYSQL_PASSWORD+x} ]
then
  echo ">> using SQLite"
else
  echo ">> set MYSQL Host: $OWNCLOUD_MYSQL_HOST"
  echo ">> set MYSQL Port: $OWNCLOUD_MYSQL_PORT"
  echo ">> set MYSQL User: <hidden>"
  echo ">> set MYSQL Password: <hidden>"
  echo ">> set MYSQL DB Name: $OWNCLOUD_MYSQL_DBNAME"
fi

if [ -z ${OWNCLOUD_RELATIVE_URL_ROOT+x} ]
then
  OWNCLOUD_RELATIVE_URL_ROOT="/"
fi

###
# Pre Install
###

if [ ! -z ${OWNCLOUD_HSTS_HEADERS_ENABLE+x} ]
then
  echo ">> HSTS Headers enabled"
  sed -i 's/#add_header Strict-Transport-Security/add_header Strict-Transport-Security/g' /etc/nginx/conf.d/nginx-owncloud.conf

  if [ ! -z ${OWNCLOUD_HSTS_HEADERS_ENABLE_NO_SUBDOMAINS+x} ]
  then
    echo ">> HSTS Headers configured without includeSubdomains"
    sed -i 's/; includeSubdomains//g' /etc/nginx/conf.d/nginx-owncloud.conf
  fi
else
  echo ">> HSTS Headers disabled"
fi

###
# Install
###

echo ">> enable ./occ script"
chmod a+x /owncloud/occ

echo ">> making owncloud available beneath: $OWNCLOUD_RELATIVE_URL_ROOT"
mkdir -p "/usr/share/nginx/html$OWNCLOUD_RELATIVE_URL_ROOT" 

# copy everything except data directory
cd /var/www/; tar cf - --exclude='owncloud/data/' owncloud | ( cd / ; tar xfp -); cd /

# copy data directory if necessary
if [ ! -e /owncloud/data/.ocdata ]
then
  echo ">> first start: copy data directory"
  cd /var/www/
  tar cf - owncloud/data | ( cd / ; tar xfp -)
  cd /
fi

# fix rights
chown -R www-data:www-data /owncloud

# adding softlink for nginx connection
echo ">> adding softlink from /owncloud to $OWNCLOUD_RELATIVE_URL_ROOT"
mkdir -p "/usr/share/nginx/html$OWNCLOUD_RELATIVE_URL_ROOT"
rm -rf "/usr/share/nginx/html$OWNCLOUD_RELATIVE_URL_ROOT"
ln -s /owncloud $(echo "/usr/share/nginx/html$OWNCLOUD_RELATIVE_URL_ROOT" | sed 's/\/$//')

###
# Post Install
###

if [ -e /owncloud/config/config.php ]
then
  echo ">> owncloud already configured - skipping initialization"
  exit 0
fi

if [ ! -z ${OWNCLOUD_DO_NOT_INITIALIZE+x} ]
then
  echo ">> OWNCLOUD_DO_NOT_INITIALIZE set - skipping initialization"
  exit 0
fi

###
# Headless initialization
###
echo ">> initialization"
echo ">> starting nginx to configure owncloud"
sleep 1
nginx > /dev/null 2> /dev/null &
sleep 1

## Update Database if this is run after an update
echo ">> update database if necessary"
cd /usr/share/nginx/html$OWNCLOUD_RELATIVE_URL_ROOT
chmod a+x occ
sudo -u www-data ./occ upgrade
cd -

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

echo ">> using wget to post data to owncloud"
wget -O - --no-check-certificate --no-proxy --post-data "$POST" https://localhost$OWNCLOUD_RELATIVE_URL_ROOT\index.php > /dev/null 2> /dev/null

echo ">> killing nginx - done with configuration"
sleep 1
killall nginx
echo ">> finished initialization"
