#!/bin/bash

#inital_path
inital_path=$PWD

#current site
site_path="${inital_path}"/..

# import advanced search configs
drush -y config-import --partial --source=$"${inital_path}"/config/advanced_search
