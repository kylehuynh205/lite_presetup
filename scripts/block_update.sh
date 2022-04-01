#!/bin/bash

#inital_path
inital_path=$PWD

#current site
site_path="${inital_path}"/../..

DRUPAL_THEME=olivero
drush -y config-import --partial --source "${inital_path}"/../configs/blocks_"${DRUPAL_THEME}"

DOMAIN=localhost:8000
DRUPAL_DEFAULT_ACCOUNT_PASSWORD=islandora
URL="http://$DOMAIN/term_from_uri?_format=json&uri=https%3A%2F%2Fschema.org%2FBook"
BOOK_TERM_ID=$(curl -u admin:"$DRUPAL_DEFAULT_ACCOUNT_PASSWORD" -X GET "$URL" | jq .[].tid[].value)
echo "book term id: $BOOK_TERM_ID"
MANIFEST_URL="https://$DOMAIN/node/[node:nid]/book-manifest"

# Set book-manifest url
drush -y --input-format=yaml config:set block.block.miradorblock visibility.term "
id: term
tid:
  -
    target_id: '$BOOK_TERM_ID'
negate: false
context_mapping: {  }"

# Set book-manifest url
drush -y config:set block.block.miradorblock settings.iiif_manifest_url "${MANIFEST_URL}"
