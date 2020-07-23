#!/bin/bash
set -e

RANDOM=$(date +%s%N)
COMPOSER_CORE=./composer.json
COMPOSER_CONSUMER=/var/mnt/composer/composer.json

function random {
  echo $(printf "%0.4f\n" $(bc -l <<< "scale=4; ${RANDOM}/32767"))
}

function randomSleep {
  local current=$(random)
  local sleep=$(echo "1 + $(random) * 4" | bc -l);

  echo "Sleeping for ${sleep}s"
  sleep $sleep
}

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

# Install patternlab if required
PATTERN_CONSUMER=/var/mnt/templates/pattern
PATTERNLAB_DIR=/var/www/app/patternlab/pattern

if [ ! -z "$PATTERNLAB" ] && [ ! -d "$PATTERNLAB_DIR" ]; then
  echo "Installing patternlab..."
  cd patternlab
  composer create-project --no-interaction pattern-lab/edition-twig-standard pattern

  if [ ! -d "$PATTERN_CONSUMER" ]; then
    echo "Copying initial pattern files..."
    mkdir $PATTERN_CONSUMER
    rsync -a $PATTERNLAB_DIR/source/** $PATTERN_CONSUMER
    chown -R www-data:www-data $PATTERNLAB_DIR
    chmod -R 777 $PATTERN_CONSUMER
  fi

  echo "Linking templates for patternlab..."
  chown -R www-data:www-data $PATTERNLAB_DIR
  rm -rf $PATTERNLAB_DIR/source
  ln -sf $PATTERN_CONSUMER $PATTERNLAB_DIR/source
  cd ..
else
  echo "Skipping patternlab install!"
fi

# Resetting database if necessary
if [ ! -z "$RESET_DATABASE_ON_STARTUP" ] && [ "$RESET_DATABASE_ON_STARTUP" == "1" ]; then
  # Sleep for random amount of time in order to miminize the probability of
  # colliding with other replicas
  randomSleep

  # Check if it was already installed
  if $(wp core is-installed); then
    echo -n "Resetting database due \"RESET_DATABASE_ON_STARTUP\"..."
    cd /var/www/app && wp db reset --yes --quiet
    echo " OK"
  else
    echo "Skipping database reset. Wordpress is not installed!"
  fi
fi

# Install or import wordpress core
if [ -z "${SKIP_WP_CORE_INSTALL}" ]; then
  if ! $(wp core is-installed); then
    if [ ! -z "$(ls -A /var/mnt/exports/sqldump_* 2> /dev/null)" ] &&
       [ ! -z "$(ls -A /var/mnt/exports/uploads_* 2> /dev/null)" ];
    then
      bash ./scripts/import.sh
    else
      wp core install \
        --title=${WORDPRESS_TITLE:-breeze} \
        --admin_user=${ADMIN_USER:-admin} \
        --admin_email=${ADMIN_EMAIL:-admin@admin.com} \
        --admin_password=${ADMIN_PASSWORD:-admin} \
        --url="${WORDPRESS_HOST_PROTOCOL:-http}://${WORDPRESS_HOST}"

      # Activate default plugins
      wp plugin activate \
        post-duplicator \
        better-wp-security \
        classic-editor \
        wp-mail-smtp \
        advanced-custom-fields-pro \
        wp-rocket

      # Ensure correct permalink structure
      wp option set permalink_structure ${PERMALINK_STRUCTURE:-'/blog/%postname%/'}

      # Enable breeze theme
      wp theme activate breeze

      # Ensure default posts to be removed
      wp post delete 1 2 3
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
