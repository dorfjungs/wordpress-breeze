#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/replace.sh

TIMESTAMP=$(date +%s)
SQLDUMP_NAME=/var/mnt/exports/sqldump_$TIMESTAMP.sql
UPLOADS_TAR=/var/mnt/exports/uploads_$TIMESTAMP.tar.gz

# Replace urls to a placeholder
wp_replace_from_to

# Export to gzipped sql file with placeholder
echo -n "Exporting database to \"${SQLDUMP_NAME}\"..."
wp --allow-root db export --single-transaction "$SQLDUMP_NAME" > /dev/null && gzip $SQLDUMP_NAME
echo " OK"

# Restore urls from the placeholder
wp_replace_to_from

# Compressing uploads
echo -n "Compressing uploads from \"/var/mnt/uploads\"..."
cd /var/mnt/uploads && tar -czf $UPLOADS_TAR .
echo " OK"
