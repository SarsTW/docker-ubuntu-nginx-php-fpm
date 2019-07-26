FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get clean && apt-get -y update \
    && apt-get install -y locales software-properties-common supervisor iputils-ping traceroute mtr net-tools dnsutils \
    && locale-gen en_US.UTF-8 \
    && LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php \
    && apt-get -y update && apt-get install -y \
       nginx=1.10.* \
       php7.3-bcmath php7.3-bz2 php7.3-cli php7.3-common php7.3-curl \
       php7.3-cgi php7.3-dev php7.3-fpm php7.3-gd php7.3-gmp php7.3-imap php7.3-intl \
       php7.3-json php7.3-ldap php7.3-mbstring php7.3-mysql \
       php7.3-odbc php7.3-opcache php7.3-pgsql php7.3-phpdbg php7.3-pspell \
       php7.3-readline php7.3-recode php7.3-soap php7.3-sqlite3 \
       php7.3-tidy php7.3-xml php7.3-xmlrpc php7.3-xsl php7.3-zip \
       php-tideways \
    && apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf \
    && sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/7.3/cli/php.ini \
    && sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/7.3/fpm/php.ini \
    && sed -i "s/display_errors = Off/display_errors = On/" /etc/php/7.3/fpm/php.ini \
    && sed -i "s/upload_max_filesize = .*/upload_max_filesize = 10M/" /etc/php/7.3/fpm/php.ini \
    && sed -i "s/post_max_size = .*/post_max_size = 12M/" /etc/php/7.3/fpm/php.ini \
    && sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.3/fpm/php.ini \
    && sed -i -e "s/pid =.*/pid = \/var\/run\/php7.3-fpm.pid/" /etc/php/7.3/fpm/php-fpm.conf \
    && sed -i -e "s/error_log =.*/error_log = \/proc\/self\/fd\/2/" /etc/php/7.3/fpm/php-fpm.conf \
    && sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.3/fpm/php-fpm.conf \
    && sed -i "s/listen = .*/listen = 9000/" /etc/php/7.3/fpm/pool.d/www.conf \
    && sed -i "s/;clear_env = no/clear_env = no/" /etc/php/7.3/fpm/pool.d/www.conf \
    && sed -i "s/;catch_workers_output = .*/catch_workers_output = yes/" /etc/php/7.3/fpm/pool.d/www.conf

ADD supervisord-nginx.conf /etc/supervisor/conf.d/nginx.conf
ADD supervisord-php-fpm.conf /etc/supervisor/conf.d/php-fpm.conf
ADD nginx.conf /etc/nginx/sites-enabled/default

EXPOSE 80

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]

