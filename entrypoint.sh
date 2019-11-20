#!/bin/bash
set -e

# Install composer deps
composer install \
    --no-scripts \
    --no-autoloader \
    --no-interaction \
    --prefer-dist
composer update --lock

# Optimize auto loader
composer dump-autoload --optimize

# Install wordpress core
wp --allow-root core install \
  --title=${WORDPRESS_TITLE:-breeze} \
  --admin_user=${ADMIN_USER:-admin} \
  --admin_email=${ADMIN_EMAIL:-admin@admin.com} \
  --admin_password=${ADMIN_PASSWORD:-admin} \
  --url=${WORDPRESS_HOST}

# Activate default plugins
wp --allow-root plugin activate \
  post-duplicator \
  better-wp-security \
  classic-editor \
  wp-mail-smtp \
  advanced-custom-fields-pro \
  wp-rocket

# Ensure correct permalink structure
wp --allow-root option set permalink_structure ${PERMALINK_STRUCTURE:-'/blog/%postname%/'}

# Enable breeze theme
wp --allow-root theme activate breeze

# Ensure default posts to be removed
wp --allow-root post delete 1 2 3

# Ensure correct permissions
chown -R www-data:www-data /var/www/app/content

# Launch apache2
exec docker-php-entrypoint apache2-foreground
