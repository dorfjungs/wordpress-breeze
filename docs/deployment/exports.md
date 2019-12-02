# Exports
Exports simply allow the framework to export the given state of your wordpress page.
This includes the whole database and uploads within your instance.

## Creating an export
First make sure you mounted an accesible volume to `/var/mnt/exports`.
This ensures the exports will live between different versions of your application.
After you attached a proper volumes you can simply execute the `export.sh` script
inside the container like this:

```sh
docker exec -t YourCurrentContainer /var/www/app/scripts/export.sh
```

## Importing an export
When the correct exports folder is mounted the container automatically checks if
he needs an import. If he needs and import, in case it's a plane database, it'll
use the latest export from the mounted directory.
> All that happens inside the entrypoint.sh

## Pushing the exports to the SCM
Since the exports are compressed and shouldn remain in an acceptable size range,
you can easily push the exports to the SCM in order to share it with other devs.