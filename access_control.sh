#current site
site_path=$PWD/..

public_files_path="${site_path}"/web/sites/default/files
private_files_path="${site_path}"/web/sites/default/private_files

#Enable microservice modules
drush -y pm:enable group groupmedia group_permissions gnode islandora_group_defaults islandora_group group_solr

mkdir "${private_files_path}"
chown -Rf www-data:www-data "${private_files_path}"

# update settings.php with path of private file system
chmod 777 "${site_path}"/web/sites/default/settings.php && sed -i "/file_private_path/c\$settings['file_private_path'] = 'sites/default/private_files';" "${site_path}"/web/sites/default/settings.php && chmod 444 "${site_path}"/web/sites/default/settings.php

# configure access control fields
drush -y config-import --partial --source=$PWD/config/private_file_system


# Apply patch for file_entity
wget https://raw.githubusercontent.com/digitalutsc/override_permission_file_entity/main/override_file_access.patch -P "${site_path}"/web/modules/contrib/file_entity
patch -u "${site_path}"/web/modules/contrib/file_entity/file_entity.module -i "${site_path}"/web/modules/contrib/file_entity/override_file_access.patch

# import access control fields
drush -y config-import --partial --source=$PWD/config/access_control