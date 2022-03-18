#!/bin/bash

#inital_path
inital_path=$PWD

#current site
site_path="${inital_path}"/..

public_files_path="${site_path}"/web/sites/default/files
private_files_path="${site_path}"/web/sites/default/private_files

#Enable microservice modules
drush -y pm:enable group groupmedia group_permissions gnode islandora_group_defaults islandora_group group_solr

mkdir "${private_files_path}"
#chown -Rf www-data:www-data "${private_files_path}"

# update settings.php with path of private file system
chmod 777 "${site_path}"/web/sites/default/settings.php 
cd "${site_path}"/web/sites/default && sed -i "/file_private_path/c\$settings['file_private_path'] = 'sites/default/private_files';" settings.php && chmod 444 "${site_path}"/web/sites/default/settings.php && cd "${inital_path}"

# configure file system
drush -y config-import --partial --source=$"${inital_path}"/config/private_file_system/system

# configure media's file fields
drush -y config-import --partial --source=$"${inital_path}"/config/private_file_system/media


# Apply patch for file_entity
wget https://raw.githubusercontent.com/digitalutsc/override_permission_file_entity/main/override_file_access.patch -P "${site_path}"/web/modules/contrib/file_entity
cd "${site_path}"/web/modules/contrib/file_entity && patch -p1 < override_file_access.patch && cd "${inital_path}"


# import access control fields
drush -y config-import --partial --source=$PWD/config/access_control
