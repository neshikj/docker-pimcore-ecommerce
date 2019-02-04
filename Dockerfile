FROM debian:stretch

RUN apt-get update && \
 DEBIAN_FRONTEND=noninteractive apt-get -y upgrade && \
 DEBIAN_FRONTEND=noninteractive apt-get -y install wget sudo supervisor pwgen apt-utils gnupg gnupg1 gnupg2 php-pear

# Import the signing key and enable the PPA for PHP 7.2
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install ca-certificates apt-transport-https \
    && wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add - \
    && echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list

# Install/Setup PHP 7.2 and other packages needed for Pimcore
RUN apt-get update \
    && apt-get -y install --no-install-recommends \
    php7.2 php7.2-cli php7.2-common php7.2-opcache php7.2-curl php7.2-mbstring php7.2-mysql \
    php7.2-zip php7.2-xml php7.2-intl php7.2-gd php7.2-bz2 php7.0-bcmath php7.2-dev php7.2-ldap php7.2-common \
    bzip2 unzip memcached ntpdate libxrender1 libfontconfig1 automake libtool nasm make pkg-config libz-dev \
    build-essential openssl zlib1g-dev libicu-dev libbz2-dev libpng-dev libc-client-dev \
    libkrb5-dev libxml2-dev libxslt1.1 libxslt1-dev locales locales-all imagemagick inkscape libssl-dev rcconf \
    lynx autoconf libmagickwand-dev pngnq pngcrush xvfb cabextract libfcgi0ldbl poppler-utils rsync \
    xz-utils libreoffice libreoffice-math xfonts-75dpi jpegoptim monit aptitude pigz libtext-template-perl \
    mailutils redis-server php-apcu git mariadb-server nano curl
ADD php.ini /etc/php/7.2/cli/php.ini

# set root password
RUN echo "root:root" | chpasswd

# Configure apache
RUN apt-get -y install apache2 systemd libapache2-mod-fcgid libapache2-mod-php \
    && a2dismod -f cgi autoindex mpm_worker mpm_prefork mpm_event \
    && a2enmod rewrite php7.2 \
    && rm /etc/apache2/sites-enabled/* \
    && chmod -R 775 /var/log/apache2
ADD vhost.conf /etc/apache2/sites-enabled/000-default.conf
RUN service apache2 restart

# setup startup script
ADD start-apache.sh /start-apache.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# ports
EXPOSE 80

# volumes
VOLUME ["/var/www", "/var/lib/mysql"]

WORKDIR /var/www
CMD ["/run.sh"]