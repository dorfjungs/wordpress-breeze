# Installation

To use this package you can just pull the latest image version from [dockerhub](https://hub.docker.com/r/dorfjungs/wordpress-breeze). This package covers things like initially installing plugins, creating an admin user with a defined password, creating the database from scratch, injecting the config from the user, dynamically handling wordpress templates (a.k.a pages in this context). The idea is to have a new wordpress instance up and running as fast as possible. In a perfect scenario with one command.

## Integration
To use the package inside your a `docker-compose.yml` you can either reference the image directly or create a new `Dockerfile` if you want to do some customization to the base distribution. A basic setup with `docker-compose` could look like this:

```yml
app:
  image: dorfjungs/wordpress-breeze:v1.*
  volumes:
    src:/var/mnt/src
    vendor:/var/mnt/vendor
    assets:/var/mnt/assets
    uploads:/var/mnt/uploads
    exports:/var/mnt/exports
    composer:/var/mnt/composer
    templates:/var/mnt/templates
  environment:
    WORDPRESS_HOST: yourpage.localhost
    WORDPRESS_TITLE: yourPage
    DATABASE_HOST: database
    DATABASE_NAME: someDbName
    DATABASE_USER: someDbUser
    DATABASE_PASS: aComplexDatabasePassword
```

## The entrypoint
After you set up the service with a **MySQL-Database** you can start the stack.
The [`entrypoint.sh`](https://github.com/dorfjungs/wordpress-breeze/blob/master/entrypoint.sh) will help you with initial set-up, keeping your composer packages up-to-date and if you did enable patternlab it'll also manage that.
