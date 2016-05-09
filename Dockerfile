FROM php:apache

RUN apt-get update && apt-get install -y git curl

RUN cd /tmp/ \
    && php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php \
    && php -r "if (hash('SHA384', file_get_contents('composer-setup.php')) . PHP_EOL === file_get_contents('https://composer.github.io/installer.sig')) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/bin/composer \
    && export PATH=$PATH.":~/.composer/vendor/bin"

RUN cd /opt/ \
    && git clone --depth=1 https://github.com/phalcon/zephir.git \
    && find zephir -type f -print0 | xargs -0 sed -i 's/sudo //g' \
    && cd /opt/zephir \
    && ./install -c

RUN git clone --branch 2.1.x --depth=1 https://github.com/phalcon/cphalcon.git /opt/cphalcon \
    && cd /opt/cphalcon \
    && zephir fullclean \
    && zephir build —backend=ZendEngine3 \
    && echo "extension=phalcon.so" >> /usr/local/etc/php/conf.d/40-phalcon.ini
