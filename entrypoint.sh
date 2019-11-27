#!/bin/bash
set -e

COMPOSER_CORE=./composer.json
COMPOSER_CONSUMER=/var/mnt/composer/composer.json

function getModifiedDate {
  if [ -f "$1" ]; then
    echo "$(date -r $1 '+%m%d%Y%H%M%S')"
  else
    echo "0"
  fi
}

function getLockFilePath {
  echo ${2:-\.}/$1.modlock
}

function lockModifiedFile {
  echo $(getModifiedDate $1) > $(getLockFilePath $2 $3)
}

function wasFileModified {
  local lastModDate=$(getModifiedDate $1)
  local lockFilePath=$(getLockFilePath $2 $3)

  if [ ! -f "$lockFilePath" ]; then
    echo "0" > $lockFilePath
  fi

  local lockModDate=$(cat $lockFilePath)

  if [ "$lastModDate" != "$lockModDate" ]; then
    echo true
    return
  fi

  echo false
}

# Wait for datbabse to be available
case $DATABASE_HOST in
  (*:*) DB_HOST=${DATABASE_HOST%:*} DB_PORT=${DATABASE_HOST##*:};;
  (*) DB_HOST=$DATABASE_HOST DB_PORT=3306;;
esac

echo -n "Waiting for ${DB_HOST}:${DB_PORT}..."
sh /wait-for.sh "${DB_HOST}:${DB_PORT}" -t 60
echo " OK"

# Handle composer dependencies
if \
  [ ! -z "$APPLICATION_ENV" ] && \
  [ "$APPLICATION_ENV" == 'dev' ] || \
  [ "$APPLICATION_ENV" == 'development' ]; then
    composer0Modified=$(wasFileModified $COMPOSER_CORE composer0 $(pwd))
    composer1Modified=$(wasFileModified $COMPOSER_CONSUMER composer1 $(pwd))

    if [ "$composer0Modified" == true ] || [ "$composer1Modified" == true ]; then
      # Install composer deps
      composer install \
          --no-scripts \
          --no-autoloader \
          --no-interaction \
          --prefer-dist

      composer update --lock

      # Optimize auto loader
      composer dump-autoload --optimize

      if [ $? -eq 0 ]; then
        lockModifiedFile $COMPOSER_CORE composer0 $(pwd)
        lockModifiedFile $COMPOSER_CONSUMER composer1 $(pwd)
      fi

      lockModifiedFile $COMPOSER_CORE composer0 $(pwd)
      lockModifiedFile $COMPOSER_CONSUMER composer1 $(pwd)
    else
      echo "The Composer configs are unchanged: Skipping updates!"
    fi
else
  echo "Skipping composer install for production!"
fi

# Install or import wordpress core
if [ -z "${SKIP_WP_CORE_INSTALL}" ]; then
  if ! $(wp --allow-root core is-installed); then
    if [ ! -z "$(ls -A /var/mnt/exports)" ]; then
      bash ./scripts/import.sh
    else
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
    fi
  else
    echo "Wordpress is already installed: Skipping install!"
  fi
else
  echo "Wordpress core installation was disabled: Skipping install!"
fi

# Ensure correct permissions
chown -R www-data:www-data /var/www/app/content
chown -R www-data:www-data /var/mnt/uploads

# Launch apache2
exec docker-php-entrypoint apache2-foreground
