#!/bin/bash

#inital_path
inital_path=$PWD

#current site
site_path="${inital_path}"/../..

# import advanced search configs
drush -y config-import --partial --source=$"${inital_path}"/../configs/advanced_search

# enable Lunce search
drush -y config-set --input-format=yaml advanced_search.settings lucene_on_off 1
