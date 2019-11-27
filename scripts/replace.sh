#!/bin/bash
REPLACE_FROM="${WORDPRESS_HOST_PROTOCOL:-http}://${WORDPRESS_HOST}"
REPLACE_TO="{::{[WP_APP_HOST]}::}"

function wp_replace {
  wp --allow-root search-replace --recurse-objects --url=$1 $1 $2 > /dev/null
}

function wp_replace_from_to {
  echo -n "Replacing from \"${REPLACE_FROM}\" to \"${REPLACE_TO}\"..."
  wp_replace $REPLACE_FROM $REPLACE_TO
  echo " OK"
}

function wp_replace_to_from {
  echo -n "Replacing from \"${REPLACE_TO}\" to \"${REPLACE_FROM}\"..."
  wp_replace $REPLACE_TO $REPLACE_FROM
  echo " OK"
}
