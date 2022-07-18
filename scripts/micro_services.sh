#!/bin/bash

 #inital_path
inital_path=$PWD

#current site
site_path=/var/www/html/drupal

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    exit 0
fi

if [ $1 == "playbook" ]; then
    #blazegraph
    blazegraph_url=http://localhost:8080/bigdata
    blazegraph_namespace=islandora
    
    #fits
    fits_mode="remote"
    fits_url=http://localhost:8080/fits/examine
    fits_config_var="fits-server-url"
        
elif [ $1 == "docker" ]; then
    #blazegraph
    blazegraph_url=https://islandora.traefik.me:8082/bigdata
    blazegraph_namespace=islandora

    #fits
    fits_mode="local"
    fits_url=/opt/fits-1.4.1/fits.sh
    fits_config_var="fits-path"
    
    # Setup Fits
    mkdir -p /opt/fits
    wget https://github.com/harvard-lts/fits/releases/download/1.4.0/fits-latest.zip -P /opt/fits
    unzip /opt/fits/fits-latest.zip
else
  echo "Please enter which environment you running this script on"
  exit 0
fi


#Enable microservice modules
drush -y pm:enable advancedqueue_runner triplestore_indexer fits

# configure Advanced Queue
drush -y config-import --partial --source=$PWD/../configs/advanced_queue

# configure advanced queue runner
drush -y config-set --input-format=yaml advancedqueue_runner.settings drush_path "${site_path}"/vendor/drush/drush/drush
drush -y config-set --input-format=yaml advancedqueue_runner.settings root_path "${site_path}"
drush -y config-set --input-format=yaml advancedqueue_runner.settings auto-restart-in-cron 1
drush -y config-set --input-format=yaml advancedqueue_runner.settings queues "
- default
- triplestore
- fits
"
drush -y config-set --input-format=yaml advancedqueue_runner.settings interval '5'
drush -y config-set --input-format=yaml advancedqueue_runner.settings mode limit
drush -y config-set --input-format=yaml advancedqueue_runner.settings started_at $(date +%s)
drush cron

# Configure Rest Services (enable jsonld endpoint)
drush -y config-import --partial --source=$PWD/../configs/rest

#configure triplestore_indexer
drush -y config-set --input-format=yaml triplestore_indexer.settings server_url "${blazegraph_url}"
drush -y config-set --input-format=yaml triplestore_indexer.settings namespace "${blazegraph_namespace}"
drush -y config-set --input-format=yaml triplestore_indexer.settings method_of_op advanced_queue
drush -y config-set --input-format=yaml triplestore_indexer.settings aqj_max_retries 5
drush -y config-set --input-format=yaml triplestore_indexer.settings aqj_retry_delay 120
drush -y config-set --input-format=yaml triplestore_indexer.settings select_auth_method digest
drush -y config-set --input-format=yaml triplestore_indexer.settings admin_username admin
drush -y config-set --input-format=yaml triplestore_indexer.settings admin_password islandora
drush -y config-set --input-format=yaml triplestore_indexer.settings advancedqueue_id triplestore
drush -y config-set --input-format=yaml triplestore_indexer.settings content_type_to_index "islandora_object: islandora_object"

# configure fits
drush -y config-set --input-format=yaml fits.fitsconfig fits-method "${fits_mode}"
drush -y config-set --input-format=yaml fits.fitsconfig "${fits_config_var}" "${fits_url}"
drush -y config-set --input-format=yaml fits.fitsconfig fits-advancedqueue_id fits
drush -y config-set --input-format=yaml fits.fitsconfig fits-extract-ingesting 1
drush -y config-set --input-format=yaml fits.fitsconfig aqj-max-retries  5
drush -y config-set --input-format=yaml fits.fitsconfig aqj-retry_delay 120
drush -y config-set --input-format=yaml fits.fitsconfig fits-default-fields "
- field_fits_checksum
- field_fits_file_format
- field_fits
"
