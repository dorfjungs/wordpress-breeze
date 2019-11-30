#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/replace.sh

BASE_DIR=/var/mnt/exports
SQLDUMP_EXPORT=$(ls $BASE_DIR/sqldump_* 2> /dev/null | sort -n -t _ -k 2 | tail -1)
UPLOADS_EXPORT=$(ls $BASE_DIR/uploads_* 2> /dev/null | sort -n -t _ -k 2 | tail -1)

if [ -z "$SQLDUMP_EXPORT" ]; then
  echo "ERR: No sqldump found to be imported!"
  exit 1
fi

if [ -z "$UPLOADS_EXPORT" ]; then
  echo "ERR: No uploads found to be imported!"
  exit 1
fi


echo -n "Importing sqldump \"${SQLDUMP_EXPORT}\"..."
gzip -c -d $SQLDUMP_EXPORT | wp --allow-root db import - > /dev/null
echo " OK"

# Replace urls from the placeholder
wp_replace_to_from

# Unzip uploads
echo -n "Extracting uploads to \"/var/mnt/uploads\"..."
tar -xvf $UPLOADS_EXPORT --directory /var/mnt/uploads > /dev/null
echo " OK"
