#!/bin/bash

#inital_path
inital_path=$PWD

#current site
site_path="${inital_path}"/..

mkdir "${private_files_path}"
#chown -Rf www-data:www-data "${private_files_path}"

# update settings.php with path of private file system
chmod 777 "${site_path}"/web/sites/default/settings.php 
cd "${site_path}"/web/sites/default && sed -i "/file_private_path/c\$settings['file_private_path'] = 'sites/default/private_files';" settings.php && chmod 444 "${site_path}"/web/sites/default/settings.php && cd "${inital_path}"
