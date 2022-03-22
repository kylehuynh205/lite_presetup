#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

#inital_path
inital_path=$PWD

#current site
site_path="${inital_path}"/..

public_files_path="${site_path}"/web/sites/default/files
private_files_path="${site_path}"/web/sites/default/private_files

#Enable access control modules
drush -y pm:enable group groupmedia group_permissions gnode islandora_group_defaults media_library_edit

# enable islandora access control with group
drush -y pm:enable islandora_group group_solr

# import group_permissions
drush -y config-import --partial --source=$"${inital_path}"/config/group_permission

mkdir "${private_files_path}"
#chown -Rf www-data:www-data "${private_files_path}"

# update settings.php with path of private file system
chmod 777 "${site_path}"/web/sites/default/settings.php 
cd "${site_path}"/web/sites/default && sed -i "/file_private_path/c\$settings['file_private_path'] = 'sites/default/private_files';" settings.php && chmod 444 settings.php && cd "${inital_path}"

# configure file system
drush -y config-import --partial --source=$"${inital_path}"/config/private_file_system/system

# configure media's file fields
drush -y config-import --partial --source=$"${inital_path}"/config/private_file_system/media


# Apply patch for file_entity
wget https://raw.githubusercontent.com/digitalutsc/override_permission_file_entity/main/override_file_access.patch -P "${site_path}"/web/modules/contrib/file_entity
cd "${site_path}"/web/modules/contrib/file_entity && patch -p1 < override_file_access.patch && cd "${inital_path}"


# import access control fields
drush -y config-import --partial --source=$PWD/config/access_control

# import config for access controle field with taxonomy terms
drush -y config-set --input-format=yaml islandora_group.config collection_based "islandora_access"
drush -y config-set --input-format=yaml islandora_group.config role_based "islandora_access"
drush -y config-set --input-format=yaml islandora_group.config node-type-access-fields '{"article":"field_access_terms","islandora_object":"field_access_terms","page":"field_access_terms"}'
drush -y config-set --input-format=yaml islandora_group.config media-type-access-fields '{"audio":"field_access_terms","document":"field_access_terms","file":"field_access_terms","image":"field_access_terms","remote_video":"field_access_terms","video":"field_access_terms","web_archive":"field_access_terms"}'

# enable default values for access control terms 
drush -y pm:enable field_access_terms_defaultvalue

# disable setup modules
drush -y pmu islandora_group_defaults field_access_terms_defaultvalue
