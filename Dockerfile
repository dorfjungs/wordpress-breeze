FROM php:7.2.2-apache

# Install PHP extensions
RUN apt-get update && apt-get install -y \
      libicu-dev \
      libpq-dev \
      libmcrypt-dev \
      zlib1g-dev \
      libcurl4-gnutls-dev \
      libfreetype6-dev \
      libjpeg62-turbo-dev \
      libpng-dev \
      mysql-client \
      unzip \
      git \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-install \
      exif \
      intl \
      mbstring \
      pcntl \
      mysqli \
      pdo \
      pdo_mysql \
      zip \
      opcache \
      curl \
      gd

# Store PHP Configs at /usr/local/etc/php/conf.d
RUN echo "upload_max_filesize = 1G" >> /usr/local/etc/php/conf.d/upload_large_dumps.ini \
    && echo "post_max_size = 1G" >> /usr/local/etc/php/conf.d/upload_large_dumps.ini

# Install wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x ./wp-cli.phar && mv wp-cli.phar /usr/bin/wp
RUN echo 'alias wp="wp --allow-root"' >>  ~/.bashrc

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN composer config --global repo.packagist composer https://packagist.org
RUN composer global require hirak/prestissimo

# Configure apache
RUN a2enmod rewrite
COPY ./config/apache-vhost.conf /etc/apache2/sites-available/0-wordpress.conf
RUN a2dissite 000-default.conf && a2ensite 0-wordpress.conf

# Change uid and gid of apache to docker user uid/gid
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

# Define root html dir as work dir
WORKDIR /var/www/app

# Add app
COPY . /var/www/app

# Expose volumes
VOLUME /var/www/app/content/themes/breeze/src
VOLUME /var/www/app/content/themes/breeze/assets
VOLUME /var/www/app/content/themes/breeze/templates
VOLUME /var/www/app/content/uploads
VOLUME /var/www/app/vendor
VOLUME /var/www/app/composer

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh

# Set correct permissions
RUN chown -R www-data:www-data /var/www/app

ENTRYPOINT [ "/entrypoint.sh" ]
