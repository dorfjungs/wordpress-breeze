FROM davideperozzi/apache-php:7.3

# Install netcat
RUN apt-get -q update && apt-get -qy install \
    netcat \
    bsdtar \
    bc \
  && rm -r /var/lib/apt/lists/*

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

# Define theme dir
ENV THEME_DIR=/var/www/app/content/themes/breeze

# Add app
COPY . /var/www/app

# Expose volumes
VOLUME /var/mnt/src \
       /var/mnt/assets \
       /var/mnt/templates \
       /var/mnt/composer \
       /var/mnt/uploads \
       /var/mnt/vendor \
       /var/mnt/exports

# Create symlink
RUN ln -sf /var/mnt/src $THEME_DIR/src && \
    ln -sf /var/mnt/assets/ $THEME_DIR/assets && \
    ln -sf /var/mnt/templates $THEME_DIR/templates && \
    ln -sf /var/mnt/uploads /var/www/app/content/uploads && \
    ln -sf /var/mnt/vendor /var/www/app/vendor && \
    ln -sf /var/mnt/composer /var/www/app/composer

# Set correct permissions
RUN chown -R www-data:www-data /var/www/app

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh

# Download wait-for
RUN wget -O /wait-for.sh https://raw.githubusercontent.com/eficode/wait-for/8d9b4446df0b71275ad1a1c68db0cc2bb6978228/wait-for
RUN chmod +x /wait-for.sh

ENTRYPOINT [ "/entrypoint.sh" ]
