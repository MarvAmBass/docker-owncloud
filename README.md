# Docker OwnCloud Container (marvambass/owncloud)
_maintained by MarvAmBass_

[FAQ - All you need to know about the marvambass Containers](https://marvin.im/docker-faq-all-you-need-to-know-about-the-marvambass-containers/)

## What is it

This Dockerfile (available as ___marvambass/owncloud___) gives you a completly secure owncloud.

It's based on the [marvambass/nginx-ssl-php](https://registry.hub.docker.com/u/marvambass/nginx-ssl-php/) Image

View in Docker Registry [marvambass/owncloud](https://registry.hub.docker.com/u/marvambass/owncloud/)

View in GitHub [MarvAmBass/docker-owncloud](https://github.com/MarvAmBass/docker-owncloud)

## Environment variables and defaults

### For Headless installation required

OwnCloud Install Settings

* __OWNCLOUD\_DO\_NOT_INITIALIZE__
 * not set by default - it set with any value, initialization process is skipped
 
OwnCloud Database Settings

* __OWNCLOUD\_MYSQL\_USER__
 * no default - if null it will use sqlite
* __OWNCLOUD\_MYSQL\_PASSWORD__
 * no default - if null it will use sqlite
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
* __OWNCLOUD\_HSTS\_HEADERS\_ENABLE__
 * default: not set - if set to any value the HTTP Strict Transport Security will be activated on SSL Channel
* __OWNCLOUD\_HSTS\_HEADERS\_ENABLE\_NO\_SUBDOMAINS__
 * default: not set - if set together with __OWNCLOUD\_HSTS\_HEADERS\_ENABLE__ and set to any value the HTTP Strict Transport Security will be deactivated on subdomains

### Inherited Variables

* __DH\_SIZE__
 * default: 1024 fast but a bit insecure. if you need more security just use a higher value
 * inherited from [MarvAmBass/docker-nginx-ssl-secure](https://github.com/MarvAmBass/docker-nginx-ssl-secure)

## Using the marvambass/owncloud Container

First you need a running MySQL Container (you could use: [marvambass/mysql](https://registry.hub.docker.com/u/marvambass/mysql/)).

You need to _--link_ your mysql container to marvambass/owncloud with the name __mysql__

    docker run -d -p 443:443 --link mysql:mysql --name owncloud marvambass/owncloud
    
## Fail2ban

You can use Fail2ban to block bruteforce password attacks.

In order to use Fail2ban you need to make your ___owncloud.log___ available on the outside.
This may be the regular case if you mapped __/owncloud/data__ to the outside.

### Fail2ban Filter

Now we need to create a new Fail2ban Filter to recognise bruteforce attacks on owncloud.
There are two kinds of Filters needed, which depends on your configuration.

__owncloud is directly available__

_/etc/fail2ban/filter.d/docker-owncloud-direct.conf_

    [Definition]
    failregex={.*Login failed:.*IP: '<HOST>',.*"}
    ignoreregex =

__owncloud is behind reverse proxy__

_/etc/fail2ban/filter.d/docker-owncloud-proxied.conf_

    [Definition]
    failregex={.*Login failed:.*X-Forwarded-For: '<HOST>'.*"}
    ignoreregex =
    
## Fail2ban Jail Config    

_/etc/fail2ban/jail.d/docker-owncloud.conf_

    [docker-owncloud-direct]
    enabled = false
    port    = http,https
    filter  = docker-owncloud-direct
    logpath = /var/docker-owncloud/data/owncloud.log
    maxretry = 3

    [docker-owncloud-proxied]
    enabled = false
    port    = http,https
    filter  = docker-owncloud-proxied
    logpath = /var/docker-owncloud/data/owncloud.log
    maxretry = 3
    
Just enable the suitable rule, check if the logpath is right you may also change maxretry and port to your needs.

Restart Fail2ban and that's all!
