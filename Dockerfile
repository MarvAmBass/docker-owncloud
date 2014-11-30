FROM marvambass/nginx-ssl-php
MAINTAINER MarvAmBass

ENV DH_SIZE 512

RUN apt-get update && apt-get install -y \
    mysql-client \
    php5-mysql \
    wget

# clean http directory
RUN rm -rf /usr/share/nginx/html/*

# install owncloud
RUN echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/community/Debian_7.0/ /' >> /etc/apt/sources.list.d/owncloud.list 
RUN wget -O - 'http://download.opensuse.org/repositories/isv:ownCloud:community/Debian_7.0/Release.key' | apt-key add -
RUN apt-get update && apt-get install -y \
    owncloud \
    mysql-client \
    php5-imap \
    sendmail

# optionals
RUN apt-get update && apt-get install -y --no-install-recommends \
    libreoffice

# install nginx owncloud config
ADD nginx-owncloud.conf /etc/nginx/conf.d/nginx-owncloud.conf

# enable php5 imap
RUN php5enmod imap

# upload limits
RUN sed -i 's/^post_max_size =.*/post_max_size = 0/g' /etc/php5/fpm/php.ini
RUN sed -i 's/^upload_max_filesize =.*/upload_max_filesize = 25G/g' /etc/php5/fpm/php.ini
RUN sed -i 's/^max_file_uploads =.*/max_file_uploads = 100/g' /etc/php5/fpm/php.ini

# add startup.sh
ADD startup-owncloud.sh /opt/startup-owncloud.sh
RUN chmod a+x /opt/startup-owncloud.sh

# add '/opt/startup-owncloud.sh' to entrypoint.sh
RUN sed -i 's/# exec CMD/# exec CMD\n\/opt\/startup-owncloud.sh/g' /opt/entrypoint.sh
