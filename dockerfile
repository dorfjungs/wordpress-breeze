FROM davideperozzi/apache-php:7.3

# Install wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x ./wp-cli.phar && mv wp-cli.phar /usr/bin/wp
RUN echo 'alias wp="wp --allow-root"' >>  ~/.bashrc

# Install improved package installer for composer
RUN composer global require hirak/prestissimo

# Configure apache
RUN a2enmod rewrite
COPY ./config/apache-vhost.conf /etc/apache2/sites-available/0-wordpress.conf
RUN a2dissite 000-default.conf && a2ensite 0-wordpress.conf

# Define root html dir as work dir
WORKDIR /var/www/app

# Add app
COPY . /var/www/app

# Expose volumes
VOLUME /var/mnt/src
VOLUME /var/mnt/assets
VOLUME /var/mnt/templates
VOLUME /var/mnt/composer
VOLUME /var/mnt/uploads
VOLUME /var/mnt/vendor

# Create symlinks
RUN ln -s /var/www/app/content/themes/breeze/src /var/mnt/src
RUN ln -s /var/www/app/content/themes/breeze/assets /var/mnt/assets
RUN ln -s /var/www/app/content/themes/breeze/templates /var/mnt/templates
RUN ln -s /var/www/app/content/uploads /var/mnt/uploads
RUN ln -s /var/www/app/vendor /var/mnt/vendor
RUN ln -s /var/www/app/composer /var/mnt/composer

# Set correct permissions
RUN chown -R www-data:www-data /var/www/app

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
