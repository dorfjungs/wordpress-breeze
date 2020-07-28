# Production
You can easily use the same container (`dorfjungs/wordpress-breeze`) in a production environment.
You just need to make some changes to the image itself.

## Creating a child Dockerfile for production
To do so, you can inherit from the parent image and copy the files to the right places.
A simple production image could look like this:

```Dockerfile
FROM dorfjungs/wordpress-breeze:v1.*

# Copy user files
COPY ./assets/dist /var/mnt/assets
COPY ./composer.json /var/mnt/composer/composer.json
COPY ./src /var/mnt/src
COPY ./assets /var/mnt/assets
COPY ./templates /var/mnt/templates
COPY ./.exports /var/mnt/exports

# Remove unused symlinks
RUN rm /var/www/app/vendor

# Retrieving ACF_PRO_KEY which is mandatory for the install
ARG ACF_PRO_KEY
ENV ACF_PRO_KEY=$ACF_PRO_KEY

# Install composer deps
RUN composer install \
    --no-scripts \
    --no-autoloader \
    --no-interaction \
    --prefer-dist && \
  composer update --lock

# Simple health check for production
HEALTHCHECK --interval=30s --timeout=30s --start-period=30s --retries=4 \
  CMD curl -f http://localhost:8080/ || exit 1
```