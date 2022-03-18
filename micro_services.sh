#current site
site_path=/var/www/drupal

#configure_search_api_solr_module
SOLR_CORE=ISLANDORA
solr_host=islandora.traefik.me:8983
solr_core=multisite

#iiif server
cantaloupe_url=https://islandora.traefik.me/cantaloupe

#blazegraph
blazegraph_url=https://islandora.traefik.me:8082/bigdata
blazegraph_namespace=islandora


#Enable microservice modules
drush -y pm:enable advancedqueue_runner triplestore_indexer fits

# configure Advanced Queue
drush -y config-import --partial --source=$PWD/config/advanced_queue

# configure advanced queue runner
drush -y config-set --input-format=yaml advancedqueue_runner.runnerconfig drush_path "${site_path}"/vendor/drush/drush/drush
drush -y config-set --input-format=yaml advancedqueue_runner.runnerconfig root_path "${site_path}"
drush -y config-set --input-format=yaml advancedqueue_runner.runnerconfig auto-restart-in-cron 1
drush -y config-set --input-format=yaml advancedqueue_runner.runnerconfig queues "
- default: default
- triplestore: triplestore
- fits:fits
"
drush -y config-set --input-format=yaml advancedqueue_runner.runnerconfig interval '5'
drush -y config-set --input-format=yaml advancedqueue_runner.runnerconfig mode limit

# Configure Rest Services (enable jsonld endpoint)
drush -y config-import --partial --source=$PWD/config/rest

#configure triplestore_indexer
drush -y config-set --input-format=yaml triplestore_indexer.triplestoreindexerconfig server-url "${blazegraph_url}"
drush -y config-set --input-format=yaml triplestore_indexer.triplestoreindexerconfig namespace "${blazegraph_namespace}"
drush -y config-set --input-format=yaml triplestore_indexer.triplestoreindexerconfig method-of-op advanced_queue
drush -y config-set --input-format=yaml triplestore_indexer.triplestoreindexerconfig aqj-max-retries 5
drush -y config-set --input-format=yaml triplestore_indexer.triplestoreindexerconfig aqj-retry_delay 120
drush -y config-set --input-format=yaml triplestore_indexer.triplestoreindexerconfig select-auth-method
drush -y config-set --input-format=yaml triplestore_indexer.triplestoreindexerconfig advancedqueue-id triplestore
drush -y config-set --input-format=yaml triplestore_indexer.triplestoreindexerconfig content-type-to-index "islandora_object: islandora_object"

# Setup Fits
mkdir -p /opt/fits
wget https://github.com/harvard-lts/fits/releases/download/1.4.0/fits-latest.zip -P /opt/fits
unzip /opt/fits/fits-latest.zip

#fits
fits_url=/opt/fits/fits.sh
fits_remote_url=http://islandora.traefik.me:8080/fits/examine

# configure fits
drush -y config-set --input-format=yaml fits.fitsconfig fits-method local
drush -y config-set --input-format=yaml fits.fitsconfig fits-path "${fits_url}"
drush -y config-set --input-format=yaml fits.fitsconfig fits-advancedqueue_id fits
drush -y config-set --input-format=yaml fits.fitsconfig fits-extract-ingesting 1
drush -y config-set --input-format=yaml fits.fitsconfig aqj-max-retries  5
drush -y config-set --input-format=yaml fits.fitsconfig aqj-retry_delay 120
drush -y config-set --input-format=yaml fits.fitsconfig fits-default-fields "
- field_fits_checksum
- field_fits_file_format
- field_fits
"
