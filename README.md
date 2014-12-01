# Docker OwnCloud Container (marvambass/owncloud)
_maintained by MarvAmBass_

## What is it

This Dockerfile (available as ___marvambass/owncloud___) gives you a completly secure owncloud.

It's based on the [marvambass/nginx-ssl-php](https://registry.hub.docker.com/u/marvambass/nginx-ssl-php/) Image

View in Docker Registry [marvambass/owncloud](https://registry.hub.docker.com/u/marvambass/owncloud/)

View in GitHub [MarvAmBass/docker-owncloud](https://github.com/MarvAmBass/docker-owncloud)

## Environment variables and defaults

### For Headless installation required

OwnCloud Database Settings

* __OWNCLOUD\_MYSQL\_USER__
 * no default - if null it will start piwik in initial mode
* __OWNCLOUD\_MYSQL\_PASSWORD__
 * no default - if null it will start piwik in initial mode
* __OWNCLOUD\_MYSQL\_HOST__
 * default: _mysql_
* __OWNCLOUD\_MYSQL\_PORT__
 * default: _3306_ - if you use a different mysql port change it
* __OWNCLOUD\_MYSQL\_DBNAME__
 * default: _owncloud_
 
OwnCloud Admin Settings

* __OWNCLOUD\_ADMIN__
 * default: _admin_ - the name of the admin user
* __OWNCLOUD\_ADMIN\_PASSWORD__
 * default: <randomly generated 10 characters> - the password for the admin user

OwnCloud Site Settings

* __OWNCLOUD\_RELATIVE\_URL\_ROOT__
 * default: _/_ - you can chance that to whatever you want/need
 
### Inherited Variables

* __DH\_SIZE__
 * default: 1024 fast but a bit insecure. if you need more security just use a higher value
 * inherited from [MarvAmBass/docker-nginx-ssl-secure](https://github.com/MarvAmBass/docker-nginx-ssl-secure)

## Using the marvambass/piwik Container

First you need a running MySQL Container (you could use: [marvambass/mysql](https://registry.hub.docker.com/u/marvambass/mysql/)).

You need to _--link_ your mysql container to marvambass/piwik with the name __mysql__

    docker run -d -p 443:443 --link mysql:mysql --name owncloud marvambass/owncloud
